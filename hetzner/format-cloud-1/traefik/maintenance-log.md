# Traefik Maintenance Log

Use this log for Traefik checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record Cloudflare tokens, dashboard credentials, ACME account private keys, or other secrets here.

## 2026-06-14 - Traefik Patch Upgrade

Date: 2026-06-14 18:15 CEST

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.17`

Stack version after: `traefik:3.6.21`

Checks:

- Container health checked: OK. `traefik_traefik` is `1/1`.
- Running image checked: OK. Live service uses `traefik:3.6.21`.
- Stack image metadata checked: OK. `com.docker.stack.image` now reports `traefik:3.6.21`.
- Latest Traefik release checked: OK. Latest `3.6.x` patch observed during this run is `v3.6.21`; newer `3.7.x` releases exist and were not applied as a routine line jump.
- Provider health checked: OK. Swarm provider remained active on the `proxy` network.
- Network membership checked: OK. Routed services remained attached and recovered after update.
- Ports checked: OK. HTTPS remained published on `443/tcp` and `443/udp`.
- Logs reviewed: OK after convergence. Early startup showed the familiar temporary missing middleware lines, but a fresh post-convergence error sample was quiet.
- Routed app smoke tests checked: OK. Local host-header probes for representative routes returned expected responses.
- Dashboard/API policy checked: OK. The dashboard remains intentionally disabled.
- Update applied: Yes.
- Notes: Metadata label reconciliation caused a brief recycle after the version update; Traefik returned to `1/1` and the final route checks passed.
- Follow-up: None from this Traefik patch pass.

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

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13@sha256:34d5089d0b414945342848518b383f11f5b3a645504ed87b77ffeb9d683d0e48`

Stack version after: `traefik:3.6.13@sha256:34d5089d0b414945342848518b383f11f5b3a645504ed87b77ffeb9d683d0e48`

Checks:

- Container health checked: OK. `traefik_traefik` is `1/1`.
- Running image checked: OK. Live image digest is the one above.
- Latest Traefik release checked: OK. Latest verifiable stable release remains
  `v3.6.13` (published 2026-04-07).
- Release notes reviewed: No newer stable patch release was verified in this
  run.
- Provider health checked: OK. Swarm provider remains enabled with
  `exposedByDefault=false` on the `proxy` network.
- Network membership checked: OK. Traefik remains attached to the shared proxy
  network.
- Ports checked: OK for current use. Public HTTPS routes continue to respond as
  expected.
- ACME storage checked: OK. `/data/traefik/certificates/acme.json` exists and
  is non-empty.
- Log storage checked: OK. `/data/traefik/logs/access.log` exists and is
  growing.
- Logs reviewed: OK. No recent filtered Traefik error lines were observed in
  this run.
- Certificate renewals checked: OK in this run. No fresh renewal errors were
  observed in the recent log sample.
- Routed app smoke tests checked: OK. Public checks for the documented services
  returned the expected `200`, `302`, and `403` responses.
- Dashboard/API policy checked: Follow-up needed. The service still advertises a
  `traefik.format.lu` router to `api@internal` while `--api=false` and
  `--api.dashboard=false` remain set.
- Update applied: No.
- Post-update logs checked: Not applicable.
- Notes: Direct-origin probes to several Access-protected hostnames timed out
  from this workstation, which is an improvement over the earlier April direct
  origin exposure finding.
- Follow-up: Decide whether to remove the dashboard router or intentionally
  enable the dashboard behind strong access control.

## 2026-05-03 - Disabled Dashboard Route Cleanup

Date: 2026-05-03 11:09 CEST

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13`

Stack version after: `traefik:3.6.13`

Checks:

- Live labels reviewed: OK. The service still had stale `traefik.format.lu`
  router labels pointing to `api@internal`.
- Dashboard route cleanup applied: OK. Removed the stale dashboard router and
  dummy service labels from `traefik_traefik`.
- Container health checked: OK. `traefik_traefik` returned to `1/1` after the
  service update.
- Post-change logs checked: OK. No fresh `api is not enabled` lines appeared in
  the immediate post-change log sample.
- Route behavior checked: OK. Local host-header requests for `traefik.format.lu`
  now return `404` without the stale internal API route.
- Notes: The Traefik dashboard remains intentionally disabled.
- Follow-up: Leave the dashboard disabled unless there is a real operational
  need to expose it behind strong access control.

## 2026-05-03 - Middleware Regression Fix

Date: 2026-05-03 11:16 CEST

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13`

Stack version after: `traefik:3.6.13`

Checks:

- Regression cause identified: OK. Removing the stale dashboard route also
  removed the dummy Traefik service-port label that the Swarm provider was
  relying on to load the Traefik-defined middlewares.
- Service label restored: OK. Re-added
  `traefik.http.services.traefik-lb-dummy.loadbalancer.server.port=8080`
  without restoring the old dashboard router labels.
- Container health checked: OK. `traefik_traefik` remained `1/1`.
- Routed app recovery checked: OK. Local host-header probes for
  `portainer.format.lu`, `bitwarden.format.lu`, and `floc.lu` returned `200`
  after the fix.
- Logs checked: OK. The earlier `middleware ... does not exist` and
  `service \"traefik-traefik\" error: port is missing` errors stopped after the
  label was restored.
- Notes: The dashboard route remains disabled; only the middleware-supporting
  dummy service label was restored.
- Follow-up: When changing self-referential Traefik labels later, keep the
  dummy service label in place unless the middleware definitions are moved to a
  dedicated dynamic config source.

## 2026-05-17 - Traefik Patch Upgrade

Date: 2026-05-17 14:52 CEST

Maintainer: Codex with Peter

Stack version before: `traefik:3.6.13`

Stack version after: `traefik:3.6.17`

Checks:

- Container health checked: OK. `traefik_traefik` returned to `1/1`.
- Running image checked: OK. The live service now runs `traefik:3.6.17`.
- Latest Traefik release checked: OK. Latest `3.6.x` patch observed during this
  run is `v3.6.17`.
- Release notes reviewed: Patch-level update applied within the existing
  `3.6.x` line.
- Provider health checked: OK. Swarm provider remained active on the `proxy`
  network after convergence.
- Network membership checked: OK. Routed services recovered after the restart.
- Ports checked: OK after update. Public `443` traffic resumed normally.
- ACME storage checked: Implicitly OK. Existing certificate storage continued to
  serve HTTPS routes after the restart.
- Log storage checked: OK. Post-update log sampling worked normally.
- Logs reviewed: OK in the final sample. Early replacement-task log lines
  briefly showed missing middleware references while the new task was coming up,
  but no fresh Traefik errors remained in the final post-convergence sample.
- Certificate renewals checked: Not fully revalidated in this run.
- Routed app smoke tests checked: OK. `https://portainer.format.lu/` returned
  the expected Cloudflare Access redirect, `https://bitwarden.format.lu/`
  returned `200`, and `https://floc.lu/` returned `200`.
- Dashboard/API policy checked: OK for current stance. The dashboard remains
  intentionally disabled.
- Update applied: Yes.
- Post-update logs checked: OK. No fresh error lines remained in the final
  `--since 60s` log sample.
- Notes: The first rollout attempt hit the expected single-node Swarm
  `host-mode port already in use` conflict while replacing a service that owns
  `443`. The service then completed with `stop-first` behavior and recovered
  cleanly.
- Follow-up: `com.docker.stack.image` metadata still reports `traefik:3.6.13`
  even though the live service image is `3.6.17`; reconcile that label later if
  metadata cleanliness matters.
