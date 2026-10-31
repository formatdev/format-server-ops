# October 31 Maintenance Round

Target: `format-cloud-1`, SSH alias `hetzner-cloud-1`. Production single-node
Swarm. Existing October 19/21 work and unrelated on-prem edits are preserved.

Status: host and supported container maintenance completed. Application
dependency releases, the next scheduled backup, and a restore test remain
follow-ups; this is not a claim that every application dependency is current.

## Preflight

- Ubuntu 24.04.5, kernel `6.8.0-146-generic`, Docker `29.9.0`, uptime 21 days.
- All 18 services `1/1`; node Ready/Active/Leader; no failed systemd units.
- Root filesystem 47% used, 77G available; about 11 GiB available memory.
- Reboot already required for installed kernel `6.8.0-147-generic`.
- Standard upgrade simulation: 20 upgrades, no additions or removals.
- SSH key-only; UFW active with SSH/HTTPS/HTTP3 inbound rules; Fail2ban active.
- `vm.overcommit_memory=0` still causes Redis startup warnings; no host tuning
  change was made during discovery.
- FLOC `v3.0.11`, PHP `8.5.12`; both Chargy `2.3.1`, PHP `8.3.36`.
  FLOC/Chargy deployments remain Peter's responsibility.
- NoLimits/phpMyAdmin PHP `8.3.36`, TIM PHP `8.4.27` remain patched.

## Backups

- October 30 MariaDB dump and Portainer archive passed `gzip -t`.
- Fresh MariaDB dump: `/data/backups/mysql/mariadb-all-databases-2026-10-31-133743.sql.gz`.
- Fresh Portainer cold archive: `/data/backups/portainer/portainer-data-20261031-133748.tar.gz`.
- Fresh FLOC MySQL dump: `/data/backups/php-security-20261021/floc-all-databases-20261031-133821.sql.gz`.
- All three fresh files are root-only and passed gzip integrity checks.
- Read-only Duplicati inspection: October 30 backup finished at `18:35:22 UTC`,
  result Success, zero warnings/errors, 87,869 files / 14,512,752,275 bytes.
- Live MariaDB and Portainer data exclusions remain configured; generated
  dumps and cold archives remain the intended backup inputs.
- Vaultwarden SQLite `quick_check` returned `ok` before maintenance.
- Last recorded restore finished April 18; no new restore test yet.
- Emergency Apache image recovery archive exists at
  `/root/php-security-20261021/patched-images.tar.gz` (803,968,027 bytes).
  Registry publication remains unresolved; do not discard the local images.

## Host Work

- Applied the 20 standard package upgrades, including Docker `29.9.2`,
  containerd `2.4.2`, Compose `5.6.1`, and Buildx `0.38.1`.
- Existing AppArmor post-install `Illegal number: yes` message recurred;
  package upgrade completed and AppArmor remained active before reboot.
- Docker restart recreated service tasks; services recovered without forced
  updates. Vaultwarden was still in its normal health-check warm-up.
- Controlled reboot completed into kernel `6.8.0-147-generic`. New boot ID
  `14be32ab-98b4-4885-925d-3e240ecfb0f4`; no reboot marker, dpkg audit findings,
  failed units, or pending package upgrades remain. No autoremove or Docker
  prune was performed; SSH, UFW, Fail2ban, and AppArmor checks passed.

## Container Updates

The following published image digests were downloaded and verified against
the running containers after updates:

| Service | Deployed version | Published digest |
| --- | --- | --- |
| Portainer server | `2.45.3 LTS` | `sha256:3609c307943bca8e5c492f69ddd6965df177208b50678a4cff28391c8dd4e96e` |
| Portainer agent | `2.45.3` | `sha256:6e6d2d5d8967da5b4d45eab32b7268af170395395d753d3f34ecb4d6ca5bd388` |
| Traefik | `3.7.17` | `sha256:30ff62491aacdb862ceb8c9edcf2627da638d7deafdd4b6dab32fe34f8aa3e90` |
| Cloudflared | `2026.10.7` | `sha256:4955524aeaa379e154023d5a027c250f7b35041a2e7e950cf13f144bc9b9c5ba` |
| Both Redis | `7.4.12-alpine3.21` | `sha256:8da19c7399dca900c6822a1cf30f9d2285585e2c4b457ff4095b0f4500054d3f` |
| Duplicati | `2.4.1.0 stable` | `sha256:5df64d95abd79ddaa41897a6c234c956d6de03df767a1b8eb8c5baecf3162bbf` |
| MariaDB | refreshed `11.8.9` | `sha256:c4124d1afa875e47f2892edf26b482fa54f796e2f342d3717a04ca091a22a9bd` |

Vaultwarden `1.37.4` remains the latest upstream release. No branch-major
database, WordPress core, or custom application release is part of this round.
Traefik migration review found Kubernetes-only changes and rejection of all
CONNECT requests; this host uses the Swarm provider and ordinary HTTPS routes.
Portainer/Docker reject compromised eMudhra certificate chains after updating.
Duplicati `2.4.1.0` migrates its local database format; retain a full stopped-state
backup and the old pinned image for rollback rather than attempting an image-only
downgrade.

- Portainer server and agent converged to `2.45.3`; the origin status API reports
  `2.45.3`. A transient `502` during startup resolved on retry.
- Traefik reports `3.7.17`, with existing arguments, ports, and dashboard policy
  retained. FLOC and Vaultwarden origin probes passed after convergence.
- Cloudflared reports `2026.10.7`; all four new QUIC connections registered.
- Each Redis instance was saved and copied before its update; snapshots are
  `/data/backups/redis-maintenance/chargy_redis-20261031-134228.rdb` and
  `/data/backups/redis-maintenance/chargy-loeffler_redis-20261031-134238.rdb`.
  Both report `7.4.12`, answer `PONG`, and retain `noeviction` policy.
- MariaDB's refreshed `11.8.9` image was picked up when tasks were recreated
  after the host Docker restart/reboot; no separate database branch change was
  performed. Running image matches the digest above; a credentialed full table
  check returned only `OK` results. FLOC MySQL remains `8.4.11` on its existing
  pinned `mysql:8-oracle` digest.
- Duplicati stopped-state backup:
  `/data/backups/duplicati-maintenance/duplicati-data-20261031-134348.tar.gz`,
  root-only, 339M, passed gzip verification before update. The running changelog
  confirms `2.4.1.0_stable_2026-10-29`; origin UI is `200`. Both server and backup
  SQLite databases pass `quick_check`. Server schema is 12 and backup schema
  remains 19: backup-database migration to the new format has not happened yet
  and must be checked after the next job. No post-update backup or restore ran.
- Saved Portainer Compose IDs `9`/`15` (Redis), `25` (Duplicati), and `26`
  (Cloudflared) now match the running references. Before image-only edits,
  Portainer was stopped and its data archived to
  `/data/backups/portainer/portainer-pre-compose-20261031-134517.tar.gz`.
  Gzip, semantic YAML comparison, Compose validation, and post-edit image
  assertions passed. Portainer restarted at `1/1`; the Bolt database and
  unrelated stored definitions were not edited. Reviewed changes are in
  [portainer-images-2026-10-31.json](portainer-images-2026-10-31.json).

## Application Dependency Checks

Read-only checks against local source lockfiles, not proof of deployed dependency
contents or exploitability. No source files were updated by this round.

| Source | Result |
| --- | --- |
| FLOC `apps/next` | Composer and npm audits clean; workspace has existing uncommitted dependency/UI work, so this is not an audit of the deployed lockfiles. Patch/minor and major updates are available. |
| Chargy | Composer: medium `symfony/mime` CVE-2026-45070. pnpm: 5 high / 6 moderate advisories; production-only 5 high / 5 moderate. Current source/release `2.3.1`, revision `f94ad4ba467b03e115b784fa703d92f2f05c9b24`, matches live image labels and successful release CI. |
| Timesheet app | npm all-dependency audit: 31 vulnerable packages (1 critical / 16 high / 9 moderate / 5 low); production-only 11 (1 critical / 10 high). Includes Quasar SSR findings, but the inspected Dockerfile serves static built files through Apache, so SSR applicability must be assessed. Local branch is ahead by two commits. |
| Timesheet reports | npm all-dependency audit: 20 vulnerable packages (4 critical / 13 high / 2 moderate / 1 low); production-only 13 (2 critical / 9 high / 2 moderate), including `proxy-addr` and Quasar. Deployment contents and affected code paths need application-specific review. |
| DSK TIM | Active build source `tim-v3/API` Composer audit reports Slim and Twig advisories, including critical Twig CVE-2026-46633 and high-severity findings. Assess deployed versions and template trust boundaries before determining exposure. The initial medium FPDI CVE-2026-45802 result came from legacy `tim/`, not the active build path. |

FLOC current source/release CI passed for revision
`3144f7cef1c751ce0ab01a767bf813b1b632929d`, matching live image labels.
Initial Chargy npm audit was unavailable because npm has no lockfile; used the
project's pnpm lockfile instead. Do not treat that failed npm check as clean.

Targeted deployed-lockfile inspection found FLOC `symfony/mime v8.1.7` and
both Chargy `v7.4.19`, which fall in the ranges affected by CVE-2026-45070.
Fixes are available in `8.1.10` and `7.4.22`, respectively. The clean local FLOC
audit reflects its existing uncommitted updates, not its deployed release.
Rebuild/release and Peter's redeploy are still required for those app fixes.

## Final Verification

- All 18 services `1/1`; Swarm node Ready/Active/Leader; Vaultwarden and MariaDB
  container health checks are healthy. Root 48% used / 76G free; about 12 GiB
  available memory.
- PHP versions remain FLOC `8.5.12`, TIM `8.4.27`, NoLimits/phpMyAdmin/both
  Chargy `8.3.36`. All three FPM configuration checks passed. No app image
  releases were deployed by this maintenance round.
- Both Chargy startup upgrade processes exited 0 after reboot.
- Origin: FLOC, Vaultwarden, Portainer, phpMyAdmin, Duplicati, timesheets,
  reports, TIM, and NoLimits all `200`; both Chargy roots `302`.
- Public TLS: FLOC, Vaultwarden, TIM, NoLimits `200`; both Chargy roots `302`;
  management/timesheet routes `302` through their existing access controls.
  The phpMyAdmin hostname is `pma.format.lu`; the initial mistaken
  `phpmyadmin.format.lu` probe was corrected and is not a service failure.
- NoLimits persistent core now reports `7.1.4` (observed, not upgraded here);
  XML-RPC remains `403`, REST user listing `401`.
- Fresh 60-second error samples for ingress, Portainer server/agent, MariaDB,
  MySQL, Vaultwarden, and Duplicati had zero matching fatal/panic/corruption/
  exception/error lines. This is a bounded sample, not proof of no errors ever.
- Stored origin certificates expire December 17 through January 7; none is
  close to expiry. Emergency patched Apache image archive passed `gzip -t`.
- No automated authenticated browser workflow was tested. Peter subsequently
  confirmed the Vaultwarden smoke test passed after live version verification;
  this is user-reported functional verification. Portainer/other application
  workflows were not separately confirmed in this exchange.
- Follow-up reconfirmed Cloudflared `2026.10.7` in the running binary and saved
  definition, with all four connections established. Vaultwarden `1.37.4` /
  Web Vault `2026.7.0` match upstream releases; its running image digest matches
  current GHCR publication and its saved Portainer definition is synchronized.

## Remaining Actions

- Prioritize application dependency fixes for FLOC/Chargy, timesheets, reports,
  and TIM; assess actual deployed dependency versions and affected code paths
  rather than equating audit counts with exploitable production vulnerabilities.
- Verify the next Duplicati job succeeds after its deferred schema migration;
  perform a separate restore test. Existing backup time-zone alignment merits
  review: latest remote job began `18:30 UTC`, while host dump/archive cron jobs
  run at `20:00`/`20:10 UTC`, so that job includes the previous day's archives.
  No schedule was changed in this round.
- Resolve registry publication for the three local-only patched Apache images.
- Redis `vm.overcommit_memory=0` warning remains; no sysctl tuning was applied.
- Peter authorized committing and pushing these maintenance records after the
  successful Vaultwarden smoke test. Unrelated host changes and the separate
  October 19 FLOC migration record are excluded from this delivery.

## Sources

- [Docker 29 release notes](https://docs.docker.com/engine/release-notes/29/)
- [Portainer 2.45.3 LTS](https://github.com/portainer/portainer/releases/tag/2.45.3)
- [Traefik 3.7.17](https://github.com/traefik/traefik/releases/tag/v3.7.17)
- [Traefik migration guide](https://doc.traefik.io/traefik/v3.7/migrate/v3/)
- [Duplicati 2.4.1.0](https://github.com/duplicati/duplicati/releases/tag/v2.4.1.0_stable_2026-10-29)
- [Cloudflared 2026.10.7](https://github.com/cloudflare/cloudflared/releases/tag/2026.10.7)
- [Redis 7.4.12](https://github.com/redis/redis/releases/tag/7.4.12)
- [PHP current source releases](https://www.php.net/downloads.php?source=Y)
- [Symfony Mime advisory](https://symfony.com/cve-2026-45070)
