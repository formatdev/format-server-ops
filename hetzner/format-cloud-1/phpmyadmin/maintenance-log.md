# phpMyAdmin Maintenance Log

Use this log for phpMyAdmin checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record database credentials, session tokens, SQL dumps, or other secrets here.

## 2026-04-18 - Initial Documentation

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `phpmyadmin/phpmyadmin:latest`

Stack version after: `phpmyadmin/phpmyadmin:latest`

Checks:

- Container health checked: OK. `phpmyadmin_phpmyadmin` is running `1/1`; container has been up for 8 days.
- Running image checked: Follow-up needed. Live image is `phpmyadmin/phpmyadmin:latest`; choose and pin a version tag later.
- Environment checked: OK. `HIDE_PHP_VERSION=true`, `PMA_HOSTS=database-1_db`, `PMA_VERBOSES=database-server-1`, and `UPLOAD_LIMIT=300M`.
- Secrets checked: OK. No database password was observed in the service environment.
- Logs reviewed: OK. No recent filtered PHP, mysqli, login, warning, fatal, or error lines found.
- Traefik routing checked: OK. Public `https://pma.format.lu/` returned `302`; local Traefik host-header route returned `200`.
- Network membership checked: OK. phpMyAdmin is attached to the `proxy` network.
- Update applied: No.
- Notes: Created this service documentation folder and sanitized live-style stack reference.
- Follow-up: Pin the phpMyAdmin image tag and review access policy for `pma.format.lu` together with broader origin/admin-surface hardening.

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Container health checked:
- Running image checked:
- Latest phpMyAdmin release/image checked:
- Release notes reviewed:
- Environment checked:
- Secrets checked:
- Logs reviewed:
- Traefik route checked:
- Network membership checked:
- Database connection checked:
- UI login checked:
- Update applied:
- Post-update logs checked:
- Notes:
- Follow-up:
