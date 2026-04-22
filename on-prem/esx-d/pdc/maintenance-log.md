# PDC Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-pdc` and `winad-pdc` both returned `PDC`.
- Domain controller services checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, and `Netlogon` running.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM listener checked: GPO HTTP listener on `5985`, listening on `127.0.0.1`, `192.168.1.5`, `::1`, and link-local IPv6.
- WinRM TCP checked from Mac: `192.168.1.5:5985` still timed out even though the service and listener are running and the `Allow remote Admin - WinRM 5985` firewall rule is enabled/scoped to `192.168.1.73,192.168.113.2`.
- Replication checked: `repadmin /replsummary` showed 0 failures for BDC source and PDC destination, largest delta about 38 minutes.
- `dcdiag /q` checked: failed test `Replications` because `DsBindWithSpnEx()` to BDC returned access denied.
- Time service checked: stratum 3, source `192.168.1.253,0x8`, last successful sync 2026-04-18 20:30:13.
- Disk space checked: C: 67 GB free of 89.4 GB.
- Pending reboot checked: `PendingFileRenameOperations` present.
- Recent updates checked: latest installed hotfixes included `KB5078763` and `KB5078766` on 2026-03-16.
- File cleanup performed: deleted 2 files older than 30 days from `C:\Windows\Temp`, about 0.2 MB. Post-cleanup `C:\Windows\Temp` measured about 1.3 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No DNS, SYSVOL, GPO, firewall rule, FSMO, replication, or snapshot/reboot action was changed.

Follow-up:

- Investigate why remote TCP/5985 to PDC times out despite WinRM service/listener/firewall rule appearing correct.
- Re-run `dcdiag` with a credential/context that can bind to BDC, or verify BDC-side permissions/connectivity.
- Plan reboot/update work carefully because this DC has a pending reboot indicator.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on PDC using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 3 visible updates successfully: Windows Malicious Software Removal Tool KB890830, .NET cumulative update KB5084071, and OS cumulative update KB5082142.
- Task log: `C:\ProgramData\Codex\windows-update-PDC-20260418-220831.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 63.7 GB.
- Post-install visible update scan still listed KB5082142 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending, Windows Update reboot required, and `PendingFileRenameOperations`.
- Reboot performed: No.

Notes:

- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No DNS, SYSVOL, GPO, firewall rule, FSMO, replication, snapshot, or reboot action was changed.

Follow-up:

- Reboot PDC only in a planned DC maintenance window, then re-run replication, SYSVOL/DFSR, DNS, time, and Windows Update checks.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Domain controller health checked:
- DNS checked:
- Replication checked:
- SYSVOL/DFSR checked:
- Time service checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
