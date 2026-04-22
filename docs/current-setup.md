# Current Setup

This document describes the observed live setup on the `lportainer` VM as audited over SSH on `2026-04-04`.

## Host

- hostname: `lportainer`
- platform intent: Ubuntu VM on ESXi
- management model: Docker plus Portainer
- compose definitions for most live stacks have now been imported into this repo in sanitized form

## Running Containers

Observed running services:

- `traefik`
- `portainer`
- `whoami`
- `paperless`
- `paperless-postgres`
- `paperless-redis`
- `paperless-pcz`
- `paperless-pcz-postgres`
- `paperless-pcz-redis`
- `paperless-core-tika`
- `paperless-core-gotenberg`
- `paperless-ollama`
- `paperless-pcz-gpt`

## Active Application Groups

### Reverse proxy and admin

- Traefik is running as a standalone compose stack from `/home/peter/stacks/traefik/docker-compose.yml`
- Portainer is running and publishes management ports directly on the host
- a `whoami` container is present as a routing test service
- the repo now contains a sanitized Traefik compose file matching the observed live stack
- the repo now also contains a reconstructed Portainer compose file matching the observed live container

### Paperless instance 1

- project name appears as `paperless`
- services: Paperless webserver, PostgreSQL, Redis
- routed hostname observed in labels: `paperless.format.lu`
- represented in the repo as [`compose/paperless-work`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-work)

### Paperless instance 2

- project name appears as `paperless-pcz`
- services: Paperless webserver, PostgreSQL, Redis
- routed hostname observed in labels: `paperless-pcz.format.lu`
- represented in the repo as [`compose/paperless-pcz`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-pcz)

### Shared helper services

- project name appears as `paperless-core`
- optional helpers currently running:
  - Gotenberg
  - Tika
- represented in the repo as [`compose/paperless-core`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-core)

### AI-related services

- project name appears as `paperless-ai`
- active service: Ollama
- project name appears as `paperless-pcz-gpt`
- active service: Paperless GPT sidecar/web service
- routed hostname observed in labels: `paperless-pcz-gpt.format.lu`
- represented in the repo as [`compose/paperless-ai`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-ai) and [`compose/paperless-pcz-gpt`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-pcz-gpt)

## Networks

Observed Docker networks:

- `proxy`
- `paperless`
- `paperless_backend`
- `paperless-pcz_backend`

Traefik is attached to `proxy`.

Both Paperless web containers are attached to:

- `proxy`
- `paperless`
- one dedicated backend network each

Portainer is attached to the default Docker `bridge` network, not the `proxy` network.

## Storage Model

The live host is currently using Docker named volumes, not the bind-mounted `/srv/paperless/...` layout from the earlier repo draft.

Observed volume groups include:

- `paperless_*`
- `paperless-pcz_*`
- `paperless-ai_*`
- `portainer_data`

The host `/srv` tree is effectively unused for the Paperless deployment at the time of inspection.

## Traefik State

Observed facts:

- Traefik publishes host ports `80` and `443`
- Traefik uses Docker labels with `exposedByDefault=false`
- Traefik has a file provider configured
- the local dynamic config directory exists in the stack definition but was empty at inspection time
- an ACME storage file exists but was empty at inspection time
- the observed routers on Traefik-managed services were using the `web` entrypoint in labels

This suggests the live routing configuration is still in a transitional or partially wired state for TLS.

## Important Caveat

Most live compose stacks are now represented in sanitized form under [`compose/`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose), but the host may still be running Portainer-internal copies rather than these repository files.
