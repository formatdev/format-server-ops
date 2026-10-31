# ESX-D On-Prem Runbooks

Runbooks for the on-prem VMware host shown as `192.168.5.203` in vCenter.

Last updated: 2026-10-31

Latest host/placement verification, October 31 about 21:48: **192.168.5.203 is Connected again**, with HA Connected (Secondary), and **Easyjob3 is back on .203**. Peter confirms its temporary .205 placement and .203 downtime were intentional firmware maintenance; vCenter records the return migration completed at 21:47:01. ESXi remains 8.0.3 build 24674464 (Update 3e), so the physical firmware work did not update the hypervisor. Codex performed no migration/reconnect/power action. Always recheck placement before host-level maintenance.

## October 31 Maintenance Status

Final Easyjob3 outcome, verified at 23:18: Windows component repair and the
Easyjob-only RPC trust fix are complete. VMware Time Provider is removed;
Secure Boot PK/2023 KEK servicing is Updated; VBS, Credential Guard and memory
integrity are running. All 48 SQL databases and core services pass, and Peter
confirms Easyjob works with HVCI active. Both approved maintenance snapshots were
removed and consolidated successfully without reboot. This final state supersedes
the earlier pending Easyjob3 security/outage notes below, which record the day's
sequence. Remaining follow-ups include PDC certificate-revocation reachability,
endpoint signing/bypass-IO warnings, inactive System Guard Secure Launch, disk
capacity/earlier component-cleanup behavior and VMware critical-patch access.
See [Easyjob3's runbook](easyjob3/README.md) and maintenance log for final evidence.

- Admin, Easyjob3, Exchange3, File, PDC and Tim were reached through local and domain SSH. All six Windows Update searches succeeded with zero applicable updates; CBS/WU reboot markers are clear. WinRM remains intentionally disabled by GPO. No update installation or Codex reboot was performed. The separately authorized Easyjob3-only policy change is recorded below.
- Initial member trust checks and five-context PDC/BDC replication passed. Later BDC became unreachable consistently with its operator-documented ESX-C shutdown, and PDC reported inbound replication failures. Easyjob3's first post-reboot trust failure was subsequently resolved after the approved host-only RPC override and Peter's second reboot; cross-DC verification remains pending. Exchange automatic services were running, sampled queues empty and fresh delivery records present during its check. ACME returned 0; all 13 retained daily diagnostic-cleanup reports have zero errors. Peter explicitly retained the existing fixed-UTC cleanup schedule (currently 05:30 local).
- Easyjob3's authorized SYSTEM repair completed successfully: all 40 corrupt component payloads were repaired, SFC repaired protected files and a verification-only pass found no integrity violations. At that pre-reboot checkpoint, CheckHealth reported no component-store corruption, all 48 SQL databases were online, PDC trust passed and CBS/WU reboot flags were clear. C: had approximately 13.01 GiB free. Codex performed no reboot, SQL stop or protection bypass. The later post-reboot domain findings below supersede that trust result. The earlier component cleanup partially reclaimed about 7 GiB but its catalog-deletion blockage was not retested after repair; capacity planning and that separate cleanup issue remain follow-ups.
- Other follow-ups: recurring Admin/Tim Netlogon events despite healthy current trust; FILE endpoint warnings, pending file renames and stale desktop notes; Exchange transport/DKIM warnings without current sampled queue blockage. No redirected-folder or legacy-user data was changed.
- Easyjob3 repair/verification finished by 18:46 local. All three completed one-off tasks returned 0 and were removed; native reports were retained. No Codex repair task remains active. Temporary staging's lowest sampled free space was 6.03 GiB; cancellation was not needed. The 150-GiB disk has no unallocated extent, and separate Edge/Panda pending file operations remain untouched.
- Peter rebooted Easyjob3 at 18:54:24 and upgraded Easyjob to 6.28.2.73. After the initial post-boot PDC trust failure (1311), he authorized the separate Easyjob-only RPC compatibility GPO `97f95ddc-2bf8-4c18-a40c-2977cef6e29d`, sole Apply trustee `EASYJOB3$`, sole value `EnableAuthEpResolution=0`, then rebooted again at **19:41:10**. At 19:46-19:47, repeated secure-channel tests pass and nltest reports PDC status 0; registry/RSoP confirm the override survived reboot and NTLM blocking remains intact. Default Domain Policy and the Exchange-only policy were preserved, with backups retained on PDC. SQL is 48/48 online, core Easyjob/endpoint services run, DISM CheckHealth reports no corruption, C: has 14.45 GiB free, and CBS/WU/pending-file flags are clear. WinRM remains disabled. The earlier SYSTEM update scan offered zero updates; no machine-password reset, Codex reboot or additional cleanup occurred. Startup Netlogon, `dggpext.dll`, VMware precision-time and Secure Boot firmware warnings remain recorded follow-ups; an operator Easyjob workflow check remains pending.
- Easyjob3 warning follow-up: Peter confirms the three stopped optional Easyjob services are unused and reports the rest is OK. Read-only investigation confirms an old NULL Secure Boot Platform Key with an incomplete KEK update, an enabled VMware precision-time provider without its device, and VBS configured but not running because required virtualization/DMA capabilities are unavailable. Supported remedies and approval gates are recorded in the Easyjob3 runbook/log; no further policy, Tools, boot-key or power change was made.
- Peter subsequently authorized removing only Easyjob3's VMware Time Provider. The signed installed-version MSI completed at 20:06:56 with result 0; feature comparison confirms only that component removed, with registry/DLL absent and all 48 databases/core services still online. Domain time and trust pass. Configuration/log backup is retained; no reboot or vSphere time-sync checkbox change occurred. Both checkboxes were found checked; periodic sync should be handled separately from the removed provider. Next approved reboot should validate no recurring provider errors. Secure Boot/VBS changes remain unapproved and were not performed.
- Post-firmware Easyjob3 checks at 21:47-21:50: trust passes, all 48 SQL databases/core services run, RPC override 0 and NTLM block 2 remain intact. Time recovered to PDC synchronization after a transient unsynchronized sample; no manual clock action occurred. Secure Boot still has a NULL PK/incomplete KEK update. VMware VBS, guest virtualization exposure and virtual IOMMU are all disabled, explaining missing prerequisites. Preferred plan is HPE/vCenter-compatible ESXi 8 patch assessment for automated PK repair, then staged guest VBS activation with compatibility/recovery checks. Do not reduce the domain DMA requirement before testing VMware VBS's IOMMU support. Endpoint-agent signing warnings remain a compatibility-review gate, not proven HVCI failures. No configuration change was made in this inspection.
- Lportainer remained unreachable and was not powered on, preserving the prior intentional shutdown. ESXi/vCenter network endpoints were checked, but authenticated host/appliance health and available updates remain unverified. Per-VM maintenance logs distinguish completed checks from these outstanding items.

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

- On 2026-10-10, Peter confirmed all VMs and hosts had been rebooted. This is an operator confirmation; authenticated ESXi/vCenter boot-time verification remains unavailable.

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
- WinRM service: intentionally disabled by GPO as of 2026-07-19; do not treat `Stopped`/`Disabled` as drift unless the policy changes.
- Historical WinRM HTTP listener: `5985`
- scoped inbound firewall for SSH `22` and WinRM `5985`:
  - `192.168.1.73`
  - `192.168.113.2`

## Files

- [new-thread-prompt.md](new-thread-prompt.md): prompt for starting a dedicated ESX-D maintenance thread
- one subfolder per VM with `README.md` and `maintenance-log.md`
