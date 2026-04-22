# phpMyAdmin On format-cloud-1

This folder documents the phpMyAdmin service hosted through Portainer on the Hetzner server `hetzner-cloud-1`.

phpMyAdmin is a sensitive administrative interface for database access. Treat exposure and updates carefully, and avoid storing database passwords or session details in this repository.

## Live Service

- service: phpMyAdmin
- server: `hetzner-cloud-1`
- Docker service: `phpmyadmin_phpmyadmin`
- public hostname in labels: `pma.format.lu`
- current live image: `phpmyadmin/phpmyadmin:latest`
- live replica state during documentation: `1/1`
- reverse proxy: Traefik on external Docker network `proxy`
- backend container port: `80`
- database target: `database-1_db`
- database display name: `database-server-1`
- upload limit: `300M`
- PHP version header hidden: `HIDE_PHP_VERSION=true`

## Current Decisions

- Route phpMyAdmin only through Traefik on `websecure`.
- Keep `HIDE_PHP_VERSION=true`.
- Do not store database credentials in the stack or docs.
- Review access policy regularly because phpMyAdmin is a high-value admin surface.
- Prefer pinning the image version instead of using `latest` once the current exact version/tag policy is chosen.

## Known Issues

- The live image is `phpmyadmin/phpmyadmin:latest`. For predictable maintenance, this should eventually be replaced with a pinned version tag.
- Public hostname is `pma.format.lu`, not `phpmyadmin.format.lu`.
- Access policy for `pma.format.lu` should be reviewed with the broader Hetzner origin-hardening and admin-surface hardening work.

## Update Policy

Before updating:

1. Confirm the target phpMyAdmin version/tag.
2. Confirm the backing database service is healthy.
3. Confirm the route is protected as intended.
4. Review phpMyAdmin release notes or image tag changes.
5. Redeploy through Portainer.
6. Test the phpMyAdmin login page and database connection after the update.

## Maintenance Cadence

Run phpMyAdmin checks as part of the combined Hetzner platform maintenance run on the 15th and the last day of each month when requested.

Use this checklist:

1. Confirm `phpmyadmin_phpmyadmin` is running `1/1`.
2. Confirm the running image tag.
3. Check whether the image should be pinned or bumped.
4. Review phpMyAdmin logs for PHP, mysqli, auth, login, and database connection errors.
5. Confirm `pma.format.lu` returns an expected status through Cloudflare.
6. Confirm the local Traefik host-header route returns an expected status.
7. Confirm the service is attached to the `proxy` network.
8. Confirm `PMA_HOSTS` still points to the intended database service.
9. Confirm no database credentials are present in the stack environment.
10. If an update is applied, redeploy through Portainer and watch logs immediately after startup.
11. After any update, test UI login and database visibility.
12. Record the result in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/phpmyadmin/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/phpmyadmin/stack.example.yml): sanitized live-style Portainer stack reference
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/phpmyadmin/maintenance-log.md): ongoing maintenance history
