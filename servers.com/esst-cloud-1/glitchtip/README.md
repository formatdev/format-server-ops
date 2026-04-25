# GlitchTip on esst-cloud-1

Runbook notes for the `esst-glitchtip` Docker Swarm stack.

## Purpose

Self-hosted GlitchTip for eSST application error tracking and performance
monitoring, exposed at `https://glitchtip.esst.lu`.

## Live Topology

- `web`: GlitchTip web/API service
- `worker`: background jobs and scheduler
- `migrate`: one-shot database migrations during upgrades
- `postgres`: GlitchTip PostgreSQL database
- `redis`: Redis queue/cache backend

## Current Version

- Target app image: `glitchtip/glitchtip:v5.2.1`

## Deployment Notes

- Keep `web`, `worker`, and `migrate` on the same GlitchTip tag.
- Keep `worker` on the internal network only; it does not need Traefik access.
- Disable public self-registration unless there is an explicit product need.
- Set `ALLOWED_HOSTS` and `CSRF_TRUSTED_ORIGINS` explicitly for the public
  hostname.
- Run `pgpartition` as part of the migration job for GlitchTip 5.x upgrades so
  the current and next event partitions exist before the worker starts
  consuming traffic.
- Use the stack example in this directory as the tracked baseline and inject
  secrets at deploy time instead of committing them.

## Useful Checks

```sh
docker service ls | grep esst-glitchtip
docker service ps esst-glitchtip_web
docker service logs --tail 100 esst-glitchtip_web
docker service logs --tail 100 esst-glitchtip_worker
docker exec "$(docker ps --filter name=esst-glitchtip_web -q | head -n1)" ./manage.py pgpartition --yes
```
