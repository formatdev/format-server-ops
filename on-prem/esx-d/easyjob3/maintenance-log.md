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
