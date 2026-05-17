# BDC Maintenance Log

## 2026-04-18 - Runbook Created

Scope:

- Created ESX-C starter runbook structure.
- Inspected repository documentation and local SSH alias configuration only.
- No connection to `BDC` was made during this entry.
- No VMware, Windows, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data changes were made.

Findings:

- Repo already had Windows remote-admin guidance in `docs/windows-ssh.md` and `docs/ssh-config.md`.
- Repo already had ESX-D and ESX-E on-prem runbook patterns under `on-prem/`.
- Local SSH config resolves `win-bdc` to `192.168.1.4` as local `Administrateur`.
- Local SSH config resolves `winad-bdc` to `192.168.1.4` as `format\Administrateur`.
- Both aliases use `~/.ssh/windows-admin_ed25519`.
- `BDC` should be treated as likely backup domain controller for `format.lu` until verified.

Next safe checks:

- Verify `win-bdc` with read-only `hostname` and `whoami`.
- Verify `winad-bdc` only after confirming the alias is expected for current domain-admin SSH access.
- Run read-only AD/DC health checks before any change.

## 2026-04-18 - Pre-Update Discovery

Scope:

- Performed read-only preflight before installing Windows updates.
- No reboot, snapshot, migration, power, firewall, SSH, WinRM, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, or data changes were made during discovery.

Findings:

- `win-bdc` and `winad-bdc` both authenticated key-only and returned hostname `BDC`.
- Both aliases landed as `format\administrateur`; `win-bdc` did not prove a separate local break-glass identity during this check.
- OS: Windows Server 2022 Standard, version `10.0.20348`.
- Domain: `format.lu`.
- Domain role: `BackupDomainController`.
- Services: `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were `Running`/`Automatic`.
- `WinRM` was `Stopped`/`Disabled`; no change was made.
- `winrm enumerate winrm/config/listener` failed because WinRM was not running.
- Remote-admin firewall address filters for the expected SSH/WinRM rules were scoped to `192.168.1.73` and `192.168.113.2`.
- `dcdiag /q` reported `KnowsOfRoleHolders`, `Replications`, and `RidManager` failures tied to authentication/bind failures against `PDC`.
- `repadmin /replsummary` showed 0 failures for `PDC` source and `BDC` destination, largest delta about 3 minutes, but also reported operational error `1326` retrieving information from `PDC.format.lu`.
- FSMO roles are all held by `PDC.format.lu`.
- DC locator for `format.lu` returned `BDC.format.lu` with GC, LDAP, KDC, time, writable, and DNS flags.
- Time source was `PDC.format.lu`; last successful sync was on 2026-04-18.
- Disk health reported healthy volumes; `C:` had about 73 GB free of about 96 GB.
- Pending Windows Update inventory showed 3 software updates:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Blast radius:

- `BDC` is confirmed domain-critical infrastructure.
- Installing OS updates may require a later reboot even though the update search reported `Reboot=False` before installation.
- Do not reboot without an explicit maintenance window because this host provides AD DS, DNS, Kerberos, time, and related domain-controller services.

## 2026-04-18 - Windows Updates Installed, Reboot Pending

Scope:

- Installed pending software updates using the Windows Update COM API from a temporary `NT AUTHORITY\SYSTEM` scheduled task.
- No reboot was performed.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall, SSH, WinRM, power, snapshot, migration, or data changes were made.
- Temporary scheduled task `FormatOps-WindowsUpdate-NoReboot` was deleted after completion.
- Temporary installer script `C:\ProgramData\FormatOps\Install-WindowsUpdates-NoReboot.ps1` was removed after completion.
- Installer log was left on the server at `C:\ProgramData\FormatOps\Logs\windows-update-20260418-bdc.log`.

Result:

- Updates ran as `NT AUTHORITY\SYSTEM`.
- Download result: `2` (succeeded).
- Install result: `2` (succeeded).
- `RebootRequired=True`.
- Installed successfully with per-update `hresult=0x00000000`:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Post-checks:

- `BDC` remained reachable over SSH after install.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update search still listed `KB5082142` as pending, consistent with the reboot-required state.
- Registry reboot check: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired` exists.
- `repadmin /replsummary` still showed 0 failures for `PDC` source and `BDC` destination, with operational error `1326` retrieving information from `PDC.format.lu`, matching the pre-update credential/bind caveat.

Next:

- Schedule an explicit reboot window for `BDC` before considering the cumulative update complete.
- After reboot, verify AD DS, DNS, DFSR/SYSVOL, time sync, Kerberos/domain logon, and replication.

## 2026-04-18 - Reboot Completed After Updates

Scope:

- Rebooted `BDC` with explicit approval after successful update installation.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall, SSH, WinRM, snapshot, migration, or data changes were made.

Result:

- Reboot completed successfully.
- Post-reboot boot time: 2026-04-18 22:36:20.
- `BDC` remained reachable over SSH as `format\administrateur`.
- Windows Update pending count after reboot: `0`.
- Registry reboot check after reboot: `False`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Time sync succeeded from `PDC.format.lu`; last successful sync was 2026-04-18 22:37:07.
- `repadmin /replsummary` showed 0 failures for `PDC` source and `BDC` destination, largest delta about 59 seconds.
- `repadmin /replsummary` still reported operational error `1326` retrieving information from `PDC.format.lu`, matching the pre-existing credential/bind caveat.

Next:

- Re-check `dcdiag /q` from an approved context that can bind to `PDC`.
- Continue tracking the existing `1326` PDC retrieval caveat separately from the update/reboot work.

## 2026-05-03 - Planned Shutdown For ESX-C Host Maintenance

Scope:

- Operator indicated `BDC` would be shut down as part of a coordinated
  three-VM ESX-C host-maintenance window.
- This entry records the approved maintenance context only.
- No live verification command was run from this thread at the time of
  documentation.

Findings:

- `BDC` had already completed its April 2026 Windows update and reboot cycle in
  the earlier entries above.
- The planned shutdown is for ESX-C host maintenance, not for additional guest
  OS patching.

Notes:

- Shutdown action was operator-performed/planned outside this thread.
- Any later power-on verification should confirm domain-controller core
  services, time sync, and replication health again after the ESX-C host work.

## 2026-05-16 - Twice-Monthly Maintenance Attempt Blocked While VM Offline

Scope:

- Started the next twice-monthly ESX-C maintenance pass.
- Limited this entry to non-mutating reachability checks because the VMs were
  expected to have been shut down for ESX-C host maintenance.
- No VMware, Windows, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data
  changes were made from this thread.

Findings:

- `nc -vz -G 5 192.168.1.4 22` timed out.
- `nc -vz -G 5 192.168.1.4 5985` timed out.
- `BDC` was not reachable yet for guest-level maintenance verification.

Result:

- Twice-monthly guest maintenance for `BDC` could not proceed because the VM
  was still offline or otherwise unreachable during the ESX-C host-maintenance
  window.

Next:

- Re-run the normal `BDC` post-power-on verification after ESX-C host work is
  complete and guest network reachability returns.

## 2026-05-16 - Post-Power-On Verification After ESX-C Host Maintenance

Scope:

- Re-tried the twice-monthly ESX-C maintenance pass after VPN reachability was
  restored and the guest came back online.
- Limited this entry to post-power-on verification and Windows Update
  discovery.
- No VMware, Windows, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data
  changes were made from this thread.

Findings:

- `BDC` responded on SSH again as `format\administrateur`.
- Last boot time observed: `2026-05-03 16:55:55`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were running and
  automatic.
- `WinRM` was now `Running`/`Automatic` without a change from this thread.
- `repadmin /replsummary` still showed `0` failures for `PDC` source and `BDC`
  destination, with the same operational error `1326` while retrieving
  information from `PDC.format.lu`.
- Time sync remained healthy from `PDC.format.lu`; last successful sync was
  `2026-05-16 08:37:59`.
- Windows Update COM search from the SSH session failed with `0x80240032`.
- Windows Update operational log still showed background scans finding
  available software updates on 2026-05-16:
  - repeated `found 2 updates`
  - repeated `found 1 updates`
- Reboot indicators were clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`

Result:

- `BDC` came back cleanly after ESX-C host maintenance and domain-controller
  core health looked consistent with the prior baseline.
- Guest patch installation did not proceed yet in this entry because the
  remote, non-interactive Windows Update enumeration path was not giving a
  trustworthy update list.

## 2026-05-16 - Windows Update Install Started, Servicing Still Running

Scope:

- Started Windows Update installation on `BDC` using a temporary
  `NT AUTHORITY\\SYSTEM` scheduled task after the post-power-on checks.
- No reboot was performed in this entry.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall,
  SSH, WinRM, snapshot, migration, power, or data changes were made.

Findings:

- SYSTEM-side update inventory/logging captured this currently available update
  set:
  - Windows Malicious Software Removal Tool x64 v5.141 (`KB890830`)
  - 2026-05 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1
    (`KB5088862`)
  - 2026-05 cumulative update for Microsoft server operating system version
    21H2 (`KB5087545`)
- Download phase reported `DownloadResult=2` (succeeded).
- `TrustedInstaller` and `TiWorker` remained active for an extended period
  after the task launch, indicating Windows servicing was still in progress.
- `Get-ScheduledTaskInfo` for `FormatOps-WU-Install-20260516` continued to show
  `LastTaskResult=267009` (`0x41301`, task still running).
- During servicing, Windows Update operational events shifted from repeated
  `found 2 updates` / `found 1 updates` to `found 1 updates` / `found 0
  updates`.
- Reboot indicators during the in-progress state were:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=True`
  - `PendingFileRenameOperations=False`
- `Get-HotFix` did not yet show the May 2026 update KBs at the time of this
  snapshot.

Result:

- Update installation was started successfully on `BDC`, but it had not reached
  a final completed state within this maintenance window snapshot.
- `BDC` should be treated as mid-servicing until a later verification confirms
  task completion or a reboot-finalized post-install state.

## 2026-05-17 - Manual Update Install And Reboot Verified

Scope:

- Operator reported manually completing the pending May 2026 Windows updates
  and reboot on `2026-05-16`.
- Performed read-only verification on `2026-05-17` over SSH.
- No VMware, Windows, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data
  changes were made from this thread.

Findings:

- `BDC` responded on SSH as `format\administrateur`.
- Last boot time observed after the operator reboot:
  `2026-05-16 16:23:16` Europe/Luxembourg time.
- `Get-HotFix` now shows the May 2026 OS cumulative update
  `KB5087545` installed on `2026-05-16`.
- Windows Update operational log on `2026-05-17` repeatedly reported
  `Windows Update successfully found 0 updates`.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True` still remains and should be tracked as a
  follow-up signal separate from Windows Update completion.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were
  `Running`/`Automatic`.
- `WinRM` was `Stopped`/`Disabled` during this verification.
- `repadmin /replsummary` again showed `0` failures for `PDC` source in the
  returned summary view.

Result:

- `BDC` appears successfully updated and rebooted for the May 2026 cycle.
- Windows Update itself is currently clean, with no further available updates
  reported during this verification pass.

## 2026-05-17 - Cleared Stale Pending File Rename Queue

Scope:

- Investigated the lingering `PendingFileRenameOperations=True` state found
  during the post-update verification on `2026-05-17`.
- Backed up the current registry value on `BDC`, then removed only the stale
  `PendingFileRenameOperations` value.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, snapshot, migration, power, or data changes
  were made from this thread.

Blast radius review:

- `Component Based Servicing\\RebootPending=False`
- `WindowsUpdate\\Auto Update\\RebootRequired=False`
- `TrustedInstaller` was stopped/manual at the time of change.
- `BITS` was stopped/manual at the time of change.
- `wuauserv` was running/manual, but Windows Update operational checks already
  showed `0 updates` available.
- The pending rename queue contained only stale fax/print-driver rename pairs
  under `C:\\Windows\\System32\\spool\\drivers\\x64\\3\\...`.
- None of the queued source or destination files still existed.

Action:

- Backed up the original registry payload to:
  `C:\\ProgramData\\FormatOps\\Logs\\pending-file-rename-bdc-20260517-081315.txt`
- Removed the registry value:
  `HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\PendingFileRenameOperations`

Post-checks:

- `PendingFileRenameOperations` no longer exists after the change.
- Reboot-required indicators remained clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `Spooler`, `sshd`, and `W32Time` remained
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.

Result:

- Cleared a stale pending file rename queue on `BDC` without affecting domain
  controller core services.
- The lingering rename flag from the May 2026 patch cycle is now resolved.

## 2026-05-17 - System Cleanup Launched

Scope:

- Launched Windows Disk Cleanup (`cleanmgr`) on `C:` for `BDC`.
- Selected the system-cleanup categories by setting the `VolumeCaches`
  `StateFlags517` entries and running `cleanmgr /d C /sagerun:517`.
- Interpreted "system files cleanup" conservatively by excluding only
  `DownloadsFolder`; the rest of the cleanup categories exposed by `cleanmgr`
  were selected.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, snapshot, migration, power, or data changes
  were made from this thread.

Blast radius review:

- `cleanmgr.exe` was present at `C:\\Windows\\System32\\cleanmgr.exe`.
- Pre-launch `C:` free space was about `70.6 GB` of about `96.0 GB`.
- `BDC` had no Windows Update or CBS reboot-required flags before launch.
- `BDC` is domain-critical infrastructure, so this action was limited to the
  built-in cleanup surface and did not include ad hoc file deletion.

Selected cleanup surface:

- Included all visible `VolumeCaches` categories except `DownloadsFolder`.
- This included categories such as `Update Cleanup`, `Temporary Files`,
  `Windows Defender`, `Recycle Bin`, and any other cleanup categories currently
  exposed by `cleanmgr` on this host.

Observed runtime state:

- `cleanmgr`, `DismHost`, `TiWorker`, and `TrustedInstaller` all started and
  remained present during observation.
- The SSH wrapper was interrupted after an extended wait, but the cleanup
  processes continued to run on the host.
- Latest observed `C:` free space during the in-progress state was about
  `70.6 GB`.
- Reboot-required indicators stayed clear during observation:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`

Result:

- Cleanup launch succeeded on `BDC`.
- At the end of this observation window, cleanup still appeared to be
  in progress rather than fully completed.
