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
