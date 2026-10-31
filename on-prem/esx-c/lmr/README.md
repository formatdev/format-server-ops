# LMR Runbook

Starter runbook for the `LMR` VM on ESX-C.

Last updated: 2026-10-31

## Known State

- VM name in vCenter: `LMR`
- Expected Windows hostname: `LMR`
- Expected IP from local SSH config: `192.168.1.8`
- Expected local break-glass SSH alias: `win-lmr`
- Expected domain-admin SSH alias: `winad-lmr`
- Expected SSH identity: `~/.ssh/windows-admin_ed25519`
- Role: production format.lu member server hosting IMOSSQL2019 and MySQL_CSF2_Master. Both database services were Running/Automatic on October 31.
- Verified live state: confirmed domain-joined Windows member server on 2026-04-18.
- Current maintenance: see [maintenance log](maintenance-log.md), October 31 entry.
- Window closure: operator reports LMR shut down on October 31 for HPE host firmware work, now in progress. Power state and firmware outcome were not independently verified; the following results precede shutdown. After startup, prioritize the unresolved domain-channel result, then SQL/MySQL, archived backup availability, disks and restart markers.
- Initial October 31 inspection at 14:36-14:41: boot October 17 02:23:52, build 20348.5761. Fresh scan succeeded with zero offered updates; CBS/WU flags clear. Eight non-empty rename strings remain (Edge and temporary files). SQL/MySQL, both SSH aliases, trust, account lookup, disks and PDC time sync passed at that point. Initially present TiWorker/TrustedInstaller were idle in a five-second sample and absent by 14:41; no FormatOps tasks were present. Later domain-check results below supersede the initial trust status.
- October 31 authorized storage work completed: nine SQL .bak files dated before October 1 (16.7378 GiB logical) were copied to D:\FormatOps\Archives\SQLBackups\2026-10-31, hash-verified, then removed from their exact C: locations. Protected manifest.json retains original paths and hashes on LMR only. The October 21 2.639 GiB IMOS backup remains on C:. No live database or order files were moved. C: now has about 32.7 GiB free (27.4%), up from 13.32 GiB; D: has about 877.64 GiB free.
- Windows StartComponentCleanup completed at 15:18:04 with exit 0, NoRestart and no ResetBase. Post-analysis reports actual component store 7.73 GB (previously 10.01 GB), zero reclaimable packages, cleanup recommended No. CBS/WU restart flags remain false; eight existing application rename strings remain. SQL/MySQL, SSH, Netlogon, time and ESET services are Running; all 11 VSS writers Stable/No error. No reboot was performed.
- Final domain checks at 15:18-15:19 differ from the initial successful check: generic and PDC/BDC-targeted secure-channel tests return False in both local and domain SSH contexts, and nltest channel query returns 1311. Both SSH aliases and domain SID lookup still work; DNS and TCP 88/135/389/445 to both controllers pass. No new Netlogon event returned since 15:01. This is an unresolved partial domain-authentication finding, not proof of a machine-password mismatch or a demonstrated cleanup side effect. No trust reset, policy edit or service restart was attempted.
- Initial disk scan measured IMOS at 65.10 GiB, including 37.20 GiB of order data and 14.38 GiB in Library\DB. After the approved backup archive, Library\DB measures 5.685 GiB. The remaining IMOS order/library assets and Factory\DELETED contents require application-specific retention/dependency review before any further move or deletion. Recycle Bin, shadow storage and page file were not changed.
- Other follow-up: three expired personal-store certificates still warn, while the active RDP certificate is valid through February 3, 2027. Two October 26 SQL SSPI handshake errors remain historical findings. WinRM remains Stopped/Disabled. No patch, certificate or policy change was performed this round; exact private backup filenames/profile paths were excluded from the repo.
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
