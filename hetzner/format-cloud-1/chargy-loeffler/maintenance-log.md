# chargy-loeffler Maintenance Log

Use this log for `chargy-loeffler` checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record credentials, tokens, customer data, Redis dumps, or other secrets here.

## 2026-08-23 - Redis Patch Update

Date: 2026-08-23 15:40 CEST

Maintainer: Codex with Peter

Stack version before: `redis:7.4.8-alpine3.21`

Stack version after: `redis:7.4.11-alpine3.21`

Checks:

- Redis service update applied: OK. Updated `chargy-loeffler_redis` to `redis:7.4.11-alpine3.21`.
- Redis service health checked: OK. `chargy-loeffler_redis` returned to `1/1`.
- App service health checked: OK. `chargy-loeffler_app` stayed `1/1` during the Redis update.
- Redis startup logs checked: OK. Redis `7.4.11` loaded the existing RDB cleanly and returned to `Ready to accept connections`.
- Public route checked: OK. `https://chargy.loeffler.lu/` returned the expected `302`.
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

- App service health checked: OK. `chargy-loeffler_app` is `1/1`.
- Redis service health checked: OK. `chargy-loeffler_redis` is `1/1`.
- Running image tag/digest checked: OK. Live app image is the digest above.
- Latest approved repo/CI build checked: Partial. GitHub shows a successful
  `Build and publish release` run for the same SHA on branch `v2.1.2`, but the
  private registry digest could not be compared directly from this workstation.
- Public route checked: OK. `https://chargy.loeffler.lu/` returns `302` to the
  login route.
- App logs reviewed: Follow-up noted. The app is serving successfully, but the
  recent log window still includes intermittent internal `/index.php` `404`,
  `302`, and `200` sequences that should be reviewed.
- Redis logs reviewed: Follow-up noted. Redis starts cleanly, but warns that
  `vm.overcommit_memory` is not enabled on the host.
- Redis backup relevance checked: Partial. The Redis volume exists and is small
  (`8K`), but off-host restore verification was not performed in this run.
- Update applied: No.
- Rollback image recorded: `esst/chargy:latest@sha256:e51bf141960890b40e242ab555bdab4c1c26849eeabb59e14c8bfa8fd3579672`
- Notes: This stack and `chargy` still share the same `esst/chargy` image
  digest.
- Follow-up: Review the internal `/index.php` request pattern before the next
  deploy, review the `phpoffice/phpspreadsheet` advisories, and decide whether
  to enable `vm.overcommit_memory=1` on the host for Redis safety.

## 2026-05-03 - Redis Patch Update

Date: 2026-05-03 11:31 CEST

Maintainer: Codex with Peter

Stack version before: `redis:7.4-alpine3.21`

Stack version after: `redis:7.4.8-alpine3.21`

Checks:

- Redis service update applied: OK. Updated `chargy-loeffler_redis` to
  `redis:7.4.8-alpine3.21`.
- Redis service health checked: OK. `chargy-loeffler_redis` returned to `1/1`.
- App service health checked: OK. `chargy-loeffler_app` stayed `1/1` during the
  Redis update.
- Redis startup logs checked: OK. Redis `7.4.8` loaded the existing RDB cleanly
  and returned to `Ready to accept connections`.
- Public route checked: OK. `https://chargy.loeffler.lu/` continued returning
  the expected Cloudflare challenge/login path.
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
