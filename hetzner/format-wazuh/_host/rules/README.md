# Privileged AD Group Alerts

Rule `110310` on `format-wazuh` raises a level 12 alert when either Format
domain controller records a change to a watched security group. It matches
the target SID, so localized names and renames do not break monitoring.
Restricting the rule to `BDC.format.lu` and `PDC.format.lu` (or their short names)
also keeps member-server groups with shared built-in SIDs out of this category.

## Monitored Groups

| SID prefix | RIDs and groups |
| --- | --- |
| `S-1-5-21-3572445798-2314295735-3149754986` | 512 Domain Admins, 516 Domain Controllers, 518 Schema Admins, 519 Enterprise Admins, 520 Group Policy Creator Owners, 521 Read-only Domain Controllers, 526 Key Admins, 527 Enterprise Key Admins, 1101 DnsAdmins |
| Same domain SID | 1117 Organization Management, 1128 Exchange Servers, 1129 Exchange Trusted Subsystem, 1130 Exchange Windows Permissions |
| `S-1-5-32` | 544 Administrators, 548 Account Operators, 549 Server Operators, 550 Print Operators, 551 Backup Operators |

Matches Windows Security events 4727-4735, 4737, 4754-4758, and 4764 for those
SIDs: member added or removed, group created, changed, deleted, or type changed.
This is a fixed watchlist, not a directory permission inventory. Review it
after adding delegated admin groups, replacing a group (new SID), changing
nesting, or adding a domain controller. It does not monitor arbitrary AD
ACL changes or membership changes in unlisted nested groups.

## Searching And Triage

In Wazuh Dashboard, search `wazuh-alerts-*`:

- Privileged changes: `rule.id: "110310"` (or
  `rule.groups: "format_ad_privileged_group"`). Check
  `data.win.eventdata.subjectUserName` (actor), `targetUserName` and
  `targetSid` (group), and `memberName`/`memberSid` when present.
- All security-group changes on the controllers, including routine events:

  ```text
  (agent.id: "012" or agent.id: "019") and
  data.win.system.eventID: ("4727" or "4728" or "4729" or "4730" or "4731" or
    "4732" or "4733" or "4734" or "4735" or "4737" or "4754" or "4755" or
    "4756" or "4757" or "4758" or "4764")
  ```

Routine events retain their native rules (e.g. level 5 rules `60141` and
`60142` for ordinary global-group adds/removes). The existing 90-day
indexed-alert retention and all agent settings are unchanged. Alerts are
searchable in Wazuh only; no email or chat delivery is configured.

## Verification

- November 15, 2026: verified the installed SID list against AD and checked
  both agents' Security channel filters. No GPO or agent changes were needed.
- In isolated native EventChannel tests, the baseline passed 5 cases and
  the new rule passed 43: all 18 SIDs, all 16 event IDs, four routine
  membership records, and five out-of-scope cases. No live privileged AD
  groups were changed and no synthetic alerts entered the production index.
- Validated and restarted only the manager at 10:39-10:40 CET. It loaded
  one additional rule. Manager, indexer, dashboard and Filebeat were active;
  BDC, PDC and Exchange3 agents all reported Active.
- After rollout, BDC routine test group `ZA-BDC-T-9456f4` produced Security
  records `34100031` (4728) and `34100033` (4729). Both were searchable in
  `wazuh-alerts-4.x-2026.11.15` at level 5 (`60141` and `60142`);
  both temporary groups were removed. PDC's earlier membership events
  remained searchable and new Security events continued to arrive. The
  optional repeat group-write test on PDC was denied and was not retried
  with elevated permissions.

## Deployment And Rollback

- Install [the tracked rule](format-ad-privileged-groups.xml) as
  `/var/ossec/etc/rules/format-ad-privileged-groups.xml`, mode `0640`,
  owner `root:wazuh`. Keep vendor rules and `local_rules.xml` unchanged.
- Validate with `/var/ossec/bin/wazuh-analysisd -t`, then restart just
  `wazuh-manager` and verify agent connectivity and fresh indexed events.
  Tests must exercise the native Windows EventChannel decoder: generic JSON
  input to the CLI log tester does not enter that ruleset in Wazuh 4.14.10.
  Use an isolated manager and synthetic cases, not live privileged group
  changes or synthetic production alerts.
- To roll back, move only this custom rule out of `/var/ossec/etc/rules/`
  into the root-only recovery directory
  `/root/wazuh-privileged-ad-20261115-JoVR0j`, validate and restart the
  manager again. The directory contains the pre-change rules archive.
  Do not roll back the DC audit policy or restore other rules for this change.

See the [DC audit policy and live event evidence](../../../../on-prem/esx-d/pdc/security-group-management-auditing.md)
and [Wazuh custom rule guidance](https://documentation.wazuh.com/current/user-manual/ruleset/rules/custom.html).
