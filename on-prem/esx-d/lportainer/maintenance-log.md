# LPORTAINER Maintenance Log

## 2026-04-18 - Health Check And Cleanup Assessment

Maintainer: Codex with Peter

Checks:

- SSH checked: `lportainer` returned `lportainer`.
- Uptime checked: up 13 days, 12 hours; load around 0.01.
- Disk space checked: root `/` 24 GB used of 117 GB; `/var/lib/docker` 5.3 GB used of 236 GB.
- Docker checked: running containers included Portainer, Traefik, Paperless stacks, Redis/Postgres/Tika/Gotenberg helpers, and `whoami`.
- Compose stacks checked: `paperless`, `paperless-ai`, `paperless-core`, `paperless-pcz`, `paperless-pcz-gpt`, and `traefik` running.
- Docker disk checked: images 16.75 GB total with 16.32 GB reclaimable; volumes 5.494 GB total with 0 reclaimable.
- Package updates checked: updates available for Docker packages, containerd, systemd, apparmor, rsyslog, snapd, udev, and related packages.
- Journal usage checked: about 41 MB.
- File cleanup attempted: apt cache measured about 121 MB and apt lists about 238 MB; `sudo apt-get clean` was not run because sudo requires an interactive password.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- Docker prune was not run.
- No containers, images, volumes, compose files, or app data were changed.

Follow-up:

- Decide whether to update Docker/systemd packages in a maintenance window, since these may restart services or require a reboot.
- Consider Docker image prune only after confirming the reclaimable images are not needed for rollback.

## 2026-05-03 - Bi-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH checked: `lportainer` returned `lportainer`.
- Uptime checked: up about 9 days 22 hours; load near idle.
- Disk space checked: `/` about 85 GB free of 117 GB; `/var/lib/docker` about 219 GB free of 236 GB.
- Docker checked: application and helper containers were running, including `portainer`, `traefik`, `paperless`, `paperless-pcz`, `paperless-pcz-gpt`, `paperless-ollama`, Postgres, Redis, Gotenberg, Tika, and `whoami`.
- Compose stacks checked: `paperless`, `paperless-ai`, `paperless-core`, `paperless-pcz`, `paperless-pcz-gpt`, and `traefik` all showed `running`.
- Package updates checked: upgradable packages currently include `docker-ce`, `docker-ce-cli`, `docker-ce-rootless-extras`, `iproute2`, `linux-firmware`, `linux-generic`, `linux-headers-generic`, `linux-image-generic`, `linux-libc-dev`, `linux-tools-common`, and `thermald`.
- Docker image inventory checked: largest local images still include `ollama/ollama` about 9.7 GB, `gotenberg/gotenberg` about 2.71 GB, and `ghcr.io/paperless-ngx/paperless-ngx` about 2.04 GB.
- Journal usage checked: about 73.6 MB.
- Updates installed by Codex: No.
- Reboot required: Not checked.

Notes:

- `sudo -n true` still failed, so no package install or `apt-get clean` action was attempted.
- No containers, compose files, images, volumes, or application data were changed.

Follow-up:

- Plan Docker and kernel package updates in a maintenance window because they may restart services and likely require a reboot.
- Re-check whether a noninteractive approved sudo path exists before the next Linux package-maintenance pass.

## 2026-05-03 - Package Update Completed

Maintainer: Codex with Peter

Scope:

- Apply the pending Linux and Docker package updates on `lportainer` after Peter temporarily enabled passwordless sudo for the maintenance session.

Checks and actions:

- Refreshed apt metadata with `apt-get update`.
- Simulated the upgrade with `apt-get -s dist-upgrade` before installing.
- Installed updates with `DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade`.
- Upgraded packages included:
  - `docker-ce`, `docker-ce-cli`, `docker-ce-rootless-extras`
  - `iproute2`
  - `linux-firmware`
  - `linux-generic`, `linux-headers-generic`, `linux-image-generic`
  - `linux-libc-dev`, `linux-tools-common`
  - `thermald`
- New kernel payload installed: `6.8.0-111` package set.
- Cleared apt package cache with `apt-get clean`.

Post-checks:

- Running kernel remains `6.8.0-110-generic` until reboot.
- Reboot flag present: `/var/run/reboot-required`.
- Docker package version now `5:29.4.2-2~ubuntu.24.04~noble`.
- All containers were up after the upgrade; `docker ps` and `docker compose ls` both looked healthy.
- `needrestart` reported no containers needing restart.
- Disk space after update: `/` about 84 GB free of 117 GB; `/var/lib/docker` about 219 GB free of 236 GB.
- Apt cache after cleanup: `/var/cache/apt/archives` about 8 KB; apt lists about 240 MB.

Notes:

- Container uptime counters reset during the Docker package update, which is expected after a Docker daemon restart.
- No Docker prune, image deletion, volume deletion, or compose-file change was performed.

Follow-up:

- Reboot `lportainer` in an approved window to boot the `6.8.0-111-generic` kernel.
- After reboot, re-check `uname -r`, `docker ps`, `docker compose ls`, and Portainer access.

## 2026-05-03 - Portainer STS Pin And Upgrade

Maintainer: Codex with Peter

Scope:

- Replace the standalone `portainer/portainer-ce:latest` container on `lportainer` with the repo-aligned `2.41.0 STS` pin.

Checks and actions:

- Current container shape inspected before change:
  - image: `portainer/portainer-ce:latest`
  - name: `portainer`
  - restart policy: `always`
  - published ports: `8000:8000`, `9443:9443`
  - mounts: `portainer_data:/data` and `/var/run/docker.sock:/var/run/docker.sock`
- Manual backup created before the upgrade:
  - `/data/backups/portainer/portainer-data-manual-20260503-151543Z.tar.gz`
- Pulled target image: `portainer/portainer-ce:2.41.0@sha256:7e859a1d90eaf96b1d934ffd42972cb337747e31ff4e1fac934869d842c10151`
- Recreated the container with the same ports, mounts, and restart policy, pinned to `2.41.0`.

Post-checks:

- Container health checked: OK. `docker ps` shows `portainer` running on `portainer/portainer-ce:2.41.0`.
- Local HTTPS check: OK. `curl -k -I https://127.0.0.1:9443` returned `HTTP/1.1 200 OK`.
- Startup logs checked: OK. Portainer started successfully on `2.41.0`.
- Database migration checked: OK. Portainer migrated its data from `2.39.1` to `2.41.0`.
- Existing data volume checked: OK. `portainer_data` was reused; no new volume was created.

Notes:

- Portainer logs still report that `/run/secrets/portainer` is not present and it is proceeding without an encryption key; this matches the prior behavior and was not changed in this maintenance step.
- This brings `lportainer` in line with the externally documented Portainer `2.41.0 STS` pattern in the repo.
- No Docker prune, image deletion, volume deletion, or compose-stack change was performed.

Follow-up:

- Verify Portainer browser login and endpoint inventory from the UI after the STS upgrade.
- Keep the manual backup archive until the upgraded UI has been checked and the host reboot is complete.

## 2026-05-16 - Twice-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH checked: OK. `lportainer` reachable again; uptime about 1 week 5 days before this package pass.
- Docker checked: upgraded from `29.4.2` to `29.5.0`; `docker --version` now reports `Docker version 29.5.0, build 98f1464`.
- Portainer checked: container remained on `portainer/portainer-ce:2.41.0`.
- Compose stacks checked: `paperless`, `paperless-ai`, `paperless-core`, `paperless-pcz`, `paperless-pcz-gpt`, and `traefik` all came back `running` after the Docker package restart.
- Disk space checked: no storage pressure issue surfaced in this pass.
- Backups checked: no new backup action was taken in this pass.
- Updates installed: Yes. Installed `docker-buildx-plugin`, `docker-ce`, `docker-ce-cli`, `docker-ce-rootless-extras`, and `open-vm-tools`.
- Reboot required: No reboot flag remained after the package update.
- Notes: Docker package restart reset container uptime counters, but all expected containers came back. After maintenance, `apt list --upgradable` returned no remaining package lines, and the temporary sudo override `/etc/sudoers.d/90-codex-maint` was removed.
- Follow-up: do a light browser smoke check on Portainer/Paperless/Traefik during the next interactive pass and keep an eye on Docker package cadence, since the host picked up another minor Docker wave only 13 days after the prior update.

## 2026-05-17 - Stack Image Refresh And Pinning

Maintainer: Codex with Peter

Scope:

- Refresh the active Lportainer application stack images and replace floating tags with explicit version pins where approved.

Checks and actions:

- Exported and backed up the active stack definitions before change:
  - backup directory: `/home/peter/codex-stack-backup-20260517-123512Z`
  - working directory: `/home/peter/codex-stack-update-20260517-123512Z`
- Patched stack definitions to explicit pins:
  - `paperless` -> `ghcr.io/paperless-ngx/paperless-ngx:2.20.15`
  - `paperless-pcz` -> `ghcr.io/paperless-ngx/paperless-ngx:2.20.15`
  - `paperless-core` -> `gotenberg/gotenberg:8.32.0` and `apache/tika:3.2.3.0`
  - `paperless-ai` -> `ollama/ollama:0.23.1`
  - `traefik` -> `traefik:3.7.0`
- Left `paperless-pcz-gpt` on `icereed/paperless-gpt:latest`, but pulled and recreated the container to refresh the current latest image.
- Redeployed stacks one by one rather than as one broad restart:
  - `paperless`
  - `paperless-pcz`
  - `paperless-core`
  - `paperless-ai`
  - `paperless-pcz-gpt`
  - `traefik`

Post-checks:

- `docker compose ls`: all expected projects returned `running`.
- `docker ps`: all expected containers returned `Up`.
- `paperless`: healthy on `2.20.15`.
- `paperless-pcz`: healthy on `2.20.15`.
- `paperless-core-gotenberg`: running `8.32.0`.
- `paperless-core-tika`: running `apache/tika:3.2.3.0`.
- `paperless-ollama`: running `ollama/ollama:0.23.1`; in-container `ollama --version` returned `0.23.1`.
- `traefik`: running `traefik:3.7.0` with OCI version label `v3.7.0`.
- `portainer`: unchanged and still healthy on `portainer/portainer-ce:2.41.0`.

Notes:

- The first broad attempt earlier in the day did not stick and the host returned to the prior known-good image set; the successful pass above was done stack by stack with backups retained.
- Portainer-managed stack definitions were updated inside the `portainer_data` volume and the active Traefik compose file was updated at `/home/peter/stacks/traefik/docker-compose.yml`.
- No Docker prune, image deletion, volume deletion, or Portainer data reset was performed.

Follow-up:

- Open the Portainer and Paperless UIs once from a browser for a quick human smoke test after the image refresh.
- Keep the backup and working directories until the refreshed stacks have had a normal business-day soak.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH checked:
- Docker checked:
- Portainer checked:
- Compose stacks checked:
- Disk space checked:
- Backups checked:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
