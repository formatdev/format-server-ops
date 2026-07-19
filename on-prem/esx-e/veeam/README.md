# Veeam Runbook

Runbook for the standalone Windows Veeam server VM on ESX-E.

Last updated: 2026-07-19

## Known State

- VM name in VMware inventory: `Veeam`
- IP: `192.168.90.10`
- Windows hostname: `veeam`
- Domain membership: standalone `WORKGROUP`; not joined to `format.lu`
- SSH alias: `win-veeam` points to `192.168.90.10` as local `Administrator`
- Expected domain SSH alias: none
- Role: Veeam backup server
- OS: Microsoft Windows Server 2022 Standard, build `20348`
- VM platform: VMware virtual machine
- Last boot observed during mid-July maintenance: `2026-06-17 21:51:44`

## Critical Role Notes

This server is backup infrastructure. Treat it as high-risk operationally even if it is a single VM.

- Do not reboot during active backup, restore, copy, replication, or maintenance sessions.
- Do not change repositories, credentials, encryption settings, license settings, or retention policy without explicit approval.
- Do not delete backup files or repository data from Windows Explorer, PowerShell, or storage tools unless following a reviewed Veeam cleanup plan.
- Confirm backup job state and recent restore-point health before maintenance that could affect availability.

## Standalone Remote Admin Baseline

Because this server is not domain-joined, the remote-admin model should be local-only.

- Preserve any working local break-glass SSH access.
- Do not configure `format\sshadmins`, `winad-veeam`, or domain GPO-based access unless the server is intentionally joined later.
- Local admin observed during first discovery: `veeam\administrator`
- Prefer key-only SSH:
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`
  - `PermitEmptyPasswords no`
  - `AllowGroups administrators` or a verified local SSH admin group
- `sshd` should be `Automatic` and `Running` if SSH is intended.
- `WinRM` should be `Automatic` and `Running` only if it is intentionally used for this standalone server.
- Any inbound SSH `22` and WinRM `5985` firewall rules should be scoped to trusted admin sources:
  - `192.168.1.73`
  - `192.168.113.2`

## First Checks

From the Mac:

```sh
nc -vz 192.168.90.10 22
nc -vz 192.168.90.10 5985
nc -vz 192.168.90.10 10001
```

As of 2026-04-18, SSH on `22`, WinRM HTTP `5985`, and Veeam transport/data mover port `10001` were reachable from the maintainer Mac. OpenSSH Server was installed by the operator during first maintenance. Password SSH worked for the operator, but key-only SSH still failed from the Mac and needs `administrators_authorized_keys`/`sshd_config`/permissions verification before routine maintenance use.

Later on 2026-04-18, key-only SSH was verified from the Mac with `ssh -o BatchMode=yes win-veeam hostname` and `ssh -o BatchMode=yes win-veeam whoami`.

Current remote-admin findings:

- `sshd`: `Automatic`, `Running`
- `WinRM`: `Automatic`, `Running`
- WinRM HTTP listener: `5985`, listening on `127.0.0.1`, `192.168.90.10`, `::1`, and link-local IPv6
- `administrators_authorized_keys`: one `windows-admin` key, ACL limited to `SYSTEM` and local `Administrators`
- `sshd_config`: `PubkeyAuthentication yes`, `PasswordAuthentication no`, `PermitEmptyPasswords no`, administrator match block uses `__PROGRAMDATA__/ssh/administrators_authorized_keys`
- Firewall: default `OpenSSH SSH Server (sshd)` rule disabled; custom `Allow remote Admin - SSH 22` rule enabled and scoped to `192.168.1.73,192.168.113.2`
- `sshd.exe` WER dumps configured under `C:\ProgramData\ssh\dumps` with `DumpCount=10`, `DumpType=2`

Current storage findings:

- `C:` NTFS, healthy, about 51.6 GB free of 128.5 GB during 2026-07-19 maintenance
- `E:` `VeeamHDD`, ReFS, healthy, about 1.40 TB free of 30.8 TB during 2026-07-19 maintenance

Current Windows Update findings:

- April 2026 Windows/.NET/SQL updates installed on `2026-04-18`.
- May 2026 update cycle completed on `2026-05-16`: `KB5089270`, `KB890830` v5.141, `KB5088862`, and `KB5087545`.
- CBS, Windows Update reboot flags, and pending file rename operations were all clear after the May 2026 reboot.
- End-of-month check on `2026-05-31` found no new pending updates; CBS and Windows Update reboot flags remained clear, but `PendingFileRenameOperations` had reappeared.
- A later operator-approved reboot on `2026-05-31` cleared `PendingFileRenameOperations` again without introducing new CBS or Windows Update reboot flags.
- Mid-June check on `2026-06-14` found no pending Windows updates, no CBS/Windows Update reboot flags, and `PendingFileRenameOperations=True` again after a same-day reboot; the current queue sampled only `C:\Program Files (x86)\Microsoft\EdgeUpdate\1.3.239.19`.
- Early-July check on `2026-07-04` again found `0` pending Windows updates and no CBS/Windows Update reboot flags; `PendingFileRenameOperations` remained present but was now sampled as one `EdgeUpdate` path plus four `C:\Config.Msi\*.rbf` entries and two `C:\WINDOWS\Temp\DEL*.tmp` entries.
- Mid-July check on `2026-07-19` found `5` pending updates with no current CBS/Windows Update reboot flag: `PowerShell LTS v7.4.17 (x64)`, SQL Server 2016 SP3 CU security update `KB5102339`, `KB890830` v5.143, `.NET` cumulative update `KB5102206`, and Windows Server cumulative update `KB5099540`.
- SQL Server instance `.\VEEAMSQL2016` reported `13.0.7085.1`, `SP3`, `CU1`.
- Veeam Backup & Replication service executable now reports version `13.0.2.29`, indicating the later Veeam upgrade completed.
- Veeam services returned to `Running` after the normal post-boot delay; `SQLAgent$VEEAMSQL2016` remained stopped/disabled as before.

Current Veeam warning interpretation:

- Recent Veeam warning-result jobs observed on 2026-05-03 were later confirmed by the operator to stem from backup-destination free space dropping below the `10%` warning threshold and SMTP/email warning behavior.
- Treat those warnings as explained unless later maintenance finds a different underlying cause.

On the server:

```powershell
hostname
whoami
(Get-CimInstance Win32_ComputerSystem).PartOfDomain
(Get-CimInstance Win32_ComputerSystem).Domain
Get-Service sshd,WinRM
winrm enumerate winrm/config/listener
Get-Content C:\ProgramData\ssh\sshd_config |
  Select-String 'AllowGroups|AllowUsers|PubkeyAuthentication|PasswordAuthentication|PermitEmptyPasswords'
Get-NetFirewallRule -Enabled True |
  Where-Object { $_.DisplayName -match 'ssh|winrm|remote admin|5985|22' } |
  Get-NetFirewallPortFilter
```

## Veeam Health Checks

Start with service and event state before touching configuration.

```powershell
Get-Service |
  Where-Object { $_.DisplayName -match 'Veeam' -or $_.Name -match 'Veeam' } |
  Sort-Object DisplayName |
  Select-Object Status,Name,DisplayName,StartType

Get-EventLog -LogName Application -Newest 100 |
  Where-Object { $_.Source -match 'Veeam' -or $_.EntryType -eq 'Error' } |
  Select-Object TimeGenerated,EntryType,Source,EventID,Message

Get-PSDrive -PSProvider FileSystem |
  Select-Object Name,Used,Free,Root
```

If the Veeam PowerShell module or console is available, prefer Veeam-native job/session checks after confirming no sensitive output will be committed to the repo.

## Log Locations To Inspect

Verify actual paths during maintenance, but common locations include:

- `C:\ProgramData\Veeam\Backup`
- `C:\ProgramData\Veeam\Setup`
- Windows Event Viewer: Application and System logs
- Veeam Backup & Replication console session history

Do not copy large logs or secrets into this repo. Summarize timestamps, components, and non-sensitive error IDs/messages.

## Files

- [maintenance-log.md](maintenance-log.md): ongoing maintenance history
