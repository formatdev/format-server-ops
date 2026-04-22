# Live Compose

These directories now reflect sanitized versions of the live compose-managed stacks observed on `lportainer`.

## Imported Stacks

- [`compose/traefik`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/traefik)
- [`compose/paperless-work`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-work)
- [`compose/paperless-pcz`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-pcz)
- [`compose/paperless-core`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-core)
- [`compose/paperless-ai`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-ai)
- [`compose/paperless-pcz-gpt`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/paperless-pcz-gpt)
- [`compose/portainer/docker-compose.yml`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/portainer/docker-compose.yml)

## Secret Handling

Live compose files contained secrets inline. In this repository they have been replaced with environment variables and example files under [`env-templates/`](/Users/czibulapeter/Documents/GitHub/format-server-ops/env-templates).

Sanitized items include:

- PostgreSQL passwords
- Paperless secret keys
- Paperless GPT API token
- Traefik dashboard basic-auth hash

## Important Operational Note

These repo files are now structurally aligned with the live compose stacks, but that does not automatically mean the host is deploying from this repository today. Portainer may still hold its own internal copies until you explicitly re-point operations to Git-managed files.

## Portainer

Portainer was reconstructed from live container inspection rather than recovered from a Portainer-managed compose export. See [`compose/portainer/docker-compose.yml`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/portainer/docker-compose.yml) and [`compose/portainer/README.md`](/Users/czibulapeter/Documents/GitHub/format-server-ops/compose/portainer/README.md).
