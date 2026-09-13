# ESX-C On-Prem Runbooks

Runbooks for the on-prem VMware host `ESX-C`.

Last updated: 2026-09-13

## Current VM Inventory

Known Windows VMs currently assigned to ESX-C:

| VM | Folder | Expected access alias | Notes |
| --- | --- | --- | --- |
| `BDC` | [bdc](bdc/README.md) | `win-bdc`, `winad-bdc` | Verified backup domain controller and DNS server for `format.lu`; domain-critical. |
| `Kuhnle` | [kuhnle](kuhnle/README.md) | `win-kuhnle`, `winad-kuhnle` | Production `format.lu` member server running `SQLBase_SERVER1`; both access paths recovered after the temporary policy test. |
| `LMR` | [lmr](lmr/README.md) | `win-lmr`, `winad-lmr` | Production `format.lu` member server hosting `IMOSSQL2019` and `MySQL_CSF2_Master`. |

## Latest Maintenance Status

September 13, 2026 maintenance is partially completed. Kuhnle's domain access
recovered after an approved temporary policy test and additional reboot; a
durable correction is not established. LMR's reboot and BDC patching remain
outstanding. All times below are local. See per-VM logs for evidence and scope.

| VM | Updates | Restart And Health |
| --- | --- | --- |
| Kuhnle | KB890830, KB5126149, KB5122882 installed successfully; fresh scan offers zero updates. | Booted 13:19:12; both SSH aliases, account lookup, trust, and SQLBase pass. Reboot/rename markers clear. Temporary-policy result is not a durable fix. |
| LMR | Above three updates plus SQL KB5122773 installed successfully at 12:41:30. | Reboot required and deferred. SQL/MySQL, both SSH aliases, and domain trust pass. Not yet verified after reboot. |
| BDC | Three offered updates remain uninstalled. | No reboot performed. Focused DC tests, SYSVOL/NETLOGON, time sync, and last inbound replication attempts pass. |

Next: review the [domain authentication policy audit](../kerberos-ntlm-gpo-audit-2026-09-13.md).
Direct PDC/BDC inspection found that Default Domain Policy is enforced, so a
normal child-OU exception cannot override its RPC setting. The approved Kuhnle
test set EnableAuthEpResolution=0 before reboot, but the configured value was
back to 1 after startup. Any durable correction needs a separately approved
scope and precedence design; do not weaken NTLM blocking.
Review the same inherited setting on LMR before resuming its reboot; patch and
restart BDC last with PDC available. This test did not create a GPO exception or
change AD, firewall, SSH, WinRM, or replication configuration. WinRM remains
Stopped/Disabled on all three guests; the target model below is not a statement
of current configuration.

The September 5 cleanup tasks were found stopped with a terminated result;
cleanup success and reclaimed space remain unverified. Their tasks and saved
profile flags were removed from all three guests on September 13. No new broad
Disk Cleanup was launched. The prior C:-only scope claim is corrected in each
log: `cleanmgr /sagerun` enumerates all drives and ignores `/d`.

Guest disks report Healthy. Current backup success, hypervisor job state, and
end-to-end application transactions were not independently verified.

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
