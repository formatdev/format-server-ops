# Database 1 Maintenance Log

Use this log for shared MariaDB checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record root passwords, application database passwords, SQL dumps, personal data, customer data, or other secrets here.

## 2026-04-18 - Initial Runbook And Health Check

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `mariadb:11.4@sha256:bdd77d2a639e5e123025e4c5f7e0a2373b06f733631c57d53034709b23dae807`

Stack version after: `mariadb:11.4@sha256:bdd77d2a639e5e123025e4c5f7e0a2373b06f733631c57d53034709b23dae807`

Checks:

- Container health checked: OK. `database-1_db` is running `1/1`.
- Public exposure checked: OK. No Traefik labels were present on the service.
- Running image checked: OK. Live service uses `mariadb:11.4@sha256:bdd77d2a639e5e123025e4c5f7e0a2373b06f733631c57d53034709b23dae807`.
- Running version checked: OK. Container reports `11.4.10-MariaDB`.
- Registry digest checked: Follow-up needed. Current `mariadb:11.4` registry index resolves to `sha256:3b4dfcc32247eb07adbebec0793afae2a8eafa6860ec523ee56af4d3dec42f7f`, newer than the live service digest.
- Current LTS line checked: OK. MariaDB `11.4` remains an active LTS line; MariaDB `11.8` is a newer LTS line but should be treated as a planned compatibility upgrade, not a routine patch bump.
- Data mount checked: OK. `/data/databases/db_1` exists and is about `484M`.
- Database directories checked: OK. Observed app databases include `chargy`, `chargy_loeffler`, `display_website`, `floc`, `format_website`, `formatexpo_website`, `nolimits_website`, and `primary`.
- Logs reviewed: Follow-up needed. Recent logs show crashed tables in `format_website`, including `_fwbk_for_*` tables and `for_usermeta`.
- Credentialed table check: Not completed. `mariadb-check` without credentials was denied; credentials were not retrieved or recorded.
- Update applied: No.
- Notes: Take a fresh database backup or snapshot before attempting table repair or image redeploy.
- Follow-up: Verify backup freshness; run credentialed `mariadb-check`; repair crashed `format_website` tables during a maintenance window; then redeploy `mariadb:11.4` to pull the refreshed digest if backups are good.

## 2026-04-18 - format_website Table Repair

Date: 2026-04-18

Maintainer: Peter with Codex verification

Stack version before: `mariadb:11.4`

Stack version after: `mariadb:11.4`

Checks:

- Repair performed: OK. Peter repaired the reported `format_website` tables through phpMyAdmin.
- Table check performed: OK. Peter confirmed phpMyAdmin check results looked fine after repair.
- Service health checked: OK. `database-1_db` is running.
- Running version checked: OK. Container reports `11.4.10-MariaDB`.
- Post-repair logs checked: OK. No fresh `format_website` crashed-table messages were observed in the latest log window.
- Remaining log notes: MariaDB logged an `io_uring_queue_init()` warning after restart and credentialless root access warnings from earlier maintenance checks; neither is the repaired table crash.
- Follow-up: Continue with backup freshness verification and the planned controlled `mariadb:11.4` image redeploy after backups are confirmed.

## 2026-04-18 - Backup Verification And Image Refresh

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `mariadb:11.4@sha256:bdd77d2a639e5e123025e4c5f7e0a2373b06f733631c57d53034709b23dae807`

Stack version after: `mariadb:11.4.10@sha256:3b4dfcc32247eb07adbebec0793afae2a8eafa6860ec523ee56af4d3dec42f7f`

Checks:

- Fresh dump created: OK. Created `/data/backups/mysql/mariadb-all-databases-2026-04-18-160526.sql.gz`.
- Dump integrity checked: OK. `gzip -t` passed.
- Dump contents spot-checked: OK. Expected app databases were present in the dump.
- Image refresh checked: OK. Service now runs `mariadb:11.4.10@sha256:3b4dfcc32247eb07adbebec0793afae2a8eafa6860ec523ee56af4d3dec42f7f`.
- Running version checked: OK. Container reports `11.4.10-MariaDB`.
- Redeploy logs checked: OK. MariaDB reported `MariaDB upgrade not required` and became ready for connections.
- Table check completed: OK. Full credentialed `mariadb-check --check --all-databases` completed.
- Focused table check reviewed: OK. Filtering the full table check for non-OK results returned no output.
- Previously crashed tables checked: OK. The repaired `format_website` tables, including `_fwbk_for_*` tables and `for_usermeta`, checked OK.
- Remaining log notes: The `io_uring_queue_init()` warning falls back to native AIO and is not a table corruption issue.
- Update applied: Yes. The service now uses the refreshed `11.4.10` digest.
- Follow-up: Confirm off-host backup status in Duplicati during the next backup maintenance check. Treat MariaDB `11.8` as a separate planned compatibility upgrade later.

## 2026-04-18 - MariaDB 11.8 LTS Upgrade

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `mariadb:11.4.10@sha256:3b4dfcc32247eb07adbebec0793afae2a8eafa6860ec523ee56af4d3dec42f7f`

Stack version after: `mariadb:11.8.6@sha256:78a5047d3ba33975f183f183c2464cc7f1eab13ec8667e57cc9a5821d6da7577`

Checks:

- Pre-upgrade dump created: OK. Created `/data/backups/mysql/mariadb-all-databases-2026-04-18-161317.sql.gz`.
- Dump integrity checked: OK. `gzip -t` passed.
- System-versioned tables checked: OK. Count was `0`.
- Upgrade applied: OK. Updated Swarm service to `mariadb:11.8.6` and added `MARIADB_AUTO_UPGRADE=1`.
- Service convergence checked: OK. `database-1_db` converged and the running container reported healthy.
- Running version checked: OK. Container reports `11.8.6-MariaDB`.
- Upgrade logs checked: OK. The entrypoint detected the major upgrade, backed up system tables, ran `mariadb-upgrade`, and reported `Finished mariadb-upgrade`.
- Table check completed: OK. Full credentialed `mariadb-check --check --all-databases` completed.
- Focused table check reviewed: OK. Filtering the full table check for non-OK results returned no output.
- Public smoke checks: OK. `floc.lu`, `www.nolimits.lu`, `chargy.format.lu`, `chargy.loeffler.lu`, `ts.format.lu`, `tsr.format.lu`, `dsk-tim.format.lu`, and `pma.format.lu` returned `200`.
- Public smoke notes: `dsk-pm.format.lu/` returned `404` with `index.php` missing from `/app`; the service had already been running for 13 days, so this was not treated as a MariaDB upgrade regression.
- Portainer stack redeploy checked: OK. Peter redeployed the stack with `mariadb:11.8.6` and `MARIADB_AUTO_UPGRADE=1`; the resulting service image is digest-pinned to `sha256:78a5047d3ba33975f183f183c2464cc7f1eab13ec8667e57cc9a5821d6da7577`.
- Post-Portainer redeploy logs checked: OK. Entrypoint reported `MariaDB upgrade not required` and MariaDB became ready for connections.
- Remaining log notes: The `io_uring_queue_init()` warning falls back to native AIO and is not a table corruption issue.
- Rollback notes: Because `mariadb-upgrade` ran, rollback should be treated as restore-from-dump or restore-from-snapshot work, not a simple image tag downgrade.
- Follow-up: Confirm off-host backup status in Duplicati during the next backup maintenance check.

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Container health checked:
- Public exposure checked:
- Running image checked:
- Registry digest checked:
- Running version checked:
- Data mount checked:
- Backup freshness checked:
- Logs reviewed:
- Table check completed:
- Crashed tables repaired:
- Update applied:
- Rollback notes:
- Notes:
- Follow-up:
