# Duplicati FC1 Maintenance Log

Use this log for Duplicati checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record encryption keys, backup destination credentials, SSH private keys, Duplicati UI credentials, exported job definitions containing secrets, SQL dumps, or other secrets here.

## 2026-09-05 - Duplicati Stable Upgrade

Date: 2026-09-05 09:34 CEST

Maintainer: Codex with Peter

Stack version before: `duplicati/duplicati@sha256:01f8cb81ad7d548b7ceec61d696bb5d27d8057fee0ddee37c2b8a0ff1f1729f7`

Stack version after: `duplicati/duplicati@sha256:eb0c1298a1974048332745b393897ae3cc1c20258e4fc26a796f2b5d75eb6218`

Checks:

- Latest upstream release checked: OK. `v2.4.0.0_stable_2026-09-03` superseded the previous `2.3.0.4` stable release.
- Breaking permission change reviewed: OK. The actual application data directory `/data/Duplicati` was root-owned with mode `0700`, matching the new strict requirement.
- Container and metadata checked: OK. The service is `1/1`, and both the live image and stack label use the tested digest `sha256:eb0c1298a1974048332745b393897ae3cc1c20258e4fc26a796f2b5d75eb6218`.
- Mounted paths checked: OK. The existing named data volume and read-only host source mounts remained configured.
- Route checked: OK. `duplicati-fc1.format.lu` returned `200` after a brief Traefik discovery delay.
- Logs reviewed: OK. Duplicati started and listened on port `8200` without permission, configuration, migration, or database errors.
- Update applied: Yes.
- Follow-up: Confirm the next scheduled remote backup completes in the Duplicati UI and retain the normal restore-test cadence.

## 2026-07-19 - Duplicati Image Refresh

Date: 2026-07-19 09:44 CEST

Maintainer: Codex with Peter

Stack version before: `duplicati/duplicati@sha256:50555cd2cf1cd140ee240996cc3b94afb0254d07f6bccc5495561530a6c3d6ab`

Stack version after: `duplicati/duplicati@sha256:01f8cb81ad7d548b7ceec61d696bb5d27d8057fee0ddee37c2b8a0ff1f1729f7`

Checks:

- Container health checked: OK. `duplicati-fc1_duplicati_fc1` is `1/1`.
- Running image checked: OK. Live image digest is `sha256:01f8cb81ad7d548b7ceec61d696bb5d27d8057fee0ddee37c2b8a0ff1f1729f7`.
- Stack image metadata checked: OK. `com.docker.stack.image` reports the same pinned digest as the live service image.
- Latest upstream release checked: OK. Latest stable release observed during this run is `v2.3.0.4_stable_2026-07-09`.
- Duplicati version checked: OK. Container changelog starts with `2026-07-09 - 2.3.0.4_stable_2026-07-09`.
- Mounted paths checked: OK. Service started with the existing mounts and listened on port `8200`.
- Route checked: OK. Local host-header route for `duplicati-fc1.format.lu` returned `200`.
- Logs reviewed: OK. Startup log showed the server listening on port `8200`.
- Update applied: Yes.
- Notes: The service remains pinned by digest after pulling the current `duplicati/duplicati:latest` image.
- Follow-up: Check the Duplicati UI for last successful backup, verification status, destination health, and last restore test.

## 2026-06-14 - Duplicati Image Refresh

Date: 2026-06-14 18:16 CEST

Maintainer: Codex with Peter

Stack version before: `duplicati/duplicati@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Stack version after: `duplicati/duplicati@sha256:50555cd2cf1cd140ee240996cc3b94afb0254d07f6bccc5495561530a6c3d6ab`

Checks:

- Container health checked: OK. `duplicati-fc1_duplicati_fc1` is `1/1`.
- Running image checked: OK. Live image digest is `sha256:50555cd2cf1cd140ee240996cc3b94afb0254d07f6bccc5495561530a6c3d6ab`.
- Stack image metadata checked: OK. `com.docker.stack.image` now reports the same pinned digest as the live service image.
- Latest upstream release checked: OK. Latest stable release observed during this run remains `v2.3.0.1_stable_2026-04-24`.
- Mounted paths checked: OK. Service started with the existing mounts and listened on port `8200`.
- Route checked: OK. Local host-header route for `duplicati-fc1.format.lu` returned `200`.
- Logs reviewed: OK. Startup log showed the server listening on `0.0.0.0:8200`.
- Update applied: Yes.
- Notes: The service remains pinned by digest after pulling the current `duplicati/duplicati:latest` image. Metadata label reconciliation caused a brief recycle; the service returned to `1/1`.
- Follow-up: Check the Duplicati UI for last successful backup, verification status, destination health, and last restore test.

## 2026-04-18 - Initial Runbook And Version Check

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Stack version after: `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Checks:

- Container health checked: OK. `duplicati-fc1_duplicati_fc1` is running `1/1`.
- Public route checked: OK. `https://duplicati-fc1.format.lu/` redirects to Cloudflare Access.
- Running image checked: OK. Live image is `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`.
- Registry digest checked: OK. Docker registry `duplicati/duplicati:latest` currently resolves to the same index digest.
- Duplicati version checked: OK. Container changelog shows `2.3.0.0_stable_2026-04-14`.
- Latest upstream release checked: OK. GitHub latest release is `v2.3.0.0_stable_2026-04-14`.
- Mounted paths checked: OK. `/data`, `/source-data`, `/source-etc`, `/source-root`, and `/sshkeys` exist in the running container.
- SSH key mount checked: OK. `/sshkeys/synology_backup_ed25519` exists in the running container.
- Settings encryption checked: OK. `SETTINGS_ENCRYPTION_KEY` is set in the running container. Value not recorded.
- Recent active logs checked: OK. No matching errors were observed in the last 10 minutes.
- Historical logs reviewed: Follow-up noted. Earlier restarts showed missing encryption key and missing `/sshkeys`; current container state shows both are now present.
- Backup metadata checked: Partial. `/data/Duplicati/Duplicati-server.sqlite` and one backup copy of the server database exist in the Duplicati data volume.
- Notes: Duplicati `2.3.0.0_stable_2026-04-14` includes a server database schema update to version 11, so rollback needs extra care.
- Follow-up: Check the Duplicati UI for last successful backup, verification status, destination health, and last restore test. Consider making `/data:/source-data` read-only if backup jobs do not need write access to that mount. Move secret values toward Docker secrets or another controlled process later.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Stack version before: `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Stack version after: `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Checks:

- Container health checked: OK. `duplicati-fc1_duplicati_fc1` is `1/1`.
- Public route checked: OK. `https://duplicati-fc1.format.lu/` redirects to
  Cloudflare Access.
- Running image checked: OK. Live image digest is
  `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`.
- Registry digest checked: Follow-up needed. The current `latest` registry
  digest now resolves to `sha256:c5cc20fc744cce2957a61cb0b331ecdf333c9fcf28281f96cc587e11ed4536af`.
- Duplicati version checked: Partial. The deployed digest still corresponds to
  the older April stable build; GitHub now shows `v2.3.0.1_stable_2026-04-24`
  as the latest release.
- Upstream release checked: Update available. Latest release is
  `v2.3.0.1_stable_2026-04-24`.
- Mounted paths checked: OK. `/data`, `/source-data`, `/source-etc`,
  `/source-root`, and `/sshkeys` are present as expected.
- SSH key mount checked: OK. `/sshkeys/synology_backup_ed25519` exists.
- Settings encryption checked: OK. `SETTINGS_ENCRYPTION_KEY` is set.
- Backup jobs checked in UI: Not checked from CLI.
- Last successful backup checked: Partial. Duplicati metadata records
  `LastBackupDate=20260502T183000Z`.
- Verification/restore test checked: Not verified in this run.
- Logs reviewed: Follow-up needed. Duplicati notifications show repeated backup
  warnings because `/source-data/portainer/data/portainer.db` is locked during
  backup, and the database also reports that `v2.3.0.1` is available.
- Update applied: No.
- Rollback notes: Keep the current server database and backup definitions intact
  if a future Duplicati image update is tested.
- Notes: Backup coverage for Portainer is currently partial because the live
  `portainer.db` file is skipped when locked.
- Follow-up: Check the Duplicati UI for job health and restore-test status,
  decide whether to upgrade to `2.3.0.1`, and create a consistent backup path
  for Portainer state instead of relying on the locked live database file.

## 2026-05-03 - Portainer Live Data Exclusion

Date: 2026-05-03 09:25 CEST

Maintainer: Codex with Peter

Checks:

- Duplicati configuration backup created: OK. Backed up
  `Duplicati-server.sqlite` before changing the job filter list.
- Backup job filter updated: OK. Added `/source-data/portainer/data/` as an
  exclusion for `format-cloud-1 to Synology`.
- Filter verification checked: OK. The live filter list now excludes database
  dumps, the live Portainer data directory, Traefik logs, and `/root/.cache/`.
- Warning source addressed: OK. Future runs should stop trying to copy the
  locked live `portainer.db` file and instead rely on the quiesced archive
  under `/source-data/backups/portainer/`.
- Service restart applied: No. The Duplicati container was left running.
- Follow-up: Confirm after the next scheduled backup that the previous
  `portainer.db` locked-file warning no longer appears in Duplicati
  notifications.

## 2026-05-03 - Image Pinning

Date: 2026-05-03 12:04 CEST

Maintainer: Codex with Peter

Stack version before: `duplicati/duplicati:latest@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Stack version after: `duplicati/duplicati@sha256:d63ea5b2524b7e73889f3c7b9bee48690cc6dc4ae7f46f48d9c70d265e2f99ce`

Checks:

- Pinning target chosen: OK. Pinned Duplicati to the currently tested image
  digest rather than a mutable `latest` tag.
- Unpullable tag attempt reviewed: OK. The human-readable version-style tag
  `2.3.0.0_stable_2026-04-14` was not available from Docker Hub and caused a
  brief paused update state before the digest pin was applied.
- Service recovery checked: OK. `duplicati-fc1_duplicati_fc1` returned to `1/1`
  on the pinned digest.
- Route check after pinning: OK. `https://duplicati-fc1.format.lu/` still
  returns the expected Cloudflare Access challenge path.
- Startup logs checked: OK. Recent logs show the server listening on port
  `8200`.
- Notes: This change improves rollout predictability without changing the tested
  Duplicati build itself.
- Follow-up: When a future Duplicati upgrade is chosen, move from this digest
  pin to the next explicitly tested digest or documented pullable tag.

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Container health checked:
- Public route checked:
- Running image checked:
- Registry digest checked:
- Duplicati version checked:
- Upstream release checked:
- Mounted paths checked:
- SSH key mount checked:
- Settings encryption checked:
- Backup jobs checked in UI:
- Last successful backup checked:
- Verification/restore test checked:
- Logs reviewed:
- Update applied:
- Rollback notes:
- Notes:
- Follow-up:
