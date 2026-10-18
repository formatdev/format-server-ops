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

## 2026-10-10 - Maintenance Round

Maintainer: Codex with Peter

Checks:

- Local and domain SSH, domain trust, `sshd`, and `Netlogon` checked healthy; WinRM remains `Stopped`/`Disabled` as expected by GPO.
- Exchange3 is running Windows Server 2022 build `20348.5622`, booted on 2026-10-09. Windows Update returned `0`; CBS and Windows Update reboot markers are clear.
- Exchange Server Subscription Edition is build `15.2.2562.53`, the current Sep26SUv2 build released 2026-10-02. All automatic Exchange services are running.
- SMTP ports 25 and 587 and HTTPS 443 are listening. External SMTP STARTTLS negotiated TLS 1.2 and presented the valid `CN=exchange.format.lu` Let's Encrypt certificate.
- The win-acme task last result is `0`. The current certificate has a private key and expires 2026-11-20; Exchange has begun emitting expected certificate-expiry warnings.
- Submission, retry-mailbox-delivery, and active-mailbox-delivery queue performance counters were all `0`. Full `Get-Queue` and `Get-ExchangeCertificate` checks remain blocked in SSH-launched EMS by the known delegated-credential error.
- ESET Mail Security `13.0.10006.0` and ESET Management Agent `13.3.1192.0` are installed; ESET core, firewall helper, forwarder, and management-agent services are running. Microsoft Defender antivirus is disabled as expected with ESET active.
- Recurrent DKIM event `1057` remains the known async-resume issue. AirSync clients for Jens Gilz and Pascal Martin exceeded the 250-message object limit.
- Admin-audit event `5000` reports that Exchange cannot find the discovery mailbox. The AD object exists and has `Mailbox-DB3` and `EXCHANGE3` attributes, so interactive EMS mailbox/statistics validation is required before any repair.
- OWA returned the expected unauthenticated HTTP 440 response. No external mail was sent as a test.

Notes:

- No update, reboot, queue, connector, certificate, mailbox, ESET, DKIM, firewall, or GPO change was made.
- Monitor the daily ACME task through the next renewal. Validate the discovery mailbox and audit logging from an interactive Exchange Management Shell.

## 2026-10-10 - System Mailbox Follow-up

Maintainer: Codex with Peter

- Peter confirmed all VMs and hosts had been rebooted. Post-reboot local SSH confirms Exchange AD Topology, Information Store, Transport, and Frontend Transport services are running.
- Event `5000` persists after reboot. The sampled health-mailbox `Set-Mailbox` operation succeeded, but its admin-audit record could not be saved because `GetDiscoveryMailbox` could not locate the required hidden mailbox.
- PDC AD queries found the migration and federation arbitration recipients and the ordinary `DiscoverySearchMailbox` object, but no standard `SystemMailbox{...}` objects. Querying arbitration recipient type returned only migration and federation recipients. These directory findings suggest missing discovery/system arbitration mailboxes; the ordinary discovery search mailbox is not the discovery arbitration mailbox.
- The exact affected system mailboxes and mailbox-store state still require read-only interactive EMS checks: `Get-Mailbox -Arbitration`, `Get-Mailbox -AuditLog`, `Get-Mailbox -RecipientTypeDetails DiscoveryMailbox`, and `Get-MailboxDatabase -Status`.
- Peter supplied the interactive EMS results: arbitration contains only federation and migration; `Get-Mailbox -AuditLog` is empty; the ordinary `DiscoverySearchMailbox` exists on `Mailbox-DB3`; both `Mailbox-DB3` and `Archive-DB2` are mounted. These results confirm the standard discovery, organization/OAB, approval, and additional system arbitration mailboxes are absent from the returned inventory.
- Exchange3's D: DVD drive has no mounted media. Microsoft's supported recovery begins with `/PrepareAD` from appropriate Exchange SE installation media to recreate missing AD objects, then enables/configures the missing arbitration mailboxes. No recovery command has yet been run.
- Domain SSH was denied on this follow-up; local break-glass SSH remains usable. No Exchange mailbox, audit setting, domain trust, or service configuration was changed.
- Consult Microsoft's Exchange SE system-mailbox recovery procedure after the mailbox inventory identifies the missing objects. Do not delete the existing discovery search mailbox merely because the error mentions discovery.
- Peter mounted Exchange SE media on F:. Setup version `15.02.2562.017` and its Microsoft signature were verified; the installed security-update build remains `15.2.2562.53`.
- Peter's interactive `/PrepareAD` attempt stopped at prerequisite analysis because WinRM was disabled. The Exchange 2013 topology warning was informational; successful AD preparation has not yet been confirmed.
- Temporarily set WinRM to `Manual` and started it for the recovery. Verified `Running`/`Manual` and a successful local `Test-WSMan`. The existing enabled WinRM firewall rule is scoped to `192.168.1.70` and `192.168.113.2`; no firewall or GPO change was made.
- Recovery remains pending: rerun `/PrepareAD` interactively, verify/recreate only the missing system mailboxes, then restore WinRM to `Stopped`/`Disabled` and verify the baseline.
- On Peter's request to run recovery through SSH, domain alias `winad-exchange3` successfully connected as `format\administrateur` with enabled Enterprise Admins and Schema Admins group SIDs and a high-integrity token. An explicit negotiated LDAP bind to `PDC.format.lu` failed with `System.DirectoryServices.Protocols.LdapException: The supplied credential is invalid`. Group membership does not provide usable delegated domain credentials in this key-authenticated session. No `/PrepareAD` attempt was launched through SSH and no credential or security-policy workaround was used; the AD preparation step still requires an elevated interactive domain session.
- Peter reran `/PrepareAD` interactively. The setup log confirms organization preparation completed successfully at `2026-10-10 14:21:46`, using BDC, with result `0`. PDC now contains all five standard missing arbitration accounts plus the `SystemMailbox{8cc370d3-822a-4ab8-a926-bb94bd0641a9}` audit account; all six currently have no `homeMDB` or mailbox recipient-type attributes. Mailbox enablement and capability configuration remain pending.
- The successful run also emitted a configuration-preservation warning. The reviewed current-run entries do not identify an affected configuration file; `UpdateConfigFiles.log` was last modified on 2026-10-03 and does not establish a new configuration change from this AD-only run. Keep the warning open rather than restoring configuration files speculatively.
- Setup logged SID-resolution trust errors, but a subsequent local check returned `Test-ComputerSecureChannel -Server PDC.format.lu = True` and `nltest /sc_query:format.lu` returned PDC with status `0`. Core Exchange services remain running; no trust reset or Exchange service restart was performed during this follow-up.
- BDC's local AD query independently confirms the same six unmailboxed system accounts. The returned domain-partition inbound replication metadata reports result `0`; a cross-DC ADWS query from PDC's SSH session failed authentication, so local queries were used rather than changing authentication policy.
- Peter's first guided enablement block returned only the original federation and migration mailboxes. A fresh PDC query confirms all six recreated accounts remain disabled and have no `homeMDB` or mailbox recipient-type attributes. The block's `RecipientTypeDetails -eq 'User'` guard was too restrictive for recreated disabled system accounts. Enablement has not succeeded; retry only the five verified missing arbitration accounts directly with `Enable-Mailbox -Arbitration`, leaving AD login accounts disabled and configuring capabilities only after success is confirmed.
- Peter's corrected enablement block successfully enabled all five missing arbitration mailboxes on `Mailbox-DB3`. Interactive EMS now lists seven arbitration mailboxes including the preserved federation and migration recipients. PDC independently confirms `homeMDB` points to `Mailbox-DB3` and recipient type `8388608` for the five recreated arbitration mailboxes. Their capabilities are still empty; organization/OAB, discovery, and shard capability configuration remains pending. The separate `SystemMailbox{8cc370d3-822a-4ab8-a926-bb94bd0641a9}` audit account still has no mailbox attributes.
- Peter completed the capability block. Interactive EMS shows all eight documented organization/OAB capabilities, discovery `OrganizationCapabilityUMDataStorage`, and shard `OrganizationCapabilityShardRelevancyFeatureStore`; PDC independently confirms discovery ID `41` and shard ID `66`. Empty capabilities on federation, approval, and encrypted-message arbitration mailboxes are expected.
- Exchange requested a manual `Update-OfflineAddressBook` to activate OAB generation. PDC configuration discovery found one default offline address book; its generating mailbox must be verified through EMS before changing an assignment. OAB generation has not yet been requested. Sampled event `5000` failures include the earlier enablement operations and do not establish that the error persists after the completed capability block. Audit-mailbox enablement and a fresh audit-write/read test remain pending; no Exchange service restart or audit-policy change has been made.
- Peter's interactive OAB block showed an empty generating-mailbox assignment on the sole default OAB, assigned it to `SystemMailbox{bb558c35-97f1-4cb9-8ff7-d53741dc928c}`, and requested `Update-OfflineAddressBook` without a reported error. EMS subsequently returned the expected generator DN. Request acceptance is not yet proof of completed OAB generation or an Outlook download. The following `Get-Mailbox -AuditLog` query returned no mailbox.
- The next guided step is narrowly scoped enablement of the already Setup-created `SystemMailbox{8cc370d3-822a-4ab8-a926-bb94bd0641a9}` on `Mailbox-DB3` with the audit-log mailbox type, followed by auditing configuration inspection and a uniquely marked audit-write test. Microsoft's `Enable-Mailbox -AuditLog` parameter is documented but marked reserved for internal Microsoft use; do not describe this as a generally documented administrator recovery procedure. No audit-account mailbox enablement or fresh write-test success has yet been confirmed.
- Peter successfully enabled the audit mailbox on `Mailbox-DB3`; EMS reports `AuditLogMailbox`, and PDC independently confirms recipient type `4398046511104`. Admin auditing is enabled with cmdlet and parameter filters `*`. `Write-AdminAuditLog` returned without a reported error for marker `Exchange3 recovery verification 20261010-163601`. At `16:36:48` no new management event `5000` was found since the marker timestamp; indexed readback of the exact marker remains pending.
- Core Exchange services remain running, SMTP/HTTPS ports 25/587/443 are listening, domain trust to PDC passes, and the win-acme task result is `0` from its 2026-10-10 run. WinRM remains the temporary `Running`/`Manual` exception until interactive verification is complete.
- OAB generation is NOT verified successful: `OABGeneratorLog\oabgen2026101014-1.LOG` records the on-demand request at `14:32:50Z`, then `AuthzInitializeContextFromSid` failed for SID `S-1-5-21-3572445798-2314295735-3149754986-6615` with a trust-relationship exception. PDC and BDC independently identify this SID as the recreated organization/OAB mailbox and report domain-partition replication result `0`. A local SSH SID-to-name translation also fails while `nltest /sc_query` returns PDC status `0`; these checks demonstrate a SID-resolution problem not explained by the passing secure-channel result alone.
- Exchange NTLM events sampled were audit-only `8002`/`8003`, not proof of an enforced block. Both DCs have `RestrictNTLMInDomain=5` and exception lists beginning with Exchange names; no NTLM, GPO, trust, firewall, or Exchange-service change was made in response. Investigate the OAB SID-resolution failure and the configuration-preservation warning separately before marking the recovery complete.
- Peter's interactive SID translation also failed with the trust-relationship exception; no audit search record was included in the supplied output. Fresh discovery found Exchange3 joined to `format.lu`, DNS limited to PDC/BDC, time synchronized to BDC, and Netlogon reporting a healthy BDC channel. PDC and BDC agree on the Exchange3 computer GUID, machine SID, password-set timestamp `2026-10-08 21:40:31`, key version `144`, and AES encryption types `24`. No additional machine-password reset was performed.
- Identified a likely RPC/NTLM compatibility cause: Exchange3 has `EnableAuthEpResolution=1` in `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc`, and RSoP attributes it to Default Domain Policy (`{31B2F340-016D-11D2-945F-00C04FB984F9}`). Both DCs have incoming NTLM `RestrictReceivingNTLMTraffic=2` and domain restriction `5`; the domain exception lists contain only Exchange aliases, not PDC/BDC. Microsoft's RPC interface restriction documentation states endpoint-mapper client authentication uses NTLM and is incompatible with incoming NTLM Deny All. SYSTEM Kerberos ticket metadata shows valid machine-account tickets to both DCs; no ticket purge occurred.
- No matching Exchange3 blocked-NTLM event was returned from the bounded DC sample; sampled enforced-block events concerned FILE/NUC-RIP and were not treated as proof of the Exchange failure or acted upon. The RPC policy conflict is a strong hypothesis requiring a scoped change and post-reboot validation, not yet a verified fix.
- Proposed follow-up: an Exchange3-only GPO override disabling RPC Endpoint Mapper Client Authentication, preserving domain NTLM restrictions and all other hosts. Microsoft documents a reboot requirement for this RPC setting. Obtain authorization for the exact policy exception and planned Exchange3 outage, document GPO precedence, backup/rollback and active-session gates, then recheck SID translation, OAB generation, audit readback, Exchange services and mail flow. No GPO, registry override, reboot, service restart, or broad NTLM exception was performed in this investigation.
- Peter authorized direct GPO creation/update, not a reboot. Precheck on PDC confirms GroupPolicy administration is available. Exchange3 is in `OU=_Edge-Servers with NTLM,OU=_Servers,OU=_Computers,DC=format,DC=lu`; Default Domain Policy is linked at domain-root order `1` and enforced, so a child-OU override cannot supersede this setting.
- Planned change: create a dedicated `EXCHANGE3 - RPC endpoint mapper compatibility` computer-policy GPO with only `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc\EnableAuthEpResolution` DWORD `0`; retain Authenticated Users read access but remove Apply, grant Apply only to `EXCHANGE3$`, disable the unused user configuration, then link at the domain root with higher precedence and enforcement. Other hosts are excluded by security filtering, and existing domain links retain their relative precedence. Back up Default Domain Policy and export the original link state before activation; rollback is to remove the new link and allow the preserved Default Domain Policy value `1` to apply, followed by a planned reboot. No NTLM restriction is to be changed. GPO creation, effective-state validation and reboot-dependent recovery results are pending at this point.
- Created `EXCHANGE3 - RPC endpoint mapper compatibility`, GUID `8329967d-20fa-495b-ac49-2e8e6e6f48ec`, with user configuration disabled and the sole registry-policy value `EnableAuthEpResolution` DWORD `0`. Verified the only `GpoApply` trustee is `EXCHANGE3$` SID `S-1-5-21-3572445798-2314295735-3149754986-3146`; Authenticated Users and Enterprise Domain Controllers have read access only. Administrative edit permissions were retained.
- Saved backups and before/after link/report exports on PDC in `C:\ProgramData\Codex\GPO-Backups\EXCHANGE3-RPC-20261010-165318`. Default Domain Policy backup ID is `531b6ae5-4169-484a-aea6-48b0f454b8c8`; the newly created GPO was also backed up after linking. These are GPO backups, not evidence of an Exchange data backup.
- Linked the new GPO at `DC=format,DC=lu`, order `1`, enabled and enforced, only after verifying its security filter and sole setting. Existing root links shifted down one position but their relative order, enabled/enforced flags and settings were preserved. Default Domain Policy still contains RPC value `1`; NTLM restrictions were not changed.
- BDC independently returns the same GPO, DWORD `0`, exact Apply trustee and enabled/enforced order-1 link. Its domain replication result is `0`. Exchange3 still has effective registry value `1`, with core Exchange services and temporary WinRM `Running`/`Manual`. No forced policy refresh, reboot, trust reset, ticket purge or Exchange service restart occurred. Activation and validation remain pending.
- Rollback: remove only the new link with `Remove-GPLink -Guid 8329967d-20fa-495b-ac49-2e8e6e6f48ec -Target 'DC=format,DC=lu' -Domain format.lu -Server PDC.format.lu`, then confirm the original links regain their previous relative order and the preserved Default Domain Policy applies RPC value `1`. A planned Exchange3 reboot is required for the RPC runtime change. Retain the unlinked GPO/backups for investigation rather than deleting unrelated policies.

- Peter explicitly authorized policy refresh, outage prechecks and an Exchange3-only reboot. At `16:59`, Windows Update events reported zero available updates; CBS recorded clean TrustedInstaller/TiWorker automatic shutdown at `16:57:32`, and both CBS/WU reboot markers were clear. No Setup, ExSetup or MSI installer was present. The Windows Update installer COM read was denied in SSH; CBS/process/event evidence was used instead, without bypassing access controls.
- Veeam's latest Exchange3 task log records `Success` at `2026-10-09 22:42:58`, with all 16 objects processed. The parent job finished with a warning associated with failed notification delivery, not an Exchange task failure. Current Veeam process inspection shows only `STARTINFRARESCAN`; the latest service-log job states are Stopped. This is backup-log evidence, not a restore test. The native module could not be loaded by Windows PowerShell 5.1 because it requires 7.6; no backup configuration or job was changed.
- At approximately `17:00`, computer-policy refresh returned exit `0`; the effective RPC DWORD is now `0`, and RSoP identifies the new GPO at precedence `1` ahead of Default Domain Policy at `2`. WinRM returned to `Stopped`/`Disabled`, with SSH still Running/Automatic. A separate `dggpext.dll` extension warning and bandwidth-estimation warning were recorded; they do not negate the verified RPC registry-policy result and remain follow-up items.
- All sampled transport queue-length counters, including external/internal active and retry queues, submission, poison, unreachable and shadow queues, were zero. Full `Get-Queue` remains unverified in the delegated SSH context. Automatic Exchange services were running; C: and E: had 55.4 GB and 78.1 GB free. The only interactive session was the operator's active administrator RDP session, covered by the explicit reboot authorization. SID translation still failed before reboot, as expected to require runtime activation; no repair success is claimed yet.

- The non-force restart at `17:01:23` was refused because the operator's RDP session was logged in; subsequent readback confirmed the original `08:13:33` boot time. No session was killed by that attempt. Peter then explicitly confirmed all work was saved and authorized a forced Exchange3-only restart. Runtime recovery checks remain pending until the new boot is verified.

- The authorized forced restart was issued at `17:02:20`; SSH subsequently became unavailable and returned with new boot time `2026-10-10 17:03:04`. No other VM or host was rebooted by this action. Effective RPC value remains `0`, and the formerly failing SID `S-1-5-21-3572445798-2314295735-3149754986-6615` now translates successfully to `FORMAT\SM_9181b5fa52e84e169`. PDC secure-channel testing returns True and `nltest` reports PDC status `0`; this validates resolution of the observed SID-lookup failure after the scoped policy change.
- At `17:04:04`, Health Manager was still StartPending and Transport was not yet running; both reached Running by `17:04:37` without intervention. At `17:05:26`, no automatic Exchange service was stopped. All sampled transport queue-length counters and current messages queued for delivery were zero. ESET core, Netlogon and SSH are running; WinRM remains Stopped/Disabled. CBS/WU reboot markers are clear.
- HTTPS OWA reached HTTP `200` after its redirect with certificate-chain verification result `0`; SMTP STARTTLS presented thumbprint `B053D9AF863A4931B04931418CFA60097E56458E`, valid through `2026-11-20 07:30:25Z`. These post-reboot probes used the internal address with the public server name. The daily win-acme task retains last result `0` from `09:52:52`; next run now reads `2026-10-11 12:29:29`. No forced renewal or certificate change was made.
- A corrected Application event-ID `5000` query returned no events since the reboot; the latest existing event is `16:28:25` from `MSExchange Management Application`. An initial query used the wrong provider name and returned a parameter error, so its apparent zero was not accepted as evidence. The existing `dggpext.dll` policy extension warning recurred at startup with error code `2147946961`; the RPC registry setting nevertheless remains verified. Configuration-preservation and this separate extension warning remain open.
- Domain SSH still cannot perform `Get-Queue` through the Exchange snap-in because its key-authenticated session has no usable delegated AD credentials. The OAB generator log has not recorded a new post-reboot generation at this checkpoint. Next steps require elevated interactive Windows PowerShell with the Exchange snap-in: verify full queues and mounted databases, request OAB generation again and read back the exact audit marker `Exchange3 recovery verification 20261010-163601`. Actual OAB completion and indexed audit readback are still unverified; no authentication restriction was relaxed to bypass this limitation.

- Peter's post-reboot interactive verification returned only the Ready submission queue with zero messages; both `Archive-DB2` and `Mailbox-DB3` are mounted. The default OAB generator remains the intended organization mailbox. The exact pre-reboot audit marker search returned `Audit matches: 0`, without a supplied error; this does not establish successful audit readback or distinguish a missing write from an indexing/search issue.
- At `17:42`, live SSH inspection confirms actual OAB recovery: `OABGeneratorLog\oabgen2026101015-1.LOG` records generation for GUID `3da2d70a-b4e7-422c-8090-bfaf3b80cf01`, upload of 192 OAB files to the mailbox, 55 records, status `0`, completed publication and `FinishProcessingOAB` at `2026-10-10 15:41:05Z` (`17:41:05` Luxembourg time). The prior SID exception belongs to the earlier failed run, not this successful one. An authenticated Outlook download has not been tested.
- No Application event `5000` was returned since the `17:03:04` reboot, and no automatic Exchange service was stopped during this check. Audit readback remains open: inspect the current audit configuration/agent and write a new uniquely marked test after the SID fix, then search after the documented indexing interval. No further reboot, service, GPO, authentication-policy or mailbox configuration change was made during this verification.

- Peter confirmed `AdminAuditLogEnabled=True`, cmdlet/parameter filters `*`, and `Admin Audit Log Agent Enabled=True`. The fresh post-repair write returned without a reported error for marker `Exchange3 post-repair verification 20261010-174420`; the subsequent indexed search again returned zero local marker matches after the 15-minute interval.
- At `18:01`, no Application event `5000` was returned since the fresh marker. Search, Host Controller, Information Store and Mailbox Assistants services are Running; WinRM remains Stopped/Disabled. Sampled errors were the known certificate-expiry warnings and DKIM async issue, plus an RBAC connection-leak warning, not a newly observed audit-write failure.
- Structured CSV parsing of `AuditingOptics\AdminAuditOptics\AdminAuditOptics20261010-1.LOG` found both manual-write operations: `14:36:30.957Z` and `15:44:37.268Z` (`16:36:30` and `17:44:37` local). Both report `CmdletSucceeded=1`, `AuditSucceeded=1`, and empty `LoggingError`. These are successful write-path diagnostics, not retrieval of the exact comment from the mailbox.
- `AuditingOptics\AuditSearchOptics\AuditSearchOptics20261010-1.LOG` reports successful searches with `ResultsReturned=1000` and `ErrorCount=0`, including the latest search at `16:00:42.391Z` (`18:00:42` local). Thus `Audit matches: 0` reflects the client marker filter after a capped result set, not a raw zero-entry server response. Remove server filters and inspect raw/manual-write records with a larger bounded result set before concluding that storage or indexing failed.
- Read-only locale inspection found `lb-LU` for system locale, the SSH user's culture, `.DEFAULT` and both service-account profiles `S-1-5-19`/`S-1-5-20`. Microsoft KB `3054391` documents incomplete/empty filtered audit searches associated with secondary regional formats for Exchange 2013/2016/2019; this is a plausible diagnostic lead, not a confirmed Exchange SE cause. No locale, GPO, mailbox, service or authentication setting was changed. Exact marker readback remains pending.

## 2026-10-11 - Audit Recovery Verification Completed

Maintainer: Codex with Peter

- Peter's interactive unfiltered `Search-AdminAuditLog -ResultSize 5000` returned 51 raw audit records and two `Write-AdminAuditLog` records, both with `Succeeded=True`.
- Enumeration of each record's `CmdletParameters` retrieved the exact Comment values: `Exchange3 post-repair verification 20261010-174420` at `2026-10-10 17:44:20` and `Exchange3 recovery verification 20261010-163601` at `2026-10-10 16:36:01`, Luxembourg time. These are operator-supplied interactive results, not a new successful delegated SSH query.
- Exact write-and-read verification has passed. Together with the previously verified SID lookup and successful OAB generation, this closes the system-mailbox audit recovery check. The earlier client predicate using `CmdletParameters.Value` and filtered searches did not provide reliable negative evidence; parameter enumeration now confirms the comments. No regional-format cause has been established, and no locale change is warranted by those earlier zero-match results alone.
- No additional reboot, service, certificate, GPO, authentication, locale or mailbox configuration change was made for this verification. Only the Exchange runbook and maintenance log were updated; unrelated working-tree changes were preserved.
- Remaining follow-ups are separate from the passed audit check: an authenticated Outlook OAB download and end-to-end inbound/outbound mail test, the configuration-preservation warning, the `dggpext.dll` policy-extension warning and the pre-existing DKIM async issue. These were not marked resolved by the audit readback.

## 2026-10-11 - Outlook OAB Download Follow-up

Maintainer: Codex with Peter

- Peter uses classic Outlook on his office Windows PC. Screenshots at `09:41:46` and `09:43:09` show a full-download request with the changes-only checkbox cleared, the placeholder `Download Offline Address Book List` instead of an OAB name, and error `0x8004010F` (`The operation failed. An object cannot be found.`). This is a failed client acceptance test, separate from the successful OAB generation and audit recovery.
- At `09:44`, live SSH confirms AD Topology, Information Store, Mailbox Assistants, Transport and SSH are Running; WinRM remains Stopped/Disabled. The latest OAB generation log records status `0`, 55 records and completed processing at `2026-10-11 07:04:55Z` (`09:04:55` local); the generated `oab.xml` exists and is current.
- PDC's local AD query confirms OAB GUID `3da2d70a-b4e7-422c-8090-bfaf3b80cf01` is the default, with the intended generating-mailbox link. Peter's mailbox is on `Mailbox-DB3`, with no explicit OAB override or address-book-policy link. The frontend OAB virtual directory's internal and external URLs both reference `https://exchange.format.lu/oab`.
- OAB distribution still needs an Exchange-native property read: raw AD returned `msExchOABFlags=32` without an OAB virtual-directory link in the selected properties. No flag meaning was inferred from that integer. A read-only installed-assembly type scan failed to load all dependent types, so it was not used to justify a configuration change.
- Next diagnostic: capture the office Outlook client's Test E-mail AutoConfiguration result, specifically its OAB URL or the corresponding error, then compare against the default OAB and Exchange-native web-distribution settings. Do not recreate the Outlook profile, delete its cache, change NTLM/GPO settings or modify OAB assignments speculatively. No production setting was changed in this inspection.

## 2026-10-11 - Outlook OAB Download Verification Completed

Maintainer: Codex with Peter

- Peter's initial Outlook Autodiscover XML contained mailbox/MAPI and EWS settings but no `OABUrl`. Interactive EMS confirmed the sole default OAB had `GlobalWebDistributionEnabled=False` and `VirtualDirectories={}`. Both frontend OAB URLs already referenced `https://exchange.format.lu/oab`; generation and generator assignment were not the remaining distribution gap.
- The guided change targeted only existing OAB GUID `3da2d70a-b4e7-422c-8090-bfaf3b80cf01`, setting `VirtualDirectories=$null` and `GlobalWebDistributionEnabled=$true`. Peter supplied the resulting `True` value and empty directory list, which is expected for global web distribution. This enables download distribution for users of that default OAB without changing authentication, URLs, generating mailbox or mailbox assignments. The recorded prior state provides rollback by restoring global distribution to False.
- Peter reported restarting the IIS websites himself. His subsequent Autodiscover XML includes `https://exchange.format.lu/oab/3da2d70a-b4e7-422c-8090-bfaf3b80cf01/` as `OABUrl`, matching the default OAB GUID. No raw Autodiscover attachment or delegate-mailbox details were copied into the repository.
- Peter confirmed 55 entries in the local address book in Outlook Classic offline mode. This completes operator-confirmed end-to-end client acceptance and matches the previously verified successful server generation count. The earlier `0x8004010F` OAB download issue is closed for the tested client; other clients were not separately tested.
- No additional remote command, reboot, profile/cache deletion, GPO, NTLM or mailbox-data change was performed for this final verification. The separate configuration-preservation warning, policy-extension warning, pre-existing DKIM issue and end-to-end inbound/outbound mail-flow test remain outside this passed OAB check.

## 2026-10-11 - Inbound and Outbound Mail Verification Completed

Maintainer: Codex with Peter

- After the passed Outlook offline address-book test, Peter confirmed that the requested incoming and outgoing email tests were both successful. Basic end-to-end mail-flow acceptance is now complete on the operator-tested paths.
- No message trace, full-header analysis, all-domain/connector test or ESET mail-flow policy validation was supplied; successful delivery alone does not establish those separate checks. The configuration-preservation warning, `dggpext.dll` policy-extension warning and pre-existing DKIM async issue remain open.
- No production command or configuration change was performed for this confirmation. Only the Exchange runbook and maintenance log were updated; unrelated working-tree changes remain untouched. No commit or push was requested or performed.

## 2026-10-11 - DKIM, Device Guard and Setup-Preservation Inspection

Maintainer: Codex with Peter

- Peter authorized follow-up of the remaining warnings. Discovery used local break-glass SSH on Exchange3 and a read-only GroupPolicy query on PDC; delegated Exchange cmdlets were not bypassed. The maintainer route to Exchange3 uses `utun6`. Host identity is `Exchange3`, SSH identity `exchange3\administrateur`, Windows Server 2022, with unchanged boot time `2026-10-10 17:03:04`.
- At approximately `10:15` Luxembourg time, AD Topology, Information Store, Transport, Frontend Transport and SSH are Running. WinRM remains Stopped/Disabled. All sampled submission, internal/external active/retry, poison and unreachable queue-length counters returned zero. These counters are not a fresh full `Get-Queue` query.
- `MSExchange Extensibility` event `1057` continues for Exchange DkimSigner, including `2026-10-11 09:38:14` and `10:00:50`. The installed signer DLL/configurator version is `3.4.0.0`; agents.config shows the signer and both ESET transport agents enabled. Upstream latest release resolves to v3.4.0, its README contains a 2023 maintenance notice, and issue 391 describes the matching async-resume error. No proven replacement/fix was established, and no agent was disabled or updated. Sources: [upstream release](https://github.com/Pro/dkim-exchange/releases/tag/v3.4.0), [matching issue](https://github.com/Pro/dkim-exchange/issues/391).
- Peter supplied the external recipient's headers for the outgoing test at `09:38`: Microsoft 365 reports `spf=pass`, `dkim=pass` and `dmarc=pass` for `format.lu`. The DKIM signature uses `d=format.lu`, `s=selector1` and relaxed/relaxed canonicalization. This validates that single delivered message despite the recurring agent event; it does not establish that every message or domain is signed correctly. ESET's `clean, is OK` header is present, not proof of full policy or attachment-scan coverage. Raw headers, recipient identifiers and message content were not copied into the repository.
- Safe signer-settings inspection found seven domains using selector1: format.lu, display.lu, displaycenter.lu, floc.lu, formatexpo.fr, nolimits.lu and lmr-sa.lu. Maintainer DNS queries returned DKIM TXT records for five domains; display.lu's selector query returned NXDOMAIN, and displaycenter.lu resolves through a Microsoft-hosted DKIM CNAME. Confirm whether the display domains moved to another mail platform before considering scoped signer cleanup; no DNS, key or signer setting was changed or rotated. Private-key contents were not read or displayed.
- Registry/file inspection identifies CSE `{F312195E-3D9D-447A-A3F5-08DFFA24735E}` as Device Guard (`dggpext.dll`, Microsoft file description). GroupPolicy event 7016 and DeviceGuard event 7001 return `2147946961` / `0x800711D1`; Windows decodes this as the hypervisor not protecting DMA because IOMMU is absent or not enabled. The latest sampled failure is `08:58:25`.
- Device Guard effective policy has VBS, HVCI, Credential Guard and System Guard enabled, with `RequirePlatformSecurityFeatures=3`. PDC's read-only Default Domain Policy query confirms matching settings; the RSOP registry-property query returned no matching rows, so it was not claimed as direct winning-GPO evidence. Guest Secure Boot returns True. `Win32_DeviceGuard` reports VBS status 1 (enabled/not running), configured services `{1,2,3}`, running services `{0}`, available properties `{2,4,5,6}` and required properties `{1,2,3}`; hypervisor and DMA capabilities are absent from the available set. CPU reporting also returns SLAT/VM-monitor extensions False. Windows code-integrity enforcement status 2 is distinct from running HVCI/VBS. Sources: [Microsoft VBS validation and policy requirements](https://learn.microsoft.com/en-us/windows/security/hardware-security/enable-virtualization-based-protection-of-code-integrity).
- Proposed next gate: inspect the existing Exchange3 VM's VBS, virtual-IOMMU and exposed hardware-virtualization settings in vCenter, then assess host/guest/driver compatibility and backup/outage/rollback before any VM or security-policy correction. No vCenter settings were inspected in this pass; no domain-wide GPO change, registry override or security disabling was performed.
- Setup log inspection found one historical ServiceHost preservation failure in February 2024 and three failures on `2026-09-05`: ServiceHost defaultProxy/appSettings and AD Topology system.serviceModel, each reporting the configuration file in use. The Oct10 AD-only run emits the generic warning without a new affected-file failure. Setup registry retains `PreservationCmdletsFailed=PreserveDefaultProxy,PreserveSystemServiceModel,PreserveAppSettings`.
- Compared only the affected current files with the exact September pre-upgrade copies at `C:\Program Files\Microsoft\Exchange Server\V15\Config\v_152174810_D20260905T1810\Bin`: all appSettings keys/values match, ServiceHost defaultProxy XML matches, and system.serviceModel XML matches for both ServiceHost and Directory.TopologyService. The sampled message/buffer/reader limits also match; both current files parse successfully. No restoration is indicated for these identified failures. Other missing-backup/section diagnostics were not treated as evidence of lost custom values, and no complete old file was restored or persisted warning marker cleared. Source: [Microsoft configuration preservation](https://learn.microsoft.com/en-us/exchange/plan-and-deploy/custom-configuration-preservation).
- No service restart, update, reboot, GPO, certificate, DNS, DKIM key, mailbox or production file change was made. Findings were recorded only in the Exchange runbook/log; unrelated repository changes remain untouched. DKIM event remediation and the Device Guard capability/policy mismatch remain open, while external authentication passes for the tested format.lu message.

## 2026-10-11 - Display MX and VBS Follow-up

Maintainer: Codex with Peter

- Peter reports Exchange3's Virtualization Based Security setting is off in vCenter and display mail moved to Microsoft 365. These are operator confirmations, not a new authenticated vCenter or Microsoft 365 tenant inspection.
- Live MX queries through the maintainer resolver and independently through `1.1.1.1` agree: `display.lu` has only priority-0 `display-lu.mail.protection.outlook.com`; `displaycenter.lu` has only priority-0 `displaycenter-lu.mail.protection.outlook.com`. Both records have TTL 3600. This verifies incoming mail's Microsoft 365 DNS entry point, not every mailbox's location or all internal relay routes.
- Standard selector1/selector2 CNAME lookups for display.lu return NXDOMAIN through both resolvers. The maintainer resolver returns displaycenter.lu CNAMEs `selector1-displaycenter-lu._domainkey.displaylu.y-v1.dkim.mail.microsoft` and `selector2-displaycenter-lu._domainkey.displaylu.y-v1.dkim.mail.microsoft`. Tenant-side DKIM enablement and outbound authentication remain unverified. Obtain display.lu's exact expected CNAME values from its Microsoft 365 DKIM configuration rather than inventing targets. Source: [Microsoft custom-domain DKIM configuration](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure).
- Display's on-prem signer entries were not removed. Before retirement, check whether applications, relays or hybrid routes still send these domains through Exchange3; the MX destination alone is not permission or sufficient evidence to change outbound signing or accepted domains. No key rotation or DNS change was made.
- Important compatibility correction to the earlier VBS investigation: the existing Device Guard policy also configures Credential Guard (`LsaCfgFlags=1`), and Microsoft's application requirements state enabling Credential Guard on Exchange Server is unsupported. Do not activate VMware VBS under that policy merely to satisfy the DMA requirement. An Exchange3-only policy design must exclude unsupported Credential Guard and separately review HVCI/System Guard, guest/driver compatibility and VM capabilities, with explicit change authorization, backup and rollback. Default Domain Policy and all VM/security settings remain unchanged. Source: [Microsoft Credential Guard application requirements](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/#application-requirements).
- Only DNS discovery and the Exchange runbook/log were updated in this follow-up. No remote production configuration command, reboot, VM power action, signer cleanup or commit/push was performed.

## 2026-10-11 - Display Sender and Relay Investigation

Maintainer: Codex with Peter

- Peter requested inspection for any remaining display.lu/displaycenter.lu sending through Exchange3 before retiring the signer entries. Scope was read-only transport logs and directory configuration; no tenant, sender, alias, connector, mailbox or signer change was performed.
- Local SSH confirmed Exchange3 and `exchange3\administrateur` at approximately `10:29` Luxembourg time. Tracking retention contained 1,798 MSGTRK/MSGTRKMD/MSGTRKMS files, totaling 105.7 MiB, with log-header UTC dates from `2026-09-11 08:01:24` to `2026-10-11 08:00:50`; the current files continued to receive records. This is an approximately 30-day observation window, not an all-time or tenant-wide search.
- Structured CSV parsing used each file's `#Fields` header and tested sender-address and return-path domain suffixes separately from recipients. The first summary attempt retained a leading space in the first column name and hit a PowerShell Group-Object null-value error; its timestamp/group output was not accepted. The corrected parser trims headers, requires the relevant fields, parses timestamps and groups using explicit string keys. Both corrected tracking passes returned zero file errors. Subjects, bodies, recipient addresses and raw message identifiers were not exported to the repository.
- Of 646 display-domain text-matching rows, 356 had a display-domain sender or return-path. All were Incoming display.lu events: 71 SMTP RECEIVE, 71 HAREDIRECTFAIL, 72 AGENTINFO, 70 SMTP SEND, 70 STOREDRIVER DELIVER, one ROUTING TRANSFER and one ROUTING FAIL. Matches span `2026-09-15 12:09:47Z` to `2026-10-09 08:50:10Z`. The 70 SEND events all use `Intra-Organization SMTP Send Connector` with Exchange3 as destination; these are internal delivery, not external outbound sending. The rows involve two external sender addresses, omitted here.
- Zero matched Originating events, zero matched STOREDRIVER submission events and zero matched SEND events via an external connector were found for either domain. Displaycenter.lu has zero sender/envelope matches. RECEIVE original-client addresses fall in Microsoft 365's 40.107/52.101 ranges. Sender-address represents Sender, or From when Sender is absent; return-path represents the SMTP envelope sender. A distinct From domain obscured by a different Sender header may not be represented by this test. Source: [Microsoft message-tracking fields and events](https://learn.microsoft.com/en-us/exchange/mail-flow/transport-logs/message-tracking).
- Independently scanned all 720 retained frontend SMTP receive logs (202.1 MiB), using structured CSV and the SMTP MAIL FROM command field. Zero file errors; 72 display.lu MAIL FROM commands, zero displaycenter.lu commands, zero private IPv4 source addresses and zero IPv6 sources. Remote IPv4 prefixes are 40.107 (23 commands) and 52.101 (49 commands), consistent with the tracking RECEIVE sources. Commands do not equal successfully accepted unique messages; the extra command relative to tracking RECEIVE was not treated as a new local sender. Hub SMTP receive/send protocol directories contain no retained files, so those paths provide no independent protocol evidence.
- PDC local AD configuration inventory lists five accepted domains, none a display domain. The sole send connector `Sendconnector MX` has routingList `SMTP:*;1`, not a display-specific route. Default email-address-policy templates contain format.lu, nolimits.lu and lmr-sa.lu, not display.lu/displaycenter.lu. Receive connector bindings/IP ranges were inspected as metadata; no relay-permission or open-relay conclusion was inferred from their IP ranges alone.
- Sixteen directory objects retain display-domain proxy addresses, including ordinary mailboxes, scanners, EasyjobSync, distribution groups and system recipients. Their aliases alone are not evidence of current sending, but represent a dormant-use risk; no alias cleanup or mailbox deletion was authorized or performed.
- Conclusion: no observed locally originating or external outbound display-domain mail in the retained window. The existing signer entries appear obsolete for current observed traffic, while incoming display.lu messages still arrive from Microsoft 365. Before applying retirement, retain a rollback copy, remove only the two named signer entries, leave all private keys/aliases/other five signing domains untouched, and establish any required reload/restart gate. Do not present this finite log search as proof that a monthly/quarterly application can never send again. Signer retirement and any transport restart were not performed in this inspection.

## 2026-10-11 - Authorized Display DKIM Signer Retirement

Maintainer: Codex with Peter

- Peter explicitly authorized a settings backup and removal of only display.lu/displaycenter.lu from the signer, preserving keys and aliases. Scope was Exchange3's DKIM settings.xml only, not SSL/TLS, AD, DNS, connectors, tenant configuration or transport-agent installation.
- Reconfirmed local SSH identity `exchange3\administrateur`, signer version `3.4.0.0`, seven configured domains and Running transport/frontend/Information Store services. Pre-change settings SHA256: `2A530B2B3923929ADA951D27ACA7514A5238CD998CE3A7977295C67900AE62D3`.
- Verified backup: `C:\Program Files\Exchange DkimSigner\maintenance-backups\20261011-104654-display-retirement\settings.xml`, checksum identical to the original. before.json records settings ACL, domain inventory and key-file metadata; after.json records results. The change script is archived beside them. Private-key contents were not read/exported by the maintenance script; the running signer reloads its existing keys normally.
- The first execution created a separate verified staging backup under `20261011-104633-display-retirement` but failed before modifying live settings: PowerShell marshaled the null File.Replace backup argument as an invalid path. The corrected execution uses an explicit same-directory replacement-backup path. The original settings hash was guarded again before retry; no live change occurred in the failed attempt.
- XML parsing and candidate/post-write comparisons removed exactly the two target DomainElement nodes. Remaining domains, in order: format.lu, floc.lu, formatexpo.fr, nolimits.lu, lmr-sa.lu. Selectors/key references, signing algorithm, canonicalization and headers-to-sign remain unchanged. Settings ACL and all 20 key-file metadata records (name, size, UTC write time and ACL) matched; certificate-store inventory also matched. No directory write occurred, so aliases were untouched.
- Post-change settings SHA256: `8A0D7EB3C545B293245D0D926C5C4E2E9913533FCD85662F74519D0406BFCCA5`; independently read back after completion. Atomic replacement avoided exposing a partially written XML file; LastWriteTimeUtc notification triggered the existing watcher. Source: [v3.4.0 settings reload implementation](https://github.com/Pro/dkim-exchange/blob/v3.4.0/Src/Exchange.DkimSigner/DkimSigningRoutingAgentFactory.cs).
- Live Exchange DKIM events: `10:46:54`, record `19182132`, detected change/reloading; `10:46:55`, record `19182133`, loaded RSA-SHA256, relaxed/relaxed, Number of domains: 5. No DKIM reload error was returned. Transport process `14732` was unchanged; transport, frontend transport and Information Store remained Running/Automatic. No service restart or reboot was performed.
- Independent post-change check returned zero for all sampled submission, internal/external active/retry delivery, mailbox active/retry delivery, unreachable and poison queue-length counters across their reported instances. The first counter selection omitted the Internal/External name prefixes and was rejected as incomplete before sampling; the corrected selection used the host's enumerated counter paths. A repeated signer-event read returned only the successful change/reload events, with no subsequent reload error.
- Rollback: stage the verified backup with its original ACL on the same volume, atomically replace live settings, update LastWriteTimeUtc and check for a successful seven-domain reload. Preserve current settings as a separate rollback-time archive; do not overwrite a concurrent edit blindly. Retained keys allow reinstatement without rotation.
- Follow-up: send another external format.lu message and check recipient Authentication-Results for DKIM pass after retirement. The earlier passed message is pre-change evidence only. This cleanup does not resolve the pre-existing async-resume event 1057 or configure Microsoft 365 signing for display.lu. No commit/push was requested.

## 2026-10-11 - Post-Retirement External DKIM Acceptance

Maintainer: Codex with Peter

- Peter supplied the external recipient's headers for the test sent at `10:54:47` Luxembourg time, after the `10:46` signer cleanup. Microsoft 365 received it at `08:54:48 UTC`; this is post-change evidence rather than the earlier pre-change test.
- Recipient Authentication-Results reports `spf=pass` for format.lu, `dkim=pass` with verified signing domain format.lu, `dmarc=pass` for format.lu and `compauth=pass`. DKIM remains RSA-SHA256, selector1, relaxed/relaxed canonicalization. The Exchange-to-Microsoft-365 Received header records TLS 1.2; ESET's clean-result header is present.
- Post-change outbound delivery/signing acceptance passed for this message. This does not establish signing for every remaining domain, attachment-scan coverage, or resolution of the pre-existing async-resume event 1057. Microsoft 365 DKIM configuration for display.lu remains a separate follow-up.
- Only this sanitized verification summary was added to the Exchange runbook/log. Raw headers, signatures, recipient addresses, message identifiers and body content were not copied into the repository. No remote production change, restart or commit/push was performed.

## 2026-10-11 - Display.lu Microsoft 365 DKIM DNS Setup

Maintainer: Codex with Peter

- Peter opened the signed-in Cloudflare display.lu DNS page after requesting access to set the DKIM DNS values. Initial zone inventory contained eight records and no DKIM selectors. Microsoft Defender confirmed display.lu NoDKIMKeys/Disabled; displaycenter.lu was already Valid/Enabled and was left unchanged.
- Created DKIM keys for display.lu in the tenant and read the exact Publish CNAMEs dialog values. No guessed tenant prefix or partition value was used. Private tenant keys were neither accessible nor exported; no old on-prem keys were touched.
- Exported the pre-change Cloudflare zone at `11:04:14` Luxembourg time. The browser download-event wait timed out, but filesystem verification confirmed the complete 1,729-byte export. Retained copy: `~/Downloads/display.lu-before-dkim-20261011-110414.txt`, SHA256 `a5ecf3d18871f0058d4dfaaa99147e444464ba85cb55bf5a9f85934cb6606b4b`.
- Added only DNS-only CNAMEs `selector1._domainkey.display.lu` -> `selector1-display-lu._domainkey.displaylu.a-v1.dkim.mail.microsoft` and `selector2._domainkey.display.lu` -> `selector2-display-lu._domainkey.displaylu.a-v1.dkim.mail.microsoft`. Cloudflare TTL is Auto; authoritative DNS reports 300 seconds. Verified proxy disabled before saving each record and verified both rows afterward. The first native switch click only focused the control; the semantic checked-state operation applied DNS-only mode before either save.
- Post-change export at `11:08:42`: `~/Downloads/display.lu-after-dkim-20261011.txt`, SHA256 `1fac8d96ec72623232625167c6faa6f50b40fb765b54abb7b3f848524380fafd`. Diff shows only the two new CNAMEs, export timestamp and SOA serial change. All eight existing CNAME/MX/TXT records and proxy/TTL settings remain unchanged.
- Read-only DNS checks through alex.ns.cloudflare.com and 1.1.1.1 resolve both CNAMEs to the exact tenant-provided targets. Both Microsoft targets return `v=DKIM1; k=rsa` public-key TXT records. No key material or account identifiers were copied into the repository.
- First Microsoft 365 enablement attempt returned CnameMissing: publish the two CNAMEs and allow synchronization. Correct DNS publication was independently verified; signing remains Disabled until the tenant accepts enablement. Bounded retry and an external display.lu test are pending at this checkpoint, not marked passed.
- One subsequent enablement retry returned the same validation error. Final page readback confirms display.lu CnameMissing/Disabled, displaycenter.lu Valid/Enabled and the other tenant rows unchanged. Both Cloudflare authoritative servers now return the exact new CNAMEs. Microsoft validation/synchronization remains pending, not a reason to overwrite correct records or repeatedly generate keys. Retry later, then verify an external display.lu test message before calling signing accepted.
- Saved proof screenshots: `~/Downloads/display-lu-dkim-cloudflare-20261011.jpg` and `~/Downloads/display-lu-dkim-m365-pending-20261011.jpg`. DNS setup is complete; tenant signing enablement and the external message test are outstanding. The relevant browser pages were left open for continuation.
- Scope excludes Exchange3 settings, local keys, aliases, certificates, displaycenter.lu, other tenant domains, MX/SPF/web records and DMARC. Rollback requires authorized disabling of display.lu tenant signing followed by removal of only the two added CNAMEs, not wholesale zone import. No commit/push was requested.

## 2026-10-11 - Authorized Display.lu DMARC Monitoring

Maintainer: Codex with Peter

- Peter explicitly authorized `p=none` and aggregate reports to `Peter.Czibula@format.lu`. Pre-change 1.1.1.1 queries returned NXDOMAIN for `_dmarc.display.lu` and `display.lu._report._dmarc.format.lu`. The existing post-DKIM display.lu export contained all ten current records before this addition.
- Added DNS-only TXT `_dmarc.display.lu` with `v=DMARC1; p=none; rua=mailto:Peter.Czibula@format.lu`, TTL Auto. This monitors authentication without requesting rejection or quarantine. No `ruf` forensic reporting or third-party reporting service was enabled.
- The chosen reporting destination is external to display.lu. After exporting format.lu's 36-record zone, added only DNS-only TXT `display.lu._report._dmarc.format.lu` with `v=DMARC1;`, TTL Auto, to authorize aggregate reports for this specific source domain. No wildcard permission was added. Source: [RFC 7489 external destination verification](https://www.rfc-editor.org/rfc/rfc7489.html#section-7.1).
- Readback in Cloudflare confirms both records. Authoritative alex.ns.cloudflare.com returns the exact display.lu policy; zita.ns.cloudflare.com returns the exact authorization record. Independent 1.1.1.1 queries return both exact values. Cloudflare's refreshed display.lu page shows All set / No recommendations; this is DNS-configuration acceptance, not proof of outbound DKIM or report delivery.
- Display pre-change archive: `~/Downloads/display.lu-after-dkim-20261011.txt`, SHA256 `1fac8d96ec72623232625167c6faa6f50b40fb765b54abb7b3f848524380fafd`. Post-change export at `11:32:17` Luxembourg time: `~/Downloads/display.lu-after-dmarc-20261011.txt`, SHA256 `f6b60842e6bfab499f3d5a278c0993f7c96f369d8c6f0b3ca1a2c56587323e49`. Diff shows only the new DMARC TXT plus export time/SOA serial.
- Format pre-change export at `11:30:56`: `~/Downloads/format.lu-before-display-dmarc-20261011.txt`, SHA256 `09fae1158f24aa72a663bb766797a6b49b0a03e9cc3ca19b79bdf333cc8122b6`. Post-change export at `11:31:53`: `~/Downloads/format.lu-after-display-dmarc-20261011.txt`, SHA256 `2714ddc847ec2b2eb704d54c7a64b19639bdb587fcc00ad0c6989e3e8eb0d055`. Diff shows only the domain-specific report authorization plus export metadata. All 36 pre-existing records, including format.lu's `p=reject` policy, remain unchanged.
- Saved screenshots: `~/Downloads/display-lu-dmarc-monitoring-final-20261011.jpg` and `~/Downloads/display-lu-dmarc-report-authorization-20261011.jpg`. Initial policy screenshot also retained. Zone exports are archival evidence, not files to import wholesale.
- No MX, SPF, DKIM selector, certificate, alias, Exchange setting, displaycenter.lu policy or service was changed. No reboot, key rotation, commit or push was performed. Only the two additions and these Exchange runbook/log notes are part of this follow-up; unrelated dirty work remains untouched.
- Follow-up: verify actual report arrival, review legitimate senders before enforcement, and finish display.lu tenant DKIM activation/external-message verification. Last refreshed Microsoft view before this DMARC change still showed CnameMissing/Disabled. Rollback requires authorized removal of only the two new TXT records after checking for concurrent edits; report collection would stop.

## 2026-10-11 - Display.lu DKIM Activation and Signed Test

Maintainer: Codex with Peter

- Peter supplied headers for the 11:40 test from a display.lu mailbox to his on-prem format.lu mailbox. The message was submitted in Microsoft 365 at approximately 09:40:47 UTC and received by Exchange3 at 11:40:49 Luxembourg time. Sender/recipient local parts, raw identifiers, signatures and body content were not copied into the repository.
- Live read-only Microsoft Defender inspection now confirms display.lu Valid/Enabled and displaycenter.lu still Valid/Enabled. This supersedes the earlier pending CnameMissing checkpoint. Codex did not toggle or rotate tenant keys in this verification pass.
- The received message contains a DKIM-Signature with `d=display.lu`, `s=selector1`, RSA-SHA256 and relaxed/relaxed canonicalization. Microsoft's ARC-Authentication-Results reports SPF, DKIM and DMARC pass for display.lu. The ordinary Authentication-Results header instead reports DKIM none/message not signed and DMARC none. These are different processing observations, not proof that the final message lacks a signature; the reason for the earlier none result is not established from these headers alone.
- Delivery and active custom-domain signing are confirmed. ARC results are upstream assertions; they are not an independent verification by the on-prem recipient, and ARC cryptographic validation was not performed. ESET clean/antispam OK headers and TLS 1.2 on Microsoft 365-to-Exchange3 transport are present, without claiming attachment-scan coverage.
- Follow-up: send a new display.lu message to Gmail or another external provider and inspect that recipient's own Authentication-Results for `dkim=pass` with display.lu alignment and `dmarc=pass`. Microsoft recommends another email system for DKIM acceptance testing: [Microsoft verification guidance](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure#verify-dkim-signing-of-outbound-mail-from-microsoft-365). DMARC remains monitoring-only; report delivery and sender coverage remain pending before enforcement.
- Only the runbook/log were updated. No DNS, certificate, alias, signer, service, reboot, commit or push action was performed.

## 2026-10-11 - Display.lu Independent External Acceptance

Maintainer: Codex with Peter

- Peter supplied the external recipient's headers for the 11:43 display.lu test. Microsoft 365 submitted the message at 09:43:32 UTC; receiving server www165.your-server.de delivered it at 11:43:37 Luxembourg time. Personal addresses, raw signatures, message identifiers and body content were not copied into the repository.
- The receiving server's own Authentication-Results reports SPF pass for display.lu, DKIM pass with `header.d=display.lu`, `header.s=selector1`, RSA-SHA256, and DMARC pass with `header.from=display.lu`. Its separate X-DKIM-Status also reports pass. This is independent recipient verification, not merely Microsoft's upstream ARC assertion. The older Microsoft Authentication-Results none header remains in the message but does not contradict the receiver's verification of the subsequently signed message.
- Received headers show direct Microsoft 365-to-external delivery over TLS 1.3, without traversing Exchange3. Active DKIM signing and independent acceptance are complete for this tested sending path. This does not prove all application senders, displaycenter.lu acceptance, or aggregate-report delivery.
- DMARC remains `p=none`; no additional DNS or tenant change was made. Follow-up is to confirm reports arrive at the authorized mailbox and review legitimate source coverage before considering quarantine/reject. Only these Exchange runbook/log notes were updated; no service action, key rotation, commit or push was performed.

## 2026-10-18 - Inbound Mail Delivery Incident Inspection

Maintainer: Codex with Peter

- Read-only inspection at approximately 21:58-22:05 Luxembourg time after Peter reported missing inbound mail. Domain SSH works; Windows Server 2022 last booted on 2026-10-17 at 03:12. All automatic Exchange services, IIS and ESET are running. WinRM remains intentionally Stopped/Disabled. Free space is approximately C: 52.7 GB and E: 77.6 GB.
- DNS returns MX `10 exchange.format.lu` and A `217.31.68.238`. From the maintenance VPN, SMTP greeting/EHLO succeed with STARTTLS advertised; HTTPS certificate validation succeeds and `/owa/` returns HTTP 440 without an authenticated session. These are VPN-path checks, not an independent Internet delivery test.
- Transport performance counters report retry mailbox delivery queue length `76`, active mailbox delivery `0`, submission `0` and external retry `0`. These are sampled counters, not a full Get-Queue inventory. Latest mailbox-delivery tracking file is `MSGTRKMD2026101722-1.LOG`, with DELIVER at `2026-10-17T22:01:02.589Z` (2026-10-18 00:01:02 Luxembourg time).
- Today's message tracking repeatedly defers Peter's mailbox delivery with `432 4.3.2 STOREDRV; mailbox database is offline`, `MailboxOfflineException.MapiExceptionMdbOffline`, and inability to open the Microsoft System Attendant mailbox. Recent Mailbox Replication event 1006 reports MapiExceptionMdbOffline for both Mailbox-DB3 and Archive-DB2. Store service and both worker processes remain running; these facts do not establish whether the databases are actually dismounted or inaccessible for another reason.
- Peter reported an earlier sender-side DMARC rejection and an iCloud resend. Sender-specific tracking confirms the resend reached Exchange at `2026-10-18T19:59:44.555Z` (21:59:44 local), followed by AGENTINFO; no corresponding delivery was found in that inspection. The rejection text has been requested; its cause is not established and must not be conflated with the confirmed mailbox-delivery failure. Sender details and message content were not copied into this log.
- `nltest /sc_query` returns BDC with connection status 0. The Exchange3 RPC compatibility value `EnableAuthEpResolution=0` is still effective. No trust reset or policy change was attempted.
- A read-only Exchange snap-in query for `Get-MailboxDatabase -Status` fails with the known key-authenticated SSH delegated-credential limitation. Interactive EMS must verify mounted status and full queue errors before choosing recovery. No database mount/dismount, service restart, transport retry, reboot, update, certificate or security-policy change was performed.
- Separate warnings remain: filtering-engine download failures, ESET/DKIM async-resume event 1057, and a transport Watson event. The current exchange.format.lu certificate has a private key and expires 2027-01-14; it is not expired. The win-acme task's 2026-10-18 run returned `4294967295`, requiring separate log inspection; no forced renewal was run. These observations are not established root causes of the mailbox outage.
- Follow-up: obtain interactive `Get-MailboxDatabase -Status` and `Get-Queue` output, determine the cause of database unavailability, then authorize the narrow recovery and verify queued-message delivery. Obtain the earlier DMARC rejection separately. No commit or push was performed.

## 2026-10-18 - Black Desktop During Incident Access

Maintainer: Codex with Peter

- Peter reported sihost.exe system-error dialogs and a black desktop with no Start menu while attempting interactive access; exact dialog wording and confirmation of the affected host were requested. Read-only Exchange3 inspection at 22:05 finds an active administrator RDP session opened at approximately 22:02. Its sihost.exe and dwm.exe processes are present, but explorer.exe, ShellExperienceHost and StartMenuExperienceHost are absent from the process sample.
- Machine Winlogon Shell is `explorer.exe`; Userinit points to the expected Windows system32 executable. Both explorer.exe and sihost.exe exist and are nonempty. This metadata is not an integrity verification. No matching Application crash/hang report was returned by the sampled last-two-hour query; no profile-service or Shell-Core warning/error was returned by the sampled last-hour queries. The sihost error's cause remains undetermined.
- Core Exchange services and User Profile Service remain running. CBS and Windows Update reboot flags are clear. Approximately 1.15 GiB physical memory is free out of 16 GiB; no out-of-memory cause is established. BITS repeatedly fails with 0x80004005 and associated DCOM activation timeouts; no causal connection to the desktop or mailbox outage is established.
- Guided the operator to open Task Manager in the remote session and run explorer.exe; restoration is not yet confirmed. An interactive elevated PowerShell window can be launched from Task Manager to obtain the pending Exchange diagnostics without depending on the Start menu. No remote process termination/launch, sign-out, profile modification, service restart, reboot or repair command was performed.

## 2026-10-18 - Interactive Database and Queue Verification

Maintainer: Codex with Peter

- Peter successfully restored the desktop by launching explorer.exe; the Start menu still does not work. Normal elevated interactive Windows PowerShell with the Exchange snap-in is usable.
- Interactive `Get-MailboxDatabase -Status` reports `Mounted=True` for both Archive-DB2 and Mailbox-DB3, while warning that last backup time, database size/available space and worker process information cannot be retrieved for either database. This supersedes any inference that the transport error alone proves actual dismount; mailbox access remains impaired despite the reported mounted status.
- Interactive `Get-Queue` confirms Exchange3\951 in Retry with 77 messages and the same 432 4.3.2 STOREDRV / MapiExceptionMdbOffline / Microsoft System Attendant error. Submission is Ready with zero messages. No queued message was removed, resubmitted or manually retried.
- Read-only SSH inspection at 22:14 confirms Store service and both Store worker processes are still present with their original 2026-10-17 startup times. The sampled midnight window also shows BITS/DCOM failures, IMAP and Mailbox Replication unexpected terminations, an ECP application-pool communication failure and Store-assistant access errors. These are correlation evidence, not a proven common cause.
- Next interactive diagnostics: mailbox-database copy status, MAPI connectivity and server component states. Do not infer database corruption, recreate system mailboxes, or run mount/dismount/repair commands from the transport error alone. No production recovery change has yet been performed.

## 2026-10-18 - Mounted Databases Fail Live MAPI Access

Maintainer: Codex with Peter

- Peter's interactive database-copy query returns Mounted with no ErrorMessage for Archive-DB2 and Mailbox-DB3. Both `Test-MAPIConnectivity` results fail with MailboxOfflineException / MapiExceptionMdbOffline (ec=1142) while opening Microsoft System Attendant. ServerWideOffline, HubTransport and FrontendTransport all report Active. These results confirm an access failure despite the reported mounted state; maintenance mode is not the observed block.
- At approximately 22:16, read-only SSH confirms Information Store, RPC Client Access, Replication, AD Topology, Windows RPC, endpoint mapper and DCOM services running. Store controller, both workers and RPC Client Access have TCP listeners. Sampled retry mailbox queue length remains 77. No service was restarted.
- Domain secure-channel tests explicitly targeting PDC and BDC both return True. The organization-mailbox SID that failed during October recovery now resolves successfully. No recent Netlogon warning/error is returned by the sampled last-day query. These checks do not establish the cause of the current Store access failure, but provide no evidence for another trust reset or RPC-policy change.
- No local Veeam/backup/repair process is present in the process-name sample; VSS and software shadow provider are stopped. No Exchange backup completion is returned by the sampled MSExchangeIS event query. This is not proof of a successful recent backup or absence of a job controlled by the backup server; backup protection remains unverified.
- The sampled mailbox-database failure-item channel has no new October entry (newest entry is 2026-08-23). HighAvailability Operational repeatedly reports event 875 for an absent replication TCP-port registry value; causal relevance is not established and no registry value was added.
- Proposed next recovery, not performed: a controlled Information Store service restart after confirming recent backup/no active backup or restore and obtaining explicit approval for interruption of both databases. This would affect all mailbox clients and temporarily take both databases offline. Preserve transport queues and transaction logs; do not force-kill workers or run database repair. Recovery and subsequent MAPI/queue-drain acceptance remain pending.

## 2026-10-18 - Authorized Graceful Restart and Delivery Recovery

Maintainer: Codex with Peter

- Peter chose a normal Exchange3 restart, confirmed no backup jobs running and explicitly confirmed a successful backup from yesterday. Backup success is operator-confirmed, not an independently queried Veeam job result. The only logged-in user was the operator's administrator RDP session; no local installer/backup/repair process was found and CBS/WU reboot flags were clear. Pre-restart retry mailbox queue length was 77, submission 0 and external retry 0.
- Issued a planned Windows restart using `shutdown.exe /r /t 0 /d p:4:1` with an operator-approved incident comment and without `/f`. The request returned exit 0. SSH became unavailable briefly, then recovered. Verified LastBootUpTime is 2026-10-18 22:21:32 Luxembourg time, replacing the previous 2026-10-17 boot time. No hard reset or ESXi/other-VM power action was performed.
- Early startup check found Transport still stopped and queue counters not yet available. No manual service start/restart was attempted. By 22:23:24 all automatic Exchange services were running. Store events 40018 confirm successful mounts of both Mailbox-DB3 and Archive-DB2 at 22:22:35, with subsequent mount operations reporting NoError.
- At 22:23:51 retry mailbox delivery was 0, but submission was still 61; this intermediate checkpoint was not treated as a fully cleared queue. By 22:24:49 all 19 sampled total queue-length counters, including submission, active/retry mailbox and remote delivery, poison, unreachable, delay and shadow, were 0.
- The new mailbox-delivery log contains 82 DELIVER records after reboot, latest sampled timestamp 22:24:22 local. A sender-and-recipient-specific check confirms the previously accepted external iCloud resend was delivered to Peter's mailbox at `2026-10-18T20:24:20.126Z` (22:24:20 local). This verifies actual Store delivery rather than just an empty queue; no message subjects, personal sender address, body or raw identifiers were copied into the repository.
- Peter independently confirmed that the desktop and Start menu now work normally and emails are arriving. Immediate operational recovery is accepted. Fresh interactive Test-MAPIConnectivity and full Get-Queue output were not collected after reboot; do not label those exact tests passed from the log/counter evidence alone.
- Post-restart SMTP greeting, EHLO, STARTTLS, post-TLS EHLO and HELP all succeed from the maintenance VPN. TLS 1.2 certificate chain/hostname verification passes; exchange.format.lu certificate expires 2027-01-14. No test email was injected by this probe. HTTPS certificate validation also succeeds; unauthenticated OWA returns HTTP 440. These are VPN-path checks, not an independent external round-trip test. Domain channel query reports PDC with status 0; WinRM remains intentionally Stopped/Disabled.
- Postboot warnings include recurring ESET/DKIM async-resume events, certificate-expiry notices for the still-valid certificate, historical deleted EXCHANGE2 routing references, NLS sort-version warnings and one mailbox approaching its quota. Their relevance to the incident is not established; no speculative policy, registry, mailbox, agent, certificate or AD change was performed. The earlier failed win-acme task and sender-reported DMARC rejection remain separate follow-ups.
- No update installation, database repair, explicit mount/dismount, message resubmission/deletion, GPO/firewall change or standalone Store restart was requested or performed. Root cause remains unresolved despite recovery. Runbook/log updated; no commit or push requested.

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
