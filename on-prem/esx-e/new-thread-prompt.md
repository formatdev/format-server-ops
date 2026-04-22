# New Thread Prompt

Use this prompt when opening a dedicated ESX-E maintenance thread from the
`format-server-ops` repository.

```text
We are in /Users/czibulapeter/Documents/GitHub/format-server-ops.

Continue maintaining the on-prem VMware host ESX-E. First inspect git status and read:
- on-prem/esx-e/README.md
- on-prem/esx-e/veeam/README.md
- on-prem/esx-e/veeam/maintenance-log.md

ESX-E currently has one known workload VM:
- Veeam

The Veeam VM is a standalone Windows server and is not joined to the format.lu domain. Do not apply the domain-admin `winad-*` model, `SSH Admins` AD group model, or domain GPO assumptions unless discovery proves the server has been changed.

Use discovery-first operations. Do not reboot, snapshot, migrate, power off, update Windows, change Veeam configuration, alter repositories, delete backup data, prune disks, or change firewall/remote-admin policy until the current state and blast radius are documented.

Start with read-only checks:
- verify the expected SSH alias, likely `win-veeam`, if configured
- verify the Windows hostname and local admin identity
- verify whether the server is still workgroup/standalone
- inspect `sshd` and WinRM service states
- inspect SSH configuration without removing break-glass access
- inspect firewall scope for SSH 22 and WinRM 5985 if WinRM is enabled
- inspect Veeam services, backup job state, recent failures, active sessions, repository state, and free disk space
- inspect Windows event logs and Veeam logs for recent backup or service errors

Record findings in `on-prem/esx-e/veeam/maintenance-log.md`. Keep secrets, passwords, private keys, unredacted repository credentials, license data, hashes, and sensitive customer data out of the repo.
```

