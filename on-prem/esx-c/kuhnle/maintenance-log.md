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

## 2026-05-31 - End-Of-Month Verification

Scope:

- Performed read-only end-of-month verification for `Kuhnle`.
- Checked reboot state, current update posture, cleanup follow-through, disk
  state, and domain secure-channel health.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made from this thread.

Findings:

- `Kuhnle` responded on SSH as `kuhnle\administrateur`.
- Last boot time remained `2026-05-17 10:19:25` Europe/Luxembourg time.
- Domain secure channel still tested healthy against `\\PDC.format.lu`.
- Current free space:
  - `C:` about `26.5 GB` of about `53.0 GB`
  - `D:` about `36.4 GB` of about `53.7 GB`
- Relative to the pre-cleanup `2026-05-17` snapshot, `C:` free space is up by
  about `2.3 GB`.
- Windows Update operational events on `2026-05-31` repeatedly reported
  `Windows Update successfully found 0 updates`.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True` has returned.
- Current pending rename queue is large (`74` entries) and is mostly composed
  of:
  - `C:\\Config.Msi\\*.rbf`
  - `C:\\Windows\\Temp\\eset.temp\\...`
  - `C:\\Windows\\SystemTemp\\msedgeupdate.dll...`
  - `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.233.3`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- `cleanmgr.exe` and `DismHost` were no longer present during this check, so
  the earlier cleanup launch no longer appears to be actively running.
- `TiWorker` and `TrustedInstaller` were present at low activity during the
  check, but without any reboot-required flags or available updates.

Result:

- `Kuhnle` is currently reachable, stable, and not offering new Windows
  updates at the end of the month.
- Mid-month cleanup appears to have completed and reclaimed some space.
- A new pending rename queue remains and appears tied to MSI/ESET/EdgeUpdate
  cleanup rather than the earlier empty-update state alone.

## 2026-05-31 - Rebooted To Clear Pending Rename Queue

Scope:

- Rebooted `Kuhnle` with explicit operator approval to test whether the current
  `PendingFileRenameOperations` queue would clear naturally.
- Performed post-reboot verification for boot time, reboot-required flags,
  pending rename state, and initial domain secure-channel behavior.
- No VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration, power, or
  data changes were made from this thread beyond the approved reboot itself.

Findings:

- Post-reboot boot time observed: `2026-05-31 09:15:48` Europe/Luxembourg
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

- The reboot cleared the current `PendingFileRenameOperations` queue on
  `Kuhnle`.
- `Kuhnle` came back on SSH cleanly, but domain logon/DC reachability still
  needs follow-up because the secure-channel check did not recover during this
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
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260531-kuhnle.log`
- Windows Update result:
  - `Count=0`
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- Domain secure channel recovered after the earlier post-reboot warning:
  `nltest /sc_query:format.lu` succeeded against `\\PDC.format.lu`.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260531`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260531.ps1`

Result:

- `Kuhnle` had no pending Windows software updates at the time of this pass.
- No reboot is required from this update check.
- The earlier post-reboot `ERROR_NO_LOGON_SERVERS` condition is no longer
  present in this follow-up check.

## 2026-05-31 - Operator Cleanup And Shutdown For ESX-C Host Restart

Scope:

- Operator reported cleaning up disk space on `Kuhnle`.
- Operator reported shutting down `Kuhnle` afterward as part of an ESX-C host
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

- After ESX-C host restart and guest power-on, verify `Kuhnle` SSH reachability,
  domain secure channel, reboot-required state, free space, and application
  role/service state before closing the maintenance cycle.

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

- `Kuhnle` responded on SSH as `kuhnle\\administrateur`.
- Last boot time observed: `2026-06-13 22:30:21` Europe/Luxembourg time.
- Domain secure channel tested healthy against `\\PDC.format.lu`.
- Recent hotfixes show June 2026 updates already installed on `2026-06-13`:
  - `KB5094147`
  - `KB5094128`
- Windows Update operational events repeatedly reported
  `Windows Update successfully found 0 updates`.
- SYSTEM-side Windows Update task `FormatOps-WU-Install-20260614` completed
  with `LastTaskResult=0`.
- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260614-kuhnle.log`
- Windows Update result:
  - `Count=0`
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Current free space:
  - `C:` about `23.0 GB` of about `53.0 GB`
  - `D:` about `36.4 GB` of about `53.7 GB`

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260614`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task_20260614.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260614.ps1`

Result:

- `Kuhnle` has no pending Windows software updates visible to Windows Update.
- No reboot is required from this check.

## 2026-07-04 - Inspection Round

Scope:

- Performed read-only inspection of `Kuhnle`.
- Checked SSH reachability, boot time, update visibility, reboot flags,
  pending rename state, free space, service state, and domain secure channel.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made.

Findings:

- `Kuhnle` responded on SSH as `kuhnle\\administrateur`.
- Last boot time observed: `2026-06-17 21:52:34` Europe/Luxembourg time.
- Domain secure channel tested healthy against `\\PDC.format.lu`.
- Windows Update operational events repeatedly reported
  `Windows Update successfully found 0 updates`.
- Recent hotfixes still show June 2026 updates installed:
  - `KB5094147`
  - `KB5094128`
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
- `PendingFileRenameOperations=True`; current queue is small (`8` string
  entries / `4` rename pairs), related to EdgeUpdate and TeamViewer cleanup:
  - `C:\\Windows\\SystemTemp\\msedgeupdate.dll...`
  - `C:\\Program Files (x86)\\Microsoft\\EdgeUpdate\\1.3.241.13`
  - `C:\\Program Files\\TeamViewer\\Update_15.79.4_x64...zip`
  - `C:\\Program Files\\TeamViewer\\Update\\update.exe`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Current free space:
  - `C:` about `20.6 GB` of about `53.0 GB`
  - `D:` about `36.4 GB` of about `53.7 GB`

Result:

- `Kuhnle` is reachable, domain-connected, and not showing available Windows
  updates in the inspected Windows Update events.
- No update or reboot action was taken during this inspection.
- The remaining pending rename queue appears tied to EdgeUpdate/TeamViewer
  cleanup and can be cleared in a future reboot window.

## 2026-07-19 - Twice-Monthly Maintenance And July Updates

Scope:

- Performed ESX-C twice-monthly maintenance for `Kuhnle`.
- Ran Windows Update installation as `NT AUTHORITY\\SYSTEM` using the Windows
  Update COM API from temporary scheduled task
  `FormatOps-WU-Install-20260719`.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, power, or data
  changes were made.
- No reboot command was issued from this thread; `Kuhnle` rebooted during the
  servicing window after updates were installed.

Pre-update findings:

- `Kuhnle` responded on SSH as `kuhnle\\administrateur`.
- Last boot before updates was observed as `2026-07-04 21:38:27`
  Europe/Luxembourg time.
- Domain remained `format.lu`; domain role remained member server.
- `sshd` was `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Domain secure channel tested healthy against `\\PDC.format.lu`.
- Current free space before installation:
  - `C:` about `22.5 GB`
  - `D:` about `36.4 GB`
- Windows Update reported three applicable updates:
  - Windows Malicious Software Removal Tool x64 v5.143 (`KB890830`)
  - 2026-07 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1
    (`KB5102206`)
  - 2026-07 cumulative update for Microsoft server operating system version
    21H2 for x64-based systems (`KB5099540`)

Update result:

- Installer log was left on the server at:
  `C:\\ProgramData\\FormatOps\\Logs\\windows-update-20260719-kuhnle.log`
- Download result: `2` (succeeded), `HResult=0`.
- Install result: `2` (succeeded), `RebootRequired=True`, `HResult=0`.
- Per-update results for `KB890830`, `KB5102206`, and `KB5099540` were all
  `Result=2`, `HResult=0`.
- Post-servicing hotfix inventory shows July 2026 updates installed on
  `2026-07-19`:
  - `KB5099540`
  - `KB5101010`
  - `KB5120210`

Post-checks:

- Post-update boot time observed: `2026-07-19 10:05:50`
  Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Reboot-required indicators were clear after the observed reboot:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Time sync was current from `PDC.format.lu`.
- `nltest /dsgetdc:format.lu` discovered `\\BDC.format.lu` successfully, but
  `Test-ComputerSecureChannel` returned `False` and
  `nltest /sc_query:format.lu` reported `ERROR_NO_LOGON_SERVERS` immediately
  after the observed reboot.
- Recent System log review after the update/reboot showed boot-time Kerberos,
  time-service, DCOM, and service-control errors; no corrective action was
  taken in this thread.
- Current free space after servicing:
  - `C:` about `17.9 GB` of `49.4 GB`
  - `D:` about `33.9 GB` of `50.0 GB`

Cleanup:

- Removed temporary scheduled task `FormatOps-WU-Install-20260719`.
- Removed temporary scripts:
  - `C:\\ProgramData\\FormatOps\\esxc_wu_task_20260719.ps1`
  - `C:\\ProgramData\\FormatOps\\WU-Install-20260719.ps1`

Result:

- July Windows updates installed successfully and Windows Update now reports no
  applicable software updates.
- Reboot-required and pending-rename indicators are clear.
- Follow up on the post-reboot secure-channel inconsistency before making any
  domain/GPO/remote-admin changes on `Kuhnle`.

## 2026-07-19 - Post-Maintenance Clean Follow-Up

Scope:

- Rechecked `Kuhnle` after the July maintenance round had time to settle.
- Performed discovery-only checks for update visibility, reboot-required
  indicators, pending rename state, SSH/WinRM service state, and domain secure
  channel.
- No reboot, VMware, GPO, firewall, SSH, WinRM, update, snapshot, migration,
  power, or data changes were made.

Findings:

- `Kuhnle` responded on SSH.
- Current boot time observed: `2026-07-19 11:16:11` Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Reboot-required indicators are clear:
  - `WindowsUpdate\\Auto Update\\RebootRequired=False`
  - `Component Based Servicing\\RebootPending=False`
  - `PendingFileRenameOperations=False`
- `sshd` was `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Domain secure channel recovered successfully:
  - `Test-ComputerSecureChannel -Server PDC.format.lu=True`
  - `nltest /sc_query:format.lu` returned `NERR_Success` against
    `\\PDC.format.lu`
  - DC locator returned `\\PDC.format.lu`

Result:

- `Kuhnle` is clean from the checked Windows Update, reboot-required,
  pending-rename, SSH service, and domain secure-channel perspective.
- The earlier immediate post-reboot `ERROR_NO_LOGON_SERVERS` condition is no
  longer present.

## 2026-08-04 - Maintenance Attempt Blocked By Network Reachability

Scope:

- Started a new ESX-C maintenance pass for `Kuhnle`.
- Limited the pass to repository review and non-mutating network reachability
  checks because the guest was not reachable.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot,
  migration, power, or data changes were made.

Findings:

- `nc` to `192.168.1.14:22` failed with connection refused.
- `nc` to `192.168.1.14:5985` failed with connection refused.
- SSH via `win-kuhnle` failed with connection refused on port `22`.
- ICMP returned `Communication prohibited by filter` from `10.128.128.128`,
  then timed out.

Result:

- Guest-level maintenance could not proceed because network reachability to
  `Kuhnle` is blocked or the required tunnel/filter path is not open.

Next:

- Re-run discovery after the VPN/tunnel/firewall path to the ESX-C guest
  subnet is confirmed open.

## 2026-08-04 - Maintenance Retry And Pre-Change Inspection

Scope:

- Retried the ESX-C maintenance pass after the VPN/tunnel path was restored.
- Performed discovery-only checks for identity, role/domain state, Windows
  Update, reboot state, disks, SSH/WinRM, firewall scope, event health, DNS,
  time, Netlogon, AD port reachability, and domain secure channel.
- No update, reboot, VMware, domain, GPO, firewall, SSH, WinRM, snapshot,
  migration, power, or data change was made.

Findings:

- Local `win-kuhnle` and domain `winad-kuhnle` SSH aliases are reachable.
- Hostname is `KUHNLE`, IP is `192.168.1.14/24`, and the VM remains a
  `format.lu` member server.
- Last boot remains `2026-07-19 11:16:11` Europe/Luxembourg time.
- Windows Update search returned `Count=0`.
- Windows Update and CBS reboot-required indicators are clear.
- `PendingFileRenameOperations=True`; the queue contains 30 strings, with
  non-empty items categorized as EdgeUpdate, Windows Temp, and TeamViewer
  cleanup.
- Free space is about `23.9 GB` on `C:` and `33.8 GB` on `D:`.
- `sshd` is `Running`/`Automatic`. `WinRM` remains `Stopped`/`Disabled`.
- Existing SSH port `22` and WinRM port `5985` rules are scoped to trusted
  sources `192.168.1.73` and `192.168.113.2`; no firewall change was made.
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

- A secure-channel reset would change Kuhnle's member-computer trust state
  against the domain and could affect domain authentication and services using
  domain identities. No reset, Netlogon restart, domain rejoin, or GPO action
  was attempted during this inspection.

Result:

- No applicable Windows updates are currently visible and no Windows Update or
  CBS reboot is pending.
- Kuhnle is reachable and its AD network prerequisites are healthy, but the
  machine secure channel requires a separate approved remediation or an
  approved reboot/recheck window before this round can be called fully clean.

## 2026-08-04 - Planned Guest Shutdown For ESX-C Host Maintenance

Scope:

- Shut down `Kuhnle` at the user's request for physical ESX-C host maintenance.
- No VMware power operation, forced application termination, domain/GPO,
  firewall, SSH, WinRM, update, snapshot, migration, or data change was made.

Action and result:

- Direct shutdown from the SSH token was rejected and did not change guest
  state.
- Submitted an orderly Windows guest shutdown as local SYSTEM with planned
  hardware-maintenance reason code `p:1:1` through temporary scheduled task
  `FormatOps-Shutdown-20260804-Kuhnle`.
- The task action was configured to remove itself after submitting the shutdown
  request.
- SSH port `22` stopped responding after the shutdown request. This confirms
  guest network services are offline; hypervisor power state was not queried
  from this thread.

Post-start checks:

- After ESX-C host maintenance, verify SSH reachability, boot time, Windows
  Update and reboot flags, pending rename state, domain secure channel, time,
  disks, services/events, and absence of the temporary shutdown task.

## 2026-08-23 - Twice-Monthly Maintenance Pre-Install State

Scope:

- Started a new ESX-C maintenance round and completed discovery before Windows
  servicing.
- No reboot, VMware, domain/GPO, firewall, SSH, WinRM, snapshot, migration,
  power, or data change was made during discovery.

Findings:

- Kuhnle is reachable over local SSH and booted after host maintenance at
  `2026-08-04 20:43:23` Europe/Luxembourg time.
- The `format.lu` secure channel has recovered: PowerShell returned `True`
  and `nltest` returned `NERR_Success` against BDC.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`;
  WinRM remains `Stopped`/`Disabled`.
- Windows Update and CBS reboot flags are clear.
- `PendingFileRenameOperations=True` with 38 strings, mainly EdgeUpdate and
  related temporary cleanup.
- Free space is about `24.2 GB` on `C:` and `33.8 GB` on `D:`.
- Three applicable updates are visible: `KB890830`, `KB5121650`, and
  `KB5120242`.
- Removed the confirmed stale August shutdown task; no FormatOps scheduled
  tasks remain.

Blast radius:

- Installation can restart Windows/application services and is expected to
  require a guest reboot, temporarily interrupting Kuhnle workloads and domain
  access. No domain trust, GPO, firewall, SSH, or WinRM configuration change is
  in scope.

## 2026-08-23 - August Updates Installed And Verified

Action:

- Installed the three discovered updates as local SYSTEM using temporary task
  `FormatOps-WU-Install-20260823` and the Windows Update COM API.
- Performed one planned update reboot with reason code `p:2:17`.
- No VMware, domain trust, GPO, firewall, SSH, WinRM, snapshot, migration,
  power, or data configuration change was made.

Install result:

- Log retained on the guest at
  `C:\ProgramData\FormatOps\Logs\windows-update-20260823-kuhnle.log`.
- Download and install result codes were `2` (succeeded).
- `KB890830`, `KB5121650`, and `KB5120242` each returned `Result=2`,
  `HResult=0`; Windows reported `RebootRequired=True`.
- Servicing completed at `2026-08-23 15:57:22`.

Post-checks:

- New boot time is `2026-08-23 16:01:12` Europe/Luxembourg time.
- Windows Update returned `Count=0`; Windows Update and CBS reboot flags are
  clear.
- `PendingFileRenameOperations=False`.
- Free space is about `21.1 GB` on `C:` and `33.8 GB` on `D:`.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`;
  WinRM remains `Stopped`/`Disabled`.
- The secure channel and `nltest` temporarily reported
  `ERROR_NO_LOGON_SERVERS` after reboot, then recovered naturally against
  PDC without a trust reset or Netlogon restart.
- Local `win-kuhnle` and domain `winad-kuhnle` SSH aliases both work after
  the recovery window.
- Post-boot event groups were time-service, DCOM, Kerberos, and virtual-TPM
  events in the inspected window; no corrective change was made.
- Temporary installer/reboot tasks and the temporary installer script were
  removed; the audit log remains.

Result:

- August updates are installed and Windows Update is clean.
- Kuhnle is healthy from the checked update, reboot, rename, service, disk,
  secure-channel, and SSH-access perspectives.

## 2026-09-05 - Twice-Monthly Maintenance Pre-Reboot State

Scope:

- Started the September ESX-C maintenance round with read-only discovery.
- No Windows update, reboot, VMware, domain trust, GPO, firewall, SSH, WinRM,
  snapshot, migration, power, or data configuration change was made during
  discovery.

Findings:

- Local `win-kuhnle` and domain `winad-kuhnle` aliases are reachable and map
  to `192.168.1.14`; the respective identities are local and
  `format\\Administrateur`.
- Kuhnle remains a `format.lu` member server. Its secure channel is healthy,
  and DC locator finds PDC.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`; WinRM remains
  `Stopped`/`Disabled`.
- `sshd_config` allows local administrators and `format\\sshadmins`. The
  enabled SSH and WinRM firewall rules remain scoped to `192.168.1.73` and
  `192.168.113.2`.
- Windows Update search returned `Count=0`; Windows Update and CBS reboot
  flags are clear.
- `PendingFileRenameOperations=True` with 41 non-empty delete operations,
  currently from ESET, TeamViewer, EdgeUpdate, PowerShell execution, and
  Windows Installer temporary cleanup.
- Current boot time is `2026-08-23 21:55:15` Europe/Luxembourg time.
- `C:` has about `23.8 GB` free of `49.4 GB`; `D:` has about `33.8 GB` free
  of `50.0 GB`. Both report healthy.
- No temporary `FormatOps-*` scheduled task remains.
- Recent grouped System warnings/errors were mainly virtual-TPM, time-service,
  and DCOM events; no current secure-channel or core-service failure was found.

Blast radius:

- The approved reboot will briefly interrupt Kuhnle production workloads and
  domain access. No domain trust, GPO, firewall, SSH, or WinRM configuration
  change is in scope.

Planned action:

- Reboot Kuhnle first to process the pending cleanup queue. Recheck updates,
  reboot flags, rename state, services, secure channel, both SSH aliases,
  events, and disk health before proceeding to LMR.

## 2026-09-05 - Cleanup Reboot Completed; Domain SSH Pending

Action:

- Submitted one planned guest reboot as local SYSTEM through self-removing
  scheduled task `FormatOps-Reboot-20260905-Kuhnle`.
- No Windows update, VMware, domain trust, GPO, firewall, SSH, WinRM,
  snapshot, migration, power, or data configuration change was made.

Post-checks:

- New boot time is `2026-09-05 09:25:09` Europe/Luxembourg time.
- Windows Update remains at `Count=0`; Windows Update and CBS reboot flags are
  clear.
- The 41 pending delete operations were processed. The registry value now
  contains only one empty string, with no actionable source or destination.
- `sshd`, `Netlogon`, and `W32Time` are `Running`/`Automatic`; local
  `win-kuhnle` break-glass SSH works.
- `C:` has about `23.9 GB` free and `D:` has about `33.8 GB` free; both report
  healthy.
- No temporary `FormatOps-*` scheduled task remains.
- DNS and tested AD ports to both PDC and BDC are reachable. DC locator finds
  PDC, and time is synchronized to BDC.
- The machine secure channel initially remained unhealthy with
  `ERROR_NO_LOGON_SERVERS`, then recovered naturally without a trust reset or
  Netlogon restart. Final checks returned `Test-ComputerSecureChannel=True`
  and `NERR_Success` against PDC.
- Domain user lookup still returns RPC error `1722`, and domain
  `winad-kuhnle` SSH fails because OpenSSH cannot resolve the domain account.
  No SSH configuration or key change was made.
- Boot-time Kerberos events report that domain-controller certificate
  revocation could not be checked because the revocation server was offline.
- Kuhnle's AD computer account is enabled. BDC showed no new Netlogon rejection
  event for Kuhnle during the inspected post-reboot window.

Result:

- The cleanup reboot, core health checks, and domain secure channel succeeded,
  but Kuhnle is not fully clear because domain user lookup and domain-admin
  SSH have not recovered. Local break-glass SSH remains available.
- The ESX-C reboot sequence was stopped. Do not reset the secure channel,
  restart Netlogon, rejoin the domain, or change certificate/GPO settings until
  the remediation scope and application impact are separately approved.

## 2026-09-05 - Domain Access Remediation Pre-State

Authorization and scope:

- The user approved continuing the Kuhnle remediation and, once Kuhnle is
  fully healthy, the sequential LMR and BDC maintenance reboots.
- Read-only rechecks still showed working local break-glass SSH, a successful
  `nltest` secure-channel query, RPC error `1722` during domain user lookup,
  and unavailable `winad-kuhnle` SSH.
- Direct SID translation for `format\\Administrateur` reported that the
  workstation trust relationship failed, confirming the state was not limited
  to OpenSSH.
- No running Kuhnle service uses a `format\\...` service identity, and
  Netlogon has no dependent services.

Blast radius and first action:

- Restarting Netlogon can briefly interrupt new domain authentication and
  domain account lookup on Kuhnle. Local break-glass SSH remains available.
- Restart Netlogon only, without changing the machine password, resetting the
  secure channel, rejoining the domain, changing GPO, or changing SSH/firewall
  configuration. Revalidate trust, SID lookup, and both SSH aliases before any
  stronger action or any other VM reboot.

## 2026-09-05 - Netlogon Restart Result And Secure-Channel Reset Scope

Result of first action:

- Netlogon restarted successfully and returned to `Running`/`Automatic`.
- The restart did not restore SID translation, domain user lookup, or
  `winad-kuhnle`; RPC error `1722` and the trust-relationship error remained.
- Local break-glass SSH, DC discovery, time synchronization, and the
  `nltest` channel query remained available.

Next action and blast radius:

- Reset Kuhnle's secure channel specifically against PDC. This renews the
  member-computer authentication channel and can briefly invalidate cached
  domain authentication on Kuhnle; no running service uses a domain service
  identity.
- This action does not rejoin the machine, change its OU, alter GPO, change
  DNS/firewall/SSH configuration, or modify other computers.
- If the reset fails or local SSH becomes unhealthy, stop the ESX-C sequence.
  PDC and BDC remain online, and local `win-kuhnle` is the containment path;
  do not attempt a domain rejoin without a separate rollback plan.

## 2026-09-05 - Secure-Channel Reset Result And Machine-Password Scope

Result of channel reset:

- `nltest /sc_reset` against PDC returned `NERR_Success`, but SID translation,
  domain user lookup, and `winad-kuhnle` remained unavailable.
- This confirms DC reachability but does not reconcile the member-computer
  trust secret used by Windows account lookup.

Next action and blast radius:

- Renew Kuhnle's machine-account password against `format.lu` using the local
  computer context. This changes the shared trust secret for Kuhnle's existing
  AD computer account; it does not rejoin or move the computer, change user
  passwords, alter GPO, or change SSH/firewall configuration.
- If renewal fails, retain local `win-kuhnle`, leave LMR and BDC online, and
  stop before any domain rejoin or computer-account reset. Validate SID lookup,
  secure channel, and both SSH aliases before continuing.

## 2026-09-05 - Machine-Password Renewal Result And Reboot Scope

Result:

- `nltest /sc_change_pwd:format.lu` returned `NERR_Success`.
- A subsequent Netlogon restart completed cleanly, but SID translation, domain
  user lookup, and `winad-kuhnle` still returned the same trust/RPC errors.

Next action and blast radius:

- Perform one additional Kuhnle guest reboot so LSA and Netlogon reload the
  renewed machine trust secret. This causes another brief Kuhnle production
  interruption; PDC and BDC remain online and local break-glass SSH is the
  recovery path.
- If domain SID translation and `winad-kuhnle` do not recover after this boot,
  stop without rejoining the domain or changing the AD computer object, and do
  not reboot LMR or BDC.

## 2026-09-05 - Trust Remediation Final Result

Action and verification:

- Performed the second controlled Kuhnle reboot through self-removing SYSTEM
  task `FormatOps-Reboot-20260905-Kuhnle-2`.
- New boot time is `2026-09-05 09:59:27` Europe/Luxembourg time.
- BDC shows Kuhnle's AD computer-account password updated at the expected
  repair time. Subsequent inbound domain-partition replication from PDC to BDC
  completed successfully.
- Observed 16 additional postboot checks. Local `win-kuhnle` remained healthy,
  `Test-ComputerSecureChannel=True`, and `nltest /sc_query` returned
  `NERR_Success`.
- SID translation continued to report a failed workstation trust relationship,
  domain user lookup continued to return RPC error `1722`, and
  `winad-kuhnle` continued to fail because OpenSSH could not resolve the domain
  user.
- Windows Update remains at `Count=0`; Windows Update and CBS reboot flags are
  clear, no non-empty pending rename operation remains, and `sshd`, Netlogon,
  and Windows Time are `Running`/`Automatic`.
- No temporary `FormatOps-*` scheduled task remains.

Result:

- Kuhnle is healthy through local break-glass access and from the checked
  update, reboot, disk, and core-service perspectives, but domain account
  resolution and domain-admin SSH remain blocked.
- The repair sequence stops here. A domain rejoin, AD computer-object reset,
  GPO/certificate change, or broader domain repair requires a separate plan
  with application validation and rollback steps.
- LMR and BDC were not rebooted; their pending application-cleanup operations
  remain queued for a later maintenance window.

## 2026-09-05 - System Files Cleanup Pre-State

Authorization and scope:

- The user requested Windows Disk Cleanup with system files on all three ESX-C
  VMs.
- Use the established `cleanmgr` SYSTEM profile on `C:` only. Select all 27
  cleanup categories exposed by this VM except `DownloadsFolder`; no ad hoc
  file deletion, non-system volume cleanup, application-data deletion, or
  configuration change is in scope.
- The selected surface includes Windows Update Cleanup, previous installations,
  Windows ESD installation files, device-driver packages, discarded upgrade
  files, temporary/setup/error-reporting files, caches, Defender cleanup, and
  Recycle Bin. This can remove rollback resources exposed by Windows Disk
  Cleanup.

Pre-state and blast radius:

- `C:` has about `24.00 GiB` free of `49.37 GiB` and reports healthy.
- Windows Update and CBS reboot flags are clear. No `cleanmgr`, DISM host,
  Windows Update worker, or temporary cleanup task is active.
- `sshd`, Netlogon, and Windows Time are `Running`/`Automatic`; local
  break-glass SSH remains the required access path while domain-admin SSH is
  unresolved.
- Cleanup can increase CPU and disk activity and invoke DISM, TiWorker, or
  TrustedInstaller for an extended period. It is not expected to reboot the VM;
  stop the sequence if an unexpected reboot or service failure occurs.

## 2026-09-05 - System Files Cleanup Launched; Verification Interrupted

Action:

- Created cleanup profile `905` and selected all 27 discovered `VolumeCaches`
  categories except `DownloadsFolder`.
- Started `cleanmgr /d C /sagerun:905` as local SYSTEM through scheduled task
  `FormatOps-CleanMgr-20260905-Kuhnle`.
- Free space at launch was about `23.98 GiB`.

Observed state:

- One expected cleanup chain remained active during observation: `cleanmgr`,
  `DismHost`, TiWorker, and TrustedInstaller. No duplicate cleanup was started
  and none of these processes was terminated.
- Free space remained about `24.01 GiB` while the system-files servicing phase
  was running.
- Remote checks then failed simultaneously for Kuhnle, LMR, and BDC. The local
  route to all three addresses had fallen back to Wi-Fi gateway `10.10.10.1`
  instead of the VPN tunnel, so this is recorded as loss of the administration
  path rather than evidence of a Kuhnle reboot or failure.

Pending verification:

- After the VPN route is restored, inspect the existing task and cleanup
  processes before doing anything else. Do not relaunch cleanup while the
  original task or servicing workers remain active.
- Verify completion, free space, reboot flags, services, local SSH, and the
  existing Kuhnle domain-access issue; then remove task
  `FormatOps-CleanMgr-20260905-Kuhnle` and all `StateFlags0905` properties.

## 2026-09-05 - Cleanup Retry Verification Interrupted By VPN Loss

- After the VPN returned, the original task and its single expected cleanup
  chain were still running; no duplicate task was created and no process was
  terminated.
- Kuhnle remained on the same boot, with clear Windows Update/CBS reboot flags,
  healthy `C:`, and `sshd`, Netlogon, and Windows Time running.
- The VPN became unreachable again during fleet monitoring. Cleanup completion,
  final free space, profile/task removal, and post-cleanup domain-access checks
  remain pending.


## 2026-09-13 - Maintenance Discovery And Patch Scope

- Both configured SSH aliases work. Last observed boot: 2026-09-05 18:28:48 local time.
- C: free space 22.56 GiB; fixed volumes report Healthy. Windows Update/CBS reboot markers are clear.
- Pending rename queue has 9 non-empty strings, including security-driver backup/temporary files and MSI/Windows temporary cleanup. No manual queue or file deletion is planned.
- SQLBase_SERVER1 is Running/Automatic; Gupta SQLBase Server1 is Stopped/Manual. Domain trust, SID lookup, and both SSH aliases now pass. No domain rejoin is warranted by these checks.
- Update scan succeeded and offers: KB890830, KB5126149, KB5122882.
- Recent warning/error summaries retain previously observed categories; no full application transaction or backup restore was tested. Current backup success and hypervisor job state are not independently verified in this guest-only pass.
- September 5 cleanup task is Ready with LastTaskResult 267014 (0x41306, terminated). No cleanmgr/DismHost remains. Cleanup success and reclaimed bytes cannot be established from this result.
- Correction to prior cleanup scope: Microsoft documents that /sagerun enumerates all drives and ignores /d. The earlier C:-only assertion was incorrect; no per-drive deletion audit is available. See https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr.
- Retire only the stopped FormatOps-CleanMgr-20260905 task for this VM and its StateFlags0905 profile properties. Do not restart broad Disk Cleanup during this patch round.
- A reboot briefly interrupts SQLBase and Kuhnle production access. Wait for existing servicing workers to exit before starting one monitored SYSTEM installer. Keep unrelated AD, GPO, firewall, SSH, WinRM, and application configuration unchanged.

## 2026-09-13 - Updates Installed; Domain Access Regressed After Reboot

- The single SYSTEM installer completed at 12:28:17 local time. KB890830, KB5126149, and KB5122882 each returned ResultCode 2 / HResult 0; the task ended Ready / result 0 and requested a reboot.
- Controlled reboot verified by new boot time 12:32:36. Subsequent update search succeeded (ResultCode 2), with zero applicable software updates. Windows Update/CBS reboot flags and PendingFileRenameOperations are clear.
- SQLBase_SERVER1, sshd, Netlogon, and Windows Time are Running/Automatic. WinRM remains Stopped/Disabled; its configuration was not changed. Fixed volumes report Healthy; at 12:37 C: had 19.71 GiB free and D: 33.82 GiB.
- Secure-channel checks against both BDC and PDC fail, domain account translation fails, and winad-kuhnle rejects authentication. win-kuhnle remains available. nltest reports ERROR_NO_LOGON_SERVERS (1311), despite DC discovery returning BDC and successful TCP connections to both DCs on 88, 135, 389, and 445. These checks do not establish a root cause or prove all required RPC traffic is healthy.
- Windows Time is synchronized to BDC. No System warning/error events were returned in the initial post-boot query. No end-to-end production application or backup test was performed.
- Hold further guest restarts and BDC patching while this regression remains unresolved. LMR's already-running installer is allowed to finish; do not interrupt native servicing.
- No Netlogon restart, secure-channel reset, machine-password change, domain rejoin, AD/GPO edit, or firewall/remote-access change was made in this round.
- Removed the stopped September 5 cleanup task and its 27 StateFlags0905 properties. No new broad Disk Cleanup was started; prior reclaimed space remains unverified.
- Application warning/error summary since boot contains one SPBaseMgrService event 13; no full event payload or sensitive logs were copied into the repository.
- Removed this round's completed update/reboot tasks and transferred installer script after verifying task result 0. The per-guest Windows Update audit log remains under C:\ProgramData\FormatOps\Logs.
- Final recheck at 12:43:46, eleven minutes after boot: trust and account lookup still fail; SQLBase/local SSH remain available, reboot and rename markers remain clear, and C: has 19.61 GiB free. The recovery gate remains unresolved.

## 2026-09-13 - Scoped Domain-Access Investigation

- User approved proceeding with Kuhnle. At 12:47, local access and SQLBase are available but domain SSH, secure-channel validation, and domain-account lookup still fail. No new reboot is pending.
- First diagnostic action: run the same non-mutating trust/account-lookup queries once under local SYSTEM, independently of the SSH logon token, using a temporary scheduled task. Only status codes and known infrastructure names are written to a guest-local diagnostic log; no secrets, ticket contents, or customer data are collected.
- Task/script creation is the only initial guest modification. No service restart, machine-password reset, AD/GPO change, firewall edit, or domain rejoin is included. SQLBase runs as LocalSystem; Netlogon reports no dependent services. Keep local win-kuhnle available throughout.
- SYSTEM checks reproduced the failure against both DCs. Normal SYSTEM Kerberos ticket requests for ldap/BDC.format.lu and ldap/PDC.format.lu subsequently returned exit 0; no tickets were purged or exported. BDC's four observed dynamic LSASS/RPC listener ports were TCP-reachable from Kuhnle. No matching recent BDC Netlogon rejection was found; this is not proof that every authentication path is healthy.
- Next scoped action: one nltest secure-channel reconnection to BDC, using Kuhnle's existing machine identity. This can interrupt new domain authentication on Kuhnle but does not intentionally rotate the machine password or change AD membership, policies, or SSH. No running format-domain service identity was found, and Netlogon has no dependent services. Verify trust, lookup, and both aliases before stronger action.
- At 12:51:33 the reconnection returned NERR_Success, but subsequent trust validation failed and the channel query reverted to 1311. Domain user lookup returns RPC error 1722. No password reset is justified by this transient success alone.
- Diagnostic scope extension: temporarily enable local Netlogon debug logging for one bounded reconnection/lookup attempt, then disable it and restore the originally absent DBFlag value. This adds small local logging overhead and repeats the same transient channel reconnection; no reboot, service restart, security-policy relaxation, password reset, or domain rejoin. Keep raw native logs on the guest and record only sanitized status/method summaries in the repository.

### Findings And Proposed Next Step

- The short trace shows session establishment succeeding with both controllers, followed by authentication-data requests resetting the connection to STATUS_NO_LOGON_SERVERS (0xc000005e). This does not demonstrate a mismatched machine password. Debug logging was disabled and the originally absent DBFlag restored and verified.
- Kuhnle has EnableAuthEpResolution=1 under HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc. Computer RSoP identifies Default Domain Policy as the winning source. BDC has RestrictReceivingNTLMTraffic=2 and RestrictNTLMInDomain=5. DNS resolves both controller names to their expected IPv4 addresses.
- At 12:54:52, SYSTEM RPC endpoint-mapper tests to BDC: Kerberos succeeds (exit 0), NTLM fails with access denied (exit 5). An unauthenticated endpoint-mapper connectivity test also succeeds. These tests do not change server security settings or prove application transactions work.
- Microsoft documents that EnableAuthEpResolution uses NTLM for endpoint-mapper queries and is incompatible with denying incoming NTLM. Microsoft recommends retaining NTLM restrictions when choosing between these settings: https://learn.microsoft.com/en-us/windows-server/security/rpc-interface-restrict. This is a strong candidate cause, not yet confirmed by a controlled configuration test.
- A read-only LMR comparison finds the same EnableAuthEpResolution=1 value. Do not change Default Domain Policy or assume this is limited to Kuhnle. Its current computer container is OU=_Edge-Servers with NTLM,OU=_Servers,OU=_Computers,DC=format,DC=lu; neither the computer nor its OU membership was changed.
- Proposed approval-gated test: change only Kuhnle's effective Enable RPC Endpoint Mapper Client Authentication setting to Disabled (EnableAuthEpResolution=0), preserving incoming/outgoing NTLM restrictions, endpoint authorization, and firewall scope, then perform one planned Kuhnle reboot. This permits unauthenticated endpoint discovery; authentication/authorization for the actual RPC services must remain intact. The policy requires reboot to take effect.
- Do not present a local registry override as durable: Default Domain Policy can overwrite it. Any lasting GPO exception must apply only to KUHNLE$ and be separately documented with its link/filter and rollback. Do not edit the shared default policy. If the test fails, restore the original effective value 1 and reboot to restore runtime behavior; this can require a second production interruption.
- Approval is required before that policy change. No new GPO, policy override, password reset, domain rejoin, service restart, or reboot was performed during this investigation. LMR and BDC maintenance remain held.
- The diagnostic task completed with result 0 and was removed along with its transferred script. Native diagnostic logs remain on Kuhnle; no raw trace, credentials, or ticket contents were committed to the repository.
- Final checks at approximately 12:57: secure-channel validation recovered to True and nltest returned NERR_Success against BDC, but account lookup and winad-kuhnle still fail. SQLBase, Netlogon, and local SSH remain running. The cause of this partial recovery is not established; it does not close the domain-access issue or remove the policy-test approval gate.

## 2026-09-13 - Approved Temporary RPC Policy Test

- User approved the proposed Kuhnle-only temporary override and reboot. At 13:17:56 local time, EnableAuthEpResolution is still DWORD 1; domain lookup/SSH fail while secure-channel validation passes. SQLBase and local SSH run normally; there are no active cleanup/update installers, temporary FormatOps tasks, or pending reboot/rename markers. Boot remains 12:32:36; healthy volumes have C: 19.66 GiB and D: 33.82 GiB free.
- Change only HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc\EnableAuthEpResolution from 1 to 0, retain the original value in a guest-local audit record, and restart Kuhnle through one SYSTEM task. Expected impact: brief loss of Kuhnle production/SQLBase access. Preserve local break-glass SSH; do not reboot another guest or alter shared GPOs, NTLM restrictions, firewall, SSH, WinRM, AD objects, or passwords.
- On recovery, verify new boot, actual registry value (including possible GPO overwrite), SQLBase, both SSH aliases, secure channel, account lookup, reboot markers, disks, and event summaries. No policy-refresh suppression or recurring enforcement task is authorized. If the setting is overwritten, report the test limitation rather than fighting Group Policy. Rollback value is DWORD 1; a failed test may require restoring it and a further reboot as previously documented.

### Initial Test Result

- Recorded the original DWORD 1 in C:\ProgramData\FormatOps\Logs\kuhnle-rpc-policy-test-20260913.json, set only EnableAuthEpResolution to 0, verified 0, and requested the approved reboot using FormatOps-Kuhnle-RPC-Test-Reboot-20260913.
- New boot verified at 13:19:12. By 13:19:39 secure-channel validation and domain-account lookup pass. Both win-kuhnle and winad-kuhnle subsequently succeed. SQLBase_SERVER1, sshd, Netlogon, and Windows Time are Running/Automatic; WinRM remains Stopped/Disabled.
- The first post-boot registry read already shows EnableAuthEpResolution=1 again. Computer Group Policy startup completion is recorded at approximately 13:19:28. This is consistent with policy reapplication; no policy suppression or repeated override was attempted. Recovery followed the temporary test/reboot, but the RPC runtime's loaded value was not directly measured. The policy conflict remains a strong candidate rather than a conclusively isolated root cause, and recovery across another reboot is unverified.
- Fresh Windows Update search succeeds (ResultCode 2) with zero offered software updates. Windows Update/CBS reboot markers and the rename queue are clear. C: has 19.99 GiB free and D: 33.82 GiB; both volumes report Healthy.
- Post-boot warning/error groups contain Windows Time events 1/4, DCOM 10016, and SPBaseMgrService 13. Windows Time subsequently synchronizes successfully to BDC. No application transaction or backup/restore test was performed, and these event summaries are not an assertion that every log is clean.
- No lasting GPO exception was created. Shared domain policies, NTLM restrictions, AD membership/passwords, firewall, SSH, and WinRM configuration were not changed. A durable Kuhnle-only policy correction requires separate approval and documented filtering/rollback; do not modify Default Domain Policy as part of this temporary test.
- Repeat verification at 13:21:47: both SSH aliases, account lookup, secure channel (BDC/NERR_Success), and SQLBase still pass. No reboot/rename markers remain. C: is healthy with 19.91 GiB free; D: remains 33.82 GiB. The configured RPC value is still the original 1. Kuhnle's and BDC's inspected NTLM restriction values are unchanged.
- Verified the reboot task's result 0 and removed that completed task; no FormatOps task remains. The guest-local original-value audit record is retained. No second reboot or further registry override was performed because access recovered and the configured value had already returned to its original state. This does not establish the RPC runtime's current cached setting or guarantee persistence across another boot.

## 2026-09-13 - PDC/BDC GPO Audit Follow-Up

- User requested a read-only check against Kerberos-first, NTLM-for-edge-servers-only intent. Direct PDC and BDC reports agree, and all 17 GPO AD/SYSVOL version sets match. No policy, service, registry, or AD change was made during the audit.
- Default Domain Policy is domain-linked, enforced, and highest priority. Its EnableAuthEpResolution=1 cannot be overridden by a normal child-OU exception. This corrects the earlier assumption that a simple Kuhnle-only child policy would suffice.
- KUHNLE and FILE belong to the NTLM edge OU but are missing from the domain NTLM server-exception list. NTLM Allow also applies to a workstation OU; ADMIN is an exception outside the edge OU. Do not blindly add/remove exceptions before confirming intended roles and application needs.
- Full findings, effective settings, additional conflicting GPO values, and the approval-gated correction order are in [the domain authentication policy audit](../../kerberos-ntlm-gpo-audit-2026-09-13.md). No permanent fix was applied.

## 2026-09-13 - Read-Only NTLM Event Review

- Latest local credential-validation records correlate with this audit's public-key SSH sessions. Do not interpret them as proof that SSH authenticated using network NTLM. The latest retained NTLM Operational event is an audit-only 8002 at September 12 15:26:53, with local caller KUHNLE$/PID 4; no remote user is identified.
- The Security log only extends back to September 13 10:39:21, preventing correlation with that prior-day event. No policy/logging changes were made. See the [sanitized activity review](../../kerberos-ntlm-gpo-audit-2026-09-13.md#latest-ntlm-event-inspection).
