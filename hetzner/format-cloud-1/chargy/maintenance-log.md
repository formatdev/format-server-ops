# chargy Maintenance Log

## 2026-10-31 - End-Of-Month Maintenance

- Observed app release `2.3.1`, PHP `8.3.36`, source revision
  `f94ad4ba467b03e115b784fa703d92f2f05c9b24`; successful release CI matches.
  No application image deployment by this round; Peter retains ownership.
- Redis patched `7.4.11` -> `7.4.12-alpine3.21` after SAVE/snapshot;
  version/PONG verified, `noeviction` retained. Saved Compose ID 9 reconciled.
- App startup upgrade exited 0 after reboot; PHP-FPM config passed, root `302`
  and origin login `200`. All host services `1/1`.
- Deployed `symfony/mime v7.4.19` is affected by CVE-2026-45070; patch at
  `7.4.22` or newer and rebuild/redeploy. Source pnpm audit also has findings.
- [Full round record and dependency checks](../_host/maintenance-2026-10-31.md).

Use this log for `chargy` checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record credentials, tokens, customer data, Redis dumps, or other secrets here.

## 2026-10-21 - Critical PHP Security Deployment

- Deployed `esst/chargy:2.2.8`, digest
  `sha256:a0e2059c2e36ff797c6b506e2d05951358145066ff36c6507847fe8d82cf041a`.
  Previous image: `esst/chargy:latest@sha256:5511c90248ccd107e32b47c825106f98518f869ada2ca9aab3105e12e95a99e2`.
- Actual PHP moved from `8.3.23` to `8.3.36`, fixing CVE-2026-109618
  and CVE-2026-109619. The release workflow completed successfully:
  [build 39631094093](https://github.com/formatdev/Chargy/actions/runs/39631094093).
- Direct Docker pulls were denied, but Swarm successfully used its retained
  registry authentication. A start-first update preserved the existing task
  during download. Original stop-first/pause update policy was restored.
- Service converged at `1/1`; PHP-FPM checks passed, startup app-upgrade
  exited 0, and the origin route returned the expected `302`.
- A fresh all-databases MariaDB dump passed gzip verification before rollout:
  `/data/backups/mysql/mariadb-all-databases-2026-10-21-160318.sql.gz`.
- Saved Portainer app definition ID `9` remains `esst/chargy:latest`.
  No stored-file change was made. The published `latest` image is release
  `2.2.8`; a future manual redeploy must pull it.
- Subsequent live inspection showed the service back on `latest` pinned to
  the same fixed digest, consistent with the saved definition. That later
  service change was observed rather than performed by this task.
- This deployment occurred before discovering Peter's newer instruction in
  another task to redeploy Chargy/Floc manually. Production deployment work
  stopped on discovering that instruction; no FLOC deployment followed.
- See the host PHP security verification report for cross-service checks.
  Authenticated workflows are not claimed as tested by these CLI probes.

## 2026-10-10 - Redis Pin Reconciliation

- Found live Redis `7.4.8` under the moving `7.4-alpine3.21` tag and an older
  pinned digest in the saved Portainer Compose definition (ID `9`).
- Saved an RDB snapshot and restored `redis:7.4.11-alpine3.21` in the live
  service, stack image label, and saved definition. YAML validation passed.
- Service converged; binary reports `7.4.11`; `PING` returned `PONG`.
- Chargy app digest remains unchanged from September 13. Startup upgrade
  exited 0 after the host reboot; final origin/public routes returned `302`.
- Portainer data was archived before the saved-definition correction; see
  the host log for backup paths and full maintenance verification.

## 2026-08-23 - Redis Patch Update

Date: 2026-08-23 15:40 CEST

Maintainer: Codex with Peter

Stack version before: `redis:7.4.8-alpine3.21`

Stack version after: `redis:7.4.11-alpine3.21`

Checks:

- Redis service update applied: OK. Updated `chargy_redis` to `redis:7.4.11-alpine3.21`.
- Redis service health checked: OK. `chargy_redis` returned to `1/1`.
- App service health checked: OK. `chargy_app` stayed `1/1` during the Redis update.
- Redis startup logs checked: OK. Redis `7.4.11` loaded the existing RDB cleanly and returned to `Ready to accept connections`.
- Public route checked: OK. `https://chargy.format.lu/` returned the expected `302`.
- Notes: The host still logs the known `vm.overcommit_memory must be enabled` warning at Redis startup.
- Follow-up: Keep `chargy` and `chargy-loeffler` Redis tags aligned, and decide later whether to enable `vm.overcommit_memory=1` at the host level.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Repo/ref checked: `/Users/czibulapeter/Documents/GitHub/Chargy`, branch `main`, commit `ecc496006e0f820dc1f03333b96e00640525df29`

Source commit recorded: Yes

Dependency freshness checked: Yes. Ran `composer outdated --direct`,
`composer audit`, `pnpm outdated`, and `pnpm audit`.

Dependency updates available: Yes. Composer updates are available across Laravel
and related packages, `phpoffice/phpspreadsheet` currently has four advisories
in `composer audit`, and the frontend audit reports one moderate `postcss`
advisory.

Stack version before: `esst/chargy:latest@sha256:e51bf141960890b40e242ab555bdab4c1c26849eeabb59e14c8bfa8fd3579672`

Stack version after: `esst/chargy:latest@sha256:e51bf141960890b40e242ab555bdab4c1c26849eeabb59e14c8bfa8fd3579672`

Checks:

- App service health checked: OK. `chargy_app` is `1/1`.
- Redis service health checked: OK. `chargy_redis` is `1/1`.
- Running image tag/digest checked: OK. Live app image is the digest above.
- Latest approved repo/CI build checked: Partial. GitHub shows a successful
  `Build and publish release` run for the same SHA on branch `v2.1.2`, but the
  private registry digest could not be compared directly from this workstation.
- Public route checked: OK. `https://chargy.format.lu/` returns `302` to the
  login route.
- App logs reviewed: OK overall. Startup was clean; Nginx logs a deprecated
  `listen ... http2` syntax warning.
- Redis logs reviewed: Follow-up noted. Redis starts cleanly, but warns that
  `vm.overcommit_memory` is not enabled on the host.
- Redis backup relevance checked: Partial. The Redis volume exists and is small
  (`8K`), but off-host restore verification was not performed in this run.
- Update applied: No.
- Rollback image recorded: `esst/chargy:latest@sha256:e51bf141960890b40e242ab555bdab4c1c26849eeabb59e14c8bfa8fd3579672`
- Notes: This stack and `chargy-loeffler` still share the same `esst/chargy`
  image digest.
- Follow-up: Review the `phpoffice/phpspreadsheet` advisories before the next
  rebuild and decide whether to enable `vm.overcommit_memory=1` on the host for
  Redis safety.

## 2026-05-03 - Redis Patch Update

Date: 2026-05-03 11:31 CEST

Maintainer: Codex with Peter

Stack version before: `redis:7.4-alpine3.21`

Stack version after: `redis:7.4.8-alpine3.21`

Checks:

- Redis service update applied: OK. Updated `chargy_redis` to
  `redis:7.4.8-alpine3.21`.
- Redis service health checked: OK. `chargy_redis` returned to `1/1`.
- App service health checked: OK. `chargy_app` stayed `1/1` during the Redis
  update.
- Redis startup logs checked: OK. Redis `7.4.8` loaded the existing RDB cleanly
  and returned to `Ready to accept connections`.
- Public route checked: OK. `https://chargy.format.lu/` continued returning the
  expected Cloudflare challenge/login path.
- Notes: The host still logs the known
  `vm.overcommit_memory must be enabled` warning at Redis startup.
- Follow-up: Keep `chargy` and `chargy-loeffler` Redis tags aligned, and decide
  later whether to enable `vm.overcommit_memory=1` at the host level.

## Maintenance Template

Date:

Maintainer:

Repo/ref checked:

Source commit recorded:

Dependency freshness checked:

Dependency updates available:

Stack version before:

Stack version after:

Checks:

- App service health checked:
- Redis service health checked:
- Running image tag/digest checked:
- Latest approved repo/CI build checked:
- Public route checked:
- App logs reviewed:
- Redis logs reviewed:
- Redis backup relevance checked:
- Update applied:
- Rollback image recorded:
- Notes:
- Follow-up:
