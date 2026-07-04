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
