# format-cloud-1 Host Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker Engine maintenance, and reboot decisions for `format-cloud-1`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-07-19 - Mid-Month Maintenance Round

Date: 2026-07-19

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Docker Engine: `29.6.1`
- Portainer: `2.43.0`
- Uptime: about 2 weeks, 15 hours, 49 minutes.
- Root filesystem: 150G total, 50G used, 95G free, 35% used.
- Memory: 15 GiB total, about 11 GiB available.
- Swarm was healthy before maintenance; all services were `1/1`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Docker Engine: `29.6.2`
- Portainer: `2.43.0`
- Root filesystem remained about 35% used.
- Memory after reboot: 15 GiB total, about 13 GiB available.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` worked through the configured alias before and after reboot.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`, `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active.
- System health checked: OK. `systemctl --failed` reported 0 failed units after maintenance.
- SSH hardening checked: OK. Password authentication remains disabled, public-key authentication remains enabled, and `MaxAuthTries` remains 3.
- Docker Swarm checked: OK. Single node is `Ready`, `Active`, and `Leader` on Engine `29.6.2`.
- Docker services checked: OK. All Swarm services reported `1/1` after package maintenance, reboot, and image updates.
- Container health checked: OK. No unhealthy containers were reported.
- Backups checked: OK. Daily MariaDB dump and Portainer archive cadence were current through `2026-07-18`.
- Apt upgrade applied: Yes. Applied Docker Engine `29.6.2`, `containerd.io` `2.2.6`, Docker Compose plugin `5.3.1`, `fwupd`, `apport`, `plymouth`, and related packages.
- Apt upgrades checked: OK. No package upgrades remained after maintenance.
- Reboot requirement checked: OK. Rebooted into `6.8.0-136-generic`; no reboot marker remained afterward.
- Stack updates applied: Yes. Traefik moved to `3.6.23`, and Duplicati moved to digest `sha256:01f8cb81ad7d548b7ceec61d696bb5d27d8057fee0ddee37c2b8a0ff1f1729f7`.
- Stack image metadata checked: OK. Key `com.docker.stack.image` labels matched live images after updates.
- Routed app smoke tests checked: OK. Local Traefik host-header checks returned `200` for `bitwarden.format.lu`, `floc.lu`, `portainer.format.lu`, `pma.format.lu`, and `duplicati-fc1.format.lu`; `chargy.format.lu` returned the expected `302` login redirect.

Notes:

- The first apt command continued in its SSH session after a second apt attempt saw the dpkg lock; it completed normally while updating initramfs.
- Docker package maintenance briefly recycled several tasks. Vaultwarden again needed extra health-check time after the Docker restart and host reboot; its route returned to `200`.
- Traefik update again hit the known single-node host-mode `443` replacement wait before converging cleanly.
- Traefik `3.6.x` has a newer patch, but the `3.6` line is no longer the actively supported feature line; keep a planned `3.7.x` migration on the roadmap instead of treating it as a blind patch bump.
- Redis 8 and custom `esst/*` application refreshes were not included in this host maintenance pass.

Follow-up:

- Plan a separate Traefik `3.7.x` review/migration.
- Continue avoiding Docker prune/cleanup unless bind mounts, volumes, and active service image references have been reviewed.

## 2026-07-04 - Inspection And Maintenance Round

Date: 2026-07-04

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Installed kernel package: `linux-image-virtual=6.8.0-134.134`
- Docker Engine: `29.5.3`
- Portainer: `2.42.0`
- Uptime: about 2 weeks, 5 days, 23 hours
- Root filesystem: 150G total, 49G used, 96G free, 34% used.
- Memory: 15 GiB total, about 11 GiB available.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Docker Engine: `29.6.1`
- Portainer: `2.43.0`
- Root filesystem: 150G total, 49G used, 96G free, 34% used.
- Memory: 15 GiB total, about 13 GiB available after reboot.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` worked through the configured alias.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`,
  `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active.
- System health checked: OK. `systemctl --failed` reported 0 failed units.
- SSH hardening checked: OK. Password authentication remains disabled,
  public-key authentication remains enabled, and `MaxAuthTries` remains 3.
- Docker Swarm checked: OK. Single node remains `Ready`, `Active`, and
  `Leader`.
- Docker services checked: OK. All Swarm services reported `1/1` after the Docker package restart, host reboot, and image updates.
- Container health checked: OK. No unhealthy containers were reported.
- Portainer checked: OK. `portainer_portainer` and `portainer_agent` are
  running on `2.43.0`.
- Public app smoke tests checked: OK. Local Traefik host-header checks returned
  `200` for `bitwarden.format.lu`, `floc.lu`, `portainer.format.lu`,
  `pma.format.lu`, and `duplicati-fc1.format.lu`; `chargy.format.lu`
  returned the expected `302` login redirect.
- Apt upgrades checked: OK. No package upgrades remained after maintenance.
- Apt upgrade applied: Yes. Applied Docker Engine `29.6.1`,
  `containerd.io` `2.2.5`, Docker Buildx `0.35.0`, Docker Compose plugin
  `5.3.0`, `iproute2`, `kpartx`, `multipath-tools`, and `qemu-guest-agent`.
- Reboot requirement checked: OK. Rebooted into `6.8.0-134-generic`; no
  reboot marker remained afterward.
- Stack updates applied: Yes. Portainer moved to `2.43.0`, Traefik moved to
  `3.6.22`, and Vaultwarden stack image metadata was reconciled to `1.36.0`.
- Backups checked: OK. Fresh Portainer archive
  `/data/backups/portainer/portainer-data-20260704-155126.tar.gz` was created
  before the Portainer update. Daily MariaDB dumps were current through
  `2026-07-03`.

Notes:

- Docker package maintenance briefly left several overlay-network services
  rejecting tasks with `vxlan interface: file exists`; the required reboot
  cleared the condition.
- Vaultwarden briefly returned `404` immediately after reboot while Traefik was
  resyncing provider state; repeated checks returned `200` after the service
  became healthy.
- Traefik showed the familiar startup-only missing middleware lines during the
  replacement task; a fresh post-convergence error sample was quiet.
- Traefik update again hit the known single-node host-mode `443` replacement
  wait before converging cleanly.
- Live Chargy Redis service image tags currently show `redis:7.4-alpine3.21`
  while the app runbooks still mention `redis:7.4.8-alpine3.21`; reconcile
  during the next Redis/app-specific pass.
- `docker system df` was not pruned during this round.

Follow-up:

- Continue avoiding Docker prune/cleanup unless bind mounts, volumes, and
  active service image references have been reviewed.
- Keep Redis 8 and custom `esst/*` application refreshes as separate planned
  work.

## 2026-06-14 - Mid-Month Host Maintenance

Date: 2026-06-14

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Portainer: `2.41.1`
- Root filesystem was about 33% used.
- Swarm was healthy before maintenance; all services were `1/1`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Portainer: `2.42.0`
- Root filesystem remained about 33% used.
- Uptime at verification: freshly rebooted during the package maintenance pass.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` returned cleanly after the reboot.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`, `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. `systemctl --failed` reported 0 failed units after maintenance.
- Docker Swarm checked: OK. Single node remained `active/true` and all services converged to `1/1`.
- Container health checked: OK. No unhealthy containers were reported after convergence.
- Backups checked: OK. Fresh Portainer archive `/data/backups/portainer/portainer-data-20260614-161347.tar.gz` and MariaDB dump `/data/backups/mysql/mariadb-all-databases-2026-06-14-161556.sql.gz` were created before service updates.
- Apt upgrade applied: Yes. Docker Engine moved to `29.5.3`; `fwupd`, AppArmor, cloud-init, firmware, and related libraries were also updated.
- Reboot requirement checked: OK. No `/var/run/reboot-required` marker remained after the host came back.
- Stack updates applied: Yes. Portainer moved to `2.42.0`, Traefik to `3.6.21`, MariaDB to `11.8.8`, and Duplicati to digest `sha256:50555cd2cf1cd140ee240996cc3b94afb0254d07f6bccc5495561530a6c3d6ab`.
- Stack image metadata checked: OK. Reconciled stale `com.docker.stack.image` labels for Portainer, Traefik, MariaDB, and Duplicati.
- Routed app smoke tests checked: OK. Local Traefik host-header probes returned expected responses for Vaultwarden, FLOC, Portainer, Chargy, phpMyAdmin, and Duplicati.

Notes:

- The host rebooted during package maintenance; no reboot marker was present afterward and services recovered cleanly.
- Reconciling stale stack image labels caused a brief Swarm recycle for the affected services; all returned to `1/1`.
- Public hostname checks mostly hit Cloudflare Access/challenge behavior, so final backend health was verified with local Traefik host-header probes.
- Redis was intentionally left on the current `7.4.8` line rather than jumping to Redis 8 during routine maintenance.

Follow-up:

- Keep custom `esst/*` application image refreshes as separate app maintenance work.

## 2026-05-31 - End-Of-Month Host Maintenance

Date: 2026-05-31

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Portainer: `2.41.0`
- Root filesystem was about 33% used.
- Swarm was healthy before maintenance; all services were `1/1`.
- Pending apt work included `containerd.io`, Docker Engine `29.5.2`
  packages, `docker-compose-plugin`, `docker-buildx-plugin`, `snapd`, and a
  kept-back `linux-image-virtual` upgrade.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Portainer: `2.41.0`
- Root filesystem remained about 33% used.
- Uptime at verification: about 1 minute.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` worked before reboot and returned
  cleanly after reboot.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`,
  `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. `systemctl --failed` reported 0 failed units
  after maintenance.
- Disk checked: OK. Root filesystem remained about 33% used.
- Memory checked: OK. About 11 GiB was available at the discovery pass and
  about 13 GiB after reboot.
- Docker Swarm checked: OK. Single node remained `active/true` and all
  services converged back to `1/1`.
- Docker services checked: OK. Docker and containerd package maintenance
  briefly recycled Swarm tasks during package maintenance and reboot; all
  services recovered.
- Container health checked: OK. `database-1_db` and `vaultwarden_server`
  reported healthy after convergence.
- Portainer checked: OK. `portainer_portainer` and `portainer_agent` returned
  to `1/1` on `2.41.0`.
- HTTPS routing checked: OK. Direct local `https://127.0.0.1` returned
  HTTP `404`, which is consistent with Traefik host-header routing on the raw
  host endpoint. Public smoke checks returned `200` for
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

- This pass updated Docker Engine to `29.5.2`, `containerd.io` to `2.2.4`,
  `docker-compose-plugin` to `5.1.4`, and `snapd` to `2.75.2+ubuntu24.04`.
- `vaultwarden_server` was again the slowest service to settle after reboot,
  but it returned to healthy `1/1` without intervention.
- Public app smoke checks matched the expected production behavior after the
  host recovered.

Follow-up:

- Keep the known Traefik host-header behavior in mind when checking the raw
  host endpoint; app-specific validation should continue to use the routed
  public hostnames.

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
