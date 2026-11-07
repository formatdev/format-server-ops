# format-cloud-1 Host Maintenance Log

## 2026-10-31 - Backup Schedule Alignment Follow-Up

- With Peter's approval, moved only the two root cron preparation hours from
  `20` to `18`: MariaDB dump `18:00`, Portainer archive `18:10`, followed by
  unchanged Duplicati `18:30 UTC`. All clocks use UTC; Luxembourg winter times
  are `19:00`, `19:10`, and `19:30` respectively.
- Original crontab backed up; expected-job guards, syntax validation, and
  installed-content comparison passed. Cron remains active. Scripts, retention,
  Duplicati configuration and services were not modified by this correction.
- Existing fresh staging files are readable and gzip-valid inside Duplicati;
  the next automatic cycle and remote inclusion remain to be verified.
- [Detailed schedule/rollback record](maintenance-2026-10-31.md#backup-schedule-follow-up).

## 2026-10-31 - End-Of-Month Maintenance

Applied 20 standard host package upgrades and rebooted into kernel
`6.8.0-147-generic`; Docker is `29.9.2`. No pending upgrades, reboot marker,
dpkg audit findings, or failed units remain. All 18 services are `1/1`.

Updated Portainer server/agent to `2.45.3 LTS`, Traefik to `3.7.17`,
Cloudflared to `2026.10.7`, both Redis instances to `7.4.12`, and Duplicati
to `2.4.1.0 stable`. MariaDB's refreshed `11.8.9` image was picked up during
task recreation; credentialed full table checks passed. Fresh database/cold
backups and saved Portainer image-reference validation passed.

PHP runtimes remain patched. Application dependency follow-ups remain, including
deployed Symfony Mime versions in FLOC/both Chargy, and source audit findings in
timesheets/reports/TIM. FLOC/Chargy app deployment ownership remains Peter's.
No app release, host tuning, destructive cleanup, commit, or push was performed.

Follow-up: Peter confirmed the Vaultwarden smoke test passed and authorized
the scoped maintenance-record commit/push. Server `1.37.4` / Web Vault
`2026.7.0` and the current published image digest were reconfirmed live;
Cloudflared `2026.10.7` was also reconfirmed in its running and saved definitions.

[Detailed verification, rollback records, and remaining actions](maintenance-2026-10-31.md).

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker Engine maintenance, and reboot decisions for `format-cloud-1`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-10-21 - Cross-Service PHP Verification And Chargy Follow-Up

- Independently inventoried six affected PHP containers. Subsequent checks
  confirmed PHP `8.3.36` for NoLimits, phpMyAdmin, and both Chargy services,
  plus `8.4.27` for TIM. All 18 services were `1/1`; sampled origin routes
  returned their expected `200`/`302` responses.
- Both Chargy services were updated here to security release `2.2.8`, then
  observed on `latest` at the same fixed digest. Direct pulls were denied,
  but retained Swarm registry authentication successfully pulled the release.
  Temporary start-first/rollback settings were restored to the original
  stop-first/pause update configuration. Startup upgrade processes exited 0.
- These Chargy updates occurred before discovering Peter's newer instruction
  in another task to redeploy Chargy and FLOC manually. No further production
  deployment followed that discovery. Saved Chargy Compose files remain on
  `latest`; no Portainer stored-file edits were performed by this task.
- FLOC's shared PHP `8.5.12` base was published and checked independently.
  Its `v3.0.11` application image passed publication/runtime checks in
  workflow `39633745002`. After Peter reported redeploying FLOC and both
  Chargy stacks, live verification at 16:32 UTC confirmed FLOC `v3.0.11` /
  PHP `8.5.12` and both Chargy `2.2.8` / PHP `8.3.36`, with exact published
  image digests and successful FPM configuration checks. All six affected PHP
  containers now run fixed versions; all 18 services remain `1/1`. Public and
  origin roots respond as expected, and all three origin login pages are `200`.
  Authenticated workflows were not tested.
- Additional MariaDB and FLOC MySQL dumps passed gzip verification. No host
  package maintenance or reboot was performed. An unrelated failed
  `fwupd-refresh.service` was observed before deployment and left unchanged.
- [Full cross-service verification and remaining actions](php-security-verification-2026-10-21.md).

## 2026-10-21 - Emergency PHP Security Runtime Updates

Peter requested patching TIM, NoLimits and phpMyAdmin for CVE-2026-109618
and CVE-2026-109619. Chargy and Floc were explicitly left for Peter.

- Confirmed PHP.net fixes: 8.2.35, 8.3.36, 8.4.27 and 8.5.12. The patched
  official PHP Docker tags lacked usable amd64 manifests during this run.
- Built checksum-verified PHP releases against the existing Debian variants,
  retained application code/configuration and additional extensions, and tested
  each candidate through isolated Apache HTTP plus CLI extension comparison.
- Deployed local images: TIM PHP 8.4.20 -> 8.4.27; NoLimits 8.3.30 -> 8.3.36;
  phpMyAdmin 8.3.26 -> 8.3.36. All three updates completed and all 18 services
  were 1/1 afterward. No host upgrade, reboot or database migration was run.
- NoLimits origin homepage and database read passed; XML-RPC remained 403,
  REST user listing 401. TIM and phpMyAdmin origin pages returned 200.
  No fatal PHP, segmentation fault or symbol lookup errors appeared in the
  inspected startup logs. Authenticated browser workflows were not tested.
- Fresh MariaDB dump and NoLimits file copy passed gzip checks. A cold
  Portainer backup preceded saved-definition updates. Compose files 2, 4 and 8
  now match the running image tags; YAML semantic and Compose validation passed.
- Docker Hub rejected push with insufficient token scopes. These images are
  local-only under `format-security/*`; a verified patched-image archive and
  rebuild inputs are retained. Registry publication remains outstanding.
- [Full image, build, verification and recovery record](php-security-20261021/README.md).

## 2026-10-10 - October Maintenance Round

Date: 2026-10-10 06:44 CEST

Maintainer: Codex with Peter

Host maintenance:

- Before: kernel `6.8.0-139-generic`, Docker `29.8.0`, uptime about 26 days;
  all 18 services `1/1`. Reboot marker referenced installed kernel `142`.
- Applied 25 package upgrades and two new kernel packages, with no removals.
  After controlled reboot: kernel `6.8.0-146-generic`, Docker `29.9.0`,
  containerd `2.4.1`, Compose `5.6.0`, Buildx `0.38.0`; Ubuntu remains 24.04.5.
- No reboot marker, dpkg audit findings, or failed systemd units remain.
  Only `libopeniscsiusr` and `open-iscsi` are deferred by Ubuntu phasing;
  phasing was not overridden.
- AppArmor post-install emitted `Illegal number: yes`, but installation
  completed and AppArmor was active after reboot. No workaround was applied.
- Root: 60G used, 85G available, 42% used; about 12 GiB memory available.
  No Docker prune, autoremove, or production-data deletion.
- SSH remains key-only; UFW and Fail2ban baseline checks passed.

Container maintenance:

- Portainer server/agent: `2.45.0` -> `2.45.2 LTS`; migration and version API OK.
- Traefik: `3.7.13` -> `3.7.14`; migration notes reviewed against actual Swarm
  arguments. The usual transient host-port replacement wait resolved.
- Vaultwarden: `1.37.2` -> `1.37.4`. Binary reports Web-Vault `2026.7.0`;
  no separate frontend update. Effective `CF-Connecting-IP` avoids changed
  `X-Forwarded-For` parsing behavior.
- Duplicati: stable `2.4.0.0` -> `2.4.0.1`, verified in container changelog,
  pinned to `sha256:e32e280cc30e98ac5cea8d2b339cd19810b1b39e638fb9d39253786630104de0`.
- Cloudflared: explicit tag `2026.10.0`, digest
  `sha256:9b49eed8f62806d5d45ddf59ecefb5710429598ea6d3fcccd2af938f621b2b07`.
  All four tunnel connections registered.
- Both Chargy Redis services had drifted to `7.4.8` under `7.4-alpine3.21`.
  Saved definitions pinned the old digest. Saved RDB snapshots, then restored
  `7.4.11-alpine3.21` pins. Both servers report `7.4.11` and respond `PONG`.
- MariaDB `11.8.9` and phpMyAdmin `5.2.3` remain current in selected lines.
  Major WordPress/Redis/MariaDB changes and MySQL `8-oracle` refresh remain
  separate compatibility-reviewed work.
- FLOC and Chargy application digests match September 13 recorded builds.
  No private-image registry/source freshness claim is made.

Saved deployment definitions:

- Stopped Portainer, waited for its container to exit, and made a verified
  archive before changing only image references in stored Compose files.
  YAML parsing and target-image assertions passed; Portainer restarted.
- Reconciled IDs `9` and `15` (Redis), `11` (Vaultwarden), `25` (Duplicati),
  and `26` (Cloudflared) with this round's versions.
- Also reconciled IDs `1` (MariaDB `11.8.9`) and `2` (phpMyAdmin `5.2.3`)
  with existing live versions, without redeploying those services.
- The Bolt database and unrelated saved stacks were not edited.

Backups:

- October 9 scheduled MariaDB/Portainer archives passed `gzip -t`.
- Fresh dump: `/data/backups/mysql/mariadb-all-databases-2026-10-10-043731.sql.gz`.
- Portainer pre-upgrade: `/data/backups/portainer/portainer-data-20261010-043719.tar.gz`.
- Portainer pre-edit: `/data/backups/portainer/portainer-data-20261010-044305.tar.gz`.
- Vaultwarden cold archive: `/data/backups/vaultwarden/vaultwarden-data-20261010-043956.tar.gz`.
- Duplicati cold archive: `/data/backups/duplicati-maintenance/duplicati-data-20261010-044019.tar.gz`.
- All fresh archives passed gzip verification. Vaultwarden SQLite
  `quick_check` returned `ok` before maintenance.
- Read-only Duplicati results confirmed successful remote jobs October 7-9.
  Latest finish: October 9, `18:41:51 UTC`, 87,601 files, 12,565,000,023 bytes.
- No post-patch remote backup or restore was run. Last recorded restore is
  April 18. New Vaultwarden/Duplicati maintenance archives are root-only and
  separate from existing scheduled retention policies.

Final verification:

- All 18 services `1/1`; node Ready, Active, Leader; no unhealthy containers.
  Services recovered automatically after reboot. Both Chargy startup upgrade
  processes exited 0; no forced app/database recovery was necessary.
- Vaultwarden's health warm-up caused transient `404`, then `200` responses.
- Origin: `200` for Bitwarden, FLOC, Portainer API, phpMyAdmin, and Duplicati;
  `302` for both Chargy routes.
- Public TLS: Bitwarden/FLOC `200`; Chargy routes `302`; Portainer, phpMyAdmin,
  and Duplicati `302` to `esst.cloudflareaccess.com`.
- Fresh two-minute error samples for ingress, management, vault, backup,
  MariaDB, MySQL, and Redis containers had zero matches.
- Peter confirmed completion of the Portainer and Vaultwarden smoke tests
  after maintenance. This is user-reported functional verification.
- Verify the next scheduled Duplicati backup and plan a separate restore test.

Sources: [Docker releases](https://docs.docker.com/engine/release-notes/29/),
[Traefik 3.7.14](https://github.com/traefik/traefik/releases/tag/v3.7.14),
[Portainer 2.45.2](https://github.com/portainer/portainer/releases/tag/2.45.2),
[Vaultwarden 1.37.4](https://github.com/dani-garcia/vaultwarden/releases/tag/1.37.4),
[Duplicati 2.4.0.1](https://github.com/duplicati/duplicati/releases/tag/v2.4.0.1_stable_2026-10-07),
[Cloudflared 2026.10.0](https://github.com/cloudflare/cloudflared/releases/tag/2026.10.0).

## 2026-09-13 - Package Maintenance, Reboot, And Backup Verification

Date: 2026-09-13 12:08 CEST

Maintainer: Codex with Peter

Host state:

- Before: kernel `6.8.0-139-generic`, Docker `29.8.0`, uptime about eight days;
  all 18 services were `1/1`. A pending reboot marker listed `libc6`.
- Applied eight package upgrades with no package additions or removals:
  containerd `2.3.5`, Buildx `0.37.1`, base-files, motd-news-config,
  python-apt-common, python3-apt, python3-distupgrade, and
  ubuntu-release-upgrader-core.
- After: Ubuntu reports `24.04.5 LTS`; kernel remains `6.8.0-139-generic`,
  Docker remains `29.8.0`, and Compose remains `5.5.1`.
- Controlled reboot completed. No pending apt upgrades, dpkg audit findings,
  reboot marker, or failed systemd units remained.
- Root filesystem: 56G used, 89G available, 39% used. About 12 GiB memory
  available after recovery.

Service and security checks:

- All 18 Swarm services recovered to `1/1`. The node is Ready, Active, Leader.
- MariaDB, MySQL, and Redis recovered automatically. Both Chargy startup
  upgrade processes exited successfully; no forced recovery was needed.
- Vaultwarden needed its usual health-check warm-up; its route briefly
  returned `404`, then returned `200` once healthy.
- Final local Traefik route checks returned `200` for Bitwarden, FLOC,
  Portainer, phpMyAdmin, and Duplicati, and `302` for both Chargy routes.
  These probes test origin routing, not authenticated user workflows.
- SSH remains key-only. UFW remains active with inbound SSH and HTTPS
  allowances; Fail2ban and the sshd jail are active.
- Fresh current-container log samples for Traefik, Portainer, MariaDB,
  Duplicati, and Cloudflared showed no matching errors after recovery.

Container release review:

- Cloudflared now runs `2026.9.1`, compared with `2026.8.3` last round.
  The mutable `latest` image was already refreshed when inspected after
  reboot; pulling and reapplying the service image confirmed the current
  version. Registry digest:
  `sha256:b269e8abd07a5bf6f3f4be65d5050b2174eca89c56a0241a8ff32a16aec454e4`.
  All four tunnel connections registered successfully.
- Traefik `3.7.13`, Portainer `2.45.0`, Vaultwarden `1.37.2`, Redis `7.4.11`,
  MariaDB `11.8.9`, and phpMyAdmin `5.2.3` remain current in the selected
  release lines based on upstream release and official-image metadata.
- Duplicati stable remains `2.4.0.0`; its pinned image digest still matches
  the registry's `latest` manifest. New canary releases were not selected.
- Major application/database changes and private custom-app build reviews
  remain separate work. Private registry freshness was not reverified during
  the initial inspection; Peter's subsequent FLOC/Chargy bumps are noted below.

Backups:

- September 12 local backups are present and passed `gzip -t`:
  `/data/backups/mysql/mariadb-all-databases-2026-09-12-200001.sql.gz` and
  `/data/backups/portainer/portainer-data-20260912-201001.tar.gz`.
- Read-only Duplicati metadata and result inspection confirms successful
  Synology backups on September 8, 9, 10, 11, and 12 after the stable upgrade.
  The latest finished at `2026-09-12 18:34:27 UTC`, examining 87,345 files
  totaling 12,581,533,390 bytes. This closes the prior post-upgrade backup
  verification follow-up.
- No restore test was performed. The last recorded restore remains April 18.

Application follow-up before commit:

- Peter reported updating FLOC and Chargy. Live service inspection confirmed
  FLOC digest `sha256:8a25198cf10b6e39b869704ab4c8347cc06ef9b41704a78a13a15f733289799c`
  and both Chargy stacks on digest
  `sha256:a0015897e46c952ea4a1c7f0783a67d856e5e8875eb951aa2e3f4d787f10e6d6`.
- All three application containers were running, with FLOC returning `200`
  and both Chargy routes returning `302`. Source build commits and dependency
  review were not independently verified here.

Sources: [Cloudflared release](https://github.com/cloudflare/cloudflared/releases/tag/2026.9.1),
[Traefik releases](https://github.com/traefik/traefik/releases),
[Portainer releases](https://github.com/portainer/portainer/releases),
[Vaultwarden releases](https://github.com/dani-garcia/vaultwarden/releases),
[Duplicati releases](https://github.com/duplicati/duplicati/releases),
[Docker official-image metadata](https://github.com/docker-library/official-images/tree/master/library).

## 2026-09-05 - September Maintenance Round

Date: 2026-09-05 09:34 CEST

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-138-generic`
- Docker Engine: `29.7.2`
- Uptime: about 12 days, 17 hours, 45 minutes.
- Swarm was healthy before maintenance; all services were `1/1`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-139-generic`
- Docker Engine: `29.8.0`
- Docker Compose plugin: `5.5.1`
- Root filesystem: 150G total, 56G used, 89G free, 39% used.
- Memory after reboot: 15 GiB total, about 13 GiB available.
- Reboot marker: none present.
- Pending apt upgrades: none observed.

Checks:

- SSH, firewall, Fail2ban, and system health checked: OK. SSH remained key-only, UFW allowed only SSH and HTTPS, Fail2ban remained active, and no failed systemd units were reported.
- Backups checked: OK. Daily Portainer and MariaDB backups were current through 2026-09-04. Fresh pre-upgrade backups were created at `/data/backups/portainer/portainer-data-20260905-072656.tar.gz` and `/data/backups/mysql/mariadb-all-databases-2026-09-05-072709.sql.gz`; the MariaDB dump passed gzip verification.
- Apt full upgrade applied: Yes. Upgraded 16 packages and installed 20 new split firmware/kernel packages, including Docker Engine `29.8.0`, containerd `2.3.4`, Buildx `0.37.0`, Compose `5.5.1`, Python 3.12 updates, procps, linux-firmware, and kernel `6.8.0-139`.
- Reboot completed: Yes. The host booted `6.8.0-139-generic`; no reboot marker or pending apt upgrades remained.
- Docker Swarm checked: OK. All 18 services finished at `1/1`, with no unhealthy containers.
- Stack updates applied: Portainer server and agent `2.45.0 LTS`, Traefik `3.7.13`, MariaDB `11.8.9`, Duplicati stable `2.4.0.0` pinned to digest `sha256:eb0c1298a1974048332745b393897ae3cc1c20258e4fc26a796f2b5d75eb6218`, and Cloudflared `2026.8.3`.
- Duplicati permission preflight checked: OK. Its actual application data directory `/data/Duplicati` was already owned by root with mode `0700`, satisfying the new stable release's strict data-folder requirement.
- Routed app smoke tests checked: OK. Local Traefik checks returned `200` for Bitwarden, FLOC, Portainer, phpMyAdmin, and Duplicati; both Chargy routes returned the expected `302`.
- Fresh logs reviewed: OK. Portainer migrated from `2.44.0` to `2.45.0`; MariaDB reported no upgrade required and became ready; Duplicati listened on port 8200; fresh Traefik, Cloudflared, and upgraded-service error samples were quiet after convergence.

Recovery notes:

- During the reboot, Swarm stopped one Redis task, MariaDB, and MySQL while its manager was shutting down and did not automatically schedule replacements. Their data services had shut down cleanly. Forced service updates recreated exactly those three tasks, and all converged.
- Both Chargy containers initially started before MariaDB was available, so their startup upgrade process failed and routes returned `503`. Recycling the two app services after the databases were healthy made both startup upgrades exit successfully and restored the expected `302` responses.
- Traefik again encountered the expected single-node host-mode port `443` replacement wait before converging.
- Duplicati briefly returned `404` while Traefik refreshed service discovery, then returned `200` on the next check.

Notes:

- Redis `7.4.11`, Vaultwarden `1.37.2`, and phpMyAdmin `5.2.3` remained current in their selected lines.
- WordPress 7.1, Redis 8, MariaDB 12.x, and the MySQL `8-oracle` moving-tag refresh remain separate compatibility-reviewed work.
- Mutable custom `esst/*` image tags could not be compared with their registries from this host because registry pulls were unavailable. Running images remained healthy and unchanged.
- No Docker prune, production volume cleanup, autoremove, or production data
  deletion was performed. A disposable Duplicati version-probe container and
  its anonymous test volume were removed after validation.

## 2026-08-23 - End-Of-Month Maintenance Round

Date: 2026-08-23 15:40 CEST

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Docker Engine: `29.7.1`
- Reboot state: reboot required; marker listed `linux-image-6.8.0-137-generic`, `linux-base`, `linux-image-6.8.0-138-generic`, and `linux-base`.
- Uptime: about 2 weeks, 4 days, 22 hours, 26 minutes.
- Swarm was healthy before maintenance; all services were `1/1`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-138-generic`
- Docker Engine: `29.7.2`
- Docker Compose plugin: `5.5.0`
- Root filesystem: 150G total, 55G used, 90G free, 38% used.
- Memory after reboot: 15 GiB total, about 12 GiB available.
- Reboot marker: none present.
- Pending apt upgrades: none observed.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` worked before and after reboot.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`, `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active; two sources were banned before maintenance.
- System health checked: OK. `systemctl --failed` reported 0 failed units after maintenance.
- Docker Swarm checked: OK. Single-node Swarm recovered after package maintenance and reboot.
- Docker services checked: OK. All Swarm services reported `1/1` after package maintenance, reboot, and image updates.
- Container health checked: OK. No unhealthy containers were reported.
- Backups checked: OK. Portainer archives were current through `/data/backups/portainer/portainer-data-20260822-201001.tar.gz`; MariaDB dumps were current through `/data/backups/mysql/mariadb-all-databases-2026-08-22-200001.sql.gz`.
- Apt upgrade applied: Yes. Upgraded Docker Engine to `29.7.2`, `containerd.io` to `2.3.3`, Docker Buildx to `0.36.1`, Docker Compose plugin to `5.5.0`, `linux-firmware`, `snapd`, `apport`, `qemu-guest-agent`, `open-vm-tools`, Kerberos libraries, and console/keyboard packages.
- Pending apt upgrades checked: OK. No package upgrades remained after maintenance.
- Reboot requirement checked: OK. Rebooted into `6.8.0-138-generic`; no reboot marker remained afterward.
- Stack updates applied: Yes. Traefik moved to `3.7.11`, Vaultwarden moved to `1.37.2`, both Chargy Redis services moved to `redis:7.4.11-alpine3.21`, and Cloudflared `latest` refreshed from `2026.7.3` to `2026.8.2`.
- Stack image metadata checked: OK. Traefik, Vaultwarden, Redis, and Cloudflared `com.docker.stack.image` labels matched the live images after updates.
- Routed app smoke tests checked: OK. Local Traefik host-header checks returned `200` for `bitwarden.format.lu`, `floc.lu`, `portainer.format.lu`, `pma.format.lu`, and `duplicati-fc1.format.lu`; `chargy.format.lu` and `chargy.loeffler.lu` returned the expected `302`.
- Logs reviewed: OK. Fresh Traefik and Cloudflared filtered log samples were quiet after convergence. Vaultwarden `1.37.2` launched normally. Redis `7.4.11` loaded existing RDB files and returned to ready.

Notes:

- No Docker prune, volume cleanup, database upgrade, WordPress major upgrade, MariaDB major upgrade, or MySQL `8-oracle` moving-tag refresh was performed.
- Vaultwarden again had a post-reboot and post-update health warm-up period; `bitwarden.format.lu` briefly returned `404` while Traefik waited for a healthy backend, then returned `200`.
- Traefik again hit the known single-node host-mode `443` replacement wait and then converged cleanly.
- Redis still logs the known `vm.overcommit_memory` warning at startup.
- Cloudflared shutdown errors appeared for the old task during the controlled replacement; the new `2026.8.2` task registered tunnel connections cleanly.

Follow-up:

- Keep Redis 8, WordPress 7.1, MariaDB 12.x, and MySQL `8-oracle` refreshes as separate planned compatibility and backup-reviewed work.

## 2026-08-04 - Package Maintenance, Reboot, And Stack Updates

Date: 2026-08-04 17:16 CEST

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Docker Engine: `29.6.2`
- Portainer: `2.43.0`
- Uptime: about 2 weeks, 2 days, 7 hours, 21 minutes.
- Root filesystem: 150G total, 51G used, 94G free, 36% used.
- Memory: 15 GiB total, about 11 GiB available.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Docker Engine: `29.7.1`
- Portainer: `2.44.0`
- Root filesystem: 150G total, 51G used, 93G free, 36% used.
- Memory after reboot: 15 GiB total, about 13 GiB available.

Checks:

- SSH checked: OK. `ssh hetzner-cloud-1` resolves to `188.245.43.92` and worked through the configured alias.
- Firewall checked: OK. `ufw` remains active with inbound `22/tcp`, `443/tcp`, and `443/udp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active; one source was banned at inspection time.
- System health checked: OK. `systemctl --failed` reported 0 failed units.
- Docker Swarm checked: OK. Swarm remains active with local node control available.
- Docker services checked: OK. All Swarm services reported `1/1` after package maintenance, reboot, and image updates.
- Container health checked: OK. No unhealthy containers were reported.
- Backups checked: OK. MariaDB dumps were current through `/data/backups/mysql/mariadb-all-databases-2026-08-03-200001.sql.gz`; a fresh Portainer archive was created at `/data/backups/portainer/portainer-data-20260804-151452.tar.gz`.
- Routed app smoke tests checked: OK. Local Traefik host-header checks returned `200` for `bitwarden.format.lu`, `floc.lu`, `portainer.format.lu`, `pma.format.lu`, and `duplicati-fc1.format.lu`; `chargy.format.lu` returned the expected `302`.
- Public hostname checks checked: Cloudflare Access/WAF returned HTTP `403` externally for sampled protected hostnames, while local Traefik routing was healthy.
- Apt upgrade applied: Yes. Upgraded `docker-ce`, `docker-ce-cli`, and `docker-ce-rootless-extras` to `29.7.1`, `docker-buildx-plugin` to `0.36.0`, `docker-compose-plugin` to `5.4.0`, `libssl3t64` and `openssl` to `3.0.13-0ubuntu3.12`, `tzdata` to `2026c-0ubuntu0.24.04.1`, and `distro-info-data` to `0.72-0ubuntu0.24.04.1`.
- Pending apt upgrades checked: OK. No package upgrades remained after maintenance.
- Upgrade simulation checked: OK. `apt-get -s upgrade` and `apt-get -s full-upgrade` both reported 9 upgraded, 0 newly installed, 0 removed, and 0 not upgraded.
- Reboot requirement checked: OK. Reboot completed and no reboot marker remained afterward.
- Stack updates applied: Yes. Portainer server and agent moved to `2.44.0`, Traefik moved to `3.7.10`, and Vaultwarden was verified running `1.37.1`.
- Stack image metadata checked: OK. Portainer, Traefik, and Vaultwarden `com.docker.stack.image` labels matched the live images after updates.
- Logs reviewed: OK. Portainer migrated its database from `2.43.0` to `2.44.0` and started cleanly. Portainer agent kept its known multi-network warning. Traefik had the familiar startup-only missing middleware lines, and the fresh post-convergence filtered sample was quiet. Vaultwarden `1.37.1` launched and accepted websocket connections.

Notes:

- No Docker prune, stack redeploy, volume cleanup, or data deletion was performed.
- Docker's package restart briefly left several Swarm tasks at `0/1` with stale VXLAN `file exists` errors. The already-required host reboot cleared the interfaces, and all services converged to `1/1` afterward.
- Vaultwarden needed additional health-check warm-up after reboot before reaching `1/1`.
- The single-node host-mode `443` replacement wait occurred during the Traefik update and then converged cleanly.

Follow-up:

- Continue the normal monthly inspection cadence.

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

## 2026-11-07 — PePs hosted pilot

- Scope: user-authorised production packaging, first release, managed Portainer
  stack and migration of the current Servior setup. Existing applications and
  shared MariaDB were left unchanged.
- Release: `formatdev/PePs` v0.1.0, commit
  `787c77329207d3df8abca496125bce49660fd82a`, private Docker Hub digest
  `sha256:76afad83e1dc17468445d70b8fcdf58b95465429f637b439f7c23269725b2b18`.
  CI passed SQLite/MySQL tests, Composer/npm audits, formatting, type checking,
  frontend build and an isolated production-container smoke test.
- Portainer: managed `peps`, ID 27. Web/nginx/FPM runs as UID 1000. Dedicated
  MySQL and private encrypted overlay; no host ports published. Only web joins
  the existing Traefik `proxy` network. Four external Swarm secrets preserve the
  original APP_KEY and M365 registration and provide new database credentials.
- Migration: local app/workers/scheduler stopped before the snapshot. Original
  local database and a restricted full pre-migration dump retained. Filtered
  export included Servior only, with existing primary keys, maison aliases,
  column mappings, email templates and historical snapshots. Hosted counts:
  one customer, 22 maisons, 1,604 employees/episodes/assignments/codes, three
  imports, one mail batch with 1,604 messages, zero clinical calls/reports.
- Verification: all selected source/destination row fingerprints matched;
  account transformations separately checked, every foreign-key relationship
  checked. Existing superadmin renamed to `peter.czibula@format.lu` with password
  unchanged; the real administrator retained and `.test` accounts disabled.
  Sessions, cached tokens, jobs and reset tokens were not copied. MFA required.
- Read-only hosted verification decrypted all 19,391 encrypted fields. No
  migrations pending, retention dry-run found zero eligible identities/clinical
  periods. M365 mailbox and Exchange trace access passed; no email was sent.
- HTTPS: existing proxied DNS record points to 188.245.43.92; Cloudflare Full
  (strict) verified. Public login works with secure, HttpOnly session cookie and
  no-store response. The user completed hosted sign-in/authenticator setup.
  Authenticated browser checks then confirmed the superadmin dashboard,
  Servior's 1,604 employees and 22 maisons, maison aliases/counts, saved Excel
  mappings and all three imports (two drafts and completed mail lot 3).
  Email showed an empty review/queue/error list and 1,604 history entries.
  The test-lock banner, owner destination and ten-message limit were visible;
  destination and limit inputs were verified read-only. No records were changed
  and no mail was sent during these checks. Dashboard left open for the user.
- All six PePs services converged to 1/1. The first scheduled M365 sync,
  report preparation (disabled for Servior) and token pruning completed at
  10:00 Luxembourg time. Queue and failed-job counts remained zero; existing
  mail states remained ten test-sent and 1,594 test-skipped.
- Mail safety: deployment locks test mode, test destination and ten-message
  limit even if database settings say live. Local services remain stopped to
  avoid duplicate scheduling. Reports remain disabled for Servior.
- Backup: installed `/usr/local/sbin/backup-peps.sh`, 18:05 UTC, 14 local days;
  existing cron entries preserved. First consistent gzip dump succeeded and
  restored into an isolated, network-disabled MySQL container. Restored row
  fingerprints and all 19,391 encrypted fields passed with the published image.
  Duplicati sources/filters include SQL dumps, storage and secret escrow; the
  next 18:30 off-site upload and an off-site retrieval were not yet verified.
  The raw `/data/peps/mysql` directory is also included by the existing broad
  source: only the consistent SQL dump is validated for restoration.
- Rollback: retained original local database, pre-migration dump, hosted initial
  dump and original key. Do not reopen an old copy without reconciling later
  hosted writes and retention erasures.

## 2026-11-07 — PePs sign-in navigation update

- User-reported issue: after initial authenticator setup, the account-security
  settings appeared to be another required step. Subsequent sign-in could also
  return to a remembered security URL. Optional expansion panels were missing
  their Vue registrations, leaving all forms visible.
- Released and deployed `formatdev/PePs` v0.1.1, commit
  `8fc62b1454a456dfa76effd2f3615a40dac98710`, image digest
  `sha256:8191f92d284fa398a50c31da8e036b3b67153cef31c2f911e2feeafa8d15c9b6`.
  Sign-in and initial MFA confirmation now land on the dashboard. Recovery
  codes remain one-time-only, with browser-history clearing. The security
  page has green dashboard/red sign-out buttons and collapsed optional forms.
- Validation: 22 focused account tests passed locally. Release workflow
  42410318922 passed 323 tests on each of SQLite/MySQL (2/1 expected skips),
  dependency audits, formatting, type checking, build and isolated image smoke
  test. No dependency, schema, password or authenticator changes.
- Production gate: fresh consistent dump
  `/data/backups/peps/peps-20261107T201840Z.sql.gz`; zero queued/failed jobs and
  zero active employee messages. Original deployment files saved with suffix
  `.before-v0.1.1` under `/data/peps`.
- Deployment: updated only `PEPS_IMAGE` in Portainer's managed stack 27;
  forced image re-pull/redeployment was disabled to preserve the unchanged
  database. The five app services converged to the new digest; all six services
  healthy, web update completed at 20:24:22 UTC. MySQL container unchanged.
  Host `deploy.env` was reconciled to the new image. No migrations required.
- Hosted read-only verification passed: 19,394 encrypted fields, 1,604
  employees/assignments/codes, 22 maisons, three imports and 1,604 messages.
  HTTPS `/login` and `/up` returned 200; mail test lock remains enabled.
- Authenticated verification: the user signed in and reported the dashboard
  opened; the browser independently confirmed `/dashboard`. The security page
  showed its optional-settings explanation, green dashboard/red sign-out
  buttons and three collapsed sections. Password settings expanded/collapsed
  correctly without entering credentials; the green button returned to the
  dashboard. No account settings were submitted. Screenshot retained locally.
- Earlier same-day delivery test: user authorised exactly one Servior sample
  to `peter.czibula@format.lu`. Message 5 in lot 3 was reissued with its previous
  delivery record preserved in revision history. The other 1,603 message rows
  were unchanged. Microsoft reported delivered at the 09:57:30 UTC check and
  the hosted UI displayed the result. The user subsequently confirmed receipt
  and appearance. No additional mail was sent for this navigation update.
- Rollback: restore the v0.1.0 image digest in Portainer; schema is unchanged.
  Current hosted data and original encryption key must be retained.

## November 7, 2026 — PePs production data reset

- User authorised removing Servior's employees, codes, imports and employee
  mailing history while retaining Servior and its maisons/settings, accounts,
  authentication, call reasons, M365 connection and mail test mode. The user
  explicitly requested **no new backup**. Existing backups and the scheduled
  backup configuration were left untouched.
- Gate: one customer (Servior, ID 3), no clinical calls or statistical reports,
  zero queued/failed jobs and no pending account messages. Employee mail was
  already terminal: 10 test-sent and 1,594 test-skipped. Reports disabled.
- Brief maintenance mode and background-service pause prevented writes.
  A single transaction with foreign-key enforcement deleted 1,604 employees,
  employment episodes, assignments and codes; three imports with 5,680 rows
  and 1,604 proposed changes; one email batch with 1,604 messages.
- In-memory before/after fingerprints confirmed customers, locations, aliases,
  users, call reasons, mail settings, account messages, password reset tokens
  and migration records were unchanged. Location code counters and table ID
  sequences were retained to prevent reuse of previously issued identifiers.
  Existing audit events were retained and a production reset event recorded.
- Verification at 20:53 UTC: zero employees, assignments, codes, imports,
  email batches/messages, calls and reports; one customer and 22 maisons.
  Remaining encrypted fields decrypted successfully. M365 test lock remains
  enabled for peter.czibula@format.lu with a ten-message limit. No mail sent.
- Maintenance mode ended and all six services returned to 1/1; web and MySQL
  healthy, public /login and /up returned 200. Web/database containers and
  deployed v0.1.1 digest unchanged. No new release or local app/data changes.
- A fresh import can now populate Servior using its preserved column and
  maison mappings. Restoring an older data backup would undo this clean state.

## November 7, 2026 — PePs v0.2.0 release

- User authorised committing, pushing and publishing the accumulated PePs
  work. Source `b99e939468e258f58d4e8f76417c84687cf3d55e` was pushed to
  `codex/peps-foundation` and tagged `v0.2.0` in `formatdev/PePs`.
- The release adds the shared psychologist/superadmin call workspace,
  sorting, automatic filters, unlimited call reasons, expanded aggregate
  statistics access and compact layouts/navigation. The optional MFA
  shortcut is restricted to the local environment.
- [Release workflow](https://github.com/formatdev/PePs/actions/runs/42421654170)
  passed: SQLite 355 passed / 6,128 assertions, MySQL 356 passed / 6,139
  assertions, dependency audits, formatting, Vue type check/build and the
  isolated packaged-runtime smoke test. The private reference-workbook test
  is optional; the locking test is MySQL-only. A test-isolation fix restores
  trusted-host state after simulated production-login tests.
- Published private image `esst/peps:0.2.0`, immutable digest
  `sha256:1d61d1c9a7974894ca582ee6ab0eea18e811127789211ee2d3c6a6d5d6989c76`.
  Image labels confirm version 0.2.0 and the source commit above.
- Gate: zero queued/failed jobs and no employee/report messages pending.
  Fresh post-reset backup `/data/backups/peps/peps-20261107T224002Z.sql.gz`
  completed with gzip integrity verification (98 KiB). Original deployment
  files preserved as `.before-v0.2.0`; this backup has not been independently
  restored or confirmed off-site.
- Updated only `PEPS_IMAGE` in managed Portainer stack 27. Forced image
  re-pull/redeployment was disabled; all five application services converged
  and all six services are 1/1. The existing healthy MySQL container is
  unchanged. Portainer's saved image and host `deploy.env` agree. No migration.
- Read-only post-deployment verification passed: two encrypted fields,
  one customer, 22 maisons, zero employees/assignments/codes/calls/imports,
  employee mail and statistical reports. HTTPS health and login return 200.
  MFA remains required, the local shortcut is disabled, and mail is locked
  to peter.czibula@format.lu with the ten-message limit and three-second pacing.
- Authenticated hosted checks confirmed the new navigation, Appels filters,
  statistics auto-filter/reset, blank date bounds, four cards on one desktop
  row and account-security navigation below the collapsed sections. The
  dashboard remains at one client, 22 maisons and zero employees. Screenshot
  retained locally. No clinical data was added and no email was sent.
- Rollback: restore the v0.1.1 image digest in Portainer, retaining the current
  database and original encryption key. The PePs integration PR remains draft;
  this is a versioned hosted pilot.

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
