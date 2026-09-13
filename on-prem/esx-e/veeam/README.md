# Veeam Runbook

Runbook for the standalone Windows Veeam server VM on ESX-E.

Last updated: 2026-09-13

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
- Last boot observed: `2026-09-13 12:38:18`, verified at `12:45` after the operator's update reboot

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

- `C:` NTFS, healthy, about 39.34 GB free of 128.5 GB after the `2026-09-13` update reboot (`30.62%` free)
- `E:` `VeeamHDD`, ReFS, healthy, about 6.71 TB free of 30.8 TB on `2026-09-13` (`21.81%` free)
- The primary chain now contains one full plus 149 reverse increments; current Veeam logs explicitly confirm a 150-point retention policy

Current Windows Update findings:

- April 2026 Windows/.NET/SQL updates installed on `2026-04-18`.
- May 2026 update cycle completed on `2026-05-16`: `KB5089270`, `KB890830` v5.141, `KB5088862`, and `KB5087545`.
- CBS, Windows Update reboot flags, and pending file rename operations were all clear after the May 2026 reboot.
- End-of-month check on `2026-05-31` found no new pending updates; CBS and Windows Update reboot flags remained clear, but `PendingFileRenameOperations` had reappeared.
- A later operator-approved reboot on `2026-05-31` cleared `PendingFileRenameOperations` again without introducing new CBS or Windows Update reboot flags.
- Mid-June check on `2026-06-14` found no pending Windows updates, no CBS/Windows Update reboot flags, and `PendingFileRenameOperations=True` again after a same-day reboot; the current queue sampled only `C:\Program Files (x86)\Microsoft\EdgeUpdate\1.3.239.19`.
- Early-July check on `2026-07-04` again found `0` pending Windows updates and no CBS/Windows Update reboot flags; `PendingFileRenameOperations` remained present but was now sampled as one `EdgeUpdate` path plus four `C:\Config.Msi\*.rbf` entries and two `C:\WINDOWS\Temp\DEL*.tmp` entries.
- Mid-July check on `2026-07-19` found `5` pending updates with no current CBS/Windows Update reboot flag: `PowerShell LTS v7.4.17 (x64)`, SQL Server 2016 SP3 CU security update `KB5102339`, `KB890830` v5.143, `.NET` cumulative update `KB5102206`, and Windows Server cumulative update `KB5099540`.
- The July 2026 update cycle completed on `2026-07-19`; after reboot there were no remaining pending updates, CBS/Windows Update reboot flags were clear, and `PendingFileRenameOperations` was clear again.
- A later verification reboot on `2026-07-19` again returned with no remaining pending updates, no reboot-pending flags, and `PendingFileRenameOperations` clear after the temporary `.NET 8.0.28`/`.NET 8.0.29` runtime rename queue drained.
- Early-August inspection on `2026-08-04` found one pending update, `PowerShell LTS v7.4.18 (x64)`, with no CBS or Windows Update reboot requirement.
- `PendingFileRenameOperations` had reappeared with 22 registry entries representing 11 Edge updater and temporary installer paths; no Windows servicing paths were observed.
- Component-store analysis found `0` reclaimable packages and did not recommend cleanup.
- On `2026-08-23`, Windows Update discovery found four pending updates: `KB890830` v5.144, `.NET` cumulative update `KB5121650`, `PowerShell v7.6.5 (x64)`, and Windows Server cumulative update `KB5120242`.
- Software patching on `2026-08-22` installed PowerShell `7.6.4` and .NET `8.0.30`. Windows Installer deferred removal of .NET `8.0.29` until reboot, leaving a large pending rename queue even though CBS and Windows Update reboot flags remained clear.
- Component-store analysis on `2026-08-23` again found `0` reclaimable packages and did not recommend cleanup.
- The August 2026 update cycle completed on `2026-08-23`: `KB890830` v5.144, `.NET` update `KB5121650`, PowerShell `7.6.5`, and Windows Server cumulative update `KB5120242` installed successfully.
- After reboot, Windows reported build `20348.5499`, zero pending updates, no CBS or Windows Update reboot requirement, and no pending file rename operations. The deferred .NET `8.0.29` removal also completed.
- Early-September inspection on `2026-09-05` again found zero pending Windows updates and no CBS or Windows Update reboot requirement.
- `PendingFileRenameOperations` contained 50 non-empty paths: 25 `Config.Msi` rollback files, 24 temporary files, and one updater path. No Veeam or Windows servicing path was present.
- Component-store analysis reported zero reclaimable packages and did not recommend cleanup.
- SQL Server instance `.\VEEAMSQL2016` now reports `13.0.7095.1`, `SP3`.
- Veeam Backup & Replication was upgraded on `2026-08-26`. The server executable reports base version `13.1.0.411`, while hot-update components and the client/server compatibility log report `13.1.1.18`.
- PowerShell `7.6.6` installation succeeded on `2026-09-13`; PowerShell LTS `7.4.18` was also present in the prior inventory.
- Veeam services returned to `Running` after the normal post-boot delay; `SQLAgent$VEEAMSQL2016` remained stopped/disabled as before.
- Inspection on `2026-09-13` found four downloaded updates awaiting installation: `KB890830` v5.145, .NET `KB5126149`, PowerShell `7.6.6`, and Windows Server cumulative update `KB5122882`. None was installed during this inspection.
- CBS and Windows Update reboot flags were clear; seven pending rename paths referred to security-provider backup DLLs, MSI rollback files, and driver staging files. Component-store analysis found zero reclaimable packages and did not recommend cleanup.
- The operator subsequently installed all four updates and restarted Windows at `12:38:18`. Post-reboot verification at `12:45-12:47` confirmed all four installation-history results were Succeeded with `HResult=0`, Windows build `20348.5622`, and all three reboot/rename indicators clear. Veeam, SQL, SSH, and WinRM services recovered; no fresh pending-update search was performed.

Current Veeam warning interpretation:

- Recent Veeam warning-result jobs observed on 2026-05-03 were later confirmed by the operator to stem from backup-destination free space dropping below the `10%` warning threshold and SMTP/email warning behavior.
- Treat those warnings as explained unless later maintenance finds a different underlying cause.
- On `2026-08-04`, current job-state logging showed all three configured jobs stopped; repository free space had fallen to `3.78%`, reinforcing the existing capacity-warning explanation.
- Read-only filesystem inventory found that `E:\VeeamBackups\Backup Job ESXE to ESX-B` held about `26.74 TiB` logical size in one full backup, 199 reverse-increment files, and one metadata file. Do not remove these files directly; retention or capacity changes must be reviewed and performed through Veeam.
- On `2026-08-23`, Veeam logs confirmed the retention setting is now 150 points. The latest primary backup, copy, and replication payloads completed successfully; their final warning state came from SMTP relay rejection `5.7.54`.
- On `2026-09-05`, all three jobs were stopped. The latest primary backup was `Failed`, while backup copy and replication remained `Warning`.
- In the latest primary run, `Exchange3`, `File`, and `VMware vCenter Server` completed successfully, but retries for `Admin`, `PDC`, `Easyjob3`, `Tim`, `Kuhnle`, `Lmr`, and `BDC` failed before data transfer with remote SCM, RPC, guest-agent, or installer-service connectivity errors.
- Investigation found that the `2026-08-26` Veeam server upgrade had left the persistent Veeam Installer Services on `Tim` and `Admin` stopped and partially upgraded. The upgrade logs showed service-stop timeout `0x0000041d`; the newer service then required the signed Veeam OpenSSL FIPS `3.1.2.2` prerequisite.
- On `2026-09-05`, the signed prerequisite and Veeam-managed component packages were repaired on `Tim` and `Admin`. Installer, Transport, and Guest Interaction components now report `13.1.1.18`, run automatically, and listen on TCP `6160`, `6162`, and `6190`; Veeam can reach all three ports on both guests.
- Verification on `2026-09-13` confirmed the `2026-09-11` primary backup and replication each completed all 10 tasks successfully. The NAS4 copy finished on `2026-09-12 00:45` with all 10 successful. All seven formerly failing guests have successful primary task records; the backup incident is resolved for the observed cycle. This is job-completion evidence, not a restore test.
- Final Warning results came from the established SMTP relay rejection `5.7.54`. All three configured jobs were stopped during inspection; only the infrastructure-rescan worker was observed.
- Separate follow-ups on `2026-09-13`: recurring TPM-WMI `1796` SBAT update failures despite Secure Boot enabled; Windows Time reports unsynchronized and three NTP probes to `time.windows.com` timed out. VMware Tools time synchronization is enabled and the sampled UTC clock agreed with the maintainer clock. No time or firmware policy was changed.
- Follow-up at `2026-09-13 12:14`: operator-started Windows updates were installing, with CBS and Windows Update reboot flags now True. WatchGuard candidate `192.168.1.253` answered four NTP probes with offsets of approximately `+0.69` to `+0.80 ms`. It is reachable but is not the configured Windows peer; that remains `time.windows.com,0x9`. VMware Tools host synchronization reports enabled; ESX-E's upstream NTP configuration is not yet verified.

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

For the verified domain/standalone time-source matrix, see [On-Prem Time Synchronization](../../time-synchronization.md). With operator approval on `2026-09-13`, Veeam now uses its own gateway `192.168.90.253,0x8` for Windows NTP. Windows Time is Automatic/Running and synchronized at stratum 4; VMware periodic synchronization is disabled. Startup/resume synchronization settings were not changed. These settings and successful gateway synchronization were verified again at `12:45` after the Windows update reboot.

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
