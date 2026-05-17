# format-cloud-1 Host Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker Engine maintenance, and reboot decisions for `format-cloud-1`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-05-16 - Monthly Host Maintenance

Date: 2026-05-16

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Previously installed but not yet booted kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Portainer: `2.41.0`
- Root filesystem was about 32% used.
- Swarm was healthy before maintenance; all services were `1/1`.
- Pending apt work included `distro-info-data`, Docker Engine `29.5.0`
  packages, `open-vm-tools`, and a kept-back `linux-image-virtual` upgrade.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Portainer: `2.41.0`
- Root filesystem remained about 32% used.
- Uptime at verification: about 7 minutes.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` worked before and after reboot.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`,
  `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. `systemctl --failed` reported 0 failed units
  after maintenance.
- Disk checked: OK. Root filesystem remained about 32% used.
- Memory checked: OK. About 13 GiB remained available after reboot.
- Docker Swarm checked: OK. Single node remained `active/true` and all
  services converged back to `1/1`.
- Docker services checked: OK. Docker daemon restart briefly recycled Swarm
  tasks during package maintenance and reboot; all services recovered.
- Container health checked: OK. `database-1_db` and `vaultwarden_server`
  reported healthy; no containers remained down after convergence.
- Portainer checked: OK. `portainer_portainer` and `portainer_agent` returned
  to `1/1` on `2.41.0`.
- HTTPS routing checked: OK. Direct local `https://127.0.0.1` returned
  HTTP `404`, which is consistent with Traefik host-header routing on the raw
  host endpoint. Public smoke checks then returned `200` for
  `bitwarden.format.lu`, `200` for `floc.lu`, `302` for
  `portainer.format.lu` through Cloudflare Access, `302` for
  `chargy.format.lu` to `/auth/login`, and `302` for `ts.format.lu`
  through Cloudflare Access.
- Public port exposure checked: Not re-run externally during this pass.
- Apt upgrade applied: Yes. Ran `apt-get update`, `apt-get upgrade`, and
  `apt-get full-upgrade`.
- Remaining apt upgrades checked: OK. No packages remained upgradable after the
  maintenance pass.
- Reboot requirement checked: OK. No reboot required after reboot.

Notes:

- This pass intentionally used `full-upgrade` so the host could move directly
  from the running `6.8.0-110-generic` kernel to `6.8.0-117-generic` in a
  single reboot instead of first booting the previously installed `111` kernel.
- Docker package maintenance restarted the daemon and caused the expected brief
  interruption on this single-node Swarm host.
- `vaultwarden_server` and `database-1_db` were the last services to settle
  after reboot; both reached healthy `1/1` status.
- Public app smoke checks were run after the push to GitHub and matched the
  expected production behavior.

Follow-up:

- Keep the known Traefik host-header behavior in mind when checking the raw
  host endpoint; app-specific validation should continue to use the routed
  public hostnames.

## 2026-05-03 - Bi-Monthly Host Maintenance

Date: 2026-05-03 08:37 CEST

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.0`
- Portainer: `2.39.1 LTS`
- Docker Swarm was healthy before maintenance; all services were `1/1`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.2`
- Portainer: `2.39.1 LTS`
- Root filesystem remained about 32% used.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` worked.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`,
  `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. No failed systemd units before or after package
  maintenance.
- Disk checked: OK. Root filesystem remained about 32% used.
- Memory checked: OK. Load and free memory remained within normal range during
  the maintenance pass.
- Docker Swarm checked: OK. Single node remained `Ready`, `Active`, and
  `Leader`.
- Docker services checked: OK. Docker Engine restart briefly recycled Swarm
  tasks during package maintenance, then all services reconverged to `1/1`.
- Container health checked: OK. `vaultwarden_server`, `portainer_portainer`,
  `portainer_agent`, and `traefik_traefik` were healthy after convergence.
- Portainer checked: OK. Public endpoint still redirected through Cloudflare
  Access and the Portainer service stayed `1/1`.
- HTTPS routing checked: OK. Public checks returned `200` for
  `bitwarden.format.lu`, `200` for `floc.lu`, `302` for
  `portainer.format.lu`, `302` for `chargy.format.lu`, and `302` for
  `ts.format.lu`.
- Public port exposure checked: Not re-run from a port-scan perspective during
  this pass; host firewall intent and public app checks matched the expected
  production shape.
- Apt upgrade applied: Yes. `apt-get upgrade -y` upgraded Docker Engine to
  `29.4.2` plus `iproute2`, `linux-firmware`, and `ubuntu-pro-client`
  packages.
- Remaining apt upgrades checked: Partial. `linux-image-virtual` remained
  listed as upgradable because it was kept back by `apt upgrade`.
- Reboot requirement checked: OK. `/var/run/reboot-required` was absent after
  the applied upgrade set.

Notes:

- This pass intentionally used `apt upgrade`, matching the runbook's standard
  host update flow. It did not perform `full-upgrade`, install the kept-back
  kernel meta-package, or reboot the single-node Swarm host.
- Docker package maintenance caused a brief rolling interruption while the
  daemon restarted and Swarm tasks reconverged.
- Traefik logs still show the known `api is not enabled` dashboard-router
  mismatch.
- Vaultwarden logs still show the expected notice that `config.json` overrides
  `DOMAIN`, `SIGNUPS_ALLOWED`, and `ADMIN_TOKEN`.

Follow-up:

- Decide whether to schedule a separate controlled kernel maintenance window for
  `linux-image-virtual`, which would require a host reboot and brief outage on
  this single-node Swarm host.
- Keep the existing Traefik dashboard-router mismatch on the backlog unless a
  separate cleanup window is opened.

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
