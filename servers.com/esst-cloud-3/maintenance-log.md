# esst-cloud-3 Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker maintenance, and reboot decisions for `esst-cloud-3`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-25 - Duplicati EC3 Preparation

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- `esst-cloud-3` holds the production monitoring MariaDB service.
- No Portainer-managed Duplicati stack was present for this node.

Host after:

- Prepared `duplicati-ec3` stack definition for a node-local Duplicati service.
- Prepared logical MariaDB all-database dump script with 14 day local retention.
- Adjusted normal database dump to exclude `monitoring.audit_trail_entry`,
  `monitoring.activity_log`, and `monitoring.failed_jobs`.
- Prepared optional latest-only heavy table dump script for those tables.
- Disabled EC3 database dump scheduling after deciding that EC2 app-generated
  monitoring dumps are the backup source for the `monitoring` database.
- Removed EC3 local monitoring dump staging files.
- Backup design excludes the live MariaDB datadir and backs up dump files instead.

Checks:

- SFTP key copied to the node and verified against NAS4 `/ESSTBF/duplicati/esst-cloud-3`.
- MariaDB root credential file prepared as root-readable only on the node.
- MariaDB connection verified from the running container.
- Notes: The production monitoring database is backed up through the EC2
  app-generated dump folder. EC3 should not back up the live MariaDB datadir or
  scheduled `monitoring` database dumps.
- Follow-up: Deploy `duplicati-ec3` through Portainer, configure the Duplicati job, and run the first backup after EC2 finishes.

## 2026-04-19 - Local SSH Alias And Key Prepared

Date: 2026-04-19

Maintainer: Codex with Peter

Host before:

- Local SSH alias was not present.
- Local per-host key was not present.

Host after:

- Provider private key validates locally with `ssh-keygen -y`.
- Local SSH alias `esst-cloud-3` points to `cloud-user@188.42.62.60`.
- Local SSH alias uses `~/.ssh/esst-cloud-3`.

Checks:

- SSH checked: Not yet reachable from this workstation. Port 22 connection timed
  out during a non-interactive probe. TCP/22 also timed out from `esst-cloud-1`
  to private IP `192.168.0.20`, although ICMP ping works.
- Notes: The timeout likely indicates host firewall policy, provider firewall,
  SSH listening on a different port/interface, or sshd not running.
- Follow-up: Use servers.com console or Swarm manager access to confirm SSH
  service and firewall state.

## Maintenance Template

Date:

Maintainer:

Host before:

Host after:

Checks:

- SSH checked:
- Firewall checked:
- Fail2ban checked:
- System health checked:
- Disk checked:
- Memory checked:
- Docker checked:
- Public port exposure checked:
- Apt upgrade applied:
- Remaining apt upgrades checked:
- Reboot requirement checked:
- Notes:
- Follow-up:
