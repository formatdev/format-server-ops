# Custom App Version Matrix

## October 31 Observation

- FLOC: `v3.0.11`, PHP `8.5.12`, digest
  `sha256:0414d60d3f0829b73b2e84ccc99e183817ea90f89c32adf4ad0f7d6e49ae6b84`.
- Both Chargy: `2.3.1`, PHP `8.3.36`, digest
  `sha256:75ce52b8889a6470acf0f057081e0da6e2eb29c8a43170d657c3e19e0ad56741`.
- Both Redis: `7.4.12-alpine3.21`, version/PONG verified after snapshots/update.
- TIM: local-only `format-security/format-dsk-tim:1.0.0-php8.4.27`,
  PHP `8.4.27`; registry publication remains pending.
- FLOC MySQL remains `8.4.11` on its existing pinned `mysql:8-oracle` digest.
- Deployed FLOC/Chargy Symfony Mime versions are affected by CVE-2026-45070.
  Timesheet/report/TIM source audits also need follow-up. No custom app release
  was deployed during this infrastructure round; Peter retains FLOC/Chargy
  deployment ownership.
- [Full audit counts, deployment evidence, and follow-ups](../_host/maintenance-2026-10-31.md).

## September 13 Baseline

The following historical matrix was observed on `2026-09-13` from
`hetzner-cloud-1`; use the newer observation above for current values.

Do not treat mutable tags such as `latest` or channel tags as proof that an app
is up to date. For those, compare the live image digest with the image Peter
built from the latest reviewed repo commit.

| Stack | Service | Public host | Live image | Current version posture | Maintenance action |
| --- | --- | --- | --- | --- | --- |
| `next-floc` | `next-floc_app` | `floc.lu` | `esst/floc:latest` | Mutable tag with observed digest | Run Composer/pnpm checks in `floc/apps/next`; rebuild `latest` if Peter accepts updates |
| `format-timesheet-reports` | `format-timesheet-reports_app` | `tsr.format.lu` | `esst/format-timesheet-reports:1.0.0-beta.1` | Version-like tag | Run npm checks in `timesheet-reports-2026`; rebuild/deploy if Peter accepts updates |
| `format-timesheet-2026` | `format-timesheet-2026_app` | `ts.format.lu` | `esst/format-timesheet-2026:latest` | Mutable tag | Run npm checks in `timesheet-app-2026`; rebuild `latest` if Peter accepts updates |
| `format-dsk` | `format-dsk_tim` | `dsk-tim.format.lu` | `esst/format-dsk-tim:1.0.0` | Version-like tag | Check Docker base images in `dsk/tim*/Dockerfile`; rebuild and version explicitly if Peter accepts updates |
| `chargy-loeffler` | `chargy-loeffler_app` | `chargy.loeffler.lu` | `esst/chargy:latest` | Mutable tag with observed digest | Run Composer/pnpm checks in `Chargy`; rebuild `latest` if Peter accepts updates |
| `chargy` | `chargy_app` | `chargy.format.lu` | `esst/chargy:latest` | Mutable tag with observed digest | Run Composer/pnpm checks in `Chargy`; rebuild `latest` if Peter accepts updates |

## Shared Runtime Services

Peter reported FLOC and Chargy image bumps on `2026-09-13`. Subsequent live
inspection confirmed these service image digests:

- FLOC: `sha256:8a25198cf10b6e39b869704ab4c8347cc06ef9b41704a78a13a15f733289799c`.
- Both Chargy stacks: `sha256:a0015897e46c952ea4a1c7f0783a67d856e5e8875eb951aa2e3f4d787f10e6d6`.

All three containers were running. Origin probes returned `200` for FLOC
and `302` for both Chargy routes. Build source commits and dependency review
were not independently verified during this host maintenance round.

| Stack | Service | Live image | Notes |
| --- | --- | --- | --- |
| `next-floc` | `next-floc_db` | `mysql:8-oracle` | Check MySQL release compatibility before bumping. |
| `chargy-loeffler` | `chargy-loeffler_redis` | `redis:7.4.11-alpine3.21` | Coordinate Redis bumps with app compatibility. |
| `chargy` | `chargy_redis` | `redis:7.4.11-alpine3.21` | Coordinate Redis bumps with app compatibility. |

## Maintenance Rule

Registry comparison for the mutable `esst/*` tags was unavailable from the
host on `2026-09-05`; the running services remained healthy and unchanged.

An app is current only when all are true:

- The live service is healthy.
- The live image tag/digest is recorded.
- The source repo commit used for the current image is known.
- Dependency freshness commands have been reviewed.
- The live image digest matches Peter's latest accepted build, or a newer dependency update has intentionally not been deployed yet.
- Public smoke tests and recent logs are clean after any update.
