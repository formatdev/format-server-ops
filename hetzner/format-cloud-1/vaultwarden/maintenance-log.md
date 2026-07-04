# Vaultwarden Maintenance Log

Use this log for the combined Vaultwarden maintenance run on the 15th and the last day of each month.

Do not record real admin passwords, invite links, backup credentials, or unredacted hashes here.

## 2026-07-04 - Metadata And Route Check

Date: 2026-07-04 17:54 CEST

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.36.0`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.36.0`

Checks:

- Container health checked: OK. `vaultwarden_server` is `1/1` and healthy after the host reboot.
- Vaultwarden release checked: OK. Latest GitHub release remains `1.36.0`.
- Traefik routing checked: OK. Local host-header route for `bitwarden.format.lu` returned `200` after provider convergence.
- Stack image metadata checked: OK. Reconciled stale `com.docker.stack.image` metadata from `1.35.7` to `1.36.0`.
- Update applied: No image update. Metadata label only.
- Notes: The first post-reboot local route check returned `404` while Traefik was resyncing provider state; repeated checks returned `200`.
- Follow-up: Direct origin exposure and UI-level backup/restore verification remain broader platform follow-ups.

## 2026-04-18 - Initial Documentation

- documented the format-cloud-1 Vaultwarden stack
- selected `ghcr.io/dani-garcia/vaultwarden:1.35.4` as the current target image
- documented that the admin token should be rotated because the previous plain token was exposed in chat
- documented the hashed `ADMIN_TOKEN` workflow
- documented `SIGNUPS_ALLOWED=false` as the safe default
- documented twice-monthly maintenance as the intended cadence
- updated the cadence to one combined health, backup, release, and update check on the 15th and the last day of each month when requested

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Container health checked:
- Vaultwarden release checked:
- Release notes reviewed:
- Container logs reviewed:
- Traefik routing checked:
- TLS checked:
- Normal login checked:
- Admin login checked:
- Signup policy checked:
- Admin token hash checked:
- Cloudflare protection checked:
- Direct origin exposure checked:
- Backup coverage checked:
- Latest backup checked:
- Update applied:
- Post-update logs checked:
- Browser extension or mobile sync checked:
- Notes:
- Follow-up:

## 2026-04-18 - Manual Combined Maintenance Run

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.4`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.35.4`

Checks:

- Container health checked: OK. `vaultwarden_server` is running `1/1`; container reports `healthy` and has been up for 9 days.
- Vaultwarden release checked: latest official GitHub release found: `1.35.7`, released 2026-04-13.
- Release notes reviewed: `1.35.7` notes mention a 2FA fix for Android. Update recommended but not applied during this run.
- Container logs reviewed: OK overall. Recent normal login responses observed. Minor `PathBuf` `BadStart('.')` warnings observed; no panic or database failure found in filtered logs.
- Traefik routing checked: OK for Vaultwarden. Local Traefik checks returned `200` for `/` and `/admin` with `Host: bitwarden.format.lu`.
- TLS checked: public HTTPS returned `200` through Cloudflare.
- Normal login checked: Not interactively checked. Logs show recent successful `/identity/connect/token` responses.
- Admin login checked: Not interactively checked. `/admin` route returned `200`; credential login was not performed from CLI.
- Signup policy checked: OK. `SIGNUPS_ALLOWED=false`.
- Admin token hash checked: OK. `ADMIN_TOKEN` is present and detected as an Argon2 hash. The value was not recorded.
- Cloudflare protection checked: OK for public DNS path. Public HTTPS resolved to a Cloudflare IP.
- Direct origin exposure checked: Follow-up needed. Direct-origin HTTPS to `188.245.43.92` with the `bitwarden.format.lu` host header returned `200` for both `/` and `/admin`.
- Backup coverage checked: Partial. Vaultwarden data path exists in the container and `/data/db.sqlite3` exists.
- Latest backup checked: Partial. Duplicati service is running, but no clear last-successful backup line was found in recent container logs.
- Update applied: No.
- Post-update logs checked: Not applicable.
- Browser extension or mobile sync checked: Not checked from CLI.
- Notes: Traefik logs include repeated ACME renewal errors for `novaculture.lu` and `www.novaculture.lu`; these appear unrelated to Vaultwarden but should be cleaned up separately.
- Follow-up: Decide whether to update Vaultwarden from `1.35.4` to `1.35.7`; verify Duplicati backup status in the Duplicati UI; consider restricting origin access so Vaultwarden is reachable only through Cloudflare; consider adding extra protection for `/admin` through Cloudflare Access, Traefik IP allowlisting, or equivalent.

## 2026-04-18 - Post-Update Smoke Test

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.4`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

Checks:

- Container health checked: OK. `vaultwarden_server` is running `1/1`; container reports `healthy`.
- Public HTTPS checked: OK. `https://bitwarden.format.lu/` returned `200` through Cloudflare.
- Traefik routing checked: OK. Local Traefik checks returned `200` for `/` and `/admin` with `Host: bitwarden.format.lu`.
- Post-update logs checked: Vaultwarden started successfully as version `1.35.7`; Rocket launched on port `80`; `/api/config`, websocket notifications, and `/admin` returned `200`.
- Admin token hash checked: Follow-up needed. The stack environment has an Argon2-looking `ADMIN_TOKEN`, but Vaultwarden logs say `/data/config.json` overrides `ADMIN_TOKEN` and the active value is plain text.
- Signup policy checked: Follow-up needed. The stack environment has `SIGNUPS_ALLOWED=false`, but `/data/config.json` overrides it and currently contains `"signups_allowed": true`.
- Traefik logs checked: no Vaultwarden-specific Traefik routing failure observed. Existing unrelated Traefik `api is not enabled` errors remain.
- Update applied: Yes, `1.35.4` to `1.35.7`.
- Notes: Functional smoke tests passed, but active Vaultwarden admin settings are controlled by `/data/config.json`, not by the stack environment.
- Follow-up: Open Vaultwarden `/admin`, set signups to disabled, replace the active admin token with the Argon2 hash, save config, restart Vaultwarden, and confirm startup no longer warns about a plain text `ADMIN_TOKEN`.

## 2026-04-18 - Persisted Config Hardening

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

Checks:

- Config backup created: `/data/files/vaultwarden/data/config.json.bak-20260418-120426`.
- Admin token hash checked: OK. `/data/config.json` now contains an Argon2-hashed `admin_token`.
- Signup policy checked: OK. `/data/config.json` now contains `"signups_allowed": false`.
- Service restart checked: OK. `docker service update --force vaultwarden_server` converged.
- Container health checked: OK. `vaultwarden_server` is running `1/1`; container reports `healthy`.
- Public HTTPS checked: OK. `https://bitwarden.format.lu/` returned `200` through Cloudflare.
- Traefik routing checked: OK. Local Traefik checks returned `200` for `/` and `/admin` with `Host: bitwarden.format.lu`.
- Post-restart logs checked: OK. Vaultwarden started as version `1.35.7`; no plain text `ADMIN_TOKEN` warning was present in the latest startup log.
- Notes: Vaultwarden still logs that `DOMAIN`, `SIGNUPS_ALLOWED`, and `ADMIN_TOKEN` are overridden by `data/config.json`; this is expected now because the persisted values have been hardened.
- Follow-up: Direct origin access and Duplicati backup verification remain open platform-maintenance items.

## 2026-04-18 - Combined Maintenance Check

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

Checks:

- Container health checked: OK. `vaultwarden_server` is running `1/1`; container reports `healthy`.
- Vaultwarden release checked: OK. Latest stable release remains `1.35.7`.
- Release notes reviewed: No newer stable release found.
- Container logs reviewed: OK. Current startup logs show version `1.35.7` and no plain-text `ADMIN_TOKEN` warning. The persisted config override notice remains expected.
- Traefik routing checked: OK. Local Traefik checks returned `200` for `/` and `/admin` with `Host: bitwarden.format.lu`.
- TLS checked: OK. Public HTTPS returned `200` through Cloudflare.
- Normal login checked: Not interactively checked.
- Admin login checked: Not interactively checked. `/admin` route returned `200`.
- Signup policy checked: OK. `/data/config.json` contains `"signups_allowed": false`.
- Admin token hash checked: OK. `/data/config.json` contains an Argon2-hashed `admin_token`.
- Cloudflare protection checked: OK for the public DNS path. Public HTTPS resolved to a Cloudflare IP.
- Direct origin exposure checked: Follow-up still needed. Direct-origin HTTPS to `188.245.43.92` with the `bitwarden.format.lu` host header returned `200`.
- Backup coverage checked: Partial. Vaultwarden data path and database exist.
- Latest backup checked: Partial. Duplicati logs did not show a clear success/failure line from CLI; verify in the Duplicati UI.
- Update applied: No. Current version is already latest stable.
- Post-update logs checked: Not applicable.
- Browser extension or mobile sync checked: Not checked from CLI.
- Notes: No Vaultwarden image bump was needed.
- Follow-up: Lock down direct origin access where practical and verify backup success in Duplicati UI.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.7@sha256:9a8eec71f4a52411cc43edc7a50f33e9b6f62b5baca0dd95f0c6e7fd60f1a341`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.35.7@sha256:9a8eec71f4a52411cc43edc7a50f33e9b6f62b5baca0dd95f0c6e7fd60f1a341`

Checks:

- Container health checked: OK. `vaultwarden_server` is `1/1` and healthy.
- Vaultwarden release checked: OK. Latest verifiable official release remains
  `1.35.7`, published 2026-04-13.
- Release notes reviewed: No newer stable patch release was verified in this
  run.
- Container logs reviewed: OK overall. Recent logs show successful login-token
  responses; the recurring `PathBuf BadStart('.')` warnings remain but no
  database or startup failure was observed.
- Traefik routing checked: OK. Public `https://bitwarden.format.lu/` returned
  `200`.
- TLS checked: OK. Public HTTPS is responding normally through Cloudflare.
- Normal login checked: Not interactively checked. Logs show recent successful
  `/identity/connect/token` responses.
- Admin login checked: Not interactively checked in this run.
- Signup policy checked: OK. `SIGNUPS_ALLOWED=false` remains set in the service
  environment and persisted config.
- Admin token hash checked: OK. `ADMIN_TOKEN` remains Argon2-hashed in the
  service environment and persisted config.
- Cloudflare protection checked: OK. Public DNS continues to resolve through
  Cloudflare.
- Direct origin exposure checked: OK from this workstation. Direct-origin probes
  to `188.245.43.92` with the Vaultwarden host header timed out.
- Backup coverage checked: Partial. Vaultwarden data remains under
  `/data/files/vaultwarden/data`, which is included in the broader Duplicati
  source-data backup path.
- Latest backup checked: Partial. The Duplicati metadata check shows the latest
  backup date as `2026-05-02 18:30 UTC`.
- Update applied: No.
- Post-update logs checked: Not applicable.
- Browser extension or mobile sync checked: Not checked in this run.
- Notes: The earlier April config-hardening work is still in place and appears
  durable across the reboot and later host changes.
- Follow-up: Keep an eye on the recurring `PathBuf` warnings even though they
  are not currently blocking service health.

## 2026-05-03 - Vaultwarden Upgrade To 1.35.8

Date: 2026-05-03 11:20 CEST

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.35.8`

Checks:

- Container update applied: OK. Updated `vaultwarden_server` to
  `ghcr.io/dani-garcia/vaultwarden:1.35.8`.
- Container health checked: OK. The replacement task reached `1/1` and healthy
  state.
- Startup logs checked: OK. Vaultwarden `1.35.8` launched normally and
  continued using the persisted `config.json`.
- Web vault version checked: OK. The running container now reports
  `Web-Vault 2026.3.1`.
- Route check after update: OK. Local Traefik host-header probes for
  `bitwarden.format.lu` returned `200` after service convergence.
- Notes: This matches the newer web vault version already seen on
  `bitwarden.esst.lu`.
- Follow-up: Do one normal browser login check when convenient, mainly to
  confirm the newer web vault behaves as expected for day-to-day users.

## 2026-05-17 - Vaultwarden Upgrade To 1.36.0

Date: 2026-05-17 14:52 CEST

Maintainer: Codex with Peter

Stack version before: `ghcr.io/dani-garcia/vaultwarden:1.35.8`

Stack version after: `ghcr.io/dani-garcia/vaultwarden:1.36.0`

Checks:

- Container health checked: OK. `vaultwarden_server` returned to `1/1` and
  healthy.
- Vaultwarden release checked: OK. Latest official GitHub release observed
  during this run is `1.36.0`.
- Release notes reviewed: `1.36.0` includes security fixes and a web-vault
  update, so the patch was treated as worth applying promptly.
- Container logs reviewed: OK. Vaultwarden `1.36.0` launched normally and
  continued using the persisted `data/config.json`.
- Traefik routing checked: OK after convergence. Public
  `https://bitwarden.format.lu/` returned `200`.
- TLS checked: OK. Public HTTPS continued to work through Cloudflare after the
  update.
- Normal login checked: Not interactively checked in this run.
- Admin login checked: Not interactively checked in this run.
- Signup policy checked: OK. Startup logs still show `SIGNUPS_ALLOWED` is
  managed through the persisted config.
- Admin token hash checked: OK. Startup logs still show `ADMIN_TOKEN` is
  managed through the persisted config.
- Cloudflare protection checked: OK. Public access remains proxied by
  Cloudflare.
- Direct origin exposure checked: Not revalidated in this run.
- Backup coverage checked: Partial. Vaultwarden data remains under
  `/data/files/vaultwarden/data`, inside the broader host backup scope.
- Latest backup checked: Not revalidated in this run.
- Update applied: Yes.
- Post-update logs checked: OK. The final startup log shows Rocket launched on
  port `80` without application errors.
- Browser extension or mobile sync checked: Not checked in this run.
- Notes: The update took a little while to finish pulling and pass health, but
  it converged cleanly in the end.
- Follow-up: Do one real browser login and `/admin` sanity check when
  convenient, mainly because `1.36.0` includes security-sensitive changes.
