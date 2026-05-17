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

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Stack version before: `phpmyadmin/phpmyadmin:latest@sha256:42a200db07b4e70fbf32c594ad4521cf16399b8e54bbb5adceae98e7566dfbeb`

Stack version after: `phpmyadmin/phpmyadmin:latest@sha256:42a200db07b4e70fbf32c594ad4521cf16399b8e54bbb5adceae98e7566dfbeb`

Checks:

- Container health checked: OK. `phpmyadmin_phpmyadmin` is `1/1`.
- Running image checked: OK. Live `latest` digest is
  `sha256:42a200db07b4e70fbf32c594ad4521cf16399b8e54bbb5adceae98e7566dfbeb`.
- Latest phpMyAdmin release/image checked: OK. Official latest release is
  `5.2.3`, and Docker Hub `latest` currently points to the `5.2.3` image line.
- Release notes reviewed: No newer release than `5.2.3` was found.
- Environment checked: OK. `HIDE_PHP_VERSION=true`, `PMA_HOSTS=database-1_db`,
  `PMA_VERBOSES=database-server-1`, and `UPLOAD_LIMIT=300M`.
- Secrets checked: OK. No database password was recorded in the checked service
  configuration.
- Logs reviewed: OK. No recent filtered phpMyAdmin error or warning lines were
  observed.
- Traefik route checked: OK. `https://pma.format.lu/` redirects to Cloudflare
  Access.
- Network membership checked: OK. The service remains attached to its expected
  networks, including the shared proxy network.
- Database connection checked: Not interactively checked in this run.
- UI login checked: Not interactively checked in this run.
- Update applied: No.
- Post-update logs checked: Not applicable.
- Notes: The live image is current for the `latest` track, but the operational
  follow-up to pin an explicit version tag still stands.
- Follow-up: Pin `phpmyadmin/phpmyadmin:5.2.3` (or a newer explicit version when
  chosen) instead of `latest`, and keep the Access policy review on the broader
  admin-surface hardening list.

## 2026-05-03 - Image Pinning

Date: 2026-05-03 12:04 CEST

Maintainer: Codex with Peter

Stack version before: `phpmyadmin/phpmyadmin:latest@sha256:42a200db07b4e70fbf32c594ad4521cf16399b8e54bbb5adceae98e7566dfbeb`

Stack version after: `phpmyadmin/phpmyadmin:5.2.3`

Checks:

- Pinning target chosen: OK. Pinned phpMyAdmin from mutable `latest` to the
  explicit `5.2.3` image tag.
- Service update checked: OK. `phpmyadmin_phpmyadmin` returned to `1/1`.
- Version verification checked: OK. The running container still reports
  phpMyAdmin `5.2.3`.
- Route check after pinning: OK. `https://pma.format.lu/` still returns the
  expected Cloudflare Access challenge path.
- Notes: This removes the day-to-day ambiguity of `latest` without changing the
  deployed phpMyAdmin release line.
- Follow-up: Keep the tag explicit and bump it intentionally when a newer
  phpMyAdmin version is chosen.

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
