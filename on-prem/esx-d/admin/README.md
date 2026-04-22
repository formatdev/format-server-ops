# Admin Runbook

Starter runbook for the `Admin` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `Admin`
- Expected Windows hostname: `ADMIN`
- Expected FQDN: `admin.format.lu`
- Expected SSH aliases: `win-admin`, `winad-admin`
- Role: administrative/jump server, verify during next maintenance

## First Checks

```sh
ssh win-admin hostname
ssh winad-admin hostname
```

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
Get-Service sshd,WinRM
winrm enumerate winrm/config/listener
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

