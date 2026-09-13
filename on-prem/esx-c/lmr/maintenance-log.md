# LMR Maintenance Log

## 2026-04-18 - Runbook Created

Scope:

- Created ESX-C starter runbook structure.
- Inspected repository documentation and local SSH alias configuration only.
- No connection to `LMR` was made during this entry.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data changes were made.

Findings:

- Repo already had Windows remote-admin guidance in `docs/windows-ssh.md` and `docs/ssh-config.md`.
- Repo already had ESX-D and ESX-E on-prem runbook patterns under `on-prem/`.
- Local SSH config resolves `win-lmr` to `192.168.1.8` as local `Administrateur`.
- Local SSH config resolves `winad-lmr` to `192.168.1.8` as `format\Administrateur`.
- Both aliases use `~/.ssh/windows-admin_ed25519`.
- Role, domain membership, service state, firewall scope, update state, event logs, and disk state are not yet verified.

Next safe checks:

- Verify `win-lmr` with read-only `hostname` and `whoami`.
- Verify `winad-lmr` only after confirming current local access and domain membership expectations.
- Record role, hostname, domain membership, IP, SSH alias state, WinRM state, firewall scope, updates, services, event logs, and disk state before changes.

## 2026-04-18 - Pre-Update Discovery

Scope:

- Performed read-only preflight before installing Windows updates.
- No reboot, snapshot, migration, power, firewall, SSH, WinRM, GPO, or data changes were made during discovery.

Findings:

- `win-lmr` authenticated key-only and returned hostname `LMR`, identity `lmr\administrateur`.
- `winad-lmr` authenticated key-only and returned hostname `LMR`, identity `format\administrateur`.
- OS: Windows Server 2022 Standard, version `10.0.20348`.
- Domain: `format.lu`.
- Domain role: `MemberServer`.
- Domain secure channel was healthy; `nltest /sc_query:format.lu` succeeded against `\\PDC.format.lu`.
- Services: `sshd` was `Running`/`Automatic`; `WinRM` was `Stopped`/`Disabled`.
- `winrm enumerate winrm/config/listener` failed because WinRM was not running.
- Remote-admin firewall address filters for the expected SSH/WinRM rules were scoped to `192.168.1.73` and `192.168.113.2`.
- Disk health reported healthy volumes; `C:` had about 31 GB free of about 128 GB and `D:` had about 963 GB free of about 1.1 TB.
- Recent hotfixes showed March 2026 security updates installed.
- Last 7 days event count: `System=0`, `Application=63` warnings/errors.
- Pending Windows Update inventory showed 4 software updates:
  - Security Update for SQL Server 2019 RTM GDR (`KB5084817`)
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Blast radius:

- `LMR` is confirmed as a domain-joined Windows member server, but application role is still not verified.
- The pending SQL Server 2019 security update implies SQL Server is installed or update-applicable on this host; treat as potentially application-critical.
- Installing OS and SQL updates may require a later reboot or service restart even though the update search reported `Reboot=False` before installation.
- Do not reboot without an explicit maintenance window because production role and user impact are not yet documented.

## 2026-04-18 - Windows Updates Installed, Reboot Pending

Scope:

- Installed pending software updates using the Windows Update COM API from a temporary `NT AUTHORITY\SYSTEM` scheduled task.
- No reboot was performed.
- No VMware, GPO, firewall, SSH, WinRM, power, snapshot, migration, or data changes were made.
- Temporary scheduled task `FormatOps-WindowsUpdate-NoReboot` was deleted after completion.
- Temporary installer script `C:\ProgramData\FormatOps\Install-WindowsUpdates-NoReboot.ps1` was removed after completion.
- Installer log was left on the server at `C:\ProgramData\FormatOps\Logs\windows-update-20260418-lmr.log`.

Result:

- Updates ran as `NT AUTHORITY\SYSTEM`.
- Download result: `2` (succeeded).
- Install result: `2` (succeeded).
- `RebootRequired=True`.
- Installed successfully with per-update `hresult=0x00000000`:
  - Security Update for SQL Server 2019 RTM GDR (`KB5084817`)
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Post-checks:

- `LMR` remained reachable over SSH after install.
- Domain secure channel remained healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update search still listed `KB5082142` as pending, consistent with the reboot-required state.
- Registry reboot check: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired` exists.

Next:

- Schedule an explicit reboot window for `LMR` before considering the cumulative update complete.
- After reboot, verify application role, SQL Server state if applicable, domain secure channel, event logs, disk state, and Windows Update pending count.

## 2026-04-18 - Reboot Completed After Updates

Scope:

- Rebooted `LMR` with explicit approval after successful update installation.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, or data changes were made.

Result:

- Reboot completed successfully.
- Post-reboot boot time: 2026-04-18 22:31:04.
- `LMR` remained reachable over SSH as `lmr\administrateur`.
- Windows Update pending count after reboot: `0`.
- Registry reboot check after reboot: `False`.
- Domain secure channel remained healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.

Next:

- Verify application role and SQL Server state if applicable.
- Review post-reboot event logs during the next application-specific health check.

## 2026-05-03 - Planned Shutdown For ESX-C Host Maintenance

Scope:

- Operator indicated `LMR` would be shut down as part of a coordinated three-VM
  ESX-C host-maintenance window.
- This entry records the approved maintenance context only.
- No live verification command was run from this thread at the time of
  documentation.

Findings:

- `LMR` had already completed its April 2026 Windows update and reboot cycle in
  the earlier entries above.
- The planned shutdown is for ESX-C host maintenance, not for additional guest
  OS patching.

Notes:

- Shutdown action was operator-performed/planned outside this thread.
- Any later power-on verification should confirm SSH reachability, domain
  secure channel, and SQL/application service state again after the ESX-C host
  work.

## 2026-05-16 - Twice-Monthly Maintenance Attempt Blocked While VM Offline

Scope:

- Started the next twice-monthly ESX-C maintenance pass.
- Limited this entry to non-mutating reachability checks because the VMs were
  expected to have been shut down for ESX-C host maintenance.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made from this thread.

Findings:

- `nc -vz -G 5 192.168.1.8 22` timed out.
- `nc -vz -G 5 192.168.1.8 5985` timed out.
- `LMR` was not reachable yet for guest-level maintenance verification.

Result:

- Twice-monthly guest maintenance for `LMR` could not proceed because the VM
  was still offline or otherwise unreachable during the ESX-C host-maintenance
  window.

Next:

- Re-run the normal `LMR` post-power-on verification after ESX-C host work is
  complete and guest network reachability returns.

## 2026-05-16 - Post-Power-On Verification After ESX-C Host Maintenance

Scope:

- Re-tried the twice-monthly ESX-C maintenance pass after VPN reachability was
  restored and the guest came back online.
- Limited this entry to post-power-on verification and Windows Update
  discovery.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made from this thread.

Findings:

- `LMR` responded on SSH again as `lmr\administrateur`.
- Last boot time observed: `2026-05-03 16:55:55`.
- Domain secure channel still tested healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Current observed free space:
  - `C:` about `27.0 GB` free of `119.4 GB`
  - `D:` about `895.8 GB` free of `1024 GB`
- Windows Update COM search from the SSH session failed with `0x80240032`.
- Windows Update operational log still showed background scans finding
  available software updates on 2026-05-16:
  - repeated `found 3 updates`
  - repeated `found 1 updates`
- Reboot indicators were mostly clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=True`
- Recent warnings/errors remained mostly baseline-type noise, especially VMware
  virtual TPM `1803`, `DCOM 10016`, and recurring `AutoEnrollment 64`
  application warnings.

Result:

- `LMR` came back cleanly after ESX-C host maintenance and remained generally
  consistent with its earlier baseline.
- Guest patch installation did not proceed yet in this entry because the
  remote, non-interactive Windows Update enumeration path was not giving a
  trustworthy update list.

## 2026-05-16 - Windows Update Install Started, Servicing Still Running

Scope:

- Started Windows Update installation on `LMR` using a temporary
  `NT AUTHORITY\\SYSTEM` scheduled task after the post-power-on checks.
- No reboot was performed in this entry.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, power, or data
  changes were made.

Findings:

- SYSTEM-side update inventory/logging captured this currently available update
  set:
  - Security update for SQL Server 2019 RTM GDR (`KB5090408`)
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
  `found 3 updates` / `found 1 updates` to `found 1 updates` / `found 1
  updates`.
- Reboot indicators during the in-progress state were:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=True`
  - `PendingFileRenameOperations=False`
- `Get-HotFix` did not yet show the May 2026 update KBs at the time of this
  snapshot.

Result:

- Update installation was started successfully on `LMR`, but it had not reached
  a final completed state within this maintenance window snapshot.
- `LMR` should be treated as mid-servicing until a later verification confirms
  task completion or a reboot-finalized post-install state.

## 2026-05-17 - Manual Update Install And Reboot Verified

Scope:

- Operator reported manually completing the pending May 2026 Windows updates
  and reboot on `2026-05-16`.
- Performed read-only verification on `2026-05-17` over SSH.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made from this thread.

Findings:

- `LMR` responded on SSH as `lmr\administrateur`.
- Last boot time observed after the operator reboot:
  `2026-05-16 16:22:14` Europe/Luxembourg time.
- Domain secure channel still tested healthy against `\\BDC.format.lu`.
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

- `LMR` appears successfully updated and rebooted for the May 2026 cycle.
- The earlier `2026-05-16` "servicing still running" state is now superseded
  by the operator-completed update and the clean post-reboot verification.

## 2026-05-17 - System Cleanup Launched

Scope:

- Launched Windows Disk Cleanup (`cleanmgr`) on `C:` for `LMR`.
- Selected the system-cleanup categories by setting the `VolumeCaches`
  `StateFlags517` entries and running `cleanmgr /d C /sagerun:517`.
- Interpreted "system files cleanup" conservatively by excluding only
  `DownloadsFolder`; the rest of the cleanup categories exposed by `cleanmgr`
  were selected.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made from this thread.

Blast radius review:

- `cleanmgr.exe` was present at `C:\\Windows\\System32\\cleanmgr.exe`.
- Pre-launch `C:` free space was about `26.7 GB` of about `128.2 GB`.
- `LMR` had no Windows Update or CBS reboot-required flags before launch.

Selected cleanup surface:

- Included all visible `VolumeCaches` categories except `DownloadsFolder`.
- This included categories such as `Update Cleanup`, `Temporary Files`,
  `Windows Defender`, `Recycle Bin`, `Previous Installations`,
  `Temporary Setup Files`, `Windows Upgrade Log Files`, and any other cleanup
  categories currently exposed by `cleanmgr` on this host.

Observed runtime state:

- `cleanmgr`, `DismHost`, `TiWorker`, and `TrustedInstaller` all started and
  remained present during observation.
- The SSH wrapper was interrupted after an extended wait, but the cleanup
  processes continued to run on the host.
- Latest observed `C:` free space during the in-progress state was about
  `26.6 GB`.
- Reboot-required indicators stayed clear during observation:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`

Result:

- Cleanup launch succeeded on `LMR`.
- At the end of this observation window, cleanup still appeared to be
  in progress rather than fully completed.

## 2026-05-31 - End-Of-Month Verification

Scope:

- Performed read-only end-of-month verification for `LMR`.
- Checked reboot state, current update posture, cleanup follow-through, disk
  state, and domain secure-channel health.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made from this thread.

Findings:

- `LMR` responded on SSH as `lmr\administrateur`.
- Last boot time remained `2026-05-17 10:19:25` Europe/Luxembourg time.
- Domain secure channel still tested healthy against `\\PDC.format.lu`.
- Current free space:
  - `C:` about `30.6 GB` of about `128.2 GB`
  - `D:` about `961.7 GB` of about `1099.5 GB`
- Relative to the pre-cleanup `2026-05-17` snapshot, `C:` free space is up by
  about `3.9 GB`.
- Windows Update operational events on `2026-05-31` repeatedly reported
  `Windows Update successfully found 0 updates`.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True` has returned.
- Current pending rename queue is large (`70` entries) and is mostly composed
  of:
  - `C:\\Config.Msi\\*.rbf`
  - `C:\\WINDOWS\\Temp\\eset.temp\\...`
  - `C:\\Program Files\\TeamViewer\\Update\\update.exe`
  - `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.233.3`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `cleanmgr.exe` and `DismHost` were no longer present during this check, so
  the earlier cleanup launch no longer appears to be actively running.
- `TiWorker` and `TrustedInstaller` were present at low activity during the
  check, but without any reboot-required flags or available updates.

Result:

- `LMR` is currently reachable, stable, and not offering new Windows updates
  at the end of the month.
- Mid-month cleanup appears to have completed and reclaimed some space.
- A new pending rename queue remains and appears tied to MSI/ESET/TeamViewer/
  EdgeUpdate cleanup rather than the earlier empty-update state alone.

## 2026-05-31 - Rebooted To Clear Pending Rename Queue

Scope:

- Rebooted `LMR` with explicit operator approval to test whether the current
  `PendingFileRenameOperations` queue would clear naturally.
- Performed post-reboot verification for boot time, reboot-required flags,
  pending rename state, and initial domain secure-channel behavior.
- No VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration, power, or
  data changes were made from this thread beyond the approved reboot itself.

Findings:

- Post-reboot boot time observed: `2026-05-31 09:15:41` Europe/Luxembourg
  time.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=False` after reboot; pending count is now `0`.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Immediate post-reboot secure-channel checks still returned:
  - `Status = 1311 0x51f ERROR_NO_LOGON_SERVERS`
- A second check after a short wait still returned the same `ERROR_NO_LOGON_SERVERS`
  result during this turn.

Result:

- The reboot cleared the current `PendingFileRenameOperations` queue on `LMR`.
- `LMR` came back on SSH cleanly, but domain logon/DC reachability still needs
  follow-up because the secure-channel check did not recover during this
  observation window.

## 2026-05-31 - End-Of-Month Windows Update Check

Scope:

- Ran a Windows Update inventory/install pass as `NT AUTHORITY\\SYSTEM` using
  the Windows Update COM API.
- No updates were installed because Windows Update returned no applicable
  software updates.
- No reboot, VMware, GPO, firewall, SSH, WinRM, snapshot, migration, power, or
  data changes were made.

Findings:

- Temporary task `FormatOps-WU-Install-20260531` ran successfully with
  `LastTaskResult=0`.
- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260531-lmr.log`
- Windows Update result:
  - `Count=0`
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- Domain secure channel recovered after the earlier post-reboot warning:
  `nltest /sc_query:format.lu` succeeded against `\\BDC.format.lu`.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260531`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260531.ps1`

Result:

- `LMR` had no pending Windows software updates at the time of this pass.
- No reboot is required from this update check.
- The earlier post-reboot `ERROR_NO_LOGON_SERVERS` condition is no longer
  present in this follow-up check.

## 2026-05-31 - Operator Cleanup And Shutdown For ESX-C Host Restart

Scope:

- Operator reported cleaning up disk space on `LMR`.
- Operator reported shutting down `LMR` afterward as part of an ESX-C host
  restart window.
- This entry records the approved maintenance context only.
- No live verification command was run from this thread at the time of this
  documentation entry.

Findings:

- The disk cleanup and shutdown were operator-performed outside this thread.
- The shutdown is for ESX-C host maintenance, not for additional guest Windows
  patching.
- Earlier in this maintenance pass, Windows Update returned `Count=0`,
  `PendingFileRenameOperations=False`, no reboot-required flags, and the domain
  secure channel had recovered successfully.

Next:

- After ESX-C host restart and guest power-on, verify `LMR` SSH reachability,
  domain secure channel, reboot-required state, free space, and SQL/application
  service state if applicable before closing the maintenance cycle.

## 2026-06-14 - Twice-Monthly Maintenance Verification

Scope:

- Performed read-only post-host-restart and twice-monthly maintenance checks.
- Ran a Windows Update inventory/install pass as `NT AUTHORITY\\SYSTEM` using
  the Windows Update COM API.
- No updates were installed because Windows Update returned no applicable
  software updates.
- No reboot, VMware, GPO, firewall, SSH, WinRM, snapshot, migration, power, or
  data changes were made.

Findings:

- `LMR` responded on SSH as `lmr\\administrateur`.
- Last boot time observed: `2026-06-13 22:29:39` Europe/Luxembourg time.
- Domain secure channel tested healthy against `\\BDC.format.lu`.
- Recent hotfixes show June 2026 updates already installed on `2026-06-13`:
  - `KB5094147`
  - `KB5094128`
- Windows Update operational events repeatedly reported
  `Windows Update successfully found 0 updates`.
- SYSTEM-side Windows Update task `FormatOps-WU-Install-20260614` completed
  with `LastTaskResult=0`.
- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260614-lmr.log`
- Windows Update result:
  - `Count=0`
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=True`
- Current pending rename queue contains one EdgeUpdate cleanup entry:
  `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.239.19`.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Current free space:
  - `C:` about `27.5 GB` of about `128.2 GB`
  - `D:` about `961.6 GB` of about `1099.5 GB`

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260614`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task_20260614.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260614.ps1`

Result:

- `LMR` has no pending Windows software updates visible to Windows Update.
- A reboot window is recommended to clear the current EdgeUpdate
  `PendingFileRenameOperations` queue.

## 2026-07-04 - Inspection Round

Scope:

- Performed read-only inspection of `LMR`.
- Checked SSH reachability, boot time, update visibility, reboot flags,
  pending rename state, free space, service state, and domain secure channel.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made.

Findings:

- `LMR` responded on SSH as `lmr\\administrateur`.
- Last boot time observed: `2026-06-17 21:52:31` Europe/Luxembourg time.
- Domain secure channel tested healthy against `\\BDC.format.lu`.
- Windows Update operational events repeatedly reported
  `Windows Update successfully found 0 updates`.
- Recent hotfixes still show June 2026 updates installed:
  - `KB5094147`
  - `KB5094128`
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True`; current queue is small (`4` string
  entries / `2` rename pairs), related to EdgeUpdate and TeamViewer cleanup:
  - `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.241.13`
  - `C:\\Program Files\\TeamViewer\\Update\\update.exe`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Current free space:
  - `C:` about `24.8 GB` of about `128.2 GB`
  - `D:` about `961.5 GB` of about `1099.5 GB`

Result:

- `LMR` is reachable, domain-connected, and not showing available Windows
  updates in the inspected Windows Update events.
- No update or reboot action was taken during this inspection.
- The remaining pending rename queue appears tied to EdgeUpdate/TeamViewer
  cleanup and can be cleared in a future reboot window.

## 2026-07-19 - Twice-Monthly Maintenance And July Updates

Scope:

- Performed ESX-C twice-monthly maintenance for `LMR`.
- Ran Windows Update installation as `NT AUTHORITY\\SYSTEM` using the Windows
  Update COM API from temporary scheduled task
  `FormatOps-WU-Install-20260719`.
- No reboot was performed from this thread.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, power, or data
  changes were made.

Pre-update findings:

- `LMR` responded on SSH as `lmr\\administrateur`.
- Last boot before updates was observed as `2026-07-04 21:38:28`
  Europe/Luxembourg time.
- Domain remained `format.lu`; domain role remained member server.
- `sshd` was `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Domain secure channel tested healthy against `\\PDC.format.lu`.
- Current free space before installation:
  - `C:` about `24.8 GB`
  - `D:` about `961.4 GB`
- Windows Update reported four applicable updates:
  - Security Update for SQL Server 2019 RTM GDR (`KB5102336`)
  - Windows Malicious Software Removal Tool x64 v5.143 (`KB890830`)
  - 2026-07 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1
    (`KB5102206`)
  - 2026-07 cumulative update for Microsoft server operating system version
    21H2 for x64-based systems (`KB5099540`)

Update result:

- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260719-lmr.log`
- Download result: `2` (succeeded), `HResult=0`.
- Install result: `2` (succeeded), `RebootRequired=True`, `HResult=0`.
- Per-update results for `KB5102336`, `KB890830`, `KB5102206`, and
  `KB5099540` were all `Result=2`, `HResult=0`.
- Post-servicing hotfix inventory shows July 2026 updates installed on
  `2026-07-19`:
  - `KB5099540`
  - `KB5101010`
  - `KB5120210`

Post-checks:

- `LMR` remained reachable over SSH after installation.
- Windows Update search returned `Count=0`.
- Reboot-required indicators remain set because `LMR` has not rebooted since
  the update install:
  - `WindowsUpdate\\Auto Update\\RebootRequired=True`
  - `Component Based Servicing\\RebootPending=True`
  - `PendingFileRenameOperations=False`
- Domain secure channel remained healthy against `\\PDC.format.lu`.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Recent System log review showed two recent warning/error items in the checked
  window: service-control event `7031` and virtual TPM event `1803`; no
  corrective action was taken in this thread.
- Current free space after servicing:
  - `C:` about `19.0 GB` of `119.4 GB`
  - `D:` about `895.3 GB` of `1024 GB`

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260719`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task_20260719.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260719.ps1`

Result:

- July Windows updates installed successfully and Windows Update now reports no
  applicable software updates.
- `LMR` still needs an explicit reboot window to complete the July update
  cycle and clear Windows Update/CBS reboot-required state.
- After reboot, verify SSH reachability, domain secure channel, SQL/application
  service state if applicable, event logs, disk state, and reboot-required
  indicators.

## 2026-07-19 - Post-Maintenance Clean Follow-Up

Scope:

- Rechecked `LMR` after the July maintenance round had time to settle.
- Performed discovery-only checks for update visibility, reboot-required
  indicators, pending rename state, SSH/WinRM service state, and domain secure
  channel.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made.

Findings:

- `LMR` responded on SSH.
- Current boot time observed: `2026-07-19 11:16:11` Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Reboot-required indicators are now clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `sshd` was `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Domain secure channel tested healthy:
  - `Test-ComputerSecureChannel -Server PDC.format.lu=True`
  - `nltest /sc_query:format.lu` returned `NERR_Success` against
    `\\PDC.format.lu`

Result:

- `LMR` is clean from the checked Windows Update, reboot-required,
  pending-rename, SSH service, and domain secure-channel perspective.
- The earlier July update reboot-required state is now cleared.

## 2026-08-04 - Maintenance Attempt Blocked By Network Reachability

Scope:

- Started a new ESX-C maintenance pass for `LMR`.
- Limited the pass to repository review and non-mutating network reachability
  checks because the guest was not reachable.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made.

Findings:

- `nc` to `192.168.1.8:22` failed with connection refused.
- `nc` to `192.168.1.8:5985` failed with connection refused.
- SSH via `win-lmr` failed with connection refused on port `22`.
- ICMP returned `Communication prohibited by filter` from `10.128.128.128`,
  then timed out.

Result:

- Guest-level maintenance could not proceed because network reachability to
  `LMR` is blocked or the required tunnel/filter path is not open.

Next:

- Re-run discovery after the VPN/tunnel/firewall path to the ESX-C guest
  subnet is confirmed open.

## 2026-08-04 - Maintenance Retry And Pre-Change Inspection

Scope:

- Retried the ESX-C maintenance pass after the VPN/tunnel path was restored.
- Performed discovery-only checks for identity, role/domain state, Windows
  Update, reboot state, disks, SSH/WinRM, firewall scope, event health, SQL
  service state, DNS, time, Netlogon, AD port reachability, and domain secure
  channel.
- No update, reboot, VMware, domain, GPO, firewall, SSH, WinRM, snapshot,
  migration, power, or data change was made.

Findings:

- Local `win-lmr` and domain `winad-lmr` SSH aliases are reachable.
- Hostname is `LMR`, IP is `192.168.1.8/24`, and the VM remains a `format.lu`
  member server.
- Last boot remains `2026-07-19 11:16:11` Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Windows Update and CBS reboot-required indicators are clear.
- `PendingFileRenameOperations=True`; the queue contains six strings, with
  non-empty items categorized as EdgeUpdate and TeamViewer cleanup.
- Free space is about `25.1 GB` on `C:` and `895.2 GB` on `D:`.
- `sshd` is `Running`/`Automatic`. `WinRM` remains `Stopped`/`Disabled`.
- Existing SSH port `22` and WinRM port `5985` rules are scoped to trusted
  sources `192.168.1.73` and `192.168.113.2`; no firewall change was made.
- The `IMOSSQL2019` SQL Server service and full-text launcher are running; SQL
  Agent remains stopped/disabled.
- DNS servers remain PDC (`192.168.1.5`) and BDC (`192.168.1.4`). Netlogon,
  DNS Client, and Windows Time are `Running`/`Automatic`, and time is
  synchronized to `PDC.format.lu`.
- PDC AD ports `88`, `135`, `389`, `445`, `464`, and `3268` are reachable and
  DC locator successfully finds PDC.
- The machine secure channel is not healthy: both
  `Test-ComputerSecureChannel -Server PDC.format.lu` and
  `nltest /sc_query:format.lu` failed, with the latter reporting
  `ERROR_NO_LOGON_SERVERS`. Domain-admin SSH still authenticates successfully.
- A follow-up `nltest /sc_query:format.lu` run as local SYSTEM through temporary
  task `FormatOps-SecureChannel-Check-20260804` returned the same
  `ERROR_NO_LOGON_SERVERS`, confirming this is not limited to the SSH logon
  context. The temporary task and output file were removed afterward.
- Seven-day System warning/error groups were mainly virtual TPM `1803`, plus
  DCOM `10016` and one Windows Installer service restart event `7031`.

Blast radius before any repair:

- A secure-channel reset would change LMR's member-computer trust state against
  the domain and could affect domain authentication, the IMOS application, and
  SQL-related access using domain identities. No reset, Netlogon restart,
  domain rejoin, or GPO action was attempted during this inspection.

Result:

- No applicable Windows updates are currently visible and no Windows Update or
  CBS reboot is pending.
- LMR and its checked SQL service are reachable, and AD network prerequisites
  are healthy, but the machine secure channel requires a separate approved
  remediation or an approved reboot/recheck window before this round can be
  called fully clean.

## 2026-08-04 - Planned Guest Shutdown For ESX-C Host Maintenance

Scope:

- Shut down `LMR` at the user's request for physical ESX-C host maintenance.
- No VMware power operation, forced application termination, domain/GPO,
  firewall, SSH, WinRM, update, snapshot, migration, or data change was made.

Action and result:

- Direct shutdown from the SSH token was rejected and did not change guest
  state.
- Submitted an orderly Windows guest shutdown as local SYSTEM with planned
  hardware-maintenance reason code `p:1:1` through temporary scheduled task
  `FormatOps-Shutdown-20260804-LMR`.
- The task action was configured to remove itself after submitting the shutdown
  request.
- SSH port `22` stopped responding after the shutdown request. This confirms
  guest network services are offline; hypervisor power state was not queried
  from this thread.

Post-start checks:

- After ESX-C host maintenance, verify SSH reachability, boot time, Windows
  Update and reboot flags, pending rename state, domain secure channel, time,
  disks, IMOS/SQL services, events, and absence of the temporary shutdown task.

## 2026-08-23 - Twice-Monthly Maintenance Pre-Install State

Scope:

- Started a new ESX-C maintenance round and completed discovery before Windows
  servicing.
- No reboot, VMware, domain/GPO, firewall, SSH, WinRM, snapshot, migration,
  power, or data change was made during discovery.

Findings:

- LMR is reachable over local SSH and booted after host maintenance at
  `2026-08-04 20:43:23` Europe/Luxembourg time.
- The `format.lu` secure channel has recovered: PowerShell returned `True`
  and `nltest` returned `NERR_Success` against PDC.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`;
  WinRM remains `Stopped`/`Disabled`.
- IMOS SQL Server and its full-text launcher are running; SQL Agent remains
  stopped/disabled.
- Windows Update and CBS reboot flags are clear.
- `PendingFileRenameOperations=True` with 26 strings, mainly EdgeUpdate
  cleanup.
- Free space is about `25.0 GB` on `C:` and `894.9 GB` on `D:`.
- Three applicable updates are visible: `KB890830`, `KB5121650`, and
  `KB5120242`.
- Removed the confirmed stale August shutdown task and May update task; no
  FormatOps scheduled tasks remain.

Blast radius:

- Installation can restart Windows, IMOS, or SQL-related services and is
  expected to require a guest reboot, temporarily interrupting LMR application
  and database access. No domain trust, GPO, firewall, SSH, WinRM, or SQL
  configuration change is in scope.

## 2026-08-23 - August Updates Installed And Verified

Action:

- Installed the three discovered updates as local SYSTEM using temporary task
  `FormatOps-WU-Install-20260823` and the Windows Update COM API.
- Performed one planned update reboot with reason code `p:2:17`.
- No VMware, domain trust, GPO, firewall, SSH, WinRM, SQL, snapshot, migration,
  power, or data configuration change was made.

Install result:

- Log retained on the guest at
  `C:\ProgramData\FormatOps\Logs\windows-update-20260823-lmr.log`.
- Download and install result codes were `2` (succeeded).
- `KB890830`, `KB5121650`, and `KB5120242` each returned `Result=2`,
  `HResult=0`; Windows reported `RebootRequired=True`.
- Servicing completed at `2026-08-23 15:52:31`.

Post-checks:

- New boot time is `2026-08-23 16:25:47` Europe/Luxembourg time.
- Windows Update returned `Count=0`; Windows Update and CBS reboot flags are
  clear.
- `PendingFileRenameOperations=False`.
- Free space is about `22.1 GB` on `C:` and `894.9 GB` on `D:`.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`;
  WinRM remains `Stopped`/`Disabled`.
- IMOS SQL Server and its full-text launcher are running; SQL Agent remains
  stopped/disabled.
- The secure channel and `nltest` temporarily reported
  `ERROR_NO_LOGON_SERVERS` after reboot, then recovered naturally against
  PDC without a trust reset or Netlogon restart.
- Local `win-lmr` and domain `winad-lmr` SSH aliases both work after the
  recovery window.
- Post-boot event groups were time-service, DCOM, Kerberos, and virtual-TPM
  events in the inspected window; no corrective change was made.
- Temporary installer/reboot tasks and the temporary installer script were
  removed; the audit log remains.

Result:

- August updates are installed and Windows Update is clean.
- LMR is healthy from the checked update, reboot, rename, service, disk, SQL,
  secure-channel, and SSH-access perspectives.

## 2026-09-05 - Twice-Monthly Maintenance Pre-Reboot State

Scope:

- Started the September ESX-C maintenance round with read-only discovery.
- No Windows update, reboot, VMware, domain trust, GPO, firewall, SSH, WinRM,
  SQL, snapshot, migration, power, or data configuration change was made
  during discovery.

Findings:

- Local `win-lmr` and domain `winad-lmr` aliases are reachable and map to
  `192.168.1.8`; the respective identities are local and
  `format\\Administrateur`.
- LMR remains a `format.lu` member server. Its secure channel is healthy, and
  DC locator finds PDC.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`; WinRM remains
  `Stopped`/`Disabled`.
- `sshd_config` allows local administrators and `format\\sshadmins`. The
  enabled SSH and WinRM firewall rules remain scoped to `192.168.1.73` and
  `192.168.113.2`.
- The `IMOSSQL2019` SQL service is `Running`/`Automatic`; SQL Browser,
  telemetry, and SQL Writer are also running. SQL Agent remains intentionally
  `Stopped`/`Disabled`.
- Windows Update search returned `Count=0`; Windows Update and CBS reboot
  flags are clear.
- `PendingFileRenameOperations=True` with 29 non-empty delete operations,
  currently from ESET, TeamViewer, EdgeUpdate, and Windows Installer temporary
  cleanup.
- Current boot time is `2026-08-23 21:58:28` Europe/Luxembourg time.
- `C:` has about `24.0 GB` free of `119.4 GB`; `D:` has about `894.8 GB` free
  of `1024.0 GB`. Both report healthy.
- No temporary `FormatOps-*` scheduled task remains.
- Recent grouped System warnings/errors were mainly virtual-TPM, time-service,
  DCOM, and Kerberos events; no current SQL, secure-channel, or core-service
  failure was found.

Blast radius:

- The approved reboot will temporarily interrupt the IMOS application and its
  SQL database access. No SQL, domain trust, GPO, firewall, SSH, or WinRM
  configuration change is in scope.

Planned action:

- Reboot LMR after Kuhnle has recovered to process the pending cleanup queue.
  Recheck updates, reboot flags, rename state, SQL and core services, secure
  channel, both SSH aliases, events, and disk health before proceeding to BDC.

## 2026-09-05 - Reboot Deferred After Kuhnle Domain-Access Delay

Result:

- LMR was not rebooted after Kuhnle's domain user lookup and domain-admin SSH
  failed to recover within the observation window.
- LMR remains online with zero applicable Windows updates, healthy disks, a
  healthy secure channel, working local/domain SSH aliases, and the checked
  IMOS SQL services running.
- Its 29 pending application-cleanup delete operations remain queued for a
  later approved reboot window. No configuration or workload change was made.

## 2026-09-05 - System Files Cleanup Pre-State

Authorization and scope:

- The user requested Windows Disk Cleanup with system files on all three ESX-C
  VMs.
- Use the established `cleanmgr` SYSTEM profile on `C:` only. Select all 27
  cleanup categories exposed by this VM except `DownloadsFolder`; no ad hoc
  file deletion, non-system volume cleanup, SQL/application-data deletion, or
  configuration change is in scope.
- The selected surface includes Windows Update Cleanup, previous installations,
  Windows ESD installation files, device-driver packages, discarded upgrade
  files, temporary/setup/error-reporting files, caches, Defender cleanup, and
  Recycle Bin. This can remove rollback resources exposed by Windows Disk
  Cleanup.

Pre-state and blast radius:

- `C:` has about `23.95 GiB` free of `119.40 GiB` and reports healthy.
- Windows Update and CBS reboot flags are clear. TiWorker and TrustedInstaller
  were active after the discovery scan, so cleanup must wait until they exit.
- The `IMOSSQL2019` SQL service, `sshd`, Netlogon, and Windows Time are
  `Running`/`Automatic`.
- Cleanup can increase CPU and disk activity and invoke DISM, TiWorker, or
  TrustedInstaller for an extended period. SQL data is out of scope, but LMR
  application performance may be reduced while the system disk is busy. No
  reboot is planned.

## 2026-09-05 - Cleanup Launch Deferred After VPN Route Loss

- LMR cleanup was not launched. The administration route to all ESX-C guests
  fell back to Wi-Fi while Kuhnle cleanup was being monitored.
- Restore and verify the VPN route, then confirm SQL, update, reboot, disk, and
  servicing state again before creating any LMR cleanup profile or task.

## 2026-09-05 - System Files Cleanup Launched; Verification Interrupted

- After the VPN returned, confirmed no active servicing worker or prior cleanup
  task, then created cleanup profile `905` with all 27 discovered categories
  except `DownloadsFolder`.
- Started `cleanmgr /d C /sagerun:905` as local SYSTEM through scheduled task
  `FormatOps-CleanMgr-20260905-LMR`. Free space at launch was about
  `23.11 GiB`.
- One expected cleanup chain remained active during observation. The
  `IMOSSQL2019` SQL service stayed running and free space remained stable; no
  duplicate task was created and no process was terminated.
- The VPN became unreachable again while cleanup was running. Completion,
  reclaimed space, profile/task removal, reboot flags, SQL health, and final
  domain/SSH checks remain pending verification.


## 2026-09-13 - Maintenance Discovery And Patch Scope

- Both configured SSH aliases work. Last observed boot: 2026-09-05 18:28:48 local time.
- C: free space 21.64 GiB; fixed volumes report Healthy. Windows Update/CBS reboot markers are clear.
- Pending rename queue has 8 non-empty strings, including security-driver backup/temporary files and MSI/Windows temporary cleanup. No manual queue or file deletion is planned.
- IMOSSQL2019, its full-text launcher, and MySQL_CSF2_Master are running. SQL Agent is Stopped/Disabled. Domain trust, SID lookup, and both SSH aliases pass.
- Update scan succeeded and offers: KB890830, KB5126149, KB5122882, SQL Server KB5122773.
- Recent warning/error summaries retain previously observed categories; no full application transaction or backup restore was tested. Current backup success and hypervisor job state are not independently verified in this guest-only pass.
- September 5 cleanup task is Ready with LastTaskResult 267014 (0x41306, terminated). No cleanmgr/DismHost remains. Cleanup success and reclaimed bytes cannot be established from this result.
- Correction to prior cleanup scope: Microsoft documents that /sagerun enumerates all drives and ignores /d. The earlier C:-only assertion was incorrect; no per-drive deletion audit is available. See https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr.
- Retire only the stopped FormatOps-CleanMgr-20260905 task for this VM and its StateFlags0905 profile properties. Do not restart broad Disk Cleanup during this patch round.
- SQL patching may restart IMOSSQL2019; a reboot interrupts IMOS, MySQL, and other LMR workloads. Wait for existing servicing workers to exit before starting one monitored SYSTEM installer. Keep unrelated AD, GPO, firewall, SSH, WinRM, and application configuration unchanged.

## 2026-09-13 - Four Updates Installed; Reboot Deferred

- Started one SYSTEM installer at 12:23:18 local time, after confirming native servicing was idle. This overlapped Kuhnle's installer, but no simultaneous guest reboot was scheduled.
- Installer completed at 12:41:30: KB890830, SQL Server 2019 GDR KB5122773, .NET KB5126149, and OS KB5122882 each returned ResultCode 2 / HResult 0. Aggregate result was 2 / 0, RebootRequired True; scheduled task ended Ready / result 0.
- Reboot is held because Kuhnle lost domain authentication after its reboot. LMR remains on its September 5 boot. At 12:42, Windows Update and CBS reboot markers are set and the rename queue contains nine non-empty strings. Do not reinstall updates or manually clear these markers before the planned reboot.
- MSSQL$IMOSSQL2019, MySQL_CSF2_Master, Netlogon, sshd, and Windows Time are Running/Automatic. Both SSH aliases, secure-channel validation, and domain-account lookup pass. WinRM remains Stopped/Disabled, unchanged.
- C: has 17.72 GiB free and D: 894.75 GiB; both report Healthy. No Application warning/error events were returned for this maintenance window. These are service-level checks, not application transaction or database integrity tests.
- Removed the stopped September 5 cleanup task and all 27 StateFlags0905 properties; verification finds zero remaining profile flags. No new broad Disk Cleanup was launched.
- Removed this round's completed installer task and transferred script; its audit log remains under C:\ProgramData\FormatOps\Logs. Native servicing workers were not interrupted.
- Pending: controlled reboot after the Kuhnle recovery gate is resolved, then confirm a new boot, SQL/MySQL services, both SSH paths, domain trust, reboot markers, disk state, event summaries, and a fresh successful update scan. Until then, patch finalization and post-reboot health are unverified.

## 2026-09-13 - Read-Only NTLM Event Review

- Latest local credential-validation records correlate with this audit's public-key SSH sessions and do not establish application use of network NTLM. Latest retained incoming blocked event is 4002 at 10:30:39, with local caller LMR$/PID 4; no remote user/source is identified.
- No policy/logging changes or reboot were performed. See the [sanitized activity review](../../kerberos-ntlm-gpo-audit-2026-09-13.md#latest-ntlm-event-inspection) for evidence and retention limits.
