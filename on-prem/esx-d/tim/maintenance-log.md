# TIM Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-tim` and `winad-tim` both returned `Tim`.
- Secure channel checked: healthy; domain `format.lu`.
- OS checked: Microsoft Windows 11 Pro for Workstations `10.0.26200`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM TCP checked: `192.168.1.12:5985` reachable after restore.
- Disk space checked: C: 12.3 GB free of 64.2 GB.
- Pending reboot checked: `Component Based Servicing\RebootPending` present.
- Recent updates checked: latest installed hotfixes included `KB5088467` and `KB5083769` on 2026-04-18.
- File cleanup performed: deleted 273 files older than 30 days from `C:\Windows\Temp`, about 22.9 MB. Post-cleanup `C:\Windows\Temp` measured about 66.2 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No application data, user data, GPO, firewall rule, or snapshot/reboot action was changed.

Follow-up:

- C: free space is low; inspect non-user cleanup candidates before installing more updates.
- Schedule/confirm a reboot window if the pending Windows reboot is expected after the 2026-04-18 updates.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on TIM using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 4 visible updates successfully: Windows Security platform KB5007651, Windows Malicious Software Removal Tool KB890830, .NET Framework security update KB5082417, and Windows security update KB5083769.
- Task log: `C:\ProgramData\Codex\windows-update-Tim-20260418-220849.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 10.7 GB.
- Post-install visible update scan still listed KB5007651, KB5082417, and KB5083769 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending and Windows Update reboot required; `PendingFileRenameOperations` was not present.
- Reboot performed: No.

Notes:

- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No application data, user data, GPO, firewall rule, snapshot, or reboot action was changed.

Follow-up:

- Reboot TIM in an agreed workstation maintenance window, then re-run Windows Update scan.
- C: free space is now low after update staging; inspect cleanup candidates after reboot finalizes component servicing.

## 2026-05-03 - Bi-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-tim` and `winad-tim` both connected; `winad-tim whoami` returned `format\administrateur`.
- Secure channel checked: broken; `Test-ComputerSecureChannel -Verbose` returned `False`.
- Secure-channel repair attempt checked: `Test-ComputerSecureChannel -Repair -Verbose` from the domain-admin SSH path failed with `The user name or password is incorrect`; `nltest /sc_query:format.lu` returned `ERROR_NO_LOGON_SERVERS`.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled` again, restored to `Running`/`Automatic`.
- WinRM listener checked after restore: GPO HTTP listener on `5985` listening on `127.0.0.1`, `192.168.1.12`, `::1`, and link-local IPv6.
- WinRM firewall scope checked: `Allow remote Admin - WinRM 5985` still scoped to `192.168.1.73,192.168.113.2`.
- WinRM local self-test checked: `Test-NetConnection 127.0.0.1 -Port 5985` succeeded and `Test-WSMan 127.0.0.1` returned server identity.
- WinRM TCP checked from the maintainer Mac after restore: `192.168.1.12:5985` timed out.
- Disk space checked: C: about 16.5 GB free.
- Pending reboot checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Visible Windows updates checked: `0`.
- Recent hotfixes checked: `KB5083769`, `KB5088467`, `KB5082417`.
- File cleanup performed: deleted 3 old files from `C:\Windows\Temp`, about 0.9 MB; remaining temp content about 65.7 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- April update state appears finalized because visible updates and reboot flags are clear.
- Both machine trust and WinRM drift/regression recurred on TIM.

Follow-up:

- Run a credentialed secure-channel repair for TIM from an interactive session or with an approved credential path.
- Investigate why external TCP/5985 to TIM now times out even though the local listener and firewall scope look correct.

## 2026-05-03 - Trust Repair Completed From Console

Maintainer: Peter with Codex

Scope:

- Repair the broken `TIM` machine secure channel from the vCenter console after the guest became unstable and was hard-reset.

Actions:

- Peter confirmed locally that `Test-ComputerSecureChannel -Verbose` was broken and `nltest /sc_query:format.lu` returned `1311`.
- Peter ran `Reset-ComputerMachinePassword -Server PDC.format.lu -Credential format\Administrateur`.
- Initial post-reset secure-channel check still failed, so Peter ran:
  - `Test-ComputerSecureChannel -Server PDC.format.lu -Repair -Credential format\Administrateur -Verbose`
  - `Restart-Service Netlogon -Force`
- After a further reboot, Codex rechecked remotely and confirmed:
  - `win-tim` returned `tim\administrateur`
  - `winad-tim` returned `format\administrateur`
  - `Test-ComputerSecureChannel -Server PDC.format.lu -Verbose` returned `True`
  - `nltest /dsgetdc:format.lu` found `\\PDC.format.lu`
  - `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`
- WinRM had to be started again manually after the reboot; Codex then verified TCP/5985 was reachable from the maintainer Mac.
- Visible Windows updates checked after recovery: `0`.

Notes:

- During diagnosis, generic secure-channel checks briefly disagreed with the explicit `-Server PDC.format.lu` check; the final explicit PDC-targeted checks were healthy and are the trusted outcome.
- No domain leave/rejoin, GPO change, firewall rule change, or Windows Update install was performed during this repair.

Follow-up:

- Monitor whether TIM again loses machine trust or WinRM startup state after future reboots.

## 2026-05-16 - Twice-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-tim` and `winad-tim` both remained usable.
- Secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu -Verbose` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success`.
- `sshd` checked: `Running`/`Automatic`.
- `WinRM` checked: had drifted again to `Stopped`/`Disabled`; restored to `Running`/`Automatic`; TCP `5985` reachable again from the maintainer Mac.
- Role verified: workstation/client baseline only; no additional app role check in this pass.
- Disk space checked: C: about 13.6 GB free before update install.
- Event logs reviewed: Windows Update task log under `C:\ProgramData\Codex`.
- Updates installed: Yes. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` completed with `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Reboot required: Yes.
- Notes: Installed payloads were MRT `KB890830`, .NET security update `KB5087051`, and Windows security update `KB5089549`. Post-install remote Windows Update scan returned `VisibleUpdates=0`.
- Follow-up: remove the one-off task if it is still present, reboot TIM in an agreed window, and keep watching for the recurring machine-trust or WinRM drift symptoms after reboot.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Secure channel checked:
- `sshd` checked:
- `WinRM` checked:
- Role verified:
- Disk space checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
