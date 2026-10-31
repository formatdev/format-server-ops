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

## 2026-10-10 - Connectivity Check

Maintainer: Codex with Peter

Checks:

- ESX-D management HTTPS at `192.168.5.203:443` is reachable; host SSH at port 22 remains refused and was not enabled.
- vCenter at `192.168.5.15` is reachable on HTTPS and SSH.
- Authenticated appliance, ESX hardware, datastore, backup, alarm, VM power-state, and available-update checks remain unavailable because no approved working vCenter credential path is configured.

Notes:

- No host, appliance, datastore, VM, vCLS, snapshot, migration, reboot, update, certificate, or power action was performed.

## 2026-10-31 - End-of-Month Connectivity Check

Maintainer: Codex with Peter

- ESX-D at 192.168.5.203 accepts HTTPS; its SSH port 22 is refused. vCenter at 192.168.5.15 accepts HTTPS and SSH. SSH was not enabled on the ESXi host.
- No approved authenticated vCenter/ESXi management session was established in this round. Appliance/host version, datastore capacity, alarms, backups, VM power states and available hypervisor/appliance patches remain unverified; network reachability alone is not a health result.
- No appliance/host update, reboot, snapshot, migration, datastore change or VM power operation was performed. vCLS was left untouched as a VMware system VM.

## 2026-10-31 - Authenticated Host Version and Easyjob3 Placement Check

Maintainer: Codex with Peter

- During the Easyjob3 VMware Time Provider follow-up, Peter signed in to the existing Chrome vCenter tab at `https://vcenter8.format.lu/`. The host name resolves to 192.168.5.15. No credentials were extracted or saved. Direct management-IP HTTPS probes from the Mac/Easyjob3 had timed out; authenticated browser UI access nevertheless worked.
- At approximately 20:07-20:08, historical ESX-D 192.168.5.203 is **Not responding**, with Cannot synchronize host, host connection/power alarm and HA-agent-disabled notice. Summary displays VMware ESXi 8.0.3 build 24674464 and ProLiant DL325 Gen10 Plus v2. Because the host is not responding, this is last-known vCenter inventory, not confirmation of its currently running build or power state. Whether it is intentionally offline remains unconfirmed.
- Easyjob3 Summary shows Powered On on **192.168.5.205**, Tools Running/Current, VM hardware version 21, 6 vCPU/16 GB and a 150-GB disk on MSA_PERFHDD. Host .205 is Connected, ProLiant DL345 Gen10 Plus, AMD EPYC 7313P, approximately two hours uptime, with ESXi 8.0.3 build 24674464. Broadcom's build table identifies Update 3e/P05. Observed placement, not a migration performed by Codex, supersedes the historical ESX-D workload association for future host-level changes.
- Inspected Easyjob3 VM Options without changing values: startup/resume host-time sync and periodic host-time sync both checked; VBS Enable visually unchecked. Cancelled the dialog without saving. These checkboxes are separate from the Windows VMware Time Provider feature removed through the guest MSI; the guest change and its backup/postchecks are recorded in the Easyjob3 maintenance log.
- No vSphere configuration save, host reconnect, power action, migration, snapshot, host/appliance update, key change, alarm dismissal or vCLS action occurred. Current patch availability, appliance health/backup and the cause of .203's disconnection remain unverified. Plan Secure Boot work against actual host placement and a separately approved outage/recovery plan.

## 2026-10-31 - ESX-D Return after Operator Firmware Maintenance

Maintainer: Codex with Peter

- Peter confirms the prior .203 outage and temporary .205 workload placement were intentional firmware maintenance; he reports firmware updates finished and requests reinspection. Authenticated vCenter now shows .203 Connected, HA Connected (Secondary), about 58 minutes uptime, nine inventory VMs, and unchanged ESXi 8.0.3 build 24674464 / ProLiant DL325 Gen10 Plus v2. No active Issues and Alarms block was displayed in the sampled Summary. This is management/HA recovery evidence, not a full hardware sensor, storage-path or firmware-version audit.
- Operator Exit maintenance mode task completed 21:45:51. Easyjob3 return migration completed 21:47:01; its Summary confirms current host .203, Powered On, Tools Running/Current and hardware version 21. The earlier .205 placement note is historical. These migrations were observed in administrator task records, not initiated by Codex.
- Inspected Easyjob3 settings without saving: guest CPU virtualization and virtual IOMMU unchecked; VMware VBS visually unchecked; EFI/Secure Boot enabled, no configured security device and Force EFI Setup unchecked. Cancelled the dialog. Guest independently reports Secure Boot NULL-PK/KEK servicing blockage and VBS configured/not running. Detailed evidence and staged remediation options are in the Easyjob3 log.
- Firmware work did not install an ESXi update. Vendor catalog lists ESXi U3j/P09 and newer U3k as candidate 8.0 branch levels with the automated no-vTPM Platform Key remediation path, subject to HPE/vCenter compatibility, entitlement and a separately approved host/workload maintenance plan. No compatibility/deployment claim is made solely from catalog availability. No host/appliance update, reconnect, snapshot, migration, boot-key change, VM setting save, power operation or vCLS action occurred during this inspection.

## 2026-10-31 - Assigned Licence Edition and Expiry

- Peter authorized a read-only licence check in the authenticated vCenter UI. Licence inventory and asset assignments both confirm ESX-D 192.168.5.203 uses **vSphere 8 Essentials Plus**, expiration **Never**. Hosts .201 and .205 use the same edition and expiry, one CPU each; aggregate inventory usage is 3 of 6 CPUs (up to 32 cores per CPU).
- `vcenter8.format.lu` uses **vCenter Server 8 Essentials**, expiration **Never**, 1 of 1 instance. Both licence inventory entries are Assigned; these are not merely unused keys found in inventory.
- No expired/evaluation licence was shown for these assets. Installed non-expiring metadata does not verify ownership, active support, support end date or rights to later patch releases. Customer Connect metadata was blank; no licence synchronization, portal entitlement request, key export or assignment change occurred. Inspection output redacted key-shaped strings before display; no keys/screenshots containing keys were saved to the repository.
- Sanitized platform records updated. Next step is checking purchase/support records and the customer's legitimate Broadcom critical-patch access, not replacing the installed keys or assuming a new subscription is required. No host, VM, power, update, security or licence configuration was changed; no commit/push requested.

## 2026-10-31 - Broadcom Critical-Patch Catalogue Check

- Peter signed in to Broadcom and authorized read-only patch-access inspection.
  Dashboard reports 0 active contracts for this account. Free Downloads lists
  vSphere and vCenter, but product pages expose no releases. The official
  VMSA FAQ's direct vSphere Solutions link displays critical-patch terms and
  No data found, with no package/download controls. This is an unresolved empty
  catalogue, not a confirmed entitlement denial or proof of ineligibility.
- No exact downloadable ESXi/vCenter package verified. Vendor advisory names
  U3k fixes, but public release availability must not be presented as account
  access. Current appliance build, backup and compatibility remain separate
  preflight checks. Detailed sanitized findings and references are recorded in
  on-prem/vmware-platform/maintenance-log.md.
- No downloads, terms acceptance, profile submission, token creation, licence
  or account changes, host/appliance updates or power operations performed.
  Follow up with Broadcom portal/customer care about KB 314603 and the empty
  critical-patch Solutions catalogue before selecting deployment media.

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
