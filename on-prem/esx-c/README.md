# ESX-C On-Prem Runbooks

Runbooks for the on-prem VMware host `ESX-C`.

Last updated: 2026-10-31

## Current VM Inventory

Known Windows VMs currently assigned to ESX-C:

| VM | Folder | Expected access alias | Notes |
| --- | --- | --- | --- |
| `BDC` | [bdc](bdc/README.md) | `win-bdc`, `winad-bdc` | Verified backup domain controller and DNS server for `format.lu`; domain-critical. |
| `Kuhnle` | [kuhnle](kuhnle/README.md) | `win-kuhnle`, `winad-kuhnle` | Production `format.lu` member running `SQLBase_SERVER1`; both SSH aliases, domain lookup and trust pass on October 31. |
| `LMR` | [lmr](lmr/README.md) | `win-lmr`, `winad-lmr` | Production `format.lu` member server hosting `IMOSSQL2019` and `MySQL_CSF2_Master`. |

## Latest Maintenance Status

Window closed by the operator on October 31. The operator reports all servers
shut down and an HPE firmware update underway on the host; within this thread,
that report covers BDC, Kuhnle and LMR. Shutdown completion/power state,
firmware versions and update success were not independently verified. No
further guest/host action was sent. The findings below are the last online
observations, not current powered-on health. Post-start verification is pending,
with LMR's unresolved domain-channel result the first guest follow-up.

October 31 inspection around 14:36-14:41 CET found all three guests reachable,
with core role/security services running and healthy mounted data volumes.
All run Windows build 20348.5761; KB5126654, KB5126655 and KB5127687 report
installation on October 17. Successful fresh scans offered zero non-hidden
software updates. CBS/WU reboot flags are clear, so no installation or reboot
was needed. Initial inspection made no cleanup, policy, access, or security-agent
change; the separately authorized LMR archive/cleanup is recorded below.
LMR's initially present servicing processes showed no CPU activity in a
five-second sample and had exited by the final 14:41 check. No FormatOps tasks
were present. ESX-C host SSH remains refused; inventory, host jobs and iLO
firmware state were not verified.

| VM | Updates And Restart | Health And Follow-Up |
| --- | --- | --- |
| Kuhnle | Zero offered; CBS/WU clear. Boot October 19 17:36:57. | SQLBase, both aliases, lookup, trust and disks pass. Nineteen rename strings. Last returned HealthCheck crash October 21, followed by agent/plugin updates; execution success is not established by absent crashes. October 30 temporary-profile errors need review. C: 20.23 GiB free. |
| LMR | Zero offered; component cleanup exit 0, CBS/WU clear. Boot October 17 02:23:52 unchanged. | Nine old SQL backups archived/verified to D:. C: now about 32.7 GiB free (27.4%). SQL/MySQL, both aliases and lookup pass, but final secure-channel checks fail/1311 despite initial success. Eight rename strings and certificate warnings remain. |
| BDC | Zero offered; CBS/WU clear. Boot October 26 11:14:06. | Focused DC tests, SYSVOL/NETLOGON and all five inbound replication contexts pass. Two Edge rename strings; both aliases work. C: 63.35 GiB free. Historical Netlogon/SSH events require context; broad SSH rule remains enabled. |

`EnableAuthEpResolution=1` remains configured on all three. Kuhnle's domain
lookup and SSH work again after a later boot, whose sequence this task did not
observe. This supersedes the October 10 access-failure status but does not
establish a durable correction of the earlier RPC/NTLM policy conflict.
Retain the [September domain-policy audit](../kerberos-ntlm-gpo-audit-2026-09-13.md)
as the baseline for a scoped policy correction. No new domain-policy audit
or change was performed. ADMIN's absence was last verified October 10.

WinRM is still Stopped/Disabled on all three; the target model below is not
the current configuration. Kuhnle/LMR explicit SSH and WinRM rules retain the
two trusted sources. BDC still has an enabled SSH Allow-Any rule alongside
its scoped rule. Both BDC aliases authenticate as the domain administrator,
not as independently verified local break-glass identities. No access policy
was changed.

All 11/10/11 sampled VSS writers on BDC/Kuhnle/LMR are Stable/No error. All
three use PDC time, leap indicator 0, stratum 5. Remaining rename strings
belong to updater/temporary-file queues; leave them intact. They are not counts
of rename pairs and do not by themselves mandate a restart.

Read-only Veeam log checks confirm successful per-VM primary, NAS4 copy and
replication tasks for all three. Overall payloads completed October 30 23:02:44,
October 31 00:30:08 and October 30 16:48:56 respectively, each 10 successful,
zero failed. SMTP relay rejection 5.7.54 remains; the primary session already
reported Warning before mail delivery, so do not attribute every warning solely
to email. Veeam's E: repository has 2323.87 GiB free (8.11%): capacity follow-up
belongs in the separate Veeam maintenance thread; no backup data was touched.
Native session/restore-point enumeration failed its SSL connection after using
the installed PowerShell 7 runtime. Evidence therefore comes from existing
logs, not a restore test or native restore-point validation. Guest application
transactions and VMware job state were not independently tested. Only sanitized
findings are stored here.

LMR disk follow-up identified IMOS as the main consumer (initially 65.10 GiB
logical), including 37.20 GiB of order data. User then approved archiving old
SQL backups and component cleanup. Nine backups dated before October 1,
16.7378 GiB logical, were copied/hash-verified to
D:\FormatOps\Archives\SQLBackups\2026-10-31 before exact source removal;
the October 21 IMOS backup remains on C:. DISM cleanup completed at 15:18:04,
exit 0, without ResetBase or restart. Post-analysis reports 7.73 GB actual
component store, zero reclaimable packages, cleanup recommended No. C: free
space rose from 13.32 to about 32.7 GiB; D: has 877.64 GiB free. Final role
services and VSS pass, but secure-channel tests now return False/1311 while
both SSH paths, domain lookup, DNS and controller TCP probes work. Cause and
relationship to servicing are unproven; no trust/policy repair was made.
See [LMR's disk investigation](lmr/maintenance-log.md#2026-10-31---read-only-c-drive-usage-investigation)
for scope, measured sizes and limitations.

## Safety Rules

- Treat all ESX-C VMs as production until proven otherwise.
- Use discovery-first operations and record current state before any change.
- Do not reboot, snapshot, migrate, power off, update Windows, change GPOs, delete data, alter firewall policy, or change SSH/WinRM configuration until current state and blast radius are documented.
- Keep secrets, passwords, private keys, unredacted hashes, backup credentials, customer data, and sensitive logs out of this repo.
- Preserve any existing local break-glass SSH path if it works.
- For domain-managed Windows servers, verify existing access before aligning with the domain-admin remote-admin model.
- For domain controllers, avoid AD, DNS, DHCP, time sync, replication, SYSVOL, and GPO changes unless the scope and rollback path are documented first.

## Common Windows Remote Admin Target

For Windows member servers that are confirmed domain-joined and intended to follow the established model:

- local break-glass SSH alias: `win-<name>`
- domain-admin SSH alias: `winad-<name>`
- identity: `~/.ssh/windows-admin_ed25519`
- domain user: `format\Administrateur`
- AD group: `SSH Admins` (`sAMAccountName: sshadmins`)
- `sshd` service: `Automatic`, `Running`
- `WinRM` service: `Automatic`, `Running`
- WinRM HTTP listener: `5985`
- scoped inbound firewall for SSH `22` and WinRM `5985`:
  - `192.168.1.73`
  - `192.168.113.2`

Do not apply this baseline blindly. First verify current role, hostname, domain membership, access path, service state, listener state, firewall scope, update state, event logs, and disk state.

## Discovery Order

1. Confirm VMware inventory and VM power state from vCenter without changing power, snapshot, migration, or hardware settings.
2. Confirm local SSH alias behavior with non-mutating commands only.
3. Confirm domain SSH alias behavior only if already configured and expected.
4. For BDC, verify domain controller role and health before treating it as a normal Windows server.
5. For Kuhnle and LMR, verify production role and domain membership before changing remote-admin state.

## Files

- [bdc](bdc/README.md): BDC VM runbook
- [kuhnle](kuhnle/README.md): Kuhnle VM runbook
- [lmr](lmr/README.md): LMR VM runbook
