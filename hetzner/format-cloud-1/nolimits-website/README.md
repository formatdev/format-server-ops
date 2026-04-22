# NoLimits Website On format-cloud-1

This folder documents the NoLimits WordPress service hosted through Portainer on the Hetzner server `hetzner-cloud-1`.

WordPress is a high-volume attack target. Keep this runbook focused on updates, admin-surface protection, plugin/theme hygiene, and backup verification.

## Live Service

- service: NoLimits WordPress website
- server: `hetzner-cloud-1`
- Docker service: `nolimits-website_wordpress`
- public hostnames: `nolimits.lu`, `www.nolimits.lu`
- current live image: `wordpress:6.9.4-php8.3-apache`
- reverse proxy: Traefik on external Docker network `proxy`
- backend container port: `80`
- WordPress database host: `database-1_db`
- WordPress content bind mount: `/data/files/nolimits/website/wp-content:/var/www/html/wp-content`

## Current Decisions

- Pin the WordPress image instead of using `latest`.
- Keep PHP on `8.3` until the custom theme is fixed or replaced.
- Protect `wp-admin` and `wp-login.php` with Cloudflare Access.
- Block `xmlrpc.php` at Traefik.
- Keep REST user listing restricted.
- Disable WordPress' built-in plugin/theme file editor with `DISALLOW_FILE_EDIT`.
- Force SSL for WordPress admin with `FORCE_SSL_ADMIN`.
- Keep admin-driven plugin/theme/core updates available; do not set `DISALLOW_FILE_MODS` unless updates should be fully blocked from the admin UI.
- Do not record database or SMTP secrets in this repository.

## Admin Protection

Cloudflare Access protects:

- `nolimits.lu/wp-admin`
- `nolimits.lu/wp-login.php`
- `www.nolimits.lu/wp-admin`
- `www.nolimits.lu/wp-login.php`

Allowed identity domains are currently:

- `nolimits.lu`
- `format.lu`
- `esst.lu`

## XML-RPC Block

XML-RPC is blocked through a high-priority Traefik router:

```text
(Host(`nolimits.lu`) || Host(`www.nolimits.lu`)) && Path(`/xmlrpc.php`)
```

The router uses an IP allowlist middleware that only allows `127.0.0.1/32`, so public requests receive `403`.

## Plugin And Theme Hygiene

Current active plugins:

- `better-search-replace`
- `disable-json-api`
- `updraftplus`
- `wp-mail-smtp`

Current themes:

- `PictureThis`: active theme
- `twentytwentyfive`: fallback theme

Archived cleanup items:

- `/data/files/nolimits/maintenance-archive/wordpress-cleanup-20260418-151625`

## Known Issues

- The active `PictureThis` theme is legacy and has received compatibility patches for PHP 8. Continue monitoring it and plan a replacement or full modernization.
- Database and SMTP secrets are currently present in Docker service environment variables. Rotate and improve secret handling later.
- Direct-origin exposure remains a broader Hetzner platform hardening item.

## Maintenance Checklist

1. Confirm `nolimits-website_wordpress` is running `1/1`.
2. Confirm the running WordPress image tag.
3. Check the latest WordPress Docker image tag and release notes.
4. Confirm `wp-admin` and `wp-login.php` still redirect to Cloudflare Access.
5. Confirm `/xmlrpc.php` returns `403` on both hostnames.
6. Review logs for PHP fatal errors, plugin errors, auth attempts, and suspicious paths.
7. Confirm REST user listing remains restricted.
8. Confirm backups include the database and `/data/files/nolimits/website/wp-content`.
9. Review active plugins and themes; remove unused items where safe.
10. Record changes in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/nolimits-website/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/nolimits-website/stack.example.yml): sanitized live-style Portainer stack reference
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/nolimits-website/maintenance-log.md): ongoing maintenance history
