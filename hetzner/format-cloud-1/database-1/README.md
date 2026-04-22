# Database 1 On format-cloud-1

This folder documents the shared MariaDB service hosted through Portainer on the Hetzner server `hetzner-cloud-1`.

This database backs multiple applications. Treat updates, repairs, and restarts as maintenance-window work only.

## Live Service

- service: shared MariaDB
- server: `hetzner-cloud-1`
- Docker service: `database-1_db`
- current live image: `mariadb:11.8.6`
- current observed digest: `sha256:78a5047d3ba33975f183f183c2464cc7f1eab13ec8667e57cc9a5821d6da7577`
- observed MariaDB version: `11.8.6-MariaDB`
- upgrade environment: `MARIADB_AUTO_UPGRADE=1`
- data bind mount: `/data/databases/db_1:/var/lib/mysql`
- Traefik route: none
- public exposure: none expected

## Known Databases

Observed database directories:

- `chargy`
- `chargy_loeffler`
- `display_website`
- `floc`
- `format_website`
- `formatexpo_website`
- `nolimits_website`
- `primary`

System schemas:

- `mysql`
- `performance_schema`
- `sys`

## Version Policy

The current production line is `mariadb:11.8`, which is an active LTS line. On `2026-04-18`, the running server was upgraded from MariaDB `11.4.10` to `11.8.6`.

Major LTS jumps should not be handled as routine twice-monthly patch bumps. Prefer:

1. Keep `11.8` current for patch-level image refreshes.
2. Review application compatibility before moving to the next LTS line.
3. Take a fresh dump or host snapshot before any database image update.
4. Use `MARIADB_AUTO_UPGRADE=1` or run `mariadb-upgrade` manually when the image update requires it.
5. Run `mariadb-check --check --all-databases` after any major LTS upgrade.

## Current Follow-Ups

- Confirm Duplicati or another off-host backup has a recent successful database backup before the next database maintenance window.
- Keep the next MariaDB LTS jump as a planned compatibility upgrade later, not a routine twice-monthly maintenance bump.
- `mariadb-check` requires controlled credentials; do not record those credentials in this repository.

## Recent Resolved Items

- On `2026-04-18`, a fresh all-databases dump was created at `/data/backups/mysql/mariadb-all-databases-2026-04-18-160526.sql.gz` and gzip verification passed.
- On `2026-04-18`, the service was redeployed to the refreshed `11.4.10` image digest: `sha256:3b4dfcc32247eb07adbebec0793afae2a8eafa6860ec523ee56af4d3dec42f7f`.
- On `2026-04-18`, the previously reported `format_website` crashed tables, including `_fwbk_for_*` tables and `for_usermeta`, checked OK after repair.
- On `2026-04-18`, a full credentialed `mariadb-check --check --all-databases` produced no non-OK table results.
- On `2026-04-18`, a fresh pre-upgrade dump was created at `/data/backups/mysql/mariadb-all-databases-2026-04-18-161317.sql.gz` and gzip verification passed.
- On `2026-04-18`, the service was upgraded from `mariadb:11.4.10` to `mariadb:11.8.6` with `MARIADB_AUTO_UPGRADE=1`.
- On `2026-04-18`, `mariadb-upgrade` completed successfully and the post-upgrade full table check produced no non-OK table results.

## Maintenance Checklist

1. Confirm `database-1_db` is running `1/1`.
2. Confirm the service is not exposed through Traefik or public ports.
3. Record the live image tag and digest.
4. Compare the live digest with the current `mariadb:11.8` registry digest.
5. Check the running MariaDB version.
6. Review recent logs for crash recovery, corrupt tables, denied connections, failed starts, and disk warnings.
7. Confirm `/data/databases/db_1` exists and has expected size.
8. Verify backup freshness before any update or repair.
9. Run `mariadb-check` with controlled credentials during maintenance.
10. Repair crashed tables only after a fresh backup.
11. Record all findings in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/database-1/maintenance-log.md).

## Useful Commands

Inspect service:

```bash
ssh hetzner-cloud-1 'docker service inspect database-1_db --format "Image={{.Spec.TaskTemplate.ContainerSpec.Image}} Mounts={{json .Spec.TaskTemplate.ContainerSpec.Mounts}}"'
```

Check service health:

```bash
ssh hetzner-cloud-1 'docker service ps database-1_db --no-trunc --format "{{.Name}} {{.CurrentState}} {{.Error}}"'
```

Check running server version:

```bash
ssh hetzner-cloud-1 'cid=$(docker ps --filter label=com.docker.swarm.service.name=database-1_db -q | head -n1); docker exec "$cid" sh -lc "mariadb --version"'
```

Check current `11.8` registry digest:

```bash
docker buildx imagetools inspect mariadb:11.8
```

Review logs:

```bash
ssh hetzner-cloud-1 'docker service logs --since 24h --tail 300 database-1_db'
```

Credentialed table check, during maintenance only. Use the controlled backup/check user from the server-side credential file; do not print or record the password:

```bash
ssh hetzner-cloud-1 'PASS=$(cat /root/.mariadb-backup-password); cid=$(docker ps --filter label=com.docker.swarm.service.name=database-1_db -q | head -n1); docker exec -e MYSQL_PWD="$PASS" "$cid" mariadb-check -ubackup_user --check --all-databases'
```

Show only non-OK table check lines:

```bash
ssh hetzner-cloud-1 'PASS=$(cat /root/.mariadb-backup-password); cid=$(docker ps --filter label=com.docker.swarm.service.name=database-1_db -q | head -n1); docker exec -e MYSQL_PWD="$PASS" "$cid" mariadb-check -ubackup_user --check --all-databases 2>&1 | grep -vE " OK$|^$" || true'
```

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/database-1/stack.example.yml): sanitized live-style Portainer stack reference
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/database-1/maintenance-log.md): ongoing maintenance history
