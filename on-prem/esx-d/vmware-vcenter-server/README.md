# VMware vCenter Server Runbook

Starter runbook for the `VMware vCenter Server` VM on ESX-D.

Last updated: 2026-10-31

## Known State

- VM name in vCenter: `VMware vCenter Server`
- Role: vCenter appliance managing ESX-D / on-prem VMware inventory
- Access: vCenter UI/API, verify URL and credentials in the password manager
- Verified UI URL: `https://vcenter8.format.lu/` (resolves to 192.168.5.15). Peter signed in to Chrome for a read-only check on October 31; no credentials were extracted or stored by Codex.
- At about 21:48, ESX-D 192.168.5.203 is Connected again, HA Connected (Secondary), about 58 minutes uptime, ProLiant DL325 Gen10 Plus v2, ESXi 8.0.3 build 24674464 (Update 3e). Peter confirms the earlier Not responding state was intentional firmware maintenance; the ESXi build is unchanged.
- Easyjob3 is back on .203, Powered On/Normal, hardware version 21. Its operator-initiated return migration completed at 21:47:01. Earlier .205 placement was temporary. No migration was performed by Codex; use current vCenter placement before future VM/host work.
- Appliance backup/health, exact HPE firmware versions and HPE/vCenter compatibility of a future ESXi patch remain unverified. Broadcom lists Update 3k build 25595708 as the current 8.0 U3 branch patch; this is vendor catalog information, not a deployment/entitlement/compatibility assessment. No host update is authorized by the read-only inspection.
- Licence assignments verified October 31: `vcenter8.format.lu` uses **vCenter Server 8 Essentials**, expiration **Never**. ESX-D .203 and the other two managed hosts use **vSphere 8 Essentials Plus**, each expiration **Never**. These are non-expiring installed licences; support coverage and patch/download entitlement were not verified. No licence key is stored in this runbook, and no assignment or synchronization was changed. See the VMware platform log for sanitized usage/capacity evidence.
- Subsequent signed-in Broadcom inspection: account dashboard reports 0 active contracts; the vendor-linked critical-patch Solutions page displays terms but **No data found**, with no packages/download controls. No specific ESXi/vCenter patch access is confirmed, and no download or terms acceptance occurred. Ask Broadcom to resolve the empty catalogue; see the platform maintenance log. This is not proof that the installed perpetual licences are invalid or that the account is ineligible.

## Safety Rules

- Treat as critical virtualization management infrastructure.
- Do not power off, snapshot, resize, or patch without explicit confirmation.
- Do not confuse this VM with the ESX-D host itself.
- Verify vCenter health and backup before updates.

## First Checks

From the vCenter UI:

- appliance health
- storage usage
- backups
- services
- ESX-D host connectivity
- VM inventory
- recent alarms/events

Record verified facts in [maintenance-log.md](maintenance-log.md).

