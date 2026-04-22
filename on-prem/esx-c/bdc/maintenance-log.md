# BDC Maintenance Log

## 2026-04-18 - Runbook Created

Scope:

- Created ESX-C starter runbook structure.
- Inspected repository documentation and local SSH alias configuration only.
- No connection to `BDC` was made during this entry.
- No VMware, Windows, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data changes were made.

Findings:

- Repo already had Windows remote-admin guidance in `docs/windows-ssh.md` and `docs/ssh-config.md`.
- Repo already had ESX-D and ESX-E on-prem runbook patterns under `on-prem/`.
- Local SSH config resolves `win-bdc` to `192.168.1.4` as local `Administrateur`.
- Local SSH config resolves `winad-bdc` to `192.168.1.4` as `format\Administrateur`.
- Both aliases use `~/.ssh/windows-admin_ed25519`.
- `BDC` should be treated as likely backup domain controller for `format.lu` until verified.

Next safe checks:

- Verify `win-bdc` with read-only `hostname` and `whoami`.
- Verify `winad-bdc` only after confirming the alias is expected for current domain-admin SSH access.
- Run read-only AD/DC health checks before any change.

## 2026-04-18 - Pre-Update Discovery

Scope:

- Performed read-only preflight before installing Windows updates.
- No reboot, snapshot, migration, power, firewall, SSH, WinRM, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, or data changes were made during discovery.

Findings:

- `win-bdc` and `winad-bdc` both authenticated key-only and returned hostname `BDC`.
- Both aliases landed as `format\administrateur`; `win-bdc` did not prove a separate local break-glass identity during this check.
- OS: Windows Server 2022 Standard, version `10.0.20348`.
- Domain: `format.lu`.
- Domain role: `BackupDomainController`.
- Services: `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were `Running`/`Automatic`.
- `WinRM` was `Stopped`/`Disabled`; no change was made.
- `winrm enumerate winrm/config/listener` failed because WinRM was not running.
- Remote-admin firewall address filters for the expected SSH/WinRM rules were scoped to `192.168.1.73` and `192.168.113.2`.
- `dcdiag /q` reported `KnowsOfRoleHolders`, `Replications`, and `RidManager` failures tied to authentication/bind failures against `PDC`.
- `repadmin /replsummary` showed 0 failures for `PDC` source and `BDC` destination, largest delta about 3 minutes, but also reported operational error `1326` retrieving information from `PDC.format.lu`.
- FSMO roles are all held by `PDC.format.lu`.
- DC locator for `format.lu` returned `BDC.format.lu` with GC, LDAP, KDC, time, writable, and DNS flags.
- Time source was `PDC.format.lu`; last successful sync was on 2026-04-18.
- Disk health reported healthy volumes; `C:` had about 73 GB free of about 96 GB.
- Pending Windows Update inventory showed 3 software updates:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Blast radius:

- `BDC` is confirmed domain-critical infrastructure.
- Installing OS updates may require a later reboot even though the update search reported `Reboot=False` before installation.
- Do not reboot without an explicit maintenance window because this host provides AD DS, DNS, Kerberos, time, and related domain-controller services.

## 2026-04-18 - Windows Updates Installed, Reboot Pending

Scope:

- Installed pending software updates using the Windows Update COM API from a temporary `NT AUTHORITY\SYSTEM` scheduled task.
- No reboot was performed.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall, SSH, WinRM, power, snapshot, migration, or data changes were made.
- Temporary scheduled task `FormatOps-WindowsUpdate-NoReboot` was deleted after completion.
- Temporary installer script `C:\ProgramData\FormatOps\Install-WindowsUpdates-NoReboot.ps1` was removed after completion.
- Installer log was left on the server at `C:\ProgramData\FormatOps\Logs\windows-update-20260418-bdc.log`.

Result:

- Updates ran as `NT AUTHORITY\SYSTEM`.
- Download result: `2` (succeeded).
- Install result: `2` (succeeded).
- `RebootRequired=True`.
- Installed successfully with per-update `hresult=0x00000000`:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Post-checks:

- `BDC` remained reachable over SSH after install.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update search still listed `KB5082142` as pending, consistent with the reboot-required state.
- Registry reboot check: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired` exists.
- `repadmin /replsummary` still showed 0 failures for `PDC` source and `BDC` destination, with operational error `1326` retrieving information from `PDC.format.lu`, matching the pre-update credential/bind caveat.

Next:

- Schedule an explicit reboot window for `BDC` before considering the cumulative update complete.
- After reboot, verify AD DS, DNS, DFSR/SYSVOL, time sync, Kerberos/domain logon, and replication.

## 2026-04-18 - Reboot Completed After Updates

Scope:

- Rebooted `BDC` with explicit approval after successful update installation.
- No VMware, AD, DNS, DHCP, time sync, replication, SYSVOL, GPO, firewall, SSH, WinRM, snapshot, migration, or data changes were made.

Result:

- Reboot completed successfully.
- Post-reboot boot time: 2026-04-18 22:36:20.
- `BDC` remained reachable over SSH as `format\administrateur`.
- Windows Update pending count after reboot: `0`.
- Registry reboot check after reboot: `False`.
- `DNS`, `DFSR`, `Netlogon`, `NTDS`, `sshd`, and `W32Time` were `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Time sync succeeded from `PDC.format.lu`; last successful sync was 2026-04-18 22:37:07.
- `repadmin /replsummary` showed 0 failures for `PDC` source and `BDC` destination, largest delta about 59 seconds.
- `repadmin /replsummary` still reported operational error `1326` retrieving information from `PDC.format.lu`, matching the pre-existing credential/bind caveat.

Next:

- Re-check `dcdiag /q` from an approved context that can bind to `PDC`.
- Continue tracking the existing `1326` PDC retrieval caveat separately from the update/reboot work.
