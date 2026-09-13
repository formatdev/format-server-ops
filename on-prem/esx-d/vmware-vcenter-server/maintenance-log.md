# VMware vCenter Server Maintenance Log

## 2026-04-18 - Access Discovery Attempt

Maintainer: Codex with Peter

Checks:

- UI/API access checked: not completed; no vCenter DNS name or credential path was available in the local runbook.
- DNS guesses checked: `vcenter`, `vcenter.format.lu`, `vcsa`, and `vcsa.format.lu` did not resolve.
- ESX-D host HTTPS checked: `192.168.5.203:443` was reachable. This is the ESX-D host address from the runbook, not confirmed as the vCenter Server VM.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No vCenter appliance, host, datastore, VM, snapshot, migration, or patch action was performed.

Follow-up:

- Add the actual vCenter Server URL/IP and approved credential path to the runbook before appliance health/update checks.

## 2026-08-04 - Connectivity Check

Maintainer: Codex with Peter

Checks:

- ESX-D host HTTPS checked: `192.168.5.203:443` is reachable through the on-prem VPN.
- vCenter appliance URL/API credentials remain undocumented locally, so appliance health, backup, datastore, alarm, and update checks were not completed.

Notes:

- No host, vCenter appliance, datastore, VM, snapshot, migration, reboot, or patch action was performed.

## 2026-08-23 - Connectivity And Access Check

Maintainer: Codex with Peter

Checks:

- ESX-D management HTTPS at `192.168.5.203:443` is reachable through the on-prem VPN.
- ESX-D host SSH at `192.168.5.203:22` refused the connection; it was not enabled or changed.
- The documented vCenter appliance at `192.168.5.15` is reachable on SSH and HTTPS and advertises VMware vCenter Server `8.0.3.00500`.
- The configured local vCenter SSH identity file is missing, so authenticated appliance service checks could not be completed.
- Browser access was blocked by the appliance's untrusted HTTPS certificate; no browser safety interstitial was bypassed.

Notes:

- No host, appliance, datastore, VM, snapshot, migration, reboot, update, certificate, or power action was performed.
- Follow up with an approved vCenter login/certificate path to inspect ESX-D hardware health, alarms, datastore capacity, VM power state, backups, and available host/appliance updates.

## 2026-09-05 - Connectivity Check

Maintainer: Codex with Peter

Checks:

- ESX-D management HTTPS at `192.168.5.203:443` is reachable; host SSH at port 22 remains unavailable and was not enabled.
- vCenter at `192.168.5.15` is reachable on HTTPS and SSH and advertises VMware vCenter Server `8.0.3.00500`.
- Authenticated appliance, ESX hardware, datastore, backup, alarm, and available-update checks remain unverified.

Notes:

- No host, appliance, datastore, VM, vCLS, snapshot, migration, reboot, update, certificate, or power action was performed.

## 2026-09-13 - Connectivity Check

Maintainer: Codex with Peter

Checks:

- ESX-D management HTTPS at `192.168.5.203:443` was reachable; host SSH at port 22 remained unavailable and was not enabled.
- vCenter at `192.168.5.15` was reachable on HTTPS and SSH.
- Authenticated appliance, ESX hardware, datastore, backup, alarm, and available-update checks remained unavailable because no approved working vCenter credential path was present.

Notes:

- No host, appliance, datastore, VM, vCLS, snapshot, migration, reboot, update, certificate, or power action was performed.

## Maintenance Template

Date:

Maintainer:

Checks:

- UI/API access checked:
- Appliance health checked:
- Services checked:
- Backup status checked:
- ESX-D host connectivity checked:
- Datastore usage checked:
- Alarms/events reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
