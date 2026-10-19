# EXCHANGE3 Runbook

Starter runbook for the `Exchange3` VM on ESX-D.

Last updated: 2026-10-18

## Known State

- VM name in vCenter: `Exchange3`
- Expected Windows hostname: `EXCHANGE3`
- Expected IP from local SSH config: `192.168.1.6`
- Expected SSH aliases: `win-exchange3`, `winad-exchange3`
- Role: Microsoft Exchange server, verify exact version and topology before maintenance

## Safety Rules

- Treat as production mail infrastructure.
- Do not reboot, patch, change certificates, or restart Exchange services without explicit confirmation.
- Check transport queues and Exchange service health before and after maintenance.

## 2026-10-18 Mailbox Access Recovery

- Incident: both databases reported Mounted, but live MAPI access failed with MapiExceptionMdbOffline / Microsoft System Attendant errors; 77 messages were waiting for mailbox delivery. The interactive desktop also failed to start normally. Server/transport components were Active, domain trust passed against PDC and BDC, and the existing RPC compatibility value remained `0`.
- Peter confirmed a successful backup from the previous day and no running backup jobs, then authorized a normal server restart. A graceful Windows restart without forced application closure completed; verified boot time is 2026-10-18 22:21:32 Luxembourg time. No database repair, manual dismount, queue deletion, policy change or host restart was performed.
- Both databases logged successful mounts at 22:22:35; all automatic Exchange services recovered. By 22:24:49, all sampled total transport queue-length counters were zero and the post-reboot mailbox-delivery log contained 82 DELIVER records. The identified external resend to Peter's mailbox was delivered at 22:24:20. These are live log/counter checks, not a fresh interactive Get-Queue or MAPI test.
- Peter confirmed after reconnecting that the desktop and Start menu work normally and emails are arriving. SMTP STARTTLS and HTTPS certificate validation pass from the maintenance VPN; the certificate expires 2027-01-14. Domain channel query returns PDC with status 0; WinRM remains intentionally Disabled/Stopped.
- Immediate recovery is verified, but the underlying cause is not established. The earlier sender-side DMARC rejection still requires its exact error text; it is separate from the recovered Store-access failure. Filtering/DKIM warnings, the failed win-acme scheduled run, and other historical warnings below remain follow-ups rather than claimed fixed.

## Transaction Logs and Backup Verification

- Operator-supplied interactive database status on 2026-10-18 identifies Archive-DB2 at `E:\ExchangeDatabases\Archive-DB2.edb`, with transaction logs in `C:\ExchangeLogs\Archive-DB2`, and Mailbox-DB3 at `E:\ExchangeDatabases\Mailbox-DB3\Mailbox-DB3.edb`, with transaction logs in `C:\ExchangeLogs\Mailbox-DB3`. Both LastFullBackup values are 2026-10-16 22:06:22; LastIncrementalBackup is empty.
- Read-only guest and Veeam-server inspection confirms the October 16 Exchange task succeeded at 22:32:38. Guest `VeeamVssSupport.log` records `VSS_BT_FULL`, successful BACKUP FINISH notification to Microsoft Exchange Writer at 22:32:30 and subsequent Stable state. The current Exchange VSS writer is Stable/No error. This establishes successful application-aware processing and the backup-completion handoff that enables Exchange truncation; it is not independent proof of every file deletion.
- At approximately 22:34 on October 18, the archive log folder contains 744 numbered logs, plus current/temp logs, totaling 746 MiB of `.log` files; the mailbox log folder contains 542 numbered logs, plus current/temp logs, totaling 544 MiB. Oldest numbered files are from October 16. This is a bounded current inventory, not a before/after deletion comparison. The retained Application log starts October 18, so October 16 ESE truncation events are unavailable there.
- Never manually delete transaction logs, checkpoints or reserved logs. The operator's separate cleanup script targets IIS/Exchange diagnostic/Ceres paths, not these verified transaction-log roots. That read-only verification did not run cleanup, change circular logging or modify/rerun backup jobs; diagnostic cleanup was automated separately below. Next backup verification should compare generation ranges across the next normal primary backup and check new backup/truncation events. A newer Exchange application-aware run after October 16 was not found in the inspected records; verify the intended schedule before classifying that gap as a failure.

## Automated Diagnostic Log Cleanup

- Scheduled task: `\Codex\Exchange diagnostic log cleanup`, daily at 06:30 in the server's W. Europe time zone (Luxembourg), as SYSTEM. It runs locally without the maintainer Mac. Missed runs start when available; overlapping task instances are ignored, an additional named mutex prevents concurrent manual runs, and runtime is capped at one hour.
- Installed script: `C:\script\ExchangeDiagnosticCleanup\Clear-ExchangeDiagnosticLogs.ps1`. Source: [Clear-ExchangeDiagnosticLogs.ps1](scripts/Clear-ExchangeDiagnosticLogs.ps1). Administrator/SYSTEM-only permissions apply to the new subfolder and reports; existing `C:\script` files and their ACLs were not changed. The older manual `C:\script\DeleteExchangeLogs.ps1` remains present but should not be run alongside the scheduled cleanup.
- Only `.log`, `.blg` and `.etl` files with LastWriteTimeUtc strictly older than 15 days are eligible, under these four fixed roots: `C:\inetpub\logs\LogFiles`, `C:\Program Files\Microsoft\Exchange Server\V15\Logging`, and the two `V15\Bin\Search\Ceres\Diagnostics\ETLTraces` / `Logs` folders. No directories are deleted. Newer files, other extensions, linked/reparse paths and in-use files are retained.
- Hard exclusions protect all of `C:\ExchangeLogs` and `E:\ExchangeDatabases`, plus standard Exchange numbered/current/temporary transaction-log names regardless of their age or location. Each candidate's path, ancestors and current metadata are rechecked before deletion. Checkpoint, reserved and database extensions are never eligible. This does not change Veeam truncation or circular logging.
- Without `-Apply`, the script only previews. Each run writes per-file JSONL audit records and a JSON summary under `C:\script\ExchangeDiagnosticCleanup\Reports`; unexpected errors produce a nonzero task result instead of being hidden. Audit reports are retained separately and are not deleted by the 15-day diagnostic rule. Task XML is saved beside the script. Execution policy remains RemoteSigned; no policy/GPO/service changes are needed.
- [Safety tests](scripts/Test-ExchangeDiagnosticCleanup.ps1) passed 22 checks on Exchange3. The first SYSTEM preview found 10,302 eligible files, 8.13 GiB logical size, with zero errors and no deletions. First applied-run and protected-file verification results are recorded in the maintenance log.
- First applied run completed successfully on October 18 at 22:51:50: 10,302 old diagnostic files deleted, zero errors, task result 0. C: free space increased by approximately 7.46 GiB to 61.66 GiB during verification (distinct from logical file size). All 1,298 baseline numbered transaction logs, all 22 checkpoint/reserved files, both database files and the unchanged legacy script were verified present. All 19 sampled queue-length counters were zero and core mail services remained running. Next scheduled run: October 19 at 06:30 local.

Preview manually from elevated PowerShell:

```powershell
& 'C:\script\ExchangeDiagnosticCleanup\Clear-ExchangeDiagnosticLogs.ps1'
```

Pause the schedule without removing scripts or reports:

```powershell
Disable-ScheduledTask -TaskPath '\Codex\' -TaskName 'Exchange diagnostic log cleanup'
```

To resume, use `Enable-ScheduledTask` with the same task path/name. Disabling the schedule does not restore deleted diagnostics; use retained backups if historical logs are required. Keep scheduled cleanup separate from incident collection and transaction-log management.

## RPC Compatibility Policy

- GPO: `EXCHANGE3 - RPC endpoint mapper compatibility`
- GUID: `8329967d-20fa-495b-ac49-2e8e6e6f48ec`
- Linked at the domain root, enabled/enforced, order `1`, because Default Domain Policy is enforced.
- Apply permission is limited to the `EXCHANGE3$` computer account. Authenticated Users retain read access only; user configuration is disabled.
- Sole setting: `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc\EnableAuthEpResolution` DWORD `0`. Domain NTLM restrictions remain unchanged.
- Created and verified on PDC and BDC on 2026-10-10. Computer-policy refresh applied DWORD `0`; the authorized Exchange3 reboot completed with boot time `17:03:04`. The previously failing organization-mailbox SID now resolves successfully and domain trust passes. OAB generation completed successfully at `17:41` with 55 records and files uploaded to its generating mailbox. On 2026-10-11, Peter's interactive audit search and parameter enumeration retrieved both exact verification comments with `Succeeded=True`, confirming audit write-and-read recovery. The subsequent classic Outlook error `0x8004010F` was followed by a separate OAB distribution repair; Peter confirmed 55 local address-book entries in offline mode after the repair.
- All automatic Exchange services recovered, sampled transport queue lengths are zero, HTTPS/SMTP TLS respond with the valid certificate, and WinRM is back to the intended `Stopped`/`Disabled` baseline. A separate `dggpext.dll` policy-processing warning remains open.
- GPO backups and original link state are on PDC under `C:\ProgramData\Codex\GPO-Backups\EXCHANGE3-RPC-20261010-165318`.
- Rollback is to remove only this GPO's domain-root link, refresh policy and plan the required reboot. The preserved Default Domain Policy supplies the original RPC value `1`.

## OAB Distribution

- Default OAB GUID: `3da2d70a-b4e7-422c-8090-bfaf3b80cf01`; generating mailbox: `SystemMailbox{bb558c35-97f1-4cb9-8ff7-d53741dc928c}`.
- On 2026-10-11, Peter's interactive EMS output confirmed `GlobalWebDistributionEnabled=False` with no assigned virtual directories. Outlook Autodiscover XML contained no `OABUrl` despite successful server-side generation.
- Guided repair enabled `GlobalWebDistributionEnabled=True` while leaving `VirtualDirectories` empty. The existing internal/external URL `https://exchange.format.lu/oab` and mailbox assignments were unchanged. Peter confirmed the new setting, reported restarting the IIS websites, and supplied fresh XML containing the matching OAB download URL.
- Client acceptance passed: Peter confirmed 55 entries in the local address book while Outlook Classic was offline, matching the server generation count. This is operator-confirmed client verification, not a new live SSH check. Rollback of this distribution change alone is to restore `GlobalWebDistributionEnabled=False`; the directory list was already empty. It is separate from the RPC GPO rollback above.

## Mail Flow Verification

- On 2026-10-11, Peter confirmed the requested inbound and outbound email tests were successful. Basic mail-flow acceptance, audit write/read and the tested client's offline address-book download have passed.
- This is operator-confirmed delivery, not a new remote message trace or verification of every domain, connector or antivirus policy. Peter subsequently supplied the external recipient's headers for the `format.lu` test message: Microsoft 365 reports SPF, DKIM and DMARC pass, with signing domain `format.lu` and selector `selector1`. The message also contains ESET's clean-result header; this does not validate the complete antivirus policy or attachment handling.

## Warning Follow-up

- Read-only inspection on 2026-10-11 confirmed core Exchange services Running and all sampled transport queue-length counters zero. WinRM remains intentionally Stopped/Disabled. No server configuration was changed.
- Setup preservation: the identified ServiceHost and AD Topology configuration failures date to 2026-09-05 and report files in use. The affected current appSettings, ServiceHost defaultProxy and both system.serviceModel sections match the exact pre-upgrade copies under `Config\v_152174810_D20260905T1810\Bin`. Both current files parse as XML. No restoration is indicated for these identified failures; the persisted `PreservationCmdletsFailed` registry marker was not cleared. Missing-backup/section diagnostics do not justify copying old whole configuration files over the current build.
- Device Guard: extension `dggpext.dll` fails with `0x800711D1` because DMA protection/IOMMU is unavailable to the guest. Effective Device Guard policy requires Secure Boot plus DMA (`RequirePlatformSecurityFeatures=3`); matching settings exist in Default Domain Policy. Secure Boot passes, but WMI reports VBS enabled/not running, no running VBS services and no available hypervisor/DMA security properties. Peter reports that vCenter VBS is off. Do not simply enable VM VBS under the current policy: it also enables Credential Guard, which Microsoft explicitly does not support on Exchange Server. Plan an Exchange3-only, compatibility-reviewed policy correction before any VM activation; do not edit Default Domain Policy globally. Source: [Microsoft Credential Guard application requirements](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/#application-requirements).
- DKIM: the enabled signer is `3.4.0.0`, the upstream project's latest published release at inspection. Async-resume event `1057` still recurs; the successful external `format.lu` DKIM result does not prove the warning is fixed or validate every message/domain. Keep the signer enabled while assessing impact; no DLL replacement or transport restart was performed.
- DNS follow-up: Peter reports display mail moved to Microsoft 365. MX lookups return only priority-0 `display-lu.mail.protection.outlook.com` for `display.lu` and `displaycenter-lu.mail.protection.outlook.com` for `displaycenter.lu`. Initial inspection found both display.lu DKIM selectors missing; they were subsequently published through Cloudflare using the tenant's exact generated values, as documented below. Displaycenter.lu was already Valid/Enabled in Microsoft 365 and was not changed. Display.lu is now Valid/Enabled and the 11:43 external recipient independently reports SPF, DKIM and DMARC pass. Aggregate-report delivery and legitimate sender coverage remain follow-ups before DMARC enforcement. The two on-prem signing entries remain retired; no further Exchange signer/key change was made. Other five configured domains return DKIM TXT records, not proof of private-key agreement or successful message verification.
- Display sender investigation on 2026-10-11: all 1,798 retained message-tracking files (approximately 2026-09-11 to 2026-10-11) show zero Originating events, zero mailbox submissions and zero external-connector SEND events with either display domain in sender-address or return-path. Display.lu matches are incoming messages followed by local delivery; displaycenter.lu has no sender/envelope matches. A separate scan of 720 frontend SMTP receive logs found only display.lu MAIL FROM commands from Microsoft 365 address ranges, with no private-network sources. Both domains are absent from accepted-domain inventory and the current default email-address-policy templates. Sixteen directory objects still have legacy display aliases, including scanner and EasyjobSync accounts; aliases were not changed. This finite observation is not a guarantee about dormant senders or From headers overridden by a separate Sender header. Only the two signing entries were subsequently removed; their keys and aliases remain untouched.

## DKIM Display-Domain Retirement

- On 2026-10-11 at `10:46` Luxembourg time, Peter authorized backing up the signer and removing only `display.lu` and `displaycenter.lu`. This is DKIM email-signing configuration, not the SSL/TLS certificate used to encrypt client/SMTP connections.
- Verified settings backup: `C:\Program Files\Exchange DkimSigner\maintenance-backups\20261011-104654-display-retirement\settings.xml`. Adjacent `before.json`, `after.json` and the archived change script record checksums, original settings ACL and verification. No private-key content was exported.
- Remaining signing domains: `format.lu`, `floc.lu`, `formatexpo.fr`, `nolimits.lu`, `lmr-sa.lu`, all still using selector1. XML verification proved that only the two target DomainElement nodes were removed; global settings and other domain entries are unchanged. Settings ACL, all key-file names/sizes/write timestamps/ACLs and the local certificate inventory matched before/after. No AD alias, DNS or certificate write was performed.
- Live `Exchange DKIM` events at `10:46:54`/`10:46:55` confirm change detection and successful loading of five domains with RSA-SHA256 and relaxed/relaxed canonicalization. Transport process `14732` remained running; no transport/service restart or reboot occurred. Automatic reload is implemented in the [v3.4.0 factory source](https://github.com/Pro/dkim-exchange/blob/v3.4.0/Src/Exchange.DkimSigner/DkimSigningRoutingAgentFactory.cs).
- Rollback: stage the verified settings backup on the same volume with its recorded ACL, atomically replace the current settings file, update LastWriteTimeUtc and confirm the signer reloads seven domains. Keys are still present. Post-change acceptance passed: Peter supplied external recipient headers for the `2026-10-11 10:54` test, with Microsoft 365 reporting SPF, DKIM and DMARC pass for format.lu; the signature still uses selector1, RSA-SHA256 and relaxed/relaxed canonicalization. This verifies the tested message, not all five domains or attachment scanning. Recurring async-resume event 1057 is not claimed fixed.

## Microsoft 365 Display DKIM

- On 2026-10-11, Peter opened the signed-in Microsoft Defender DKIM page and Cloudflare display.lu DNS zone to complete the missing custom-domain signing configuration. Tenant inspection confirmed display.lu NoDKIMKeys/Disabled, while displaycenter.lu was Valid/Enabled. Only display.lu was changed.
- Created new tenant-managed DKIM keys for display.lu, not a rotation of an existing signing configuration. Published two DNS-only CNAMEs, TTL Auto (authoritative DNS reports 300 seconds):
  - `selector1._domainkey.display.lu` -> `selector1-display-lu._domainkey.displaylu.a-v1.dkim.mail.microsoft`
  - `selector2._domainkey.display.lu` -> `selector2-display-lu._domainkey.displaylu.a-v1.dkim.mail.microsoft`
- Before/after zone exports are retained locally as `~/Downloads/display.lu-before-dkim-20261011-110414.txt` and `~/Downloads/display.lu-after-dkim-20261011.txt`. Comparison shows exactly the two CNAME additions plus export time/SOA serial changes; all eight existing DNS records are unchanged. The backup is archival evidence, not a zone file to import blindly.
- Both CNAMEs resolve correctly through both Cloudflare authoritative servers and 1.1.1.1; both Microsoft targets return DKIM public-key TXT records. The initial enablement attempt and one retry returned CnameMissing. Subsequent live tenant inspection after Peter's 11:40 test confirms display.lu Valid/Enabled; displaycenter.lu remains Valid/Enabled. Independent acceptance passed for the 11:43 external test: receiving server www165.your-server.de reports SPF pass, DKIM pass for display.lu/selector1 and DMARC pass for display.lu. This supersedes the earlier on-prem test's ambiguous authentication headers and verifies the tested Microsoft 365 sending path, not every application sender. Do not rotate keys or change correct CNAMEs to resolve an earlier cached status.
- Rollback, only if authorized: disable display.lu tenant signing before removing the two newly added CNAMEs; preserve all other records and domains. No on-prem private key, alias, certificate, MX, SPF, website or DMARC setting was changed in this operation.

## Display.lu DMARC Monitoring

- On 2026-10-11, Peter authorized monitoring-only DMARC with aggregate reports to `Peter.Czibula@format.lu`. Published DNS-only TXT `_dmarc.display.lu`: `v=DMARC1; p=none; rua=mailto:Peter.Czibula@format.lu`, TTL Auto. No quarantine/reject policy or forensic reporting was enabled for display.lu.
- Since the report destination is outside display.lu, added only TXT `display.lu._report._dmarc.format.lu`: `v=DMARC1;`, DNS-only/Auto, authorizing this domain's aggregate reports. This is not format.lu's DMARC policy; its existing `_dmarc` reject policy remains unchanged. [External report authorization](https://www.rfc-editor.org/rfc/rfc7489.html#section-7.1).
- Authoritative and 1.1.1.1 DNS checks return both exact records. Cloudflare now shows no recommendations for display.lu. Zone-export comparisons show only these two additions plus export metadata; all previous records remain unchanged. Backups and verification details are in the maintenance log.
- Report delivery is not yet verified. Review actual reports and legitimate sender coverage before any enforcement change. Tenant DKIM is Valid/Enabled and independent external-message authentication passed for the 11:43 test. Rollback, only if authorized, removes only these two added TXT records after confirming no concurrent edits.

## First Checks

```sh
ssh win-exchange3 hostname
ssh winad-exchange3 hostname
```

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
Get-Service sshd,WinRM
Get-Service MSExchange*
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

