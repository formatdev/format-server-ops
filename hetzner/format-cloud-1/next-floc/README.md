# next-floc On format-cloud-1

This runbook documents the `next-floc` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Service

- stack: `next-floc`
- app service: `next-floc_app`
- database service: `next-floc_db`
- public hostname: `floc.lu`
- live app image: `esst/floc:latest`
- observed app digest: `sha256:b7f45a39edaa90d14aec9903597c957d676b2c091328f101ec8b795ca502f500`
- database image: `mysql:8-oracle`
- app backend port: `8080`
- reverse proxy: Traefik on external Docker network `proxy`

## Persistent Data

- uploads: `/data/files/floc-next/uploads:/app/public/uploads`
- app storage: `/data/files/floc-next/storage:/app/storage`
- database backups: `/data/files/floc-next/database/backups:/home/noroot/database`
- MySQL data: `/data/files/floc-next/mysql:/var/lib/mysql`

## Version Check

The production app uses `latest`, which is OK for this stack because Peter rebuilds and publishes the image after reviewing dependency updates. During maintenance, compare the deployed digest with the image built from the intended `floc` repo commit.

Source repo:

- local path: `/Users/czibulapeter/Documents/GitHub/floc`
- remote: `https://github.com/formatdev/floc.git`

## Dependency Freshness Check

Run these commands from the active app path:

```bash
cd /Users/czibulapeter/Documents/GitHub/floc/apps/next
composer outdated --direct
composer audit
pnpm outdated
pnpm audit
```

If this stack still uses npm for a specific build path, also run:

```bash
npm outdated
npm audit
```

Do not update dependencies during the maintenance check unless Peter explicitly chooses to do the dependency bump and rebuild.

## Maintenance Checklist

1. Confirm `next-floc_app` and `next-floc_db` are running `1/1`.
2. Record the live app image tag and digest.
3. Record the current source repo commit.
4. Run the dependency freshness commands above and record whether updates are available.
5. Compare the digest with Peter's latest accepted build.
6. Confirm `https://floc.lu/` returns an expected status.
7. Review app logs for exceptions, migration errors, upload/storage errors, and database connection errors.
8. Review MySQL logs for crashes, corruption, and disk-space warnings.
9. Confirm backups cover uploads, storage, database backups, and MySQL data.
10. If updating, verify migrations and rollback steps before deploying.
11. Record all results in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/next-floc/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/next-floc/stack.example.yml)
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/next-floc/maintenance-log.md)
