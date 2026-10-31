# Kuhnle Runbook

Starter runbook for the `Kuhnle` VM on ESX-C.

Last updated: 2026-10-31

## Known State

- VM name in vCenter: `Kuhnle`
- Expected Windows hostname: `Kuhnle`
- Expected IP from local SSH config: `192.168.1.14`
- Expected local break-glass SSH alias: `win-kuhnle`
- Expected domain-admin SSH alias: `winad-kuhnle`
- Expected SSH identity: `~/.ssh/windows-admin_ed25519`
- Role: production Windows member server for format.lu; SQLBase_SERVER1 is Running/Automatic.
- Verified live state: confirmed domain-joined Windows member server on 2026-04-18.
- Current maintenance: see [maintenance log](maintenance-log.md), October 31 entry.
- Window closure: operator reports Kuhnle shut down on October 31 for HPE host firmware work, now in progress. Power state and firmware outcome were not independently verified; the following health results precede shutdown. Post-start SQLBase, local/domain access, trust, disks and security-agent checks remain pending.
- Current access/update state: boot October 19 17:36:57, build 20348.5761. Both SSH aliases, domain lookup, secure-channel validation and SQLBase pass. Fresh scan succeeded with zero offered updates; CBS/WU restart flags clear. No checked cleanup/installer processes or FormatOps tasks were present. The intervening recovery/boot sequence was not observed by this task.
- Follow-up: 19 non-empty updater/temporary-file rename strings remain. C: has 20.23 GiB free and D: 33.07 GiB; volumes are Healthy. WinRM remains Stopped/Disabled. ESET and all four checked Panda services are Running/Automatic. October 30 profile errors include access-denied/file-in-use and temporary-profile fallback; no profile was modified or deleted.
- WatchGuard follow-up: bounded Application Error query returns 12 daily HealthCheck crashes on October 10-21, latest October 21 20:30:48, with the old 1.19.0.1 launcher and c0000005 fault. Agent now registers 1.25.14.0000 / package 2.31.00 installed October 22. Signed HealthCheck/launcher files are 1.25.15.0, modified October 23. No later crash was returned; successful scheduled execution and cloud protection health remain unverified, so do not declare the fault fixed solely from event absence.
- EDR Core remains registered as protection 8.00.26.0012 / package 13.01.15. Product/package/plugin version differences alone do not establish a mismatch. Applied ESET/EDR coexistence policies remain outside this inspection; see the October 10 investigation before proposing a security-software change.
- Investigation: a likely RPC endpoint-mapper/NTLM policy conflict is documented in the September 13 log. The test set EnableAuthEpResolution=0 before reboot, but its configured value was already back to 1 after startup. No durable exception or shared-policy edit was made; NTLM blocking remains unchanged. A lasting Kuhnle-only correction needs separate approval.
- October 10 recurrence: EnableAuthEpResolution remains 1 with Default Domain Policy as the RSoP source. Account lookup reports a trust-related error while Test-ComputerSecureChannel and nltest channel query pass. This partial failure does not justify a machine-password reset or domain rejoin; preserve working local access and use the existing policy audit for the next correction.
- October 31 access recheck supersedes that failed-access status: lookup and both aliases now pass with EnableAuthEpResolution still 1. No new RSoP audit or controlled policy test was performed; persistence across another restart remains unproven.
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
