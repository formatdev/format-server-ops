# Duplicati FC1 Backup

This folder documents the `duplicati-fc1` backup service hosted through
Portainer on the Hetzner host `format-cloud-1`.

Last verified: 2026-04-18.

Duplicati is part of the backup layer. Treat updates and configuration changes
carefully, because backup metadata, destination credentials, and restore ability
are more important than simply having a green container.

## Purpose

`duplicati-fc1` backs up selected data from `format-cloud-1` to the on-prem
Synology NAS over SFTP. The setup is designed for versioned, encrypted,
off-server backups with a daily MariaDB dump included in the backup set.

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
- Current live image: `duplicati/duplicati:latest`
- Current observed digest: `sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`
- Observed Duplicati version: `2.3.0.0_stable_2026-04-14`
- Backend container port: `8200`

Sensitive values are intentionally not stored in this repository. Keep them in
Bitwarden.

## Access Protection

`https://duplicati-fc1.format.lu/` is protected by Cloudflare Access and
returns a Cloudflare Access login redirect when unauthenticated.

Keep this service behind Cloudflare Access. Duplicati has backup credentials and
access to sensitive host paths.

## Portainer Stack

The live Portainer stack should match [stack.yml](./stack.yml). A sanitized
reference is also available as [stack.example.yml](./stack.example.yml).

Important details:

- Duplicati state is stored in the Docker named volume
  `duplicati_fc1_data`.
- Host `/data` is mounted as `/source-data`.
- Host `/etc` is mounted read-only as `/source-etc`.
- Host `/root` is mounted read-only as `/source-root`.
- The Synology SFTP private key is mounted read-only at
  `/sshkeys/synology_backup_ed25519`.
- `SETTINGS_ENCRYPTION_KEY` is set for Duplicati settings encryption.

If the stack is redeployed from Portainer, make sure the SSH key mount remains
present.

Current hardening follow-up:

- Consider making `/data:/source-data` read-only unless a backup job or script
  explicitly needs write access to that source mount.
- Move sensitive values toward Docker secrets or another controlled secret
  process.
- Keep the SSH private key file permission restricted on the host.

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

The exact external SFTP endpoint, SSH key material, Duplicati backup passphrase,
Duplicati UI password, SMTP password, and exported job definitions containing
secrets are stored in Bitwarden and must not be committed to this repository.

Retention policy:

```text
1W:1D,4W:1W,12M:1M
```

This keeps daily restore points for one week, weekly restore points for four
weeks, and monthly restore points for twelve months.

Exclusions:

```text
/source-data/databases/
/source-data/traefik/logs/
/source-root/.cache/
```

The live MariaDB datadir is excluded deliberately. Database recovery should use
the generated SQL dumps instead of a live datadir copy.

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

The script uses `mariadb-dump` from the running MariaDB container and writes
compressed SQL dumps under `/data/backups/mysql`, which is included in the
Duplicati source via `/source-data/backups/mysql`.

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

The WatchGuard SFTP rule should be restricted so inbound SFTP is allowed only
from the Hetzner host IP. Do not expose Synology SFTP broadly to the internet.
See [watchguard-sftp.md](./watchguard-sftp.md) for the firewall runbook.

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

Reason: `cloudflared` connects to the internal Traefik service name `traefik`,
while Traefik presents a certificate for the public hostname rather than the
Docker service name.

## Version Notes

The live image is `duplicati/duplicati:latest`. Docker Hub documents `latest`
as the most recent stable release for the official image.

On `2026-04-18`, the live image digest matched the current Docker registry
`latest` index, and the container changelog showed
`2.3.0.0_stable_2026-04-14`.

Important rollback note:

- Duplicati `2.3.0.0_stable_2026-04-14` includes a server database schema
  update to version 11. Do not roll back to an older image without first
  checking Duplicati's database downgrade/export guidance.

## Restore Test

A restore test was completed on 2026-04-18:

- Restored file: `test-2026-04-18-062654-all-databases.sql.gz`
- Restored location: Duplicati container `/data`
- Restored size: `7,282,475` bytes
- Test result: file-level restore succeeded
- Cleanup: restored test file was removed from the Duplicati data volume
  afterward

## Recovery Notes

To recover Duplicati configuration:

1. Recreate the Portainer stack using [stack.yml](./stack.yml).
2. Restore or recreate the named volume `duplicati_fc1_data` if available.
3. If the Duplicati config is lost, restore the encrypted export from:

```text
/data/backups/duplicati-config/1-format-cloud-1 to Synology.json.aes
```

4. Use the Duplicati backup encryption passphrase from Bitwarden.
5. Confirm the SFTP private key exists at
   `/root/.ssh/duplicati_synology_backup_ed25519` and is mounted into the
   container.

## Maintenance Checklist

1. Confirm `duplicati-fc1_duplicati_fc1` is running `1/1`.
2. Confirm the public route still redirects to Cloudflare Access.
3. Compare the live image digest with the current `duplicati/duplicati:latest`
   registry digest.
4. Check the Duplicati changelog/version inside the container.
5. Review recent logs for backup failures, destination errors, database errors,
   SSH errors, and permission errors.
6. Confirm `/sshkeys/synology_backup_ed25519` is mounted in the running
   container.
7. Confirm `SETTINGS_ENCRYPTION_KEY` is set, without recording its value.
8. Check Duplicati UI for the last successful backup and restore/verification
   status.
9. Confirm backup source mounts are still correct.
10. Confirm restore testing cadence and record the last restore test date.
11. Record changes in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/duplicati-fc1/maintenance-log.md).

## Useful Commands

Inspect the service:

```bash
ssh hetzner-cloud-1 'docker service inspect duplicati-fc1_duplicati_fc1 --format "Image={{.Spec.TaskTemplate.ContainerSpec.Image}} Labels={{json .Spec.Labels}} Mounts={{json .Spec.TaskTemplate.ContainerSpec.Mounts}}"'
```

Check recent logs:

```bash
ssh hetzner-cloud-1 'docker service logs --since 6h --tail 240 duplicati-fc1_duplicati_fc1'
```

Check current image registry digest:

```bash
docker buildx imagetools inspect duplicati/duplicati:latest
```

Check mounted paths inside the running container:

```bash
ssh hetzner-cloud-1 'cid=$(docker ps --filter label=com.docker.swarm.service.name=duplicati-fc1_duplicati_fc1 -q | head -n1); docker exec "$cid" sh -lc "ls -ld /data /source-data /source-etc /source-root /sshkeys; ls -l /sshkeys"'
```

Check database dump state:

```bash
ssh hetzner-cloud-1 'crontab -l | grep backup-mariadb; ls -lh /data/backups/mysql'
```

## Open Follow-Ups

- Pin `duplicati/duplicati` to a tested exact tag after the first stable backup
  cycle.
- Consider adding or rotating `SETTINGS_ENCRYPTION_KEY` through a controlled
  secret process.
- Periodically test a MariaDB dump restore into a temporary database.
- Confirm the WatchGuard SFTP rule remains restricted to `format-cloud-1` only.

## Files

- [stack.yml](./stack.yml): live-style Portainer stack reference
- [stack.example.yml](./stack.example.yml): sanitized live-style Portainer stack
  reference
- [watchguard-sftp.md](./watchguard-sftp.md): firewall forwarding runbook
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/duplicati-fc1/maintenance-log.md): ongoing maintenance history
