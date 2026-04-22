# format-timesheet-2026 On format-cloud-1

This runbook documents the `format-timesheet-2026` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Service

- stack: `format-timesheet-2026`
- app service: `format-timesheet-2026_app`
- public hostname: `ts.format.lu`
- live app image: `esst/format-timesheet-2026:latest`
- app backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`
- mounted APK: `/data/files/format/website/wp-content/timesheet.apk:/usr/local/apache2/htdocs/timesheet.apk`

## Version Check

The production app uses `latest`, which is OK for this stack because Peter rebuilds and publishes the image after reviewing dependency updates. During maintenance, compare the deployed digest with the image built from the intended `timesheet-app-2026` repo commit.

Source repo:

- local path: `/Users/czibulapeter/Documents/GitHub/timesheet-app-2026`
- remote: `https://github.com/formatdev/timesheet-app-2026.git`

## Dependency Freshness Check

Run these commands from the source repo:

```bash
cd /Users/czibulapeter/Documents/GitHub/timesheet-app-2026
npm outdated
npm audit
```

Do not update dependencies during the maintenance check unless Peter explicitly chooses to do the dependency bump and rebuild.

## Maintenance Checklist

1. Confirm `format-timesheet-2026_app` is running `1/1`.
2. Record the live image tag and digest.
3. Record the current source repo commit.
4. Run the dependency freshness commands above and record whether updates are available.
5. Compare the live image with Peter's latest accepted build.
6. Confirm `https://ts.format.lu/` returns an expected status.
7. Confirm the mounted `timesheet.apk` is expected and current.
8. Review logs for application errors and static asset/APK download errors.
9. If updating, verify the web app and APK download path.
10. Record all results in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-2026/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-2026/stack.example.yml)
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-2026/maintenance-log.md)
