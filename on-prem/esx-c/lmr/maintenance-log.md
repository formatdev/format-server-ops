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
