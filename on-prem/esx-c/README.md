# ESX-C On-Prem Runbooks

Runbooks for the on-prem VMware host `ESX-C`.

Last updated: 2026-10-10

## Current VM Inventory

Known Windows VMs currently assigned to ESX-C:

| VM | Folder | Expected access alias | Notes |
| --- | --- | --- | --- |
| `BDC` | [bdc](bdc/README.md) | `win-bdc`, `winad-bdc` | Verified backup domain controller and DNS server for `format.lu`; domain-critical. |
| `Kuhnle` | [kuhnle](kuhnle/README.md) | `win-kuhnle`, `winad-kuhnle` | Production `format.lu` member running `SQLBase_SERVER1`; local access and trust pass, but domain SSH/account lookup fail after the October 10 restart. |
| `LMR` | [lmr](lmr/README.md) | `win-lmr`, `winad-lmr` | Production `format.lu` member server hosting `IMOSSQL2019` and `MySQL_CSF2_Master`. |

## Latest Maintenance Status

Post-start verification on October 10 around 08:16-08:19 CEST confirms all
three guests are reachable after the operator's shutdown for planned iLO work.
Each guest records a planned shutdown and EventLog stop/start; the bounded
one-day query returned no unexpected-shutdown event 41/6008. All run Windows
build 20348.5622. Fresh Windows Update scans succeeded with zero applicable
non-hidden software updates; CBS/WU restart flags are clear. No checked cleanup
or installer processes and no FormatOps tasks remained before the scans.
The iLO firmware version/update outcome and hypervisor job state were not
verified; ESX-C host SSH still returns connection refused.

| VM | Updates And Restart | Health And Follow-Up |
| --- | --- | --- |
| Kuhnle | Zero offered; CBS/WU clear. Boot October 10 07:18:02. | SQLBase, local SSH, trust and disks pass. Domain lookup/SSH fail again. Six Windows temporary-file rename strings remain. WatchGuard protection now registered as 8.00.26.0012; no HealthCheck crash since boot, next daily execution unverified. C: 23.52 GiB free. |
| LMR | Zero offered; CBS/WU and rename queue clear. Boot October 10 07:18:02. | SQL/MySQL, both SSH aliases, trust, lookup and disks pass. Three expired personal certificates still warn; active RDP certificate remains valid. C: 20.02 GiB free. |
| BDC | Zero offered; CBS/WU and rename queue clear. Boot October 10 07:17:55. | Focused DC tests, SYSVOL/NETLOGON and all five inbound replication contexts pass. Both SSH aliases work. C: 67.14 GiB free. Broad SSH rule remains enabled. |

`EnableAuthEpResolution=1` remains configured on all three. Kuhnle's domain
lookup and domain SSH regression recurred after this boot, while its secure
channel test and channel query pass. Computer RSoP still attributes the setting
to Default Domain Policy. This resembles the September partial-access failure
and keeps the RPC/NTLM policy conflict open; it is not a controlled cause test.
Retain the [September domain-policy audit](../kerberos-ntlm-gpo-audit-2026-09-13.md)
as the baseline for a scoped policy correction. No policy change was performed
during recovery verification. ADMIN's absence was last checked earlier today.

WinRM is still Stopped/Disabled on all three; the target model below is not
the current configuration. Kuhnle/LMR explicit SSH and WinRM rules retain the
two trusted sources. BDC still has an enabled SSH Allow-Any rule alongside
its scoped rule. Both BDC aliases authenticate as the domain administrator,
not as independently verified local break-glass identities. No access policy
was changed.

All sampled VSS writers are Stable/No error. Guest disks and role services
pass. Time synchronization currently uses PDC with leap indicator 0 on all
three, despite startup VMware time-provider warnings. Kuhnle's six remaining
rename strings identify psUniqueExecution.ini in Windows temporary locations;
leave the queue intact and do not infer a mandatory restart from it alone.
The separate [Veeam October 10 record](../esx-e/veeam/maintenance-log.md#2026-10-10---maintenance-inspection-after-vpn-recovery)
reports successful primary/copy/replication payloads with email warnings;
this task did not independently verify per-VM restore points or perform a
restore test. Hypervisor inventory/job state and end-to-end application
transactions were not independently checked. No raw logs or certificate
thumbprints are stored here.

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
