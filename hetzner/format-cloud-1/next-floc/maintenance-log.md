# next-floc Maintenance Log

## 2026-10-31 - End-Of-Month Maintenance

- App remains `v3.0.11`, PHP `8.5.12`, unchanged security-release digest;
  source/release CI matches revision `3144f7cef1c751ce0ab01a767bf813b1b632929d`.
  No app deployment here; Peter retains deployment ownership.
- App/database recovered after host restart, both `1/1`; FPM config test
  passed. Homepage and origin login `200`; fresh MySQL dump gzip verified.
- Local workspace Composer/npm audits are clean but include pre-existing
  uncommitted dependency changes. Deployed `symfony/mime v8.1.7` is affected
  by CVE-2026-45070; rebuild with `8.1.10` or newer and redeploy separately.
- [Full round record](../_host/maintenance-2026-10-31.md).

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

## 2026-10-19: Event Furniture Sort Order Migration

Peter approved applying the single pending migration after an event save failed
with `Unknown column 'sort_order'` while inserting into `event_item`.

- Target: `next-floc_app`, production database `floc_next` on `format-cloud-1`.
- Refreshed a single-transaction `event_item` dump before applying the migration.
  Local backup: `floc/tmp/floc-event-item-20261019-before-apply.sql.gz`.
  Verified gzip integrity and the dump completion marker; restore was not tested.
- Applied only `2026_03_26_120000_add_sort_order_to_event_item_table.php`
  using `artisan migrate --path=database/migrations/2026_03_26_120000_add_sort_order_to_event_item_table.php --force --no-interaction`.
- Migration completed in 64 ms and is recorded as batch 2. The column now exists,
  all 615 rows have `sort_order = id`, and the row count and SHA-256 fingerprint
  of all pre-existing columns match the pre-migration snapshot.
- A read-only `EXPLAIN INSERT` using the reported event 22/item 87/price 32
  statement passed. No business row was inserted during verification.
- App and database services remained `1/1`. Homepage and login returned HTTP 200.
- App remains v3.0.10 with digest
  `sha256:1d3ad435d7de9d34fcf8a8dfb95338690e334639a8d8e0424432e1901542bc13`.
- Follow-up: Peter or the coworker to retry saving the event in the browser.
  Earlier local furniture/UI fixes remain separate from this database repair.

## 2026-10-21 - PHP Security Redeployment Verification

Peter reported redeploying the stack. Read-only live checks at 16:32 UTC
confirmed the security release is running; this task did not deploy FLOC.

- Before: `v3.0.10`, PHP `8.5.2`, digest
  `sha256:1d3ad435d7de9d34fcf8a8dfb95338690e334639a8d8e0424432e1901542bc13`.
- After: `esst/floc:latest`, release `v3.0.11`, digest
  `sha256:0414d60d3f0829b73b2e84ccc99e183817ea90f89c32adf4ad0f7d6e49ae6b84`,
  source revision `3144f7cef1c751ce0ab01a767bf813b1b632929d`.
- Running container started at `2026-10-21T16:31:47Z`. PHP CLI and FPM report
  `8.5.12`; the FPM configuration test passed.
- App and database services are `1/1`; all 18 host services are `1/1`.
- Public and origin homepage checks returned `200`; origin `/login` is `200`.
  No matching fatal, extension-load, segmentation-fault, or SQLSTATE errors
  appeared in the sampled current-container logs from the preceding ten minutes.
- No authenticated user workflow or restore test was performed.
- [Cross-service PHP verification](../_host/php-security-verification-2026-10-21.md).

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
