# next-floc Maintenance Log

Use this log for `next-floc` checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record database passwords, API keys, tokens, SQL dumps, or other secrets here.

## 2026-04-18 - Twice-Monthly Check

Date: 2026-04-18

Maintainer: Codex with Peter

Repo/ref checked: `/Users/czibulapeter/Documents/GitHub/floc`, branch `main`, commit `fa6adda9748a2e10da8f667772c62908365346cd`

Source commit recorded: Yes

Dependency freshness checked: Yes. Ran `composer outdated --direct`, `composer audit`, `pnpm outdated`, `npm outdated`, and `npm audit` in `apps/next`.

Dependency updates available: Yes. Composer patch/minor updates are available for Laravel-related packages; a major update is available for `inertiajs/inertia-laravel` and `phpunit/phpunit`. JS package updates are available for Vite/Vue-related packages.

Stack version before: `esst/floc:latest@sha256:b7f45a39edaa90d14aec9903597c957d676b2c091328f101ec8b795ca502f500`

Stack version after: `esst/floc:latest@sha256:b7f45a39edaa90d14aec9903597c957d676b2c091328f101ec8b795ca502f500`

Checks:

- App service health checked: OK. `next-floc_app` is running `1/1`.
- Database service health checked: OK. `next-floc_db` is running `1/1`.
- Running image tag/digest checked: OK. App image is `esst/floc:latest@sha256:b7f45a39edaa90d14aec9903597c957d676b2c091328f101ec8b795ca502f500`; MySQL image is `mysql:8-oracle@sha256:da906917ca4ace3ba55538b7c2ee97a9bc865ef14a4b6920b021f0249d603f3d`.
- Latest approved repo/CI build checked: Follow-up needed. The current live digest still needs to be mapped to Peter's latest accepted build after dependency review.
- Public route checked: OK. `https://floc.lu/` returned `200` for both header and full GET checks.
- App logs reviewed: OK. No recent fatal/error/exception lines matched the maintenance search.
- Database logs reviewed: OK. No recent crash/corruption/disk warning lines matched the maintenance search.
- Backup coverage checked: Partial. Expected paths exist: uploads `130M`, storage `240K`, database backups `4.0K`, MySQL data `213M`. The database backup folder size is very small, so backup freshness should be verified.
- Composer security audit checked: OK. No Composer advisories found.
- npm security audit checked: Follow-up needed. `npm audit` reported 5 vulnerabilities: 2 moderate and 3 high, with fixes available via `npm audit fix`.
- Update applied: No. Dependency checks were inspection-only.
- Rollback image recorded: Current rollback candidate is the same live digest above.
- Notes: `pnpm outdated` and `npm outdated` reported packages as missing because dependencies are not installed in `apps/next`; they still identified available newer package versions from the lock/manifests.
- Follow-up: Peter to decide whether to run dependency updates and rebuild/push `esst/floc:latest`; verify database backup freshness before closing this service as fully clean.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Repo/ref checked: `/Users/czibulapeter/Documents/GitHub/floc`, branch `main`, commit `9297725c0f3a6a02b2593c9f2167326ac790c763`

Source commit recorded: Yes

Dependency freshness checked: Yes. Ran `composer outdated --direct`,
`composer audit`, `pnpm outdated`, `npm outdated`, and `npm audit` in
`apps/next`.

Dependency updates available: Yes. Composer and frontend package updates are
available; `composer audit` is clean, while the frontend audit still reports one
moderate `postcss` advisory.

Stack version before: `esst/floc:latest@sha256:c985a04eaa2d9b6421f51e14f927b33b47345b526dcd4ba52c37a39879eca5df`

Stack version after: `esst/floc:latest@sha256:c985a04eaa2d9b6421f51e14f927b33b47345b526dcd4ba52c37a39879eca5df`

Checks:

- App service health checked: OK. `next-floc_app` is `1/1`.
- Database service health checked: OK. `next-floc_db` is `1/1`.
- Running image tag/digest checked: OK. Live app image is the digest above.
- Latest approved repo/CI build checked: Partial. GitHub shows a successful
  `Next App Release Image` run for the same SHA, but the `Next App CI` workflow
  for that same commit failed.
- Public route checked: OK. `https://floc.lu/` returned `200`.
- App logs reviewed: OK overall. Recent traffic shows routine public requests
  and a few opportunistic `404` probes, but no PHP exception or migration error.
- Database logs reviewed: OK overall. Startup is clean; the remaining warnings
  are the usual self-signed CA note and permissive pid-path warning.
- Backup coverage checked: OK. Uploads, storage, database backups, and MySQL
  data paths all exist on the host.
- Update applied: No.
- Rollback image recorded: `esst/floc:latest@sha256:c985a04eaa2d9b6421f51e14f927b33b47345b526dcd4ba52c37a39879eca5df`
- Notes: Because the deployment still uses the mutable `latest` tag, direct
  registry-digest comparison was not completed from this workstation.
- Follow-up: Review why `Next App CI` is failing for the current production SHA
  before the next deploy, then decide whether the available dependency updates
  should trigger a rebuild.

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
- Database service health checked:
- Running image tag/digest checked:
- Latest approved repo/CI build checked:
- Public route checked:
- App logs reviewed:
- Database logs reviewed:
- Backup coverage checked:
- Update applied:
- Rollback image recorded:
- Notes:
- Follow-up:
