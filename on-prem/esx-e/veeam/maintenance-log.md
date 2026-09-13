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

## 2026-05-03 - Bi-Monthly Read-Only Maintenance

Performed a read-only maintenance sweep over key-only SSH from the maintainer Mac. No reboots, Windows updates, Veeam configuration changes, repository changes, firewall changes, VM power actions, or credential changes were made.

Access and identity:

- `ssh -o BatchMode=yes win-veeam hostname` continued to work; host responded as `veeam`.
- Current identity remained `veeam\administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Mac-side reachability checks succeeded for:
  - `192.168.90.10:22`
  - `192.168.90.10:5985`
  - `192.168.90.10:10001`

Current host state:

- Check time: `2026-05-03 08:28:09`.
- OS remained Microsoft Windows Server 2022 Standard, version `10.0.20348`.
- Last boot observed: `2026-04-23 10:34:05`.
- Reboot flags:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`
- Pending file rename entries were dominated by `C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\8.0.25\...` paths and should be treated as residual .NET servicing state unless later maintenance proves otherwise.

Remote-admin baseline:

- `sshd`: `Running`, `Automatic`.
- `WinRM`: `Running`, `Automatic`.
- Firewall posture matched the April baseline:
  - default `OpenSSH SSH Server (sshd)` rule present but disabled
  - custom `Allow remote Admin - SSH 22` rule enabled and scoped to `192.168.1.73,192.168.113.2`
- `sshd_config` still showed:
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`
  - `PermitEmptyPasswords no`
  - administrator match block using `__PROGRAMDATA__/ssh/administrators_authorized_keys`

Storage and service state:

- `C:` about `51.28 GB` free.
- `E:` about `2104.13 GB` free.
- SQL/Veeam services checked remained healthy:
  - `MSSQL$VEEAMSQL2016`: running/automatic
  - `SQLAgent$VEEAMSQL2016`: stopped/disabled
  - `SQLTELEMETRY$VEEAMSQL2016`: running/automatic
  - Veeam service set observed running/automatic, including Backup, REST API, Broker, Catalog, Cloud Connect, Data Mover, Distribution, Guest Interaction, Mount, NFS, Threat Hunter, and Web Service

Update state:

- Windows Update scan returned no remaining uninstalled, unhidden updates.
- SQL build remained `13.0.7080.1`, `SP3`, `CU1`.
- Recent update history still reflected the successful April 18, 2026 servicing window.

Warnings and log signals:

- Application log noise over the last 14 days was mostly recurring `Perflib` warnings:
  - `Perflib 1008` for `BITS` (`bitsperf.dll` open procedure failed)
  - `Perflib 2003` for `MSSQL$VEEAMSQL2016` trusted performance library mismatch referencing `perf-MSSQL$VEEAMSQL2016-sqlctr13.3.6300.2.dll`
- System log still showed repeated `DistributedCOM 10028` errors. Current messages were requested by `C:\Program Files\Veeam\Backup and Replication\Backup\Veeam.Backup.Manager.exe` while activating CLSID `{8BC3F05E-D86B-11D0-A075-00C04FB68820}` against `192.168.90.10`.
- Recent Veeam log activity under `C:\ProgramData\Veeam\Backup` confirmed active service logging.
- `Svc.VeeamBackup.log` showed recent stopped jobs with `Result: [Warning]`:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`

  - `Backup Job to ESXE`
  - `Replication`
- For the newest sampled status block at `2026-05-03 07:47:01`, those jobs showed the following latest run times:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`: latest run `2026-05-01 22:26:03`
  - `Backup Job to ESXE`: latest run `2026-05-01 22:00:14`
  - `Replication`: latest run `2026-05-01 16:00:17`
- The read-only log sampling captured the warning result states but did not safely establish the underlying cause from Veeam-native session data.

Assessment:

- No patching or reboot action was required during this maintenance pass because update scan was empty and core services were healthy.
- The main unresolved operational item is Veeam-native backup health: current logs suggest recent jobs ended in `Warning`, but the exact cause still needs Veeam console review or an approved `Connect-VBRServer` credential path.

Recommended next step:

- Review the three warning-result jobs in the Veeam console or via approved Veeam credentials before the next invasive maintenance window.

## 2026-05-03 - Operator Clarified Warning Cause

Operator confirmed the recent Veeam job warnings were already understood and were not treated as unexplained backup failures.

Clarified cause:

- Backup destination free space had dropped below the `10%` warning threshold.
- SMTP/email alerting also contributed to the observed warning state.
- Operator confirmed backups were otherwise fine.

Operational note:

- Operator plans to run Windows `Disk Cleanup` with `Clean up system files`, with about `1.85 GB` reclaimable at the time of discussion.
- Operator also plans to shut down the relevant client later before a future Veeam host reboot.

Interpretation update:

- The 2026-05-03 read-only maintenance findings should treat the observed Veeam warning-result jobs as explained by repository-capacity/email-warning conditions unless later evidence shows a different cause.

## 2026-05-16 - Twice-Monthly Read-Only Maintenance

Performed a read-only maintenance sweep over key-only SSH from the maintainer Mac. No reboots, Windows updates, Veeam configuration changes, repository changes, firewall changes, VM power actions, or credential changes were made during this pass.

Repo/worktree note:

- The local git worktree was already dirty in many unrelated paths outside ESX-E. Those changes were left untouched.

Access and identity:

- `ssh -o BatchMode=yes win-veeam hostname` continued to work; host responded as `veeam`.
- Current identity remained `veeam\administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Mac-side reachability checks succeeded for:
  - `192.168.90.10:22`
  - `192.168.90.10:5985`
  - `192.168.90.10:10001`

Current host state:

- Check time: `2026-05-16 08:50:38`.
- OS remained Microsoft Windows Server 2022 Standard, version `10.0.20348`.
- Last boot observed: `2026-05-03 18:17:56`.
- Reboot flags:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`
- Compared with 2026-05-03, the host had been rebooted, but pending file rename operations still had not cleared.

Remote-admin baseline:

- `sshd`: `Running`, `Automatic`.
- `WinRM`: `Running`, `Automatic`.
- Firewall posture matched the previous baseline:
  - default `OpenSSH SSH Server (sshd)` rule present but disabled
  - custom `Allow remote Admin - SSH 22` rule enabled and scoped to `192.168.1.73,192.168.113.2`
- `sshd_config` still showed:
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`
  - `PermitEmptyPasswords no`
  - administrator match block using `__PROGRAMDATA__/ssh/administrators_authorized_keys`

Storage and service state:

- `C:` about `50.23 GB` free.
- `E:` about `2027.09 GB` free.
- SQL/Veeam services checked remained healthy:
  - `MSSQL$VEEAMSQL2016`: running/automatic
  - `SQLAgent$VEEAMSQL2016`: stopped/disabled
  - `SQLTELEMETRY$VEEAMSQL2016`: running/automatic
  - Veeam service set observed running/automatic, including Backup, REST API, Broker, Catalog, Cloud Connect, Data Mover, Distribution, Guest Interaction, Mount, NFS, Threat Hunter, and Web Service

Update state:

- Windows Update scan no longer showed an empty queue. Four updates were available and already downloaded:
  - `Security Update for SQL Server 2016 Service Pack 3 CU (KB5089270)`
  - `Windows Malicious Software Removal Tool x64 - v5.141 (KB890830)`
  - `2026-05 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5088862)`
  - `2026-05 Cumulative Update for Microsoft server operating system version 21H2 for x64-based Systems (KB5087545)`
- None of those updates reported reboot required before install at scan time.
- SQL build remained `13.0.7080.1`, `SP3`, `CU1`.

Warnings and log signals:

- Application log noise over the last 14 days continued to show recurring `Perflib` warnings:
  - `Perflib 1008` for `BITS` (`bitsperf.dll` open procedure failed)
  - `Perflib 2003` for `MSSQL$VEEAMSQL2016` trusted performance library mismatch referencing `perf-MSSQL$VEEAMSQL2016-sqlctr13.3.6300.2.dll`
- System log still showed repeated `DistributedCOM 10028` errors requested by `C:\Program Files\Veeam\Backup and Replication\Backup\Veeam.Backup.Manager.exe` while activating CLSID `{8BC3F05E-D86B-11D0-A075-00C04FB68820}` against `192.168.90.10`.
- System log also showed `Microsoft-Windows-TPM-WMI 1796` (`The Secure Boot update failed to update SBAT ...`) on a VMware guest without TPM/Secure Boot expectations; this was recorded but not acted on during the read-only pass.
- Recent Veeam log activity under `C:\ProgramData\Veeam\Backup` confirmed active service logging.
- `Svc.VeeamBackup.log` continued to show recent stopped jobs with `Result: [Warning]` on `2026-05-16`:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`
  - `Backup Job to ESXE`
  - `Replication`
- These warnings remain consistent with the operator-confirmed explanation from 2026-05-03: backup-destination free space below the `10%` threshold and SMTP/email warning behavior.

Assessment:

- No changes were made during this pass because current state and blast radius were still being documented.
- The next safest maintenance target is the May 2026 Windows servicing set, because the updates are already downloaded, the host is reachable and healthy, and the queue is now clearly identified.
- Before installing those updates, confirm reboot handling and preserve the existing understanding that backup warning states are already explained by repository-capacity/email-warning conditions rather than unknown Veeam job failure.

## 2026-05-16 - May 2026 Updates Installed

With operator approval, installed the downloaded May 2026 Windows update set on the standalone Veeam server over key-only SSH using a SYSTEM scheduled task. No Veeam configuration, repositories, backup data, retention settings, firewall policy, GPOs, VM snapshots, or migrations were changed.

Pre-install state:

- Host: `veeam`
- Identity: `veeam\administrator`
- Last boot before install: `2026-05-03 18:17:56`
- Reboot flags before install:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`
- All core SQL/Veeam services were running except baseline `SQLAgent$VEEAMSQL2016` stopped/disabled.

Installed updates:

- `Security Update for SQL Server 2016 Service Pack 3 CU (KB5089270)`; install result success, `HResult=0`
- `Windows Malicious Software Removal Tool x64 - v5.141 (KB890830)`; install result success, `HResult=0`
- `2026-05 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5088862)`; install result success, `HResult=0`
- `2026-05 Cumulative Update for Microsoft server operating system version 21H2 for x64-based Systems (KB5087545)`; install result success, `HResult=0`

Execution notes:

- Reused `C:\ProgramData\format-server-ops\install-downloaded-windows-updates.ps1` through scheduled task `FormatServerOps-WindowsUpdate-May2026`.
- Windows Update event log confirmed progressive success for the SQL CU, MSRT, and .NET CU before the OS cumulative update completed.
- The scheduled-task transcript remained sparse during install and did not record a clean end-of-run block before reboot handling, but Windows Update history and post-reboot state confirmed successful completion.
- A first shutdown request overlapped with ongoing servicing; the actual reboot completed a little later once Windows entered shutdown.

Post-reboot verification:

- Last boot observed after updates: `2026-05-16 09:27:51`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Reboot flags cleared:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `False`
- Windows Update scan returned no remaining uninstalled, unhidden updates.
- SQL build reported by `sqlcmd` on `.\VEEAMSQL2016`: `13.0.7085.1`, `SP3`, `CU1`.
- Disk state after updates:
  - `C:` about `47.33 GB` free
  - `E:` about `2027.09 GB` free
- `SQLAgent$VEEAMSQL2016` remained stopped/disabled, matching baseline.
- The full observed automatic Veeam service set recovered after the normal post-boot delay.
- Temporary scheduled task `FormatServerOps-WindowsUpdate-May2026` was removed after completion.

Interpretation update:

- The old persistent pending-file-rename condition seen on 2026-05-03 and pre-install on 2026-05-16 is now cleared after the May 2026 update/reboot cycle.

## 2026-05-17 - Data Retrieval Warning Checked

Operator asked about the Veeam status string:

- `VEEAM  192.168.90.10  Online - Data retrieval failures occurred  17/05/2026 08:17:48  ... (Activated)?`

Read-only investigation findings:

- No evidence of a backup-data, repository, or host-offline failure was found around `2026-05-17 08:17:48`.
- System events around that time were mostly normal interactive/user-session service events, including `Clipboard User Service_2df7195` entering `running`.
- The closest relevant Veeam-side activity was local satellite / REST API startup shortly after, including `LicenseContainer` initialization in `Satellite_RestApi.log`.
- The more severe Veeam log warnings found in the investigation window belonged to the prior `2026-05-16` Windows update cycle, when SQL connectivity briefly degraded during servicing; those do not line up with the `2026-05-17 08:17:48` status.

Interpretation:

- Treat the `Online - Data retrieval failures occurred` state as a likely transient guest-information retrieval/UI inventory issue rather than a backup job failure.
- The trailing `Activated?` presentation likely reflects incomplete confirmation of a retrieved activation/licensing field rather than evidence that Windows activation is broken.

Operational stance:

- Safe to refresh/rescan the object later and ignore the message if it does not persist and backup operations remain healthy.

## 2026-05-17 - Disk Cleanup Launched

At operator request, launched Windows `Disk Cleanup` / `Clean up system files` on the Veeam server under `SYSTEM`.

Execution details:

- Used `cleanmgr.exe` with a generated `sagerun` profile through scheduled task `FormatServerOps-CleanMgr-May2026`.
- Enabled all discovered `VolumeCaches` cleanup categories except `DownloadsFolder`.
- `DownloadsFolder` was intentionally excluded as user data rather than system cleanup content.

Observed categories available on this host included:

- `Update Cleanup`
- `Windows Error Reporting Files`
- `System error memory dump files`
- `System error minidump files`
- `Temporary Files`
- `Temporary Setup Files`
- `Delivery Optimization Files`
- `Device Driver Packages`
- `Previous Installations`
- `Windows Upgrade Log Files`
- `Recycle Bin`
- and other standard Disk Cleanup categories present under `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches`

Observed runtime state:

- Initial `C:` free space before launch: about `47.42 GB`.
- While cleanup was running, `C:` free space increased to about `49.64 GB`.
- Observed reclaimed space at that point: about `2.22 GB`.
- The `SYSTEM` `cleanmgr.exe` process was still running at last check; Windows cleanup can continue for a long time, especially when servicing-related cleanup is included.

Operational note:

- This log entry records the launch and observed reclaim during runtime. Confirm final completion and final reclaimed space in a later check if exact final totals are needed.

## 2026-05-31 - End-Of-Month Read-Only Maintenance

Performed an end-of-month read-only maintenance sweep over key-only SSH from the maintainer Mac. No reboots, Windows updates, Veeam configuration changes, repository changes, firewall changes, VM power actions, or credential changes were made.

Access and identity:

- Check time: `2026-05-31 08:29:53`.
- Host responded as `veeam`.
- Current identity remained `veeam\administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.

Current host state:

- OS remained Microsoft Windows Server 2022 Standard, version `10.0.20348`.
- Last boot observed: `2026-05-17 10:19:29`.
- Reboot flags:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`
- `PendingFileRenameOperations` had reappeared since the May 16 patch cycle even though CBS and Windows Update reboot flags remained clear.

Storage and service state:

- `C:` about `50.62 GB` free.
- `E:` about `1882.76 GB` free.
- SQL and remote-admin services remained at baseline:
  - `MSSQL$VEEAMSQL2016`: running/automatic
  - `SQLAgent$VEEAMSQL2016`: stopped/disabled
  - `SQLTELEMETRY$VEEAMSQL2016`: running/automatic
  - `sshd`: running/automatic
  - `WinRM`: running/automatic
- Automatic Veeam services remained running, including Backup, REST API, Broker, Catalog, Cloud Connect, Data Analyzer, Data Mover, Distribution, Guest Interaction, Mount, NFS, Threat Hunter, and Web Service.

Update state:

- Windows Update scan returned no pending updates.
- Recent update history still reflected the successful May 16, 2026 servicing window.
- SQL build remained `13.0.7085.1`, `SP3`, `CU1`.

Warnings and log signals:

- Application log still showed recurring `Perflib` noise:
  - `Perflib 2003` for `MSSQL$VEEAMSQL2016` trusted performance library mismatch referencing `perf-MSSQL$VEEAMSQL2016-sqlctr13.3.6300.2.dll`
  - `Perflib 1008` for `BITS` / `bitsperf.dll`
- System log still showed recurring `DistributedCOM 10028` errors involving `Veeam.Backup.Manager.exe` activating CLSID `{8BC3F05E-D86B-11D0-A075-00C04FB68820}` against `192.168.90.10`.
- `Svc.VeeamBackup.log` continued to show recent warning-result jobs for:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`
  - `Backup Job to ESXE`
  - `Replication`
- Continue treating those warning-result jobs as explained by backup-destination free space dropping below the `10%` warning threshold and SMTP/email warning behavior unless later maintenance finds a different cause.

Next safest target:

- No new Windows updates were available as of `2026-05-31`, so the safest next maintenance target is continued read-only monitoring of repository free space on `E:` and the known warning-job pattern rather than invasive host changes.

## 2026-05-31 - Pending File Rename Follow-Up

Performed a read-only follow-up to identify what had repopulated `PendingFileRenameOperations`.

Findings:

- The queue no longer looked like the earlier `.NET 8.0.25` state seen before the May 16 patch cycle.
- Current queued paths were dominated by:
  - `C:\Config.Msi\*.rbf` rollback/installer files
  - `C:\WINDOWS\Temp\eset.temp\...` installer-temp paths
  - `C:\Program Files\dotnet\shared\Microsoft.NETCore.App\8.0.26\...`
  - `C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\8.0.26\...`
  - a small number of `C:\WINDOWS\Temp\DEL*.tmp` paths
  - `C:\Program Files (x86)\Microsoft\EdgeUpdate\1.3.233.3`
- `dotnet --list-runtimes` showed both `8.0.26` and newer `8.0.27` runtimes installed side by side for `Microsoft.NETCore.App` and `Microsoft.AspNetCore.App`.

Interpretation:

- This queue currently reads more like MSI/installer cleanup and .NET runtime replacement bookkeeping than an active Windows Update/CBS servicing hold.
- Because `CBS reboot pending` and `Windows Update reboot required` remained `False`, do not treat the queue by itself as proof that Windows patching is incomplete.
- The presence of `Config.Msi`, `eset.temp`, and `EdgeUpdate` paths suggests at least one application-level installer/update sequence also contributed to the rename queue.

Operational stance:

- Keep this read-only unless a future maintenance window specifically approves deeper cleanup of installer leftovers.
- Re-check whether the queue clears after a later intentional reboot or application update cycle rather than forcing manual registry cleanup.

## 2026-05-31 - Reboot Cleared Pending Rename Queue

With operator approval, rebooted the standalone Veeam server to see whether the pending rename queue would drain cleanly. No Veeam configuration, repository settings, firewall rules, or Windows update settings were changed.

Pre-reboot state:

- Check time before reboot: `2026-05-31 08:44:55`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- `PendingFileRenameOperations`: present.
- No new Windows updates were pending.

Reboot sequence:

- Remote reboot command was accepted over `win-veeam`.
- Host dropped from SSH at about `2026-05-31 08:45:35`.
- Host was reachable on SSH again by about `2026-05-31 08:46:14`.

Post-reboot verification:

- Last boot observed: `2026-05-31 08:45:44`.
- `PendingFileRenameOperations`: cleared.
- `CBS reboot pending`: `False`.
- `Windows Update reboot required`: `False`.
- `sshd` and `WinRM` returned to `RUNNING`.
- SQL baseline recovered:
  - `MSSQL$VEEAMSQL2016`: `RUNNING`
  - `SQLAgent$VEEAMSQL2016`: remained `STOPPED`, matching baseline
  - `SQLTELEMETRY$VEEAMSQL2016`: `RUNNING`
- Veeam service recovery showed the normal short post-boot delay, then recovered:
  - `VeeamBackupSvc`: `RUNNING`
  - `VeeamBackupRESTSvc`: `RUNNING`
  - `VeeamBrokerSvc`: `RUNNING`
  - `VeeamTransportSvc`: `RUNNING`
  - `VeeamWebSvc`: `RUNNING`
- Disk state after reboot:
  - `C:` used `73891033088`, free `54587834368`
  - `E:` used `28764656828416`, free `2021601640448`

Interpretation:

- The pending rename queue on 2026-05-31 was consistent with installer/runtime cleanup state that a normal reboot could clear.
- No follow-up cleanup of the registry queue is needed at this point.

## 2026-06-14 - Mid-Month Read-Only Maintenance

Performed a read-only maintenance sweep over key-only SSH from the maintainer Mac. No Windows updates were installed, no reboot was triggered during this check, and no Veeam configuration, repository, firewall, or credential changes were made.

Repo/worktree note:

- The local git worktree was already dirty in unrelated `on-prem/esx-c` paths before this maintenance pass. Those changes were left untouched.

Access and identity:

- Check time: `2026-06-14 18:21:08`.
- Host responded as `VEEAM`.
- Current identity remained `VEEAM\Administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.

Current host state:

- OS remained Microsoft Windows Server 2022 Standard, version `10.0.20348`.
- Last boot observed: `2026-06-14 00:48:48`.
- Reboot flags:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`

Storage and service state:

- `C:` used `74969845760`, free `53509021696`.
- `E:` used `29006834499584`, free `1779423969280`.
- SQL and remote-admin services remained at baseline:
  - `sshd`: `RUNNING`
  - `WinRM`: `RUNNING`
  - `MSSQL$VEEAMSQL2016`: `RUNNING`
  - `SQLAgent$VEEAMSQL2016`: `STOPPED`, matching baseline
  - `SQLTELEMETRY$VEEAMSQL2016`: `RUNNING`
- Sampled Veeam services were healthy:
  - `VeeamBackupSvc`: `RUNNING`
  - `VeeamBackupRESTSvc`: `RUNNING`
  - `VeeamBrokerSvc`: `RUNNING`
  - `VeeamTransportSvc`: `RUNNING`
  - `VeeamWebSvc`: `RUNNING`

Update and version state:

- Built-in Windows Update COM search returned `0` pending updates.
- `PSWindowsUpdate` cmdlets were not available on the host during this maintenance pass; update discovery was done through the built-in COM search path instead.
- `Veeam.Backup.Service.exe` reported product version `13.0.2.29`.

Pending rename follow-up:

- The queue no longer resembled the older .NET/MSI/ESET mix seen on 2026-05-31.
- Current sampled queue content was limited to:
  - `C:\Program Files (x86)\Microsoft\EdgeUpdate\1.3.239.19`
- Interpretation: this currently looks like lightweight Edge updater housekeeping rather than incomplete Windows servicing or a broad installer backlog.

Warnings and log signals:

- No pending Windows update or CBS reboot condition was present.
- The read-only Veeam warning/error tail used for this pass did not return any fresh log lines in the sampled window.

Next safest target:

- No patching action is waiting as of `2026-06-14`.
- The safest next maintenance target is continued read-only monitoring of repository free space on `E:` and watching whether the small `EdgeUpdate` rename queue clears on the next ordinary reboot.

## 2026-07-04 - Early-July Read-Only Maintenance

Performed a read-only maintenance sweep over key-only SSH from the maintainer Mac. No Windows updates were installed, no reboot was triggered during this check, and no Veeam configuration, repository, firewall, or credential changes were made.

Repo/worktree note:

- The local git worktree was already dirty in unrelated `on-prem/esx-d` and `servers.com` paths before this maintenance pass. Those changes were left untouched.

Access and identity:

- Check time: `2026-07-04 17:46:22`.
- Host responded as `VEEAM`.
- Current identity remained `VEEAM\Administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.

Current host state:

- OS remained Microsoft Windows Server 2022 Standard, version `10.0.20348`.
- Last boot observed: `2026-06-17 21:51:44`.
- Reboot flags:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`

Storage and service state:

- `C:` used `76899786752`, free `51579080704`.
- `E:` used `29252629757952`, free `1533628710912`.
- SQL and remote-admin services remained at baseline:
  - `sshd`: `RUNNING`
  - `WinRM`: `RUNNING`
  - `MSSQL$VEEAMSQL2016`: `RUNNING`
  - `SQLAgent$VEEAMSQL2016`: `STOPPED`, matching baseline
  - `SQLTELEMETRY$VEEAMSQL2016`: `RUNNING`
- Sampled Veeam services were healthy:
  - `VeeamBackupSvc`: `RUNNING`
  - `VeeamBackupRESTSvc`: `RUNNING`
  - `VeeamBrokerSvc`: `RUNNING`
  - `VeeamTransportSvc`: `RUNNING`
  - `VeeamWebSvc`: `RUNNING`

Update and version state:

- Built-in Windows Update COM search returned `PendingUpdateCount=0`.
- `Veeam.Backup.Service.exe` still reported product version `13.0.2.29`.

Pending rename follow-up:

- The queue remained present but was still much smaller than the broad May 31 installer/runtime backlog.
- Current sampled queue content included:
  - `C:\Program Files (x86)\Microsoft\EdgeUpdate\1.3.241.13`
  - `C:\Config.Msi\3c2f1235.rbf`
  - `C:\Config.Msi\3c2f1254.rbf`
  - `C:\Config.Msi\3c2f125d.rbf`
  - `C:\Config.Msi\3c2f125f.rbf`
  - `C:\WINDOWS\Temp\DEL4FE9.tmp`
  - `C:\WINDOWS\Temp\DELDDD1.tmp`
- Interpretation: this still looks like lightweight updater/installer cleanup residue rather than incomplete Windows servicing.

Warnings and log signals:

- `Svc.VeeamBackup.log` continued to show the same warning-result trio on `2026-07-04`:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`
  - `Backup Job to ESXE`
  - `Replication`
- Continue treating those warnings as explained by backup-destination free space dropping below the `10%` warning threshold and SMTP/email warning behavior unless later evidence changes.

Next safest target:

- No patching action is waiting as of `2026-07-04`.
- The main item worth watching is repository free space on `E:`, which has dropped further to about `1.53 TB` free.

## 2026-07-19 - Mid-July Read-Only Maintenance

Performed a read-only maintenance sweep over key-only SSH from the maintainer Mac. No updates were installed, no reboot was triggered during this check, and no Veeam configuration, repository, firewall, or credential changes were made.

Access and identity:

- Check time: `2026-07-19 17:46:22`.
- Host responded as `VEEAM`.
- Current identity remained `VEEAM\Administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.

Current host state:

- OS remained Microsoft Windows Server 2022 Standard, version `10.0.20348`.
- Last boot observed: `2026-06-17 21:51:44`.
- Reboot flags:
  - CBS reboot pending: `False`
  - Windows Update reboot required: `False`
  - Pending file rename operations: `True`

Storage and service state:

- `C:` used `76899786752`, free `51579080704`.
- `E:` used `29252629757952`, free `1533628710912`.
- SQL and remote-admin services remained at baseline:
  - `sshd`: `RUNNING`
  - `WinRM`: `RUNNING`
  - `MSSQL$VEEAMSQL2016`: `RUNNING`
  - `SQLAgent$VEEAMSQL2016`: `STOPPED`, matching baseline
  - `SQLTELEMETRY$VEEAMSQL2016`: `RUNNING`
- Sampled Veeam services were healthy:
  - `VeeamBackupSvc`: `RUNNING`
  - `VeeamBackupRESTSvc`: `RUNNING`
  - `VeeamBrokerSvc`: `RUNNING`
  - `VeeamTransportSvc`: `RUNNING`
  - `VeeamWebSvc`: `RUNNING`

Update and version state:

- Built-in Windows Update COM search returned `PendingUpdateCount=5`.
- Pending updates sampled during this check:
  - `PowerShell LTS v7.4.17 (x64)`
  - `Security Update for SQL Server 2016 Service Pack 3 CU (KB5102339)`
  - `Windows Malicious Software Removal Tool x64 - v5.143 (KB890830)`
  - `2026-07 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5102206)`
  - `2026-07 Cumulative Update for Microsoft server operating system version 21H2 for x64-based Systems (KB5099540)`
- `Veeam.Backup.Service.exe` still reported product version `13.0.2.29`.

Pending rename follow-up:

- The queue simplified again compared with 2026-07-04.
- Current sampled queue content was limited to:
  - `C:\Program Files (x86)\Microsoft\EdgeUpdate\1.3.241.15`
- Interpretation: this still looks like lightweight updater housekeeping rather than incomplete Windows servicing.

Warnings and log signals:

- `Svc.VeeamBackup.log` continued to show the same warning-result trio on `2026-07-19`:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`
  - `Backup Job to ESXE`
  - `Replication`
- Continue treating those warnings as explained by backup-destination free space dropping below the `10%` warning threshold and SMTP/email warning behavior unless later evidence changes.

Next safest target:

- The next maintenance target is now the July 2026 Windows update cycle, followed by the usual reboot-and-recovery verification.
- Repository free space on `E:` remains worth watching; it was about `1.40 TB` free during this check.

## 2026-07-19 - July 2026 Windows Update Cycle Completed

With operator approval, installed the pending July 2026 updates on the standalone Veeam server over key-only SSH using a temporary scheduled task running as `SYSTEM`. No Veeam configuration, repository settings, firewall rules, or credential changes were made.

Pre-install notes:

- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Update discovery at the start of the maintenance window found `5` pending updates:
  - `PowerShell LTS v7.4.17 (x64)`
  - `Security Update for SQL Server 2016 Service Pack 3 CU (KB5102339)`
  - `Windows Malicious Software Removal Tool x64 - v5.143 (KB890830)`
  - `2026-07 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5102206)`
  - `2026-07 Cumulative Update for Microsoft server operating system version 21H2 for x64-based Systems (KB5099540)`
- Recent Veeam job-state sampling still showed only the known warning-result trio, not active running sessions.

Install path:

- Wrote `C:\ProgramData\format-server-ops\windows-update-2026-07-19.ps1`.
- Launched it through scheduled task `FormatServerOps-WindowsUpdate-Jul2026` as `SYSTEM`.
- Windows Update event logs confirmed successful install progression:
  - `PowerShell LTS v7.4.17 (x64)`
  - `KB5102339`
  - `KB890830`
  - `KB5102206`
  - `KB5099540`

Observed servicing behavior:

- SQL services bounced during the SQL security update, then recovered before reboot.
- `SQL Server CEIP service (VEEAMSQL2016)` logged one transient `7031` unexpected termination during servicing and then returned to `RUNNING`.
- Windows set:
  - `CBS reboot pending=True`
  - `Windows Update reboot required=True`
- `PendingFileRenameOperations` was also present pre-reboot.

Reboot sequence:

- An initial `shutdown.exe /r` request was accepted and logged under `User32 1074` at `2026-07-19 10:05:26` but took a long time to actually commit while Windows finalized servicing.
- A later `Restart-Computer -Force` attempt reported that a shutdown was already in progress.
- Observed availability checks showed the host drop and return during the reboot window, with the final post-update boot settling at `2026-07-19 10:14:03`.

Post-reboot verification:

- Check time: `2026-07-19 10:16:42`.
- Last boot observed: `2026-07-19 10:14:03`.
- Reboot flags cleared:
  - `CBS reboot pending=False`
  - `Windows Update reboot required=False`
  - `PendingFileRenameOperations=False`
- Built-in Windows Update COM search returned `PendingUpdateCount=0`.
- Post-update Windows Update event history showed successful installs for all five updates, including final success events for:
  - `PowerShell LTS v7.4.17 (x64)` at `2026-07-19 10:15:39`
  - `KB5102339` at `2026-07-19 10:15:40`
  - `KB890830` at `2026-07-19 10:15:41`
  - `KB5102206` at `2026-07-19 10:15:41`
  - `KB5099540` at `2026-07-19 10:15:43`
- Version state after reboot:
  - PowerShell 7: `7.4.17`
  - SQL Server `.\VEEAMSQL2016`: `13.0.7095.1`, `SP3`
  - Veeam Backup & Replication service executable: `13.0.2.29`
- Remote-admin baseline recovered:
  - `sshd`: `RUNNING`
  - `WinRM`: `RUNNING`
- SQL baseline recovered:
  - `MSSQL$VEEAMSQL2016`: `RUNNING`
  - `SQLAgent$VEEAMSQL2016`: `STOPPED`, matching baseline
  - `SQLTELEMETRY$VEEAMSQL2016`: `RUNNING`
- Veeam service recovery showed the normal short post-boot delay and then recovered:
  - `VeeamBackupSvc`: `RUNNING`
  - `VeeamBackupRESTSvc`: `RUNNING`
  - `VeeamBrokerSvc`: `RUNNING`
  - `VeeamTransportSvc`: `RUNNING`
  - `VeeamWebSvc`: `RUNNING`
- Disk state after updates:
  - `C:` used `81424248832`, free `47054618624`
  - `E:` used `29335708499968`, free `1450549968896`

Cleanup:

- Removed temporary scheduled task `FormatServerOps-WindowsUpdate-Jul2026`.

Interpretation:

- The July 2026 Windows update cycle completed successfully.
- The host returned with no remaining pending updates and no remaining reboot-pending flags.

## 2026-07-19 - Verification Reboot Cleared Runtime Rename Queue

After the completed July 2026 update cycle, a later same-day sanity check found:

- `PendingUpdateCount=0`
- `CBS reboot pending=False`
- `Windows Update reboot required=False`
- `PendingFileRenameOperations=True`

Read-only inspection of the queue showed it was dominated by:

- `C:\Program Files\dotnet\shared\Microsoft.NETCore.App\8.0.28\...`
- `C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\8.0.28\...`
- one `C:\Config.Msi\*.rbf` entry

Interpretation at that point:

- Windows patching was complete, but a large .NET runtime replacement queue remained.

With operator approval, rebooted the host again to see whether that queue would clear.

Reboot sequence:

- Reboot command accepted at `2026-07-19 19:19`.
- Host dropped from SSH at about `2026-07-19 19:19:32`.
- Host returned on SSH shortly after and settled with final observed boot time `2026-07-19 19:19:37`.

Immediate post-boot observations:

- Remote admin and SQL services returned first.
- Core Veeam application services (`VeeamBackupSvc`, `VeeamBackupRESTSvc`, `VeeamBrokerSvc`, `VeeamWebSvc`) took longer than SQL to recover, which matched fresh Application log entries showing Veeam locking the new `.NET 8.0.29` runtime files during startup.

Final verification after the delayed Veeam recovery:

- Check time: `2026-07-19 19:13:08` for the pre-reboot sanity pass, then `2026-07-19 19:21:04` after reboot flags re-check.
- Last boot observed after the verification reboot: `2026-07-19 19:19:37`.
- `PendingUpdateCount=0`
- `CBS reboot pending=False`
- `Windows Update reboot required=False`
- `PendingFileRenameOperations=False`
- Core services healthy:
  - `sshd`: `RUNNING`
  - `WinRM`: `RUNNING`
  - `MSSQL$VEEAMSQL2016`: `RUNNING`
  - `SQLAgent$VEEAMSQL2016`: `STOPPED`, matching baseline
  - `SQLTELEMETRY$VEEAMSQL2016`: `RUNNING`
  - `VeeamBackupSvc`: `RUNNING`
  - `VeeamBackupRESTSvc`: `RUNNING`
  - `VeeamBrokerSvc`: `RUNNING`
  - `VeeamWebSvc`: `RUNNING`
  - `VeeamTransportSvc`: `RUNNING`

Interpretation:

- The verification reboot cleared the post-update .NET runtime rename queue.
- The host is now clean from both a Windows Update perspective and a pending-rename perspective.

## 2026-08-04 - Early-August Read-Only Maintenance

Performed a discovery-first maintenance sweep over key-only SSH. No updates were installed, no cleanup or reboot was started, and no Veeam configuration, repository, firewall, credential, or backup data changes were made.

Access and identity:

- Check time: `2026-08-04 18:35:43`.
- Host responded as `VEEAM` under `VEEAM\Administrator`.
- Host remained standalone: `PartOfDomain=False`, `Domain=WORKGROUP`.
- Last boot remained `2026-07-19 19:19:37`.

Service and storage state:

- `sshd`, `WinRM`, `MSSQL$VEEAMSQL2016`, `SQLTELEMETRY$VEEAMSQL2016`, and sampled core Veeam services were running.
- `SQLAgent$VEEAMSQL2016` remained stopped and disabled, matching baseline.
- `C:` NTFS was healthy with `55820738560` bytes free of `128478867456`.
- `E:` `VeeamHDD` ReFS was healthy with `1162373693440` bytes free of `30786258468864`, or `3.78%` free.
- Both VMware virtual NVMe disks reported `Online` and `Healthy`; both mounted filesystems reported `Healthy` and `OK`.

Veeam state:

- `Veeam.Backup.Service.exe` remained version `13.0.2.29`.
- The latest `CURRENT JOBS` state in `Svc.VeeamBackup.log` showed the three configured jobs in `Stopped` state with `Warning` results:
  - `Backup Copy Job to NAS4\Backup Job to ESXE`
  - `Backup Job to ESXE`
  - `Replication`
- Continue treating these warnings as explained by the known repository free-space threshold and SMTP warning behavior unless later evidence changes.
- Installed component inventory showed the core Veeam server packages at `13.0.2.29`; the Windows Agent redistributable and VSS Hardware Provider were both `13.0.3.1220`, so the package inventory warning did not by itself establish a partial core-server upgrade.

Windows servicing state:

- Built-in Windows Update search returned one pending update: `PowerShell LTS v7.4.18 (x64)`; it did not currently require a reboot.
- `CBS reboot pending=False`.
- `Windows Update reboot required=False`.
- `PendingFileRenameOperations=True` with 22 registry entries representing 11 Edge updater and temporary installer paths, including `AetherInstallation`; no Windows servicing paths were observed.
- DISM component-store analysis reported `0` reclaimable packages and `Component Store Cleanup Recommended: No`.

Event review:

- Repeating Virtual Disk Service event `9` errors continued during short Virtual Disk service start/stop cycles, plus one event `6`/`8` pair on `2026-07-21` for a VMware virtual disk.
- Current Windows disk and volume health remained healthy, and no NTFS, ReFS, disk, or volume failure state was found during this inspection.

Next safest target:

- Complete a repository capacity and retention review before optional patching or reboot work. `E:` is now at `3.78%` free, well below the known `10%` Veeam warning threshold.
- After capacity risk is addressed, the single PowerShell update can be considered in a confirmed maintenance window, followed by a reboot only if explicitly approved and no backup session is active.

Repository capacity follow-up:

- Performed a read-only filesystem inventory; no backup content was opened, changed, or removed.
- `E:\VeeamBackups` contained 560 files with about `29.51 TB` logical size.
- `E:\VeeamBackups\Backup Job ESXE to ESX-B` accounted for about `26.74 TiB` logical size:
  - one `.vbk` full backup
  - 199 `.vrb` reverse-increment files
  - one `.vbm` metadata file
- The oldest reverse increment was dated `2025-10-09`; the newest was dated `2026-08-03`.
- Replica and configuration-backup folders were comparatively small at about `0.098 TiB` and `0.004 TiB` logical size.
- Compared with the post-update observation on `2026-07-19`, free space fell by about `288 GB` in 16 days. Retention behavior may make growth non-linear, so this is a trend signal rather than a time-to-full forecast.
- Historical retention logging showed a 200-day retention design, broadly consistent with the current 199 reverse increments plus one full backup. The current v13 retention setting could not be confirmed through the PowerShell API because the non-interactive local connection failed to connect to the Veeam Identity service.
- The Identity process and Veeam services remained running, and the Identity log showed certificate access and local-administrator validation rather than a crash. Do not infer a Veeam console outage from the non-interactive PowerShell failure alone.

Capacity conclusion:

- Windows cleanup cannot materially address the repository pressure; the component store has no reclaimable packages and `C:` has adequate headroom.
- The operator should review the intended 200-point retention requirement and available repository capacity in the Veeam console.
- Do not delete `.vbk`, `.vrb`, or `.vbm` files directly. Any retention reduction, chain maintenance, repository expansion, or data removal requires a separate reviewed Veeam change.

## 2026-08-23 - Late-August Read-Only Maintenance

Performed a discovery-first maintenance sweep over key-only SSH. No updates were installed, no cleanup or reboot was started, and no Veeam, repository, firewall, credential, or backup data changes were made.

Access and baseline:

- Check time: `2026-08-23 15:33:02`.
- Host remained `VEEAM`, administered as local `VEEAM\Administrator` in standalone `WORKGROUP`.
- Last boot observed: `2026-08-04 21:02:44`.
- Event history showed an administrator-initiated power-off on `2026-08-04 20:08`, followed by the current boot; no unexpected-shutdown event was found in that sequence.
- `sshd`, `WinRM`, SQL, and sampled core Veeam services were running.
- `SQLAgent$VEEAMSQL2016` remained stopped and disabled, matching baseline.
- Veeam remained version `13.0.2.29`.

Storage and retention:

- Both VMware virtual disks and mounted filesystems reported `Online`, `Healthy`, and `OK`.
- `C:` had `54902333440` bytes free of `128478867456` (`42.73%`).
- `E:` had `5116757868544` bytes free of `30786258468864` (`16.62%`).
- Repository headroom improved substantially from `3.78%` on `2026-08-04`.
- The primary chain contained one `.vbk`, 149 `.vrb` files, and one `.vbm` file.
- The `2026-08-21` primary backup log explicitly reported point retention count `150` and removed the oldest `.vrb` through Veeam retention.
- The same run completed its backup payload successfully with `10` of `10` tasks successful and no failed tasks.

Job and warning state:

- All three configured jobs were `Stopped` during inspection.
- Their latest payloads completed successfully:
  - primary backup: `10` of `10` tasks successful
  - backup copy: `10` of `10` tasks successful
  - replication: `10` of `10` tasks successful
- Each final session was marked `Warning` because SMTP server `192.168.1.6:25` rejected report relay with `5.7.54`, including the external `dany@dsl.lu` recipient.
- The primary backup was next scheduled for `2026-08-24 22:00`; replication was next scheduled for `2026-08-24 09:00`.

Windows servicing state:

- PowerShell 7 reported `7.6.4`; PowerShell LTS `7.4.18` also remained installed.
- Built-in Windows Update discovery returned four pending updates:
  - `KB890830` v5.144
  - `.NET` cumulative update `KB5121650`
  - `PowerShell v7.6.5 (x64)`
  - Windows Server cumulative update `KB5120242`
- `CBS reboot pending=False` and `Windows Update reboot required=False`.
- `PendingFileRenameOperations=True` contained 692 raw registry entries, 346 non-empty paths.
- Of those non-empty paths, 329 referenced .NET `8.0.29`; Windows Installer events from `2026-08-22` explicitly stated that removal of .NET `8.0.29` required a deferred restart after .NET `8.0.30` was installed.
- The queue also included six Edge updater paths, four `Config.Msi` rollback files, and five temporary paths.
- DISM component-store analysis reported `0` reclaimable packages and `Component Store Cleanup Recommended: No`.

Event review:

- Repeating Virtual Disk Service event `9` provider errors continued, but current disks and filesystems remained healthy.
- No new disk, NTFS, ReFS, or volume health failure was found.

Next safest target:

- In an approved maintenance window, install the four pending Microsoft updates and perform one reboot to complete both Windows servicing and the deferred .NET `8.0.29` removal.
- Reconfirm that no backup, copy, replication, restore, or maintenance session is active immediately before starting.
- After reboot, verify pending updates, all reboot indicators, the rename queue, remote access, SQL, Veeam service recovery, job state, and repository free space.

## 2026-08-23 - August 2026 Windows Update Cycle Completed

With operator approval, installed all four pending Microsoft updates and rebooted the standalone Veeam server. No Veeam configuration, repository, firewall, credential, retention, or backup data changes were made.

Pre-maintenance confirmation:

- Check time: `2026-08-23 15:37:29`.
- All three configured Veeam jobs were stopped.
- No active restore or repository-maintenance log signal was found.
- One long-lived `Veeam.Backup.Manager.exe` process was identified as `STARTINFRARESCAN`, not a backup or restore session.
- `C:` and `E:` were healthy; `E:` retained about `5.12 TB` free.

Update installation:

- Used temporary scheduled task `FormatServerOps-WindowsUpdate-Aug2026` running as `SYSTEM`.
- Windows Update found and successfully installed:
  - `Windows Malicious Software Removal Tool x64 - v5.144 (KB890830)`
  - `2026-08 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 (KB5121650)`
  - `PowerShell v7.6.5 (x64)`
  - `2026-08 Cumulative Update for Microsoft server operating system version 21H2 (KB5120242)`
- Overall download and install result codes were `2` (`Succeeded`).
- Each update returned result code `2` with `HResult=0`.
- Installation completed at `2026-08-23 15:52:42` and required reboot.
- CBS finalized `KB5120242` successfully with `HRESULT=0x00000000` and target build `20348.5499`.

Reboot and recovery:

- Planned reboot was requested at `2026-08-23 15:53:19` with reason `Operating System: Hot fix (Planned)` and comment `August 2026 maintenance updates`.
- Windows finished servicing before dropping SSH, then returned with boot time `2026-08-23 15:55:37`.
- SQL and remote-access services returned first.
- Veeam application services followed their normal delayed-start sequence while locking the .NET `8.0.30` runtime files.
- By `2026-08-23 15:58:54`, the full sampled Veeam service stack had recovered.

Final verification:

- Check time: `2026-08-23 16:00:06`.
- OS build: `20348.5499`.
- PowerShell 7: `7.6.5`.
- Veeam: `13.0.2.29`.
- Built-in Windows Update search returned `PendingUpdateCount=0`.
- Reboot and servicing indicators were all clear:
  - `CBSRebootPending=False`
  - `WindowsUpdateRebootRequired=False`
  - `PendingFileRenameOperations=False`
- .NET `8.0.29` no longer appeared in installed runtime inventory; .NET `8.0.30` remained active.
- Remote access and SQL were healthy:
  - `sshd`: running
  - `WinRM`: running
  - `MSSQL$VEEAMSQL2016`: running
  - `SQLTELEMETRY$VEEAMSQL2016`: running
  - `SQLAgent$VEEAMSQL2016`: stopped and disabled, matching baseline
- Key Veeam services were running:
  - `VeeamBackupSvc`
  - `VeeamBackupRESTSvc`
  - `VeeamBrokerSvc`
  - `VeeamCatalogSvc`
  - `VeeamCloudSvc`
  - `VeeamTransportSvc`
  - `VeeamWebSvc`
- All configured jobs remained stopped and retained their previously explained SMTP-warning result state.
- No post-boot Veeam, SQL, service-control, disk, NTFS, ReFS, or volume error was found.
- Storage remained healthy:
  - `C:` free `51916849152` of `128478867456` (`40.41%`)
  - `E:` free `5116758654976` of `30786258468864` (`16.62%`)

Cleanup:

- Removed temporary scheduled task `FormatServerOps-WindowsUpdate-Aug2026`.
- Removed the temporary update script and transcript from `C:\ProgramData\format-server-ops`.

Interpretation:

- The August 2026 Windows update cycle completed successfully.
- The deferred .NET runtime rename queue cleared in the same reboot.
- No further reboot or Windows cleanup is currently required.

## 2026-08-23 - System Files Cleanup

With operator approval, ran Windows Disk Cleanup against `C:` on the standalone Veeam server. No Veeam configuration, repository, retention, firewall, credential, or backup data was changed.

Scope and safeguards:

- Confirmed all three configured Veeam jobs were stopped before cleanup.
- Selected 20 system cleanup categories, including temporary files, error-reporting files, memory dumps, Defender cleanup, delivery-optimization files, setup logs, and thumbnail/cache content.
- Excluded `DownloadsFolder`, `Recycle Bin`, previous installations, Windows ESD files, discarded upgrade files, driver packages, language packs, and Windows Update Cleanup to preserve user data and rollback options.
- Used cleanup profile `8739`; its temporary registry selection flags and scheduled task `FormatServerOps-CleanMgr-Aug2026` were removed afterward.

Execution outcome:

- `C:` free space increased from `50998001664` bytes to `55191728128` bytes, a net gain of `4193726464` bytes, about `3.91 GiB`.
- Two cleanup processes were briefly observed concurrently. They and their DISM/Windows servicing workers were allowed to exit naturally; none was forcibly terminated.
- During cleanup, Windows restarted at `2026-08-23 21:49`. Event `1074` identified `C:\WINDOWS\system32\SystemSettingsAdminFlows.exe`, running as `VEEAM\Administrator`, as the initiator with reason `Other (Unplanned)` and no comment.
- The restart cleanly stopped the event log and interrupted the scheduled-task wrapper, which consequently reported task result `267014`; no unexpected-shutdown event was recorded.
- Post-cleanup boot time was `2026-08-23 21:50:00`.

Final verification:

- Cleanup profile flags remaining: `0`.
- Temporary cleanup task present: `False`.
- `cleanmgr`, DISM host, and Windows servicing worker processes remaining: `0`.
- `CBSRebootPending=False`, `WindowsUpdateRebootRequired=False`, and `PendingFileRenameOperations=False`.
- Both VMware virtual disks remained `Online` and `Healthy`; `C:` and `E:` remained `Healthy` and `OK`.
- `E:` retained `5116758851584` bytes free; no repository content was touched.
- All 22 expected running Veeam, SQL, SSH, and WinRM services recovered. `SQLAgent$VEEAMSQL2016` remained stopped/disabled as designed.
- The Veeam service log at `2026-08-23 21:53:21` confirmed all three configured jobs were still `Stopped`.
- No post-boot Veeam, SQL, disk, NTFS, ReFS, volume, or service-control error was found.

Interpretation:

- The system-files cleanup reclaimed about `3.91 GiB` and the server recovered cleanly from the restart that occurred during the operation.
- No additional cleanup or reboot is currently required.

## 2026-09-05 - Early-September Read-Only Maintenance

Performed a discovery-first maintenance sweep over key-only SSH. No update, reboot, cleanup, Veeam configuration change, component deployment, repository change, firewall change, or backup-data change was made.

Access and baseline:

- Check time: `2026-09-05 09:20:37`.
- Host remained `VEEAM`, administered as local `VEEAM\Administrator` in standalone `WORKGROUP`.
- Last boot observed: `2026-08-26 14:54:32`.
- SSH remained key-only with `PubkeyAuthentication yes`, `PasswordAuthentication no`, `PermitEmptyPasswords no`, and the local `Administrators` match block using `administrators_authorized_keys`.
- The administrator key file ACL remained limited to `SYSTEM` and local `Administrators`.
- The custom SSH firewall rule remained enabled for TCP `22` and scoped to `192.168.1.73` and `192.168.113.2`.

Veeam upgrade state:

- Veeam was upgraded on `2026-08-26` from the previously observed `13.0.2.29` release.
- `Veeam.Backup.Service.exe` reported base version `13.1.0.411`.
- Installed hot-update components and the Veeam client/server compatibility log reported `13.1.1.18`.
- The final setup attempt logged `Hot update 1 for Veeam Backup & Replication 13.1.0.411 finished with exit code: 0` at `2026-08-26 14:44:11`.
- Two earlier setup attempts logged an inaccessible installation package before the later successful run.
- Two administrator-initiated restarts occurred during the upgrade window at `14:01:01` and `14:51:55`; both stopped and restarted the event log cleanly, with no unexpected-shutdown event.

Service and storage state:

- SSH, WinRM, SQL, and sampled core Veeam services were running.
- `SQLAgent$VEEAMSQL2016` remained stopped and disabled, matching baseline.
- Both VMware virtual NVMe disks were `Online` and `Healthy`; `C:` and `E:` were `Healthy` and `OK`.
- `C:` had `42702860288` bytes free of `128478867456` (`33.24%`).
- `E:` had `6707367378944` bytes free of `30786258468864` (`21.79%`).
- The primary repository chain remained one `.vbk`, 149 `.vrb` files, and one `.vbm` file.
- The newest `.vbk` was written during the `2026-09-04` primary run; no repository file was opened, modified, or deleted during inspection.

Windows servicing state:

- Built-in Windows Update search returned `PendingUpdateCount=0`.
- `CBS reboot pending=False` and `Windows Update reboot required=False`.
- `PendingFileRenameOperations=True` contained 50 non-empty paths: 25 `Config.Msi` rollback files, 24 temporary paths, and one updater path. No Veeam or Windows servicing path was observed.
- DISM component-store analysis reported zero reclaimable packages, zero cache/temporary data, and `Component Store Cleanup Recommended: No`.

Job state and new failure:

- All three configured jobs were stopped at the time of inspection.
- Latest job results were:
  - backup copy: `Warning`
  - primary backup: `Failed`
  - replication: `Warning`
- The primary run started on `2026-09-04 22:00`; its retry completed on `2026-09-05 00:43` with seven failed tasks and no transferred retry data.
- `Exchange3`, `File`, and `VMware vCenter Server` completed successfully in the original run.
- `Admin`, `PDC`, `Easyjob3`, `Tim`, `Kuhnle`, `Lmr`, and `BDC` failed during guest-processing startup with remote SCM/RPC, guest-agent, or Veeam Installer Service connectivity errors.
- The failing logs referenced RPC error `1722`, unavailable installer endpoint TCP `11731`, and failed fallback deployment. This is a real backup failure, not merely the established SMTP relay warning.
- Read-only TCP checks from Veeam found ports `135` and `445` reachable on six of the seven failed guests; TCP `11731` was not reachable on any of them. `Admin` did not respond on any of the three tested ports.
- A closed `11731` while jobs are stopped does not by itself distinguish a stopped or stale installer service from firewall filtering, but it is consistent with the job logs and recent server upgrade.
- The only sampled `Veeam.Backup.Manager.exe` worker was the known infrastructure-rescan operation, not a backup or restore session.

Event review:

- The known Virtual Disk Service event `9` provider warning recurred, while current disks and filesystems remained healthy.
- One `ekrn.exe` application crash was logged on `2026-09-01`; the ESET service and firewall helper were running during inspection.
- No current Veeam, SQL, NTFS, ReFS, disk, or volume failure state was found on the Veeam server itself.

Next safest target:

- Before the next primary run, review the Veeam managed-server/component status and guest interaction configuration in the Veeam console, beginning with a read-only infrastructure rescan result review.
- Determine whether the seven guests require a Veeam component upgrade/redeployment or whether guest firewall/RPC policy changed after the Veeam `13.1` upgrade.
- Any rescan that deploys components, credentials test that changes state, guest firewall change, or job retry requires separate approval and coordination with the affected guest-server runbooks.
- Do not reboot or clean Windows now: no updates are pending, the component store has nothing reclaimable, and a reboot would not address the demonstrated guest connectivity failure.

## 2026-09-05 - Veeam Guest Component Repair

Maintainer: Codex with Peter

Investigated the failed primary backup and failed component upgrades without changing Veeam jobs, repositories, retention, credentials, firewall policy, or backup data. The affected persistent component hosts were `Tim` (`192.168.1.12`) and `Admin` (`192.168.1.11`).

Root cause and recovery:

- Both guests retained Veeam Installer Service executable `13.0.1.180` after the Veeam server moved to hot-update component level `13.1.1.18`; their Installer Services were Automatic but stopped.
- The `2026-08-26` guest logs showed the Veeam-driven update timing out while stopping `VeeamDeploySvc` (`0x0000041d`), leaving the deployment DLL at `13.1.1.18` but the service executable stale.
- Starting the existing services restored Veeam management reachability on TCP `6160` and `6162`.
- A first controlled replacement test on `Tim` failed because the newer service could not load its required Veeam OpenSSL FIPS provider. The old executable was restored automatically and the service returned to Running.
- Installed the signed Veeam `OpenSSL FIPS Redistributable 3.1.2` package, version `3.1.2.2`, on both guests using the license and managed-install properties recovered from Veeam's own successful setup logs.
- Replaced each stale Installer Service executable with Veeam's signed `13.1.1.18` package copy. The old `13.0.1.180` executable remains as a rollback file on each guest until a successful backup proves the repair.
- Upgraded `Veeam Guest Interaction Proxy Service` on both guests and `Veeam Backup Transport` on `Tim` with the signed Veeam server packages and the exact Veeam-managed MSI parameters recorded in prior successful guest-install logs. Admin's Transport component was already current.

Verification:

- `Tim` and `Admin` now report signed `13.1.1.18` Installer, Transport, and Guest Interaction executables.
- `VeeamDeploySvc`, `VeeamTransportSvc`, and `VeeamGuestInteraction` are Automatic and Running on both guests.
- TCP `6160`, `6162`, and `6190` listen locally and are reachable from `VEEAM` on both guests.
- No CBS or Windows Update reboot flag was introduced; no reboot was performed.
- The signed staging packages were removed from the Mac and guest temporary directories. Veeam-owned upload payloads and repair logs were retained.
- Veeam short-name DNS resolution for `Tim` and `Admin` was unavailable from the standalone server, but its IP-based component paths were reachable. No DNS, hosts-file, firewall, domain, or remote-admin policy was changed.
- A scheduled `STARTHEALTHCHECKJOB` repository health check remained active during final verification. Its repository-only work did not overlap the repaired guest services, and it was not interrupted.

Follow-up:

- Confirm that the next primary backup completes guest processing for the seven previously failed VMs before deleting the two rollback executable copies.
- If the next run still fails for guests without persistent components, inspect that run's exact temporary deployment/RPC errors before changing guest firewall or credential policy.

## 2026-09-13 - Maintenance Inspection and Backup Recovery Verification

Performed read-only discovery on Veeam around `12:04-12:07` local time. No updates, reboot, cleanup, component deployment, configuration changes, or backup-data changes were performed. Existing unrelated repository edits were preserved.

Current state:

- VPN route and key-only `win-veeam` access worked. Identity remained local `VEEAM\Administrator` in `WORKGROUP`.
- Last boot: `2026-09-05 21:31:20`; Windows image build `20348.5499`. Veeam server base executable remained `13.1.0.411`, with deployment component `13.1.1.18`.
- All enumerated automatic Veeam, SQL, SSH, and WinRM services were running. SQL Agent remained disabled/stopped.
- Both disks were Online/Healthy. `C:` free: `42137509888` of `128478867456` bytes (`32.80%`). `E:` free: `6714809909248` of `30786258468864` bytes (`21.81%`).
- Primary repository inventory remained one VBK, 149 VRB, and one VBM. No repository content was modified.
- SSH retained key-only settings and the custom allowed source scope `192.168.1.73,192.168.113.2`.

Backup incident verification:

- Primary backup on `2026-09-11` completed at `23:22:45` with 10 successful tasks and zero failures.
- Individual primary task logs confirmed Success for Admin, PDC, Easyjob3, Tim, Kuhnle, Lmr, and BDC, as well as Exchange3, File, and VMware vCenter Server.
- NAS4 backup copy completed at `2026-09-12 00:45:33` with 10 successful tasks and zero failures.
- Replication completed at `2026-09-11 16:52:40` with 10 successful tasks and zero failures.
- All three final Warning results followed SMTP relay rejection `5.7.54` from the configured email server. The earlier guest-processing backup failure is resolved in this observed cycle; no restore test was performed.
- Today's configuration-backup log confirmed a new configuration backup was created, followed by the same email warning.
- All three configured jobs were Stopped in the latest state block. Only a `STARTINFRARESCAN` manager worker was observed; no backup or health-check worker was observed.
- Rollback copies on Tim/Admin were not revisited or deleted during this Veeam-only inspection.

Windows servicing and cleanup:

- Windows Update search found four downloaded updates: `KB890830` v5.145, .NET cumulative update `KB5126149`, PowerShell `7.6.6`, and Windows Server cumulative update `KB5122882`.
- CBS and Windows Update reboot flags were False. Seven non-empty pending rename paths referenced `vsepamsi` backup DLLs, Config.Msi rollback files, and driver staging files; the queue was preserved.
- DISM analysis completed successfully: actual component store `7.71 GB`, zero cache/temporary data, zero reclaimable packages, cleanup not recommended. Last recorded component cleanup was `2026-09-08 19:56:24`.

Event and time follow-ups:

- TPM-WMI `1796` repeated 17 times over the sampled eight days: SBAT Secure Boot update failed because a file was not found. Secure Boot currently reports enabled; no firmware or registry repair was attempted.
- Windows Time reported free-running/unsynchronized. The configured standalone peer is `time.windows.com,0x9`; all three diagnostic NTP probes timed out with `0x800705B4`.
- VMware Tools synchronization reports enabled and the sampled guest UTC matched the maintainer UTC to the second. This does not prove ongoing NTP synchronization. Earlier VMware precision-clock provider events reported no precision clock device.
- One historical SSH service termination and two iSCSI connection errors occurred on September 5. SSH and local disks are currently healthy; no current Veeam, SQL, disk, NTFS, or ReFS error appeared in the sampled event set.

Next maintenance step:

- Install the four downloaded updates in a maintenance window, with a fresh job/worker check and controlled reboot followed by service, storage, update, and backup-state verification. A reboot temporarily interrupts the standalone backup server and its repository services.
- Review the NTP path and Secure Boot servicing errors separately. No component-store cleanup is currently recommended.

## 2026-09-13 - Operator Updates and Time-Source Clarification

The operator started Windows Update and recalled WatchGuard `192.168.1.253` as the intended NTP server. Follow-up discovery at `12:14` found:

- `KB890830` installed successfully; .NET `KB5126149` and Windows cumulative update `KB5122882` had installation-start events. Windows servicing workers were active and both CBS and Windows Update reboot flags were True. Full installation completion and reboot recovery remain unverified.
- Windows Time remained configured for `time.windows.com,0x9`, with that peer Pending and no successful Windows Time synchronization recorded.
- VMware Tools service was Running and `VMwareToolboxCmd timesync status` reported enabled. This confirms the guest host-synchronization setting, but does not establish ESX-E's upstream NTP source.
- Four read-only NTP samples from Veeam to `192.168.1.253` all succeeded, with offsets between `+0.0006891` and `+0.0007977` seconds. The gateway offers a reachable NTP endpoint and closely agrees with the current guest clock; it is not currently selected as the Windows peer.
- No time configuration change, forced resynchronization, additional update installation, or reboot was initiated by Codex.

## 2026-09-13 - Cross-Server Time Audit

At the operator's request, expanded read-only time discovery to the on-prem domain servers and NAS4. Full matrix, source references, access limitations, and proposed corrections are recorded in [On-Prem Time Synchronization](../../time-synchronization.md).

- PDC emulator role and live time source were verified: PDC uses WatchGuard `192.168.1.253`; BDC follows PDC; all seven checked domain members use `NT5DS` and successfully synchronize with PDC or BDC.
- VMware periodic synchronization is disabled on PDC/BDC but enabled on all seven domain members and standalone Veeam. Startup/resume settings remain unverified.
- Veeam's Windows peer remains Pending at `time.windows.com,0x9`; Windows Time reports unsynchronized. Both WatchGuard candidate `.1.253` and Veeam's actual default gateway `.90.253` answer NTP with sub-millisecond offsets from Veeam.
- NAS4 runs chrony and is synchronized to `.90.253`. Every checked domain machine was within 4.5 ms of `.1.253` in three diagnostic samples.
- ESX-C/D/E SSH connections were refused, the configured vCenter key was missing, and Lportainer was unreachable through the current path. Their upstream time configurations could not be established.
- Recommended keeping the domain hierarchy and using explicit local-gateway NTP for standalone Veeam, then disabling VMware periodic synchronization where native time service is verified. No configuration changes or reboots were performed.

## 2026-09-13 - Veeam Gateway Time Configured

With operator approval, changed time configuration on standalone Veeam only, around `12:28-12:29` local time.

- Reconfirmed local Veeam/WORKGROUP identity and reachable gateway `192.168.90.253`, with pre-change offsets below 1 ms. No active backup manager or TiWorker/TrustedInstaller process was observed; the known infrastructure-rescan worker remained present.
- The operator's update cycle had recorded successful MSRT and PowerShell installations. Windows/.NET cumulative-update completion remained reboot-dependent; CBS reboot flag was True. No reboot was initiated.
- Changed Windows Time manual NTP peer from `time.windows.com,0x9` to `192.168.90.253,0x8` and startup from Manual to Automatic.
- Initial rediscovery reported that Windows Time was shutting down. Inspection found a clean service stop, exit code 0. Started the service again and repeated rediscovery successfully.
- Windows Time events 37/35 confirmed valid NTP data and synchronization with the gateway; status reported leap indicator 0, stratum 4, and successful synchronization at `12:28:59`.
- After native NTP synchronization was verified, disabled VMware Tools periodic synchronization on Veeam. Post-change status reported Disabled and NTP diagnostic offsets were `+0.0001507` to `+0.0001747` seconds.
- Startup/resume synchronization settings and the registered VMware precision-clock provider were left unchanged. Other servers, domain policies, firewall rules, and Veeam jobs/repositories were not modified.
- Reverify Windows Time source, service startup, and VMware periodic status after the operator's pending Windows update reboot.

## 2026-09-13 - Published Veeam Build Check and Restart Status

Read-only verification around `12:35-12:36`, following the operator's restart request:

- Installed Veeam Backup & Replication product and updater plug-in report `13.1.1.18`; Core/Common DLLs agree. The server executable and base MSI entries remain `13.1.0.411`, so those alone do not describe the installed patch level.
- [Veeam build list](https://www.veeam.com/kb2680) and [current downloads](https://www.veeam.com/products/downloads/latest-version.html?tab=current), checked today, both list `13.1.1.18` as the latest published Backup & Replication build. The Windows download is dated September 8 but retains that build number. No newer public VBR build was found; no upgrade or download was initiated.
- Windows recorded planned restart event `1074` at `12:34:47`. At `12:36`, the last boot was still `2026-09-05 21:31:20`, with TiWorker/TrustedInstaller active and CBS, Windows Update, and pending-rename markers present. The requested restart had not yet completed; no second restart or servicing intervention was attempted.
- All sampled Veeam services and the SQL instance were Running. Windows Time remained Automatic/Running, synchronized to `192.168.90.253,0x8` at stratum 4, with last successful sync `12:35:23`; VMware periodic synchronization remained Disabled. These are pre-reboot findings, not post-reboot verification.
- Next check: confirm a new boot timestamp, servicing reboot markers, service recovery, and persistence of gateway time synchronization after Windows finishes the requested restart.

## 2026-09-13 - Post-Reboot Verification

Read-only checks at `12:45-12:47` confirmed the operator's update restart completed. No additional update installation, reboot, cleanup, or configuration change was performed.

- New boot timestamp: `2026-09-13 12:38:18`; Windows build `20348.5622`.
- Windows Update installation history reports Succeeded (`ResultCode=2`, `HResult=0`) for all four updates: MSRT `KB890830` v5.145, .NET `KB5126149`, PowerShell `7.6.6`, and Windows cumulative update `KB5122882`.
- CBS reboot pending, Windows Update reboot required, and pending file rename indicators are all False. No fresh available-update search was performed.
- All enumerated Veeam services, SQL instance, SSH, WinRM, and Windows Time were Automatic/Running. SQL Agent remained Disabled/Stopped, matching baseline.
- Gateway time survived reboot: source `192.168.90.253,0x8`, stratum 4, leap indicator 0, last successful sync `12:44:54`. VMware Tools periodic synchronization remained Disabled.
- Both mounted volumes were Healthy. `C:` had `39344189440` bytes free of `128478867456`; `E:` had `6714809843712` bytes free of `30786258468864`.
- Service and OS recovery are verified. A new post-reboot backup/restore cycle was not run or verified during this check; the latest successful primary/copy/replication evidence remains the September 11-12 cycle recorded above.
