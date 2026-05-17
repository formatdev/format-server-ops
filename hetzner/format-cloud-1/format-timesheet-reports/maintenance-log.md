# format-timesheet-reports Maintenance Log

Use this log for `format-timesheet-reports` checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record credentials, tokens, report payloads, customer data, or other secrets here.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Repo/ref checked: `/Users/czibulapeter/Documents/GitHub/timesheet-reports-2026`, branch `main`, commit `f6188ad6d6d62170b5c695967648fa1da2f2ef09`

Source commit recorded: Yes

Dependency freshness checked: Partial. Ran `npm outdated` and `npm audit`, but
the local repo currently has missing installed dependencies, so the outdated
report is incomplete.

Dependency updates available: Yes. `npm audit` reports eight advisories
including `nodemailer`, `vite`, `rollup`, `immutable`, `picomatch`, `yaml`,
`postcss`, and `path-to-regexp`.

Stack version before: `esst/format-timesheet-reports:1.0.0-beta.1@sha256:1207ee923e1a362c21cdb2a3d5719980dcdd9d8ccea2a5ab7f0a4b692a740103`

Stack version after: `esst/format-timesheet-reports:1.0.0-beta.1@sha256:1207ee923e1a362c21cdb2a3d5719980dcdd9d8ccea2a5ab7f0a4b692a740103`

Checks:

- Service health checked: OK. `format-timesheet-reports_app` is `1/1`.
- Running image tag/digest checked: OK. Recorded from the running container
  image metadata.
- Latest approved repo/CI build checked: Follow-up needed. No recent GitHub
  workflow run was returned for this repo in this maintenance pass.
- Public route checked: OK. `https://tsr.format.lu/` redirects to Cloudflare
  Access.
- Logs reviewed: Follow-up noted. The recent log window shows the usual Apache
  `ServerName` warning at startup but no application crash lines.
- Report smoke test checked: Partial. Route protection and reachability were
  checked; no authenticated report-generation test was performed.
- Backup/data persistence checked: OK. The service currently has no persistent
  mounts and appears to be runtime-only.
- Update applied: No.
- Rollback image recorded: `esst/format-timesheet-reports:1.0.0-beta.1@sha256:1207ee923e1a362c21cdb2a3d5719980dcdd9d8ccea2a5ab7f0a4b692a740103`
- Notes: Local dependency installation state limits how much confidence we can
  put in the `npm outdated` output.
- Follow-up: Install repo dependencies locally before the next maintenance pass,
  review the eight npm advisories, and verify registry/build traceability before
  the next redeploy.

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

- Service health checked:
- Running image tag/digest checked:
- Latest approved repo/CI build checked:
- Public route checked:
- Logs reviewed:
- Report smoke test checked:
- Backup/data persistence checked:
- Update applied:
- Rollback image recorded:
- Notes:
- Follow-up:
