# Duplicati FC1 Backup

This folder documents the Duplicati backup setup for the Hetzner host `format-cloud-1`.

Last verified: 2026-04-18.

## Purpose

`duplicati-fc1` backs up selected data from `format-cloud-1` to the on-prem Synology NAS over SFTP. The setup is designed for versioned, encrypted, off-server backups with a daily MariaDB dump included in the backup set.

## Live Components

- Host: `format-cloud-1`
- Docker/Swarm service: `duplicati-fc1_duplicati_fc1`
- Duplicati UI: `https://duplicati-fc1.format.lu`
- Access protection: Cloudflare Access plus Duplicati UI authentication
- Reverse proxy: Traefik service `traefik_traefik`
- Cloudflare Tunnel: `tunnel-format-cloud-1`
- Backup destination: Synology SFTP, user `FormatBU`
- Synology destination path: `/FORMATBF/duplicati/format-cloud-1`
- WatchGuard SFTP forwarding: [watchguard-sftp.md](./watchguard-sftp.md)

Sensitive values are intentionally not stored in this repository. Keep them in Bitwarden.

## Portainer Stack

The live Portainer stack should match [stack.yml](./stack.yml).

Important details:

- Duplicati state is stored in the Docker named volume `duplicati_fc1_data`.
- Host `/data` is mounted as `/source-data`.
- Host `/etc` is mounted read-only as `/source-etc`.
- Host `/root` is mounted read-only as `/source-root`.
- The Synology SFTP private key is mounted read-only at `/sshkeys/synology_backup_ed25519`.

If the stack is redeployed from Portainer, make sure the SSH key mount remains present.

## Duplicati Backup Job

Backup job name:

```text
format-cloud-1 to Synology
```

Sources:

```text
/source-data/
/source-etc/
/source-root/
```

Destination:

```text
SFTP to Synology, path /FORMATBF/duplicati/format-cloud-1
```

The exact external SFTP endpoint, SSH key material, Duplicati backup passphrase, Duplicati UI password, and SMTP password are stored in Bitwarden and must not be committed to this repository.

Retention policy:

```text
1W:1D,4W:1W,12M:1M
```

This keeps daily restore points for one week, weekly restore points for four weeks, and monthly restore points for twelve months.

Exclusions:

```text
/source-data/databases/
/source-data/traefik/logs/
/source-root/.cache/
```

The live MariaDB datadir is excluded deliberately. Database recovery should use the generated SQL dumps instead of a live datadir copy.

Schedule:

```text
Daily at 20:30 Europe/Luxembourg time
```

Email notifications:

```text
To: peter.czibula@format.lu
From: Duplicati FC1 <duplicati-fc1@format.lu>
Levels: Success,Warning,Error
```

SMTP credentials are stored in Bitwarden.

## MariaDB Dumps

A host cron job runs the database dump before Duplicati starts.

Cron entry:

```cron
0 20 * * * /data/backups/mysql/backup-mariadb.sh >> /data/backups/mysql/backup-mariadb.log 2>&1
```

Script path:

```text
/data/backups/mysql/backup-mariadb.sh
```

Password file for the dedicated MariaDB backup user:

```text
/root/.mariadb-backup-password
```

Dump output pattern:

```text
/data/backups/mysql/mariadb-all-databases-YYYY-MM-DD-HHMMSS.sql.gz
```

Local dump retention:

```text
14 days
```

The script uses `mariadb-dump` from the running MariaDB container and writes compressed SQL dumps under `/data/backups/mysql`, which is included in the Duplicati source via `/source-data/backups/mysql`.

## Synology SFTP

Synology user:

```text
FormatBU
```

Expected destination folder:

```text
/FORMATBF/duplicati/format-cloud-1
```

The Hetzner backup public key is installed in:

```text
/var/services/homes/FormatBU/.ssh/authorized_keys
```

The matching private key is on `format-cloud-1`:

```text
/root/.ssh/duplicati_synology_backup_ed25519
```

The WatchGuard SFTP rule should be restricted so inbound SFTP is allowed only from the Hetzner host IP. Do not expose Synology SFTP broadly to the internet. See [watchguard-sftp.md](./watchguard-sftp.md) for the firewall runbook.

## Cloudflare Access And Tunnel

External hostname:

```text
duplicati-fc1.format.lu
```

Cloudflare Access app:

```text
duplicati-fc1
```

Tunnel:

```text
tunnel-format-cloud-1
```

Tunnel route:

```text
duplicati-fc1.format.lu -> https://traefik:443
```

Origin setting:

```text
No TLS Verify: enabled
```

Reason: `cloudflared` connects to the internal Traefik service name `traefik`, while Traefik presents a certificate for the public hostname rather than the Docker service name.

## Restore Test

A restore test was completed on 2026-04-18:

- Restored file: `test-2026-04-18-062654-all-databases.sql.gz`
- Restored location: Duplicati container `/data`
- Restored size: `7,282,475` bytes
- Test result: file-level restore succeeded
- Cleanup: restored test file was removed from the Duplicati data volume afterward

## Recovery Notes

To recover Duplicati configuration:

1. Recreate the Portainer stack using [stack.yml](./stack.yml).
2. Restore or recreate the named volume `duplicati_fc1_data` if available.
3. If the Duplicati config is lost, restore the encrypted export from:

```text
/data/backups/duplicati-config/1-format-cloud-1 to Synology.json.aes
```

4. Use the Duplicati backup encryption passphrase from Bitwarden.
5. Confirm the SFTP private key exists at `/root/.ssh/duplicati_synology_backup_ed25519` and is mounted into the container.

## Operational Checks

After changes or server maintenance, verify:

```bash
docker service ps duplicati-fc1_duplicati_fc1
docker service logs duplicati-fc1_duplicati_fc1 --tail 80
crontab -l | grep backup-mariadb
ls -lh /data/backups/mysql
```

Also verify from the Duplicati UI:

- latest backup completed successfully
- success email was sent
- restore browser shows recent versions
- a small file restore still works

## Open Follow-Ups

- Pin `duplicati/duplicati` to a tested exact tag after the first stable backup cycle.
- Consider adding `SETTINGS_ENCRYPTION_KEY` for Duplicati server settings encryption.
- Periodically test a MariaDB dump restore into a temporary database.
- Confirm the WatchGuard SFTP rule remains restricted to `format-cloud-1` only.
