# format-dsk On format-cloud-1

This runbook documents the `format-dsk` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Services

- stack: `format-dsk`
- TIM service: `format-dsk_tim`
- TIM hostname: `dsk-tim.format.lu`
- TIM image: `format-security/format-dsk-tim:1.0.0-php8.4.27`
- PHP: `8.4.27`, verified 2026-10-21
- image availability: local to `format-cloud-1`; registry publication pending
  write-capable credentials. See [emergency runtime build and recovery](../_host/php-security-20261021/README.md).
- backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`

## Current Status

- `format-dsk_tim` remains live and routed at `https://dsk-tim.format.lu/`.
- `format-dsk_pm` is intentionally disabled and is no longer present as a live
  Swarm service.
- `https://dsk-pm.format.lu/` currently returns Traefik `404`, which is
  expected while the PM service remains disabled.

## Version Check

TIM currently uses the emergency runtime image documented above, retaining the
application from `esst/format-dsk-tim:1.0.0`. Its PHP branch is 8.4. Keep the
patched local image available until a verified registry replacement is deployed.

Source repo:

- local path: `/Users/czibulapeter/Documents/GitHub/dsk`
- remote: `https://github.com/formatdev/dsk.git`

## Dependency Freshness Check

The live TIM application is built from `tim-v3/Dockerfile`, whose base is PHP
8.4 Apache on Debian Bookworm. Check patched upstream availability before the
next regular build:

```bash
cd /Users/czibulapeter/Documents/GitHub/dsk
docker pull php:8.4.27-apache-bookworm
docker run --rm --entrypoint php php:8.4.27-apache-bookworm -v
```

The older `tim/docker/Dockerfile` is a legacy PHP 7.4 path and is not the live
TIM build. PM remains disabled.

Audit application dependencies from the active API path rather than the legacy
`tim/` directory:

```bash
cd /Users/czibulapeter/Documents/GitHub/dsk/tim-v3/API
composer audit --locked
```

The October 31 source audit found Slim/Twig advisories, including a critical
Twig finding; deployed dependency contents and template trust boundaries still
need review. See the [round record](../_host/maintenance-2026-10-31.md).

## Maintenance Checklist

1. Confirm `format-dsk_tim` is running `1/1`.
2. Confirm whether `format-dsk_pm` is intentionally disabled or expected to be
   live before treating its absence as a fault.
3. Record the live image tag and digest for `format-dsk_tim`, plus the PM image
   only if the PM service is enabled.
4. Record the current source repo commit.
5. Run the base-image freshness commands above and record whether updates are available.
6. Compare the live image with Peter's latest accepted build.
7. Confirm `https://dsk-tim.format.lu/` returns an expected status, and treat
   `https://dsk-pm.format.lu/` `404` as expected only when PM is intentionally
   disabled.
8. Review logs for frontend errors, API failures, auth failures, and missing assets.
9. Confirm whether the live service has persistent data or depends on external APIs.
10. If updating, test the live TIM route before closing the maintenance window.
11. Record all results in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/stack.example.yml)
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/maintenance-log.md)
