# FILE Maintenance Log

## 2026-04-18 - All-Server Sweep Follow-Up

Maintainer: Codex with Peter

Checks:

- `win-file` and `winad-file` had already been verified earlier in this thread.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: `Running`, `Automatic`.
- Disk space checked: C: 52.4 GB free; D: 319.7 GB free; F: 1958 GB free; G: 2101.5 GB free.
- Pending reboot checked: none detected.
- Recent updates checked: latest installed hotfixes included `KB5078763` and `KB5078766` on 2026-03-16.
- File cleanup performed: deleted 2 files older than 30 days from `C:\Windows\Temp`, less than 0.1 MB. Post-cleanup `C:\Windows\Temp` measured about 79.6 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No redirected-folder, SMB share, user data, GPO, firewall rule, or snapshot/reboot action was changed during this follow-up sweep.

## 2026-04-18 - Delete Empty Legacy Folder `D:\Users\marie-luise.smaczny`

Maintainer: Codex with Peter

Scope:

- Delete only the legacy `D:\Users\marie-luise.smaczny` folder after explicit approval from Peter.

Checks:

- Path existed before deletion: Yes.
- Last write time before deletion: 2026-04-08 10:55:39.
- Recursive child count before deletion: 0.
- SMB open files under the path before deletion: none reported.
- Matching current redirected Documents path: not found during the earlier 2026-04-18 compare.
- Deletion command: `Remove-Item -LiteralPath 'D:\Users\marie-luise.smaczny' -Force`.
- Post-delete check: path no longer existed.

Notes:

- No other `D:\Users` or `D:\RedirectedFolders` data was changed.

## 2026-04-18 - Discovery-First FILE Baseline Refresh

Maintainer: Codex with Peter

Scope:

- Read-only discovery on FILE after resuming ESX-D maintenance.
- No reboot, snapshot, migration, data deletion, GPO change, Docker prune, Windows Update install, or redirected-folder data change performed.

Checks:

- `win-file` break-glass SSH checked: OK; `hostname` returned `file`, `whoami` returned `file\administrateur`.
- `winad-file` domain SSH checked: OK; `hostname` returned `file`, `whoami` returned `format\administrateur`.
- Domain secure channel checked: OK; `Test-ComputerSecureChannel -Verbose` returned `True`; `nltest /sc_query:format.lu` succeeded against `\\BDC.format.lu`.
- `sshd` service checked: `Running`, `Automatic`.
- `sshd_config` checked: `PubkeyAuthentication yes`, `PasswordAuthentication no`, `PermitEmptyPasswords no`, `AllowGroups administrators format\sshadmins`.
- `WinRM` service checked: drift found; service was `Stopped` and `Disabled`.
- WinRM blast radius documented, then restored with `Set-Service WinRM -StartupType Automatic` and `Start-Service WinRM`.
- `WinRM` post-change state checked: `Running`, `Automatic`.
- WinRM listener checked after restore: GPO-sourced HTTP listener on port `5985`, listening on `127.0.0.1`, `192.168.1.7`, and `::1`.
- WinRM policy checked: `AllowAutoConfig = 1`, `IPv4Filter = *`, `IPv6Filter = *` remain present under `HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service`.
- WinRM event history checked: SCM logged WinRM changed from automatic to disabled on 2026-04-08 at 12:59, after it had been restored on 2026-04-07.
- Firewall scoping checked: `Allow remote Admin - SSH 22` and `Allow remote Admin - WinRM 5985` are enabled for Domain profile and scoped to `192.168.1.73,192.168.113.2`.
- Maintainer source path checked: Mac `en0` was `10.10.10.180`, but route to `192.168.1.7` uses `utun4` as `192.168.113.2`, which is in the current firewall scope.
- WinRM TCP reachability checked after restore: `nc -vz -G 5 192.168.1.7 5985` succeeded.
- Disk free space checked: C: about 56 GB free, D: about 343 GB free, F: about 2.1 TB free, G: about 2.25 TB free.
- SMB shares checked: `RedirectedFolders`, `Users`, `Public`, `MailArchives`, `Temp`, `W@P`, `Archives`, print shares, and admin shares present. `RedirectedFolders` and `Users` both use manual caching.
- Folder redirection state checked: current domain `Administrateur` shell folders show Desktop at `C:\Users\Administrateur\Desktop` and Documents at `\\file.format.lu\RedirectedFolders\Administrateur\Documents`.
- Legacy `D:\Users` content checked: `D:\Users` remains shared as `Users`; no SMB open files were found under `D:\Users`.
- Active redirected-folder use checked: open SMB handles existed under `D:\RedirectedFolders` from `192.168.1.11` as `FORMAT\Administrateur` and from `192.168.1.126` as `FORMAT\jens.gilz`.
- Old-vs-new redirected-folder compare checked: only `pascal.martin` and `sarah.stehly` had old `D:\Users\<user>\Documents` folders, each with one file; both also have current `D:\RedirectedFolders\<user>\Documents`.
- Stale legacy candidates checked: `D:\Users\marie-luise.smaczny` exists without a matching new Documents folder; `D:\Users\console.log` exists as a top-level file.
- Desktop Markdown docs checked: `C:\Users\Administrateur\Desktop\FILE-health-log.md`, `FILE-inspect.md`, and `FILE-todo.md` exist; shell-folder registry confirms this desktop path for the current domain admin session.
- GPO state checked: `gpresult /SCOPE COMPUTER /R` lists `Default Domain Policy`, `Drive mapping`, `Backup Bitlocker`, `GPO_Audit_Log_Users`, `NTLM Allow`, `Allow remote Admin`, `Windows Update`, and `Local Group Policy`.
- Updates installed: No.
- Reboot required: Not checked.
- Backup/snapshot confirmed: Not checked.

Notes:

- `net group "SSH Admins" /domain` from FILE failed with RPC unavailable, despite domain secure channel and domain SSH being healthy. Re-check from a DC before changing SSH authorization.
- SCM also logged `sshd` unexpected terminations with automatic restart, most recently on 2026-04-16 at 16:21 followed by running state at 16:22.
- No data was changed under `D:\RedirectedFolders` or `D:\Users`.
- No firewall or GPO changes were made.

Follow-up:

- Monitor whether WinRM is disabled again; previous drift occurred on 2026-04-08 at 12:59 after being restored on 2026-04-07.
- Produce a reviewed candidate list and backup confirmation before any cleanup of `D:\Users`.
- Re-check `SSH Admins` group membership from PDC or another DC because the member-server `net group` RPC check failed.

## 2026-04-07 - Remote Admin And File-Server Baseline

Maintainer: Codex with Peter

Summary:

- Verified `win-file` local break-glass SSH.
- Repaired domain trust/rejoin state externally with Peter; `winad-file` then worked.
- Verified `ssh winad-file whoami` returned `format\administrateur`.
- Restored `WinRM` to `Automatic` and `Running`.
- Verified WinRM HTTP listener on `5985`.
- Verified `5985` reachable from the Mac.
- Verified secure channel healthy with `Test-ComputerSecureChannel -Verbose`.
- Verified scoped firewall rules for SSH `22` and WinRM `5985`.
- Rebuilt canonical desktop Markdown docs under `C:\Users\Administrateur\Desktop`.
- Confirmed current redirected-folder GPO target for Documents is `\\file.format.lu\RedirectedFolders\%USERNAME%\Documents`.
- Confirmed `D:\Users` is legacy relative to the current `D:\RedirectedFolders` target.
- Identified `D:\Users\marie-luise.smaczny\Documents` as a likely stale legacy redirected folder; no deletion performed.
- Checked `RedirectedFolders` share caching: `Manual`.

Follow-up:

- Produce a full old-vs-new redirected-folder compare report before deleting legacy `D:\Users` data.
- Check actual workstation Offline Files/CSC cache state before assuming redirected folders are not cached.
- Consider tightening `AllowGroups` away from broad `administrators` only after validating domain and local break-glass paths.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on FILE using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 3 visible updates successfully: Windows Malicious Software Removal Tool KB890830, .NET cumulative update KB5084071, and OS cumulative update KB5082142.
- Task log: `C:\ProgramData\Codex\windows-update-File-20260418-220823.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 49.0 GB.
- Post-install visible update scan still listed KB5082142 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending and Windows Update reboot required; `PendingFileRenameOperations` was not present.
- Reboot performed: No.

Notes:

- No data was changed under `D:\RedirectedFolders` or `D:\Users`.
- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No SMB data, GPO, firewall rule, snapshot, or reboot action was changed.

Follow-up:

- Reboot FILE in an agreed file-server maintenance window, then re-run Windows Update scan and SMB/redirected-folder access checks.

## 2026-05-03 - Bi-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Scope:

- Health and remote-admin baseline sweep on FILE without changing redirected-folder or legacy user data.

Checks:

- `win-file` break-glass SSH checked: OK; `whoami` returned `file\administrateur`.
- `winad-file` domain SSH checked: OK; `whoami` returned `format\administrateur`.
- Domain secure channel checked: healthy; `Test-ComputerSecureChannel -Verbose` returned `True`.
- `sshd` service checked: `Running`, `Automatic`.
- `WinRM` service checked: found `Stopped`/`Disabled` again, restored to `Running`/`Automatic`.
- WinRM listener checked before restore attempt: `winrm enumerate` failed because the service was stopped.
- Firewall scoping checked: `Allow remote Admin - SSH 22` and `Allow remote Admin - WinRM 5985` still scoped to `192.168.1.73,192.168.113.2`.
- WinRM TCP checked after restore: `192.168.1.7:5985` reachable from the maintainer Mac.
- Disk free space checked: C: about 52.3 GB free; D: about 322.3 GB free; F: about 1947.6 GB free; G: about 2086.3 GB free.
- Legacy `D:\Users` content checked: top-level entries still include user folders such as `Administrateur`, `arnaud.delmelle`, `Atelier`, `bogdan.stachura`, `CBC`, `gilles.konsbruck`, `guy.kaulmann`, `Heiko.Maldener`, `kathryn.melchior`, and `nathalie.bresch`.
- Desktop Markdown docs checked: `FILE-health-log.md`, `FILE-inspect.md`, and `FILE-todo.md` still exist on `C:\Users\Administrateur\Desktop`, last written `2026-04-06 20:30:13`.
- Pending reboot checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Visible Windows updates checked: `0`.
- File cleanup performed: no files older than 30 days remained in `C:\Windows\Temp`; remaining temp content about 59.9 MB.
- Updates installed: No.
- Reboot required: not indicated by CBS or Windows Update; `PendingFileRenameOperations` remains present.
- Backup/snapshot confirmed: Not checked.

Notes:

- April update state appears finalized because visible updates and reboot flags are clear.
- WinRM drift recurred again on FILE.
- No redirected-folder data, legacy `D:\Users` data, SMB shares, firewall rules, or GPOs were changed.

Follow-up:

- Investigate why `WinRM` keeps drifting back to `Disabled`/`Stopped` on FILE.
- Keep legacy `D:\Users` cleanup in the reviewed-plan lane only; this pass made no content changes there.

## 2026-05-16 - Twice-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Scope:

- Health recheck, remote-admin drift repair, and no-reboot Windows Update install.

Checks:

- `win-file` break-glass SSH checked: OK.
- `winad-file` domain SSH checked: OK.
- Domain secure channel checked: `Test-ComputerSecureChannel -Verbose` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` service checked: `Running`/`Automatic`.
- `WinRM` service checked: had drifted to `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- WinRM listener checked: TCP `5985` reachable again from the maintainer Mac.
- Firewall scoping checked: still limited to `192.168.1.73` and `192.168.113.2`.
- Disk free space checked: C: about 51.7 GB before update install; D: about 322.1 GB; F: about 1934.4 GB; G: about 2078.1 GB.
- SMB shares checked: not changed in this pass.
- Folder redirection state checked: desktop Markdown files still present; no redirected-folder data changed.
- Legacy `D:\Users` content checked: not changed in this pass.
- Event logs reviewed: Windows Update task log under `C:\ProgramData\Codex`.
- Updates installed: Yes. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` completed with `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Reboot required: Yes.
- Backup/snapshot confirmed: Not checked.
- Notes: Installed payloads were MRT `KB890830`, .NET cumulative update `KB5088862`, and OS cumulative update `KB5087545`. Post-install remote Windows Update scan returned `VisibleUpdates=0`. No redirected-folder data, legacy `D:\Users` data, SMB shares, firewall rules, or GPOs were changed.
- Follow-up: remove the one-off task if it is still present, then reboot FILE in a planned file-server window and re-run update plus SMB/redirected-folder smoke checks.

## 2026-05-31 - End-Of-Month Maintenance Sweep

Maintainer: Codex with Peter

Scope:

- Health recheck, remoting recovery, secure-channel sanity check, and no-reboot Windows Update validation.

Checks:

- `win-file` break-glass SSH checked: OK.
- `winad-file` domain SSH checked: OK.
- Domain secure channel checked: still split. `nltest /sc_query:format.lu` returned `1311`, `nltest /sc_verify:format.lu` returned `NERR_Success` against `\\BDC.format.lu`, and `Test-ComputerSecureChannel -Server PDC.format.lu` still returned `False`.
- `sshd` service checked: `Running`/`Automatic`.
- `WinRM` service checked: had drifted again to `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- WinRM listener checked: service recovery completed; no listener reconfiguration was needed.
- Firewall scoping checked: not changed in this pass.
- Disk free space checked: not deeply re-measured in this pass.
- SMB shares checked: not changed in this pass.
- Folder redirection state checked: no redirected-folder content was touched.
- Legacy `D:\Users` content checked: no legacy content was touched.
- Event logs reviewed: no deep event-log pass in this sweep; Windows Update task log under `C:\ProgramData\Codex` was checked.
- Updates installed: No. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` ran successfully and logged `VisibleCount=0`.
- Reboot required: No reboot flag was present in this pass.
- Backup/snapshot confirmed: Not checked.
- Notes: A low-impact `nltest /sc_reset:format.lu\\PDC.format.lu` succeeded and `nltest /sc_verify` remained healthy, but the generic secure-channel split persists. Remote COM-based Windows Update queries still fail from the SSH admin context with `0x80240032`, while the SYSTEM-context update script completed normally.
- Follow-up: keep FILE in the "operational but secure-channel noisy" lane unless the split starts causing SMB, GPO, or login failures. Keep redirected-folder and legacy-user-data cleanup strictly out of band.

## 2026-05-31 - Post-Update/Reboot Validation

Maintainer: Codex with Peter

Scope:

- Validate FILE after Peter completed manual updates, cleanup, guest reboot, and ESX-D host reboot.

Checks:

- Post-host-reboot network checked: `192.168.1.7` responded to ping.
- `win-file` break-glass SSH checked: OK, returned `file`.
- `winad-file` domain SSH checked: reached the host but returned SSH permission denied for the domain-admin alias.
- Domain secure channel checked from the local SSH context: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` service checked: `Running`/`Automatic`.
- `WinRM` service checked: `Running`/`Automatic`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Latest hotfix checked: `KB5087545`, installed `2026-05-17`.

Notes:

- FILE is operational after the full guest/host reboot cycle.
- No redirected-folder data, legacy `D:\Users` data, SMB shares, firewall rules, or GPOs were changed in this validation.

## 2026-05-31 - Domain SSH Follow-Up

Maintainer: Codex with Peter

Checks and actions:

- Compared domain SSH behavior after the post-host-reboot validation.
- `winad-file` initially reached the host but returned SSH permission denied for `format\Administrateur`.
- `nltest /sc_verify:format.lu` already returned `NERR_Success` against `\\PDC.format.lu`.
- Ran low-impact secure-channel reset:
  - `nltest /sc_reset:format.lu\\PDC.format.lu`
  - `nltest /sc_verify:format.lu`
- Retested `winad-file`; domain SSH returned `file`.

Notes:

- FILE domain SSH access is restored.
- No local group, SSH key, firewall, GPO, SMB, or redirected-folder data change was made.

## 2026-06-14 - Twice-Monthly Maintenance Discovery

Maintainer: Codex with Peter

Scope:

- Start of the June maintenance round, discovery-first.

Checks and actions:

- `win-file` break-glass SSH checked: returned `file\administrateur`.
- `winad-file` domain SSH checked: returned `format\administrateur`.
- Domain secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd` service checked: `Running`/`Automatic`.
- `WinRM` service checked: found `Stopped`/`Disabled` again; restored to `Running`/`Automatic`.
- WinRM listener checked: GPO listener present on `5985`.
- Firewall scoping checked: `Allow remote Admin - SSH 22` and `Allow remote Admin - WinRM 5985` still scoped to `192.168.1.73,192.168.113.2`.
- Disk free space checked: C: about 48.2 GB free; D: about 317.5 GB; F: about 1953.5 GB; G: about 2050.6 GB.
- SMB shares checked: `RedirectedFolders` and `Users` still present; no share changes made.
- SMB open files checked: active open files found under `D:\RedirectedFolders`; an open handle also existed on `D:\Users`.
- Folder redirection state checked: no redirected-folder content was touched.
- Legacy `D:\Users` content checked: top-level entries still present; compare report showed some old `Documents` folders still exist and should not be deleted without review.
- Desktop Markdown docs checked: `FILE-todo.md`, `FILE-health-log.md`, and `FILE-inspect.md` still present on `C:\Users\Administrateur\Desktop`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: `KB5094147` and `KB5094128` installed on `2026-06-13`.
- Visible Windows updates checked: `0`.

Notes:

- FILE is operational and update-clean.
- WinRM drift recurred again and was restored only at the service level; no GPO or firewall rule was changed.
- Legacy `D:\Users` cleanup remains out of scope because there are active/open handles and mixed old/new document-folder timestamps.

## 2026-07-04 - Inspection Round

Maintainer: Codex with Peter

Scope:

- Start of July ESX-D inspection, discovery-first.

Checks:

- Network reachability checked: `192.168.1.7` responded to ping from the maintainer Mac.
- SSH checked: both `win-file` and `winad-file` timed out on TCP/22.
- Additional TCP checks from the maintainer Mac timed out on `22`, `5985`, `443`, and `80`.
- Cross-check from Admin toward `file.format.lu:22` could not complete before the probe was stopped after confirming the same pattern on PDC.

Notes:

- FILE appears network-present but remote management ports were not reachable from the maintainer path during this inspection.
- No FILE service, share, redirected-folder, legacy `D:\Users`, firewall, GPO, cleanup, reboot, or update action was performed.
- Follow up from vCenter/console or another LAN host to confirm whether `sshd`/WinRM are stopped, firewall scope changed, or the host is in a restricted network state.

## 2026-07-19 - Twice-Monthly Inspection Round

Maintainer: Codex with Peter

Scope:

- July maintenance inspection, discovery-first. No installs, reboots, firewall/GPO changes, or file-server data cleanup.

Checks and actions:

- `win-file` and `winad-file` checked: both returned `file`; domain SSH returned `format\administrateur`.
- Domain secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\BDC.format.lu`.
- `sshd`, `Spooler`, and `Netlogon` checked: `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Recent hotfixes checked: latest visible installed security updates remained `KB5094147` and `KB5094128` from `2026-06-13`.
- Visible Windows updates checked: `3`, already downloaded:
  - Windows Malicious Software Removal Tool x64 v5.143 `KB890830`
  - .NET cumulative update `KB5102206`
  - OS cumulative update `KB5099540`
- Disk free space checked: C: about 48.1 GB free; D: about 317.1 GB; F: about 2003.5 GB; G: about 2010.1 GB.
- SMB shares checked: `RedirectedFolders`, `Users`, `Public`, `MailArchives`, `Temp`, `W@P`, `Archives`, print shares, and admin shares present.
- SMB open files checked: active handles existed under both `D:\RedirectedFolders` and `D:\Users`.
- Legacy `D:\Users` compare checked: old `Documents` folders still exist for `Administrateur`, `pascal.martin`, and `sarah.stehly`; current redirected-folder targets also exist.
- Desktop Markdown docs checked: `FILE-todo.md`, `FILE-health-log.md`, and `FILE-inspect.md` still present.

Notes:

- FILE is reachable again after the 2026-07-04 management-port outage.
- FILE has July updates visible/downloaded and a pending file rename; no update install or reboot was performed.
- No redirected-folder data or legacy `D:\Users` content was changed. Cleanup remains out of scope because active handles exist under both trees and the old/new compare still needs review.

## 2026-07-19 - Remote Update Install Attempt Blocked

Maintainer: Codex with Peter

Actions:

- Attempted to start a no-reboot Windows Update install remotely.
- Creating a SYSTEM scheduled task over domain SSH failed with `Access is denied`.
- Direct Windows Update COM install over SSH could search and queue updates, but creating the downloader/installer failed with `0x80070005 E_ACCESSDENIED`.
- Local break-glass SSH could create a harmless short SYSTEM task, but task actions invoking the staged PowerShell update script were rejected with `Access is denied`.
- Temporary test artifacts were removed from `C:\ProgramData\Codex`.

Notes:

- No updates were installed and no reboot was performed by Codex.
- July updates remain visible/downloaded and require an interactive elevated session or another approved elevation path.

## 2026-07-19 - Post-Manual Update Validation

Maintainer: Codex with Peter

Scope:

- Recheck FILE after Peter completed manual updates, cleanup, reboots, and ESX-D host restart.

Checks:

- `winad-file` domain SSH checked: OK, returned `format\administrateur`.
- Domain secure channel checked: `Test-ComputerSecureChannel -Server PDC.format.lu` returned `True`; `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `sshd`, `Spooler`, and `Netlogon` checked: `Running`/`Automatic`.
- `WinRM` checked: `Stopped`/`Disabled` again after reboot/policy refresh.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Recent hotfixes checked: `KB5099540`, `KB5120210`, and `KB5101010` installed on `2026-07-19`.
- Visible Windows updates checked: `0`.
- SMB shares checked: expected shares still present, including `RedirectedFolders`, `Users`, `Public`, `MailArchives`, `Temp`, `W@P`, and `Archives`.
- SMB open files checked: active handles still exist under both `D:\RedirectedFolders` and `D:\Users`.
- Desktop Markdown docs checked: `FILE-todo.md`, `FILE-health-log.md`, and `FILE-inspect.md` still present.

Notes:

- FILE is update-clean and does not currently require a reboot.
- No redirected-folder data, legacy `D:\Users` data, SMB shares, firewall rules, or GPOs were changed.
- WinRM disablement appears to be recurring after reboot/policy refresh and should be handled as a GPO/baseline follow-up, not as an individual server issue.

## Maintenance Template

Date:

Maintainer:

Scope:

Checks:

- `win-file` break-glass SSH checked:
- `winad-file` domain SSH checked:
- Domain secure channel checked:
- `sshd` service checked:
- `WinRM` service checked:
- WinRM listener checked:
- Firewall scoping checked:
- Disk free space checked:
- SMB shares checked:
- Folder redirection state checked:
- Legacy `D:\Users` content checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Backup/snapshot confirmed:
- Notes:
- Follow-up:
