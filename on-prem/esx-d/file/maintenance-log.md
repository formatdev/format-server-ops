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
