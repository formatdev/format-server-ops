# NoLimits Website Maintenance Log

Use this log for NoLimits WordPress checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record database passwords, SMTP passwords, WordPress admin credentials, SQL dumps, or other secrets here.

## 2026-04-18 - Admin Surface And XML-RPC Hardening

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `wordpress:6.7-php8.3-apache`

Stack version after: `wordpress:6.9.4-php8.3-apache`

Checks:

- Container health checked: OK. `nolimits-website_wordpress` is running `1/1`.
- Running image checked: OK. Live image is `wordpress:6.9.4-php8.3-apache`.
- Cloudflare Access checked: OK. `wp-admin` and `wp-login.php` on both apex and `www` redirect to Cloudflare Access.
- XML-RPC blocked: OK. `https://nolimits.lu/xmlrpc.php` and `https://www.nolimits.lu/xmlrpc.php` return `403`.
- REST user listing checked: OK. `/wp-json/wp/v2/users` returned `401` during the initial review.
- Logs reviewed: Follow-up needed. The active `PictureThis` theme still produces repeated PHP warnings and fatal errors.
- Update applied: Yes, WordPress image was bumped by Peter from `6.7-php8.3-apache` to `6.9.4-php8.3-apache`.
- Notes: Cloudflare API token could read Access apps but could not create a new Cloudflare Access/WAF rule for XML-RPC, so XML-RPC was blocked with Traefik labels instead.
- Follow-up: Fix or replace the `PictureThis` theme; rotate database and SMTP secrets; review direct-origin exposure.

## 2026-04-18 - PictureThis PHP 8 Compatibility Patch

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `wordpress:6.9.4-php8.3-apache`

Stack version after: `wordpress:6.9.4-php8.3-apache`

Checks:

- Theme backup created: `/data/files/nolimits/website/wp-content/themes/PictureThis-backup-20260418-150659.tgz`.
- Critical error fixed: OK. `https://www.nolimits.lu/a-propos/` now returns `200`.
- Portfolio page checked: OK. `https://www.nolimits.lu/stand-m-eco-medica-2013/` returns `200`.
- PHP 8 static-method fatal patched: changed `generated_dynamic_sidebar()` to call the existing `$sbg` instance instead of `sidebar_generator::get_sidebar()` statically.
- PHP 8 unquoted array keys patched: quoted legacy `url`, `width`, and `height` array keys across the theme PHP files.
- Warning cleanup patched: removed the legacy `TEMPLATEPATH` redefinition and fixed the `$slideshow_onff` typo to `$slideshow_onoff`.
- Admin warning cleanup patched: guarded the legacy theme admin `$_GET['page']` access with `isset()` to avoid PHP 8 undefined-array-key warnings.
- Service restart checked: OK. `nolimits-website_wordpress` converged after restart.
- Post-restart logs checked: OK. No fresh PHP fatal/warning lines for the patched issues were observed in the current container logs.
- Notes: This is a compatibility patch for an old custom/commercial theme. Long term, replacing or fully modernizing `PictureThis` is still safer than accumulating patches.
- Follow-up: Continue monitoring theme logs during regular maintenance; review remaining theme/plugin code before moving to a newer PHP major version.

## 2026-04-18 - WordPress Admin Surface And Cleanup

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `wordpress:6.9.4-php8.3-apache`

Stack version after: `wordpress:6.9.4-php8.3-apache`

Checks:

- Admin config hardened: OK. Added `DISALLOW_FILE_EDIT` and `FORCE_SSL_ADMIN` to `WORDPRESS_CONFIG_EXTRA`.
- Effective config checked: OK. The running container environment includes `DISALLOW_FILE_EDIT`, `FORCE_SSL_ADMIN`, and `WP_AUTO_UPDATE_CORE`.
- `DISALLOW_FILE_MODS` decision checked: OK. Not enabled, so plugin/theme/core updates can still be performed from WordPress admin.
- Plugin cleanup checked: OK. Inactive `akismet` was moved out of `wp-content/plugins`.
- Theme cleanup checked: OK. Old inactive default themes `twentytwentyone`, `twentytwentytwo`, `twentytwentythree`, and `twentytwentyfour` were moved out of `wp-content/themes`.
- Fallback theme retained: OK. `twentytwentyfive` remains installed as the fallback theme.
- Cleanup archive created: `/data/files/nolimits/maintenance-archive/wordpress-cleanup-20260418-151625`.
- Public smoke checks: OK. Homepage and `https://www.nolimits.lu/a-propos/` returned `200`.
- Post-cleanup logs checked: OK. No fresh PHP fatal or warning lines were observed in the recent service logs.
- Notes: Cleanup was done by archiving unused items instead of hard-deleting them, so the change is reversible.
- Follow-up: Rotate database and SMTP secrets later; keep direct-origin hardening on the broader Hetzner platform list.

## 2026-04-18 - PictureThis Portfolio Thumbnail Patch

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `wordpress:6.9.4-php8.3-apache`

Stack version after: `wordpress:6.9.4-php8.3-apache`

Checks:

- Critical error identified: `https://www.nolimits.lu/lettrage-murs-vitrines/` triggered a PHP fatal in `PictureThis/picturethis/includes/thumb.php`.
- Root cause: the legacy `vt_resize()` helper passed a `WP_Error` return value from `image_resize()` into `getimagesize()`.
- Patch applied: `vt_resize()` now falls back to the original image metadata when resize returns `WP_Error`, a non-string path, a missing file, or an unreadable image.
- Public smoke checks: OK. `https://www.nolimits.lu/lettrage-murs-vitrines/` returned `200` with a full HTML response.
- Portfolio smoke check: OK. `https://www.nolimits.lu/portfolio/` returned `200`.
- Post-patch logs checked: OK. No fresh `thumb.php`, `getimagesize()`, or PHP fatal lines were observed after the patch.
- Notes: This is another compatibility patch for the legacy `PictureThis` theme. It confirms the theme replacement/modernization follow-up is still important.

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Container health checked:
- Running image checked:
- Latest WordPress image checked:
- Release notes reviewed:
- Cloudflare Access checked:
- XML-RPC block checked:
- REST user listing checked:
- Logs reviewed:
- Theme/plugin review checked:
- Backup coverage checked:
- Latest backup checked:
- Update applied:
- Post-update logs checked:
- Notes:
- Follow-up:
