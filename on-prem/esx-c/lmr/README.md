# LMR Runbook

Starter runbook for the `LMR` VM on ESX-C.

Last updated: 2026-09-13

## Known State

- VM name in vCenter: `LMR`
- Expected Windows hostname: `LMR`
- Expected IP from local SSH config: `192.168.1.8`
- Expected local break-glass SSH alias: `win-lmr`
- Expected domain-admin SSH alias: `winad-lmr`
- Expected SSH identity: `~/.ssh/windows-admin_ed25519`
- Role: production format.lu member server hosting IMOSSQL2019 and MySQL_CSF2_Master. Both database services were Running/Automatic on September 13.
- Verified live state: confirmed domain-joined Windows member server on 2026-04-18.
- Current maintenance: see [maintenance log](maintenance-log.md), September 13 entries.
- September 13 patch status: four updates installed successfully, including SQL KB5122773. Reboot remains required and is held pending review of the inherited policy implicated in Kuhnle's regression; Kuhnle access recovered after a temporary test, not a durable fix. SQL/MySQL and both SSH aliases remain available; post-reboot health is not yet verified.
- September 5 cleanup ended with a terminated task result; reclaimed space is unverified. The stopped task and profile were removed on September 13.

## Safety Rules

- Treat as a Windows production VM until proven otherwise.
- Use discovery-first checks before any change.
- Do not reboot, snapshot, migrate, power off, update Windows, change GPOs, delete data, alter firewall policy, or change SSH/WinRM configuration until current state and blast radius are documented.
- Preserve local `win-lmr` break-glass SSH if it works.
- If domain-joined, align with the established Windows remote-admin model only after current access is verified.

## First Discovery Checks

From the Mac, use non-mutating checks:

```sh
ssh -o BatchMode=yes win-lmr hostname
ssh -o BatchMode=yes win-lmr whoami
ssh -o BatchMode=yes winad-lmr hostname
ssh -o BatchMode=yes winad-lmr whoami
nc -vz -G 5 192.168.1.8 22
nc -vz -G 5 192.168.1.8 5985
```

On the server, use read-only PowerShell first:

```powershell
hostname
whoami
Get-ComputerInfo | Select-Object CsName,CsDomain,CsDomainRole,WindowsProductName,OsVersion
Test-ComputerSecureChannel -Verbose
nltest /sc_query:format.lu
Get-Service sshd,WinRM
winrm enumerate winrm/config/listener
Get-NetFirewallRule -DisplayName 'Allow remote Admin - SSH 22','Allow remote Admin - WinRM 5985' -ErrorAction SilentlyContinue |
  Get-NetFirewallAddressFilter
Get-Volume
Get-PSDrive -PSProvider FileSystem
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10
Get-EventLog -LogName System -EntryType Error,Warning -Newest 30
Get-EventLog -LogName Application -EntryType Error,Warning -Newest 30
```

## Remote Admin Target To Verify

If `LMR` is confirmed domain-joined and intended to follow the established model:

- local `win-lmr` alias remains available as break-glass
- domain `winad-lmr` alias uses `format\Administrateur`
- domain SSH access goes through the `SSH Admins` AD group
- `sshd` and `WinRM` are `Automatic` and `Running`
- SSH `22` and WinRM `5985` firewall access is scoped to:
  - `192.168.1.73`
  - `192.168.113.2`

## Files

- [maintenance-log.md](maintenance-log.md): ongoing maintenance history
