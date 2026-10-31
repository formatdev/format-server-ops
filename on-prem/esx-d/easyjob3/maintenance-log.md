# EASYJOB3 Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-easyjob3` and `winad-easyjob3` both returned `Easyjob3`.
- Secure channel checked: healthy; domain `format.lu`.
- OS checked: Microsoft Windows Server 2025 Standard `10.0.26100`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM TCP checked: `192.168.1.13:5985` reachable after restore.
- Print service checked: `Spooler` running.
- Disk space checked: C: 17.6 GB free of 148.6 GB.
- Pending reboot checked: `PendingFileRenameOperations` present.
- Recent updates checked: latest installed hotfixes included `KB5078739` and `KB5078740` on 2026-03-16.
- File cleanup performed: deleted 2 files older than 30 days from `C:\Windows\Temp`, about 0.2 MB. Post-cleanup `C:\Windows\Temp` measured about 1.4 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No application data, user data, GPO, firewall rule, or snapshot/reboot action was changed.

Follow-up:

- Investigate low-ish C: free space and pending reboot before any update install.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on EASYJOB3 using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 5 visible updates successfully: Windows Security platform KB5007651, SQL Server 2019 RTM CU security update KB5084816, Windows Malicious Software Removal Tool KB890830, .NET Framework security update KB5082417, and Windows security update KB5082063.
- Task log: `C:\ProgramData\Codex\windows-update-Easyjob3-20260418-220756.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 15.9 GB.
- Post-install visible update scan still listed KB5082417 and KB5082063 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending, Windows Update reboot required, and `PendingFileRenameOperations`.
- Reboot performed: No.

Notes:

- SQL Server update progress was also confirmed through `MsiInstaller` and Windows Update Client events.
- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No application data, user data, GPO, firewall rule, snapshot, or reboot action was changed.

Follow-up:

- Reboot EASYJOB3 in an agreed window, then re-run Windows Update scan and application smoke checks.
- C: free space remains low-ish after update staging; revisit cleanup after reboot finalizes component servicing.

## 2026-05-03 - Bi-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-easyjob3` and `winad-easyjob3` both connected; `winad-easyjob3 whoami` returned `format\administrateur`.
- Secure channel checked: broken; `Test-ComputerSecureChannel -Verbose` returned `False`.
- Secure-channel repair attempt checked: `Test-ComputerSecureChannel -Repair -Verbose` from the domain-admin SSH path failed with `The user name or password is incorrect`; `nltest /sc_query:format.lu` returned `ERROR_NO_LOGON_SERVERS`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled` again, restored to `Running`/`Automatic`.
- WinRM TCP checked after restore: `192.168.1.13:5985` reachable from the maintainer Mac.
- Print service checked: `Spooler` running.
- Disk space checked: C: about 18.3 GB free.
- Pending reboot checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Visible Windows updates checked: `0`.
- Recent hotfixes checked: `KB5082062`, `KB5082063`, `KB5082417`.
- File cleanup performed: no files older than 30 days remained in `C:\Windows\Temp`; remaining temp content about 1.0 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- April update state appears finalized because visible updates and reboot flags are clear, but the machine trust is broken again.
- WinRM drift also recurred on this host.

Follow-up:

- Run a credentialed secure-channel repair for EASYJOB3 from an interactive session or with an approved credential path.
- Investigate why both machine trust and WinRM startup drift recurred after the April maintenance.

## 2026-05-16 - Twice-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `winad-easyjob3` connected and returned `easyjob3\administrateur`.
- Secure channel checked: `Test-ComputerSecureChannel -Verbose` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: had drifted to `Stopped`/`Disabled`; restored to `Running`/`Automatic`; TCP `5985` is reachable again from the maintainer Mac.
- Application role checked: `Spooler` `Running`/`Automatic`.
- Print service checked: `Spooler` `Running`.
- Disk space checked: C: about 14.7 GB free before update install.
- Event logs reviewed: Windows Update client and servicing process state checked during the long-running install.
- Updates installed: In progress. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` was started and logged 4 queued updates: SQL Server 2019 security update `KB5090407`, MRT `KB890830`, Windows security update `KB5087539`, and .NET security update `KB5087051`.
- Reboot required: pending final install result; not yet verified because the task was still running at the last check.
- Notes: `Easyjob3` is the only May 16 Windows host still actively servicing updates at the end of this pass; `TiWorker` and `TrustedInstaller` were still active, which is consistent with the SQL-inclusive update set still processing.
- Follow-up: re-check the task log `C:\ProgramData\Codex\windows-update-EASYJOB3-20260516-090235.log`, remove the one-off task after completion, and then schedule the reboot once the install result is logged.

## 2026-05-31 - End-Of-Month Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `winad-easyjob3` connected and returned `FORMAT\Administrateur`.
- Secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_verify:format.lu` returned `NERR_Success` against `\\BDC.format.lu`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: had drifted again to `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Application role checked: `Spooler` remained `Running`/`Automatic`.
- Print service checked: `Spooler` `Running`.
- Disk space checked: not deeply re-measured in this pass.
- Event logs reviewed: no deep event-log pass in this sweep; Windows Update task log under `C:\ProgramData\Codex` was checked.
- Updates installed: No. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` ran successfully and logged `VisibleCount=0`.
- Reboot required: No reboot flag was present in this pass.
- Notes: Remote COM-based Windows Update queries still fail from the SSH admin context with `0x80240032`, but the SYSTEM-context update script completed normally and found no visible updates.
- Follow-up: keep watching for both recurring `WinRM` startup drift and the historically noisy secure-channel state on EASYJOB3.

## 2026-05-31 - Post-Update/Reboot Validation

Maintainer: Codex with Peter

Checks:

- Peter completed manual Windows Update, cleanup, guest reboot, and ESX-D host reboot.
- Post-host-reboot network checked: `192.168.1.13` responded to ping.
- Post-host-reboot SSH checked: `win-easyjob3` returned `Easyjob3`; `winad-easyjob3` reached the host but returned SSH permission denied for the domain-admin alias.
- Secure channel checked from the local SSH context: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `False`, while `nltest /sc_query:format.lu` returned `NERR_Success` against `\\BDC.format.lu`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: `Running`/`Automatic`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Latest hotfix checked: `KB5087539`, installed `2026-05-17`.

Notes:

- Easyjob3 is reachable and booted after the host reboot.
- Domain SSH and PowerShell secure-channel checks remain noisy and should be treated as follow-up unless application symptoms appear.

## 2026-05-31 - Domain SSH Follow-Up

Maintainer: Codex with Peter

Checks and actions:

- Compared domain SSH behavior against Admin and FILE.
- `sshd_config` includes `AllowGroups administrators format\sshadmins` and uses `__PROGRAMDATA__/ssh/administrators_authorized_keys` for `Match Group administrators`.
- AD group `SSH Admins` exists with SamAccountName `sshadmins`, and `FORMAT\Administrateur` is a member.
- `winad-easyjob3` continued to return SSH permission denied for `format\Administrateur`.
- OpenSSH logs showed `Invalid user format\Administrateur`.
- `nltest /sc_reset:format.lu\\PDC.format.lu` and `nltest /sc_verify:format.lu` completed successfully, but local SID translation for `format\Administrateur` and `format\sshadmins` still returned trust-relationship failures.
- `Restart-Service Netlogon -Force` did not clear the split; `Test-ComputerSecureChannel -Server PDC.format.lu` still returned `False` while `nltest /sc_verify` returned `NERR_Success`.

Notes:

- EASYJOB3 local SSH remains usable.
- Domain SSH requires a credentialed machine-password repair from an interactive/domain-admin context.

## 2026-05-31 - Domain SSH Restored

Maintainer: Codex with Peter

Actions:

- Peter ran the credentialed machine-password repair interactively on EASYJOB3:
  - `Reset-ComputerMachinePassword -Server PDC.format.lu -Credential format\Administrateur`
  - `Restart-Service Netlogon -Force`
  - `Test-ComputerSecureChannel -Server PDC.format.lu -Verbose`
  - `nltest /sc_query:format.lu`
- The explicit PDC-targeted secure-channel check returned `True`.
- `nltest /sc_query:format.lu` still returned `1311`, matching the known generic-query split.
- Codex retested `winad-easyjob3`; domain SSH returned `Easyjob3`.
- OpenSSH logs confirmed `Accepted publickey for format\Administrateur`.

Notes:

- EASYJOB3 domain SSH is restored.
- Local-admin PowerShell trust checks can still report misleading split results after the repair; the practical domain SSH access path is healthy.

## 2026-06-14 - Twice-Monthly Maintenance Discovery

Maintainer: Codex with Peter

Checks and actions:

- `winad-easyjob3` checked: domain SSH failed with permission denied for `format\Administrateur`.
- `win-easyjob3` break-glass SSH checked: returned `Easyjob3` and `easyjob3\administrateur`.
- Secure channel initially checked from local SSH context: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `False`; `nltest /sc_query:format.lu` returned `1311`.
- Low-impact reset attempted:
  - `nltest /sc_reset:format.lu\\PDC.format.lu`
  - `Restart-Service Netlogon -Force`
- Post-reset secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success`.
- Domain SSH retest still failed with permission denied.
- Local SID translation for `format\Administrateur` and `format\sshadmins` still returned trust-relationship failures.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: `KB5094137` and `KB5094125` installed on `2026-06-13`.
- Visible Windows updates checked: `0`.
- SQL check from local admin context failed because SQL rejected `EASYJOB3\Administrateur`; domain SQL check is blocked until domain SSH/domain auth is repaired.

Notes:

- EASYJOB3 is reachable by local break-glass SSH and appears patched/reboot-clean.
- Domain SSH and domain-auth SQL checks require another credentialed machine-password repair from an interactive/domain-admin context.

## 2026-06-14 - Domain SSH And SQL Auth Restored

Maintainer: Codex with Peter

Actions:

- Peter ran the credentialed machine-password repair interactively on EASYJOB3.
- Codex retested `winad-easyjob3`; domain SSH returned `Easyjob3` and `format\administrateur`.
- Secure channel checked over domain SSH: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\BDC.format.lu`.
- OpenSSH logs confirmed `Accepted publickey for format\Administrateur`.
- SQL Server domain-auth checks succeeded against the running named instances:
  - `APSAL`
  - `CLOUDDEMAT`
  - `DATAGATE`
  - `EASYJOB6`
  - `PLANNINGPME`
  - `PNT`
- All checked SQL instances reported SQL Server 2019 `15.0.4470.1`, `RTM-CU32-GDR`, `KB5090407`.

Notes:

- EASYJOB3 domain SSH and SQL integrated-auth checks are restored.

## 2026-07-04 - Inspection Round

Maintainer: Codex with Peter

Checks and actions:

- `win-easyjob3` and `winad-easyjob3` checked: both returned `Easyjob3`; domain SSH returned `format\administrateur`.
- Secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Recent hotfixes checked: latest visible installed security updates remained `KB5094137` and `KB5094125` from `2026-06-13`.
- Visible Windows updates checked: `0`.
- SQL integrated-auth checks succeeded over domain SSH for running named instances `APSAL`, `CLOUDDEMAT`, `DATAGATE`, `EASYJOB6`, `PLANNINGPME`, and `PNT`.
- All checked SQL instances reported SQL Server 2019 `15.0.4470.1`, `RTM-CU32-GDR`, `KB5090407`.

Notes:

- EASYJOB3 domain SSH, trust, and SQL integrated-auth checks are healthy.
- Pending file rename indicates a planned reboot is useful, but no reboot was performed.
- WinRM drift recurred again and was restored only at the service level.

## 2026-07-19 - Twice-Monthly Inspection Round

Maintainer: Codex with Peter

Checks and actions:

- `win-easyjob3` and `winad-easyjob3` checked: both returned `Easyjob3`; domain SSH returned `format\administrateur`.
- Secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\BDC.format.lu`.
- `sshd` and `Netlogon` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Recent hotfixes checked: latest visible installed security updates remained `KB5094137` and `KB5094125` from `2026-06-13`.
- Visible Windows updates checked: `4`:
  - SQL Server 2019 RTM CU security update `KB5102335`
  - Windows Malicious Software Removal Tool x64 v5.143 `KB890830`
  - Windows security update `KB5099536`
  - .NET security update `KB5100998`
- SQL integrated-auth checks succeeded over domain SSH for running named instances `APSAL`, `CLOUDDEMAT`, `DATAGATE`, `EASYJOB6`, `PLANNINGPME`, and `PNT`.
- All checked SQL instances reported SQL Server 2019 `15.0.4470.1`, `RTM-CU32-GDR`, `KB5090407`.

Notes:

- EASYJOB3 domain SSH, trust, and SQL integrated-auth checks are healthy.
- July Windows/.NET/SQL updates are visible but were not installed by Codex.
- Pending file rename indicates a planned reboot is useful.

## 2026-07-19 - Remote Update Install Attempt Blocked

Maintainer: Codex with Peter

Actions:

- Attempted to start a no-reboot Windows Update install remotely.
- Creating a SYSTEM scheduled task over domain SSH failed with `Access is denied`.
- Retried through local break-glass SSH; the update task action path was still rejected with `Access is denied`.

Notes:

- No updates were installed and no reboot was performed by Codex.
- July Windows/.NET/SQL updates remain visible and require an interactive elevated session or another approved elevation path.

## 2026-07-19 - Post-Manual Update Validation

Maintainer: Codex with Peter

Checks:

- `win-easyjob3` break-glass SSH checked: OK, returned `easyjob3\administrateur`.
- `winad-easyjob3` domain SSH checked: failed with `Permission denied (publickey,keyboard-interactive)`.
- Domain secure channel checked from the local SSH context: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` and `Netlogon` checked: `Running`/`Automatic`.
- `WinRM` checked: `Stopped`/`Disabled` again after reboot/policy refresh.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: `KB5101372`, `KB5099536`, and `KB5100998` installed on `2026-07-19`.
- Visible Windows updates checked: `0`.
- SQL Server services checked: active instances `APSAL`, `CLOUDDEMAT`, `DATAGATE`, `EASYJOB6`, `PLANNINGPME`, and `PNT` are `Running`/`Automatic`; `SQLBrowser` is `Running`/`Automatic`; `TIDEPRO` and default `MSSQLSERVER` remain disabled.

Notes:

- EASYJOB3 is update-clean and does not currently require a reboot.
- SQL service state is healthy, but SQL integrated-auth version queries could not be re-run because domain SSH is denied and the local administrator account is not authorized inside SQL.
- WinRM disablement recurred after reboot/policy refresh.

## 2026-08-04 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH checked: both working; domain SSH access has recovered since the July post-update check.
- Trust checked: `nltest /sc_verify:format.lu` succeeded against PDC.
- `sshd` and `Netlogon` checked: `Running`/`Automatic`; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Six production SQL engines checked: `APSAL`, `CLOUDDEMAT`, `DATAGATE`, `EASYJOB6`, `PLANNINGPME`, and `PNT` are `Running`/`Automatic`; SQL Browser and the EASYJOB6 agent are running.
- All six SQL instances report SQL Server 2019 `15.0.4480.2`, CU32 + GDR. Microsoft lists this as the current SQL Server 2019 build (`KB5102335`, 2026-07-14).
- One downloaded Windows Security platform update, `KB5007651` version `10.0.29628.1000`, was installed through a one-time SYSTEM task.
- Update install result: success (`ResultCode=2`, `HResult=00000000`), no reboot required.
- Final Windows Update rescan still re-offered the same `KB5007651` package. The registered Security Health platform remained `10.0.29554.1001`, so the transaction did not advance the platform to the offered version.
- C: initially had about 7.5 GB free. DISM analysis found 4 reclaimable packages and recommended cleanup.
- Supported component-store cleanup completed successfully; C: increased to about 14.75 GB free.
- SQL services were rechecked after cleanup and remained healthy.
- Reboot state after maintenance: CBS `False`, Windows Update `False`.
- Temporary Codex task, script, and result log were removed after verification.

Notes:

- No SQL database or application data was changed and no reboot was performed.
- Continue watching C: capacity despite the roughly 7 GB recovery.
- Treat the recurring `KB5007651` offer as a Windows Server 2025 Security Health servicing/detection follow-up. Do not loop the installer or change AppX/registry state during routine maintenance.

## 2026-08-23 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH checked: both working.
- `nltest /sc_verify:format.lu` succeeded; the known split diagnostic remained where PowerShell returned `False` while `nltest` verified the channel.
- `sshd` and `Netlogon` are `Running`/`Automatic`; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Six production SQL engines, SQL Browser, and the EASYJOB6 agent are running in their expected start modes. All six instances reported SQL Server 2019 `15.0.4480.2` (CU32 + GDR) during pre-install discovery.
- Installed `KB890830`, .NET security update `KB5120708`, and OS security update `KB5120233`; all returned success and Windows reported a reboot is required.
- The final scan re-offers the .NET and OS updates while CBS and Windows Update reboot markers remain set. Do not retry before reboot.
- C: free space fell to about 5 GB. Component-store cleanup was not run during the pending transaction; reassess it after reboot.
- Temporary Codex update task, script, and log were removed after verification.

Notes:

- A planned guest reboot is required. No reboot was performed by Codex.
- No SQL database or application data was changed.

## 2026-09-05 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH, secure channel, `sshd`, and `Netlogon` checked healthy; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Windows Update scan returned `0`; CBS and Windows Update reboot markers are clear.
- All six production SQL Server instances are `Running`/`Automatic`. Each reports SQL Server 2019 `15.0.4480.2` (CU32 + GDR, KB5102335), current on Microsoft's SQL Server 2019 build list during this check.
- Component-store analysis found 2 reclaimable packages and recommended cleanup. `DISM /StartComponentCleanup` completed successfully without reboot; C: free space changed from 13.03 GB to 13.05 GB.
- All six SQL engines and the secure channel remained healthy after cleanup.
- Recurring Netlogon `5719` events correlate with periodic Windows Update/Windows Modules Installer activity while current trust, DNS, ports, and time are healthy.
- Temporary analysis and cleanup logs were removed after verification.

Notes:

- No SQL database, application data, GPO, or firewall configuration was changed. No reboot was performed.
- Continue monitoring C: capacity.

## 2026-09-13 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH, domain trust, `sshd`, and `Netlogon` checked healthy; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Six production SQL instances `APSAL`, `CLOUDDEMAT`, `DATAGATE`, `EASYJOB6`, `PLANNINGPME`, and `PNT` are running.
- Windows servicing installed SQL Server 2019 update `KB5122772` and `KB890830`. All six SQL instances subsequently reported `15.0.4490.9` and their databases were online.
- Windows cumulative update `KB5122871` and .NET update `KB5126052` remain offered. CBS and Windows Update reboot markers are set, so they were not retried before reboot.
- Component-store analysis found four reclaimable packages and recommended cleanup. Free space on C: recovered to about 8 GB while native servicing settled.
- An active `FORMAT\administrateur` RDP session was present with unknown unsaved application state, so no reboot or component-store cleanup was performed.
- A waiting read-only DISM analysis process was stopped only after `TiWorker` had settled; no active servicing transaction was interrupted.

Notes:

- Easyjob3 requires a planned reboot, followed by installation of the remaining OS and .NET updates, another reboot if requested, a final update scan, SQL/application smoke tests, and supported component-store cleanup.
- No SQL database, application data, GPO, firewall, or trust configuration was changed.

## 2026-10-10 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH, domain trust, `sshd`, and `Netlogon` checked healthy; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Easyjob3 is running Windows Server 2025 Standard build `26100.33438`, booted on 2026-10-09. Windows Update returned `0`; CBS and Windows Update reboot markers are clear.
- No interactive user session was present.
- SQL Browser and all six production SQL Server 2019 Standard instances are `Running`/`Automatic`. Every instance reports current CU32 + GDR build `15.0.4490.9` (`KB5122772`), and all enumerated databases are online.
- C: had 13.73 GB free. A read-only component-store analysis completed without a DISM error; supported `StartComponentCleanup` then completed successfully without reboot. C: remained approximately 13.74 GB free.
- SQL services were rechecked after cleanup and remained healthy; no reboot marker was introduced.
- Recent VSS events occurred while shutdown was already in progress. One Panda HealthCheck plug-in crash was also recorded; no SQL or application-role failure was observed.

Notes:

- No Windows or SQL update, reboot, database, application-data, GPO, firewall, or trust change was made.
- Continue monitoring C: capacity.

## 2026-10-31 - End-of-Month Maintenance

Maintainer: Codex with Peter

- Peter confirmed recent successful backups and authorized routine updates after discovery, with reboots/service interruptions separately gated. Local and domain SSH both work; explicit secure-channel test to PDC returns True and Netlogon query returns BDC status 0. WinRM remains intentionally Stopped/Disabled.
- Windows Server 2025 Standard build 26100.33650, last boot 2026-10-17 02:48:37. No interactive session was present. Windows Update search succeeded with zero applicable updates; CBS and Windows Update reboot flags are clear. No update installation was needed.
- All six production SQL Server 2019 Standard instances are Running/Automatic at 15.0.4500.2. Read-only queries confirm all 48 enumerated databases online: APSAL 5/5, CLOUDDEMAT 20/20, DATAGATE 5/5, EASYJOB6 5/5, PLANNINGPME 5/5 and PNT 8/8. The two legacy/default SQL services remain disabled; no service-start policy was changed.
- Before cleanup, C: had approximately 5.9 GiB free, a capacity warning. Read-only DISM analysis completed successfully: actual component store 18.58 GB, shared Windows components 7.60 GB, backups/disabled features 10.98 GB, four reclaimable packages and cleanup recommended. The backups/disabled-features figure is not a promise of reclaimable space.
- Peter explicitly approved supported component-store cleanup without /ResetBase and with SQL/application data left untouched. After the installer/reboot-state gate, DISM StartComponentCleanup with NoRestart ran from 14:48:32 to 14:53:57. It freed approximately 7.00 GiB (5.87 to 12.86 GiB free) but returned error 5 / 0x80070005, so this is partial reclamation, not successful completion. DISM log: C:\Windows\Logs\DISM\Codex-ComponentCleanup-20261031-144832.log.
- CBS records STATUS_CANNOT_DELETE for a servicing catalog, followed by failed CSI scavenging finalization and E_ACCESSDENIED. After a fresh worker/backup-process gate, a single one-off SYSTEM-context retry of the same supported operation ran from 14:55:52 to 14:56:12 and also returned error 5 / 0x80070005. Its log is C:\\Windows\\Logs\\DISM\\Codex-ComponentCleanup-SYSTEM-20261031.log. No further cleanup retry, forced catalog deletion, ownership/ACL change, endpoint-protection bypass or /ResetBase was attempted. The underlying cause is not established.
- Final verification: C: has 12.91 GiB free of 148.65 GiB, approximately 7.04 GiB recovered from the initial 5.87 GiB. All 48 databases remain online across the six instances at 15.0.4500.2. CBS/WU reboot markers remain clear and the October 17 boot time is unchanged. The completed temporary task Codex-Easyjob3-ComponentCleanup-20261031 was removed; DISM/CBS logs were retained and no DISM process remained at the final process check.
- Read-only DISM /CheckHealth completed with exit 0 but reports "The component store is repairable." This is a health-flag result, not a successful repair or full integrity scan. Cleanup remains incomplete; prioritize a separately reviewed servicing-repair plan and capacity follow-up. No RestoreHealth, SFC repair, reboot, SQL/application-data change, GPO or firewall change was performed.

## 2026-10-31 - Servicing Error Investigation

Maintainer: Codex with Peter

- Scope: investigate the cleanup error and propose a repair, without performing repair, reboot, protection changes or another cleanup attempt. At 17:09 local, no interactive user or servicing/installer process was active; six production SQL services were running and CBS/WU reboot markers were clear. No recent disk/Ntfs/storage error was found in the bounded System event sample; the NTFS dirty flag is clear. These checks are not a full filesystem or hardware test.
- Archived CBS evidence is in `C:\Windows\Logs\CBS\CbsPersist_20261031135842.log`: lines 848388-848398 and 848663-848675 identify the same catalog in both failures, `C:\Windows\WinSxS\Catalogs\7f092353c4772c48a528c1285b7d8bc4730e58646c769abbf8ea31eba35b248f.cat`. Native `STATUS_CANNOT_DELETE` / 0xC0000121 is translated into 0x80070005 at transaction commit; this is more specific than a general administrator-permission failure.
- The 123,044-byte catalog has Normal attributes (not read-only), a valid Microsoft Windows signature, TrustedInstaller ownership and full control for TrustedInstaller. Its SDDL matches both sampled neighboring catalogs; no explicit deny was observed. A second hard link appears under `\$Extend\$Deleted`. No catalog, hard link, attribute, owner or ACL was changed.
- A scoped Windows Restart Manager file-use query identifies PID 4 System and PID 4196 `NanoServiceMain` / Panda Cloud Antivirus Service as current users of that exact catalog. Only session/resource registration, list query and session close were used, with no shutdown/restart call. These are current users, not proof of which process held a mapped view during the earlier failed deletions.
- ESET Server Security 13.0.12007.0 and WatchGuard EDR Core are installed; ESET eamonm and Panda PSIN filters are loaded. The legacy Panda service display name alone does not prove a second full antivirus installation or an unsupported combination: [WatchGuard documents EDR Core coexistence with third-party endpoint products](https://www.watchguard.com/help/docs/help-center/en-US/content/en-us/Fireware/services/edr_core/edr_core_about_c.html). No endpoint-provider event was found in the bounded 14:47-14:58 Application sample; a vendor-console/trace review is still needed to establish interference.
- [Microsoft documents STATUS_CANNOT_DELETE](https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/ntddk/ns-ntddk-_file_disposition_information_ex) as a read-only file or existing mapped view. Combined with the Normal attributes and file-use query, an in-use mapping is the leading explanation for the cleanup failure, not a proven corrupt catalog or missing administrator rights. Do not take ownership, grant broad access or manually delete WinSxS files.
- Diagnostic-only `DISM /Online /Cleanup-Image /ScanHealth /NoRestart /English /Quiet` ran from 17:10:12 to 17:17:33, log `C:\Windows\Logs\DISM\Codex-ScanHealth-20261031.log`. Native exit 0 means the scan completed, not that the store is healthy. CBS explicitly records Operation: Detect only, result 0x0, Total Detected Corruption 40 (all CSI payload), Total Repaired Corruption 0 and zero manifest/metadata corruption in the final summary. The affected payloads are in three AppxMain component groups at 10.0.26100.1591, including lock-screen resources, PNGs, a font, PRI resources, HTML/CSS and XAML. Follow-up CheckHealth still reports repairable. The relationship between this payload corruption and the separately blocked catalog is not established.
- After the scan, all 48 databases remain online across all six production SQL instances; all six engine services are running. C: free space is approximately 13.27 GiB. CBS/WU reboot markers remain clear, the October 17 boot time is unchanged and no DISM process remains. No RestoreHealth, SFC repair, reboot, endpoint-protection change, catalog/ACL change or SQL/application-data change was performed. Approval for the supported online repair and subsequent SFC was requested separately; it is not assumed from permission to investigate.
- Repair-source discovery: Server 2025 Standard, build 26100.33650, en-US; D: is an empty virtual CD-ROM. No configured WSUS server, local repair source or explicit Internet-repair prohibition was found in the sampled policy values. This does not independently prove that DISM can download every required repair payload.
- Proposed repair now that corruption is confirmed: after approval and a fresh backup/job/session/servicing gate, run one supported online `DISM /Online /Cleanup-Image /RestoreHealth /NoRestart`, retaining its log, followed by `sfc /scannow` only after successful DISM repair. Windows Update is the preferred default repair source; if unavailable, prepare matching Server 2025 Standard en-US media with the required update level/index rather than using Server 2022 or arbitrary old media. Stop on access denied or unresolved corruption rather than looping. Recheck Windows component health, all six SQL instances/databases, disk capacity and reboot markers. No SQL service interruption is planned, but any resulting reboot requirement must be handled in a separately approved outage. A planned reboot may also release mapped files before one controlled cleanup retry; if the same catalog remains blocked, gather endpoint/Process Monitor evidence instead of forcing deletion. See [Microsoft's Server repair procedure](https://learn.microsoft.com/en-us/troubleshoot/windows-server/installing-updates-features-roles/fix-windows-update-errors) and [repair-source requirements](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/configure-a-windows-repair-source?view=windows-11).

## 2026-10-31 - Authorized Online Component Repair

Maintainer: Codex with Peter

- Peter explicitly authorized online RestoreHealth and subsequent SFC after successful DISM, without reboot, SQL service stops or endpoint-protection changes. A fresh RDP session appeared during preflight; Peter confirmed he had only logged in and had not started maintenance. Server Manager's role/feature inventory was observed using DISM/CBS; wait for that work to settle before repair, without closing his session or stopping workers.
- Recent backup success was operator-confirmed earlier in the round. The latest guest Veeam logs finish on October 30 at approximately 22:23 with the guest helper stopped; no Veeam guest backup worker was present and all enumerated VSS writers, including SQL, were Stable/No error during preflight. This is not a new independent restore test or backup-console verification. CBS/WU reboot flags were clear, six production SQL services were running and C: had approximately 13.24 GiB free.
- Planned change is limited to supported repair of Windows component files using the configured/default online repair source. Retain DISM/CBS evidence, run with NoRestart, and run SFC only after successful DISM and a review of its result/reboot state. Do not install a separate update set, retry component cleanup, alter catalogs/ACLs, bypass protection or change SQL/application data. On failure, stop and reassess; any reboot, offline repair or recovery from the operator-confirmed backup requires a separately approved outage. No automatic rollback, snapshot or restore is scheduled.
- Server Manager's inventory session closed at 17:31:31. After confirming no DISM host, SFC, MSI or Veeam guest worker, clear CBS/WU flags, more than 8 GiB free and idle TiWorker CPU over a five-second sample, the authorized direct-domain-SSH repair ran from 17:32:25 to 17:40:19: `DISM /Online /Cleanup-Image /RestoreHealth /NoRestart /English /Quiet /LogPath:C:\Windows\Logs\DISM\Codex-RestoreHealth-20261031.log`.
- The attempt failed with native exit -2146498283 / HRESULT 0x800f0915, CBS_E_REPAIR_CONTENT_MISSING. CBS final summary is Detect and Repair, 40 CSI payload corruptions detected, zero repaired and zero manifest/metadata corruption. SFC was not started because its successful-DISM prerequisite was not met. No second repair attempt has been launched at this checkpoint.
- CBS shows the immediate online-source failure at 17:38:45: Failed to set interactive flag for search, Failed to set correlation vector and Failed to do Windows update search, all 0x80070005. Server.OS, Windows.Appraiser, Windows.AppraiserData and Windows.OOBE payload/history acquisition also report access denied. The final missing-content error does not by itself establish lost Internet access or unavailable Microsoft payloads; the remote-login/WU-client context is a plausible cause, not yet proven. A separately authorized single SYSTEM-context retry has been requested to distinguish this from a genuine source-content problem; it must retain NoRestart and all existing SQL/protection limits.
- The repair also encountered STATUS_CANNOT_DELETE on `C:\Windows\WinSxS\Catalogs\aa97c849c254281b8ccbdc0e5edf1738be99c551f4dd3d2133b3265a4c34bd86.cat` at 17:39:48. This is a different catalog from the earlier cleanup error. Its observed attributes are Normal, owner TrustedInstaller and SDDL matching the previously sampled standard catalog ACL. No manual deletion, ACL change, protection bypass or retry of component cleanup was performed. Do not conflate this catalog event with the separate WU repair-content acquisition failure.
- Post-attempt CheckHealth still reports repairable; CBS/WU reboot flags remain clear and DISM reports no reboot required. C: free approximately 13.37 GiB; all 48 databases remain online across the six production SQL instances, and the October 17 boot time is unchanged. ESET, NanoServiceMain and PandaAetherAgent remain running. The direct DISM process exited; logs were retained. No SQL service stop, reboot, SFC repair, endpoint-protection change, GPO/firewall change or application-data change was made.

## 2026-10-31 - Authorized SYSTEM Repair Retry

Maintainer: Codex with Peter

- Peter explicitly approved one SYSTEM-context retry after the direct repair's access-denied online-content searches. This is a targeted context test, not permission for a reboot, SQL stop, endpoint change, catalog deletion, ACL change, another component-cleanup attempt or unlimited repair retries. Existing approval for SFC remains conditional on successful component repair and review of reboot state.
- Fresh preflight at 17:50 local: all six SQL services and existing ESET/Panda services are running, C: has about 13.47 GiB free and CBS/WU reboot markers are clear. Peter's active RDP session is retained. Another Server Manager inventory refresh began at 17:48:33; wait for its DISM session to close and the worker to settle before starting repair. No matching retry task already exists.
- The proposed one-off task runs native DISM as SYSTEM/Highest, on demand only, with IgnoreNew and a bounded execution limit. Its action must retain RestoreHealth, NoRestart and a separate diagnostic log. Remove only the completed temporary task after capturing its result; retain native logs. No recurring task, account, GPO, firewall, protection or SQL setting is changed.
- Server Manager's inventory closed at 17:51:02. After the idle-worker, no-competing-process, clear-reboot-flag and free-space gates, the one authorized retry task `Codex-Easyjob3-RestoreHealth-SYSTEM-20261031` started at 17:52:00. Verified principal SYSTEM, native `C:\Windows\System32\dism.exe`, RestoreHealth/NoRestart/English/Quiet, no trigger, IgnoreNew and a two-hour execution limit. Separate log: `C:\Windows\Logs\DISM\Codex-RestoreHealth-SYSTEM-20261031.log`. Do not launch a competing repair while this task is Running.
- Unlike the direct attempt, this SYSTEM run progressed into WUA repair-content acquisition at approximately 17:58, with download-stage progress rather than the immediate access-denied search failure. This supports a remote-login context restriction for the first attempt; it does not yet establish successful repair. All six SQL services remained running in monitoring. At 18:03 local C: had approximately 10.54 GiB free while content was staged. Task result, repaired-file count, conditional SFC and final verification are pending at this checkpoint.
- Monitoring through 18:25: the first 338,921,978-byte transfer reached completion at 18:08:37, Windows Update logged download-success event 41 at 18:08:42 and the first WUA acquisition returned 0x0 at 18:15:07. A second acquisition started at 18:15:42; its 322,991,056-byte transfer reached completion at 18:24:20. These are content-transfer/acquisition results, not final repair success. Windows Update remained CPU-active and its internal preparation reported WU_E_OPERATIONINPROGRESS/0x80240009 responses and timeouts; no second DISM attempt was launched.
- A readable Windows Update trace was generated as `C:\Windows\Logs\DISM\Codex-WindowsUpdate-RestoreHealth-20261031.log` (about 8.3 MB), using Get-WindowsUpdateLog without ForceFlush, so no Update Orchestrator/WU service stop was requested. Some ETL records did not match the decoder schema; retained text is diagnostic evidence, not a complete trace of every event.
- All 48 databases were independently rechecked online at 18:12, and all six SQL services still ran at 18:23. Staging reduced C: free space to 6.23 GiB at 18:23 and 6.11 GiB at 18:25; disk 0 is 150 GiB with no unallocated extent. Capacity-based cancellation near 4 GiB was requested from Peter; no cancellation or cleanup has occurred at this checkpoint. No manual cache/temp deletion, SQL stop, reboot or protection change was performed. Task result and subsequent checks remain pending.

## 2026-10-31 - Repair Completion and Verification

Maintainer: Codex with Peter

- This final checkpoint supersedes the pending states above. The single authorized SYSTEM RestoreHealth ran from 17:52:00 to 18:36:01 and returned 0; its task was observed Ready with LastTaskResult 0 at 18:36:08. CBS finalized the repair at 18:30:47 with operation result 0x0, 40 detected CSI payload corruptions and all 40 repaired, then completed native temporary-directory cleanup. DISM reports no reboot required. Log retained: `C:\Windows\Logs\DISM\Codex-RestoreHealth-SYSTEM-20261031.log`.
- Both repair-content acquisitions returned 0x0 in SYSTEM context (18:15:07 and 18:30:39). This contrasts with access-denied WU searches under the direct SSH token. SYSTEM context resolved that acquisition restriction without changing filesystem permissions, domain policy, firewall or endpoint protection; the earlier catalog-mapping cause is not thereby proven.
- After a fresh no-competing-worker and clear-CBS/WU-reboot-state gate, authorized `sfc /scannow` ran as SYSTEM from 18:37:08 to 18:40:57. Task result 0; its report says Windows Resource Protection found corrupt files and successfully repaired them. Report retained: `C:\Windows\Logs\CBS\Codex-SFC-SYSTEM-20261031.txt`. This is an additional protected-file repair, not a claim that SFC initially found no violations.
- A separate `sfc /verifyonly` pass ran from 18:43:00 to 18:45:42, returned 0 and explicitly reported no integrity violations. It performed verification, not another repair. Report retained: `C:\Windows\Logs\CBS\Codex-SFCVerify-SYSTEM-20261031.txt`; behavior documented by [Microsoft](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc).
- Final DISM CheckHealth reports no component-store corruption. At the 18:44-18:46 role checks, all 48 databases remained online across six SQL Server 2019 instances at 15.0.4500.2; all six engine services remained Running/Automatic. PDC secure-channel test returns True and nltest queries PDC with status 0. SSH, Netlogon and existing ESET/Panda services are Running/Automatic; WinRM remains Stopped/Disabled. The bounded recent Application sample contained no matching MSSQL/SQLSERVER error. This is role/metadata verification, not DBCC or an authenticated Easyjob application workflow test.
- No reboot or SQL service stop occurred; last boot remains 2026-10-17 02:48:37 and CBS/WU reboot markers are clear. PendingFileRenameOperations separately contains 80 values / 40 nonempty paths, including Edge updater versions and Panda/Aether installer temporary paths. They were inspected, not cleared; clear Windows servicing flags do not imply that every third-party pending operation is absent.
- Final C: free space is 13.01 GiB of 148.65 GiB. The lowest sampled free space during staging was 6.03 GiB; native cleanup recovered space without manual deletion. Peter approved cancellation near 4 GiB after staging had already recovered; that threshold was not observed, no cancellation was performed and no ongoing capacity-guard automation was created. Disk 0 is 150 GiB with no unallocated extent. Review VMware datastore capacity and plan additional system-volume headroom before another large servicing run.
- Captured result 0 for all three one-off tasks, then unregistered only `Codex-Easyjob3-RestoreHealth-SYSTEM-20261031`, `Codex-Easyjob3-SFC-SYSTEM-20261031` and `Codex-Easyjob3-SFCVerify-SYSTEM-20261031` after confirming none Running/Queued. Final scoped task inventory shows no Codex-Easyjob3 task remaining. DISM, SFC, verification and Windows Update diagnostic logs remain on the server; no recurring maintenance task was added.
- No manual catalog/cache/temp deletion, ACL/ownership change, protection bypass, GPO/firewall change, SQL/application-data change or reboot was made. Native repair and cleanup only were allowed to finish. The original StartComponentCleanup catalog-deletion failure was not retested after repair, and is not claimed resolved; review it separately in a future approved window. Runbook and ESX-D summary updated; no commit or push requested in this turn, and unrelated dirty work was preserved.

## 2026-10-31 - Operator Reboot, Easyjob Upgrade and Post-Boot Update Check

Maintainer: Codex with Peter

- Peter reported completing the restart and Easyjob upgrade and requested recovery checks and routine updates. Verified last boot 18:54:24, Windows Server 2025 Standard build 26100.33650. His active RDP session was retained; no further restart, SQL stop or session termination was performed by Codex.
- Installed/client Easyjob version is 6.28.2.73; the shared server executable reports 6.28.2.72. Easyjob Server Service, Task Scheduler and WebApi are Running/Automatic. The same three previously stopped optional-module services (Mobile Device Service, Print Server and High Performance Scaler) remain Stopped/Automatic with exit codes 0. Their usage was not confirmed and they were not started blindly. No authenticated Easyjob application, report, email or scanner workflow was tested by Codex.
- All six SQL Server 2019 instances still report 15.0.4500.2 with all 48 databases online (5/20/5/5/5/8). SQL backup history now records a full easyjob6 backup at 19:07:11; this is metadata evidence, not independent restore verification. C: free approximately 12.98 GiB. DISM CheckHealth still reports no component-store corruption. CBS/WU reboot markers are clear and the latest PendingFileRenameOperations query has zero nonempty paths.
- A local SYSTEM, on-demand diagnostic task at 19:22:34 independently checked trust and searched Windows Update. Task result 0; update search ResultCode 2 with zero applicable, non-hidden, uninstalled updates. No routine update installation was needed. Report retained as `C:\Windows\Logs\DISM\Codex-Easyjob3-PostBootScan-20261031.json`; the completed diagnostic task was removed after checking its result/report. No install or repair task remains from this follow-up.
- The post-reboot domain check is not healthy: Test-ComputerSecureChannel targeting PDC returns False over SSH and under local SYSTEM; nltest sc_query reports flags 0 / status 1311. Netlogon event 5719 at 18:54:37 reports an internal error setting up the domain session. SSH, SQL and Easyjob core services remain running. Do not treat working key-based SSH as proof of a healthy machine secure channel.
- DC Locator successfully finds writable PDC/GC/KDC at 192.168.1.5; DNS uses 192.168.1.5 and 192.168.1.4. PDC stripchart offsets are approximately -0.0036 to -0.0028 seconds. An initial time query was unsynchronized, but a subsequent query reports PDC source, leap 0 and stratum 5. No time resync, service restart or password reset was performed. PDC AD metadata shows EASYJOB3 enabled, PasswordLastSet October 30 02:52:38 and key version 160; BDC could not be queried, so cross-DC metadata equality is unverified.
- BDC at 192.168.1.4 timed out on SSH and the separately probed 88/389/445/9389 ports over the office VPN route. This is consistent with the ESX-C log's operator-reported shutdown for HPE host firmware work, not authenticated proof of VM power state. PDC showrepl reports three consecutive failures in all five contexts (1722 for domain/configuration/schema and 1256 for DNS contexts), with latest successes approximately 15:47-16:17. No BDC power action, forced replication or ESX-C maintenance change was made.
- Likely RPC/NTLM compatibility issue: Easyjob3 has EnableAuthEpResolution DWORD 1, with RSoP attributing it to Default Domain Policy GUID 31B2F340-016D-11D2-945F-00C04FB984F9 at precedence 1. PDC has incoming NTLM restriction 2. [Microsoft documents these settings as incompatible](https://learn.microsoft.com/en-us/windows-server/security/rpc-interface-restrict#enableauthepresolution), and this matches the configuration addressed separately on Exchange3. This is a reasoned hypothesis for the current failure, not a verified Easyjob resolution. Sampled local NTLM events concern anonymous CIFS attempts to FILE, not direct proof of blocked PDC RPC traffic; do not conflate them.
- Proposed change, pending Peter's separate approval: back up relevant GPO/link state, create an Easyjob3-only computer-policy compatibility override with sole value EnableAuthEpResolution=0, retain NTLM restrictions and all other hosts' settings, then have Peter reboot the VM himself and verify trust/SQL/Easyjob again. Scope must be limited by security filtering; rollback is removal of only the new link followed by a planned reboot to restore the current Default Domain Policy value 1. No GPO, registry, trust/password, endpoint-protection or firewall change has been performed in this follow-up. Cleanup is deferred while the new domain-health issue is unresolved; the earlier component-cleanup catalog failure is not claimed fixed.

## 2026-10-31 - Authorized Easyjob3-Only RPC Compatibility Policy

Maintainer: Codex with Peter

- Peter explicitly authorized backing up the relevant policy and applying an Easyjob3-only override of `EnableAuthEpResolution` to 0, retaining NTLM blocking. He will reboot the VM himself. This approval does not cover other hosts, domain-wide relaxation, machine-password resets, SQL stops or additional cleanup. Before activation, confirmed the target account is `EASYJOB3$`, SID `S-1-5-21-3572445798-2314295735-3149754986-3611`, in `OU=_Core-Servers without NTLM,OU=_Servers,OU=_Computers,DC=format,DC=lu`.
- Saved GPO backups, permission exports, target-computer metadata, relevant NTLM policy values, and domain-root link/attribute exports on PDC under `C:\ProgramData\Codex\GPO-Backups\EASYJOB3-RPC-20261031-1938` before linking. Default Domain Policy backup ID: `5b3297c8-fdec-4af2-8e68-41109dcda9b8`; existing Exchange-only GPO backup ID: `5bdc9e9c-fb12-4e5a-9c08-a829d3880f53`. These are configuration backups, not new workload backups or restore tests.
- Created `EASYJOB3 - RPC endpoint mapper compatibility`, GUID `97f95ddc-2bf8-4c18-a40c-2977cef6e29d`, with user settings disabled and no WMI filter. Its sole setting is `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc\EnableAuthEpResolution`, DWORD 0. Before linking, verified the sole GpoApply trustee is the exact EASYJOB3 computer SID. Authenticated Users (`S-1-5-11`) and Enterprise Domain Controllers (`S-1-5-9`) have read only; Domain Admins, Enterprise Admins and SYSTEM retain edit/delete/security rights. The generated report confirms one computer Registry extension, one policy and no user extensions.
- Linked at `DC=format,DC=lu`, order 1, enabled and enforced. Existing links shifted down one position while their relative order and enabled/enforced flags were verified unchanged. Computer/user policy report sections and security descriptors for Default Domain Policy and the existing Exchange-only GPO compare unchanged before/after. Default Domain Policy retains RPC value 1. The complete sampled PDC NTLM key compared unchanged; retained before/after exports are limited to relevant policy values. PDC incoming NTLM remains 2 and domain NTLM restriction remains 5; no NTLM exception was added. Easyjob3 incoming NTLM remains 2, with the sampled outgoing restriction/exception values absent as before.
- Backed up the new linked GPO as ID `57b21938-0a0c-450b-b35b-ba497ed3e9a0`; identity, unlinked/linked reports, permissions and after-link exports are retained in the same backup folder. BDC remains unavailable during the operator's separately documented ESX-C maintenance; replication of this new GPO to BDC is not verified and no BDC power/replication action was attempted.
- At 19:37:40, ran only Easyjob3 computer-policy refresh. Exit 0; registry now reads RPC DWORD 0, and RSoP identifies the new GPO at precedence 1 ahead of Default Domain Policy's value 1 at precedence 2. A separate extension warning 1085 for `{F312195E-3D9D-447A-A3F5-08DFFA24735E}` was emitted; its registered DLL is `dggpext.dll`, handler `ProcessVirtualizationBasedSecurityGroupPolicy`. The computer-policy success event 1502 and verified RPC/RSoP values do not clear that separate warning; no extension or VBS setting was changed. Saved successful computer gpresult export as `C:\Windows\Logs\Codex-Easyjob3-RPC-20261031.xml`.
- Post-policy role checks at 19:38: all six SQL Server 2019 instances remain 15.0.4500.2 with 48/48 databases online (5/20/5/5/5/8), and all six engine services plus Easyjob Server, Task Scheduler and WebApi remain Running/Automatic. The three previously stopped optional Easyjob services and disabled legacy SQL services were left unchanged. SSH/Netlogon remain Running/Automatic; WinRM remains Stopped/Disabled. C: free 12.96 GiB; CBS/WU reboot flags false. Final process inventory found no DISM, TiWorker, TrustedInstaller or MSI worker. Last boot remains 18:54:24; Peter's active session was retained and no reboot or service stop was performed by Codex.
- **Pending:** Peter must save work/close application clients and perform the planned Easyjob3 reboot. [Microsoft documents that this RPC setting requires reboot](https://learn.microsoft.com/en-us/windows-server/security/rpc-interface-restrict#enableauthepresolution). Effective policy 0 is verified, but runtime activation and secure-channel recovery are not yet verified; do not call trust repaired. After reboot, retest PDC secure channel and nltest, verify RPC value/RSoP, all SQL databases, Easyjob services and an operator application workflow. Recheck BDC replication separately after its planned return. Routine Windows Update scan earlier offered zero updates; no new installation was needed.
- Rollback, only if needed: remove only this new link with `Remove-GPLink -Guid 97f95ddc-2bf8-4c18-a40c-2977cef6e29d -Target 'DC=format,DC=lu' -Domain format.lu -Server PDC.format.lu`. Preserve the unlinked GPO/backups, confirm original links' relative order/flags, refresh Easyjob3 computer policy to restore Default Domain Policy RPC value 1, and arrange an operator-approved reboot for runtime rollback. Do not restore or edit unrelated policies. Runbook and ESX-D summary updated; no commit/push requested and unrelated dirty changes preserved.

## 2026-10-31 - Post-Override Reboot and Trust Recovery Verification

Maintainer: Codex with Peter

- Peter reported completing the planned reboot. Live OS readback confirms last boot **19:41:10**, Windows Server 2025 Standard image 26100.33650. Both domain SSH (`format\administrateur`) and local break-glass SSH (`easyjob3\administrateur`) work. These checks supersede the pending reboot/trust state in the preceding policy checkpoint; no further policy, password, firewall, service-start or reboot action was performed.
- At 19:46:31, `Test-ComputerSecureChannel -Server PDC.format.lu -Verbose` returns True, immediately followed by `nltest /sc_query:format.lu` reporting PDC, flags 30 and status 0. Repeated both at 19:47:08 with the same successful results. DC Locator also finds writable PDC/GC/KDC at 192.168.1.5. The previously reproducible PDC trust failure is resolved in these repeated post-reboot tests; no new machine-password reset was needed. This is current local/PDC recovery evidence, not a test against the unavailable BDC or a guarantee against future startup warnings.
- Effective RPC DWORD remains 0. RSoP identifies Easyjob3-only GPO `97f95ddc-2bf8-4c18-a40c-2977cef6e29d` at precedence 1, ahead of Default Domain Policy value 1 at precedence 2. Incoming NTLM remains 2, with sampled outgoing restriction/exception values absent as before. SSH, Netlogon and Spooler are Running/Automatic; WinRM remains Stopped/Disabled by policy. No SYSTEM task was needed for the now-successful trust checks.
- SQL verification at 19:46:39: all six production instances remain 15.0.4500.2, with 48/48 databases online: APSAL 5/5, CLOUDDEMAT 20/20, DATAGATE 5/5, EASYJOB6 5/5, PLANNINGPME 5/5 and PNT 8/8. All six engines and Easyjob Server Service, Task Scheduler and WebApi remain Running/Automatic. ESET core/firewall, NanoServiceMain and PandaAetherAgent are running. Existing optional Easyjob Mobile Device, Print Server and High Performance Scaler services remain Stopped/Automatic; disabled legacy SQL services remain untouched. Authenticated application/report/scanner workflows and database integrity checks were not performed.
- C: reports Healthy with 14.45 GiB free of 148.65 GiB; approximately 11.69 GiB memory was free. CBS/WU reboot markers are false, with zero nonempty pending-file-operation paths. After confirming no competing servicing/installer worker, DISM CheckHealth returned 0 and reported no component-store corruption at 19:47:18. It was a health check, not another repair or cleanup; no new update search/installation was requested. The earlier SYSTEM scan offered zero updates.
- Time is synchronized to PDC, leap 0 / stratum 4, including a 19:46:55 successful sync. Separate VMware `vmwTimeProvider` events 1/4 recurred at that timestamp, reporting no precision clock device/device unreachable. Do not label those recurring provider errors resolved merely because the current domain time source works. No VMware Tools/time-provider setting was changed.
- Bounded post-boot System/Application warning/error review (up to 100 per log): one Netlogon 5719 at 19:41:20, before the subsequent repeated passing trust checks; no later Netlogon warning/error in that sample. The separate `dggpext.dll` extension warning 1085 recurred at 19:41:22. Seven FilterManager 11 events report PSINFile and RsFx0603 lacking bypass-IO support. No matching SQL engine error, application crash/hang, disk or NTFS error appeared in the sampled events; this is not a claim that all historical logs are clean.
- Secure Boot/TPM-WMI events 1801/1803 at 19:46:20 report updated certificates not yet applied to firmware and no PK-signed KEK. Retain as a distinct VMware/firmware security follow-up; no Secure Boot keys, firmware, VBS or GPO settings were changed. SQLISService150 warning 274 reports fallback to the default configuration file, but MsDtsServer150 is Running/Automatic. Security-SPP event 16398 reports a missing grace timer; direct Windows licensing readback returns ServerStandard LicenseStatus 1 and GracePeriodRemaining 0, so that event alone is not evidence of an unlicensed installation.
- Current core-service/trust recovery is verified, but the host is not warning-free. Next operator check: open Easyjob, load a project and run a familiar report. Review optional-module usage before starting any stopped service; retain separate follow-ups for system-volume headroom, original component-cleanup failure, policy/VMware/Secure Boot warnings and cross-DC replication after BDC's planned return. No BDC/other-host action was taken. Updated only Easyjob3 runbook/log and ESX-D summary; no commit/push requested and unrelated changes preserved.

## 2026-10-31 - Warning Root Causes and Proposed Remediation

Maintainer: Codex with Peter

- Peter reports the rest is OK and explicitly confirms the three stopped optional Easyjob services (Mobile Device, Print Server, High Performance Scaler) are unused. Treat them as intentional, not pending availability faults. Their Automatic start modes and stopped states were not changed. This is operator usage/health confirmation, not a Codex application transaction test.
- Read-only checks at 19:53-19:55 confirm `Confirm-SecureBootUEFI=True`. PK is 45 bytes with the sole certificate byte 0, matching Broadcom's documented invalid/NULL placeholder test. A string-presence check finds Windows UEFI CA 2023 in db, but not the Microsoft Corporation KEK 2K CA 2023 name in KEK; this is not a complete signature-database certificate inventory. Secure Boot servicing reports `UEFICA2023Status=InProgress`, `KEKLastUpdateErrorReason=Firmware_MissingKEKInPackage`, error 2147942402 (`0x80070002`) and event 1803. AvailableUpdates is 16388 (`0x4004`). Do not blindly overwrite pending-update flags or delete/reset NVRAM.
- Get-Tpm reports no TPM present. Current vCenter/ESXi build, VM hardware version, vTPM device inventory and recovery readiness are not authenticated in this follow-up. `manage-bde`/Get-BitLockerVolume were unavailable and the encryption WMI namespace was absent, so encryption/recovery-key readiness is not independently established; absence of those tools is not proof that all relevant storage is unencrypted. No key update was attempted.
- [Broadcom Secure Boot KB 423893](https://knowledge.broadcom.com/external/article/423893/secure-boot-certificate-expirations-and.html) identifies the missing Windows OEM Devices PK as blocking OS-driven KEK updates. For confirmed vTPM-disabled VMs on ESXi 8.0 U3j/P09 or newer supported releases, its supported automated PK method uses a VM restart; older builds have a documented manual vUEFI procedure. Verify the live host/VM combination before choosing a method; an ESXi upgrade would affect other workloads and needs a separate maintenance plan. Back up VM configuration/NVRAM and verify workload recovery arrangements before approved boot-key changes, preserve Secure Boot, and follow Microsoft servicing afterward until Updated/1808 is confirmed. A reboot alone has not resolved this VM's current state.
- VMware Tools is already 13.1.5 build 25544008. `HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\vmwTimeProvider` has Enabled 1/InputProvider 1. The observed missing-device errors match [Broadcom KB 325051](https://knowledge.broadcom.com/external/article/325051): optional precision-clock provider installed without its virtual device. Windows is using PDC time; VMware Tools' separate timesync command also reports Enabled. These are distinct mechanisms. Preferred supported remedy for this AD-synchronized member is Modify VMware Tools, remove only VMware Time Provider, then perform an approved reboot and verify PDC synchronization/no new provider events. Do not disable W32Time or change PDC hierarchy, and do not add a precision clock simply to hide the warning. No Tools modification or time-provider registry change was performed.
- `dggpext.dll` is not missing/corrupt in the evidence: its registered VBS handler runs and GroupPolicy Operational event 7016 reports error 2147946961 (`0x800711D1`). DeviceGuard Operational event 7001 supplies the exact cause: the hypervisor is not protecting DMA because an IOMMU is absent/not enabled. Hyper-V-Hypervisor event 42 reports SVM absent/not enabled, while Wininit 15 says the secure kernel is not running. The guest CPU reports AMD EPYC 7313P, VMMonitorModeExtensions False and SLAT False; authenticated vCenter CPU-exposure settings remain unverified.
- RSoP attributes all sampled Device Guard settings to Default Domain Policy: EnableVirtualizationBasedSecurity 1, RequirePlatformSecurityFeatures 3, HypervisorEnforcedCodeIntegrity 1, HVCIMATRequired 1, LsaCfgFlags 1 and ConfigureSystemGuardLaunch 1. Win32_DeviceGuard reports VBS status 1, configured services 1/2/3 and running services 0: configured, not running. This is an actual protection gap, not merely cosmetic logging. [Microsoft's DeviceGuard policy documentation](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-deviceguard#requireplatformsecurityfeatures) distinguishes Secure Boot value 1 from Secure Boot plus DMA value 3, which requires hardware support.
- Proposed VBS remedy, not yet authorized/applied: verify VM hardware/AMD host support, console/backup recovery and endpoint/SQL driver compatibility; plan VM shutdown to enable vCenter Windows VBS and the required guest virtualization exposure. Where the VM cannot provide DMA protection, prepare a separately backed-up Easyjob3-only Device Guard policy using Secure Boot level 1 instead of requiring level 3. Review existing UEFI-lock settings before activating protection; preserve NTLM blocking and the already successful RPC-only override, and do not broadly edit Default Domain Policy. [Broadcom KB 423079](https://knowledge.broadcom.com/external/article/423079/how-to-enable-memory-integrity-on-window.html) documents the powered-off VM VBS setting. Validate VBS actually Running/expected services after the approved change, plus SQL, Easyjob and trust; do not promise that one setting change resolves every prerequisite.
- No service/component removal, policy/registry change, boot-key update, protection disablement or reboot occurred in this investigation. Only current evidence and unused-service classification were documented. Secure Boot and VBS work require separately approved VM/host configuration/outage steps; the healthy SQL and current domain trust are not reasons to change these settings without those gates. No commit/push requested; unrelated work preserved.

## 2026-10-31 - Authorized VMware Time Provider Removal and Live Placement Check

Maintainer: Codex with Peter

- Peter authorized removing the optional VMware Time Provider first and asked for an independent ESX-D version check and clarification of vSphere's host-time synchronization checkboxes. Scope is component removal on Easyjob3 plus read-only management inspection, not a reboot, host upgrade, VM migration, security-policy change or authorization to alter time-sync checkboxes.
- Preflight: all six SQL and three core Easyjob services run, PDC trust passes, no competing MSI/DISM/TiWorker/TrustedInstaller or Veeam guest process was found, all 11 sampled VSS writers including SqlServerWriter report Stable/No error, and CBS/WU reboot flags are clear. This is current writer evidence, not a new backup or restore test; the earlier confirmed-backup maintenance gate remains the basis for this component change. Peter's active RDP session was retained. C: had 12.49 GiB free. The three unused Easyjob services remain intentionally stopped.
- Read Windows Installer metadata without Win32_Product: installed VMware Tools 13.1.5.0 product code `{E9332AC6-D92E-4693-9F95-C4B2206FE52F}`, cached maintenance MSI `C:\Windows\Installer\33ef2.msi`, original full installer `C:\Program Files\Common Files\VMware\ToolsInstallerCache\{E9332AC6-D92E-4693-9F95-C4B2206FE52F}.msi` (99,598,336 bytes). Original MSI Authenticode is Valid, signer Broadcom Inc. Feature-table inspection confirms the exact `VmwTimeProvider` feature is installed; no guessed component name or complete Tools uninstall was used.
- Saved provider registry export, all feature states, service baseline, signed installer hash and execution result under `C:\ProgramData\Codex\Maintenance\Easyjob3-TimeProvider-20261031`. Rollback, if separately needed, is maintenance of the same signed installed-version MSI with only `ADDLOCAL=VmwTimeProvider`, preserving other feature states and reboot suppression, followed by appropriate validation. Do not restore the registry registration alone without its installer-managed files. The full installer remains in ToolsInstallerCache; no installer/cache file was deleted.
- From 20:06:47 to 20:06:56, native msiexec maintenance used only `REMOVE=VmwTimeProvider`, quiet mode, `/norestart`, `REBOOT=ReallySuppress` and `MSIRESTARTMANAGERCONTROL=DisableShutdown`. Result 0 and installer log confirm successful configuration. No ADDLOCAL=ALL, upgrade, feature-wide reinstall, SQL stop, forced application shutdown or service-policy change was requested. Native log: `Remove-TimeProvider.log`; result: `Removal-Result.xml` in the backup folder.
- Verification: `VmwTimeProvider` feature changes from state 3 (local) to 2 (absent); every other enumerated feature state compares unchanged. The provider's W32Time registry key and DLL are absent. VMware Tools, Windows Time, SSH, Netlogon, ESET and Panda/Nano remain running; WinRM stays disabled. All 48 databases remain online (5/20/5/5/5/8), all six SQL engines and three Easyjob core services run. PDC secure-channel test is True; nltest now reports BDC status 0, demonstrating its return for this connection, not proof of cross-DC replication convergence. Time source remains PDC, leap 0/stratum 4. No new Time-Service event was found in the bounded post-removal sample through 20:09:47, but no post-change reboot has occurred. Last boot remains 19:41:10, CBS/WU flags are false and nonempty pending-file paths zero. Final warning closure requires validation after the next separately approved reboot; none was initiated here.
- Direct HTTPS queries to .203 timed out from the Mac over VPN utun6 and from Easyjob3; direct .15 HTTPS also timed out. Host SSH was unavailable. These attempts made no configuration change. Peter then signed in to the existing Chrome `https://vcenter8.format.lu/` tab; authenticated UI inspection was successful. Do not conflate direct network probe failure with vCenter UI availability or treat a disconnected host's inventory as a fresh host response.
- Important placement correction at about 20:07-20:08: historical ESX-D `192.168.5.203` is shown **Not responding**, with Cannot synchronize host / host connection-power alarm and HA-agent-disabled notice. Its displayed ESXi version is 8.0.3 build 24674464, HPE ProLiant DL325 Gen10 Plus v2, but this is last-known inventory, not live host verification. Whether the disconnection is intentional is unconfirmed. No reconnect, management-agent restart, power operation or alarm dismissal was attempted.
- Easyjob3's authenticated Summary instead shows actual host **192.168.5.205**, Powered On, Tools Running/Current, VM hardware 21 (ESXi 8.0 U2 and later), 6 vCPU/16 GB, 150-GB disk on MSA_PERFHDD, and VM-level encryption Not encrypted. That last property is not a guest-volume encryption assessment. Current host .205 is Connected, HPE ProLiant DL345 Gen10 Plus, AMD EPYC 7313P, about two hours uptime, and ESXi 8.0.3 build 24674464. [Broadcom's build table](https://knowledge.broadcom.com/external/article?articleNumber=316595) maps it to Update 3e/P05. No migration was done by this action; observed placement supersedes the historical folder association for future host-level work.
- Read-only VM Options inspection: both Synchronize at startup and resume and Synchronize time periodically are currently checked; Windows VBS Enable is visually unchecked. The dialog was cancelled without saving. These time-sync controls govern VMware Tools host-clock corrections, not the removed Windows precision-clock provider. [Broadcom KB 326306](https://knowledge.broadcom.com/external/article?legacyId=1189) recommends native guest time synchronization, periodic host sync off, and one-off startup/resume sync enabled by default. Recommend only unchecking periodic sync for this domain member, with accurately synchronized host time; no checkbox was changed here.
- Both displayed host builds predate the 8.0 U3j/P09 automated NULL-PK remediation described in the previous investigation. Secure Boot repair therefore needs a separately approved, host-compatible plan, not an assumption that another guest reboot alone will repair keys. Leave Secure Boot/VBS settings, RPC override and NTLM restrictions unchanged pending that plan. Updated Easyjob3 and ESX-D records plus the management log/runbook; no commit/push requested and unrelated changes preserved.

## 2026-10-31 - Post-Firmware Host Return and Staged Security Repair Assessment

Maintainer: Codex with Peter

- Peter clarified that the .203 outage and .205 placement were intentional migrations for firmware work, then reported .203 returned and requested inspection and Secure Boot/VBS repair options. This follow-up is read-only discovery, not authorization to snapshot, reboot/shut down, patch ESXi, change VM/security policy, attach media or update boot keys.
- Authenticated vCenter confirms .203 Connected, HA Connected (Secondary), about 58 minutes uptime, ESXi 8.0.3 build 24674464 on ProLiant DL325 Gen10 Plus v2. The prior disconnected-management finding is resolved. Firmware completion is operator-reported; exact iLO/BIOS/device firmware versions were not audited. The hypervisor build is unchanged, not upgraded by the physical firmware work. Exit-maintenance task completed at 21:45:51; operator migration of Easyjob3 back completed at 21:47:01. VM Summary confirms Powered On on .203, hardware version 21, Tools Running/Current. No Codex migration or power operation occurred.
- Guest checks 21:47-21:48: boot remains 19:41:10, PDC trust True, nltest BDC status 0, six SQL engines and Easyjob core services running, 48/48 databases online (5/20/5/5/5/8), C: free 12.41 GiB. Working RPC override remains 0; incoming NTLM remains 2. The optional three Easyjob services remain intentionally stopped and unused. No new vmwTimeProvider event was found since its authorized 20:06:56 removal; provider registration remains absent. No guest restart has yet tested that change at boot.
- Secure Boot is enabled, but PK is still the 45-byte NULL placeholder; KEK string sampling still lacks the 2023 KEK name and db contains Windows UEFI CA 2023. Servicing remains InProgress, error 0x80070002 / event 1803, Firmware_MissingKEKInPackage. Get-Tpm reports no TPM; read-only virtual hardware inspection shows Security Devices Not Configured. EFI and Secure Boot are enabled, Force EFI Setup unchecked; no boot option was changed.
- Preferred Secure Boot route: assess and approve an HPE/vCenter-compatible ESXi 8 patch at least U3j/P09, then use Broadcom's no-vTPM automatic PK remediation on a planned guest restart and allow native Windows KEK servicing to finish. [Broadcom KB 423893](https://knowledge.broadcom.com/external/article/423893/secure-boot-certificate-expirations-and.html) documents the version/vTPM eligibility. [Vendor build catalog](https://knowledge.broadcom.com/external/article?articleNumber=316595) currently lists U3j build 25429389 and newer U3k build 25595708; release availability is not compatibility, entitlement or host-update approval. Verify HPE add-on/drivers, vCenter compatibility, host/workload backups, migration capacity and recovery before host maintenance. This is not permission to update other hosts or move workloads.
- Manual fallback on existing U3e is [Broadcom KB 423919](https://knowledge.broadcom.com/external/article/423919/manual-update-of-secure-boot-variables-i.html): backed-up powered-off VM, approved snapshot/recovery plan, temporary certificate disk, explicit temporary authentication-bypass approval, EFI enrollment of Microsoft's OEM Platform Key, removal of bypass/media and subsequent native Windows certificate servicing/verification. No blanket approval is assumed for those steps, and no NVRAM deletion or Secure Boot disablement is proposed. Prefer the supported automated path where compatible/available rather than choosing manual firmware enrollment first.
- VBS diagnosis is now corroborated directly by VM settings: VMware VBS unchecked, Expose hardware assisted virtualization unchecked and I/O MMU Enabled unchecked. Windows still has VBS status 1/configured services 1,2,3/running services 0 and requires hypervisor, Secure Boot and DMA. VM version 21 and EFI meet the documented broad VMware/AMD baseline; this is not proof that every driver/application is compatible. The read-only settings dialog was cancelled without saving.
- Refined VBS plan supersedes any assumption that a DMA-reducing GPO override is immediately necessary: after driver/recovery review and separately authorized graceful shutdown, enable VMware VBS and verify guest CPU virtualization/IOMMU exposure, then boot and test the existing Windows policy unchanged. [Broadcom KB 305078](https://knowledge.broadcom.com/external/article/305078/warning-message-when-you-enable-virtuali.html) documents the VBS checkbox enabling nested virtualization/IOMMU/EFI/Secure Boot; [KB 423079](https://knowledge.broadcom.com/external/article/423079/how-to-enable-memory-integrity-on-window.html) documents powered-off activation on an existing VM. Only consider a new Easyjob3-only policy if a remaining prerequisite is proven unsupported and separately approved; retain Default Domain Policy, NTLM blocking and the successful RPC-only GPO.
- Existing Credential Guard/HVCI UEFI-lock configuration increases rollback complexity and must be reviewed before activation. Microsoft warns HVCI can expose driver incompatibility/boot problems; [memory-integrity guidance](https://learn.microsoft.com/en-us/windows/security/hardware-security/enable-virtualization-based-protection-of-code-integrity) describes testing and recovery. Fresh Code Integrity 3033 samples at 21:48:46 show Panda PSANHost rejecting ESET eamsi.dll and VMware vsepamsi_x86.dll at antimalware protected-process signing levels. This is an endpoint coexistence/signing review item, **not proof that these DLLs are HVCI-incompatible kernel drivers**. No antivirus setting, exclusion, protection or driver was changed. Review vendor support and rollback readiness before enabling memory integrity in this production SQL/application VM.
- Initial time status at 21:48 reported leap 3/stratum 0 following the migrations, last sync 21:39:44. At 21:50:19 it had recovered natively: PDC source, leap 0/stratum 6, successful sync 21:50:05; three stripchart offsets -0.0038 to -0.0028 seconds. No resync, clock adjustment or time-service restart was requested. Do not treat that initial transient as a new machine-password failure or the removed provider returning.
- Proposed staged success criteria: after PK servicing, valid OEM PK/2023 KEK and Windows Updated/1808; after separate VBS activation, VBS status 2 and intended Credential Guard/HVCI services actually running, no repeating prerequisite failure, plus healthy trust, all SQL databases/core Easyjob services and operator application workflow. Snapshot/revert and UEFI-lock recovery must be understood before changing protection; do not rely only on being able to uncheck a VM setting remotely. This inspection made no server/VM policy, security, boot, snapshot, disk, migration or power change. Records updated; no commit/push requested and unrelated changes preserved.

## 2026-10-31 - Operator Manual Secure Boot PK Repair and Live Verification

- Peter reports completing backup/preflight, graceful shutdown and a powered-off
  snapshot, then downloaded VMX and NVRAM recovery files. Local inspection found
  the supplied files present/nonempty (approximately 4 KiB and 264 KiB). This is
  not an independent Veeam restore test or snapshot inventory verification.
- Following Broadcom KB 423919, Peter added a temporary 128-MB disk. His guest
  inventory identified original disk 0 as 150 GiB/GPT and new disk 1 as 128 MiB/RAW.
  Guided guarded initialization/formatting produced FAT32 KEYUPDATE at E:.
  Downloaded Microsoft's WindowsOEMDevicesPK.der through the vendor-referenced
  Microsoft URL; reported size 1531 bytes, Microsoft subject/issuer and expected
  thumbprint 3D8660C0CB2D57B189C3D7995572A552F75E48B5. BitLocker and management
  features are Available/not installed and manage-bde.exe is absent; no feature
  installation or encryption change was performed.
- Peter explicitly approved the temporary Easyjob3-only authentication bypass.
  Guided setting uefi.allowAuthBypass TRUE and Force EFI Setup, retaining Secure
  Boot enabled and leaving VBS/virtualization/IOMMU untouched. Screenshots identify
  Boot Manager, the KEYUPDATE partition and WindowsOEMDevicesPK.der selected for
  PK enrollment. Peter reports committing, powering off, removing the bypass and
  temporary disk from the VM (not deleting datastore files), clearing Force EFI
  Setup and starting normally. No KEK/DB/DBX deletion/reset or NVRAM deletion was
  instructed. Those vCenter cleanup settings remain operator-reported rather than
  independently verified by this SSH inspection. Recovery files/snapshot retained.
- Codex read-only verification at 22:41:15-22:41:54 over local and domain SSH:
  EASYJOB3 booted at 22:39:33. Confirm-SecureBootUEFI True. PK is now 1575 bytes
  rather than the prior 45-byte NULL placeholder, with CN=Windows OEM Devices PK,
  issuer Microsoft RSA Third Party PCA 2023 and matching thumbprint
  3D8660C0CB2D57B189C3D7995572A552F75E48B5. Manual PK repair is verified.
- Parsed EFI signature lists rather than relying on string matching: KEK still
  has only Microsoft Corporation KEK CA 2011. DB includes Windows UEFI CA 2023,
  Microsoft Option ROM UEFI CA 2023 and Microsoft UEFI CA 2023 alongside older
  Microsoft/VMware entries. No firmware variables were changed by these reads.
- Full certificate servicing is NOT yet verified: UEFICA2023Status InProgress,
  UEFICA2023Error/KEKLastUpdateError 2147942402 (0x80070002), error event 1803,
  Firmware_MissingKEKInPackage, AvailableUpdates unchanged at 16388 (0x4004).
  No matching sampled Secure Boot events since the latest boot. Native task
  Microsoft/Windows/PI/Secure-Boot-Update is Ready, last run 22:30:57/result 0,
  before the PK repair; historical 1801/1803 events therefore do not establish a
  new post-repair failure. Task result 0 alone does not establish servicing success.
  Next proposed step is a separately approved native task run and reinspection;
  no task was started, flag overwritten, firmware certificate enrolled or reboot
  performed by Codex in this verification.
- PDC secure channel True. Six production SQL engines and three core Easyjob
  services Running. Initial SQL metadata queries as the local admin were denied;
  domain SSH as FORMAT/Administrateur succeeded without permission changes and
  verified all 48 databases ONLINE: APSAL 5, CLOUDDEMAT 20, DATAGATE 5, EASYJOB6 5,
  PLANNINGPME 5, PNT 8. User-facing Easyjob workflow remains an operator check.
- Guest sees only original 150-GiB disk 0, confirming temporary disk detachment.
  VMware time-provider registration remains absent after this reboot. VBS remains
  configured/not running (status 1, running services 0); its activation is a
  separate change and was not performed. No host update, GPO/security relaxation,
  SQL service stop, snapshot removal or data cleanup was performed by Codex.
- Updated only Easyjob3 runbook/log, preserving other dirty work. No commit/push.
- References:
  https://knowledge.broadcom.com/external/article/423919/manual-update-of-secure-boot-variables-i.html
  https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/troubleshoot-windows-server-secure-boot-certificate-update-issues

## 2026-10-31 - Authorized Native Secure Boot Update Completed without Reboot

- Peter explicitly authorized running Secure-Boot-Update and checking again,
  with no reboot. Rechecked VPN route and authenticated domain SSH to EASYJOB3.
  Preflight at 22:44:14 confirmed boot 22:39:33, Secure Boot True, task Ready,
  SYSTEM principal and native COM action {5014B7C8-934E-4262-9816-887FA745A6C4}.
  AvailableUpdates was 0x4004, last run still 22:30:57/result 0.
- Invoked Start-ScheduledTask once at 22:44:30 for the existing task under
  Microsoft/Windows/PI; did not create/edit a task, overwrite registry flags,
  change GPO/security settings, manually write EFI variables or initiate reboot.
  Observed task metadata last-run timestamp 22:44:41. Initial result 267009
  (0x41301/running) was transient; fresh final read at 22:45:17 is Ready/result 0.
  No second manual launch occurred.
- Native Windows event 1043 at 22:44:38 states Secure Boot KEK update applied
  successfully. Event 1801 at 22:44:32 precedes that successful application;
  no later error or event 1808 was observed in the bounded sample. Registry now
  reports UEFICA2023Status Updated. UEFICA2023Error, UEFICA2023ErrorEvent,
  KEKLastUpdateError and KEKLastUpdateErrorReason are absent. Windows cleared
  AvailableUpdates from 16388 (0x4004) to 16384 (0x4000) itself.
- Independently parsed live EFI signature lists: PK remains the expected Windows
  OEM Devices PK, thumbprint 3D8660C0CB2D57B189C3D7995572A552F75E48B5. KEK now
  contains Microsoft Corporation KEK 2K CA 2023, thumbprint
  459AB6FB5E284D272D5E3E6ABC8ED663829D632B, alongside the retained 2011 entry.
  Secure Boot remains True. This verifies both manual PK repair and native KEK
  servicing completion, rather than relying on task exit alone. No 1808 claimed.
- Postchecks at 22:45:25: boot still 22:39:33; PDC secure channel True; Netlogon,
  VMware Tools and all three core Easyjob services Running. All 48 databases
  remain ONLINE across APSAL 5, CLOUDDEMAT 20, DATAGATE 5, EASYJOB6 5,
  PLANNINGPME 5 and PNT 8. C: has 14.05 GiB free. VBS still status 1 with running
  services 0; activation remains a separate planned change.
- One overlong encoded read-only postcheck was rejected by the Windows command
  line length limit before execution. Split the reads and verified normally;
  the update task was not retried and no files/tasks were created to work around it.
- Keep recovery files and snapshot until operator Easyjob workflow validation
  and separately authorized snapshot cleanup. Recheck after the next planned
  boot; none was initiated here. Temporary bypass removal remains the operator's
  report from the prior step, not a fresh independent vCenter configuration audit.
  This guest repair does not resolve missing host security patches.
- Updated only Easyjob3 records, preserving other dirty changes. No commit/push.
- Reference:
  https://support.microsoft.com/en-us/servicing/os/secure-boot/2025/09/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates

## 2026-10-31 - Operator Application Pass and Read-Only VBS Preflight

- Peter confirms Easyjob works after the Secure Boot repair and requests moving
  on to VBS. Began read-only preparation; no power, snapshot, GPO, driver, endpoint
  protection or VM configuration change was performed.
- Guest at 22:50:16 still booted 22:39:33, Secure Boot True and servicing Updated.
  DeviceGuard status 1/configured services 1,2,3/running 0; required properties
  1,2,3 versus available 2,4,5,6. Current policy remains EnableVBS 1,
  RequirePlatformSecurityFeatures 3, HVCI 1, LsaCfgFlags 1, HVCIMATRequired 1,
  ConfigureSystemGuardLaunch 1. No explicit Mandatory setting or current-loader
  hypervisorlaunchtype override was observed in the sampled registry/BCD.
- HVCI/Credential Guard UEFI-lock policy values make rollback more complex;
  preserve console/offline recovery and current firmware/configuration copies.
  A simple remote checkbox reversal is not a sufficient recovery promise.
- Current products: ESET Server Security 13.0.12007.0, Management Agent
  13.3.1192.0, VMware Tools 13.1.5.0 and WatchGuard/Panda agents/EDR components.
  Running kernel filters include ESET eamonm/ehdrv/epfw, Panda PSIN family,
  SQL RsFx0603, VMware vmci/vmxnet3/vsepflt. RsFx0603 file version is
  2019.0150.4249.71; inventory is not proof of HVCI compatibility. Seven-day
  bounded query for CI 3063/3065/3066/3087 returned no events. Repeated 3033
  concerns Panda PSANHost rejecting ESET eamsi.dll and VMware vsepamsi_x86.dll
  at protected-process signing level, not demonstrated HVCI driver failure.
  No comprehensive vendor certification or isolated test activation completed.
- Authenticated vCenter read-only inspection shows Easyjob3 Powered On on .203,
  VM version 21, six vCPU/16 GiB and only original 150-GB disk. VM Options shows
  VBS unchecked/disabled while powered on, EFI/Secure Boot enabled, Force EFI
  Setup unchecked. Complete displayed Advanced Parameters inventory contains no
  uefi.allowAuthBypass entry, independently corroborating operator cleanup.
  Cancelled settings without saving. Current snapshot count 1, Before Secure
  Boot repair at 22:18; displayed snapshot disk-used figure is 144.38 GB and is
  not treated as a measured delta growth rate. Datastores view shows MSA_PERFHDD
  Normal, 3.51 TB free of 19.15 TB.
- Next operator steps: close clients/graceful shutdown, fresh powered-off
  Before VBS snapshot after the successful key repair, and separate current
  VMX/NVRAM recovery files (retain original pre-repair files). Then enable only
  VM VBS/required virtualization/IOMMU under scoped approval, initially leaving
  current Windows policy unchanged. Retest actual VBS service status, kernel
  errors, trust, SQL and application workflow before releasing maintenance.
  Existing pre-key-repair snapshot must not be described as preserving the new
  PK/KEK state. No snapshot deletion or new snapshot was executed by Codex.
- References:
  https://knowledge.broadcom.com/external/article/423079/how-to-enable-memory-integrity-on-window.html
  https://learn.microsoft.com/en-us/windows/security/hardware-security/enable-virtualization-based-protection-of-code-integrity

## 2026-10-31 - Saved VM VBS Settings Verified while Powered Off

- Peter completed the guided graceful shutdown and new recovery checkpoint.
  Authenticated vCenter task history shows guest-shutdown initiation at 22:54:18
  and snapshot creation completed at 22:55:03. Snapshot management independently
  confirms Before VBS - Secure Boot repaired, timestamp 22:55, memory No and
  quiesce No; the original Before Secure Boot repair snapshot remains. Downloaded
  step 2 VMX/NVRAM copies are present/nonempty, timestamp 22:56, approximately
  4.2 KiB/264 KiB. Sampled VMX is EFI, hardware 21, Secure Boot TRUE, no bypass
  entry, and original disk points to Easyjob3-000002.vmdk. These files belong to
  the active snapshot chain and must not be restored blindly over later changes.
- Peter then reports enabling/saving VM VBS while leaving Easyjob3 powered off,
  and requests independent verification. Read-only authenticated vCenter at
  approximately 22:58-22:59 confirms Powered Off, host .203, six vCPU/16 GiB,
  original 150-GB disk, two snapshots, no configured security device. Summary
  now advertises Virtualization Based Security - Enable.
- Reopened settings to verify saved values rather than an unsaved checkbox:
  VM Options VBS checked; CPU Expose hardware assisted virtualization checked;
  I/O MMU Enabled checked. Virtualization/IOMMU controls are locked on by VBS.
  Firmware EFI and Secure Boot Enabled remain selected; Force EFI Setup is
  unchecked. Network adapter remains VMXNET 3 with Connect At Power On checked;
  powered-off Summary's disconnected wording is not evidence that startup
  connectivity was disabled. No hardware or setting was changed by Codex.
- Cancelled settings without saving and confirmed the VM remains Powered Off.
  No power-on, reboot, snapshot operation, GPO, registry, endpoint protection or
  driver change was performed by Codex. This is configured-state verification,
  not proof of Windows VBS/HVCI/Credential Guard runtime activation.
- Pending: operator startup with console/recovery available and clients held
  out, then DeviceGuard running status/services, Secure Boot/Updated status,
  fresh kernel/CI/policy events, SQL/database availability, PDC trust and Easyjob
  workflow. Preserve both snapshots/recovery copies until validation and explicit
  cleanup authorization. Existing UEFI-lock policy cautions still apply.
- Updated only Easyjob3 documentation; no commit/push requested.

## 2026-10-31 - First VBS Startup Verified, HVCI Still Pending

- Peter reports normal startup after saving VBS and requests live verification.
  Domain SSH checks at 23:02:03-23:03:21 confirm boot 23:01:04. No configuration,
  policy, driver, service, snapshot, update-task or power action was performed.
- VBS now status 2/running. SecurityServicesConfigured 1,2,3 but Running only 1:
  Credential Guard active, memory integrity/HVCI and System Guard Secure Launch
  not reported active. CodeIntegrityPolicyEnforcementStatus 2 is ordinary policy
  enforcement and must not be misrepresented as evidence that HVCI is running.
  AvailableSecurityProperties 1,2,3,4,5,6,7 satisfy required 1,2,3 and include
  MBEC/GMET. Hypervisor event 1 confirms successful start; event 129 confirms
  hardware I/O remapping present/enabled, Problems 0. Wininit 13 confirms
  Credential Guard started and event 18 confirms VBS key isolation started.
- DeviceGuard 7000 at 23:01:19: policy successfully processed, VBS/secure boot/
  DMA/code integrity/Credential Guard Enabled, status 0, Reboot required No.
  Prior prerequisite handler failure is absent; no post-boot GroupPolicy 1085
  in the bounded query. HVCI runtime key now exists with Enabled 1/Locked 1;
  this key was absent before first successful policy processing. Boot event 153
  describes VBS/VSM/Measured Launch without an HVCI flag. This suggests a second
  normal boot is a reasonable next activation test, but is not proof that a
  reboot alone will resolve HVCI. No reboot initiated or additional approval
  assumed. Secure Launch is separately configured/not running; no claim that
  this VM supports every secured-core hardware feature.
- A new SCM 7023 at 23:01:13 reports HvHost failed with A device attached to the
  system is not functioning. Service is Stopped/Manual. This is unresolved but
  does not mean the hypervisor or Credential Guard failed; direct success
  events/WMI prove those running. No forced service start or feature install.
- All 48 SQL databases ONLINE across APSAL 5, CLOUDDEMAT 20, DATAGATE 5, EASYJOB6
  5, PLANNINGPME 5, PNT 8. Three core Easyjob services, SSH, VMware Tools,
  Netlogon and W32Time Running; unused optional Easyjob services remain outside
  the required-health set. C: free 14.63 GiB; free physical memory 11.67 GiB.
  No critical/error Application events in the bounded post-boot query. New
  user-facing Easyjob workflow under VBS is still an operator test.
- PDC secure channel True and nltest PDC status 0. One Netlogon 5719 at 23:01:17
  precedes successful current tests. RPC EnableAuthEpResolution 0 and incoming
  NTLM block 2 persist. WinRM Stopped/Disabled remains intentional. Windows time
  synchronized to BDC, leap 0/stratum 7, successful sync 23:01:39. Removed VMware
  time-provider registration remains absent after this additional startup.
- Secure Boot True; UEFICA2023Status Updated; sampled previous error fields
  absent. Successful PK/KEK repair survived VBS activation. No boot-key or
  certificate update was performed by this read-only check.
- Bounded CI events are dominated by existing 3033 protected-process signing
  messages and associated 3089 information. Separately filtered 3063/3065/3066/
  3074/3076/3077/3084/3085/3086/3087/3099/3111 found only successful 3099 policy
  activations and 3084 WHQL enforcement information. No specific HVCI-incompatible
  driver was identified. Existing PSINFile/RsFx0603 bypass-IO warnings persist,
  plus a DCOM 10016. Do not equate these with a proven HVCI blocker or declare
  the server warning-free. Driver/endpoint coexistence review remains separate.
- Next: save/close clients and arrange a separately approved normal reboot,
  then recheck actual HVCI/Credential Guard/Secure Launch status, HvHost error,
  SQL/trust/Secure Boot and operator application workflow. Preserve existing
  GPO/UEFI-lock settings and both snapshots/recovery files; no cleanup yet.
- Updated only Easyjob3 records; git diff --check passes; no commit/push.
- WMI interpretation reference:
  https://learn.microsoft.com/en-us/windows/security/hardware-security/enable-virtualization-based-protection-of-code-integrity

## 2026-10-31 - Second VBS Boot: Memory Integrity and Credential Guard Running

- Peter reports the additional normal reboot and requests verification. Read-only
  domain SSH at 23:07:07-23:07:21 confirms EASYJOB3 boot 23:05:44. Codex did not
  reboot, start/stop services, change GPO/registry/firmware/VM settings, install
  drivers or change endpoint protection in this verification.
- DeviceGuard VirtualizationBasedSecurityStatus 2; SecurityServicesRunning 1,2
  verifies Credential Guard AND memory integrity/HVCI running. Configured 1,2,3;
  service 3/System Guard Secure Launch remains configured/not running and is not
  conflated with HVCI success. Available properties 1..7, required 1,2,3.
  DeviceGuard 7000 records policy success/status 0, no reboot required. The
  previous first-boot HVCI-pending result is superseded, not retroactively changed.
- HvHost is now Running/Manual, with no new matching SCM failure in the bounded
  post-boot System sample. First-boot HvHost device error did not recur in that
  sample. No specifically queried kernel CI blocking events 3063/3065/3066/3074/
  3076/3077/3087/3111 were found since boot. This is observed startup health, not
  exhaustive driver certification or a guarantee of future stability.
- All 48 databases ONLINE across six production instances: APSAL 5, CLOUDDEMAT
  20, DATAGATE 5, EASYJOB6 5, PLANNINGPME 5, PNT 8. Three core Easyjob services,
  SSH, VMware Tools, Netlogon and W32Time Running. No Application critical/error
  events in the bounded sample. C: free 14.65 GiB; free physical memory 11.65 GiB.
  Operator should repeat project/report workflow now HVCI is actually active;
  previous application pass was before this activation.
- PDC Test-ComputerSecureChannel True; nltest selected BDC/status 0. RPC override
  remains 0 and incoming NTLM block 2. WinRM remains Stopped/Disabled by design.
  Time synchronized to BDC, leap 0/stratum 7, last successful sync 23:06:34.
- Secure Boot True; UEFICA2023Status Updated and sampled old error fields absent.
  No further key update, native task run or firmware bypass was needed.
- Residual findings: Kerberos event 9 at 23:06:18 says the PDC certificate's
  revocation check failed because its revocation server was offline/unreachable.
  Netlogon 5719 at 23:06:19 precedes current successful PDC and BDC trust checks.
  Do not call this a current broken trust relationship or claim CRL health is
  verified. Investigate distribution-point reachability/recurrence separately;
  do not disable certificate revocation checking to hide it.
- Existing PSINFile/RsFx0603 bypass-IO warnings, DCOM 10016 and Panda PSANHost
  3033 signing rejections of ESET/VMware AMSI DLLs persist. These are not cleared
  by VBS and are not proof that HVCI failed; actual service 2 is running.
- VBS/Credential Guard/HVCI and Secure Boot repair objectives are now verified
  at OS level without an ESXi upgrade. Keep both recovery snapshots/files pending
  operator workflow test and separately authorized cleanup. Host patches and
  System Guard Secure Launch are separate unresolved scope, not implicitly fixed.
- Updated only Easyjob3 runbook/log; other dirty work preserved. No commit/push.

## 2026-10-31 - Snapshot Cleanup Preflight, Final Confirmation Pending

- Peter confirms Easyjob works with HVCI active and requests removal of both
  maintenance snapshots. Authenticated vCenter confirms exactly Before Secure
  Boot repair and Before VBS - Secure Boot repaired on Easyjob3; current VM is
  Powered On. MSA_PERFHDD Normal, 3.52 TB free of 19.15 TB. Sampled recent tasks
  show no active Easyjob3 operation; latest reboot task is Completed.
- Read-only SSH attempt to known Veeam 192.168.90.10 timed out despite the VPN
  route. This does not prove the backup server is down or idle. Peter explicitly
  confirms no active backup, replication or restore work involving Easyjob3.
  No Veeam job/service/repository or network setting was changed.
- Opened vCenter's Delete all snapshots confirmation without submitting it.
  Explained irreversible loss of both rollback points, preservation of current
  VM data/settings and possible short consolidation pause; requested final
  action-time confirmation. No snapshot removal, revert, consolidation, VM
  power action or datastore-file deletion has occurred in this preflight.
  Retain recovery files and leave the confirmation pending until Peter responds.

## 2026-10-31 - Both Maintenance Snapshots Removed and Consolidation Verified

- Peter confirmed no active Veeam backup/replication/restore involving Easyjob3,
  then explicitly answered Confirm removal of both snapshots to the final
  irreversible-action confirmation. The approved targets were Before Secure
  Boot repair and Before VBS - Secure Boot repaired; no other VM or snapshot was
  included. Prior preflight recorded healthy datastore with 3.52 TB free.
- Rechecked current Easyjob3 page and the two exact target names in the pending
  vCenter dialog. Submitted Delete All once. Remove all snapshots ran from
  23:17:03 to 23:17:34 and completed SUCCESS. Observed 11%, then 99%, then
  Completed; no cancellation or competing snapshot/power action occurred.
- Snapshot Management now says No snapshot available, with Revert/Delete/Delete
  All disabled. Read-only expanded Hard disk 1 confirms the active 150-GB thin,
  dependent NVME(0:0) backing is [MSA_PERFHDD] Easyjob3/Easyjob3.vmdk, rather
  than Easyjob3-000002.vmdk. This corroborates completed consolidation rather
  than only an empty snapshot tree. Cancelled settings without saving.
- Live guest checks during consolidation at 23:17:24 and after completion at
  23:18:14 both pass. Boot unchanged at 23:05:44; no reboot occurred. VBS status
  2 and services 1,2 confirm Credential Guard/HVCI still running. Secure Boot
  True; UEFICA2023Status Updated/error absent. PDC secure channel True. Required
  Easyjob Server/Task Scheduler/WebApi, HvHost and VMware Tools remain Running.
- All 48 databases ONLINE after completion: APSAL 5, CLOUDDEMAT 20, DATAGATE 5,
  EASYJOB6 5, PLANNINGPME 5, PNT 8. No critical/error System or Application events
  since 23:17:03 in the bounded postcheck. User-facing Easyjob workflow had
  already passed with HVCI before removal; no authenticated application workflow
  was independently performed by Codex afterward.
- Current VM data/settings were consolidated, not reverted. No SQL data, backup
  files, unused temporary-disk files, VMX/NVRAM downloads or other datastore files
  were manually deleted. Historical recovery downloads remain, but their VMX
  files reference removed snapshot chains and must not be blindly restored.
  Both snapshot rollback points are permanently removed, not retained backups.
- Completion screenshot retained locally outside Git. Only Easyjob3 runbook/log
  updated; unrelated dirty changes preserved. No commit/push requested. Existing
  PDC certificate-revocation/signing/bypass-IO warnings and inactive System Guard
  Secure Launch remain separate follow-ups, not changed by snapshot removal.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Secure channel checked:
- `sshd` checked:
- `WinRM` checked:
- Application role checked:
- Print service checked:
- Disk space checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
