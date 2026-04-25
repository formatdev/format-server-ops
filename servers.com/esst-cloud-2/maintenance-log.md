# esst-cloud-2 Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker maintenance, and reboot decisions for `esst-cloud-2`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-19 - Local SSH Alias And Key Prepared

Date: 2026-04-19

Maintainer: Codex with Peter

Host before:

- Local SSH alias was not present.
- Local per-host key was not present.

Host after:

- Provider private key validates locally with `ssh-keygen -y`.
- Local SSH alias `esst-cloud-2` points to `cloud-user@188.42.62.39`.
- Local SSH alias uses `~/.ssh/esst-cloud-2`.

Checks:

- SSH checked: Not yet reachable from this workstation. Port 22 connection timed
  out during a non-interactive probe. TCP/22 also timed out from `esst-cloud-1`
  to private IP `192.168.0.5`, although ICMP ping works.
- Notes: The timeout likely indicates host firewall policy, provider firewall,
  SSH listening on a different port/interface, or sshd not running.
- Follow-up: Use servers.com console or Swarm manager access to confirm SSH
  service and firewall state.

## 2026-04-25 - Duplicati EC2 Backup Stack Prepared

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- No active `duplicati-ec2` Swarm stack was present.
- `/data` was 88% used, with about 46G under the monitoring application's
  local database backup folder.

Host after:

- Prepared Swarm stack `duplicati-ec2`, pinned to `esst-cloud-2`.
- Verified SFTP write/list/delete to NAS4 folder
  `/ESSTBF/duplicati/esst-cloud-2` as user `eSSTBU`.
- Created Duplicati job `esst-cloud-2 to NAS4`, scheduled daily at `20:30 UTC`.
- Configured retention policy `7D:1D,4W:1W,12M:1M`.
- Excluded the monitoring local database backup archive folder, Redis,
  resources, runtime, pre-existing stale Duplicati data, and generic cache/tmp
  paths. Included the monitoring storage logs folder after checking it was about
  548M.
- Added Cloudflare DNS and Access protection for `duplicati-ec2.esst.lu`.

Checks:

- SSH checked: OK as `cloud-user`.
- Disk checked: `/dev/vda1` 170G total, 142G used, 21G available before first
  EC2 backup.
- Docker checked: CLI-created `duplicati-ec2_duplicati_ec2` was tested on
  `esst-cloud-2`, then removed so Peter can recreate it as a Portainer-managed
  stack. The Docker volume `duplicati-ec2_duplicati_ec2_data` was kept.
- SFTP checked: OK to NAS4 through `217.31.68.238`.
- Cloudflare Access checked: `duplicati-ec2.esst.lu` redirects to Cloudflare
  Access login.
- Notes: The first full backup has not been run from this log entry. Expect a
  large initial upload because monitoring uploads currently occupy about 84G.
- Follow-up: Recreate stack `duplicati-ec2` in Portainer using the prepared
  stack file, then run the first EC2 backup during an acceptable window and
  monitor local disk/NAS growth.

## 2026-04-25 - Monitoring Database Backup Retention

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- Monitoring database backup folder was about 46G.
- The folder contained twice-daily `.sql.zip` backups back to 2026-04-06 and
  one stray uncompressed 13G `.sql` file from 2026-04-20.

Host after:

- Copied the 13G uncompressed SQL file to NAS4 root:
  `/ESSTBF/2026-04-20_12:18__36a92ae9-e089-4da2-be16-91b69aef68ec.sql`.
- Verified local and NAS file sizes match: `13157483642` bytes.
- Added root cron to prune monitoring database `.sql.zip` backups older than
  14 days:
  `/opt/esst/maintenance/prune-monitoring-db-backups.sh`.
- Ran pruning once manually; old zip backup count is now `0`.

Checks:

- Backup folder checked: about 38G after pruning.
- Remaining backup files: 30 `.sql.zip` files and the copied-but-not-removed
  local 13G `.sql` file.
- Notes: The app includes `php artisan util:db:cleanup-backups`, but the running
  container reported the cached default retention `< 15 days ago`. The cron uses
  explicit `find ... -mtime +14`, which matches the accepted `< 15 days ago`
  retention behavior for these file timestamps.
- Removed stale local `/data/files/duplicati` folder after confirming it held old
  2024 Duplicati metadata, not the active EC2 Duplicati volume.
- Confirmed `/ESSTBF/duplicati/old.esst-cloud-1` exists on NAS4 as an old
  application-data archive with `esst` and `format` subfolders, not as a direct
  copy of the stale local Duplicati metadata folder.
- Removed the local 13G uncompressed `.sql` file after verifying the NAS4 copy.
- Disk checked after cleanup: `/dev/vda1` 170G total, 122G used, 41G available.
- Backup folder checked after cleanup: about 26G.
- Follow-up: Monitor the next scheduled cleanup log at
  `/data/files/esst/monitoring/production/storage/database/cleanup-backups.log`.

## 2026-04-25 - EC2 Duplicati Reset With App DB Dumps Included

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- `duplicati-ec2` excluded the app-generated monitoring database dump folder.
- NAS4 folder `/ESSTBF/duplicati/esst-cloud-2` contained the previous Duplicati
  backup set.

Host after:

- Confirmed EC2 Duplicati now includes
  `/source-data/files/esst/monitoring/production/storage/database/backups/`.
- Confirmed EC2 Duplicati excludes `/source-data/redis/`.
- Removed the previous NAS4 EC2 Duplicati target files.
- Removed the stale local EC2 Duplicati job database so the next run rebuilds a
  fresh remote set.
- Started a new initial EC2 backup run.

Checks:

- NAS4 checked before cleanup: 1519 Duplicati files, about 37G.
- NAS4 checked after cleanup: 0 Duplicati files.
- NAS4 upload checked after restart: files are being created again.
- Notes: The app-generated dumps are still pruned locally with the 14 day cron.
- Follow-up: Verify the initial EC2 backup finishes successfully.

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
