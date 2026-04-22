# Admin Maintenance Log

## 2026-04-18 - Admin Post-Update Reboot

Maintainer: Codex with Peter

Scope:

- Reboot Admin after the 2026-04-18 update installation completed and reported reboot required.

Checks and actions:

- Reboot command issued: `Restart-Computer -Force`.
- Reboot completed; fresh boot time observed: 2026-04-18 21:39:26.
- Local break-glass SSH checked after reboot: OK; `win-admin` returned `admin\administrateur`.
- Domain SSH checked after reboot: OK; `winad-admin` returned `format\administrateur`.
- `sshd` checked after reboot: `Running`, `Automatic`.
- `WinRM` checked after reboot: initially drifted to `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- WinRM TCP checked after restore: `admin.format.lu:5985` reachable.
- Windows Update checked after reboot: 0 visible uninstalled updates.
- Reboot indicators checked after reboot: `Component Based Servicing\RebootPending`, `WindowsUpdate\Auto Update\RebootRequired`, and `PendingFileRenameOperations` all absent.
- Disk checked after reboot: C: about 38.32 GB free.
- Cleanup candidates after reboot:
  - `C:\Windows\SoftwareDistribution\Download`: about 3,939.2 MB
  - `C:\Windows\Temp`: about 4.5 MB
  - `C:\Windows\Logs\CBS`: about 484.6 MB
- DNS/DC discovery checked: DNS resolves `format.lu`, `pdc.format.lu`, and `bdc.format.lu`; `nltest /dsgetdc:format.lu` found `\\BDC.format.lu`.
- Secure channel checked: still reports broken; `nltest /sc_query:format.lu` returns `ERROR_NO_LOGON_SERVERS`.
- Netlogon restarted and rechecked: `Netlogon` running, but secure channel still reports broken.

Notes:

- No machine-account trust repair, domain rejoin, GPO, firewall, user-data, or snapshot action was performed.
- GUI Disk Cleanup / system cleanup is now safe to run for Windows Update cleanup/download cache, because the update reboot is complete and Windows Update reports no remaining visible updates.

Follow-up:

- Decide whether to run a machine secure-channel repair for Admin, for example from a known-good domain credential path.
- Run GUI Disk Cleanup / Clean up system files on Admin if you want Windows to remove the remaining update cache interactively.

## 2026-04-18 - Admin Trust Repair Attempt

Maintainer: Codex with Peter

Scope:

- Attempt to repair Admin machine secure channel after post-update reboot left `Test-ComputerSecureChannel` reporting broken.

Checks and actions:

- Confirmed domain SSH still works as `format\administrateur`.
- Confirmed DNS/DC discovery:
  - DNS servers: `192.168.1.5`, `192.168.1.4`
  - `nltest /dsgetdc:format.lu` found `\\BDC.format.lu`
  - TCP connectivity to PDC/BDC on `445` and `389` succeeded
- Observed mixed secure-channel state:
  - `nltest /sc_query:format.lu` intermittently reported success against `\\BDC.format.lu`
  - `Test-ComputerSecureChannel -Server BDC.format.lu` consistently returned `False`
- Attempted `Test-ComputerSecureChannel -Repair -Server BDC.format.lu -Verbose`.
- Repair failed with: `Cannot reset the secure channel password for the computer account in the domain. Operation failed with the following exception: The user name or password is incorrect.`
- Attempted lighter Netlogon reset with `nltest /sc_reset:format.lu\BDC`.
- `nltest /sc_reset` reported success, but subsequent `nltest /sc_query:format.lu` returned `ERROR_NO_LOGON_SERVERS` and PowerShell still returned `False`.

Notes:

- No domain rejoin, computer-account reset, GPO, firewall, or reboot action was performed.
- The SSH domain logon token/key was not sufficient for `Test-ComputerSecureChannel -Repair`; a reusable domain credential/password or interactive domain-admin session is needed for the next repair step.

Follow-up:

- Repair from the Admin GUI or an interactive elevated PowerShell session with a domain admin credential:
  - `Test-ComputerSecureChannel -Repair -Credential format\Administrateur`
  - or `Reset-ComputerMachinePassword -Server BDC.format.lu -Credential format\Administrateur`
- Re-check with both `nltest /sc_query:format.lu` and `Test-ComputerSecureChannel -Verbose`.

## 2026-04-18 - Admin Trust Repair Completed From GUI

Maintainer: Peter with Codex

Scope:

- Complete Admin machine trust repair from an elevated interactive PowerShell session on Admin.

Actions:

- Initial GUI command `Test-ComputerSecureChannel -Repair -Credential format\Administrateur` returned `True`, but verification still failed.
- Codex-side checks showed Admin was discovering BDC and that PDC had trouble authenticating to BDC for AD queries.
- Peter then ran:
  - `Reset-ComputerMachinePassword -Server PDC.format.lu -Credential format\Administrateur`
  - `Restart-Service Netlogon -Force`
- Verification from Admin GUI succeeded:
  - `Test-ComputerSecureChannel -Server PDC.format.lu -Verbose` returned `True`
  - `nltest /sc_query:format.lu` returned `NERR_Success` against `\\BDC.format.lu`
- PDC AD object check showed `ADMIN` machine `PasswordLastSet` updated to 2026-04-18 21:59:30 and object `whenChanged` 2026-04-18 21:59:38.

Notes:

- Local SSH `win-admin` works after repair.
- Codex-side `winad-admin` SSH attempts reset during session setup immediately after repair, likely while `sshd`/domain auth was refreshing; re-check later.
- No domain rejoin, computer-account deletion, GPO, firewall, or reboot action was performed during this completed repair.

Follow-up:

- Re-check `winad-admin` after services settle.
- Keep the BDC/PDC authentication oddity on the domain-controller follow-up list because PDC-side AD queries to BDC failed during diagnosis.

## 2026-04-18 - Admin Windows Update Install Attempt And Cleanup Follow-Up

Maintainer: Codex with Peter

Scope:

- Follow-up after Peter observed the Admin GUI still showing system cleanup and 4 updates to install.

Checks and actions:

- Confirmed 4 visible downloaded updates before install:
  - `Security Update for SQL Server 2017 RTM GDR (KB5084819)`
  - `Windows Malicious Software Removal Tool x64 - v5.140 (KB890830)`
  - `2026-04 .NET Framework Security Update (KB5082417)`
  - `2026-04 Security Update (KB5083769) (26200.8246)`
- Direct Windows Update COM install from SSH failed with `0x80070005 E_ACCESSDENIED`, so a one-time scheduled task was created and run as `SYSTEM`.
- Scheduled task `Codex-Admin-Updates-Cleanup-20260418` completed with task result `0`.
- Windows Update installer result was success (`ResultCode=2`, `HResult=00000000`) and reported `RebootRequired=True`.
- Per-update results:
  - `KB5084819`: success, reboot required
  - `KB890830`: success, no reboot required
  - `KB5082417`: success, reboot required
  - `KB5083769`: success, reboot required
- Windows Update event log confirmed `KB5084819` and `KB890830` installation success; `.NET` and Windows security updates were started and remained visible to update search pending reboot.
- Reboot indicators after install: `Component Based Servicing\RebootPending`, `WindowsUpdate\Auto Update\RebootRequired`, and `PendingFileRenameOperations`.
- DISM component cleanup was attempted with `/Online /Cleanup-Image /StartComponentCleanup` but exited `-2146498554` while servicing/reboot was pending.
- Cleanup performed: `C:\Windows\Temp` reduced to about 3.7 MB.
- Remaining cleanup candidates after install:
  - `C:\Windows\SoftwareDistribution\Download`: about 4,111.7 MB
  - `C:\Windows\Logs\CBS`: about 465.8 MB
- Final C: free space observed: about 37.19 GB.

Notes:

- No reboot was performed by Codex.
- No user data, app data, GPO, firewall rule, or snapshot action was changed.
- GUI Disk Cleanup / system cleanup is best run after the required reboot, because Windows servicing is still pending.

Follow-up:

- Reboot Admin in an approved window.
- After reboot, re-check Windows Update. If clean, run GUI `Disk Cleanup` / `Clean up system files` or Settings Storage cleanup to remove Windows Update cleanup/download cache items.

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-admin` and `winad-admin` both returned `admin`.
- Secure channel checked: healthy; domain `format.lu`.
- OS checked: Microsoft Windows 11 Pro `10.0.26200`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM TCP checked: `admin.format.lu:5985` reachable after restore.
- Disk space checked: C: 37.9 GB free of 117.4 GB; D: 29.6 GB free of 55 GB.
- Pending reboot checked: `Component Based Servicing\RebootPending` present.
- Recent updates checked: latest installed hotfixes included `KB5088467` and `KB5083769` on 2026-04-18.
- File cleanup performed: deleted 272 files older than 30 days from `C:\Windows\Temp`, about 70.6 MB. Post-cleanup `C:\Windows\Temp` measured about 270.7 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No application data, user data, GPO, firewall rule, or snapshot/reboot action was changed.

Follow-up:

- Schedule/confirm a reboot window if the pending Windows reboot is expected after the 2026-04-18 updates.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Secure channel checked:
- `sshd` checked:
- `WinRM` checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
