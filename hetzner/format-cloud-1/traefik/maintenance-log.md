# Traefik Maintenance Log

Use this log for Traefik checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record Cloudflare tokens, dashboard credentials, ACME account private keys, or other secrets here.

## 2026-04-18 - Initial Documentation

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13`

Stack version after: `traefik:3.6.13`

Checks:

- Container health checked: OK. `traefik_traefik` is running `1/1`; container has been up for 7 days.
- Running image checked: OK. Live container image is `traefik:3.6.13`.
- Swarm labels checked: Follow-up needed. Stack image label still reports `traefik:3.6.6` even though the live container runs `3.6.13`.
- Provider checked: OK. Swarm provider is enabled with `exposedByDefault=false` and provider network `proxy`.
- Ports checked: Partial. HTTPS is published on `443/tcp` and `443/udp`; inspected live output did not show host port `80` published.
- ACME storage checked: documented as `/data/traefik/certificates:/letsencrypt`.
- Log storage checked: documented as `/data/traefik/logs:/var/log`.
- Logs reviewed: Follow-up needed. Repeated ACME renewal errors observed for `novaculture.lu` and `www.novaculture.lu`.
- Dashboard/API checked: Follow-up needed. Labels define a `traefik.format.lu` router to `api@internal`, but Traefik is started with `--api=false` and `--api.dashboard=false`, causing repeated `api is not enabled` log errors.
- Update applied: No.
- Notes: Created this service documentation folder and sanitized live-style stack reference.
- Follow-up: Decide whether the Traefik dashboard should stay disabled. If yes, remove dashboard router labels. If no, enable it only with strong access control. Fix or remove the stale `novaculture.lu` certificate resolver configuration.

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Container health checked:
- Running image checked:
- Latest Traefik release checked:
- Release notes reviewed:
- Provider health checked:
- Network membership checked:
- Ports checked:
- ACME storage checked:
- Log storage checked:
- Logs reviewed:
- Certificate renewals checked:
- Routed app smoke tests checked:
- Dashboard/API policy checked:
- Update applied:
- Post-update logs checked:
- Notes:
- Follow-up:

## 2026-04-18 - Combined Maintenance Check

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13`

Stack version after: `traefik:3.6.13`

Checks:

- Container health checked: OK. `traefik_traefik` is running `1/1`; container has been up for 7 days.
- Running image checked: OK. Live container image is `traefik:3.6.13`.
- Latest Traefik release checked: OK. Latest stable release remains `3.6.13`; `3.7.0-rc.1` exists but is a release candidate and was not applied.
- Release notes reviewed: No newer stable release found.
- Provider health checked: OK. Swarm provider is enabled with `exposedByDefault=false` and provider network `proxy`.
- Network membership checked: OK. Traefik and Vaultwarden are attached to the `proxy` network.
- Ports checked: Follow-up remains. Live endpoint publishes `443/tcp` and `443/udp`; host port `80` is not published.
- ACME storage checked: OK. `/data/traefik/certificates/acme.json` exists and is non-empty.
- Log storage checked: OK. `/data/traefik/logs/access.log` exists.
- Logs reviewed: Follow-up needed. Repeated ACME renewal errors remain for `novaculture.lu` and `www.novaculture.lu`.
- Certificate renewals checked: Partial. Active storage exists, but `novaculture.lu` renewal errors remain unresolved.
- Routed app smoke tests checked: OK for Vaultwarden. Public HTTPS returned `200`; local host-header route returned `200` for `/` and `/admin`.
- Dashboard/API policy checked: Follow-up needed. `traefik.format.lu` router still points to `api@internal` while API/dashboard are disabled, causing repeated `api is not enabled` log errors.
- Update applied: No. Current version is already latest stable.
- Post-update logs checked: Not applicable.
- Notes: Swarm stack image label still reports `traefik:3.6.6` while the running service image is `traefik:3.6.13`.
- Follow-up: Reconcile the Traefik stack in Portainer so metadata matches the running image; decide whether to remove the disabled dashboard router or intentionally enable it with strong access control; fix or remove stale `novaculture.lu` ACME configuration; decide whether port `80` should be published for HTTP-to-HTTPS redirects.

## 2026-04-18 - Metadata And Stale ACME Cleanup

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13`

Stack version after: `traefik:3.6.13`

Checks:

- Stack image metadata checked: OK. Updated `com.docker.stack.image` from `traefik:3.6.6` to `traefik:3.6.13`.
- Service restart checked: OK. `traefik_traefik` converged after the metadata update.
- Novaculture service labels checked: OK. No remaining Docker service labels reference `novaculture`.
- ACME cleanup performed: OK. Removed 3 stale novaculture certificate entries from `/data/traefik/certificates/acme.json`.
- ACME backup created: `/data/traefik/certificates/acme.json.bak-20260418-124842`.
- ACME permissions checked: OK. Restored `/data/traefik/certificates/acme.json` permissions to `0600` after the JSON rewrite.
- Container health checked: OK. `traefik_traefik` is running `1/1` on `traefik:3.6.13`.
- Routed app smoke tests checked: OK. `https://bitwarden.format.lu/` returned `200`; local host-header route for Vaultwarden returned `200`.
- Logs reviewed: OK for novaculture. No remaining novaculture ACME entries were found in storage. The only current Traefik error observed after restart is the known `api is not enabled` dashboard-router mismatch.
- Notes: During cleanup, Traefik temporarily returned a Cloudflare `526` because the rewritten ACME file had `0644` permissions. This was corrected immediately by restoring `0600` and restarting Traefik.
- Follow-up: The dashboard/API mismatch remains intentionally open for later cleanup. Direct-origin exposure remains a platform hardening item.
