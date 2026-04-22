# chargy On format-cloud-1

This runbook documents the `chargy` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Services

- stack: `chargy`
- app service: `chargy_app`
- Redis service: `chargy_redis`
- public hostname: `chargy.format.lu`
- live app image: `esst/chargy:latest`
- observed app digest: `sha256:49b95d2bcf606935eb0a60fe9d05acd8eaaabcac8c92e36dd705643e4324d16a`
- Redis image: `redis:7.4-alpine3.21`
- backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`
- Redis volume: `chargy_redis:/data`

## Version Check

The production app uses `latest`, and the same app image digest is also used by the `chargy-loeffler` stack. This is OK because Peter rebuilds and publishes the image after reviewing dependency updates. During maintenance, compare the live digest with the image built from the intended `Chargy` repo commit.

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
