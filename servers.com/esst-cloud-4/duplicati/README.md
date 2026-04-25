# Duplicati On esst-cloud-4

Backup service for the Swarm manager and proxy/control-plane node.

`esst-cloud-4` runs the Portainer server task and Traefik. It also has old
copies of application data under `/data`, but the active production services for
those datasets are pinned to other nodes and backed up there.

## Sources

The `duplicati-ec4` job should back up:

- `/opt/esst`, read-only, for Portainer data, Traefik configuration/certificates,
  deployment references, and host-side scripts.
- `/etc`, read-only, for host configuration needed during recovery.

Do not back up `/data` from EC4 as part of the normal job. The current `/data`
tree contains stale application/database copies and old Redis data; the active
production data is covered by EC1, EC2, and EC3 backup jobs.

## Exclusions

Use the same retention policy as EC1-EC3:

```text
7D:1D,4W:1W,12M:1M
```

Exclude transient or bulky paths:

```text
/source-opt-esst/deployment/traefik/logs/
/source-opt-esst/deployment/portainer/data/portainer.db
/source-opt-esst/deployment/portainer/data/useractivity.db
/source-opt-esst/deployment/portainer/data/portainer.db-*
/source-opt-esst/deployment/portainer/data/useractivity.db-*
*/cache/
*/.cache/
*/tmp/
```

The live Portainer DB files are copied to
`/opt/esst/deployment/portainer/backups/current-data-files/` before the
scheduled Duplicati run, because Portainer keeps the live files locked.

Email notifications are configured after each backup run:

```text
To: peter.czibula@format.lu,it@esst.lu
From: Duplicati EC4 <duplicati-ec4@esst.lu>
Levels: Success,Warning,Error
```

## Deployment

Prepared status on 2026-04-25:

- Swarm stack: `duplicati-ec4`
- Service: `duplicati-ec4_duplicati_ec4`
- Pinned node: `esst-cloud-4`
- URL: `https://duplicati-ec4.esst.lu`
- NAS folder: `/ESSTBF/duplicati/esst-cloud-4`
- SFTP user: `eSSTBU`
- Suggested schedule: daily at `22:00 UTC`
- Portainer DB snapshot schedule: daily at `21:45 UTC`

The Duplicati settings encryption key, UI password, and backup encryption
passphrase are stored only in root-readable files on the servers and should also
be stored in Bitwarden. Do not commit them.

## Cloudflare

`duplicati-ec4.esst.lu` is proxied through Cloudflare and protected by
Cloudflare Access for:

- `peter.czibula@format.lu`
- `liliana.grigor@esst.lu`
- `ivan.buccella@esst.lu`

## Files

- [stack.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-4/duplicati/stack.yml): Portainer stack
