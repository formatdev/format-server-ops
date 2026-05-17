# format-dsk On format-cloud-1

This runbook documents the `format-dsk` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Services

- stack: `format-dsk`
- TIM service: `format-dsk_tim`
- TIM hostname: `dsk-tim.format.lu`
- TIM image: `esst/format-dsk:tim`
- backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`

## Current Status

- `format-dsk_tim` remains live and routed at `https://dsk-tim.format.lu/`.
- `format-dsk_pm` is intentionally disabled and is no longer present as a live
  Swarm service.
- `https://dsk-pm.format.lu/` currently returns Traefik `404`, which is
  expected while the PM service remains disabled.

## Version Check

This stack uses named channel tags (`dsk-pm`, `tim`). During maintenance, compare each live image digest with the image Peter built from the intended `dsk` repo commit.

Source repo:

- local path: `/Users/czibulapeter/Documents/GitHub/dsk`
- remote: `https://github.com/formatdev/dsk.git`

## Dependency Freshness Check

This repo is currently Dockerfile/base-image driven rather than Composer/npm driven. Check whether newer base images exist before Peter rebuilds the channel tags:

```bash
cd /Users/czibulapeter/Documents/GitHub/dsk
docker pull php:8.1-apache-bullseye
docker pull php:8.2-apache-bullseye
docker pull esst/php:7.4-apache-buster
docker image inspect php:8.1-apache-bullseye --format '{{index .RepoDigests 0}}'
docker image inspect php:8.2-apache-bullseye --format '{{index .RepoDigests 0}}'
docker image inspect esst/php:7.4-apache-buster --format '{{index .RepoDigests 0}}'
```

Also review the Dockerfiles for EOL runtimes. `tim/docker/Dockerfile` currently uses PHP 7.4, so moving TIM to the `tim-v3` PHP 8.x path should stay on the follow-up list if not already completed.

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
