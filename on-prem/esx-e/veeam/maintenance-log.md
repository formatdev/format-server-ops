# Veeam Maintenance Log

Maintenance history for the standalone Veeam Windows server on ESX-E.

## 2026-04-18 - Runbook Created

Created the ESX-E/Veeam runbook from operator-provided inventory.

Known starting facts:

- ESX-E holds one known workload VM: `Veeam`.
- The Veeam VM is a Windows server.
- The Veeam VM is not joined to the `format.lu` domain.

Items to verify during first maintenance:

- VMware inventory name, guest hostname, IP address, and VMware Tools state.
- Whether Mac SSH alias `win-veeam` exists and works.
- Which local admin account is used for break-glass access.
- Whether `sshd` is installed, key-only, automatic, and running.
- Whether `WinRM` is intentionally enabled.
- Whether inbound SSH and WinRM firewall rules are scoped to trusted admin sources.
- Veeam services, active sessions, recent job status, repository health, and free disk space.
- Recent Windows Application/System events and Veeam log errors.

## 2026-04-18 - Read-Only Network Discovery

Performed read-only discovery from the maintainer Mac; no server configuration, Veeam configuration, backup data, repositories, firewall rules, snapshots, migrations, reboots, or updates were changed.

Findings:

- Operator confirmed Veeam is reachable at `192.168.90.10`.
- Route from the Mac to `192.168.90.10` uses VPN interface `utun4` via gateway `192.168.113.1`.
- `win-veeam` was not configured as a usable Mac SSH alias; `ssh win-veeam hostname` failed because the name could not be resolved.
- Mac `~/.ssh/config` did not contain a `Host win-veeam` block.
- TCP reachability on `192.168.90.10`:
  - open: `135`, `139`, `445`, `3389`, `5985`, `10001`
  - closed/filtered: `22`, `9392`, `9395`, `9396`, `9401`, `6180`
- SMB guest access was denied, and NetBIOS status lookup timed out.
- WinRM HTTP on `5985` responded with `Microsoft-HTTPAPI/2.0`; `/wsman` required `WWW-Authenticate: Negotiate`.
- A disposable local WinRM client environment was prepared under `/tmp/format-winrm-venv` with `pypsrp` and `requests-ntlm`; this changed only the Mac, not the Veeam server.

Current blocker:

- Deeper authenticated inspection still requires the standalone Veeam local admin credential or another approved access path. Continue to avoid domain-admin, `winad-*`, `SSH Admins`, and domain GPO assumptions unless discovery proves the server has changed.

## 2026-04-18 - Operator OpenSSH Install And Host Baseline

Operator installed OpenSSH Server from an elevated local-admin PowerShell session:

- Before install, `OpenSSH.Server~~~~0.0.1.0` was `NotPresent`.
- `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0` completed with `RestartNeeded: False`.
- Operator set `sshd` startup type to `Automatic` and started the service.
- Mac-side TCP check after install confirmed `192.168.90.10:22`, `5985`, and `10001` reachable.

Operator-provided host baseline:

- Hostname: `veeam`
- Current identity: `veeam\administrator`
- Domain joined: `False`
- Domain/workgroup value: `WORKGROUP`
- WinRM service: `Running`
- Veeam-related services observed running: `VeeamBackupCdpSvc`, `VeeamBackupRESTSvc`, `VeeamBackupSvc`, `VeeamBackupUpdateSvc`, `VeeamBrokerSvc`, `VeeamCatalogSvc`, `VeeamCloudSvc`, `VeeamDataAnalyzerSvc`, `VeeamDeploySvc`, `VeeamDistributionSvc`, `VeeamExplorersRecoverySvc`, `VeeamFilesysVssSvc`, `VeeamGuestInteractionSvc`, `VeeamMountSvc`, `VeeamNFSSvc`, `VeeamThreatHunterSvc`, `VeeamTransportSvc`, `VeeamVssProviderSvc`, `VeeamWebSvc`.
- SQL services observed: `MSSQL$VEEAMSQL2016` running, `SQLAgent$VEEAMSQL2016` stopped, `SQLTELEMETRY$VEEAMSQL2016` running.
- Filesystem drives:
  - `C:` used `76958494720`, free `51520372736`
  - `E:` description `VeeamHDD`, used `28437615149056`, free `2348643319808`
  - `A:` and `D:` were present with no reported used/free values

Next SSH registration items:

- Register maintainer public key fingerprint `SHA256:5yDecQjYHrBaSHiDhR9aho//eX/PwiAkdxFYi8Vs37I` in `C:\ProgramData\ssh\administrators_authorized_keys`.
- Verify `sshd_config` key-only settings and standalone `AllowGroups administrators` model.
- Verify inbound TCP/22 firewall scope before treating SSH as routine maintenance access.

Follow-up:

- Operator confirmed `ssh win-veeam` worked only after a password prompt.
- Mac-side key-only check still failed with `Permission denied`; verbose SSH showed the Mac offered `/Users/czibulapeter/.ssh/windows-admin_ed25519` with fingerprint `SHA256:5yDecQjYHrBaSHiDhR9aho//eX/PwiAkdxFYi8Vs37I`, but the server did not accept it.

## 2026-04-18 - Key-Only SSH Verified And Read-Only Baseline

After the operator updated `C:\ProgramData\ssh\administrators_authorized_keys` and restarted `sshd`, key-only SSH from the Mac succeeded:

- `ssh -o BatchMode=yes win-veeam hostname` returned `veeam`.
- `ssh -o BatchMode=yes win-veeam whoami` returned `veeam\administrator`.

Read-only host baseline over SSH:

- OS: Microsoft Windows Server 2022 Standard, version `10.0.20348`, build `20348`.
- Last boot: `2026-04-10 13:45:35`.
- Platform: VMware virtual machine, model `VMware20,1`.
- RAM reported: `17178873856` bytes.
- Domain/workgroup remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Local Administrators membership observed: `VEEAM\Administrator` only.

Remote-admin baseline:

- `sshd`: `Running`, `Automatic`.
- `WinRM`: `Running`, `Automatic`.
- WinRM HTTP listener exists on port `5985`, listening on `127.0.0.1`, `192.168.90.10`, `::1`, and link-local IPv6.
- `sshd_config` relevant settings:
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`
  - `PermitEmptyPasswords no`
  - default `AuthorizedKeysFile .ssh/authorized_keys`
  - `Match Group administrators` uses `__PROGRAMDATA__/ssh/administrators_authorized_keys`
- `administrators_authorized_keys` ACL: `NT AUTHORITY\SYSTEM:(F)` and `BUILTIN\Administrators:(F)`.
- `administrators_authorized_keys` contained one key line with comment `windows-admin`.
- `sshd.exe` WER dump directory/key were not present: no `C:\ProgramData\ssh\dumps` and no `HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\sshd.exe`.

Firewall findings:

- Default OpenSSH firewall rule `OpenSSH SSH Server (sshd)` allows TCP/22 from `Any`.
- Custom rule `Allow remote Admin - SSH 22` also exists and is scoped to `192.168.1.73,192.168.113.2`.
- Do not change firewall policy until explicitly approved; the broad default OpenSSH rule is the next remote-admin hardening candidate.

Disk and volume findings:

- `C:` NTFS healthy, size `128478867456`, free `51514318848`.
- `E:` label `VeeamHDD`, ReFS healthy, size `30786258468864`, free `2348643319808`.
- `A:` and `D:` were present with zero size/free reported.
- An EFI/FAT32 volume was present with size `362807296`, free `331866112`.

Veeam service and port findings:

- Veeam-related services observed running and automatic: Backup RESTful API, Backup Service, Backup Update Service, Backup VSS Integration, Broker, CDP Coordinator, Cloud Connect, Data Analyzer, Data Mover, Distribution, Explorers Recovery, Guest Catalog, Guest Interaction, Installer, Mount, Threat Hunter, vPower NFS, VSS Hardware Provider, and Web Service.
- SQL services: `MSSQL$VEEAMSQL2016` running/automatic, `SQLAgent$VEEAMSQL2016` stopped/disabled, `SQLTELEMETRY$VEEAMSQL2016` running/automatic.
- Veeam-related listening ports on the server:
  - `127.0.0.1:9392` and `::1:9392` by `Veeam.Backup.Service`
  - `127.0.0.1:9396` and `::1:9396` by `Veeam.Backup.UIServer`
  - `0.0.0.0:9419` and `:::9419` by `Veeam.Backup.RestAPIService`
  - `:::9420`, `0.0.0.0:10001`, and `:::10001` by `Veeam.Backup.Service`

Events and Veeam-native checks:

- Newest 120 Application events returned no Veeam/error matches with the read-only filter used.
- Newest 120 System events showed repeated DCOM `10028` errors around `2026-04-18 17:57:38`, one DCOM `10016` warning, and one Microsoft-Windows-Time-Service `36` warning about no usable time synchronization for 86400 seconds.
- Veeam PowerShell module is installed but requires PowerShell 7; PowerShell 7 exists at `C:\Program Files\PowerShell\7\pwsh.exe`.
- Importing `Veeam.Backup.PowerShell` under PowerShell 7 worked, but Veeam-native cmdlets such as `Get-VBRJob`, `Get-VBRBackupSession`, `Get-VBRBackupRepository`, and `Get-VBRServer` failed to connect to the local Veeam Backup & Replication server with `StatusCode="Cancelled", Detail="No grpc-status found on response."`.
- `Connect-VBRServer` help showed explicit Veeam credentials are required through either `Credential` or `User`/`Password`; no Veeam job/session/repository details were recorded in the repo.

## 2026-04-18 - SSH Firewall Scoped And WER Dumps Configured

With operator approval, performed remote-admin hardening over key-only SSH. No Veeam configuration, backup data, repositories, snapshots, migrations, reboots, Windows updates, or retention settings were changed.

Changes:

- Disabled the broad default Windows OpenSSH inbound firewall rule `OpenSSH SSH Server (sshd)` / `OpenSSH-Server-In-TCP`, which allowed TCP/22 from `Any`.
- Kept the custom inbound rule `Allow remote Admin - SSH 22` enabled for TCP/22, scoped to `192.168.1.73,192.168.113.2`.
- Created `C:\ProgramData\ssh\dumps`.
- Configured `HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\sshd.exe`:
  - `DumpFolder=C:\ProgramData\ssh\dumps`
  - `DumpCount=10`
  - `DumpType=2`

Verification:

- `ssh -o BatchMode=yes win-veeam hostname` still returned `veeam`.
- `ssh -o BatchMode=yes win-veeam whoami` still returned `veeam\administrator`.
- Mac TCP check to `192.168.90.10:22` still succeeded after disabling the broad default OpenSSH rule.
- Firewall verification showed `OpenSSH-Server-In-TCP` disabled with `RemoteAddress=Any`, and `Allow remote Admin - SSH 22` enabled with `RemoteAddress=192.168.1.73,192.168.113.2`.

## 2026-04-18 - Windows Update Preflight Only

Performed read-only Windows Update preflight after operator asked about running updates. No updates were installed, no reboot was triggered, and no Veeam configuration or backup data was changed.

Host and reboot state:

- Hostname: `VEEAM`.
- Last boot: `2026-04-10 13:45:35`.
- Uptime at check: about `8.33` days.
- OS: Microsoft Windows Server 2022 Standard, build `20348`.
- CBS reboot pending: `False`.
- Windows Update reboot required: `False`.
- Pending file rename operations: present.
- Services: `bits` and `cryptsvc` running/automatic; `wuauserv` stopped/manual; `TrustedInstaller` stopped/manual.

Disk state before any update install:

- `C:` NTFS healthy, size `128478867456`, free `51567616000`.
- `E:` `VeeamHDD`, ReFS healthy, size `30786258468864`, free `2348643319808`.

Veeam state before any update install:

- Veeam-related Windows services remained running/automatic.
- Veeam process list showed active Veeam service processes, including `Veeam.Backup.Service`, `Veeam.Backup.RestAPIService`, and `Veeam.Backup.Manager`.
- Veeam-native job/session state was not yet confirmed because `Connect-VBRServer` requires an explicit Veeam credential path.

Available software updates from scan:

- `SQL Server 2016 Service Pack 3 (KB5003279)`; not downloaded; reported reboot required before install: `False`.
- `Windows Malicious Software Removal Tool x64 - v5.140 (KB890830)`; downloaded; reported reboot required before install: `False`.
- `2026-04 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5084071)`; downloaded; severity `Critical`; reported reboot required before install: `False`.
- `2026-04 Cumulative Update for Microsoft server operating system version 21H2 for x64-based Systems (KB5082142)`; downloaded; reported reboot required before install: `False`.

Decision:

- Updates were not installed because current Veeam job/session/repository state remains undocumented. Before installing Windows updates, confirm no active backup, restore, copy, replication, or maintenance sessions are running and agree on reboot handling.

## 2026-04-18 - Windows Updates Installed

With operator approval, installed available Windows/SQL updates on the standalone Veeam server over key-only SSH using local `Administrator` and SYSTEM scheduled tasks. No Veeam configuration, backup repositories, backup data, retention settings, firewall policy, GPOs, VM snapshots, migrations, or power operations were changed outside the required Windows reboots.

Pre-install blast-radius notes:

- Server is standalone `WORKGROUP`, not `format.lu` domain joined.
- Access model remained local-only through `win-veeam` / `veeam\administrator`.
- Veeam-native job/session/repository state could not be queried because `Connect-VBRServer` requires explicit Veeam credentials; updates were started only after operator direction.
- `C:` had about `51.6 GB` free before install; `E:` `VeeamHDD` had about `2.35 TB` free.
- Direct Windows Update COM install over the SSH admin session failed with `E_ACCESSDENIED`, consistent with split-token/UAC behavior; the install path was changed to explicit SYSTEM scheduled tasks.

Installed updates:

- `SQL Server 2016 Service Pack 3 (KB5003279)`; install result success, `HResult=0`; first reboot required.
- `SQL Server 2016 Service Pack 3 Azure Connect Pack KB5014242`; install result success, `HResult=0`.
- `2026-04 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5084071)`; install result success, `HResult=0`.
- `2026-04 Cumulative Update for Microsoft server operating system version 21H2 for x64-based Systems (KB5082142)`; install result success, `HResult=0`; second reboot required.
- `Security Update for SQL Server 2016 Service Pack 3 CU (KB5084820)`; install result success, `HResult=0`; third reboot required.

Reboots:

- Reboot 1 completed SQL Server 2016 SP3.
- Reboot 2 completed the OS/.NET cumulative update pass.
- Reboot 3 completed SQL Server security CU `KB5084820`.

Final verification after reboot 3:

- Last boot observed: `2026-04-18 22:31:35`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Reboot pending flags cleared:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `False`
- Windows Update scan returned no remaining uninstalled, unhidden updates.
- SQL version reported by `sqlcmd` on `.\VEEAMSQL2016`: `13.0.7080.1`, `SP3`, `CU1`.
- `sshd`, `WinRM`, `MSSQL$VEEAMSQL2016`, and automatic Veeam services were running after the normal post-boot service delay.
- `SQLAgent$VEEAMSQL2016` remained stopped/disabled, matching the pre-maintenance baseline.
- Disk space after updates:
  - `C:` about `45.9 GB` free
  - `E:` about `2.19 TB` free
- Temporary scheduled tasks matching `FormatServerOps-WindowsUpdate*` were removed after completion.

Audit artifacts left on the server:

- `C:\ProgramData\format-server-ops\install-windows-updates.ps1`
- `C:\ProgramData\format-server-ops\install-downloaded-windows-updates.ps1`
- `C:\ProgramData\format-server-ops\post-update-check.ps1`
- `C:\ProgramData\format-server-ops\start-sqlcu-update-task.ps1`
- `C:\ProgramData\format-server-ops\windows-update-2026-04-18.log`
- `C:\ProgramData\format-server-ops\windows-update-downloaded-2026-04-18.log`

Residual risk / follow-up:

- Veeam-native job/session/repository health still needs an approved Veeam credential path; do not infer backup job success from Windows service health alone.
- Run a Veeam console or Veeam PowerShell health check before the next invasive maintenance window.
