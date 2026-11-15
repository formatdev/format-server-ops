# Domain Controller Security Group Auditing

Verified November 15, 2026 on BDC and PDC in `format.lu`.

## Policy And Scope

- GPO: `DC - Security Group Management Auditing`
  (`{CC548F74-8999-4785-A4AC-27AC888E2FEB}`).
- Only link: `OU=Domain Controllers,DC=format,DC=lu`, enabled and not
  enforced. At rollout that OU contained only BDC and PDC.
- Computer setting: **Audit Security Group Management = Success**. The policy
  also sets `HKLM\SYSTEM\CurrentControlSet\Control\Lsa\SCENoApplyLegacyAuditPolicy`
  to DWORD `1` on those controllers so that legacy category settings do not
  override the advanced subcategories.
- Both controllers already applied the enforced `GPO_Audit_Log_Users`
  (legacy Account Management, Logon Events, and Account Logon) and the
  Default Domain Policy (19 advanced audit settings). Neither defined this
  subcategory. Neither existing GPO nor the Default Domain Controllers Policy
  was edited.
- Staged the new GPO unlinked. Verified its audit file, registry value and
  version 2 in Active Directory and SYSVOL on both controllers before
  linking. Refreshed computer policy on PDC first, then BDC. `gpresult`
  confirmed application; comparing all 60 effective `auditpol` subcategories
  showed only Security Group Management changing, from No Auditing to Success,
  on each host. No reboot.

## Test Evidence

On each controller, created two empty temporary global security groups with
no users or access assignments. Nested one in the other and then removed it
using that controller as the explicit AD write target. Deleted all four
temporary groups and verified none remained visible on either replica.

| Controller | Windows event | Security record ID | Wazuh rule |
| --- | --- | ---: | ---: |
| BDC | 4728, member added | 34095105 | 60141 |
| BDC | 4729, member removed | 34095107 | 60142 |
| PDC | 4728, member added | 44444315 | 60141 |
| PDC | 4729, member removed | 44444317 | 60142 |

At approximately 10:15 CET, Wazuh indexed all four records under
`wazuh-alerts-4.x-2026.11.15`. Matched the originating agent, Windows event
ID, Security record ID, and temporary target group; all three search shards
responded without error. Wazuh agents `012 BDC`, `019 PDC`, and
`020 Exchange3` remained Active. The GPO rollout did not change Wazuh
settings or Exchange3 policy.

## Wazuh Alerting

Keep Wazuh on BDC, PDC, and Exchange3. The manager's separate
[privileged-group rule](../../../hetzner/format-wazuh/_host/rules/README.md)
flags watched groups at level 12 without changing routine event searches
or the GPO. AD group alerts originate on BDC or PDC, including changes to
AD groups used by Exchange.

## Recovery

Restricted on-host evidence: `C:\ProgramData\Codex\GPO-Backups\DC-GroupAudit-20261115`.
PDC holds the existing GPO backups, original link state, and report for the
new GPO. Each controller holds its local before/after audit records and test
evidence. These are configuration recovery copies, not full server backups.

If rollback is approved, remove only the new GPO's link from the Domain
Controllers OU and allow AD replication. Refresh computer policy on both
controllers. Confirm `gpresult` no longer applies the new GPO. The LSA
registry value was absent beforehand; check for a residual value before
removing it, and only remove it if no other policy now owns it. Compare
`auditpol` with the saved baseline; if the new subcategory still reports
Success, restore just that subcategory to No Auditing and recheck. Do not
overwrite unrelated changes with a full policy restore.

References: [Microsoft audit policy guidance](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/monitoring-active-directory-for-signs-of-compromise)
and [Security Group Management event IDs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/audit-security-group-management).
