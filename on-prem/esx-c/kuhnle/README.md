# Kuhnle Runbook

Starter runbook for the `Kuhnle` VM on ESX-C.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `Kuhnle`
- Expected Windows hostname: `Kuhnle`
- Expected IP from local SSH config: `192.168.1.14`
- Expected local break-glass SSH alias: `win-kuhnle`
- Expected domain-admin SSH alias: `winad-kuhnle`
- Expected SSH identity: `~/.ssh/windows-admin_ed25519`
- Role: unknown Windows production VM; verify before maintenance.
- Verified live state: confirmed domain-joined Windows member server on 2026-04-18.
- Update state: 2026-04 updates remain pending after reboot; remote elevated install attempts were blocked by access-denied errors on 2026-04-18.

## Safety Rules

- Treat as a Windows production VM until proven otherwise.
- Use discovery-first checks before any change.
- Do not reboot, snapshot, migrate, power off, update Windows, change GPOs, delete data, alter firewall policy, or change SSH/WinRM configuration until current state and blast radius are documented.
- Preserve local `win-kuhnle` break-glass SSH if it works.
- If domain-joined, align with the established Windows remote-admin model only after current access is verified.

## First Discovery Checks

From the Mac, use non-mutating checks:

```sh
ssh -o BatchMode=yes win-kuhnle hostname
ssh -o BatchMode=yes win-kuhnle whoami
ssh -o BatchMode=yes winad-kuhnle hostname
ssh -o BatchMode=yes winad-kuhnle whoami
nc -vz -G 5 192.168.1.14 22
nc -vz -G 5 192.168.1.14 5985
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

If `Kuhnle` is confirmed domain-joined and intended to follow the established model:

- local `win-kuhnle` alias remains available as break-glass
- domain `winad-kuhnle` alias uses `format\Administrateur`
- domain SSH access goes through the `SSH Admins` AD group
- `sshd` and `WinRM` are `Automatic` and `Running`
- SSH `22` and WinRM `5985` firewall access is scoped to:
  - `192.168.1.73`
  - `192.168.113.2`

## Files

- [maintenance-log.md](maintenance-log.md): ongoing maintenance history
