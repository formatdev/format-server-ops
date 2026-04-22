# Duplicati FC1 Maintenance Log

Use this log for Duplicati checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record encryption keys, backup destination credentials, SSH private keys, Duplicati UI credentials, exported job definitions containing secrets, SQL dumps, or other secrets here.

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
