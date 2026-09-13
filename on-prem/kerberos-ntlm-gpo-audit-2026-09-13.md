# Kerberos And NTLM GPO Audit

Date: 2026-09-13

## Intent And Scope

User intent: prefer Kerberos and minimize NTLM; retain NTLM only for approved
edge servers. The initial audit was read-only. No GPO, link, security filter, registry,
service, firewall, AD object, or authentication setting was changed. No reboot
was requested during this audit.

The later authorized ADMIN exception removal is tracked separately below;
the original findings describe the pre-change snapshot.

Inspected all 17 GPO reports directly on PDC and BDC, selecting authentication
security options, RPC/Kerberos administrative settings, and relevant registry
preferences. Checked links, priority, application filtering, server OU placement,
and effective registry values on PDC, BDC, KUHNLE, and LMR. Raw GPO reports,
user identities, credentials, ticket contents, and detailed logs were not saved
to this repository. This is not an audit of every unrelated policy or every
client's effective configuration.

PDC SSH initially timed out while LDAP, SMB, and ADWS remained reachable from
BDC. A remote GPO query from BDC to PDC failed with RPC error 1722 and ADWS
authentication also failed. Direct SSH subsequently recovered; PDC reported a
13:36:26 boot. Final PDC results below are direct observations, not assumptions
from BDC. The cause of the earlier SSH outage was not investigated here.

## Replication And Precedence

- All 17 GPO computer/user AD and SYSVOL version pairs match on both controllers.
- Relevant authentication-policy definitions match between PDC and BDC.
- PDC's five inbound replication contexts report successful last attempts;
  the writable domain context succeeded at 13:41:31. This is a point-in-time
  check, not an isolated restore or complete AD health test.
- Domain link order 1: Default Domain Policy, enabled and enforced.
- Domain link order 2: Drive mapping, enabled and enforced.
- Default Domain Policy, NTLM Block, NTLM Allow, Drive mapping, and the unlinked
  Enforce NTLNv2 GPO have Authenticated Users application permission and no WMI filter.

The findings are policy-design conflicts, not evidence of GPO version drift.

## Findings

### 1. RPC Discovery Conflicts With NTLM Blocking

Default Domain Policy enables **Enable RPC Endpoint Mapper Client Authentication**
(`EnableAuthEpResolution=1`). The same setting is effective on all four checked
servers. NTLM Block denies incoming NTLM on domain controllers and core servers.

This RPC discovery option uses NTLM even when the actual service call can use
Kerberos. Microsoft documents its incompatibility with incoming/outgoing NTLM
deny-all settings and recommends retaining NTLM restrictions instead of that
option. The earlier Kuhnle diagnostic also found Kerberos RPC successful and
NTLM RPC denied against BDC. This supports the policy-conflict diagnosis without
proving it is the sole cause of every observed authentication failure.

Source: [Microsoft RPC interface restrictions](https://learn.microsoft.com/en-us/windows-server/security/rpc-interface-restrict).

**Precedence correction:** a normal child-OU exception cannot override this
enforced domain-level value. Do not implement the earlier simple Kuhnle-only
exception suggestion without redesigning its precedence. Do not disable
enforcement or exclude Kuhnle from the whole Default Domain Policy merely to
change one setting; that would affect unrelated protections. A separately
approved correction must explicitly address the enforced source or use a
carefully scoped, validated higher-priority design.

Source: [Microsoft Group Policy processing](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-processing).

### 2. Edge OU And Domain Exception List Disagree

Current server classification:

| OU | Enabled Computer Accounts |
| --- | --- |
| _Edge-Servers with NTLM | EXCHANGE3, KUHNLE, FILE |
| _Core-Servers without NTLM | EASYJOB3, LMR, TIM |

Default Domain Policy sets domain NTLM authentication to **Deny for domain
servers** (`RestrictNTLMInDomain=5`), not the separate Deny all option.
Its server exception list contains:

- exchange
- exchange3
- exchange.format.lu
- exchange3.format.lu
- autodiscover.format.lu
- admin.format.lu

KUHNLE and FILE are absent despite their edge-OU placement. Allowing incoming
NTLM on a member server does not by itself exempt domain-account pass-through
authentication from the DC's domain restriction. Conversely, ADMIN is allowed
by name but belongs to the noncritical-workstation OU, not the edge-server OU.
The business need for each destination/alias must be confirmed before adding
or removing entries.

The XML definition contains a trailing space after exchange3.format.lu; PDC's
effective registry list does not. Normalize the definition during an approved
change, but do not claim the whitespace caused a live failure.

Source: [Microsoft domain NTLM server exceptions](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/network-security-restrict-ntlm-add-server-exceptions-in-this-domain).

### 3. NTLM Allow Extends Beyond Edge Servers

NTLM Allow sets incoming NTLM to Allow all, with NTLMv2-only LAN Manager
compatibility and incoming auditing. It is linked to:

- _Edge-Servers with NTLM: enabled, enforced.
- _NonCritical Workstations with NTLM: enabled, not enforced; three computer
  accounts, including ADMIN.

NTLM Block is linked only to Domain Controllers and _Core-Servers without NTLM,
both enforced. Thus the current allow/block layout does not represent an
edge-server-only boundary. The default Computers container also contains four
enabled computer accounts; no effective-policy audit was performed on those
devices, so their full authentication posture is not certified here.

### 4. Legacy Authentication Setting Hidden In Drive Mapping

Drive mapping has an enabled Computer setting `LmCompatibilityLevel=0`
(Send LM and NTLM responses). This contradicts the value 5 in Default Domain
Policy. Both links are enforced, but Default Domain Policy has higher domain
link priority. All four inspected servers currently show value 5, so there is
no observed active downgrade on those servers. The conflicting value remains
a latent regression risk if links/filtering/priority change.

The unlinked Enforce NTLNv2 GPO also contains conflicting definitions: security
policy value 5 and a registry preference writing value 3. It currently has no
reported links; do not link it without reconciling that conflict.

Value 5 rejects LM/NTLMv1 but still permits NTLMv2; it is not a Kerberos-only
setting. Source: [Microsoft LAN Manager authentication level](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/network-security-lan-manager-authentication-level).

### 5. No Outgoing Destination Restriction Found

The 17 inspected GPO reports contain no outgoing NTLM restriction or outgoing
server-exception list. `RestrictSendingNTLMTraffic` and `ClientAllowedNTLMServers`
are absent on all four sampled servers. Incoming and domain pass-through
restrictions do not establish an outgoing NTLM allowlist for external or
workgroup destinations. Endpoint-specific controls outside the inspected GPO
and registry scope were not audited.

A Kerberos-first design with NTLM only to named edge destinations needs an
audited client-outgoing policy as well as destination and domain exceptions.
Do not switch outgoing traffic straight to Deny all without first reviewing
actual dependencies and preserving administration/backup/application access.

Source: [Microsoft outgoing NTLM server exceptions](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/network-security-restrict-ntlm-add-remote-server-exceptions-for-ntlm-authentication).

## Verified Effective State

| Setting | PDC | BDC | KUHNLE | LMR |
| --- | --- | --- | --- | --- |
| RPC endpoint discovery authentication | 1 | 1 | 1 | 1 |
| Incoming NTLM | Deny all | Deny all | Allow all | Deny all |
| Outgoing NTLM restriction/list | Absent | Absent | Absent | Absent |
| LAN Manager compatibility | 5 | 5 | 5 | 5 |
| Kerberos encryption policy | 2147483640 | 2147483640 | 2147483640 | 2147483640 |

The Kerberos policy enables AES128/AES256 and future types, with DES/RC4
unchecked in the policy report. This is aligned with the stated intent, but
does not prove that every service/application successfully uses Kerberos or
that every service account has the necessary AES keys and SPNs.

PDC's sampled last-24-hour NTLM log contains 2,060 event 4002 records (incoming
NTLM blocked) and 10 event 4004 records (domain-controller NTLM blocked).
These are event counts, not counts of users, incidents, or failed applications.
Detailed workload attribution remains to be done before changing allowlists.

## Proposed Correction Order

No changes below have been performed or approved by this read-only request.

1. Back up affected GPOs outside the repository, capture relevant filters/links,
   and document a rollback and staged maintenance window. Correct only the RPC
   endpoint-mapper authentication setting while retaining NTLM denial and all
   other protections. Its reboot requirement and enforced-domain scope need
   explicit approval; never restart both DCs together.
2. Remove only the stray LAN Manager setting from Drive mapping, preserving all
   drive mappings. Leave the unlinked conflicting GPO unlinked pending cleanup.
3. Confirm whether EXCHANGE3, KUHNLE, and FILE are the intended edge destinations,
   and whether ADMIN/noncritical workstations are deliberate exceptions to the
   stated rule. Reconcile member incoming policy, domain exceptions, and actual
   short/FQDN/service aliases without blindly adding hosts or removing legacy aliases.
4. Audit outgoing NTLM by source and destination, then propose a named-edge
   destination allowlist and staged blocking. Validate SPNs, hostname-based
   access, service-account AES readiness, and application compatibility first.
5. Verify AD/SYSVOL convergence, resultant policy, and effective values; test
   local break-glass SSH, domain SSH, lookup/trust, applications, and backup
   access across controlled member reboots before any DC rollout.

## Latest NTLM Event Inspection

Read-only follow-up on PDC, BDC, KUHNLE, and LMR, approximately 13:52-13:56
local time on September 13. The other domain machines were not inspected
directly. No logging setting was changed. Logon and Credential Validation
success/failure auditing were already enabled on all four machines.

### Successful Credential Validation

Security event 4776 with status 0x0 confirms successful NTLM-family credential
validation. A DC can record this for access to another server; the event does
not contain the destination server/service or source IP. Source WORKSTATION
is the recorded name, not a verified mapping to a particular device. Names of
personal accounts were reported interactively and are deliberately omitted here.

| Log Host | Latest Sampled Activity | Interpretation |
| --- | --- | --- |
| PDC | Exchange HealthMailbox monitoring account from EXCHANGE3 at 13:53:08; latest non-monitoring account from WORKSTATION at 13:29:45. | Both credential validations succeeded; destination service is not established. |
| BDC | Exchange HealthMailbox monitoring account from EXCHANGE3 at 13:48:58; latest non-monitoring account from WORKSTATION at 13:43:29. | Both credential validations succeeded; destination service is not established. |
| KUHNLE | Local administrator validation with source KUHNLE at 13:53:24. | Correlates with this audit's public-key SSH session, not proof of NTLM authentication over the SSH connection. |
| LMR | Local administrator validation with source LMR at 13:53:26. | Correlates with this audit's public-key SSH session, not proof of an application dependency on network NTLM. |

The SSH log independently records Accepted publickey from the trusted VPN
source at the matching member-server times. Local MSV1_0 validation events and
the SSH transport authentication method must not be conflated.

Source: [Microsoft event 4776](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4776).

### Blocked Attempts And Audit-Only Events

| Host | Snapshot Of Latest Event | What Can Be Attributed |
| --- | --- | --- |
| PDC | September 13 13:52:20, event 4002, blocked. | Local calling context PDC$, svchost PID 1268, hosting RpcEptMapper/RpcSs. The remote user/source is not identified by this record. |
| BDC | September 13 13:52:26, event 4002, blocked. | Local calling context BDC$, svchost PID 976, hosting RpcEptMapper/RpcSs. The remote user/source is not identified by this record. |
| KUHNLE | September 12 15:26:53, event 8002, audit-only. | Local calling context KUHNLE$, PID 4. It describes traffic that would be blocked under a deny policy, not a confirmed denial or successful application login. |
| LMR | September 13 10:30:39, event 4002, blocked. | Local calling context LMR$, PID 4. No remote user/source is present in the record. |

PDC also records event 4004 at 13:32:01: account PDC$, source workstation PDC,
secure-channel server FILE, blocked. This is consistent with the FILE exception
gap, but does not establish which application or network protocol initiated it.
No 4004 was returned from BDC's retained operational log.

### Coverage Limits

- Oldest available Security records: PDC September 11 08:04:31; BDC September
  11 00:44:32; KUHNLE September 13 10:39:21; LMR September 10 18:26:40.
- Oldest available NTLM Operational records: PDC September 13 13:05:24; BDC
  September 13 13:05:38; KUHNLE September 9 07:32:02; LMR August 20 13:50:53.
- Queries requested up to seven days, bounded by available retention. The
  latest-4776 account comparison inspected up to 5,000 events per DC, extending
  back to September 11 08:46:24 on PDC and 09:42:22 on BDC; KUHNLE returned 234
  events and LMR 93. This is not a complete historical account inventory.
- No event 4624/4625 with AuthenticationPackageName exactly NTLM was found in
  the retained query window. That is not proof of no NTLM activity: local
  member events use MICROSOFT_AUTHENTICATION_PACKAGE_V1_0, and the DCs have
  successful pass-through credential validations in event 4776.
- Older KUHNLE application/user attribution cannot be reconstructed from the
  currently retained Security log. Do not infer that only the machine account
  used NTLM from the Operational log's calling-process identity.
- Next investigation should correlate the named-account timestamps with the
  destination application's existing logs, starting with EXCHANGE3. Do not
  assume WORKSTATION means SMB or automatically relax NTLM restrictions.

## ADMIN Exception Removal

### Authorization And Pre-Change Scope

- On September 13, the user authorized removal of ADMIN from the domain NTLM
  exceptions. They report that Kyocera firmware now supports Kerberos and that
  the copier configuration was corrected on Friday, September 11. This is user
  confirmation, not an independently observed copier authentication test.
- Target only Default Domain Policy, GUID
  `31b2f340-016d-11d2-945f-00c04fb984f9`, Security Options value
  `DCAllowedNTLMServers`: remove the exact `admin.format.lu` member.
- At 14:03 CEST, PDC reports computer AD/SYSVOL version 387/387 and user
  version 17/17. Both the policy definition and effective registry still
  contain ADMIN. Preserve the other five entries exactly, including the
  existing trailing space in the exchange3 FQDN definition.
- Blast radius: domain controllers will stop exempting domain-account NTLM
  pass-through authentication to ADMIN. Any remaining ADMIN NTLM dependency,
  not just the copier, may fail. Existing Kerberos access is the intended path.
  This does not make ADMIN fully NTLM-free: its incoming-NTLM Allow GPO and OU
  membership are explicitly outside this change.
- Preserve domain deny mode, all other policy settings, links, filtering,
  security descriptors, OU placement, local break-glass access, and other
  server exceptions. No reboot, service restart, forced domain-wide policy
  refresh, audit-policy change, or broad GPO import is planned.
- PDC's domain replication check reports success and zero consecutive
  failures. A bounded scan of 2,060 retained NTLM Operational records, oldest
  September 13 13:05:45, found no exact ADMIN/admin.format.lu field match.
  This does not establish absence of an older dependency.
- Before editing, retain a full GPO backup and exact source template in a
  restricted PDC-local directory outside the repository. Use the existing
  Security Settings extension and the native Group Policy save API to update
  its computer revision; do not create a competing Registry.pol setting.
- Rollback: reinsert only the removed list member through the same security
  setting and save a new computer revision. Use the full backup only after
  checking for intervening edits. Verify AD/SYSVOL convergence and effective
  lists on both DCs. A real copier scan and normal ADMIN access remain the
  required application-level tests.
- Protected PDC-local backup prepared at
  `C:\ProgramData\FormatOps\GpoChanges\20260913-RemoveAdminNtlm\Backup`,
  backup ID `4851419c-06b4-4d8d-9e7a-146ee639cb40`. Directory inheritance is
  disabled; access is limited to SYSTEM and built-in Administrators. Exact
  template bytes, an eight-file integrity/ACL baseline, GPO metadata, and raw
  before/after reports remain guest-local, never in the repository.
- BDC independently matches computer 387/387 and user 17/17; its effective
  exception list also still includes ADMIN. Both ADMIN SSH aliases work before
  the edit. No copier transaction has been performed.
- At 14:09:14 CEST, removed only `admin.format.lu` from the existing security
  template and saved the computer Security Settings extension through
  `Microsoft.GroupPolicy.GroupPolicyObject.Save`. No Registry.pol value or
  full-GPO import was used. PDC computer AD/SYSVOL versions became 388/388;
  user versions stayed 17/17.
- Exact template comparison confirms the intended single-member removal.
  All other policy files are byte-for-byte unchanged; the security-template
  ACL, GPO security descriptor, extension registrations, status, WMI filter,
  domain links, and all other reported computer/user settings match baseline.
- At 14:09:47, BDC independently reports 388/388 and 17/17 and the five-entry
  policy definition without ADMIN, including unchanged exchange3 whitespace.
  AD/SYSVOL replication has converged. BDC reports no replication failures;
  NTDS, DNS, DFSR, Netlogon, and SSH are running; both domain shares exist.
- PDC likewise reports no replication failures, running core DC/SSH services,
  and both domain shares present. The effective lists initially retained ADMIN
  while awaiting background application. Without a forced refresh, BDC's
  effective list excludes ADMIN at 14:12:28 and PDC's at 14:13:12.
- Repeat full PDC comparison at 14:13:23 passes all file, template, metadata,
  permission, and reported-setting preservation checks. Computer versions
  remain 388/388 and user versions 17/17. Both controllers now effectively list
  only exchange, exchange3, exchange.format.lu, exchange3.format.lu, and
  autodiscover.format.lu.
- The bounded post-change BDC NTLM Operational check and final PDC check at
  14:13:53 find no exact ADMIN match. Both ADMIN SSH aliases were retested
  successfully after effective application on both DCs; this is not a copier
  scan, SMB, or RDP transaction test.
- Status: narrow policy removal, AD/SYSVOL convergence, and effective
  application on both DCs verified. Copier scan and usual ADMIN/RDP login
  remain user acceptance tests. No reboot or forced policy refresh was used.
- Retained the exact one-off change/verification script alongside the protected
  guest-local backup as `change.ps1`; the temporary user-profile copy was moved
  there. No scheduled task, persistent worker, or monitoring automation was
  created. Repository notes contain only sanitized results, not raw evidence.

Method references: [Microsoft Group Policy save API](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/wmi_v2/class-library/grouppolicyobject-save-method-boolean-boolean-guid-guid-microsoft-grouppolicy)
and [Microsoft Security Settings extension identifiers](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-gpsb/55bb803e-b35f-4ce8-b558-4c1e92ad77a4).
