# Kuhnle Maintenance Log

## 2026-04-18 - Runbook Created

Scope:

- Created ESX-C starter runbook structure.
- Inspected repository documentation and local SSH alias configuration only.
- No connection to `Kuhnle` was made during this entry.
- No VMware, Windows, GPO, firewall, SSH, WinRM, update, reboot, snapshot, migration, power, or data changes were made.

Findings:

- Repo already had Windows remote-admin guidance in `docs/windows-ssh.md` and `docs/ssh-config.md`.
- Repo already had ESX-D and ESX-E on-prem runbook patterns under `on-prem/`.
- Local SSH config resolves `win-kuhnle` to `192.168.1.14` as local `Administrateur`.
- Local SSH config resolves `winad-kuhnle` to `192.168.1.14` as `format\Administrateur`.
- Both aliases use `~/.ssh/windows-admin_ed25519`.
- Role, domain membership, service state, firewall scope, update state, event logs, and disk state are not yet verified.

Next safe checks:

- Verify `win-kuhnle` with read-only `hostname` and `whoami`.
- Verify `winad-kuhnle` only after confirming current local access and domain membership expectations.
- Record role, hostname, domain membership, IP, SSH alias state, WinRM state, firewall scope, updates, services, event logs, and disk state before changes.

## 2026-04-18 - Pre-Update Discovery

Scope:

- Performed read-only preflight before installing Windows updates.
- No reboot, snapshot, migration, power, firewall, SSH, WinRM, GPO, or data changes were made during discovery.

Findings:

- `win-kuhnle` authenticated key-only and returned hostname `KUHNLE`, identity `kuhnle\administrateur`.
- `winad-kuhnle` authenticated key-only and returned hostname `KUHNLE`, identity `format\administrateur`.
- OS: Windows Server 2022 Standard, version `10.0.20348`.
- Domain: `format.lu`.
- Domain role: `MemberServer`.
- Domain secure channel was healthy; `nltest /sc_query:format.lu` succeeded against `\\PDC.format.lu`.
- Services: `sshd` was `Running`/`Automatic`; `WinRM` was `Stopped`/`Disabled`.
- `winrm enumerate winrm/config/listener` failed because WinRM was not running.
- Remote-admin firewall address filters for the expected SSH/WinRM rules were scoped to `192.168.1.73` and `192.168.113.2`.
- Disk health reported healthy volumes; `C:` had about 28 GB free of about 53 GB and `D:` had about 37 GB free of about 54 GB.
- Recent hotfixes showed March 2026 security updates installed.
- Last 7 days event count: `System=3`, `Application=5` warnings/errors.
- Pending Windows Update inventory showed 3 software updates:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Blast radius:

- `Kuhnle` is confirmed as a domain-joined Windows member server, but application role is still not verified.
- Installing OS updates may require a later reboot even though the update search reported `Reboot=False` before installation.
- Do not reboot without an explicit maintenance window because production role and user impact are not yet documented.

## 2026-04-18 - Windows Update Install Attempt Blocked

Scope:

- Attempted to install pending software updates after pre-update discovery.
- No updates were installed on `Kuhnle`.
- No reboot was performed.
- No VMware, GPO, firewall, SSH, WinRM, power, snapshot, migration, or data changes were made.

Attempts:

- Direct Windows Update COM install from `winad-kuhnle` reached update enumeration but failed creating the downloader with `E_ACCESSDENIED`.
- Direct Windows Update COM install from `win-kuhnle` reached update enumeration but failed creating the downloader with `E_ACCESSDENIED`.
- Temporary SYSTEM scheduled task creation using both `win-kuhnle` and `winad-kuhnle` failed with `Access is denied`.
- Temporary LocalSystem service `FormatOpsWindowsUpdate` could be created, but `sc start` failed with service error `1053`; no update log was created.

Cleanup:

- Temporary service `FormatOpsWindowsUpdate` was deleted.
- Temporary installer script was removed from `C:\ProgramData\FormatOps\Install-WindowsUpdates-NoReboot.ps1`.
- No `Kuhnle` update log was left because the installer never started.

Post-checks:

- `Kuhnle` remained reachable over SSH.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update search still showed the original 3 pending updates:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)
- Registry reboot check was `False`.

Next:

- Use an approved interactive/elevated console path, vCenter console, RMM, or an already-approved privilege elevation method to run Windows Update.
- Keep `Kuhnle` out of any reboot plan until updates are actually installed and its production role is documented.

## 2026-04-18 - Reboot Completed, Updates Still Pending

Scope:

- Rebooted `Kuhnle` with explicit approval.
- No Windows updates were installed by this reboot.
- No VMware, GPO, firewall, SSH, WinRM, snapshot, migration, or data changes were made.

Result:

- Reboot completed successfully.
- Post-reboot boot time: 2026-04-18 22:32:43.
- `Kuhnle` remained reachable over SSH as `kuhnle\administrateur`.
- Domain secure channel remained healthy.
- `sshd` remained `Running`/`Automatic`.
- `WinRM` remained `Stopped`/`Disabled`; no change was made.
- Windows Update pending count after reboot: `3`.
- Registry reboot check after reboot: `False`.
- Updates still pending:
  - Windows Malicious Software Removal Tool x64 v5.140 (`KB890830`)
  - 2026-04 cumulative update for .NET Framework 3.5, 4.8, and 4.8.1 (`KB5084071`)
  - 2026-04 cumulative update for Microsoft server operating system version 21H2 (`KB5082142`)

Next:

- Use an approved interactive/elevated console path, vCenter console, RMM, or another approved privilege elevation method to install the pending updates.
