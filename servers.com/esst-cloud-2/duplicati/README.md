# Duplicati On esst-cloud-2

Backup service for node-local data on `esst-cloud-2`.

`esst-cloud-2` is a Docker Swarm worker, so this service must be deployed from
the Swarm manager but pinned to `node.hostname == esst-cloud-2`. The backup
sources are local host paths on that node.

## Sources

The `duplicati-ec2` job should back up these paths:

- `/data`, read-only, for production monitoring bind mounts and app-generated
  database backup archives.
- `/opt/esst`, read-only, for host-side ESST files if added later.
- `/etc`, read-only, for host configuration needed during recovery.

Observed valuable production data:

- `/data/files/esst/monitoring/production/uploads`
- `/data/files/esst/monitoring/production/storage/oauth`
- `/data/files/esst/monitoring/production/storage/logs`
- `/data/files/esst/monitoring/production/storage/database/backups`

## Deployment

Status on 2026-04-25:

- Swarm stack: `duplicati-ec2`
- Service: `duplicati-ec2_duplicati_ec2`
- Pinned node: `esst-cloud-2`
- URL: `https://duplicati-ec2.esst.lu`
- NAS folder: `/ESSTBF/duplicati/esst-cloud-2`
- SFTP user: `eSSTBU`
- Schedule: daily at `20:30 UTC`, currently `22:30 Europe/Luxembourg` during
  summer time

The Duplicati settings encryption key, UI password, and backup encryption
passphrase are stored only in root-readable files on the servers and should also
be stored in Bitwarden. Do not commit them.

## Exclusions

The monitoring stack creates twice-daily local database backup archives on
`esst-cloud-2`. These are included in the EC2 backup after review.

Redis, resources, and runtime are excluded from the EC2 file backup. Redis can
be rebuilt during recovery, and the current monitoring resources/runtime folders
were intentionally left out after review.

```text
/source-data/redis/
/source-data/redis/esst/monitoring/production/
/source-data/files/esst/monitoring/production/resources/
/source-data/files/esst/monitoring/production/runtime/
```

Use the same Duplicati retention policy as EC1:

```text
7D:1D,4W:1W,12M:1M
```

Email notifications are configured after each backup run:

```text
To: peter.czibula@format.lu,it@esst.lu
From: Duplicati EC2 <duplicati-ec2@esst.lu>
Levels: Success,Warning,Error
```

## Cloudflare

`duplicati-ec2.esst.lu` is proxied through Cloudflare and protected by
Cloudflare Access for:

- `peter.czibula@format.lu`
- `liliana.grigor@esst.lu`
- `ivan.buccella@esst.lu`

## Files

- [stack.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-2/duplicati/stack.yml): Portainer stack
