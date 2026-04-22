# FILE Runbook

Runbook for the Windows file server VM `File` on ESX-D.

Last updated: 2026-04-18

## Current Verified State

Last verified from this maintenance thread: 2026-04-18.

- VM name in vCenter: `File`
- Windows hostname: `FILE`
- FQDN: `file.format.lu`
- IP: `192.168.1.7`
- Domain: `format.lu`
- AD OU: `OU=_Edge-Servers with NTLM,OU=_Servers,OU=_Computers,DC=format,DC=lu`
- Local break-glass SSH alias: `win-file`
- Domain-admin SSH alias: `winad-file`
- Both SSH paths were working on 2026-04-18:
  - `win-file` returned `file\administrateur`
  - `winad-file` returned `format\administrateur`
- Domain secure channel was healthy on 2026-04-18.
- `WinRM` drifted from the previous baseline and was found `Disabled`/`Stopped` on 2026-04-18, then restored to `Automatic`/`Running`.
- WinRM HTTP listener exists on port `5985` from GPO and listens on `127.0.0.1`, `192.168.1.7`, and `::1`.
- SSH `22` and WinRM `5985` firewall rules are scoped to:
  - `192.168.1.73`
  - `192.168.113.2`
- On 2026-04-18, the maintainer Mac routed to FILE over `utun4` as `192.168.113.2`, which is in the existing firewall scope; TCP/5985 connected after WinRM was restored.
- `Allow remote Admin` GPO appears in `gpresult` on this host.
- `Windows Update` GPO also appears in `gpresult`; no Windows Update install was run during 2026-04-18 discovery.
- `SSH Admins` AD group existence/membership was previously verified; on 2026-04-18, `net group "SSH Admins" /domain` from FILE failed with RPC unavailable, so re-check from a DC before changing SSH authorization.

Observed 2026-04-18 WinRM drift before restoration:

- `WinRM` service start type: `Disabled`
- `WinRM` service status: `Stopped`
- SCM events show start type changed from automatic to disabled on 2026-04-08 12:59.
- Policy registry still shows `HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\AllowAutoConfig = 1`, `IPv4Filter = *`, and `IPv6Filter = *`.
- Firewall rule `Allow remote Admin - WinRM 5985` remains enabled and scoped to `192.168.1.73,192.168.113.2`.
- Restored during 2026-04-18 maintenance with only `Set-Service WinRM -StartupType Automatic` and `Start-Service WinRM`; no firewall or GPO change was made.

## Critical Roles

- File server
- Redirected-folder target
- Print services may also be present; verify before maintenance

## Important Paths

- Current folder-redirection root: `D:\RedirectedFolders`
- Current Documents policy target: `\\file.format.lu\RedirectedFolders\%USERNAME%\Documents`
- Legacy redirected-folder/user root: `D:\Users`
- Canonical desktop docs: `C:\Users\Administrateur\Desktop`
- SSH admin key file: `C:\ProgramData\ssh\administrators_authorized_keys`
- SSH crash dumps: `C:\ProgramData\ssh\dumps`

## Remote Admin Baseline

The host should keep:

- local break-glass SSH working through `win-file`
- domain-admin SSH working through `winad-file`
- `sshd` `Automatic` and `Running`
- `WinRM` `Automatic` and `Running`
- WinRM HTTP listener on `5985`
- scoped inbound firewall for SSH `22` and WinRM `5985`
- `PasswordAuthentication no`
- `PermitEmptyPasswords no`
- `PubkeyAuthentication yes`
- `AllowGroups` including `format\sshadmins` and any deliberately retained break-glass group

After domain rejoin work, the observed working `sshd_config` line was:

```text
AllowGroups administrators format\sshadmins
```

That works, but is broader than the stricter target pattern. If tightening it, validate `sshd.exe -t` before restarting `sshd`, and keep local break-glass access working.

## Standard Health Check

From the Mac:

```sh
ssh win-file hostname
ssh winad-file hostname
nc -vz 192.168.1.7 22
nc -vz 192.168.1.7 5985
```

On the server:

```powershell
hostname
whoami
Test-ComputerSecureChannel -Verbose
nltest /sc_query:format.lu
Get-Service sshd,WinRM
winrm enumerate winrm/config/listener
Get-Content C:\ProgramData\ssh\sshd_config |
  Select-String 'AllowGroups|PubkeyAuthentication|PasswordAuthentication|PermitEmptyPasswords'
Get-NetFirewallRule -DisplayName 'Allow remote Admin - SSH 22','Allow remote Admin - WinRM 5985' |
  Get-NetFirewallAddressFilter
```

## Redirected Folders

Current GPO target for redirected Documents is:

```text
\\file.format.lu\RedirectedFolders\%USERNAME%\Documents
```

The old `D:\Users` tree still exists and should be treated as legacy/migration residue unless proven active.

Known observation from 2026-04-07:

- `D:\Users\marie-luise.smaczny\Documents` looked stale
- that AD user was not found
- contents were old and minimal
- no deletion was performed

Known observation from 2026-04-18:

- `D:\Users` is still shared as `Users` with access-based enumeration and manual caching.
- `D:\RedirectedFolders` is shared as `RedirectedFolders` with manual caching.
- SMB reported no open files under `D:\Users` during discovery.
- SMB reported active open files under `D:\RedirectedFolders` from `192.168.1.11` as `FORMAT\Administrateur` and `192.168.1.126` as `FORMAT\jens.gilz`.
- `D:\Users\pascal.martin\Documents` and `D:\Users\sarah.stehly\Documents` exist with one file each.
- `D:\Users\marie-luise.smaczny` had zero child items and no SMB open files, then was deleted on 2026-04-18 with explicit approval.
- `D:\Users\console.log` exists as a top-level file.

Before any cleanup, produce a compare report:

```powershell
$oldRoot = 'D:\Users'
$newRoot = 'D:\RedirectedFolders'
Get-ChildItem $oldRoot -Directory | Sort-Object Name | ForEach-Object {
  $oldDocs = Join-Path $_.FullName 'Documents'
  $newDocs = Join-Path (Join-Path $newRoot $_.Name) 'Documents'
  [pscustomobject]@{
    User = $_.Name
    OldDocumentsExists = Test-Path $oldDocs
    NewDocumentsExists = Test-Path $newDocs
    OldDocumentsTime = if (Test-Path $oldDocs) { (Get-Item $oldDocs).LastWriteTime } else { $null }
    NewDocumentsTime = if (Test-Path $newDocs) { (Get-Item $newDocs).LastWriteTime } else { $null }
  }
}
```

Do not delete `D:\Users` content without a reviewed candidate list and backup confirmation.

## Offline Files / Client Cache

As of 2026-04-07:

- `RedirectedFolders` SMB share exists at `D:\RedirectedFolders`
- share caching mode: `Manual`
- `net share RedirectedFolders` reports `Manual caching of documents`
- no domain GPO was found explicitly disabling Offline Files/CSC

So redirected folders are not forced to automatic share caching, but workstation-side Offline Files may still cache content depending on client policy and user/client state. Verify on actual workstations before assuming no cache exists.

## Desktop Markdown Docs

During the remote-admin cleanup, current copies were rebuilt at:

- `C:\Users\Administrateur\Desktop\FILE-todo.md`
- `C:\Users\Administrateur\Desktop\FILE-health-log.md`
- `C:\Users\Administrateur\Desktop\FILE-inspect.md`

The shell profile observed during SSH was `C:\Users\Administrateur.FILE`, so do not assume the visible desktop path without checking shell-folder registry values and real file locations.

## Files

- [maintenance-log.md](maintenance-log.md): ongoing maintenance history
