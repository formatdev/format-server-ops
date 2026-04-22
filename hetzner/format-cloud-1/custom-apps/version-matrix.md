# Custom App Version Matrix

Observed on `2026-04-18` from `hetzner-cloud-1`.

Do not treat mutable tags such as `latest`, `dsk-pm`, or `tim` as proof that an app is up to date. For those, compare the live image digest with the image Peter built from the latest reviewed repo commit.

| Stack | Service | Public host | Live image | Current version posture | Maintenance action |
| --- | --- | --- | --- | --- | --- |
| `next-floc` | `next-floc_app` | `floc.lu` | `esst/floc:latest` | Mutable tag with observed digest | Run Composer/pnpm checks in `floc/apps/next`; rebuild `latest` if Peter accepts updates |
| `format-timesheet-reports` | `format-timesheet-reports_app` | `tsr.format.lu` | `esst/format-timesheet-reports:1.0.0-beta.1` | Version-like tag | Run npm checks in `timesheet-reports-2026`; rebuild/deploy if Peter accepts updates |
| `format-timesheet-2026` | `format-timesheet-2026_app` | `ts.format.lu` | `esst/format-timesheet-2026:latest` | Mutable tag | Run npm checks in `timesheet-app-2026`; rebuild `latest` if Peter accepts updates |
| `format-dsk` | `format-dsk_pm` | `dsk-pm.format.lu` | `esst/format:dsk-pm` | Channel tag | Check Docker base images in `dsk/pm/docker/Dockerfile`; rebuild channel tag if Peter accepts updates |
| `format-dsk` | `format-dsk_tim` | `dsk-tim.format.lu` | `esst/format-dsk:tim` | Channel tag | Check Docker base images in `dsk/tim*/Dockerfile`; rebuild channel tag if Peter accepts updates |
| `chargy-loeffler` | `chargy-loeffler_app` | `chargy.loeffler.lu` | `esst/chargy:latest` | Mutable tag with observed digest | Run Composer/pnpm checks in `Chargy`; rebuild `latest` if Peter accepts updates |
| `chargy` | `chargy_app` | `chargy.format.lu` | `esst/chargy:latest` | Mutable tag with observed digest | Run Composer/pnpm checks in `Chargy`; rebuild `latest` if Peter accepts updates |

## Shared Runtime Services

| Stack | Service | Live image | Notes |
| --- | --- | --- | --- |
| `next-floc` | `next-floc_db` | `mysql:8-oracle` | Check MySQL release compatibility before bumping. |
| `chargy-loeffler` | `chargy-loeffler_redis` | `redis:7.4-alpine3.21` | Coordinate Redis bumps with app compatibility. |
| `chargy` | `chargy_redis` | `redis:7.4-alpine3.21` | Coordinate Redis bumps with app compatibility. |

## Maintenance Rule

An app is current only when all are true:

- The live service is healthy.
- The live image tag/digest is recorded.
- The source repo commit used for the current image is known.
- Dependency freshness commands have been reviewed.
- The live image digest matches Peter's latest accepted build, or a newer dependency update has intentionally not been deployed yet.
- Public smoke tests and recent logs are clean after any update.
