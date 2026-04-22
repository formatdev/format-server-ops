# format-cloud-1 Host Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker Engine maintenance, and reboot decisions for `format-cloud-1`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-18 - Post-Reboot Verification

Date: 2026-04-18 19:54 CEST

Maintainer: Codex with Peter

Host before:

- Expected pending follow-up from earlier maintenance: controlled reboot to boot
  into `6.8.0-110-generic`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.0`
- Portainer: `2.39.1 LTS`
- Uptime at first post-reboot check: about 1 minute

Checks:

- SSH checked: OK. Key-only login remains enforced.
- Firewall checked: OK. `ufw` is active with inbound rules limited to SSH and
  HTTPS/HTTP3.
- Fail2ban checked: OK. `sshd` jail is active.
- System health checked: OK. No failed systemd units.
- Disk checked: OK. Root filesystem is 32% used.
- Memory checked: OK. About 13 GiB available after reboot.
- Docker Swarm checked: OK. Single node is `Ready`, `Active`, and `Leader`.
- Docker services checked: OK. All Swarm services converged to `1/1`.
- Container health checked: OK. No unhealthy containers reported.
- Portainer checked: OK. Server and agent are both `1/1` on `2.39.1`.
- HTTPS routing checked: OK. Direct checks returned `200` for `floc.lu`, `302`
  for `chargy.format.lu`, `302` for `portainer.format.lu`, `200` for
  `bitwarden.format.lu`, and `302` for `ts.format.lu`.
- Public port exposure checked: OK. `22/tcp` and `443/tcp` are reachable;
  `2377/tcp` and `7946/tcp` timed out externally.
- Apt upgrade applied: No. Verification only.
- Remaining apt upgrades checked: OK. No packages listed as upgradable.
- Reboot requirement checked: OK. `/var/run/reboot-required` is absent.
- Notes: The host had already rebooted before this verification began; no reboot
  command was issued during this run. Swarm task history shows transient
  Portainer task failures during startup, but current desired tasks are running.
- Follow-up: Continue with normal stack-specific maintenance and review the
  previously noted registry access issue for `esst/format-timesheet-reports`
  before future redeploys.

## 2026-04-18 - Host Health Check And Package Upgrade

Date: 2026-04-18

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Kernel: `6.8.0-107-generic`
- Docker Engine: `29.3.1`
- Portainer: `2.39.1 LTS`

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-107-generic`
- Installed pending kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.0`
- Portainer: `2.39.1 LTS`

Checks:

- SSH checked: OK. Key-only login is still enforced.
- Firewall checked: OK. `ufw` is active; public inbound rules remain limited to SSH and HTTPS/HTTP3.
- Fail2ban checked: OK. `sshd` jail is active.
- System health checked: OK. No failed systemd units.
- Disk checked: OK. Root filesystem is 32% used.
- Memory checked: OK. About 12 GiB available after maintenance.
- Docker Swarm checked: OK. Single node is `Ready`, `Active`, and `Leader`.
- Docker services checked: OK. All Swarm services converged to `1/1`.
- Container health checked: OK. No unhealthy containers reported.
- Portainer checked: OK. Server and agent are both `1/1`.
- HTTPS routing checked: OK. Direct Traefik checks returned `200` for `floc.lu`, `302` for `chargy.format.lu`, and `200` for `portainer.format.lu`.
- Public port exposure checked: OK. `22/tcp` and `443/tcp` are reachable; `2377/tcp` and `7946/tcp` are blocked externally.
- Apt upgrade applied: Yes. Upgraded 22 packages including Docker, containerd, systemd, AppArmor, snapd, rsyslog, linux firmware, and related libraries.
- Remaining apt upgrades checked: OK. No packages remain upgradable.
- Reboot requirement checked: Reboot required. `/var/run/reboot-required.pkgs` lists `linux-image-6.8.0-110-generic` and `linux-base`.

Notes:

- Docker package maintenance briefly recycled Swarm tasks; all services reconverged.
- `vaultwarden_server` temporarily showed `0/1` while its new task was starting, then became healthy.
- Docker journal showed a transient pull-denied message for `esst/format-timesheet-reports`; the service is running `1/1`, but registry access should be reviewed before future redeploys.

Follow-up:

- Schedule a controlled reboot to boot into `6.8.0-110-generic`.
- After reboot, rerun the host health check and verify all Swarm services are `1/1`.

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
- Docker Swarm checked:
- Docker services checked:
- Container health checked:
- Portainer checked:
- HTTPS routing checked:
- Public port exposure checked:
- Apt upgrade applied:
- Remaining apt upgrades checked:
- Reboot requirement checked:
- Notes:
- Follow-up:
