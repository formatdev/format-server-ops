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

## 2026-05-03 - Bi-Monthly Host Upgrade And Reboot

Date: 2026-05-03

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.1`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 77% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: unchanged at about 77% used during this run

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. No failed systemd units before or after.
- Disk checked: OK. Root filesystem stayed at about 77% used with about 40G free.
- Memory checked: OK before maintenance. About 12 GiB available.
- Docker checked: OK. Docker upgraded to `29.4.2` and the node-local Duplicati service plus Swarm agent converged after reboot.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `iproute2`, `linux-firmware`, `ubuntu-pro-client`, and the `6.8.0-111` virtual kernel package set.
- Remaining apt upgrades checked: Upgrade completed without leftover packages being called out.
- Reboot requirement checked: Reboot required after package install; controlled reboot completed during this maintenance run.
- Notes: The manager reported `esst-cloud-2` down briefly during reboot, then back to `Ready`. Watched services remained healthy at `1/1`.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-2`.

## 2026-05-16 - Monthly Host Upgrade And Reboot

Date: 2026-05-16

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 78% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` remained about 78% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained at about 78% used with about 37G free.
- Memory checked: OK. About 13 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.0`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `docker-buildx-plugin`, `open-vm-tools`, `distro-info-data`, and the `6.8.0-117` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: `esst-cloud-2` took a little longer to return on SSH than the other workers, but rejoined the Swarm normally and came back on `29.5.0`.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-2`.

## 2026-05-31 - End-Of-Month Host Upgrade And Reboot

Date: 2026-05-31

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 81% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` remained about 81% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained at about 81% used with about 32G free.
- Memory checked: OK. About 13 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.2`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `snapd`, and the `6.8.0-124` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: `esst-cloud-2` returned normally this time without the slightly longer SSH delay seen during the previous monthly cycle.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-2`.

## 2026-06-14 - Twice-Monthly Host Upgrade And Reboot

Date: 2026-06-14

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 84% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 84% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: Follow-up noted. Root filesystem remains the tightest in the fleet at about 84% used with about 28G free.
- Memory checked: OK. About 13 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.3` and the node returned to Swarm as `Ready`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `apparmor`, `cloud-init`, `libapparmor1`, `libjcat1`, and `libxmlb2`.
- Remaining apt upgrades checked: `fwupd` remained held back.
- Reboot requirement checked: Reboot required after package install due to `apparmor`; controlled reboot completed during this maintenance run.
- Notes: `needrestart` reported that no containers required restart during package installation. `apparmor` emitted the same post-install warning seen on the other ESST hosts: `/var/lib/dpkg/info/apparmor.postinst: 148: [: Illegal number: yes`, but the package completed and the host returned healthy.
- Follow-up: Plan a separate disk-usage review for `esst-cloud-2` if usage trends upward again; it still has adequate free space, but much less headroom than `esst-cloud-1`, `esst-cloud-3`, and `esst-cloud-4`.

## 2026-07-04 - July Host Upgrade And Reboot

Date: 2026-07-04

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 84% used
- Reboot-required marker was already present from an earlier kernel install and listed `linux-image-6.8.0-134-generic` plus `linux-base`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Docker Engine: `29.6.1`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 84% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: Follow-up noted. Root filesystem remains the tightest in the fleet at about 84% used with about 28G free.
- Memory checked: Not rechecked separately after reboot during this run.
- Docker checked: OK. Docker upgraded to `29.6.1` and the node returned to Swarm as `Ready`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `iproute2`, `kpartx`, and `multipath-tools`.
- Remaining apt upgrades checked: `fwupd` remained deferred by phasing.
- Reboot requirement checked: Reboot required before maintenance due to the pending `6.8.0-134` kernel. Controlled reboot completed and the flag cleared.
- Notes: `needrestart` reported that no services, containers, or user sessions required additional restart after package installation.
- Follow-up: Keep `esst-cloud-2` on the disk-watch list; it still has adequate free space, but much less headroom than the rest of the ESST fleet.

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
