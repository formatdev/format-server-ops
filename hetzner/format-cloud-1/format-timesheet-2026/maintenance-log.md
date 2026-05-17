# format-timesheet-2026 Maintenance Log

Use this log for `format-timesheet-2026` checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record credentials, tokens, customer data, or other secrets here.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Repo/ref checked: `/Users/czibulapeter/Documents/GitHub/timesheet-app-2026`, branch `main`, local commit `85cbeb865fb77db1febbffdf662ba96792b55de1`, `origin/main` commit `1d46a04073ae7eedbcd79b32a57fc6e48971b291`

Source commit recorded: Yes

Dependency freshness checked: Yes. Ran `npm outdated` and `npm audit`.

Dependency updates available: Yes. Updates are available for `vite`, `vue`,
`vue-i18n`, `vue-router`, and `@zxing/library`; `npm audit` reported no known
vulnerabilities.

Stack version before: `esst/format-timesheet-2026:latest@sha256:be23574eecc27d91521e6d2584f67b8d4b6863d8c22bd852c1142364fb7e5e82`

Stack version after: `esst/format-timesheet-2026:latest@sha256:be23574eecc27d91521e6d2584f67b8d4b6863d8c22bd852c1142364fb7e5e82`

Checks:

- Service health checked: OK. `format-timesheet-2026_app` is `1/1`.
- Running image tag/digest checked: OK. Recorded from the running container
  image metadata.
- Latest approved repo/CI build checked: Follow-up needed. The local repo is
  ahead of `origin/main` by 2 commits, and no GitHub workflow run was found for
  the current local SHA. The latest visible GitHub image-build history is from
  January 2026 on older release branches.
- Public route checked: OK. `https://ts.format.lu/` redirects to Cloudflare
  Access.
- APK mount checked: OK. `/data/files/format/website/wp-content/timesheet.apk`
  exists and is `2.5M` (mtime `2024-06-16`).
- Logs reviewed: OK. Recent logs only show normal Apache startup.
- Update applied: No.
- Rollback image recorded: `esst/format-timesheet-2026:latest@sha256:be23574eecc27d91521e6d2584f67b8d4b6863d8c22bd852c1142364fb7e5e82`
- Notes: Because the deployment still uses the mutable `latest` tag, the active
  image cannot be confidently tied to the current local commit from the
  available metadata alone.
- Follow-up: Push or reconcile the two local commits ahead of `origin/main`,
  record which commit backs the production `latest` image, and review the
  available frontend package updates before the next rebuild.

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
- APK mount checked:
- Logs reviewed:
- Update applied:
- Rollback image recorded:
- Notes:
- Follow-up:
