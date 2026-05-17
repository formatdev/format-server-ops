# Kuhnle Maintenance Log

## 2026-04-18 - Runbook Created

Scope:

- Created ESX-C starter runbook structure.
- Inspected repository documentation and local SSH alias configuration only.
- No connection to `Kuhnle` was made during this entry.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data changes were made.

Findings:

- Repo already had Windows remote-admin guidance in `docs/windows-ssh.md` and `docs/ssh-config.md`.
- Repo already had ESX-D and ESX-E on-prem runbook patterns under `on-prem/`.
- Local SSH config resolves `win-kuhnle` to `192.168.1.14` as local `Administrateur`.
- Local SSH config resolves `winad-kuhnle` to `192.168.1.14` as `format\Administrateur`.
- Both aliases use `~/.ssh/windows-admin_ed25519`.
- Role, domain membership, service state, firewall scope, update state, event logs, and disk state are not yet verified.

Next safe checks:

- Verify `win-kuhnle` with read-only `hostname` and `whoami`.
- Verify `winad-kuhnle` only after confirming current local access and domain membership expectations.
- Record role, hostname, domain membership, IP, SSH alias state, WinRM state, firewall scope, updates, services, event logs, and disk state before changes.

## 2026-04-18 - Pre-Update Discovery

Scope:

- Performed read-only preflight before installing Windows updates.
- No reboot, snapshot, migration, power, firewall, SSH, WinRM, GPO, or data changes were made during discovery.

Findings:

- `win-kuhnle` authenticated key-only and returned hostname `KUHNLE`, identity `kuhnle\administrateur`.
- `winad-kuhnle` authenticated key-only and returned hostname `KUHNLE`, identity `format\administrateur`.
- OS: Windows Server 2022 Standard, version `10.0.20348`.
- Domain: `format.lu`.
- Domain role: `MemberServer`.
- Domain secure channel was healthy; `nltest /sc_query:format.lu` succeeded against `\\PDC.format.lu`.
- Services: `sshd` was `Running`/`Automatic`; `WinRM` was `Stopped`/`Disabled`.
- `winrm enumerate winrm/config/listener` failed because WinRM was not running.
- Remote-admin firewall address filters for the expected SSH/WinRM rules were scoped to `192.168.1.73` and `192.168.113.2`.
- Disk health reported healthy volumes; `C:` had about 28 GB free of about 53 GB and `D:` had about 37 GB free of about 54 GB.
- Recent hotfixes showed March 2026 security updates installed.
- Last 7 days event count: `System=3`, `Application=5` warnings/errors.
- Pending Windows Update inventory showed 3 software updates:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Blast radius:

- `Kuhnle` is confirmed as a domain-joined Windows member server, but application role is still not verified.
- Installing OS updates may require a later reboot even though the update search reported `Reboot=False` before installation.
- Do not reboot without an explicit maintenance window because production role and user impact are not yet documented.

## 2026-04-18 - Windows Update Install Attempt Blocked

Scope:

- Attempted to install pending software updates after pre-update discovery.
- No updates were installed on `Kuhnle`.
- No reboot was performed.
- No VMware, GPO, firewall, SSH, WinRM, power, snapshot, migration, or data changes were made.

Attempts:

- Direct Windows Update COM install from `winad-kuhnle` reached update enumeration but failed creating the downloader with `E_ACCESSDENIED`.
- Direct Windows Update COM install from `win-kuhnle` reached update enumeration but failed creating the downloader with `E_ACCESSDENIED`.
- Temporary SYSTEM scheduled task creation using both `win-kuhnle` and `winad-kuhnle` failed with `Access is denied`.
- Temporary LocalSystem service `FormatOpsWindowsUpdate` could be created, but `sc start` failed with service error `1053`; no update log was created.

Cleanup:

- Temporary service `FormatOpsWindowsUpdate` was deleted.
- Temporary installer script was removed from `C:\ProgramData\FormatOps\Install-WindowsUpdates-NoReboot.ps1`.
- No `Kuhnle` update log was left because the installer never started.

Post-checks:

- `Kuhnle` remained reachable over SSH.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update search still showed the original 3 pending updates:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)
- Registry reboot check was `False`.

Next:

- Use an approved interactive/elevated console path, vCenter console, RMM, or an already-approved privilege elevation method to run Windows Update.
- Keep `Kuhnle` out of any reboot plan until updates are actually installed and its production role is documented.

## 2026-04-18 - Reboot Completed, Updates Still Pending

Scope:

- Rebooted `Kuhnle` with explicit approval.
- No Windows updates were installed by this reboot.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, or data changes were made.

Result:

- Reboot completed successfully.
- Post-reboot boot time: 2026-04-18 22:32:43.
- `Kuhnle` remained reachable over SSH as `kuhnle\administrateur`.
- Domain secure channel remained healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update pending count after reboot: `3`.
- Registry reboot check after reboot: `False`.
- Updates still pending:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Next:

- Use an approved interactive/elevated console path, vCenter console, RMM, or another approved privilege elevation method to install the pending updates.

## 2026-05-03 - Update State Reconciled, No Pending Updates Found

Scope:

- Re-checked `Kuhnle` live state before attempting another Windows Update install.
- Limited this pass to discovery and reconciliation of the previously recorded
  pending-update state.
- No reboot, VMware, GPO, firewall, SSH, WinRM, power, snapshot, migration, or
  data changes were made.

Findings:

- `win-kuhnle` and `winad-kuhnle` both still authenticated successfully.
- Hostname remained `KUHNLE`; identity checks returned
  `kuhnle\administrateur` and `format\administrateur`.
- `Kuhnle` remained a domain-joined `format.lu` Windows Server 2022 member
  server.
- Domain secure channel still tested healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `KB5082142` is now installed (`InstalledOn=2026-04-18`).
- Windows Update operational log on 2026-05-03 repeatedly reported
  `Windows Update successfully found 0 updates`.
- Manual Windows Update COM search from the SSH session now returns
  `0x80240032`, while the Windows Update service itself continues to log
  successful scans with zero available updates.
- Current reboot state:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=True`
- Last boot time observed: `2026-04-19T09:23:30`.
- Current filesystem free space observed:
  - `C:` about `22.9 GB` free of `49.4 GB`
  - `D:` about `34.1 GB` free of `50.0 GB`
- Recent warning/error review did not show a current Windows Update failure
  requiring operator action. Notable recurring items were:
  - VMware/virtual TPM warning `Microsoft-Windows-TPM-WMI 1803`
  - periodic `BITS` perflib warning `1008`
  - occasional `DCOM 10016`
  - one DNS client timeout for `epns.eset.com`

Result:

- The previously documented "3 pending updates" state from 2026-04-18 is now
  stale.
- No install action was needed on 2026-05-03 because the server's own Windows
  Update client was already finding `0` available updates.

Next:

- Treat `Kuhnle` as patched through the currently visible Windows Update state
  as of 2026-05-03.
- Revisit only if a later maintenance cycle finds new updates or if an operator
  wants deeper investigation into the remaining `PendingFileRenameOperations`
  value.

## 2026-05-03 - System Cleanup And Planned Shutdown For ESX-C Host Maintenance

Scope:

- Operator reported running Windows system-file cleanup on `Kuhnle`.
- Operator then planned to shut down `Kuhnle` with the other ESX-C VMs for ESX-C
  host maintenance.
- No additional remote commands were run from this thread during the cleanup or
  shutdown action itself.

Findings:

- Operator-reported recovered space from Windows system-file cleanup:
  about `4.3 GB`.
- The cleanup happened after the update-state reconciliation entry above.
- The planned shutdown is part of ESX-C host maintenance, not a new guest OS
  update cycle.

Notes:

- This cleanup was operator-performed and is recorded here so the free-space
  picture in the earlier discovery entries is understood as pre-cleanup.
- Any later post-power-on check should revisit free space, SSH reachability,
  domain secure channel, and whether `PendingFileRenameOperations` still
  remains set.

## 2026-05-16 - Twice-Monthly Maintenance Attempt Blocked While VM Offline

Scope:

- Started the next twice-monthly ESX-C maintenance pass.
- Limited this entry to non-mutating reachability checks because the VMs were
  expected to have been shut down for ESX-C host maintenance.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made from this thread.

Findings:

- `nc -vz -G 5 192.168.1.14 22` timed out.
- `nc -vz -G 5 192.168.1.14 5985` timed out.
- Direct SSH with `win-kuhnle` also timed out on port `22`.
- `Kuhnle` was not reachable yet for guest-level maintenance verification.

Result:

- Twice-monthly guest maintenance for `Kuhnle` could not proceed because the VM
  was still offline or otherwise unreachable during the ESX-C host-maintenance
  window.

Next:

- Re-run the normal `Kuhnle` post-power-on verification after ESX-C host work
  is complete and guest network reachability returns.

## 2026-05-16 - Post-Power-On Verification After ESX-C Host Maintenance

Scope:

- Re-tried the twice-monthly ESX-C maintenance pass after VPN reachability was
  restored and the guest came back online.
- Limited this entry to post-power-on verification and Windows Update
  discovery.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made from this thread.

Findings:

- `Kuhnle` responded on SSH again as `kuhnle\administrateur`.
- Last boot time observed: `2026-05-03 16:55:57`.
- Domain secure channel still tested healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Current observed free space:
  - `C:` about `24.5 GB` free of `49.4 GB`
  - `D:` about `34.1 GB` free of `50.0 GB`
- This is consistent with the operator-reported system-file cleanup having
  recovered several gigabytes since the earlier pre-cleanup snapshot.
- Windows Update COM search from the SSH session failed with `0x80240032`.
- Windows Update operational log still showed background scans finding
  available software updates on 2026-05-16:
  - repeated `found 2 updates`
  - repeated `found 1 updates`
- Reboot indicators were mostly clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=True`
- Recent warnings/errors remained broadly in line with the prior baseline:
  VMware virtual TPM `1803`, periodic `BITS` perflib `1008`, occasional
  `DCOM 10016`, and older user-profile/temp-profile warnings.

Result:

- `Kuhnle` came back cleanly after ESX-C host maintenance and remained
  generally consistent with its earlier baseline.
- Guest patch installation did not proceed yet in this entry because the
  remote, non-interactive Windows Update enumeration path was not giving a
  trustworthy update list.

## 2026-05-16 - Windows Update Trigger Attempted, No Confirmed Install Yet

Scope:

- Attempted to start Windows Update installation on `Kuhnle` after the
  post-power-on checks.
- Tried the explicit SYSTEM scheduled-task path again and then triggered the
  built-in update orchestrator (`UsoClient StartInstall`).
- No reboot was performed in this entry.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, power, or data
  changes were made.

Findings:

- `Kuhnle` continued to show background Windows Update discovery events with:
  - repeated `found 2 updates`
  - repeated `found 1 updates`
- The explicit SYSTEM scheduled-task path still did not yield a trustworthy
  installer log or marker file on this host.
- `UsoClient StartInstall` at least caused `MoUsoCoreWorker` to start, showing
  that the update orchestrator reacted.
- At the snapshot taken in this pass:
  - `TrustedInstaller` was not running
  - `TiWorker` was not running
  - `MoUsoCoreWorker` had started
- Reboot indicators remained:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=True`
- `Get-HotFix` did not yet show the May 2026 update KBs at the time of this
  snapshot.

Result:

- `Kuhnle` was nudged into the Windows Update install path, but this pass did
  not produce a confirmed installed-update result yet.
- `Kuhnle` remains the least cooperative ESX-C guest for remote Windows Update
  execution and likely needs either more time for the orchestrator path to act
  or a different elevated execution path in a follow-up pass.

## 2026-05-17 - Manual Update Install And Reboot Verified

Scope:

- Operator reported manually completing the pending May 2026 Windows updates
  and reboot on `2026-05-16`.
- Performed read-only verification on `2026-05-17` over SSH.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made from this thread.

Findings:

- `Kuhnle` responded on SSH as `kuhnle\administrateur`.
- Last boot time observed after the operator reboot:
  `2026-05-16 16:40:23` Europe/Luxembourg time.
- Domain secure channel still tested healthy against `\\PDC.format.lu`.
- `Get-HotFix` now shows the May 2026 OS cumulative update `KB5087545`
  installed on `2026-05-16`.
- Windows Update operational log on `2026-05-17` repeatedly reported
  `Windows Update successfully found 0 updates`.
- Reboot indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.

Result:

- `Kuhnle` appears successfully updated and rebooted for the May 2026 cycle.
- The earlier `2026-05-16` "no confirmed install yet" state is now superseded
  by the operator-completed update and the clean post-reboot verification.

## 2026-05-17 - System Cleanup Launched

Scope:

- Launched Windows Disk Cleanup (`cleanmgr`) on `C:` for `Kuhnle`.
- Selected the system-cleanup categories by setting the `VolumeCaches`
  `StateFlags517` entries and running `cleanmgr /d C /sagerun:517`.
- Interpreted "system files cleanup" conservatively by excluding only
  `DownloadsFolder`; the rest of the cleanup categories exposed by `cleanmgr`
  were selected.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made from this thread.

Blast radius review:

- `cleanmgr.exe` was present at `C:\\Windows\\System32\\cleanmgr.exe`.
- Pre-launch `C:` free space was about `24.2 GB` of about `53.0 GB`.
- `Kuhnle` had no Windows Update or CBS reboot-required flags before launch.

Selected cleanup surface:

- Included all visible `VolumeCaches` categories except `DownloadsFolder`.
- This included categories such as `Update Cleanup`, `Temporary Files`,
  `Windows Defender`, `Recycle Bin`, `Windows Error Reporting Files`, and any
  other cleanup categories currently exposed by `cleanmgr` on this host.

Observed runtime state:

- `cleanmgr`, `DismHost`, `TiWorker`, and `TrustedInstaller` all started and
  remained present during observation.
- The SSH wrapper was interrupted after an extended wait, but the cleanup
  processes continued to run on the host.
- Latest observed `C:` free space during the in-progress state was about
  `24.1 GB`.
- Reboot-required indicators stayed clear during observation:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`

Result:

- Cleanup launch succeeded on `Kuhnle`.
- At the end of this observation window, cleanup still appeared to be
  in progress rather than fully completed.
