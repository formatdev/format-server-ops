# format-dsk On format-cloud-1

This runbook documents the `format-dsk` custom app stack hosted through Portainer on `hetzner-cloud-1`.

## Live Services

- stack: `format-dsk`
- PM service: `format-dsk_pm`
- TIM service: `format-dsk_tim`
- PM hostname: `dsk-pm.format.lu`
- TIM hostname: `dsk-tim.format.lu`
- PM image: `esst/format:dsk-pm`
- TIM image: `esst/format-dsk:tim`
- backend port: `80`
- reverse proxy: Traefik on external Docker network `proxy`

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

1. Confirm `format-dsk_pm` and `format-dsk_tim` are running `1/1`.
2. Record the live image tag and digest for both services.
3. Record the current source repo commit.
4. Run the base-image freshness commands above and record whether updates are available.
5. Compare both live images with Peter's latest accepted builds.
6. Confirm `https://dsk-pm.format.lu/` and `https://dsk-tim.format.lu/` return expected statuses.
7. Review logs for frontend errors, API failures, auth failures, and missing assets.
8. Confirm whether either service has persistent data or depends on external APIs.
9. If updating, test both PM and TIM routes before closing the maintenance window.
10. Record all results in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/stack.example.yml)
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/maintenance-log.md)
