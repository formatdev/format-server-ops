# ESX-D On-Prem Runbooks

Runbooks for the on-prem VMware host shown as `192.168.5.203` in vCenter.

Last updated: 2026-04-18

## Current VM Inventory

The VM list was captured from the vCenter UI screenshot on 2026-04-18.

| VM | Folder | Expected access alias | Notes |
| --- | --- | --- | --- |
| `Admin` | [admin](admin/README.md) | `win-admin`, `winad-admin` | Windows admin/jump server. |
| `Easyjob3` | [easyjob3](easyjob3/README.md) | `win-easyjob3`, `winad-easyjob3` | Windows application/member server; previous inventory exists in `docs/`. |
| `Exchange3` | [exchange3](exchange3/README.md) | `win-exchange3`, `winad-exchange3` | Exchange server; treat as high-risk mail infrastructure. |
| `File` | [file](file/README.md) | `win-file`, `winad-file` | Windows file server and redirected-folder target. |
| `Lportainer` | [lportainer](lportainer/README.md) | `lportainer` | Docker/Portainer host documented elsewhere in this repo. |
| `PDC` | [pdc](pdc/README.md) | `win-pdc`, `winad-pdc` | Primary domain controller. |
| `Tim` | [tim](tim/README.md) | `win-tim`, `winad-tim` | Windows workstation/server VM; role to verify. |
| `VMware vCenter Server` | [vmware-vcenter-server](vmware-vcenter-server/README.md) | vCenter UI/API | vCenter appliance managing ESX-D. |

The screenshot also showed a `vCLS-*` VM. That is a VMware Cluster Services system VM, not a normal workload runbook target. Do not power it off, delete it, or migrate it manually unless following VMware guidance.

## Safety Rules

- Treat all ESX-D VMs as production until proven otherwise.
- Do not reboot, snapshot, migrate, or delete VMs without explicit confirmation.
- Prefer read-only discovery first: SSH, WinRM, VMware inventory, event logs, services, and disk state.
- For Windows servers, preserve local `Administrateur` break-glass SSH if it already works.
- For domain-managed Windows servers, prefer the `SSH Admins` AD group and `winad-*` aliases for routine administration.
- For domain controllers and Exchange, avoid broad GPO/security changes unless the blast radius is understood.
- For the file server, do not delete redirected-folder data or legacy `D:\Users` content without a reviewed cleanup plan and backup.

## Common Windows Remote Admin Baseline

The current target pattern for Windows member servers is:

- local break-glass SSH alias: `win-<name>`
- domain-admin SSH alias: `winad-<name>`
- identity: `~/.ssh/windows-admin_ed25519`
- domain user: `format\Administrateur`
- AD group: `SSH Admins` (`sAMAccountName: sshadmins`)
- OpenSSH settings:
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`
  - `PermitEmptyPasswords no`
  - `AllowGroups format\sshadmins` plus any intentionally retained local break-glass group
- `sshd` service: `Automatic`, `Running`, restart-on-failure configured
- WER dumps for `sshd.exe`: `C:\ProgramData\ssh\dumps`
- WinRM service: `Automatic`, `Running`
- WinRM HTTP listener: `5985`
- scoped inbound firewall for SSH `22` and WinRM `5985`:
  - `192.168.1.73`
  - `192.168.113.2`

## Files

- [new-thread-prompt.md](new-thread-prompt.md): prompt for starting a dedicated ESX-D maintenance thread
- one subfolder per VM with `README.md` and `maintenance-log.md`

