# TIM Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-tim` and `winad-tim` both returned `Tim`.
- Secure channel checked: healthy; domain `format.lu`.
- OS checked: Microsoft Windows 11 Pro for Workstations `10.0.26200`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM TCP checked: `192.168.1.12:5985` reachable after restore.
- Disk space checked: C: 12.3 GB free of 64.2 GB.
- Pending reboot checked: `Component Based Servicing\RebootPending` present.
- Recent updates checked: latest installed hotfixes included `KB5088467` and `KB5083769` on 2026-04-18.
- File cleanup performed: deleted 273 files older than 30 days from `C:\Windows\Temp`, about 22.9 MB. Post-cleanup `C:\Windows\Temp` measured about 66.2 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No application data, user data, GPO, firewall rule, or snapshot/reboot action was changed.

Follow-up:

- C: free space is low; inspect non-user cleanup candidates before installing more updates.
- Schedule/confirm a reboot window if the pending Windows reboot is expected after the 2026-04-18 updates.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on TIM using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 4 visible updates successfully: Windows Security platform KB5007651, Windows Malicious Software Removal Tool KB890830, .NET Framework security update KB5082417, and Windows security update KB5083769.
- Task log: `C:\ProgramData\Codex\windows-update-Tim-20260418-220849.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 10.7 GB.
- Post-install visible update scan still listed KB5007651, KB5082417, and KB5083769 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending and Windows Update reboot required; `PendingFileRenameOperations` was not present.
- Reboot performed: No.

Notes:

- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No application data, user data, GPO, firewall rule, snapshot, or reboot action was changed.

Follow-up:

- Reboot TIM in an agreed workstation maintenance window, then re-run Windows Update scan.
- C: free space is now low after update staging; inspect cleanup candidates after reboot finalizes component servicing.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Secure channel checked:
- `sshd` checked:
- `WinRM` checked:
- Role verified:
- Disk space checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
