# EXCHANGE3 Runbook

Starter runbook for the `Exchange3` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `Exchange3`
- Expected Windows hostname: `EXCHANGE3`
- Expected IP from local SSH config: `192.168.1.6`
- Expected SSH aliases: `win-exchange3`, `winad-exchange3`
- Role: Microsoft Exchange server, verify exact version and topology before maintenance

## Safety Rules

- Treat as production mail infrastructure.
- Do not reboot, patch, change certificates, or restart Exchange services without explicit confirmation.
- Check transport queues and Exchange service health before and after maintenance.

## First Checks

```sh
ssh win-exchange3 hostname
ssh winad-exchange3 hostname
```

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
Get-Service sshd,WinRM
Get-Service MSExchange*
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

