# Duplicati On esst-cloud-1

Proposed backup service for node-local data on `esst-cloud-1`.

`esst-cloud-1` is a Docker Swarm worker, so this service must be deployed from
the Swarm manager but pinned to `node.hostname == esst-cloud-1`. The backup
sources are local host paths on that node.

## Proposed Sources

Back up these paths:

- `/data`, read-only, for production bind mounts such as Vaultwarden, Vtiger,
  WordPress, MariaDB data, and n8n files.
- `/opt/esst`, read-only, for ESST FTP/application-side files.
- `/etc`, read-only, for host configuration needed during recovery.
- `/var/lib/docker/volumes/n8n_data/_data`, read-only, because n8n can store
  workflow credentials and state in its Docker volume.
- `/var/lib/docker/volumes/esst-website_wordpress/_data`, read-only, because an
  `esst-website_wordpress` named volume was observed locally.

Skip these unless someone confirms they contain production data:

- `esst-monitoring-beta_*`
- `esst-monitoring-dev_*`
- `smtp-dev_data`
- `redis_data`

## Portainer

Portainer agent state on this worker is not the important Portainer backup. The
Portainer server database and stack definitions should be backed up on the node
that runs the Portainer server, likely `esst-cloud-4`.

## Consistency Notes

For MySQL/MariaDB-backed stacks, prefer database dumps into a backed-up path
over relying only on live raw database files. Raw database directory backups can
restore badly if copied mid-write.

Keep Duplicati behind Cloudflare Access or another strong access layer. Do not
commit backup destination credentials, Duplicati UI passwords, SSH key contents,
or exported Duplicati job definitions containing secrets.

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-1/duplicati/stack.example.yml): sanitized proposed Portainer stack
