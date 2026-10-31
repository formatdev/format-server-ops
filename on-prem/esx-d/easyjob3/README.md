# EASYJOB3 Runbook

Operational runbook for the `Easyjob3` VM on ESX-D.

Placement note, verified in authenticated vCenter on 2026-10-31 at about 21:48: Easyjob3 is powered on **192.168.5.203** again. Peter migrated it to .205 during .203's firmware maintenance, then back; vCenter records the return migration completed at 21:47:01. ESX-D is Connected with HA Connected (Secondary), still ESXi 8.0.3 build 24674464 (Update 3e). No migration was performed by Codex.

Last updated: 2026-10-31

## Known State

- VM name in vCenter: `Easyjob3`
- Expected Windows hostname: `EASYJOB3`
- Expected SSH aliases: `win-easyjob3`, `winad-easyjob3`
- Earlier repo notes: [easyjob3-inventory.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/easyjob3-inventory.md) and [easyjob3-health-check-2026-04-05.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/easyjob3-health-check-2026-04-05.md)

## Earlier October 31 Checks

Chronological checkpoints below are superseded where noted by the final Secure
Boot repair, VBS runtime and completed snapshot-cleanup sections later in this
runbook. Their older boot times and pending-warning states are not the final state.

- Post-policy reboot October 31: Windows Server 2025 Standard build `26100.33650`, last boot **19:41:10** after Peter's second restart. PDC secure-channel checks at 19:46 and 19:47 both return **True**, followed by nltest PDC status **0**. The Easyjob3-only RPC value 0 and its RSoP source survived reboot, with incoming NTLM still blocked. Local and domain SSH work, time is synchronized to PDC, and WinRM remains intentionally disabled by GPO. CBS/WU reboot markers are clear and pending file-operation count is zero. The earlier SYSTEM Windows Update search offered zero updates; it was not repeated during this recovery check.
- All six production SQL Server 2019 Standard instances report `15.0.4500.2`; all 48 enumerated databases are online.
- Peter's Easyjob update is verified: installed/client version `6.28.2.73`, shared server binary `6.28.2.72`. Server Service, Task Scheduler and WebApi are running. Peter confirms Mobile Device Service, Print Server and High Performance Scaler are unused; their Stopped/Automatic state is intentional, not an open availability issue. Their start modes were not changed. SQL records a fresh easyjob6 full backup at 19:07:11; no restore test was performed.
- Repair completed October 31 at 18:46 local: the separately approved SYSTEM RestoreHealth succeeded and repaired all 40 detected component payloads. SFC subsequently repaired protected files; a separate SFC verification-only pass found no integrity violations. Final CheckHealth reports no component-store corruption. All three one-off tasks returned 0 and were removed after completion; reports remain in Windows Logs. No repair task is still running.
- The failed direct repair's WU access-denied searches were avoided in SYSTEM context, which successfully acquired the repair content. No ACL, GPO, firewall or endpoint-protection change was needed. Codex performed no reboot or SQL service stop during repair; Peter later restarted the VM. Component-store health still passes after that reboot, and the latest pending-file-operation query has zero nonempty entries.
- Latest C: free space at 21:48 is approximately 12.41 GiB of 148.65 GiB (earlier post-reboot sample: 14.45 GiB). Temporary repair staging earlier reduced the lowest sampled free space to 6.03 GiB before native cleanup recovered it; the authorized near-4-GiB cancellation threshold was not observed and no cancellation was needed. Disk 0 is 150 GiB with no unallocated extent. Plan capacity headroom after checking VMware datastore capacity; do not delete SQL/application data to make room.
- Earlier supported component cleanup partially reclaimed about 7 GiB but failed twice during catalog scavenging. The original catalog has a valid Microsoft signature, Normal attributes and permissions matching sampled neighbors; System and WatchGuard/Panda were observed as current file users, not proven causes. This cleanup was not retried after repair, so its catalog-deletion blockage is not claimed resolved. Do not force-delete servicing files or take ownership; see the maintenance log for evidence and retained log paths.
- Authorized domain-policy follow-up: the separate `EASYJOB3 - RPC endpoint mapper compatibility` GPO (`97f95ddc-2bf8-4c18-a40c-2977cef6e29d`) applies only to `EASYJOB3$`. Its sole setting is `EnableAuthEpResolution=0`, verified at RSoP precedence 1 before and after Peter's 19:41 reboot. **The previously observed PDC trust failure is now resolved in repeated live checks.** Default Domain Policy and the Exchange-only policy contents/security were preserved, with no NTLM relaxation or machine-password reset. Backups and before/after reports are on PDC under `C:\ProgramData\Codex\GPO-Backups\EASYJOB3-RPC-20261031-1938`. All 48 SQL databases and the three core Easyjob services remain online; DISM CheckHealth reports no corruption. See the maintenance log for scope, backup IDs and rollback.
- Remaining post-boot findings: one early Netlogon 5719 event, the `dggpext.dll` policy-extension failure, recurring VMware precision-time-provider errors despite current PDC synchronization, Secure Boot certificate/KEK firmware warnings, and PSINFile/RsFx0603 bypass-IO warnings. SSIS is running despite a default-configuration fallback warning; Windows licensing reports LicenseStatus 1 despite an SPP grace-timer event. No matching SQL engine, application-crash, disk or NTFS error appeared in the bounded post-boot event sample. Peter reports the rest is OK and confirms the three optional Easyjob services are unused; no authenticated application workflow was performed by Codex.
- Warning investigation at 19:53-19:55: Secure Boot is enabled, but PK is the 45-byte NULL placeholder and the sampled KEK lacks the Microsoft 2023 name. Windows servicing reports `InProgress`, `Firmware_MissingKEKInPackage`, error `0x80070002` / event 1803. Windows reports no TPM; current authenticated ESXi build and VM hardware configuration must be verified before selecting Broadcom's supported key-remediation method. VMware Tools is already 13.1.5. `vmwTimeProvider` is enabled without the precision clock device; Broadcom recommends removing that optional Tools component when using AD/NTP, with a planned reboot. Do not disable W32Time or the AD time source.
- Subsequent authorized removal at 20:06:47-20:06:56: VMware Tools MSI returned 0; only `VmwTimeProvider` changed from installed to absent. Provider registry registration and DLL are absent, with every other MSI feature unchanged. Configuration backup, feature manifests and installer log are retained under `C:\ProgramData\Codex\Maintenance\Easyjob3-TimeProvider-20261031`. All 48 SQL databases, Easyjob core/endpoint services, VMware Tools and Windows Time remain online; PDC trust passes and nltest reports BDC status 0. Windows time source remains PDC. No reboot or time-service restart was performed; boot remains 19:41:10 and CBS/WU/pending-file flags are clear. Validate absence of new provider errors after the next separately approved reboot; full runtime/post-reboot validation is not yet complete.
- Latest authenticated vCenter follow-up at 21:48 supersedes the temporary .205 placement: .203 is back Connected and hosts Easyjob3. Peter confirms the earlier downtime/migrations were intentional firmware work. This did not update ESXi, which remains Update 3e, older than Broadcom's 8.0 U3j automated NULL-PK remedy. VM hardware remains version 21, EFI/Secure Boot enabled, with no configured security device/guest TPM. Preferred Secure Boot plan: assess HPE/vCenter-compatible ESXi 8.0 patching (U3j or newer), then use the eligible no-vTPM automatic PK repair and native Windows KEK servicing. Manual EFI enrollment is a more intrusive fallback, requiring separate backup/outage and temporary authentication-bypass approvals. No boot-key or vSphere setting change was made.
- VBS remains configured but **not running**. Read-only CPU settings now explicitly confirm hardware virtualization exposure and I/O MMU both unchecked; VMware VBS is also unchecked. **Try properly enabling VMware VBS during an approved shutdown before reducing the domain DMA requirement.** Broadcom documents that VMware VBS enables nested virtualization/IOMMU support. Retest the current policy first; a separately scoped compatibility GPO is only a contingency if a prerequisite remains unsupported. Existing Credential Guard/HVCI UEFI-lock settings and endpoint-agent compatibility need review before production activation; current Code Integrity 3033 events concern Panda's protected process rejecting ESET/VMware AMSI DLLs, not proof of HVCI driver incompatibility. Keep NTLM blocking and the working RPC override intact. The inspection dialog was cancelled without saving.
- At 21:47, PDC trust passes and nltest reports BDC status 0, confirming a usable BDC connection again. Cross-DC replication convergence was not tested in this follow-up. Time initially reported unsynchronized following the migrations, then recovered by 21:50:05 with PDC source, leap 0/stratum 6 and sampled PDC offsets around -0.004 seconds. No time repair/resync or service restart was performed. No new removed-provider warning was found since 20:06:56; post-reboot validation remains pending because the guest boot is still 19:41:10.

## Latest Secure Boot Repair

October 31 at 22:45 supersedes the NULL-PK and pending-servicing findings above.
Peter performed the guided manual EFI enrollment and reports removing the
temporary authentication bypass/disk before normal startup. Live SSH confirms
Secure Boot True and Windows OEM Devices PK, thumbprint
`3D8660C0CB2D57B189C3D7995572A552F75E48B5`.

After Peter explicitly authorized the native Secure-Boot-Update task without
reboot, Codex launched it once at 22:44:30. It completed successfully (final
Ready/result 0). EFI KEK now includes Microsoft Corporation KEK 2K CA 2023,
thumbprint `459AB6FB5E284D272D5E3E6ABC8ED663829D632B`. Windows reports
UEFICA2023Status Updated; earlier error fields are absent, AvailableUpdates is
0x4000, and event 1043 at 22:44:38 confirms KEK application. No 1808 was observed
in the bounded sample; completion is supported by Updated plus actual key/event
evidence, not an invented 1808. Boot remains 22:39:33: no reboot occurred.

All 48 databases across six production SQL instances remain online, three core
Easyjob services run and PDC trust passes. C: free is 14.05 GiB. The temporary
disk is absent from the guest; bypass removal remains operator-reported, not
independently rechecked in vCenter. Snapshot retained pending operator Easyjob
workflow and separately authorized snapshot cleanup. VBS remains configured/not
running and needs a separate compatibility/recovery review and change approval.
Do not reset update flags, manually enroll other keys or assume this patches ESXi.

Peter subsequently confirms the Easyjob application workflow works. VBS preflight
at 22:50-22:54 confirms Windows still requires Secure Boot plus DMA and enables
Credential Guard/HVCI with UEFI-lock policy values; VBS remains configured/not
running. Authenticated vCenter confirms VM VBS unchecked, EFI/Secure Boot enabled,
Force EFI Setup unchecked and no uefi.allowAuthBypass entry in the displayed
advanced parameter inventory. Settings dialog was cancelled without saving.
MSA_PERFHDD is Normal, 3.51 TB free of 19.15 TB; existing snapshot is Before Secure
Boot repair (22:18), not a checkpoint of the newly repaired state. Before VBS
activation, arrange graceful shutdown, a fresh powered-off Before VBS snapshot
and separate current VMX/NVRAM recovery copies without overwriting the original
pre-repair copies. No power/snapshot/configuration change has been made by Codex.
Sampled kernel-compatibility events are absent but do not certify all drivers;
existing ESET/WatchGuard/VMware protected-process signing warnings persist.
Retain the existing policy for the initial scoped test; UEFI-lock recovery needs
console/offline recovery capability, not just a promise to uncheck VBS remotely.

## Saved VBS Configuration (Before Startup)

At 22:59 on October 31, authenticated vCenter confirms Easyjob3 is Powered Off
on .203 with VM VBS enabled, hardware-assisted virtualization exposure checked,
virtual I/O MMU enabled, EFI/Secure Boot enabled and Force EFI Setup unchecked.
Network adapter Connect At Power On is checked. This supersedes the earlier
unchecked VM settings, but does not prove Windows VBS/HVCI is running yet.
Peter saved the VM setting; Codex inspected and cancelled without changes or
powering on. Windows policy and endpoint protection were not changed.

Fresh powered-off snapshot Before VBS - Secure Boot repaired was independently
verified at 22:55, with memory No, after the successful Secure Boot repair.
Separate 22:56 VMX/NVRAM recovery copies are present in Peter's step 2 recovery
folder, preserving the original copies. Both snapshots remain; neither was
created or deleted by Codex. Next step is operator startup with console available,
then actual Windows VBS/Credential Guard/HVCI, Secure Boot, SQL, trust and Easyjob
verification. Those subsequent runtime results are recorded below; the saved
VMware checkbox alone was not treated as runtime proof.

## Latest VBS Runtime Check

After Peter's second normal boot at 23:05:44 on October 31, live domain SSH
verification at 23:07 confirms VBS status 2/running and SecurityServicesRunning
1,2: **Credential Guard and memory integrity/HVCI are both running**. This
supersedes the first-boot partial result. HvHost is now Running/Manual, with no
matching startup failure in the new bounded sample. DeviceGuard policy event
7000 again reports success/status 0. System Guard Secure Launch (service 3)
remains configured/not running; it is separate from the verified HVCI result.

All 48 SQL databases are online; three core Easyjob services, SSH, Tools, Netlogon
and Windows Time run. PDC trust True; nltest BDC status 0. Secure Boot True,
UEFICA2023Status Updated and prior error fields absent. RPC override 0 and
incoming NTLM block 2 persist; WinRM Disabled is intentional. C: free 14.65 GiB,
free memory 11.65 GiB, time synchronized to BDC. No critical/error Application
events or specifically sampled kernel CI blocking events since this boot.

Not warning-free: new Kerberos event 9 at 23:06:18 says PDC certificate revocation
checking could not reach its revocation server; Netlogon 5719 follows before
successful current PDC/BDC trust checks. Investigate CRL availability and recurrence
separately without disabling revocation checks. Known filter bypass-IO, DCOM and
Panda protected-process signing messages persist; no claim that HVCI activation
clears these. Peter subsequently confirms Easyjob works with HVCI active and
explicitly authorizes snapshot cleanup, completed as recorded below. No further
restart, GPO, registry, driver, endpoint or host change was made.

## Snapshot Cleanup Completed

Peter confirmed no active Veeam work involving Easyjob3 and gave final explicit
approval to permanently remove both maintenance snapshots. vCenter Remove all
snapshots completed successfully on October 31, 23:17:03-23:17:34. Snapshot
Management now reports No snapshot available. Read-only disk inspection confirms
active backing `[MSA_PERFHDD] Easyjob3/Easyjob3.vmdk`, not a numbered snapshot
delta. No revert, guest shutdown, reboot or manual datastore-file deletion occurred.

At 23:18:14 postchecks confirm unchanged boot 23:05:44, VBS running with Credential
Guard/HVCI services 1,2, Secure Boot True/Updated, PDC trust True, all 48 databases
ONLINE and required Easyjob/HvHost/Tools services Running. No System/Application
critical/error events were found in the bounded operation-time sample. Recovery
downloads were left untouched; the historical VMX copies reference snapshot-era
disk chains and must not be blindly restored over this now-consolidated VM.
The two snapshot rollback points are permanently gone. Remaining CRL/signing/
bypass-IO warnings and inactive Secure Launch are separate follow-up items.

## First Checks

```sh
ssh win-easyjob3 hostname
ssh winad-easyjob3 hostname
```

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
Get-Service sshd,WinRM,Spooler
Get-Volume
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

