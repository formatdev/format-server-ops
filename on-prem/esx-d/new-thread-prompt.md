# New Thread Prompt

Use this prompt when opening a dedicated ESX-D maintenance thread from the
`format-server-ops` repository.

```text
We are in /Users/czibulapeter/Documents/GitHub/format-server-ops.

Continue maintaining the on-prem VMware host ESX-D, visible in vCenter as 192.168.5.203. First inspect git status and read:
- on-prem/esx-d/README.md
- on-prem/esx-d/file/README.md
- on-prem/esx-d/file/maintenance-log.md

The ESX-D VM inventory from the 2026-04-18 screenshot includes:
- Admin
- Easyjob3
- Exchange3
- File
- Lportainer
- PDC
- Tim
- VMware vCenter Server

Treat the vCLS VM shown in vCenter as a VMware system VM, not a normal maintenance target.

Use discovery-first operations. Do not reboot, snapshot, migrate, delete data, change GPOs, prune Docker, run Windows Update installs, or change file-server redirected-folder data until the current state and blast radius are documented.

For Windows VMs, verify both local break-glass SSH aliases (`win-*`) and domain-admin aliases (`winad-*`) where configured. Preserve local `Administrateur` SSH. The target remote-admin baseline is key-only OpenSSH, domain-admin access through the `SSH Admins` AD group, scoped firewall for SSH/WinRM from 192.168.1.73 and 192.168.113.2, `sshd` and `WinRM` automatic/running, and `sshd.exe` WER dumps in `C:\ProgramData\ssh\dumps`.

Start with the FILE VM only unless asked otherwise. Verify:
- `ssh win-file hostname`
- `ssh winad-file hostname`
- `Test-ComputerSecureChannel -Verbose`
- `sshd` and `WinRM` service states
- WinRM listener on 5985
- firewall scoping for 22 and 5985
- current redirected-folder target under `D:\RedirectedFolders`
- whether stale legacy folders remain under `D:\Users`
- desktop Markdown docs on `C:\Users\Administrateur\Desktop`

Record findings in the relevant `on-prem/esx-d/<vm>/maintenance-log.md` file. Keep secrets, passwords, private keys, unredacted hashes, and sensitive customer data out of the repo.
```

