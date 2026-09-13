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

## 2026-05-31 - End-Of-Month Verification

Scope:

- Performed read-only end-of-month verification for `BDC`.
- Checked reboot state, current update posture, cleanup follow-through, disk
  state, and core domain-controller services.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, snapshot, migration, power, or data changes
  were made from this thread.

Findings:

- `BDC` responded on SSH as `format\administrateur`.
- Last boot time remained `2026-05-17 10:19:20` Europe/Luxembourg time.
- `C:` free space is now about `72.5 GB` of about `96.0 GB`, which is about
  `1.9 GB` higher than the pre-cleanup snapshot recorded on `2026-05-17`.
- Windows Update operational events on `2026-05-31` repeatedly reported
  `Windows Update successfully found 0 updates`.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True` has returned, but this time the queue is
  not the earlier stale spool-driver pattern.
- Current pending rename queue is much larger (`110` entries) and is mostly
  composed of:
  - `C:\\Config.Msi\\*.rbf`
  - `C:\\Windows\\Temp\\eset.temp\\...`
  - `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.233.3`
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `Spooler`, `sshd`, and `W32Time` remained
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `repadmin /replsummary` again showed `0` failures in the returned summary
  view for `PDC` source / `BDC` destination.
- `cleanmgr.exe` and `DismHost` were no longer present during this check, so
  the earlier cleanup launch no longer appears to be actively running.
- `TiWorker` and `TrustedInstaller` were present at low activity during the
  check, but without any reboot-required flags or available updates.

Result:

- `BDC` is currently reachable, stable, and not offering new Windows updates
  at the end of the month.
- Mid-month cleanup appears to have completed and reclaimed some space.
- A new, nontrivial pending rename queue remains and should be handled
  cautiously because it now includes MSI/ESET/EdgeUpdate-related entries rather
  than obviously stale print-driver leftovers.

## 2026-05-31 - Rebooted To Clear Pending Rename Queue

Scope:

- Rebooted `BDC` with explicit operator approval to test whether the current
  `PendingFileRenameOperations` queue would clear naturally.
- Performed post-reboot verification for boot time, reboot-required flags,
  pending rename state, and domain-controller core services.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall,
  SSH, WinRM, update, snapshot, migration, power, or data changes were made
  from this thread beyond the approved reboot itself.

Findings:

- Post-reboot boot time observed: `2026-05-31 09:15:41` Europe/Luxembourg
  time.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=False` after reboot; pending count is now `0`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were
  `Running`/`Automatic` after reboot.
- `WinRM` came back `Running`/`Automatic`; this thread did not change the
  service configuration directly.
- `repadmin /replsummary` after reboot continued to show `0` failures in the
  returned summary view for `PDC` source / `BDC` destination.

Result:

- The reboot cleared the current `PendingFileRenameOperations` queue on `BDC`.
- `BDC` itself came back cleanly and continued to show healthy core
  domain-controller service state in this post-reboot check.

## 2026-05-31 - End-Of-Month Windows Update Check

Scope:

- Ran a Windows Update inventory/install pass as `NT AUTHORITY\\SYSTEM` using
  the Windows Update COM API.
- No updates were installed because Windows Update returned no applicable
  software updates.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, snapshot, migration, power, or data changes were made.

Findings:

- Temporary task `FormatOps-WU-Install-20260531` ran successfully with
  `LastTaskResult=0`.
- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260531-bdc.log`
- Windows Update result:
  - `Count=0`
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` remained
  `Running`/`Automatic`.
- `WinRM` was `Stopped`/`Disabled` during the cleanup verification; no change
  was made.

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260531`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260531.ps1`

Result:

- `BDC` had no pending Windows software updates at the time of this pass.
- No reboot is required from this update check.

## 2026-05-31 - Operator Cleanup And Shutdown For ESX-C Host Restart

Scope:

- Operator reported cleaning up disk space on `BDC`.
- Operator reported shutting down `BDC` afterward as part of an ESX-C host
  restart window.
- This entry records the approved maintenance context only.
- No live verification command was run from this thread at the time of this
  documentation entry.

Findings:

- The disk cleanup and shutdown were operator-performed outside this thread.
- The shutdown is for ESX-C host maintenance, not for additional guest Windows
  patching.
- Earlier in this maintenance pass, Windows Update returned `Count=0`,
  `PendingFileRenameOperations=False`, and no reboot-required flags.

Next:

- After ESX-C host restart and guest power-on, verify `BDC` SSH reachability,
  AD DS, DNS, DFSR/SYSVOL-related services, time sync, replication summary,
  and reboot-required state before closing the maintenance cycle.

## 2026-06-14 - Twice-Monthly Maintenance Verification

Scope:

- Performed read-only post-host-restart and twice-monthly maintenance checks.
- Ran a Windows Update inventory/install pass as `NT AUTHORITY\\SYSTEM` using
  the Windows Update COM API.
- No updates were installed because Windows Update returned no applicable
  software updates.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, snapshot, migration, power, or data changes were made.

Findings:

- `BDC` responded on SSH as `format\\administrateur`.
- Last boot time observed: `2026-06-13 22:26:22` Europe/Luxembourg time.
- Recent hotfixes show June 2026 updates already installed on `2026-06-13`:
  - `KB5094147`
  - `KB5094128`
- Windows Update operational events repeatedly reported
  `Windows Update successfully found 0 updates`.
- SYSTEM-side Windows Update task `FormatOps-WU-Install-20260614` completed
  with `LastTaskResult=0`.
- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260614-bdc.log`
- Windows Update result:
  - `Count=0`
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=True`
- Current pending rename queue contains print/fax driver rename pairs under
  `C:\\Windows\\System32\\spool\\drivers\\...`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `repadmin /replsummary` showed `0` failures in the returned summary view for
  `PDC` source / `BDC` destination.
- Time sync remained healthy from `PDC.format.lu`.
- `C:` free space was about `69.2 GB` of about `96.0 GB`.

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260614`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task_20260614.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260614.ps1`

Result:

- `BDC` has no pending Windows software updates visible to Windows Update.
- `BDC` is healthy from the checked DC-service, replication-summary, and time
  sync perspective.
- A reboot window is recommended to clear the current print/fax-driver
  `PendingFileRenameOperations` queue.

## 2026-07-04 - Inspection Round

Scope:

- Performed read-only inspection of `BDC`.
- Checked SSH reachability, boot time, update visibility, reboot flags,
  pending rename state, free space, domain-controller services, replication
  summary, and time sync.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, snapshot, migration, power, or data changes
  were made.

Findings:

- `BDC` responded on SSH as `format\\administrateur`.
- Last boot time observed: `2026-06-17 21:52:31` Europe/Luxembourg time.
- Windows Update operational events repeatedly reported
  `Windows Update successfully found 0 updates`.
- Recent hotfixes still show June 2026 updates installed:
  - `KB5094147`
  - `KB5094128`
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True`, but the queue is now small (`4` string
  entries / `2` rename pairs) and is EdgeUpdate-related:
  - `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.241.13`
  - `C:\\ProgramData\\Microsoft\\EdgeUpdate\\Log\\MicrosoftEdgeUpdate.log`
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `repadmin /replsummary` showed `0` failures in the returned summary view for
  `PDC` source / `BDC` destination.
- Time sync remained healthy from `PDC.format.lu`; last successful sync was
  `2026-07-04 17:42:20`.
- `C:` free space was about `68.0 GB` of about `96.0 GB`.

Result:

- `BDC` is reachable and healthy from the checked DC-service, replication
  summary, time sync, and Windows Update visibility perspective.
- No update or reboot action was taken during this inspection.
- The remaining pending rename queue appears tied to EdgeUpdate cleanup and can
  be cleared in a future reboot window.

## 2026-07-19 - Twice-Monthly Maintenance And July Updates

Scope:

- Performed ESX-C twice-monthly maintenance for `BDC`.
- Ran Windows Update installation as `NT AUTHORITY\\SYSTEM` using the Windows
  Update COM API from temporary scheduled task
  `FormatOps-WU-Install-20260719`.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall,
  SSH, WinRM, snapshot, migration, power, or data changes were made.
- No reboot command was issued from this thread; `BDC` rebooted during the
  servicing window after updates were installed.

Pre-update findings:

- `BDC` responded on SSH as `format\\administrateur`.
- Last boot before updates was observed as `2026-07-04 21:38:21`
  Europe/Luxembourg time.
- Domain role remained backup domain controller for `format.lu`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `repadmin /replsummary` showed `0` failures in the returned summary view for
  `PDC` source / `BDC` destination.
- `C:` free space was about `68.9 GB`.
- Windows Update reported one applicable update:
  - 2026-07 cumulative update for Microsoft server operating system version
    21H2 for x64-based systems (`KB5099540`)

Update result:

- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260719-bdc.log`
- Download result: `2` (succeeded), `HResult=0`.
- Install result: `2` (succeeded), `RebootRequired=True`, `HResult=0`.
- Per-update result for `KB5099540`: `Result=2`, `HResult=0`.
- Post-servicing hotfix inventory shows July 2026 updates installed on
  `2026-07-19`:
  - `KB5099540`
  - `KB5101010`
  - `KB5120210`

Post-checks:

- Post-update boot time observed: `2026-07-19 10:04:51`
  Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Reboot-required indicators were clear after the observed reboot:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True`; current sample entries are print-driver
  rename pairs under `C:\\Windows\\System32\\spool\\drivers\\x64\\3\\...`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` remained
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `repadmin /replsummary` showed `0` failures in the returned summary view for
  `PDC` source / `BDC` destination, with largest delta about 2 minutes.
- Time sync remained healthy from `PDC.format.lu`.
- Recent System log review after the update/reboot showed boot-time service,
  Schannel, and time-service errors; no corrective action was taken in this
  thread.
- `C:` free space after servicing was about `60.8 GB` of `89.4 GB`.

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260719`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task_20260719.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260719.ps1`

Result:

- July Windows updates installed successfully and Windows Update now reports no
  applicable software updates.
- `BDC` is reachable and healthy from the checked DC-service, replication
  summary, time sync, and Windows Update visibility perspective.
- Track the remaining print-driver `PendingFileRenameOperations` queue during
  the next reboot window.

## 2026-07-19 - Post-Maintenance Clean Follow-Up

Scope:

- Rechecked `BDC` after the July maintenance round had time to settle.
- Performed discovery-only checks for update visibility, reboot-required
  indicators, pending rename state, domain-controller services, and replication
  summary.
- No reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, snapshot, migration, power, or data changes
  were made.

Findings:

- `BDC` responded on SSH.
- Current boot time observed: `2026-07-19 11:16:04` Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were
  `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `repadmin /replsummary` showed `0` failures in the returned summary view for
  `PDC` source / `BDC` destination, with largest delta about 27 minutes.

Result:

- `BDC` is clean from the checked Windows Update, reboot-required,
  pending-rename, DC-service, and replication-summary perspective.

## 2026-08-04 - Maintenance Attempt Blocked By Network Reachability

Scope:

- Started a new ESX-C maintenance pass for `BDC`.
- Limited the pass to repository review and non-mutating network reachability
  checks because the guest was not reachable.
- No VMware, Windows, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data
  changes were made.

Findings:

- Local route to `192.168.1.4` used gateway `192.168.200.254`.
- `nc` to `192.168.1.4:22` failed with connection refused.
- `nc` to `192.168.1.4:5985` failed with connection refused.
- SSH via `win-bdc` failed with connection refused on port `22`.
- ICMP returned `Communication prohibited by filter` from `10.128.128.128`,
  then timed out.

Result:

- Guest-level maintenance could not proceed because network reachability to
  `BDC` is blocked or the required tunnel/filter path is not open.

Next:

- Re-run discovery after the VPN/tunnel/firewall path to the ESX-C guest
  subnet is confirmed open.

## 2026-08-04 - Maintenance Retry And Pre-Change Inspection

Scope:

- Retried the ESX-C maintenance pass after the VPN/tunnel path was restored.
- Performed discovery-only checks for identity, Windows Update, reboot state,
  disks, remote-admin services and firewall scope, event health, AD DS/DNS/
  DFSR/Netlogon/time services, SYSVOL/NETLOGON shares, and replication.
- No update, reboot, VMware, AD, DNS, DHCP, time sync, replication, SYSVOL,
  GPO, firewall, SSH, WinRM, snapshot, migration, power, or data change was
  made.

Findings:

- SSH and the expected `winad-bdc` domain-admin alias are reachable; the
  session identity is `format\\administrateur`.
- Hostname is `BDC`, IP is `192.168.1.4/24`, and Windows identifies the VM as
  a domain controller for `format.lu`.
- Last boot remains `2026-07-19 11:16:04` Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Windows Update and CBS reboot-required indicators are clear.
- `PendingFileRenameOperations=True`; the current queue has four strings/two
  non-empty items, both categorized as EdgeUpdate cleanup.
- `C:` has about `66.7 GB` free of `89.4 GB`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` are
  `Running`/`Automatic`.
- `WinRM` remains `Stopped`/`Disabled`; its existing port `5985` rule is scoped
  to `192.168.1.73` and `192.168.113.2`.
- The active OpenSSH port `22` rule currently allows `Any` remote address.
  This is documented as a scope finding only; firewall policy was not changed.
- `SYSVOL` and `NETLOGON` shares are present.
- Time synchronization is healthy from `PDC.format.lu`.
- `repadmin /showrepl BDC` showed successful inbound replication for all five
  naming contexts. `repadmin /replsummary` showed `0/5` failures for PDC to
  BDC, while still reporting the known operational error `1326` when querying
  PDC. Focused `dcdiag` also hit an access-denied bind to PDC; no replication
  change was attempted.
- Seven-day System warning/error groups were limited to DCOM `10016`, one
  Netlogon `5722` for computer `NUC-SST`, and one Windows Installer service
  restart event `7031`.

Result:

- No applicable Windows updates are currently visible and no Windows Update or
  CBS reboot is pending.
- BDC is healthy from the checked service, share, time, and direct inbound
  replication perspectives.
- The EdgeUpdate rename queue can be observed through the next approved reboot
  window. The broad SSH firewall scope and the existing PDC diagnostic bind
  caveat remain documented follow-ups, not changes for this pass.

## 2026-08-04 - Planned Guest Shutdown For ESX-C Host Maintenance

Scope:

- Shut down `BDC` at the user's request for physical ESX-C host maintenance.
- BDC was shut down last, after Kuhnle and LMR were confirmed offline, to keep
  domain-controller services available for as long as possible.
- No VMware power operation, forced application termination, AD, DNS, DHCP,
  replication, SYSVOL, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  or data change was made.

Action and result:

- Submitted an orderly Windows guest shutdown as local SYSTEM with planned
  hardware-maintenance reason code `p:1:1` through temporary scheduled task
  `FormatOps-Shutdown-20260804-BDC`.
- The task action was configured to remove itself after submitting the shutdown
  request.
- SSH port `22` stopped responding after the shutdown request. This confirms
  guest network services are offline; hypervisor power state was not queried
  from this thread.

Post-start checks:

- After ESX-C host maintenance, verify BDC SSH reachability, boot time, DC
  services, SYSVOL/NETLOGON, time synchronization, replication, Windows Update
  and reboot flags, pending rename state, and absence of the temporary shutdown
  task.

## 2026-08-23 - Twice-Monthly Maintenance Pre-Install State

Scope:

- Started a new ESX-C maintenance round and completed discovery before Windows
  servicing.
- No reboot, VMware, AD, DNS, DHCP, replication, SYSVOL, GPO, firewall, SSH,
  WinRM, snapshot, migration, power, or data change was made during discovery.

Findings:

- BDC is reachable over SSH as `format\administrateur` and booted after host
  maintenance at `2026-08-04 20:43:17` Europe/Luxembourg time.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` are
  `Running`/`Automatic`; SYSVOL and NETLOGON shares are present.
- Time is synchronized to `PDC.format.lu`.
- Direct inbound replication is successful for all five naming contexts and
  the summary shows `0/5` failures. The known diagnostic error `1326` while
  retrieving PDC information remains.
- Windows Update and CBS reboot flags are clear.
- `PendingFileRenameOperations=True` with 18 strings, currently including
  EdgeUpdate and security-software cleanup entries.
- `C:` has about `66.6 GB` free of `89.4 GB`.
- Three applicable updates are visible:
  - Windows Malicious Software Removal Tool x64 v5.144 (`KB890830`)
  - August 2026 cumulative .NET update (`KB5121650`)
  - August 2026 cumulative Server 2022 update (`KB5120242`)
- Removed three confirmed stale FormatOps tasks from May/August maintenance;
  no FormatOps scheduled tasks remain.

Blast radius:

- Installation can restart Windows services and is expected to require a guest
  reboot, briefly removing this backup domain controller and its DNS/AD
  services. PDC remains the replication and time source. No AD/GPO/replication
  configuration change is in scope.

## 2026-08-23 - August Updates Installed And Verified

Action:

- Installed the three discovered updates as local SYSTEM using temporary task
  `FormatOps-WU-Install-20260823` and the Windows Update COM API.
- Rebooted BDC last, after the member servers, using planned update reason code
  `p:2:17`. PDC remained available during the reboot.
- No VMware, AD, DNS, DHCP, replication, SYSVOL, GPO, firewall, SSH, WinRM,
  snapshot, migration, power, or data configuration change was made.

Install result:

- Log retained on the guest at
  `C:\ProgramData\FormatOps\Logs\windows-update-20260823-bdc.log`.
- Download and install result codes were `2` (succeeded).
- `KB890830`, `KB5121650`, and `KB5120242` each returned `Result=2`,
  `HResult=0`; Windows reported `RebootRequired=True`.
- BDC remained offline at the network layer for about 13 minutes while Windows
  completed the post-update boot.

Post-checks:

- New boot time is `2026-08-23 16:45:16` Europe/Luxembourg time.
- Windows Update returned `Count=0`; Windows Update and CBS reboot flags are
  clear.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` are
  `Running`/`Automatic`; WinRM remains `Stopped`/`Disabled`.
- SYSVOL and NETLOGON shares are present.
- Time is synchronized to PDC.
- Direct inbound replication is successful for all five naming contexts and
  the summary reports `0/5` failures. The known `1326` PDC diagnostic caveat
  remains.
- `C:` has about `63.5 GB` free.
- `PendingFileRenameOperations=True` with 36 non-empty entries, all
  categorized as print-driver cleanup. No second reboot was issued.
- Post-boot event groups were limited to time-service, Schannel, and DCOM
  events in the inspected window; no corrective change was made.
- Temporary installer/reboot tasks and the temporary installer script were
  removed; the audit log remains.

Result:

- August updates are installed and Windows Update is clean.
- BDC is healthy from the checked service, share, time, update, and direct
  replication perspectives.
- Track the print-driver rename queue through the next approved reboot window.

## 2026-09-05 - Twice-Monthly Maintenance Pre-Reboot State

Scope:

- Started the September ESX-C maintenance round with read-only discovery.
- No Windows update, reboot, VMware, AD, DNS, DHCP, replication, SYSVOL, GPO,
  firewall, SSH, WinRM, snapshot, migration, power, or data configuration
  change was made during discovery.

Findings:

- BDC is reachable through both expected SSH aliases as
  `format\\Administrateur`; hostname and address remain `BDC` and
  `192.168.1.4/24`.
- BDC remains a `format.lu` domain controller. `DNS`, `DFSR`, `Netlogon`,
  `NTDS`, `sshd`, and `W32Time` are `Running`/`Automatic`; SYSVOL and
  NETLOGON shares are present.
- Focused `dcdiag` connectivity, advertising, SYSVOL, Netlogon, and service
  tests passed. Time is synchronized to `PDC.format.lu`.
- Replication summary reports `0/5` failures from PDC to BDC, with the known
  operational error `1326` while querying PDC still present.
- Windows Update search returned `Count=0`; Windows Update and CBS reboot
  flags are clear.
- `PendingFileRenameOperations=True` with 28 non-empty delete operations,
  currently from ESET, EdgeUpdate, and Windows Installer temporary cleanup.
- Current boot time is `2026-08-23 21:56:29` Europe/Luxembourg time.
- `C:` has about `66.4 GB` free of `89.4 GB` and reports healthy.
- `WinRM` remains `Stopped`/`Disabled`. The dedicated SSH and WinRM rules are
  scoped to `192.168.1.73` and `192.168.113.2`, but BDC also retains an
  enabled local OpenSSH rule allowing any remote address. No rule was changed.
- The `SSH Admins` group (`sshadmins`) exists with one member, and `sshd_config`
  explicitly allows `format\\sshadmins`.
- No temporary `FormatOps-*` scheduled task remains.
- Recent grouped System warnings/errors were primarily time-service and DCOM
  events. Two Netlogon `5722` events refer to separate workstation trust
  failures; no BDC service or replication failure was observed.

Blast radius:

- The approved reboot will temporarily remove this backup domain controller
  and its DNS/AD services. PDC remains available and is the verified
  replication and time source. No AD, DNS, GPO, replication, firewall, SSH,
  or WinRM configuration change is in scope.

Planned action:

- Reboot BDC last, after Kuhnle and LMR have recovered, to process the pending
  cleanup queue. Recheck updates, reboot flags, rename state, DC services,
  SYSVOL/NETLOGON, time, replication, SSH aliases, events, and disk health.

## 2026-09-05 - Reboot Deferred After Kuhnle Domain-Access Delay

Result:

- BDC was not rebooted because the sequential maintenance run stopped after
  Kuhnle's domain user lookup and domain-admin SSH failed to recover within
  the observation window.
- BDC remains online with zero applicable Windows updates and the verified DC,
  DNS, SYSVOL/NETLOGON, time, and inbound-replication checks healthy.
- Its 28 pending application-cleanup delete operations remain queued for a
  later approved reboot window. No AD, DNS, replication, firewall, SSH, WinRM,
  or other configuration change was made.

## 2026-09-05 - System Files Cleanup Pre-State

Authorization and scope:

- The user requested Windows Disk Cleanup with system files on all three ESX-C
  VMs.
- Use the established `cleanmgr` SYSTEM profile on `C:` only. Select all 27
  cleanup categories exposed by this VM except `DownloadsFolder`; no ad hoc
  file deletion, non-system volume cleanup, AD/DNS/SYSVOL data deletion, or
  configuration change is in scope.
- The selected surface includes Windows Update Cleanup, previous installations,
  Windows ESD installation files, device-driver packages, discarded upgrade
  files, temporary/setup/error-reporting files, caches, Defender cleanup, and
  Recycle Bin. This can remove rollback resources exposed by Windows Disk
  Cleanup.

Pre-state and blast radius:

- `C:` has about `66.39 GiB` free of `89.40 GiB` and reports healthy.
- Windows Update and CBS reboot flags are clear. TiWorker and TrustedInstaller
  were active after the discovery scan, so cleanup must wait until they exit.
- DNS, DFSR, Netlogon, NTDS, `sshd`, and Windows Time are
  `Running`/`Automatic`.
- Cleanup can increase CPU and disk activity and invoke DISM, TiWorker, or
  TrustedInstaller for an extended period. BDC remains domain-critical; no AD,
  DNS, SYSVOL, replication, or GPO content is in scope, and no reboot is
  planned. Run BDC last and stop on any DC-service degradation.

## 2026-09-05 - Cleanup Launch Deferred After VPN Route Loss

- BDC cleanup was not launched. The administration route to all ESX-C guests
  fell back to Wi-Fi while Kuhnle cleanup was being monitored.
- Restore and verify the VPN route, then repeat DC services, SYSVOL/NETLOGON,
  time, replication, update, reboot, disk, and servicing checks before creating
  any BDC cleanup profile or task. BDC remains last in the sequence.

## 2026-09-05 - System Files Cleanup Launched; Verification Interrupted

- After the VPN returned, reconfirmed DNS, DFSR, Netlogon, NTDS, `sshd`, and
  Windows Time running, SYSVOL/NETLOGON present, and replication summary at
  `0/5` failures with the known `1326` query caveat.
- Waited until TiWorker and TrustedInstaller were absent in two consecutive
  checks, then created cleanup profile `905` with all 27 discovered categories
  except `DownloadsFolder`.
- Started `cleanmgr /d C /sagerun:905` as local SYSTEM through scheduled task
  `FormatOps-CleanMgr-20260905-BDC`. Free space at launch was about
  `66.34 GiB`.
- DNS, NTDS, and DFSR remained running during the initial cleanup observation.
  No duplicate task was created and no process was terminated.
- The VPN became unreachable again while cleanup was running. Completion,
  reclaimed space, profile/task removal, reboot flags, DC services, shares,
  time, replication, and final SSH checks remain pending verification.


## 2026-09-13 - Maintenance Discovery And Patch Scope

- Both configured SSH aliases work. Last observed boot: 2026-09-05 18:28:42 local time.
- C: free space 65.86 GiB; fixed volumes report Healthy. Windows Update/CBS reboot markers are clear.
- Pending rename queue has 6 non-empty strings, including security-driver backup/temporary files and MSI/Windows temporary cleanup. No manual queue or file deletion is planned.
- DNS, DFSR, NTDS, Netlogon, SSH, and time services are Running/Automatic. SYSVOL/NETLOGON are present; focused dcdiag tests pass; all five inbound replication contexts succeeded. Time is synchronized to PDC.
- Update scan succeeded and offers: KB890830, KB5126149, KB5122882.
- Recent warning/error summaries retain previously observed categories; no full application transaction or backup restore was tested. Current backup success and hypervisor job state are not independently verified in this guest-only pass.
- September 5 cleanup task is Ready with LastTaskResult 267014 (0x41306, terminated). No cleanmgr/DismHost remains. Cleanup success and reclaimed bytes cannot be established from this result.
- Correction to prior cleanup scope: Microsoft documents that /sagerun enumerates all drives and ignores /d. The earlier C:-only assertion was incorrect; no per-drive deletion audit is available. See https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr.
- Retire only the stopped FormatOps-CleanMgr-20260905 task for this VM and its StateFlags0905 profile properties. Do not restart broad Disk Cleanup during this patch round.
- Reboot BDC last, with PDC available, temporarily reducing AD/DNS redundancy. Verify DC services, shares, time, and replication afterward. Wait for existing servicing workers to exit before starting one monitored SYSTEM installer. Keep unrelated AD, GPO, firewall, SSH, WinRM, and application configuration unchanged.

## 2026-09-13 - Domain Controller Kept Online

- BDC patching and reboot are held after Kuhnle's post-reboot domain authentication regression. The three offered updates remain to be installed; this is not a completed patch round for BDC.
- Repeat checks at approximately 12:35 local time passed Connectivity, Advertising, SysVolCheck, NetLogons, and Services. SYSVOL and NETLOGON are present; all five inbound replication contexts report successful last attempts, including the writable domain context at 12:34:55. Windows Time remains synchronized to PDC.
- Removed the stopped September 5 cleanup task and its 27 StateFlags0905 properties. No new Disk Cleanup, update installer, reboot, or AD/DNS/GPO/replication change was started on BDC.

## 2026-09-13 - Read-Only NTLM Event Review

- Latest sampled successful domain credential validation includes EXCHANGE3 monitoring accounts and non-monitoring accounts from WORKSTATION. Event 4776 does not identify the destination service. Latest incoming blocked events show BDC$ as the local RPC-host process identity, not the remote user's identity.
- No policy/logging changes were made. Personal account names and detailed logs were kept out of the repository. See the [sanitized NTLM activity review](../../kerberos-ntlm-gpo-audit-2026-09-13.md#latest-ntlm-event-inspection) for timestamps, scope, and retention limits.

## 2026-09-13 - Authorized ADMIN NTLM Exception Removal

- User reports the Kyocera copier was corrected for Kerberos on September 11
  after its firmware update, and authorizes removing ADMIN's domain exception.
  The copier change itself has not been independently transaction-tested.
- Removed only `admin.format.lu` from Default Domain Policy on PDC after a
  protected guest-local GPO backup. Other entries and settings, permissions,
  links, and OU placement were preserved. ADMIN's separate incoming-NTLM Allow
  policy is unchanged. No BDC reboot, service restart, or forced refresh.
- At 14:09:47 CEST, BDC reports the updated five-entry policy and computer
  AD/SYSVOL versions 388/388, user 17/17. Core DC/SSH services are running,
  SYSVOL/NETLOGON are present, and no replication failures are reported.
- At 14:12:28, normal background application removed ADMIN from BDC's
  effective exception list. No exact ADMIN match appeared in the inspected
  post-change NTLM Operational events. This short window is not an application
  compatibility guarantee; copier scan and normal ADMIN/RDP access remain to
  be tested by the user.
- Full scope, backup reference, rollback, and PDC verification are tracked in
  the [domain audit change record](../../kerberos-ntlm-gpo-audit-2026-09-13.md#admin-exception-removal).
