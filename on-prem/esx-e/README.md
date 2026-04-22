# ESX-E On-Prem Runbooks

Runbooks for the on-prem VMware host `ESX-E`.

Last updated: 2026-04-18

## Current VM Inventory

ESX-E currently holds one known workload VM.

| VM | Folder | Expected access alias | Notes |
| --- | --- | --- | --- |
| `Veeam` | [veeam](veeam/README.md) | `win-veeam` | Standalone Windows Veeam server; not joined to the `format.lu` domain. |

## Safety Rules

- Treat ESX-E and the Veeam VM as production backup infrastructure until proven otherwise.
- Do not reboot, snapshot, migrate, update, or power off the Veeam VM without explicit confirmation.
- Before changing the Veeam server, inspect backup job state, repository health, free disk space, recent failures, and active sessions.
- Do not assume domain policies, domain groups, or `winad-*` SSH aliases apply here.
- Preserve any working local break-glass access.
- Keep secrets, backup repository credentials, license data, private keys, and unredacted backup paths out of the repo.

## Standalone Windows Remote Admin Baseline

Because the Veeam VM is not domain-joined, the expected pattern is local-only administration unless later discovery says otherwise.

- local SSH alias: `win-veeam`, if configured
- local admin account: verify during maintenance; do not assume whether it is `Administrateur` or `Administrator`
- identity: `~/.ssh/windows-admin_ed25519`, if this host uses the shared Windows admin key
- OpenSSH settings to prefer:
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`
  - `PermitEmptyPasswords no`
  - `AllowGroups administrators` or a more specific local admin group if one exists
- `sshd` service: `Automatic`, `Running`, restart-on-failure configured
- WER dumps for `sshd.exe`: `C:\ProgramData\ssh\dumps`
- WinRM service: `Automatic`, `Running`, only if intentionally enabled for this standalone host
- WinRM HTTP listener: `5985`, only if intentionally enabled
- scoped inbound firewall for SSH `22` and WinRM `5985`, if WinRM is enabled:
  - `192.168.1.73`
  - `192.168.113.2`

## Files

- [new-thread-prompt.md](new-thread-prompt.md): prompt for starting a dedicated ESX-E maintenance thread
- [veeam/README.md](veeam/README.md): Veeam VM runbook
- [veeam/maintenance-log.md](veeam/maintenance-log.md): Veeam maintenance history
