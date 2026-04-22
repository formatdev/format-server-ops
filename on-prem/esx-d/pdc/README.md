# PDC Runbook

Starter runbook for the `PDC` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `PDC`
- Expected Windows hostname: `PDC`
- Expected IP from local SSH config: `192.168.1.5`
- Expected SSH aliases: `win-pdc`, `winad-pdc`
- Role: primary domain controller for `format.lu`

## Safety Rules

- Treat as critical identity infrastructure.
- Do not reboot, demote, change DNS, seize FSMO roles, or edit SYSVOL/GPOs without explicit confirmation.
- Check replication, DNS, SYSVOL, and time service before and after maintenance.

## First Checks

```sh
ssh win-pdc hostname
ssh winad-pdc hostname
```

```powershell
hostname
dcdiag
repadmin /replsummary
Get-Service DNS,NTDS,DFSR,W32Time,Netlogon
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

