# Duplicati On esst-cloud-1

Backup service for node-local data on `esst-cloud-1`.

`esst-cloud-1` is a Docker Swarm worker, so this service must be deployed from
the Swarm manager but pinned to `node.hostname == esst-cloud-1`. The backup
sources are local host paths on that node.

## Sources

The `duplicati-ec1` job backs up these paths:

- `/data`, read-only, for production bind mounts such as Vaultwarden, Vtiger,
  WordPress, MariaDB data, and n8n files.
- `/opt/esst`, read-only, for ESST FTP/application-side files.
- `/etc`, read-only, for host configuration needed during recovery.
- `/var/lib/docker/volumes/n8n_data/_data`, read-only, because n8n can store
  workflow credentials and state in its Docker volume.
- `/var/lib/docker/volumes/esst-website_wordpress/_data`, read-only, because an
  `esst-website_wordpress` named volume was observed locally.
- `/data/backups/databases`, through `/data`, for logical database dumps.

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

## Database Dumps

A root cron job creates logical dumps before the Duplicati schedule.

Cron entry on `esst-cloud-1`:

```cron
30 18 * * * /data/backups/databases/backup-databases.sh >> /data/backups/databases/backup-databases.log 2>&1
```

This is 20:30 Luxembourg summer time, one hour before the current Duplicati
schedule.

Script:

```text
/data/backups/databases/backup-databases.sh
```

Dump outputs:

```text
/data/backups/databases/glitchtip-postgres/glitchtip-postgres-all-databases-YYYY-MM-DD-HHMMSS.sql.gz
/data/backups/databases/vtiger-mysql/vtiger-mysql-all-databases-YYYY-MM-DD-HHMMSS.sql.gz
/data/backups/databases/website-mariadb/website-mariadb-all-databases-YYYY-MM-DD-HHMMSS.sql.gz
```

Local dump retention is 14 days. Duplicati handles off-host retention.

## Exclusions

Keep intended database dumps under `/data/backups/databases`, but avoid backing
up local backup plugin output and manual archives. Before deploying Duplicati on
`esst-cloud-2`, `esst-cloud-3`, or `esst-cloud-4`, scan for existing backup
folders and archive piles first so those hosts do not upload backups of backups.

Current `duplicati-ec1` exclusions include:

```text
/source-data/files/esst/website/wp-content/updraft/
/source-data/files/esst/website/wp-content/backups/
/source-data/files/esst/website/wp-content/ai1wm-backups/
/source-data/files/esst/website/wp-content/upgrade-temp-backup/
```

Email notifications are configured after each backup run:

```text
To: peter.czibula@format.lu,it@esst.lu
From: Duplicati EC1 <duplicati-ec1@esst.lu>
Levels: Success,Warning,Error
```

Keep Duplicati behind Cloudflare Access or another strong access layer. Do not
commit backup destination credentials, Duplicati UI passwords, SSH key contents,
or exported Duplicati job definitions containing secrets.

## Files

- [stack.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-1/duplicati/stack.yml): Portainer stack
- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-1/duplicati/stack.example.yml): sanitized proposed Portainer stack
- [backup-databases.sh](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-1/duplicati/backup-databases.sh): logical database dump script
