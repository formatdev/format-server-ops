# esst-cloud-1 Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker maintenance, and reboot decisions for `esst-cloud-1`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-25 - GlitchTip Hardened And Upgraded To 5.2.1

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- `esst-glitchtip_web`, `esst-glitchtip_worker`, and `esst-glitchtip_migrate`
  were running `glitchtip/glitchtip:v5.0.5`.
- Worker was attached to the `proxy` network even though it is not
  user-facing.
- Public host restrictions were not explicitly set in tracked config.
- User registration policy was commented out in the provided stack snippet.

Host after:

- GlitchTip app services updated to `glitchtip/glitchtip:v5.2.1`.
- Worker kept on the internal network only.
- Tracked stack baseline added under `glitchtip/` with secret placeholders.
- Public host hardening included in tracked config:
  `ALLOWED_HOSTS=glitchtip.esst.lu`,
  `CSRF_TRUSTED_ORIGINS=https://glitchtip.esst.lu`,
  `ENABLE_USER_REGISTRATION=false`.
- Manual `pgpartition --yes` run completed after the upgrade to create missing
  current-day partitions for event tables.

Checks:

- App version checked: OK.
- Logs checked: OK. Event ingestion continued after the upgrade and worker
  partition errors cleared after `pgpartition`.
- Config tracked in repo: OK.
- Notes: Redis remains on `6.2`; that is fine for GlitchTip 5.x but would need
  a planned upgrade before moving to GlitchTip 6.x.
- Follow-up: Use the tracked stack example as the baseline for the next planned
  maintenance window and prepare a dedicated Redis + worker-command migration
  for GlitchTip 6.x.

## 2026-04-19 - Provider SSH Key Restored And Baseline Checked

Date: 2026-04-19

Maintainer: Codex with Peter

Host before:

- Local SSH alias initially used a fresh key that had not been installed on the
  server.
- Provider private key file initially had invalid local formatting and could not
  be parsed by `ssh`.

Host after:

- Provider private key validates locally with `ssh-keygen -y`.
- Local SSH alias `esst-cloud-1` points to `cloud-user@188.42.62.40`.
- Local SSH alias uses `~/.ssh/esst-cloud-1`.
- OS: Ubuntu 24.04.3 LTS.
- Kernel: `6.8.0-110-generic`.
- Docker Engine: `29.1.3`.
- Docker Swarm state: active worker, not a manager.
- Root filesystem: 113G total, 106G used, 2.1G available, 99% used.
- Memory: 7.8Gi total, 4.6Gi available.
- Reboot requirement: none.

Checks:

- SSH checked: OK. Provider key login works as `cloud-user`.
- Sudo checked: OK. `cloud-user` has passwordless sudo.
- Firewall checked: `ufw` is inactive.
- System health checked: OK. No failed systemd units.
- Docker checked: OK. Containers are running. This host is a Swarm worker, so
  manager-only commands such as `docker stack ls` are not available here.
- Disk checked: Warning. Root filesystem is 99% used.
- Docker disk usage checked: Warning. Docker reports 46.29GB of images with
  12.8GB reclaimable, plus 7.084GB reclaimable stopped-container data.
- Private network checked: OK for ICMP to `192.168.0.5`, `192.168.0.20`, and
  `192.168.0.14`; TCP/22 to all three is closed or filtered from
  `esst-cloud-1`.
- Notes: The server explicitly rejects root SSH and instructs login as
  `cloud-user`.
- Follow-up: Prioritize disk cleanup planning before package upgrades. Identify
  the Swarm manager node before making stack changes.

## 2026-05-03 - Bi-Monthly Host Upgrade And Reboot

Date: 2026-05-03

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.1`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 51% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 49% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run. Prior notes still say `ufw` is inactive.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. No failed systemd units before or after.
- Disk checked: OK. Root filesystem remained healthy and slightly improved after maintenance.
- Memory checked: OK. About 6.4 GiB available after reboot.
- Docker checked: OK after reboot. Docker upgraded cleanly and local worker tasks recovered.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `iproute2`, `linux-firmware`, `ubuntu-pro-client`, and the `6.8.0-111` virtual kernel package set.
- Remaining apt upgrades checked: OK. No remaining upgradable packages were checked after the run, but the upgrade itself completed without held-back packages.
- Reboot requirement checked: Reboot required after package install; controlled reboot completed during this maintenance run.
- Notes: Immediately after the Docker package upgrade, several services pinned to `esst-cloud-1` failed with `network sandbox join failed ... error creating vxlan interface: file exists`, and the worker temporarily lost the `proxy` overlay network. Rebooting the host restored the overlay network and the affected services converged successfully.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-1`, but note that Vaultwarden still logs a plain-text `ADMIN_TOKEN` warning sourced from `data/config.json`.

## 2026-05-03 - Vaultwarden Upgrade And GlitchTip Upgrade Attempt

Date: 2026-05-03 09:46 CEST

Maintainer: Codex with Peter

Actions:

- Upgraded `esst-vaultwarden_bitwarden` from `vaultwarden/server:1.35.7` to
  `vaultwarden/server:1.35.8`.
- Verified the replacement task started successfully and reached a healthy
  container health state on `esst-cloud-1`.
- Attempted to upgrade `esst-glitchtip_*` services from
  `glitchtip/glitchtip:v5.2.1` to `glitchtip/glitchtip:v6.1.6`.

Result:

- Vaultwarden update completed successfully at the Swarm service level.
- The GlitchTip upgrade was blocked before migration execution because the
  worker could not pull `glitchtip/glitchtip:v6.1.6`; Docker returned
  `manifest unknown: manifest unknown`.
- Reverted the GlitchTip migration service back to the known-good
  `glitchtip/glitchtip:v5.2.1` image and confirmed the one-shot task completed.

Follow-up:

- Keep GlitchTip on `v5.2.1` until a pullable `6.x` image/tag is confirmed.
- Vaultwarden still warns that `ADMIN_TOKEN` is stored as plain text in
  `data/config.json`.

## 2026-05-16 - Monthly Host Upgrade And Reboot

Date: 2026-05-16

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 66% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 60% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem improved to about 60% used with about 44G free.
- Memory checked: OK. About 4.6 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.0`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `docker-buildx-plugin`, `open-vm-tools`, `distro-info-data`, and the `6.8.0-117` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: Worker maintenance completed without the earlier overlay-network issue seen on 2026-05-03.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-1`.

## 2026-05-31 - End-Of-Month Host Upgrade And Reboot

Date: 2026-05-31

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 96% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 94% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: Follow-up noted. Root filesystem remains tight at about 94% used with about 7.0G free, though slightly improved from before the upgrade.
- Memory checked: OK. About 5.0 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.2`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `snapd`, and the `6.8.0-124` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: Worker maintenance completed cleanly and the node rejoined Swarm without overlay or convergence issues.
- Follow-up: Plan a separate disk-usage cleanup review for `esst-cloud-1`; the host still has less free headroom than the rest of the fleet.

## 2026-06-10 - Database Backup Script Retention Fix

Date: 2026-06-10

Maintainer: Codex with Peter

Host before:

- `/data/backups/databases/backup-databases.sh` still used `set -euo pipefail`
  with retention pruning only at the end of the script.
- The `esst-vtiger_mysql` dump block was still present even though the related
  Swarm service is no longer deployed.
- Failed or interrupted dumps could leave behind incomplete `.sql.gz` files.
- A separate cleanup earlier in the day restored free space after GlitchTip
  logical backups filled the root filesystem.

Host after:

- The backup script now runs retention cleanup from a `trap prune EXIT`
  handler, so old dump cleanup still runs if one dump fails.
- The obsolete `vtiger` dump block and its local directory handling were
  removed.
- Database dumps now write to `.sql.gz.partial` and only move into place on
  success.
- The script now continues through the remaining dumps and returns non-zero only
  after all dump attempts finish.

Checks:

- SSH checked: OK. `cloud-user` key login worked during the fix.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. No host instability observed during the test run.
- Disk checked: OK. Root filesystem had healthy headroom at about 39% used
  after the earlier cleanup.
- Memory checked: Not specifically rechecked during this run.
- Docker checked: OK. Relevant `esst-glitchtip_postgres`,
  `esst-website_mariadb`, and `esst-website_wordpress` containers were present.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: No.
- Remaining apt upgrades checked: Not rechecked during this run.
- Reboot requirement checked: No reboot required.
- Notes: Deployed the patched script to the live host, kept a timestamped backup
  of the previous script, and ran a real backup pass successfully. The run
  produced a new `glitchtip-postgres` dump of about `732M` and a new
  `website-mariadb` dump of about `20M`, with no leftover `.partial` files.
  `pg_dumpall` emitted PostgreSQL collation version mismatch warnings for
  `postgres`, `template1`, and `glitchtip`, but the dump completed
  successfully.
- Follow-up: Plan a separate PostgreSQL collation maintenance task; it is not
  part of the backup-retention bug but should not be forgotten.

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
