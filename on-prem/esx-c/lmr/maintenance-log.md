# LMR Maintenance Log

## 2026-04-18 - Runbook Created

Scope:

- Created ESX-C starter runbook structure.
- Inspected repository documentation and local SSH alias configuration only.
- No connection to `LMR` was made during this entry.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data changes were made.

Findings:

- Repo already had Windows remote-admin guidance in `docs/windows-ssh.md` and `docs/ssh-config.md`.
- Repo already had ESX-D and ESX-E on-prem runbook patterns under `on-prem/`.
- Local SSH config resolves `win-lmr` to `192.168.1.8` as local `Administrateur`.
- Local SSH config resolves `winad-lmr` to `192.168.1.8` as `format\Administrateur`.
- Both aliases use `~/.ssh/windows-admin_ed25519`.
- Role, domain membership, service state, firewall scope, update state, event logs, and disk state are not yet verified.

Next safe checks:

- Verify `win-lmr` with read-only `hostname` and `whoami`.
- Verify `winad-lmr` only after confirming current local access and domain membership expectations.
- Record role, hostname, domain membership, IP, SSH alias state, WinRM state, firewall scope, updates, services, event logs, and disk state before changes.

## 2026-04-18 - Pre-Update Discovery

Scope:

- Performed read-only preflight before installing Windows updates.
- No reboot, snapshot, migration, power, firewall, SSH, WinRM, GPO, or data changes were made during discovery.

Findings:

- `win-lmr` authenticated key-only and returned hostname `LMR`, identity `lmr\administrateur`.
- `winad-lmr` authenticated key-only and returned hostname `LMR`, identity `format\administrateur`.
- OS: Windows Server 2022 Standard, version `10.0.20348`.
- Domain: `format.lu`.
- Domain role: `MemberServer`.
- Domain secure channel was healthy; `nltest /sc_query:format.lu` succeeded against `\\PDC.format.lu`.
- Services: `sshd` was `Running`/`Automatic`; `WinRM` was `Stopped`/`Disabled`.
- `winrm enumerate winrm/config/listener` failed because WinRM was not running.
- Remote-admin firewall address filters for the expected SSH/WinRM rules were scoped to `192.168.1.73` and `192.168.113.2`.
- Disk health reported healthy volumes; `C:` had about 31 GB free of about 128 GB and `D:` had about 963 GB free of about 1.1 TB.
- Recent hotfixes showed March 2026 security updates installed.
- Last 7 days event count: `System=0`, `Application=63` warnings/errors.
- Pending Windows Update inventory showed 4 software updates:
  - Security Update for SQL Server 2019 RTM GDR (`KB5084817`)
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Blast radius:

- `LMR` is confirmed as a domain-joined Windows member server, but application role is still not verified.
- The pending SQL Server 2019 security update implies SQL Server is installed or update-applicable on this host; treat as potentially application-critical.
- Installing OS and SQL updates may require a later reboot or service restart even though the update search reported `Reboot=False` before installation.
- Do not reboot without an explicit maintenance window because production role and user impact are not yet documented.

## 2026-04-18 - Windows Updates Installed, Reboot Pending

Scope:

- Installed pending software updates using the Windows Update COM API from a temporary `NT AUTHORITY\SYSTEM` scheduled task.
- No reboot was performed.
- No VMware, GPO, firewall, SSH, WinRM, power, snapshot, migration, or data changes were made.
- Temporary scheduled task `FormatOps-WindowsUpdate-NoReboot` was deleted after completion.
- Temporary installer script `C:\ProgramData\FormatOps\Install-WindowsUpdates-NoReboot.ps1` was removed after completion.
- Installer log was left on the server at `C:\ProgramData\FormatOps\Logs\windows-update-20260418-lmr.log`.

Result:

- Updates ran as `NT AUTHORITY\SYSTEM`.
- Download result: `2` (succeeded).
- Install result: `2` (succeeded).
- `RebootRequired=True`.
- Installed successfully with per-update `hresult=0x00000000`:
  - Security Update for SQL Server 2019 RTM GDR (`KB5084817`)
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Post-checks:

- `LMR` remained reachable over SSH after install.
- Domain secure channel remained healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update search still listed `KB5082142` as pending, consistent with the reboot-required state.
- Registry reboot check: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired` exists.

Next:

- Schedule an explicit reboot window for `LMR` before considering the cumulative update complete.
- After reboot, verify application role, SQL Server state if applicable, domain secure channel, event logs, disk state, and Windows Update pending count.

## 2026-04-18 - Reboot Completed After Updates

Scope:

- Rebooted `LMR` with explicit approval after successful update installation.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, or data changes were made.

Result:

- Reboot completed successfully.
- Post-reboot boot time: 2026-04-18 22:31:04.
- `LMR` remained reachable over SSH as `lmr\administrateur`.
- Windows Update pending count after reboot: `0`.
- Registry reboot check after reboot: `False`.
- Domain secure channel remained healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.

Next:

- Verify application role and SQL Server state if applicable.
- Review post-reboot event logs during the next application-specific health check.
