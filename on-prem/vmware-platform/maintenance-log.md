# VMware Platform Maintenance Log

Use this log for ESXi host and vCenter platform checks. Keep per-VM operating
system and application maintenance in the matching VM folder.

## 2026-05-31 - MSA2062 Firmware Update To IN210P003

- Scope: updated the HPE MSA 2062 SAN at Niederanven - Atelier from firmware
  `IN210P002` to `IN210P003`.
- Initial issue: the Windows flash component workflow failed, and a wrong
  extracted bundle (`IN300R007_hpe_enc.sfw`, for the MSA 2070/2072 line) was
  rejected by the array with a version-verify/downgrade compatibility message.
- Correct package: `firmware-hpe-msa-2060-IN210P003_3.0.0-1.1.x86_64.rpm`.
  The payload was extracted on macOS with `rpm2cpio`/`cpio`; the extracted
  `IN210P003...hpe_enc.sfw` file was used for the update.
- SMU upload initially remained stuck as a failed firmware upload at `99%`.
  `restart mc` / full Management Controller restart restored `System Ready:
  Ready`, but did not clear the failed upload record by itself.
- Recovery path: uploaded the correct `IN210P003` `.sfw` file via SFTP to
  controller management IP `192.168.5.210` on port `1022`; upload completed
  successfully and started the partner firmware update flow.
- Pre-update checks:
  - `check firmware-upgrade-health` returned `Pass`;
  - controller redundancy was `Active-Active ULP`;
  - Controller A and B were both `Operational`.
- Final verification:
  - `show firmware-update-status` reported `Completion Status: Success`,
    `Bundle Version: IN210P003`, and all update/reboot/cleanup steps `OK` or
    `N/A`;
  - `show redundancy-mode` reported `Controller Redundancy Status: Redundant`,
    both controllers `Operational`, `Other MC Status: Operational`, and
    `System Ready: Ready`;
  - `show versions` reported `IN210P003` on both Controller A and Controller B;
  - `show firmware-bundles` reported `IN210P003` as `Active` and `OK`, with
    `IN210P002` retained as `Available`.
- Notes: avoid activating `firmware bundle available` unless verifying the
  available bundle first, because during the failed-upload recovery the
  available bundle was still the older `IN110P002`.

## 2026-05-03 - SSH Login Path Planning

- Scope: created a dedicated VMware platform runbook for ESXi 8.x and vCenter
  SSH access.
- Decision: use temporary SSH enablement only, with one Ed25519 key per ESXi
  host and a separate key for the vCenter Server Appliance.
- ESX-D host alias proposed: `esx-d-host` for `192.168.5.203`.
- ESX-E host alias proposed: `esx-e-host`; management address still needs to be
  verified.
- vCenter alias proposed: `vcenter` for `192.168.5.15`.
- Follow-up: during the next VMware maintenance session, verify ESXi/vCenter
  versions, install only the required public keys, test aliases, record key
  fingerprints, and disable SSH again after checks.

## 2026-05-03 - VCSA Control Point Note

- Existing access: Peter reports working SSH access to VCSA at `192.168.5.15`.
- Decision: use VCSA as the preferred first control point for appliance health,
  vSphere inventory access, and ESXi management-network reachability tests.
- Boundary: VCSA SSH does not automatically grant ESXi shell access. ESXi SSH
  still needs to be enabled per host and ESXi root credentials or an existing
  host key are still required to install `/etc/ssh/keys-root/authorized_keys`.
- Follow-up: verify the three ESXi host management IPs from vCenter, then test
  VCSA-to-host reachability on ports `443` and `22`.

## 2026-05-03 - VCSA ProxyJump Blocked

- Observed: `ssh -J vcenter root@192.168.5.203` reached VCSA but failed with
  `channel 0: open failed: administratively prohibited: open failed`.
- Interpretation: VCSA interactive SSH works, but SSH TCP forwarding is blocked
  by VCSA SSH policy, so `ProxyJump vcenter` is not currently a usable path.
- Also observed: local ESX-D host key was created as
  `~/.ssh/esx-d-host_ed25519`; public key fingerprint
  `SHA256:gNz4lLzet53OgqWuFmIitYByO/2Pu9XiDlJRxkD8aMc`.
- Follow-up: use direct workstation-to-ESXi SSH if reachable, or use VCSA
  interactive shell as a manual bridge. Avoid changing VCSA SSH daemon policy
  unless there is a deliberate security decision.

## 2026-05-03 - ESX-E SSH Key Setup

- ESX-E management IP confirmed as `192.168.5.205`.
- Peter enabled SSH on ESX-E and confirmed root login worked.
- Peter reports the SSH public key was installed on ESX-E.
- Follow-up: clean local `~/.ssh/config` so `Host esx-e-host` points directly
  to `192.168.5.205` and does not use `ProxyJump vcenter`, because VCSA
  forwarding is blocked.

## 2026-05-03 - ESX-C SSH Password Pending

- ESX-C management IP confirmed as `192.168.5.201`.
- Local alias proposed: `esx-c-host`.
- ESX-C host key prompt accepted locally; known host fingerprint observed as
  `SHA256:Pk/S1Wz/niFflfT8nRRQXISrzgmcy/PQlYDtKea6xPU`.
- Public key installation did not complete because password login timed out;
  likely wrong or unavailable root password.
- Decision: pause ESX-C and first confirm ESX-D and ESX-E key-based SSH.

## 2026-05-03 - ESXi Ed25519 Key Rejected

- Observed: ESX-D `/etc/ssh/keys-root/authorized_keys` exactly matched local
  `~/.ssh/esx-d-host_ed25519.pub`, but key-only login still failed.
- Root cause: Broadcom documents that `ssh-ed25519` is not supported for ESXi
  SSH. Supported algorithms include ECDSA and RSA SHA-2 families.
- Decision: switch ESXi host login keys from Ed25519 to RSA 4096 keys named
  `~/.ssh/esx-*-host_rsa`.

## 2026-05-03 - ESX-D RSA Key Confirmed

- ESX-D RSA 4096 key created locally:
  `~/.ssh/esx-d-host_rsa`.
- ESX-D RSA public key fingerprint:
  `SHA256:YCIU2Dyl9LGFbNMXa7hPEB5OouNqQOW/Im39cMe6HBo`.
- Key-only SSH confirmed with:
  `ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no esx-d-host 'hostname; vmware -vl'`.
- Confirmed host/version output: `ESXD`, VMware ESXi `8.0.3`
  build `24674464`, VMware ESXi `8.0 Update 3`.
- ESX-E RSA 4096 key created locally:
  `~/.ssh/esx-e-host_rsa`; fingerprint
  `SHA256:NC0JFDrnlHZNj6esFrv6IEmYuvKmgp/N7UCAQqzyY7Y`.
- ESX-C RSA 4096 key created locally:
  `~/.ssh/esx-c-host_rsa`; fingerprint
  `SHA256:ihlDK5MJuWbvxSWXmJRk1e1MMcJVFHtpkqxTt1xT91o`.
- Follow-up: install and test RSA keys for ESX-E and ESX-C. Clean local
  `~/.ssh/config` so ESXi host aliases use `_rsa` keys.

## 2026-05-03 - ESX-C Root Password Recovery Decision

- Issue: ESX-C root password appears lost or incorrect, blocking RSA public key
  installation on `192.168.5.201`.
- Supported recovery options from Broadcom guidance:
  - if host remains connected to vCenter and licensing/features allow it, reset
    the root password through Host Profiles or a vCenter-mediated method such
    as PowerCLI;
  - otherwise reinstall ESXi while preserving VMFS datastores, then reattach or
    re-register workloads.
- Decision: do not attempt unsupported boot-media/shadow-file edits during
  routine maintenance. First inspect ESX-C state from vCenter, verify whether it
  is connected and manageable, and check whether Host Profiles or PowerCLI
  reset is available.

## 2026-05-03 - ESX-C Ready For vCenter-Mediated Reset

- ESX-C is attached to vCenter 8 and reachable.
- ESX-C is in maintenance mode.
- ESX-C VMs are shut down.
- Decision: attempt a vCenter-mediated root password reset first, preferably
  via PowerCLI if Host Profiles are not available. This is lower risk than an
  ESXi reinstall because the host is still managed by vCenter.

## 2026-05-03 - ESX-C Console SSH Diagnostics

- ESX-C root login works through DCUI/ESXi Shell, so the root password is not
  lost.
- `pam_tally2 --user root` showed `0` failures before and after reset.
- `/etc/init.d/SSH restart` succeeded and reported SSH login enabled.
- `esxcli system ssh server config list` showed `permitrootlogin yes`,
  `challengeresponseauthentication yes`, and `usepam yes`.
- `esxcli system account list` showed root shell access `true`.
- `/var/log/auth.log` showed repeated current `sshd[...] FIPS mode initialized`
  entries, indicating SSH connections from the Mac are reaching the ESXi SSH
  daemon.
- Decision: install the RSA public key directly from ESXi Shell via console and
  test key-only SSH, avoiding password SSH quirks for ESX-C.

## 2026-05-03 - ESX-C Password SSH Next Step

- Constraint: Peter is remote over VPN and not on the same subnet; iLO HTML
  console cannot paste, making console public-key installation awkward.
- Decision: settle password SSH first by resetting the ESX-C root password from
  DCUI/ESXi Shell to a known temporary ASCII-only password, then test SSH from
  the Mac and inspect `/var/log/auth.log` if it still fails.

## 2026-05-03 - ESX-C Password Reset Confirmed But SSH Still Fails

- ESX-C root password was changed successfully from the local ESXi Shell.
- ESX-C management IP confirmed from `esxcli network ip interface ipv4 get`:
  `vmk0 192.168.5.201/24`, gateway `192.168.5.253`.
- `/var/log/auth.log` recorded `pam_unix(passwd:chauthtok): password changed
  for root`.
- SSH from Mac still does not authenticate with the new password.
- Next diagnostic: bypass local Mac SSH config with `ssh -F /dev/null`, inspect
  verbose client auth output, and check whether ESXi lockdown/access policy is
  blocking direct SSH root login despite DCUI root access.

## 2026-05-03 - ESX-C SSH Password Auth Confirmed

- `vim-cmd vimsvc/auth/lockdown_is_enabled` returned false.
- Verbose Mac SSH test with `ssh -vvv -F /dev/null` authenticated successfully
  to `192.168.5.201` using `keyboard-interactive`.
- The failure/hang occurs after authentication when requesting remote command
  execution, not during password verification.
- Decision: use interactive SSH or a TTY-forced stream to install the RSA key,
  then test public-key interactive login first before relying on remote command
  execution.

## 2026-05-03 - ESX-C SSH Session Channel Hangs

- `ssh -F /dev/null -t root@192.168.5.201` authenticated but then timed out
  before presenting a usable interactive shell.
- Remote command execution and interactive SSH both appear to hang after
  successful authentication.
- Decision: avoid iLO HTML paste and direct SSH command execution for key
  installation. Use vCenter-mediated ESXCLI through PowerCLI:
  `system ssh key add --username root --auth-key <public key>`.

## 2026-05-03 - PowerCLI vCenter Access Confirmed

- PowerCLI access to vCenter succeeded with a vCenter inventory user.
- `Get-VMHost` listed:
  - `192.168.5.201` in `Maintenance`, powered on
  - `192.168.5.203` connected, powered on
  - `192.168.5.205` in `Maintenance`, powered on
- Initial `CreateArgs()` property assignment did not work in this PowerCLI
  version; use direct `Invoke(@{ username = "root"; authkey = $pubkey })`
  hashtable syntax instead.

## 2026-05-03 - ESX-C RSA Key Installed Via PowerCLI

- PowerCLI `system.ssh.key.add.Invoke(@{ username = "root"; authkey = $pubkey })`
  returned `true` for ESX-C.
- PowerCLI `system.ssh.key.list.Invoke(@{ username = "root" })` listed the
  `ssh-rsa` key for root.
- Mac key-only SSH to `esx-c-host` still authenticated far enough to open the
  connection but timed out before presenting a usable shell, matching the prior
  password-auth post-login hang.
- Decision: credentials and key installation are solved. Remaining issue is
  ESX-C SSH session startup behavior; inspect shell startup files, SSH sandbox /
  FIPS behavior, and management agents from console/vCenter before relying on
  ESX-C SSH.

## 2026-05-03 - ESX-C Shell State Checked

- `/root` does not exist, but this is not the root cause because
  `/etc/passwd` sets root, dcui, and vpxuser home directories to `/`.
- `/etc/shells` contains `/bin/ash` and `/bin/sh`; root shell is `/bin/sh`.
- `esxcli system security fips140 ssh get` showed SSH FIPS mode enabled.
- `esxcli system ssh version get` showed OpenSSH `9.8p1` with OpenSSL
  `3.0.15`.
- Remaining issue: SSH authenticates but the session channel hangs before a
  shell or command output is usable. Next safe steps are SSH service stop/start,
  hostd/vpxa restart, compare FIPS setting with ESX-D/ESX-E, and if still
  stuck, reboot ESX-C while it remains in maintenance mode with VMs shut down.

## 2026-05-03 - ESX-C Reboot Did Not Clear SSH Hang

- SSH service start reports `SSH sandbox is not enabled, SSH will run in
  superdom`; Broadcom documents this as the default ESXi 8 behavior, not an
  error.
- ESX-C was rebooted while in maintenance mode; SSH still authenticates and
  then hangs before shell/command usability.
- Next diagnostic: compare `esxcli system security fips140 ssh get` between
  ESX-C and the working ESX-D/ESX-E hosts. If C differs or remains suspect,
  temporarily disable SSH FIPS on ESX-C, restart SSH, test key login, then
  decide whether to keep or revert.

## 2026-05-03 - ESX-C FIPS Matches Working Hosts

- ESX-D and ESX-E both report SSH FIPS enabled.
- ESX-C also reports SSH FIPS enabled.
- ESX-C was restarted again, but key-based SSH still times out after
  authentication.
- Decision: FIPS is not the differentiator. Next compare ESX-C SSH/session
  configuration and logs against working ESX-D/ESX-E, focusing on what happens
  after auth when a session channel should open.

## 2026-05-03 - ESX-C SSH Config Matches Working Hosts

- ESX-D and ESX-E SSH server config lists are identical.
- ESX-C visible SSH server config also matches the working hosts.
- Remaining suspect: login-time files or session startup state rather than SSH
  server config values. Because `printmotd yes` and `banner /etc/issue` are
  enabled, compare `/etc/motd` and `/etc/issue` on ESX-C against working hosts
  and temporarily disable `printmotd` if needed.

## 2026-05-03 - ESX-C Managed Path Healthy, Direct SSH Degraded

- ESX-C `/etc/issue` and `/etc/motd` match ESX-D in size and content.
- Temporary SSH config changes for `printmotd` and `banner` did not resolve the
  direct SSH session timeout.
- PowerCLI/vCenter ESXCLI path works:
  `system.version.get` returned VMware ESXi `8.0.3`, update `3`, patch `70`,
  build `Releasebuild-24674464`.
- Decision: ESX-C is manageable through vCenter/PowerCLI, but direct SSH remains
  degraded after authentication. Do not spend more routine maintenance time on
  SSH without a planned remediation window; use vCenter/PowerCLI for immediate
  host checks.

## 2026-05-03 - ESX-C Direct SSH Still Broken After PID Cleanup

- Peter removed the stale SSH runtime file as suggested and restarted SSH, but
  direct SSH to `root@192.168.5.201` still times out.
- Decision: continue investigation through PowerCLI/vCenter rather than direct
  SSH. Do not share vCenter credentials in the repo or chat; run diagnostics
  from an authenticated local PowerCLI session.

## 2026-05-03 - ESX-C SSH Auth Succeeds, Session Channel Stalls

- Verbose Mac SSH with ESX-C RSA key showed:
  - server accepts `/Users/czibulapeter/.ssh/esx-c-host_rsa`;
  - authentication succeeds using `publickey`;
  - server reads `/etc/ssh/keys-root/authorized_keys`;
  - session channel opens, but with `rwindow 0`;
  - shell request never completes and the client times out with broken pipe.
- Interpretation: credentials, key installation, firewall, and SSH transport
  are good. The failure is server-side session/PTY startup on ESX-C.
- Next diagnostic: inspect and clear stale `sshd` child processes and check
  pseudo-terminal devices from the ESX-C console.

## 2026-05-03 - ESX-D/ESX-E Session Startup Baseline

- ESX-D and ESX-E root account entries match ESX-C:
  `root:x:0:0:Administrator:/:/bin/sh`.
- ESX-D and ESX-E `/etc/profile` and `/etc/profile.local` are standard and
  identical in the checked sections; `/etc/profile.local` only contains the
  default comments.
- ESX-D and ESX-E `/dev/char/pty` exists and contains `ptmx`.
- ESX-D and ESX-E shell timeout advanced settings are both `0` for
  `/UserVars/ESXiShellInteractiveTimeOut` and `/UserVars/ESXiShellTimeOut`.
- Follow-up: on ESX-C, check the same timeout settings and inspect/clear stale
  `sshd-session` children before attempting deeper host remediation.

## 2026-05-03 - ESX-C Session Startup Baseline Matches

- ESX-C `/UserVars/ESXiShellInteractiveTimeOut` is `0`.
- ESX-C `/UserVars/ESXiShellTimeOut` is `0`.
- ESX-C `/dev/char/pty` exists and contains `ptmx`.
- ESX-C `/etc/profile.local` contains only the default comments.
- These match the working ESX-D/ESX-E baseline. Remaining check is stale
  `sshd` / `sshd-session` processes.

## 2026-05-03 - ESX-C No Stale SSHD Process Found

- `ps` filtered for `shd` only showed `bcflushd`; no stale `sshd` or
  `sshd-session` process was visible at rest.
- ESX-D and ESX-E have `/.ssh` but no `/.ssh/rc` and no `/etc/ssh/sshrc` in the
  checked output.
- Next diagnostic: check whether ESX-C has an SSH login hook file
  `/.ssh/rc` or `/etc/ssh/sshrc`, then temporarily increase SSH log level to
  capture where the session stalls.

## 2026-05-03 - ESX-C SSH Hooks Absent

- ESX-C `ps | grep ssh` showed no idle `sshd` or `sshd-session` processes.
- ESX-C `/.ssh` exists and matches the default style seen on ESX-D/ESX-E.
- ESX-C has no `/.ssh/rc`.
- ESX-C has no `/etc/ssh/sshrc`.
- ESX-D/ESX-E PAM baseline:
  - `/etc/security/ssh_limits.conf` is `* - maxsyslogins 50`;
  - `/etc/pam.d/system-auth` is the default 592-byte file from `2025-04-01`.
- Next diagnostic: check ESX-C `/etc/pam.d/sshd`,
  `/etc/security/ssh_limits.conf`, and `/etc/pam.d/system-auth` against the
  working host baseline.

## 2026-05-03 - ESX-C PAM Helper Script Returns

- Manual ESX-C console test of `ssh_vob.sh` with
  `PAM_TYPE=open_session PAM_USER=root PAM_RHOST=manual` returned immediately
  with exit code `0`.
- This means the helper script itself is not obviously hanging.
- Remaining PAM diagnostic: temporarily remove optional `ssh_vob.sh` lines from
  `/etc/pam.d/sshd` to rule out `pam_vmk_exec.so` wrapper behavior during SSH
  session open, then restore from backup.

## 2026-05-03 - ESX-D/ESX-E Log Sweep

- ESX-D SSH and ESX-E SSH work with RSA host keys.
- ESX-D identity:
  - hostname `ESXD`
  - VMware ESXi `8.0.3` build `24674464`
  - uptime about 10 days
- ESX-E identity:
  - hostname `ESXE`
  - VMware ESXi `8.0.3` build `24674464`
  - uptime about 10 days
- ESX-D log findings:
  - repeated `HBX: Failed to cleanup registration key` / `Vol3: Error closing
    the volume. Eviction fails` warnings against local datastore `ESXD_SSD`;
    Broadcom documents this local NVMe-backed VMFS pattern as benign, though it
    can create log noise;
  - repeated `VNVME: Error status: Not supported converted to: 0x80:0x1`
    entries; multiple production VMs on `MSA_PERFHDD` use virtual NVMe
    controllers;
  - repeated `Hostd VMkernelStatsProvider VSINode not found` messages;
  - `PDC.scoreboard is not readable` appeared in `hostd.log`, likely a
    transient VM stats/read artifact while inspecting VM state;
  - `smartd Failed to set the VSI node status` appeared once in the sampled
    syslog tail.
- ESX-E log findings:
  - repeated `HBX` / `Vol3` cleanup warnings against local datastore
    `ESXE_SSD`;
  - repeated HPE iLO/AMS/SUT `hpilo-* Busy` messages;
  - old 2024 SSH attempts for invalid user `Administrateur`;
  - vCenter/hostd/vpxa HTTP connection timeout messages that look like normal
    management polling/session timeout noise.
- Datastore capacity snapshot:
  - ESX-D `MSA_PERFHDD`: about `3.9 TB` free of `21.1 TB`;
  - ESX-E `ESXE_VEEAMHDD`: about `5.2 TB` free of `48.0 TB`;
  - ESX-D/ESX-E local SSD datastores are almost empty.
- Follow-up:
  - monitor datastore free space, especially `ESXE_VEEAMHDD`;
  - check vCenter alarms/tasks for VM snapshot consolidation or lock issues
    before acting on `PDC.scoreboard`;
  - revisit ESX-C direct SSH only when on-site/in office; use vCenter/PowerCLI
    for ESX-C meanwhile.
