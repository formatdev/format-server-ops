# BDC Runbook

Starter runbook for the `BDC` VM on ESX-C.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `BDC`
- Expected Windows hostname: `BDC`
- Expected IP from local SSH config: `192.168.1.4`
- Expected local break-glass SSH alias: `win-bdc`
- Expected domain-admin SSH alias: `winad-bdc`
- Expected SSH identity: `~/.ssh/windows-admin_ed25519`
- Role: likely backup domain controller for `format.lu`; verify before any maintenance.
- Verified live state: confirmed backup domain controller for `format.lu` on 2026-04-18.
- Update state: 2026-04 updates installed and reboot completed on 2026-04-18; no pending updates after reboot.

## Safety Rules

- Treat as critical identity infrastructure until proven otherwise.
- Do not reboot, demote, change DNS, change DHCP, change time sync, seize or transfer FSMO roles, edit SYSVOL, edit GPOs, or change replication topology without explicit confirmation and documented blast radius.
- Preserve existing local `win-bdc` break-glass SSH if it works.
- Verify `winad-bdc` only because it is already expected/configured locally.
- Do not make AD, GPO, replication, DNS, DHCP, or time-service changes from this host until current domain state is documented.

## First Discovery Checks

From the Mac, use non-mutating checks:

```sh
ssh -o BatchMode=yes win-bdc hostname
ssh -o BatchMode=yes win-bdc whoami
ssh -o BatchMode=yes winad-bdc hostname
ssh -o BatchMode=yes winad-bdc whoami
nc -vz -G 5 192.168.1.4 22
nc -vz -G 5 192.168.1.4 5985
```

On the server, prefer read-only PowerShell and built-in domain-controller checks:

```powershell
hostname
whoami
Get-ComputerInfo | Select-Object CsName,CsDomain,CsDomainRole,WindowsProductName,OsVersion
Get-Service DNS,DHCPServer,NTDS,DFSR,W32Time,Netlogon,sshd,WinRM
dcdiag /q
repadmin /replsummary
repadmin /showrepl
netdom query fsmo
nltest /dsgetdc:format.lu
w32tm /query /status
dfsrdiag pollad
```

Use care with output: record concise findings only, not sensitive logs or secrets.

## AD/DNS/DHCP Notes To Verify

- Whether `BDC` is a domain controller for `format.lu`.
- Whether it is Global Catalog.
- Whether it hosts DNS zones for `format.lu`.
- Whether DHCP is installed or active.
- Whether SYSVOL and NETLOGON shares are present.
- Whether AD replication with `PDC` is healthy.
- Whether time source and offset are sane for a domain controller.

## Files

- [maintenance-log.md](maintenance-log.md): ongoing maintenance history
