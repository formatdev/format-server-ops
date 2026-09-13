# Kuhnle Runbook

Starter runbook for the `Kuhnle` VM on ESX-C.

Last updated: 2026-09-13

## Known State

- VM name in vCenter: `Kuhnle`
- Expected Windows hostname: `Kuhnle`
- Expected IP from local SSH config: `192.168.1.14`
- Expected local break-glass SSH alias: `win-kuhnle`
- Expected domain-admin SSH alias: `winad-kuhnle`
- Expected SSH identity: `~/.ssh/windows-admin_ed25519`
- Role: production Windows member server for format.lu; SQLBase_SERVER1 is Running/Automatic.
- Verified live state: confirmed domain-joined Windows member server on 2026-04-18.
- Current maintenance: see [maintenance log](maintenance-log.md), September 13 entries.
- Domain access: both SSH aliases, secure-channel validation, and account lookup recovered after the approved temporary RPC-policy test and 13:19:12 reboot on September 13. SQLBase is running, no updates are offered, and reboot/rename markers are clear. Recovery across another reboot is not yet established.
- Investigation: a likely RPC endpoint-mapper/NTLM policy conflict is documented in the September 13 log. The test set EnableAuthEpResolution=0 before reboot, but its configured value was already back to 1 after startup. No durable exception or shared-policy edit was made; NTLM blocking remains unchanged. A lasting Kuhnle-only correction needs separate approval.
- Subsequent [PDC/BDC policy audit](../../kerberos-ntlm-gpo-audit-2026-09-13.md) found Default Domain Policy enforced, an edge/domain-exception mismatch, and other conflicting settings. A normal child-OU exception cannot override the RPC setting; use the audit's correction plan instead of assuming a simple local exception will persist.
- September 5 cleanup ended with a terminated task result; reclaimed space is unverified. The stopped task and profile were removed on September 13.

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
