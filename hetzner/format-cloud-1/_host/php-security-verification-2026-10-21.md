# PHP Critical Security Verification - 2026-10-21

Target: `format-cloud-1`, SSH alias `hetzner-cloud-1`.

Status: all six affected containers are patched. After Peter reported
redeploying FLOC and both Chargy stacks, live verification confirmed the fixed
image digests and PHP runtimes on October 21 at 16:32 UTC.

## Advisory

PHP released fixes for CVE-2026-109618 and CVE-2026-109619 on October 21.
Both advisories rate the vulnerabilities critical, CVSS 4.0 9.2. Fixed releases
are PHP `8.2.35`, `8.3.36`, `8.4.27`, and `8.5.12`.

Sources: [OOM corruption advisory](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w),
[stale global state advisory](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp).

## Initial Live Inventory

| Service | Initial PHP | Required PHP in same branch |
| --- | --- | --- |
| `next-floc_app` | 8.5.2 | 8.5.12 |
| `chargy_app` | 8.3.23 | 8.3.36 |
| `chargy-loeffler_app` | 8.3.23 | 8.3.36 |
| `nolimits-website_wordpress` | 8.3.30 | 8.3.36 |
| `phpmyadmin_phpmyadmin` | 8.3.26 | 8.3.36 |
| `format-dsk_tim` | 8.4.20 | 8.4.27 |

All 18 services were running `1/1` during initial inspection. No host PHP
executable was found. WordPress's persistent installation reports core `7.1.3`,
despite its older `wordpress:6.9.4-php8.3-apache` image tag.

## Work Coordination

The active `FLOC app update` and `CHARGY app update` tasks are preparing their
application security releases. `Inspect hetzner/format-wazuh` is already
building and deploying the three affected Apache services on this same host.
No instructions were sent to those tasks from this chat.

A separate fallback build was prepared in `esstdev/docker-images`, branch
`fix/php-security-20261021`. Its workflow run `39631181653` was cancelled after
discovering this overlap; none of that run's images were deployed.

After deploying both Chargy services, this task discovered Peter's newer
instruction in the other tasks to deploy Chargy and FLOC manually. Deployment
work stopped at that point. FLOC has not been redeployed by this task.

Official fixed PHP tags had empty manifests when checked, and refreshed
WordPress/phpMyAdmin images still contained vulnerable PHP. Source builds
therefore require verification of the fixed source and the resulting runtime.

## Additional Verified Backups

Created during this verification task, with mode `0600` and successful
`gzip -t` checks:

- `/data/backups/mysql/mariadb-all-databases-2026-10-21-160318.sql.gz`
- `/data/backups/php-security-20261021/floc-all-databases-20261021-160321.sql.gz`

The FLOC dump includes the normal completion marker. These integrity checks
do not constitute a restore test.

## Final Verification

| Service | Verified PHP after work | Live image |
| --- | --- | --- |
| `next-floc_app` | 8.5.12 | `esst/floc:latest`, release v3.0.11 |
| `chargy_app` | 8.3.36 | `esst/chargy:latest`, release 2.2.8 |
| `chargy-loeffler_app` | 8.3.36 | `esst/chargy:latest`, release 2.2.8 |
| `nolimits-website_wordpress` | 8.3.36 | `format-security/wordpress:6.9.4-php8.3.36-apache` |
| `phpmyadmin_phpmyadmin` | 8.3.36 | `format-security/phpmyadmin:5.2.3-php8.3.36-apache` |
| `format-dsk_tim` | 8.4.27 | `format-security/format-dsk-tim:1.0.0-php8.4.27` |

Chargy release `2.2.8` passed its published-image PHP checks in
[workflow 39631094093](https://github.com/formatdev/Chargy/actions/runs/39631094093).
Both live services use digest
`sha256:a0e2059c2e36ff797c6b506e2d05951358145066ff36c6507847fe8d82cf041a`.
Direct image pulls were denied, but retained Swarm registry authentication
successfully pulled the release. Start-first/automatic-rollback settings were
used for deployment and restored to their original stop-first/pause values
after convergence. Both app-upgrade startup processes exited 0; both origin
routes returned `302`; PHP-FPM runtime/configuration checks passed.

Subsequent live inspection showed both services on `latest` pinned to the
same fixed digest. Those later service changes were observed, not performed
by this task; the published release remains `2.2.8`.

Saved Chargy Portainer definitions `9` and `15` retain `esst/chargy:latest`;
their stored files were not modified here. The three Apache definitions were
reconciled by the other maintenance task. Its detailed build, verification,
and recovery record is [here](php-security-20261021/README.md).

The Apache images remain local-only: Docker Hub denied pushes from both
the server and this Mac. Retain the verified server recovery archive and
resolve push permissions before relying on registry-based recovery.

FLOC's fixed shared base passed AMD64 and ARM64 tests and publication in
[workflow 39631789347](https://github.com/esstdev/docker-images/actions/runs/39631789347).
An independent isolated local run of
`esst/php:8.5.12-fpm-alpine-security1` also reported PHP `8.5.12`.
Its published multi-architecture digest is
`sha256:eadadd70fe6f15e72d47da40cf1df2d1bd937837f325bdb0bf45e6d79301ec81`.
Application image `esst/floc:v3.0.11` passed build, publication, and runtime
verification in
[workflow 39633745002](https://github.com/formatdev/floc/actions/runs/39633745002).
Its published manifest-list digest is
`sha256:0414d60d3f0829b73b2e84ccc99e183817ea90f89c32adf4ad0f7d6e49ae6b84`;
the published-image PHP check passed for both AMD64 and ARM64.
After Peter reported redeploying FLOC and both Chargy stacks, the running FLOC
container was verified against that exact digest and source revision
`3144f7cef1c751ce0ab01a767bf813b1b632929d`. It started at
`2026-10-21T16:31:47Z` and reports release `v3.0.11`, PHP CLI and FPM `8.5.12`,
with a successful FPM configuration test. Both Chargy services still match
the fixed `2.2.8` digest above and report PHP CLI and FPM `8.3.36`; both FPM
configuration tests passed. Their observed container start times remain
`16:19:58Z` and `16:20:05Z`; the reported redeploy did not create newer
containers, but the running content is the expected patched release.

The fresh public and origin checks returned FLOC `200` and both Chargy roots
`302`. All three origin login pages returned `200`. No matching fatal,
segmentation-fault, extension-load, or SQLSTATE errors appeared in the sampled
current-container logs from the preceding ten minutes. The other three PHP
containers were rechecked and retain the fixed runtime versions in the table.

Final host checks found all 18 services at `1/1`. Origin responses were `200`
for FLOC, NoLimits, phpMyAdmin, and TIM, and `302` for both Chargy routes.
These are routing/application availability checks, not authenticated user
workflows or proof that the previous vulnerable runtimes were never exploited.
