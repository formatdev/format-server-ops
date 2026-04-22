# EASYJOB3 Runbook

Starter runbook for the `Easyjob3` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `Easyjob3`
- Expected Windows hostname: `EASYJOB3`
- Expected SSH aliases: `win-easyjob3`, `winad-easyjob3`
- Earlier repo notes: [easyjob3-inventory.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/easyjob3-inventory.md) and [easyjob3-health-check-2026-04-05.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/easyjob3-health-check-2026-04-05.md)

## First Checks

```sh
ssh win-easyjob3 hostname
ssh winad-easyjob3 hostname
```

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
Get-Service sshd,WinRM,Spooler
Get-Volume
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

