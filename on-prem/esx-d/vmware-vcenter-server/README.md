# VMware vCenter Server Runbook

Starter runbook for the `VMware vCenter Server` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `VMware vCenter Server`
- Role: vCenter appliance managing ESX-D / on-prem VMware inventory
- Access: vCenter UI/API, verify URL and credentials in the password manager

## Safety Rules

- Treat as critical virtualization management infrastructure.
- Do not power off, snapshot, resize, or patch without explicit confirmation.
- Do not confuse this VM with the ESX-D host itself.
- Verify vCenter health and backup before updates.

## First Checks

From the vCenter UI:

- appliance health
- storage usage
- backups
- services
- ESX-D host connectivity
- VM inventory
- recent alarms/events

Record verified facts in [maintenance-log.md](maintenance-log.md).

