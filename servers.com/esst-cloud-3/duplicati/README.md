# Duplicati On esst-cloud-3

Backup service for host configuration on `esst-cloud-3`.

`esst-cloud-3` is a Docker Swarm worker, so this service must be deployed from
the Swarm manager but pinned to `node.hostname == esst-cloud-3`.

## Sources

The `duplicati-ec3` job should back up these paths:

- `/opt/esst`, read-only, for host-side scripts and ESST files.
- `/etc`, read-only, for host configuration needed during recovery.

Do not back up the live MariaDB datadir directly. The production monitoring
database is covered by the app-generated dump files on `esst-cloud-2`, which are
included in the EC2 Duplicati job.

## Database Dumps

Database dump scripts were prepared during review, but they are not scheduled
and should not be included in EC3 Duplicati while EC2 backs up the app-generated
production monitoring dumps.

## Deployment

Prepared status on 2026-04-25:

- Swarm stack: `duplicati-ec3`
- Service: `duplicati-ec3_duplicati_ec3`
- Pinned node: `esst-cloud-3`
- URL: `https://duplicati-ec3.esst.lu`
- NAS folder: `/ESSTBF/duplicati/esst-cloud-3`
- SFTP user: `eSSTBU`
- Suggested Duplicati schedule: daily at `21:30 UTC`

The Duplicati settings encryption key, UI password, and backup encryption
passphrase are stored only in root-readable files on the servers and should also
be stored in Bitwarden. Do not commit them.

## Exclusions

Use the same Duplicati retention policy as EC1 and EC2:

```text
7D:1D,4W:1W,12M:1M
```

Use generic cache/temp exclusions:

```text
*/cache/
*/.cache/
*/tmp/
```

Email notifications are configured after each backup run:

```text
To: peter.czibula@format.lu,it@esst.lu
From: Duplicati EC3 <duplicati-ec3@esst.lu>
Levels: Success,Warning,Error
```

## Cloudflare

`duplicati-ec3.esst.lu` is proxied through Cloudflare and protected by
Cloudflare Access for:

- `peter.czibula@format.lu`
- `liliana.grigor@esst.lu`
- `ivan.buccella@esst.lu`

## Files

- [stack.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-3/duplicati/stack.yml): Portainer stack
- [backup-databases.sh](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-3/duplicati/backup-databases.sh): MariaDB dump script
- [backup-audit-latest.sh](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-3/duplicati/backup-audit-latest.sh): latest-only heavy table dump script
