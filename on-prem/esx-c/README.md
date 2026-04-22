# ESX-C On-Prem Runbooks

Runbooks for the on-prem VMware host `ESX-C`.

Last updated: 2026-04-18

## Current VM Inventory

Known Windows VMs currently assigned to ESX-C:

| VM | Folder | Expected access alias | Notes |
| --- | --- | --- | --- |
| `BDC` | [bdc](bdc/README.md) | `win-bdc`, `winad-bdc` | Likely backup domain controller for `format.lu`; treat as domain-critical until proven otherwise. |
| `Kuhnle` | [kuhnle](kuhnle/README.md) | `win-kuhnle`, `winad-kuhnle` | Windows production VM; role and domain state need verification. |
| `LMR` | [lmr](lmr/README.md) | `win-lmr`, `winad-lmr` | Windows production VM; role and domain state need verification. |

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
