# Admin Runbook

Starter runbook for the `Admin` VM on ESX-D.

Last updated: 2026-10-10

## Known State

- VM name in vCenter: `Admin`
- Expected Windows hostname: `ADMIN`
- Expected FQDN: `admin.format.lu`
- Expected SSH aliases: `win-admin`, `winad-admin`
- Role: administrative/jump server, verify during next maintenance

## Copier Scanning

- Copier FTP was retired on 2026-10-10 at Peter's request following Kyocera firmware SMB improvements.
- The IIS FTP site `Formascan_input`, its TCP 21 and passive-range firewall rules, and the remaining IIS FTP feature were removed/disabled. Do not restore FTP for scanning.
- SMB shares `Formascan_input` and `OUTPUT_BO` remain online. `C:\_BardecodeFiler\input` and all scan/application data were preserved.
- A real copier-to-SMB scan acceptance test remains operator-side verification; firmware support does not by itself confirm the copier destination and credentials.

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

