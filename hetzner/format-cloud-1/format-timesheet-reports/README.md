# format-timesheet-reports On format-cloud-1

This runbook documents the `format-timesheet-reports` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Service

- stack: `format-timesheet-reports`
- app service: `format-timesheet-reports_app`
- public hostname: `tsr.format.lu`
- live app image: `esst/format-timesheet-reports:1.0.0-beta.1`
- app backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`

## Version Check

This stack already uses a version-like image tag. During maintenance, compare `1.0.0-beta.1` with the latest image Peter built after reviewing the `timesheet-reports-2026` repo dependencies.

Source repo:

- local path: `/Users/czibulapeter/Documents/GitHub/timesheet-reports-2026`
- remote: `https://github.com/formatdev/timesheet-reports-2026.git`

## Dependency Freshness Check

Run these commands from the source repo:

```bash
cd /Users/czibulapeter/Documents/GitHub/timesheet-reports-2026
npm outdated
npm audit
```

Do not update dependencies during the maintenance check unless Peter explicitly chooses to do the dependency bump and rebuild.

## Maintenance Checklist

1. Confirm `format-timesheet-reports_app` is running `1/1`.
2. Record the live image tag and digest.
3. Record the current source repo commit.
4. Run the dependency freshness commands above and record whether updates are available.
5. Compare the live image with Peter's latest accepted build.
6. Confirm `https://tsr.format.lu/` returns an expected status.
7. Review logs for application errors, report-generation failures, auth failures, and upstream API errors.
8. Confirm whether the app has persistent data or only generated/runtime data.
9. If updating, verify generated reports and rollback image before deploying.
10. Record all results in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-reports/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-reports/stack.example.yml)
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-reports/maintenance-log.md)
