# Emergency PHP Runtime Update - 2026-10-21

Scope approved by Peter: TIM, NoLimits WordPress and phpMyAdmin on
`format-cloud-1`. Chargy and Floc are being handled separately by Peter.

PHP published fixes for CVE-2026-109618 and CVE-2026-109619 on October 21.
The official patched PHP Docker tags had empty amd64 manifests at inspection;
pulling `php:8.5.12-fpm-alpine` returned no matching linux/amd64 manifest.
Existing application images also contained vulnerable runtimes.

## Deployed Images

These images are **local to format-cloud-1**. They have not been published to
a registry: the configured Docker Hub token rejected pushes with
`unauthorized: access token has insufficient scopes`.

| Service | Previous PHP | Fixed PHP | Local Image |
| --- | --- | --- | --- |
| TIM | 8.4.20 | 8.4.27 | `format-security/format-dsk-tim:1.0.0-php8.4.27` |
| NoLimits | 8.3.30 | 8.3.36 | `format-security/wordpress:6.9.4-php8.3.36-apache` |
| phpMyAdmin | 8.3.26 | 8.3.36 | `format-security/phpmyadmin:5.2.3-php8.3.36-apache` |

Verified Docker image IDs:

- TIM: `sha256:1507dded1bdbcb962762b569efadf92e0c7be7c1e517e879ffe01a55e605a518`
- NoLimits: `sha256:015d46aed52058e727bf0772a92298f3011b3606a1d9793e3d188854802ddff8`
- phpMyAdmin: `sha256:899004b7c54ece6777b7ca5de8499714570ed822614c97d1beaedf8230700fe1`

NoLimits' persistent WordPress core reports `7.1.3`. The image's `6.9.4`
ancestry tag is not the live core version; the PHP replacement retained the
existing core volume and wp-content.

Swarm was updated with `--no-resolve-image` using the local tags. Saved Portainer
Compose files 8, 4 and 2 match these tags. Portainer was stopped, backed up,
and restarted for the saved-file changes; YAML semantics were checked to allow
only the intended image changes, and all three Compose files validated.

Keep these images cached. Until registry publication is completed, disable
forced image pulls on redeploy and load the image archive on any replacement
node before scheduling these services there.

## Build And Verification

`images.json` pins original application image digests, target PHP versions and
PHP.net release SHA-256 values. `Dockerfile` and `build-runtime.sh` rebuild PHP
with the inherited branch's configuration options on the same Debian variant.
Only PHP runtime, Apache module, bundled extensions, headers/build helpers and
source archive are copied into the original application image. Application
code, entrypoints, PHP configuration and additional extensions are retained.

Build on an amd64 Docker host:

```sh
python3 build-images.py
```

`verify-image.sh IMAGE EXPECTED_PHP BASELINE_MODULES_FILE` compares the CLI
extension list, starts an isolated Apache container with no external network
or host ports, and verifies HTTP JSON reports the fixed version through
`apache2handler`. Its probe files are mounted only into disposable test
containers and are not installed in the production images.

All three checks passed. Running service container image IDs matched the
tested images and PHP versions, with unchanged extension lists. TIM retained
both `interbase` and `PDO_Firebird`; NoLimits retained its image/intl modules;
phpMyAdmin retained `mysqli` and `uploadprogress`.

Origin responses after deployment: TIM 200, NoLimits apex 301/www 200,
phpMyAdmin 200. NoLimits database `SELECT 1` passed; XML-RPC remained 403 and
REST user listing 401 on both hostnames. All 18 Swarm services were 1/1.
Public automated NoLimits requests received Cloudflare 403 before deployment;
authenticated browser workflows were not tested in this intervention.

## Recovery Files

Protected server directory: `/root/php-security-20261021/`.

- `patched-images.tar.gz`: all three patched final images; gzip test passed.
  SHA-256: `46614d2b825687aa3ebbc2b0cf6468dcec005d9b76fede5c8f9b281780c0ba09`.
- `mariadb-before.sql.gz`: fresh all-database transaction-consistent dump using
  the existing backup account; gzip test passed.
- `nolimits-files-before.tgz`: WordPress core volume and wp-content file copy;
  gzip test passed. This was a live file copy, not a coordinated application
  snapshot. No restore test was performed.
- `portainer-before.tgz`: cold Portainer archive, excluding its nested backups;
  gzip test passed.
- `*.before.json`, `*.compose-before.yml`, `*.modules-before.txt`:
  original service definitions, saved Compose files and extension lists.
- `deployed-images.json`: final tags, base digests, source checksums and image IDs.

Reload patched images when needed:

```sh
gzip -t /root/php-security-20261021/patched-images.tar.gz
gzip -dc /root/php-security-20261021/patched-images.tar.gz | docker load
```

The previous images remain available for diagnosis but contain vulnerable PHP.
Prefer restoring the patched archive rather than reverting to those images.

## Follow-up

- Publish the three tested images with a Docker Hub token that has write access,
  or replace them with verified patched upstream images. Reconcile Swarm,
  Portainer and these references together when doing so.
- Verify TIM and phpMyAdmin authenticated workflows in a browser.
- Peter will update the separate Chargy and Floc images.

References:

- [PHP security advisory](https://www.php.net/archive/2026.php#2026-10-21-1)
- [CVE-2026-109618 advisory](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w)
- [CVE-2026-109619 advisory](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp)
