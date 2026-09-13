# EXCHANGE3 Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-exchange3` and `winad-exchange3` both returned `Exchange3`.
- Secure channel checked: healthy; domain `format.lu`.
- OS checked: Microsoft Windows Server 2022 Standard `10.0.20348`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM TCP checked: `192.168.1.6:5985` reachable after restore.
- Disk space checked: C: 52.2 GB free before cleanup and 54.2 GB free after cleanup; E: 85.4 GB free of 350 GB.
- Pending reboot checked: `PendingFileRenameOperations` present.
- Recent updates checked: latest installed hotfixes included `KB5078766` and `KB5078763` on 2026-03-16.
- Exchange services checked: all `MSExchange*` services were running except `MSExchangePop3` and `MSExchangePOP3BE`, both `Stopped`/`Manual`.
- Transport queues checked: attempted `Get-Queue`, but Exchange cmdlet failed with AD credential error for `FORMAT\Administrateur` in the SSH PowerShell session.
- Certificates checked: attempted `Get-ExchangeCertificate`, but Exchange cmdlet failed with the same AD credential error.
- File cleanup performed: deleted 2,427 files older than 30 days from `C:\Windows\Temp`, about 2,038.5 MB. Post-cleanup `C:\Windows\Temp` measured about 69.7 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No Exchange services were restarted.
- No mail data, queue data, certificates, GPO, firewall rule, or snapshot/reboot action was changed.

Follow-up:

- Run Exchange Management Shell health checks from an interactive session or known-good credential path: queue health, certificate expiry, component state, and event logs.
- Plan update/reboot work carefully because this host has a pending reboot indicator.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on EXCHANGE3 using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 3 visible updates successfully: Windows Malicious Software Removal Tool KB890830, .NET cumulative update KB5084071, and OS cumulative update KB5082142.
- Task log: `C:\ProgramData\Codex\windows-update-Exchange3-20260418-220816.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 51.0 GB.
- Post-install visible update scan still listed KB5082142 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending, Windows Update reboot required, and `PendingFileRenameOperations`.
- Reboot performed: No.

Notes:

- No Exchange services were restarted.
- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No mail data, queue data, certificates, GPO, firewall rule, snapshot, or reboot action was changed.

Follow-up:

- Reboot EXCHANGE3 in an agreed Exchange maintenance window, then re-run Windows Update scan and Exchange Management Shell health checks.

## 2026-05-03 - Bi-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-exchange3` and `winad-exchange3` both connected; `winad-exchange3 whoami` returned `format\administrateur`.
- Secure channel checked: healthy; `Test-ComputerSecureChannel -Verbose` returned `True`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled` again, restored to `Running`/`Automatic`.
- WinRM TCP checked after restore: `192.168.1.6:5985` reachable from the maintainer Mac.
- Exchange services checked: 25 `MSExchange*` services `Running`; 2 `Stopped`.
- Disk space checked: C: about 55.6 GB free; E: about 85.1 GB free.
- Pending reboot checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Visible Windows updates checked: `0`.
- Recent hotfixes checked: `KB5082142`, `KB5082137`, `KB5082427`.
- File cleanup performed: no files older than 30 days remained in `C:\Windows\Temp`; remaining temp content about 66.8 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- April update state appears finalized because visible updates and reboot flags are clear.
- WinRM drift recurred on this host as well.

Follow-up:

- Run the previously deferred Exchange Management Shell checks from a context that can load Exchange cmdlets cleanly.
- Investigate why `WinRM` startup drift recurred after the April maintenance.

## 2026-05-03 - Exchange Certificate Renewal Automation Repair

Maintainer: Peter with Codex

Scope:

- Diagnose the near-expiry Exchange certificate and repair the broken `win-acme` renewal automation on `EXCHANGE3`.

Checks:

- Exchange Management Shell checks run locally by Peter and reviewed by Codex:
  - `Get-ExchangeServer` reported `Version 15.2 (Build 1748.10)`, `Standard`, `Mailbox`.
  - `Get-Queue` showed `Exchange3\\Submission` clean and one stale retry queue item for `eccfstudies.com`.
  - `Get-ExchangeCertificate` showed the active `CN=exchange.format.lu` IIS/SMTP/IMAP certificate expiring `2026-06-01 10:53:03`.
- The stale retry queue item was an old undeliverable message with remote socket refusal from `eccfstudies.com`; no broad queue backlog was present.
- Scheduled task `win-acme renew (acme-v02.api.letsencrypt.org)` existed and was `Ready`, but `Get-ScheduledTaskInfo` showed repeated failures with `2147942593`.
- `C:\Program Files\Lets Encrypt\wacs.exe` was found to be a zero-byte corrupted file.

Actions:

- Peter replaced the broken `wacs.exe` with a working `win-acme` binary.
- Peter ran:
  - `& "C:\Program Files\Lets Encrypt\wacs.exe" --renew --baseuri "https://acme-v02.api.letsencrypt.org/"`
- Renewal succeeded for all 7 identifiers:
  - `exchange.format.lu`
  - `exchange3.format.lu`
  - `autodiscover.format.lu`
  - `autodiscover.floc.lu`
  - `autodiscover.formatexpo.fr`
  - `autodiscover.lmr-sa.lu`
  - `autodiscover.nolimits.lu`
- The manual run updated IIS bindings but failed its script step because `./Scripts/ImportExchange.ps1` was invoked from the wrong working directory.
- The renewed certificate was then explicitly enabled for Exchange services by Peter:
  - `Enable-ExchangeCertificate -Thumbprint 5A2FE271F5B6588917E7A37DC06DAF1C0EDA63FA -Services SMTP,IMAP,IIS`
- Peter tested the scheduled task again:
  - `Start-ScheduledTask -TaskName "win-acme renew (acme-v02.api.letsencrypt.org)"`
  - `Get-ScheduledTaskInfo ...` then returned `LastTaskResult : 0`
- A fresh `win-acme` log was created:
  - `C:\ProgramData\win-acme\acme-v02.api.letsencrypt.org\Log\log-20260503.txt`

Results:

- Active Exchange certificate now:
  - Thumbprint: `5A2FE271F5B6588917E7A37DC06DAF1C0EDA63FA`
  - Subject: `CN=exchange.format.lu`
  - Services: `IMAP, IIS, SMTP`
  - Expiry: `2026-08-01 16:55:27`
- Renewal automation is healthy again with scheduled-task result `0`.

Notes:

- The root cause was a corrupted zero-byte `wacs.exe`, not an Exchange certificate-store failure.
- The manual renewal run initially reported `succeeded with errors` only because it was launched from `C:\Windows\System32`, so the relative `./Scripts/ImportExchange.ps1` path failed. The scheduled task works because its working directory is correctly set to `C:\Program Files\Lets Encrypt`.
- No Exchange service restart, transport change, queue purge, or mailbox data change was performed during this repair.

Follow-up:

- Keep the new `win-acme` binary and monitor the next scheduled renewal run for a normal `LastTaskResult : 0`.
- Review whether the stale retry queue item for `eccfstudies.com` still exists later; it was not treated as a mail-flow outage during this repair.

## 2026-05-16 - Twice-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-exchange3` and `winad-exchange3` remain usable for routine remoting.
- Secure channel checked: `Test-ComputerSecureChannel -Verbose` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: had drifted back to `Stopped`/`Disabled`; restored to `Running`/`Automatic`; TCP `5985` reachable again from the maintainer Mac.
- Exchange services checked: service summary remained `25 Running`, `2 Stopped`, matching the prior POP3-disabled baseline.
- Certificates checked: no new certificate work was needed in this pass; the repaired `win-acme` path from 2026-05-03 remained in place.
- Event logs reviewed: Windows Update task log under `C:\ProgramData\Codex`.
- Updates installed: Yes. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` completed with `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Reboot required: Yes.
- Notes: Installed payloads were MRT `KB890830`, .NET cumulative update `KB5088862`, and OS cumulative update `KB5087545`. Post-install remote Windows Update scan returned `VisibleUpdates=0`.
- Follow-up: remove the one-off task if it is still present, then reboot Exchange3 in a planned Exchange window and re-run Windows Update plus basic EMS health checks afterward.

## 2026-05-31 - End-Of-Month Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `winad-exchange3` connected and returned `FORMAT\Administrateur`.
- Secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: had drifted again to `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Exchange services checked: not deeply re-inventoried in this pass; no new service fault surfaced during remoting checks.
- Transport queues checked: not re-run in this pass.
- Certificates checked: no new certificate work was needed; the repaired `win-acme` path remained in place.
- Event logs reviewed: no deep event-log pass in this sweep; Windows Update task log under `C:\ProgramData\Codex` was checked.
- Updates installed: No. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` ran successfully and logged `VisibleCount=0`.
- Reboot required: No reboot flag was present in this pass.
- Notes: Remote COM-based Windows Update queries still fail from the SSH admin context with `0x80240032`, but the SYSTEM-context update script completed normally and found no visible updates.
- Follow-up: keep an eye on recurring `WinRM` startup drift and do the next deeper Exchange validation from an interactive EMS session if service symptoms appear.

## 2026-05-31 - Post-Update/Reboot Validation

Maintainer: Codex with Peter

Checks:

- Peter completed manual Windows Update, cleanup, guest reboot, and ESX-D host reboot.
- Post-host-reboot network checked: `192.168.1.6` responded to ping.
- Post-host-reboot SSH checked: `win-exchange3` returned `Exchange3`; `winad-exchange3` reached the host but returned SSH permission denied for the domain-admin alias.
- Secure channel checked from the local SSH context: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `False`; `nltest /sc_query:format.lu` returned `1311` / `ERROR_NO_LOGON_SERVERS`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: `Running`/`Automatic`.
- Exchange services checked: `MSExchangeADTopology`, `MSExchangeIS`, and `MSExchangeTransport` were `Running`.
- EMS check attempted from the local SSH context, but Exchange cmdlets failed with `ADInvalidCredentialException` for `EXCHANGE3\Administrateur`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Latest hotfix checked: `KB5087545`, installed `2026-05-17`.

Notes:

- Exchange3 is booted and core Exchange services are running after the host reboot.
- Domain SSH and secure-channel state need a domain-authenticated or interactive EMS follow-up; no queue, certificate, transport, or mailbox data change was made in this validation.

## 2026-05-31 - Domain SSH Follow-Up

Maintainer: Codex with Peter

Checks and actions:

- Compared domain SSH behavior against Admin and FILE.
- `sshd_config` includes `AllowGroups administrators format\sshadmins` and uses `__PROGRAMDATA__/ssh/administrators_authorized_keys` for `Match Group administrators`.
- AD group `SSH Admins` exists with SamAccountName `sshadmins`, and `FORMAT\Administrateur` is a member.
- `winad-exchange3` continued to return SSH permission denied for `format\Administrateur`.
- OpenSSH logs showed `Invalid user format\Administrateur`.
- `nltest /sc_reset:format.lu\\PDC.format.lu`, `Restart-Service Netlogon -Force`, and `nltest /sc_verify:format.lu` completed successfully, but local SID translation for `format\Administrateur` and `format\sshadmins` still returned trust-relationship failures.

Notes:

- Exchange3 local SSH remains usable and core Exchange services remained running during this follow-up.
- Domain SSH requires a credentialed machine-password repair from an interactive/domain-admin context before retesting EMS/domain SSH.

## 2026-05-31 - Domain SSH Restored

Maintainer: Codex with Peter

Actions:

- Peter ran the credentialed machine-password repair interactively on Exchange3:
  - `Reset-ComputerMachinePassword -Server PDC.format.lu -Credential format\Administrateur`
  - `Restart-Service Netlogon -Force`
  - `Test-ComputerSecureChannel -Server PDC.format.lu -Verbose`
  - `nltest /sc_query:format.lu`
- The explicit PDC-targeted secure-channel check returned `True`.
- `nltest /sc_query:format.lu` returned `NERR_Success`.
- Codex retested `winad-exchange3`; domain SSH returned `Exchange3`.
- `whoami` over domain SSH returned `format\administrateur`.
- OpenSSH logs confirmed `Accepted publickey for format\Administrateur`.
- Exchange core services checked over the restored domain SSH path: `MSExchangeADTopology`, `MSExchangeIS`, and `MSExchangeTransport` were `Running`.

Notes:

- Exchange3 domain SSH is restored.
- Exchange core services remained healthy during the repair.

## 2026-06-14 - Twice-Monthly Maintenance Discovery

Maintainer: Codex with Peter

Checks and actions:

- `winad-exchange3` checked: domain SSH failed with permission denied for `format\Administrateur`.
- `win-exchange3` break-glass SSH checked: returned `Exchange3` and `exchange3\administrateur`.
- Secure channel checked from local SSH context: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- Low-impact reset attempted:
  - `nltest /sc_reset:format.lu\\PDC.format.lu`
  - `Restart-Service Netlogon -Force`
- Domain SSH retest still failed with permission denied.
- Local SID translation for `format\Administrateur` and `format\sshadmins` still returned trust-relationship failures.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`; listener exists, but TCP/5985 from the maintainer Mac still timed out.
- Exchange services checked: `MSExchangeADTopology`, `MSExchangeIS`, and `MSExchangeTransport` were `Running`.
- EMS queue/certificate checks from local admin context failed with `ADInvalidCredentialException` for `EXCHANGE3\Administrateur`.
- win-acme checked: scheduled task last ran `2026-06-14 10:17:17` with result `0`; recent log `log-20260614.txt` exists.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Recent hotfixes checked: `KB5094128` and `KB5094147` installed on `2026-06-13`.
- Visible Windows updates checked: `0`.

Notes:

- Exchange3 core services and win-acme automation look healthy.
- Domain SSH/EMS checks require domain-auth repair from an interactive/domain-admin context.
- Pending file rename indicates a planned reboot is useful, but no reboot was performed.

## 2026-06-14 - Domain SSH Partially Restored, EMS Still Blocked

Maintainer: Codex with Peter

Actions:

- Peter ran the credentialed machine-password repair interactively on Exchange3.
- Codex retested `winad-exchange3`; domain SSH returned `Exchange3` and `format\administrateur`.
- OpenSSH logs confirmed `Accepted publickey for format\Administrateur`.
- `nltest /sc_verify:format.lu`, `nltest /dsgetdc:format.lu`, and `nltest /sc_reset:format.lu\\PDC.format.lu` all succeeded against `\\PDC.format.lu`.
- DC reachability checked from Exchange3: TCP `88`, `389`, and `445` to `PDC.format.lu` succeeded.
- `Test-ComputerSecureChannel -Server PDC.format.lu` still returned `False`.
- Exchange cmdlets over the restored domain SSH session still failed with `ADInvalidCredentialException` for `FORMAT\Administrateur`.
- `whoami /groups` in the SSH session did not show the expected domain admin/Exchange role groups, only local administrators and generic logon groups.

Notes:

- Domain SSH transport is restored, but the domain authorization token/EMS path is not healthy yet.
- Core Exchange services remained running. No queue, certificate, transport, or mailbox data change was made.
- Recommended next step is an interactive domain-admin EMS check on the console/RDP session, or a fresh domain logon after reboot, before treating Exchange3 EMS access as restored.

## 2026-07-04 - Inspection Round

Maintainer: Codex with Peter

Checks and actions:

- `win-exchange3` and `winad-exchange3` checked: both returned `Exchange3`; domain SSH returned `format\administrateur`.
- Secure-channel checks remained split: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `False` / `1311`, while `nltest /sc_verify:format.lu` and `nltest /dsgetdc:format.lu` succeeded against `\\PDC.format.lu`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Exchange services checked: `MSExchangeADTopology`, `MSExchangeIS`, and `MSExchangeTransport` were `Running`.
- EMS queue/certificate checks over domain SSH still failed with `ADInvalidCredentialException` for `FORMAT\Administrateur`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: latest visible installed security updates remained `KB5094128` and `KB5094147` from `2026-06-13`.
- Visible Windows updates checked: `0`.

Notes:

- Exchange3 is reachable and core Exchange services are running.
- EMS/domain authorization remains blocked from the SSH session, matching the prior June finding.
- No queue, certificate, transport, mailbox, firewall, GPO, reboot, or update action was performed.

## 2026-07-19 - Twice-Monthly Inspection Round

Maintainer: Codex with Peter

Checks and actions:

- `win-exchange3` and `winad-exchange3` checked: both returned `Exchange3`; domain SSH returned `format\administrateur`.
- Secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `nltest /sc_verify:format.lu` and `nltest /dsgetdc:format.lu` also succeeded against `\\PDC.format.lu`.
- `sshd`, `Netlogon`, `MSExchangeADTopology`, `MSExchangeIS`, and `MSExchangeTransport` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- EMS queue/certificate checks over domain SSH still failed with `ADInvalidCredentialException` for `FORMAT\Administrateur`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: latest visible installed security updates remained `KB5094128` and `KB5094147` from `2026-06-13`.
- Visible Windows updates checked: `3`:
  - Windows Malicious Software Removal Tool x64 v5.143 `KB890830`
  - .NET cumulative update `KB5102206`
  - OS cumulative update `KB5099540`

Notes:

- Exchange3 is reachable and core Exchange services are running.
- Unlike 2026-07-04, the explicit secure-channel check returned healthy in this pass.
- EMS/domain authorization remains blocked from the SSH session, matching the prior token issue.
- July Windows/.NET updates are visible but were not installed by Codex.

## 2026-07-19 - Remote Update Install Attempt Blocked

Maintainer: Codex with Peter

Actions:

- Attempted to start a no-reboot Windows Update install remotely.
- Creating a SYSTEM scheduled task over domain SSH failed with `Access is denied`.
- Retried through local break-glass SSH; the update task action path was still rejected with `Access is denied`.

Notes:

- No updates were installed and no reboot was performed by Codex.
- July Windows/.NET updates remain visible and require an interactive elevated session or another approved elevation path.
- EMS/domain authorization is still blocked from the SSH session.

## 2026-07-19 - Post-Manual Update Validation

Maintainer: Codex with Peter

Checks:

- `winad-exchange3` domain SSH checked: OK, returned `format\administrateur`.
- Domain secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\BDC.format.lu`.
- `sshd`, `Netlogon`, `MSExchangeADTopology`, `MSExchangeIS`, and `MSExchangeTransport` checked: `Running`/`Automatic`.
- `WinRM` checked: `Stopped`/`Disabled` again after reboot/policy refresh.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: `KB5099540`, `KB5120210`, and `KB5101010` installed on `2026-07-19`.
- Visible Windows updates checked: `0`.
- Certificate store checked: `CN=exchange.format.lu` certificate present with expiry `2026-09-26 11:58:31`.

Notes:

- Exchange3 is update-clean and does not currently require a reboot.
- Core Exchange services are running.
- Full Exchange Management Shell queue/certificate service checks remain best validated from an interactive Exchange shell because SSH-launched EMS has previously hit credential/token issues.
- WinRM disablement recurred after reboot/policy refresh.

## 2026-08-04 - Maintenance Round

Maintainer: Codex with Peter

Checks:

- Local and domain SSH checked: both working.
- Trust checked: `nltest /sc_verify:format.lu` succeeded against PDC.
- Automatic Exchange services checked: all running; POP services remain manual/stopped.
- Visible Windows updates checked: `0`.
- win-acme renewal task checked: last run `2026-08-04 11:48:48`, result `0`; next run scheduled for 2026-08-05.
- Certificate store checked: `CN=exchange.format.lu`, private key present, expires `2026-09-26 11:58:31`.
- Reboot state checked: CBS `False`, Windows Update `False`.
- SSH-launched Exchange cmdlets still returned the known delegated-credential error, so queue and Exchange service bindings were not changed.

Notes:

- Exchange3 is operational and update-clean. No reboot was performed.
- Keep the certificate renewal task under routine observation; full queue checks remain best performed in an interactive Exchange Management Shell.

## 2026-08-23 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH checked: both working.
- `nltest /sc_verify:format.lu` succeeded against PDC; the known PowerShell secure-channel false result remained non-authoritative.
- Windows Update had already started a native install session before the temporary Codex task began. The duplicate task ended with `0x41306` and was not retried while servicing was active.
- The native session installed `KB890830`, .NET cumulative update `KB5121650`, and OS cumulative update `KB5120242`, then restarted Exchange3 twice under Windows Update control. Final boot time is `2026-08-23 16:07:45`.
- Final Windows Update rescan returned `0`; CBS and Windows Update reboot markers are clear.
- Automatic Exchange services, including Replication and Throttling after post-boot settling, are running. SSH, SMTP, and HTTPS are reachable.
- win-acme renewal task last result is `0`. Certificate `CN=exchange.format.lu` has a private key and expires `2026-11-20 08:30:25`.
- Temporary Codex task, script, and log were removed after verification.

Notes:

- The restarts were not issued by Codex. No Exchange, certificate, queue, connector, GPO, or firewall configuration was changed.
- SSH-launched Exchange cmdlets retain the known delegated-token limitation; no transport queue mutation was attempted.

## 2026-09-05 - Maintenance Round

Maintainer: Codex with Peter

Checks and actions:

- Local and domain SSH, secure channel, `sshd`, and `Netlogon` checked healthy; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Windows Update scan returned `0`; CBS and Windows Update reboot markers are clear.
- Exchange mailbox, transport, replication, throttling, mitigation, and flighting services are running. The transport queue audit found only the empty Ready submission queue.
- The Exchange Mitigation connectivity test still cannot reach its service endpoint even though DNS and TCP 443 to `officeclient.microsoft.com` succeed. No proxy, TLS, or firewall change was made.
- SMTP initially omitted STARTTLS because the Default Frontend connector still referenced the previous R13 certificate issuer. The current YR1 certificate was already bound to IIS/backend transport and is valid through `2026-11-20`.
- Ran the existing `exchange-post-renewal.ps1` hook once as SYSTEM. It corrected the frontend connector, after which SMTP advertised STARTTLS and presented certificate thumbprint `B053D9AF863A4931B04931418CFA60097E56458E`.
- Updated the custom hook to enable SMTP, IIS, and IMAP, and changed the active win-acme renewal definition to call that hook instead of the stock relative `ImportExchange.ps1`. Dated backups of both changed files were retained.
- A non-forced win-acme renewal check connected successfully and found renewal not yet due. The scheduled task last result remains `0`, with its next run on `2026-09-06`.
- Exchange build is `15.2.1748.39`; Microsoft's current Exchange 2019 CU15 release table lists `15.2.1748.49`. Schedule the applicable security update separately with an outage/reboot plan and ESU eligibility confirmed.
- DKIM transport agent `3.4.0.0` is enabled. Event `1057` matches a known async-resume issue in the unmaintained upstream project; queue state is currently clean, so no agent change was made.
- Temporary audit and repair tasks, scripts, and logs were removed after verification.

Notes:

- No reboot, queue mutation, firewall, GPO, or mailbox data change was performed.

## 2026-09-13 - Maintenance Round

Maintainer: Codex with Peter

Checks:

- Local and domain SSH, domain trust, `sshd`, and `Netlogon` checked healthy; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Exchange Server Subscription Edition build is `15.2.2562.17`. Mailbox, transport, replication, throttling, mitigation, and flighting services were running.
- Windows Update offered Exchange security update `KB5121608`, .NET update `KB5126149`, OS update `KB5122882`, and `KB890830`.
- SMTP, submission port 587, and HTTPS were reachable. SMTP STARTTLS negotiated TLS 1.2 and presented the valid `CN=exchange.format.lu` certificate.
- The win-acme renewal task last result is `0`; the active certificate is valid through `2026-11-20`.
- SSH-launched Exchange queue cmdlets retained the known delegated-credential limitation. A staged read-only SYSTEM precheck was blocked because task registration for the PowerShell action returned Access Denied.

Notes:

- No Exchange or Windows updates were installed and no reboot was performed during this round.
- Complete an interactive Exchange health and queue precheck, confirm backup state and outage window, then install the four offered updates and verify services, queues, mail flow, HTTPS, SMTP STARTTLS, and win-acme afterward.
- No connector, queue, certificate, firewall, GPO, or mailbox data was changed.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Secure channel checked:
- `sshd` checked:
- `WinRM` checked:
- Exchange services checked:
- Transport queues checked:
- Certificates checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
