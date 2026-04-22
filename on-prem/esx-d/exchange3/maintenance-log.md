# EXCHANGE3 Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-exchange3` and `winad-exchange3` both returned `Exchange3`.
- Secure channel checked: healthy; domain `format.lu`.
- OS checked: Microsoft Windows Server 2022 Standard `10.0.20348`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM TCP checked: `192.168.1.6:5985` reachable after restore.
- Disk space checked: C: 52.2 GB free before cleanup and 54.2 GB free after cleanup; E: 85.4 GB free of 350 GB.
- Pending reboot checked: `PendingFileRenameOperations` present.
- Recent updates checked: latest installed hotfixes included `KB5078766` and `KB5078763` on 2026-03-16.
- Exchange services checked: all `MSExchange*` services were running except `MSExchangePop3` and `MSExchangePOP3BE`, both `Stopped`/`Manual`.
- Transport queues checked: attempted `Get-Queue`, but Exchange cmdlet failed with AD credential error for `FORMAT\Administrateur` in the SSH PowerShell session.
- Certificates checked: attempted `Get-ExchangeCertificate`, but Exchange cmdlet failed with the same AD credential error.
- File cleanup performed: deleted 2,427 files older than 30 days from `C:\Windows\Temp`, about 2,038.5 MB. Post-cleanup `C:\Windows\Temp` measured about 69.7 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No Exchange services were restarted.
- No mail data, queue data, certificates, GPO, firewall rule, or snapshot/reboot action was changed.

Follow-up:

- Run Exchange Management Shell health checks from an interactive session or known-good credential path: queue health, certificate expiry, component state, and event logs.
- Plan update/reboot work carefully because this host has a pending reboot indicator.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on EXCHANGE3 using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 3 visible updates successfully: Windows Malicious Software Removal Tool KB890830, .NET cumulative update KB5084071, and OS cumulative update KB5082142.
- Task log: `C:\ProgramData\Codex\windows-update-Exchange3-20260418-220816.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 51.0 GB.
- Post-install visible update scan still listed KB5082142 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending, Windows Update reboot required, and `PendingFileRenameOperations`.
- Reboot performed: No.

Notes:

- No Exchange services were restarted.
- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No mail data, queue data, certificates, GPO, firewall rule, snapshot, or reboot action was changed.

Follow-up:

- Reboot EXCHANGE3 in an agreed Exchange maintenance window, then re-run Windows Update scan and Exchange Management Shell health checks.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Secure channel checked:
- `sshd` checked:
- `WinRM` checked:
- Exchange services checked:
- Transport queues checked:
- Certificates checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
