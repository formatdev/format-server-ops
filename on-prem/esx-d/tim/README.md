# TIM Runbook

Starter runbook for the `Tim` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `Tim`
- Expected Windows hostname: `TIM`
- Expected IP from local SSH config: `192.168.1.12`
- Expected SSH aliases: `win-tim`, `winad-tim`
- Role: verify during next maintenance

## First Checks

```sh
ssh win-tim hostname
ssh winad-tim hostname
```

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
Get-Service sshd,WinRM
Get-Volume
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

