# chargy On format-cloud-1

This runbook documents the `chargy` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Services

- stack: `chargy`
- app service: `chargy_app`
- Redis service: `chargy_redis`
- public hostname: `chargy.format.lu`
- live app image: `esst/chargy:latest` (verified release `2.3.1`)
- observed app digest (2026-10-31): `sha256:75ce52b8889a6470acf0f057081e0da6e2eb29c8a43170d657c3e19e0ad56741`
- observed PHP runtime: `8.3.36`
- Redis image: `redis:7.4.12-alpine3.21`
- backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`
- Redis volume: `chargy_redis:/data`

## Version Check

The production app follows `latest`; its verified release is `2.3.1`, and the
same digest is used by the `chargy-loeffler` stack. During maintenance, compare the
live digest and actual PHP runtime with the intended reviewed build.

Source repo:

- local path: `/Users/czibulapeter/Documents/GitHub/Chargy`
- remote: `https://github.com/formatdev/Chargy.git`

## Dependency Freshness Check

Run these commands from the source repo:

```bash
cd /Users/czibulapeter/Documents/GitHub/Chargy
composer outdated --direct
composer audit
pnpm outdated
pnpm audit
```

Do not update dependencies during the maintenance check unless Peter explicitly chooses to do the dependency bump and rebuild.

## Maintenance Checklist

1. Confirm `chargy_app` and `chargy_redis` are running `1/1`.
2. Record the live app image tag and digest.
3. Record the current source repo commit.
4. Run the dependency freshness commands above and record whether updates are available.
5. Compare the live image with Peter's latest accepted `Chargy` build.
6. Confirm `https://chargy.format.lu/` returns an expected status.
7. Review app logs for errors, auth failures, queue/session issues, and Redis connection errors.
8. Review Redis logs and confirm the Redis volume is backed up if it stores important state.
9. If updating, compare behavior with the `chargy-loeffler` stack and record whether both were updated together.
10. Record all results in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/chargy/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/chargy/stack.example.yml)
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/chargy/maintenance-log.md)
