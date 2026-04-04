# Backup And Restore

This runbook matches the current live layout: Docker named volumes plus Portainer-managed compose projects.

## What Must Be Backed Up

- `paperless_paperless_db`
- `paperless_paperless_data`
- `paperless_paperless_media`
- `paperless_paperless_export`
- `paperless_paperless_consume`
- `paperless_paperless_redis`
- `paperless-pcz_paperless_pcz_db`
- `paperless-pcz_paperless_pcz_data`
- `paperless-pcz_paperless_pcz_media`
- `paperless-pcz_paperless_pcz_export`
- `paperless-pcz_paperless_pcz_consume`
- `paperless-pcz_paperless_pcz_redis`
- `paperless-ai_paperless_ollama` if the AI side matters
- `portainer_data`

## Configuration That Must Also Be Backed Up

- `/home/peter/stacks/traefik/docker-compose.yml`
- `/home/peter/stacks/traefik/traefik.yml`
- `/home/peter/stacks/traefik/acme.json`
- Portainer internal compose data from `/data/compose` inside the `portainer` container or from the `portainer_data` volume
- any local notes describing stack ownership and DNS names

## Backup Approach

Use both:

- VM-level backup for broad recovery
- application-level export of Docker volumes and compose definitions

## Exporting A Named Volume

Example pattern from the VM:

```bash
docker run --rm \
  -v paperless_paperless_media:/source:ro \
  -v "$PWD:/backup" \
  alpine \
  tar -czf /backup/paperless_paperless_media.tar.gz -C /source .
```

Repeat this for each required volume.

## PostgreSQL Backup

For each Paperless instance, create a logical dump in addition to volume backup:

```bash
docker exec -i paperless-postgres pg_dump -U paperless paperless > paperless.sql
docker exec -i paperless-pcz-postgres pg_dump -U paperless paperless > paperless-pcz.sql
```

## Portainer Stack Backup

Export the compose definitions currently stored in Portainer:

```bash
docker cp portainer:/data ./portainer-data-export
```

At minimum, retain:

- `portainer.db`
- `compose/`

## Restore Principles

- restore into a test VM first when possible
- restore volumes before starting dependent containers
- restore PostgreSQL dumps only after the target database container is running
- restore Portainer data carefully, because it contains internal stack state

## Risk Notes

- named-volume backups are less transparent than bind-mounted host paths
- if Portainer remains the live deployment source, losing `portainer_data` means losing stack metadata even if images and volumes survive
