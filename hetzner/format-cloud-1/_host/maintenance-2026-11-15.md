# November 15 Maintenance Round

Target: production `format-cloud-1` via `hetzner-cloud-1`. The single
Swarm manager now hosts 24 services, including six PePs services.

## Host Updates And Recovery

- Before: Ubuntu 24.04.5, kernel `6.8.0-147-generic`, Docker `29.9.2`.
  All 24 services were `1/1`; no failed units or interactive SSH sessions.
  Reboot was already required for kernel `6.8.0-149`, linux-base, and libc6.
- Applied seven package upgrades with no additions or removals. Docker
  `29.9.3`, containerd `2.4.2-4` (package), Compose `5.7.1`, Buildx
  `0.39.0`, and SQLite library `3.45.1-1ubuntu2.9` are installed.
- Docker restarted during packaging. MariaDB, both Chargy apps, NoLimits,
  and phpMyAdmin tasks were rejected on the shared overlay with
  `error creating vxlan interface: file exists`; Vaultwarden was warming up.
  Paused image updates and used the planned reboot, without changing the
  network, to clear the error. New kernel `6.8.0-149-generic`; boot ID
  `7a6ec7bb-8f24-40f7-bb18-2c33941cc465`. All 24 tasks converged.
- Both Chargy apps then still answered HTTP 503. Their startup commands had
  exited 1 and left Laravel maintenance markers. Verified 36 migrations
  already applied, none pending, and Horizon running for each app. Ran
  `php artisan up` as the service user, without restarting tasks, changing
  images, or running migrations. Both origins and public roots returned
  `302`; both login pages returned `200`. Review startup retry/failure
  handling in Chargy separately so a dependency warm-up cannot leave it down.
- No package audit findings, failed systemd units or reboot marker remain.
  Only Ubuntu-phased `distro-info`, `python3-distro-info`, and `snapd` were
  deferred. SSH key-only, UFW, Fail2ban, and AppArmor remain in place. Root
  51% used / 72G free; about 12 GiB available memory. No prune or autoremove.

## Deployed Images

| Service | Before | After | Running manifest digest |
| --- | --- | --- | --- |
| Traefik | 3.7.17 | 3.7.19 | `sha256:aa942a00bce033c909bf1f7e861d93761be4b31a035f10d2410d33e38a8f41cf` |
| Vaultwarden | 1.37.4 | 1.37.5 | `sha256:4fe17f415f90087377d37c755e0ea3cf189dcc6794e49cdd2a9adbb4937d9e1f` |
| Cloudflared | 2026.10.7 | 2026.11.0 | `sha256:b94b96edf2c9c4360f8879c8580cfaa99077f19c849ec595ca2f711b27d4f344` |
| MariaDB | 11.8.9 | 11.8.9 refreshed during task recreation | `sha256:d36f18d65a0459510b8b0f643b226a6d299e3206486e2b64ff20754a6d291707` |

- Traefik includes the 3.7.18 fixes. This deployment uses Swarm, not
  Ingress-NGINX. Reviewed BasicAuth length and default path normalization
  changes; no routing arguments changed. FLOC, Vaultwarden and PePs origin
  probes passed before proceeding to Cloudflared.
- Vaultwarden bundled Web Vault now reports `2026.10.1`. Existing effective
  `CF-Connecting-IP` and disabled public signup retained. Reviewed the stricter
  startup validation, verified the cold archive, upgraded, then verified the
  container health and SQLite `quick_check`. A transient origin `404` at
  task convergence cleared; final origin and public roots returned `200`.
- Cloudflared binary reports `2026.11.0`; four distinct tunnel connections
  registered. Access-protected admin routes still redirect.
- Portainer server/agent stay on `2.45.3 LTS`; Duplicati stays on `2.4.1.0`
  stable; both Redis services stay on `7.4.12-alpine3.21`. No newer release
  found on those selected lines. Redis overcommit warning remains untuned.
- Saved Portainer Compose image references updated only for IDs 11 and 26
  using the [reviewed changes](portainer-images-2026-11-15.json). Stopped
  Portainer, waited for exit, cold-archived its data, checked the old image
  values, validated image-only YAML changes and both Compose files, then
  restarted and verified the status API. No Bolt DB edits.
- MariaDB credentialed table check: 412 OK, zero non-OK lines. No separate
  database redeploy. PePs MySQL is `8.4.13`; FLOC remains `8.4.11` on its
  existing digest. The newer FLOC MySQL tag content needs a dedicated
  compatibility and rollback check; no MySQL update was applied.

## Backups And Recovery

- Daily cron unchanged: MariaDB `18:00 UTC`, PePs `18:05`, Portainer
  `18:10`, then Duplicati `18:30`. Existing retention unchanged.
- November 14 scheduled Duplicati backup completed at `18:44:21 UTC`
  (`19:44 CET`), success with zero warnings/errors. Job schema is now 22.
  Its completed fileset (operation 303, remote manifest marked Verified)
  contains these same-day preparation files, with matching local lengths and
  successful local gzip checks:
  - `mariadb-all-databases-2026-11-14-180001.sql.gz`
  - `peps-20261114T180501Z.sql.gz`
  - `portainer-data-20261114-181001.tar.gz`
- This verifies catalog inclusion, not an independent restore. Last recorded
  restore is April 18. The existing broad source may include live PePs MySQL
  files; use the consistent SQL dump for database recovery.
- Root-only, gzip-verified rollback files under `/data/backups/maintenance-20261115/`:
  - `floc-all-databases-20261115-082459.sql.gz` (dump completion marker present)
  - `vaultwarden-before-1.37.5-20261115-082904.tar.gz` (cold data including
    SQLite and persisted configuration)
  - `portainer-before-compose-20261115-083134.tar.gz` (cold data, excluding
    nested backups)
- Previous public service images retained. For Vaultwarden rollback, preserve
  the current data before restoring the cold archive if database compatibility
  requires it; do not overwrite post-upgrade data with an image-only rollback.
  The October local PHP-image recovery archive also passed `gzip -t`; registry
  publication remains open.

## Applications And Final Checks

- FLOC `v3.0.11` and PePs `0.2.0` use PHP `8.5.12`; both Chargy
  `2.3.1`, NoLimits and phpMyAdmin use `8.3.36`; TIM uses `8.4.27`.
  CLI runtime checks passed and all four FPM configuration tests passed.
- Before Peter's redeploy, FLOC and both Chargy contained affected Symfony Mime
  `8.1.7` and `7.4.19` respectively. Published FLOC `v3.0.12` and Chargy `2.3.2` have
  fixes in their release source lockfiles (`8.1.10` / `7.4.22`); associated
  build workflows succeeded. Peter's redeploy is verified below.
  Local FLOC and Chargy Composer audits reported no advisories.
- TIM live Composer metadata confirms Twig `3.24.0` and Slim `4.15.1`;
  Twig is below the `3.26.0` fix for CVE-2026-46633. The active TIM source
  audit reported 18 advisories. Prioritize a tested rebuild and assess whether
  untrusted Twig templates can be compiled; production exploitability was
  not established.
- Source production-only npm audit: timesheet app 11 affected packages (1
  critical, 10 high); reports 13 (2 critical, 9 high, 2 moderate). Check
  deployed dependency contents before assessing exposure. PePs source Composer
  audit reported one low Laravel advisory (CVE-2026-128083).
- Final Swarm: all 24 services `1/1`. MariaDB, Vaultwarden, and PePs web/DB
  health checks passed. Sampled post-convergence logs for ingress, management,
  vault, backups, MariaDB, MySQL, FLOC, and PePs had no matching fresh fatal,
  panic, corruption or SQLSTATE lines. Public and origin probes passed with
  expected 200/302 responses after Chargy recovery. No automated authenticated
  workflows, restore test, or hardening policy change were performed.

## Operator Smoke Test And Application Redeploys

Peter confirmed the Vaultwarden smoke test passed. This is user-reported
functional verification.

Peter redeployed FLOC and both Chargy instances. Read-only verification at
`2026-11-15 09:41 CET` checked the running image and installed dependency:

| Service | Release | Installed Symfony Mime | Running image digest |
| --- | --- | --- | --- |
| `next-floc_app` | `v3.0.12` | `8.1.10` | `sha256:bf0fe4743f5b8a749f49814be1d23f7cb48f87e3e60b681db8a384d7123201ef` |
| `chargy_app` and `chargy-loeffler_app` | `2.3.2` | `7.4.22` | `sha256:f1d889506f2fb3329765361ec4dddbf77b08d4c8457fdaf8e3779cb0a0ed2169` |

The running revisions match the release source:
FLOC `18f80f23c354072e5d028a266253e8c6613f701d` and Chargy
`e9a32ee7295cde5fba4df62322fc8c6f3c6e90fc`. The affected Mime versions are
no longer deployed in these apps. PHP remains `8.5.12` for FLOC and
`8.3.36` for both Chargy instances. All three FPM configuration checks
passed, all three origin login pages returned `200`, and all 24 services
were `1/1`. Authenticated workflows for these apps were not tested. TIM's
Twig dependency update and the Duplicati restore test remain open.

## References

- [Docker 29.9.3 notes](https://docs.docker.com/engine/release-notes/29/#2993)
- [Traefik 3.7.19](https://github.com/traefik/traefik/releases/tag/v3.7.19)
  and [3.7.18 migration notes](https://doc.traefik.io/traefik/v3.7/migrate/v3/#v3718)
- [Vaultwarden 1.37.5](https://github.com/dani-garcia/vaultwarden/releases/tag/1.37.5)
- [Cloudflared 2026.11.0](https://github.com/cloudflare/cloudflared/releases/tag/2026.11.0)
- [FLOC release build](https://github.com/formatdev/floc/actions/runs/41206571242)
  and [Chargy 2.3.2 release](https://github.com/formatdev/Chargy/releases/tag/v2.3.2)
- [Twig advisory](https://symfony.com/cve-2026-46633)
