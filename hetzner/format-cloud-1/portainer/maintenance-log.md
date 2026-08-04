# Portainer Maintenance Log

Use this log for Portainer checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record Portainer passwords, API tokens, backup passwords, registry credentials, or other secrets here.

## 2026-08-04 - STS Upgrade

Date: 2026-08-04 17:16 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.43.0`, `portainer/agent:2.43.0`

Stack version after: `portainer/portainer-ce:2.44.0`, `portainer/agent:2.44.0`

Checks:

- Backup checked: OK. Created `/data/backups/portainer/portainer-data-20260804-151452.tar.gz` before the update.
- Portainer server health checked: OK. `portainer_portainer` is `1/1`.
- Portainer agent health checked: OK. `portainer_agent` is `1/1`.
- Running images checked: OK. Server and agent both run `2.44.0`.
- Stack image metadata checked: OK. `com.docker.stack.image` matches `2.44.0` for both server and agent.
- Latest Portainer release checked: OK. `2.44.0 STS` was the latest upstream STS release observed during this run.
- Server logs reviewed: OK. Portainer backed up its database, migrated from `2.43.0` to `2.44.0`, and started cleanly.
- Agent logs reviewed: OK. Agent started on API version `2.44.0`; the known multi-network warning remains unchanged.
- Traefik route checked: OK. Local host-header route for `portainer.format.lu` returned `200`.
- Update applied: Yes.
- Notes: The recurring `encryption key file not present` informational startup lines remain unchanged from previous runs.
- Follow-up: Continue to prefer LTS unless an STS update is deliberately chosen.

## 2026-07-04 - STS Upgrade

Date: 2026-07-04 17:51 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.42.0`, `portainer/agent:2.42.0`

Stack version after: `portainer/portainer-ce:2.43.0`, `portainer/agent:2.43.0`

Checks:

- Backup checked: OK. Created `/data/backups/portainer/portainer-data-20260704-155126.tar.gz` before the update.
- Portainer server health checked: OK. `portainer_portainer` is `1/1`.
- Portainer agent health checked: OK. `portainer_agent` is `1/1`.
- Running images checked: OK. Server and agent both run `2.43.0`.
- Stack image metadata checked: OK. `com.docker.stack.image` matches `2.43.0` for both server and agent.
- Latest Portainer release checked: OK. `2.43.0 STS` and `2.39.4 LTS` were current upstream releases observed during this run.
- Server logs reviewed: OK. Portainer backed up its database, migrated from `2.42.0` to `2.43.0`, and started cleanly.
- Agent logs reviewed: OK. No agent convergence issue observed after update.
- Traefik route checked: OK. Local host-header route for `portainer.format.lu` returned `200`.
- Update applied: Yes.
- Notes: The recurring `encryption key file not present` informational startup lines remain unchanged from previous runs.
- Follow-up: Continue to prefer LTS unless an STS update is deliberately chosen.

## 2026-06-14 - STS Upgrade

Date: 2026-06-14 18:15 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.41.1`, `portainer/agent:2.41.1`

Stack version after: `portainer/portainer-ce:2.42.0`, `portainer/agent:2.42.0`

Checks:

- Backup checked: OK. Created `/data/backups/portainer/portainer-data-20260614-161347.tar.gz` before the update.
- Portainer server health checked: OK. `portainer_portainer` is `1/1`.
- Portainer agent health checked: OK. `portainer_agent` is `1/1`.
- Running images checked: OK. Server and agent both run `2.42.0`.
- Stack image metadata checked: OK. `com.docker.stack.image` now matches `2.42.0` for both server and agent.
- Latest Portainer release checked: OK. `2.42.0 STS` was the latest Portainer release observed during this run.
- Server logs reviewed: OK. Portainer backed up its database, migrated from `2.41.1` to `2.42.0`, and started cleanly.
- Agent logs reviewed: OK. No agent convergence issue observed after update.
- Traefik route checked: OK. Local host-header route for `portainer.format.lu` returned `200`.
- UI checked: OK. Peter confirmed Portainer looked good after the upgrade.
- Update applied: Yes.
- Notes: The recurring `encryption key file not present` informational startup lines remain unchanged from previous runs. Metadata label reconciliation caused a brief recycle after the version update; both services returned to `1/1`.
- Follow-up: Continue to prefer LTS unless an STS update is deliberately chosen.

## 2026-04-18 - Initial Documentation

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.39.1`, `portainer/agent:2.39.1`

Stack version after: `portainer/portainer-ce:2.39.1`, `portainer/agent:2.39.1`

Checks:

- Container health checked: OK. `portainer_portainer` is running `1/1`; `portainer_agent` is running `1/1`.
- Running image checked: OK. Portainer server and agent both run `2.39.1`.
- Latest Portainer release checked: OK. `2.39.1` is the current LTS patch version observed during documentation.
- Release notes reviewed: Portainer `2.39` is an LTS release line; `2.39.1` is the current patch deployed.
- Server logs reviewed: OK. No recent error, warning, auth, database, backup, or update lines found in filtered service logs.
- Agent logs reviewed: OK. No recent error, warning, failure, or panic lines found in filtered service logs.
- Traefik routing checked: Not checked during initial documentation.
- Backup coverage checked: Partial. Portainer data path is `/data/portainer/data`; backup success still needs confirmation through the broader backup/duplicati review.
- Update applied: No.
- Notes: Created this service documentation folder and sanitized live-style stack reference.
- Follow-up: Swarm stack image labels still report `2.33.6` even though the running server and agent images are `2.39.1`; reconcile labels or redeploy the stack from the corrected definition later. Review access policy for `portainer.format.lu` together with broader origin hardening.

## 2026-04-18 - Stack Image Label Cleanup

Date: 2026-04-18

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.39.1`, `portainer/agent:2.39.1`

Stack version after: `portainer/portainer-ce:2.39.1`, `portainer/agent:2.39.1`

Checks:

- Portainer server label checked: OK. `com.docker.stack.image` now matches `portainer/portainer-ce:2.39.1`.
- Portainer agent label checked: OK. `com.docker.stack.image` now matches `portainer/agent:2.39.1`.
- Portainer server health checked: OK. `portainer_portainer` is running `1/1`.
- Portainer agent health checked: OK. `portainer_agent` is running `1/1`.
- Traefik route checked: OK. `https://portainer.format.lu/` returned `302`, which is expected for the Portainer UI redirect.
- Post-change logs checked: OK. No recent filtered error, warning, failure, or panic lines found for server or agent.
- Update applied: No image update. Metadata labels only.
- Notes: The previous stale `2.33.6` stack image label follow-up is resolved.
- Follow-up: Review access policy for `portainer.format.lu` together with broader origin hardening.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.39.1@sha256:1ae8e65d50ca5498cb2c33e617495a1e3ef245b0d2392b4a44c70ae09b822891`, `portainer/agent:2.39.1@sha256:7af856876dcb2778108bf6846f3da31b176443db90e3de31fcfdf17e5ab7857e`

Stack version after: `portainer/portainer-ce:2.39.1@sha256:1ae8e65d50ca5498cb2c33e617495a1e3ef245b0d2392b4a44c70ae09b822891`, `portainer/agent:2.39.1@sha256:7af856876dcb2778108bf6846f3da31b176443db90e3de31fcfdf17e5ab7857e`

Checks:

- Portainer server health checked: OK. `portainer_portainer` is `1/1`.
- Portainer agent health checked: OK. `portainer_agent` is `1/1`.
- Running images checked: OK. Server and agent both match the current
  `2.39.1` digests.
- Latest Portainer release checked: OK. Latest LTS release remains `2.39.1`.
- Release notes reviewed: No newer LTS release was found.
- Server logs reviewed: OK. No recent filtered error or warning lines were
  observed.
- Agent logs reviewed: OK. No recent filtered error or warning lines were
  observed.
- Traefik route checked: OK. `https://portainer.format.lu/` redirects to
  Cloudflare Access.
- UI login checked: Not interactively checked in this run.
- Swarm visibility checked: OK. The host remains a single-node leader and all
  documented services are `1/1`.
- Backup coverage checked: Partial. Portainer data still lives at
  `/data/portainer/data`, but the Duplicati backup job is warning that the live
  `portainer.db` file is locked during backup.
- Latest backup checked: Partial. Duplicati metadata shows the job ran on
  `2026-05-02`, but the locked `portainer.db` warning means the resulting backup
  is not a complete Portainer state capture.
- Update applied: No.
- Post-update logs checked: Not applicable.
- Notes: Portainer itself is healthy; the real maintenance follow-up is the
  backup gap around the live SQLite database.
- Follow-up: Introduce a consistent Portainer backup method that does not rely
  on copying the locked live `portainer.db`, and keep the Access/origin review
  on the broader hardening list.

## 2026-05-03 - Portainer Backup Automation

Date: 2026-05-03 09:16 CEST

Maintainer: Codex with Peter

Checks:

- Backup script created: OK. Added `backup-portainer.sh` to the repo and
  installed it on `format-cloud-1` at `/usr/local/sbin/backup-portainer.sh`.
- Backup flow checked: OK. The script scales `portainer_portainer` to `0`,
  archives `/data/portainer/data`, scales the service back to `1`, and prunes
  local archives older than 7 days.
- Retention checked: OK. Local Portainer backup retention is set to `7` days.
- Cron entry checked: OK. Daily backup is scheduled for `20:10` local time.
- Duplicati pickup path checked: OK. The output archive lives under `/data`, so
  it is included in the normal `/source-data` backup path.
- Notes: This avoids relying on a live copy of the locked `portainer.db`
  SQLite file.
- Follow-up: After the first scheduled run, verify that a fresh archive appears
  under `/data/backups/portainer` and that Duplicati carries it off-host.

## 2026-05-03 - Duplicati Pickup Alignment

Date: 2026-05-03 09:25 CEST

Maintainer: Codex with Peter

Checks:

- Duplicati live-source exclusion checked: OK. The backup job now excludes
  `/source-data/portainer/data/`.
- Archive pickup path checked: OK. Duplicati still includes
  `/source-data/backups/portainer/` through the normal `/source-data` source.
- Warning cleanup follow-up set: OK. The next scheduled backup should verify
  that the old locked `portainer.db` warning is gone.

## 2026-05-03 - Portainer STS Upgrade

Date: 2026-05-03 10:15 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.39.1`, `portainer/agent:2.39.1`

Stack version after: `portainer/portainer-ce:2.41.0`, `portainer/agent:2.41.0`

Checks:

- Pre-update backup checked: OK. Created manual archive
  `/data/backups/portainer/portainer-data-manual-20260503-0815UTC.tar.gz`
  before the image update.
- Portainer server update applied: OK. Updated `portainer_portainer` to
  `portainer/portainer-ce:2.41.0`.
- Portainer agent update applied: OK. Updated `portainer_agent` to
  `portainer/agent:2.41.0`.
- Service convergence checked: OK. Both services returned to `1/1`.
- Route check after update: OK. `https://portainer.format.lu/` remained behind
  Cloudflare and returned a challenge response while the backend stayed up.
- Agent connectivity checked: OK. Agent logs show API server `2.41.0` started
  normally on port `9001`.
- Logs reviewed: OK. Portainer migrated its database from `2.39.1` to `2.41.0`
  and started normally. No trusted-origin or CSRF startup errors were observed.
- Notes: Portainer still logs that `/run/secrets/portainer` is not present and
  proceeds without an encryption key; this is unchanged from before the
  upgrade.
- Follow-up: Do one authenticated UI sanity check for state-changing actions in
  the browser, since `2.41.0 STS` changed CSRF trusted-origin handling.

## 2026-05-03 - Backup Script Filter Fix

Date: 2026-05-03 10:18 CEST

Maintainer: Codex with Peter

Checks:

- Backup helper failure reviewed: OK. The earlier run hung before archiving
  because the service replica check filtered on `name=^portainer_portainer$`.
- Script fix applied: OK. Changed the helper to filter on
  `name=portainer_portainer`, which matches Docker service listings on this
  host.
- Host script sync checked: OK. Reinstalled the corrected helper at
  `/usr/local/sbin/backup-portainer.sh`.
- Follow-up: Let the scheduled `20:10` backup run once and confirm the helper
  now scales down, archives, and scales back up cleanly.

## 2026-05-17 - Portainer Patch Upgrade

Date: 2026-05-17 14:52 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.41.0`, `portainer/agent:2.41.0`

Stack version after: `portainer/portainer-ce:2.41.1`, `portainer/agent:2.41.1`

Checks:

- Pre-update backup checked: OK. Ran `/usr/local/sbin/backup-portainer.sh` and
  created `/data/backups/portainer/portainer-data-20260517-124925.tar.gz`.
- Portainer server health checked: OK. `portainer_portainer` returned to `1/1`.
- Portainer agent health checked: OK. `portainer_agent` returned to `1/1`.
- Running images checked: OK. Server and agent both now run `2.41.1`.
- Latest Portainer release checked: OK. `2.41.1` is the current CE patch
  release observed during this run.
- Release notes reviewed: Patch-level update applied within the existing
  `2.41.x` line.
- Server logs reviewed: OK overall. Portainer migrated the database from
  `2.41.0` to `2.41.1` and started normally.
- Agent logs reviewed: OK. The agent converged cleanly on `2.41.1`.
- Traefik route checked: OK. `https://portainer.format.lu/` redirects to
  Cloudflare Access as expected.
- UI login checked: Not interactively checked in this run.
- Swarm visibility checked: OK. The single-node Swarm remained `Ready` and
  `Leader` throughout the update.
- Backup coverage checked: OK. Portainer data remains under
  `/data/portainer/data` and the local backup archive was created successfully.
- Latest backup checked: OK. Fresh manual backup archive exists from this run.
- Update applied: Yes.
- Post-update logs checked: OK. No fresh startup or migration errors were
  observed after convergence.
- Notes: Portainer still logs that `/run/secrets/portainer` is not present and
  proceeds without an encryption key; this is unchanged from earlier runs.
- Follow-up: Do one authenticated UI sanity check when convenient, mainly for
  environment and stack visibility.

## 2026-05-31 - End-Of-Month Portainer Check

Date: 2026-05-31 08:38 CEST

Maintainer: Codex with Peter

Stack version before: `portainer/portainer-ce:2.41.1`, `portainer/agent:2.41.1`

Stack version after: `portainer/portainer-ce:2.41.1`, `portainer/agent:2.41.1`

Checks:

- Portainer server health checked: OK. `portainer_portainer` converged to `1/1`.
- Portainer agent health checked: OK. `portainer_agent` converged to `1/1`.
- Running images checked: OK. Server and agent both run `2.41.1`.
- Latest Portainer release checked: OK. Upstream now offers newer releases, including `2.42.0 STS`, but no version jump was applied in this run.
- Release notes reviewed: No action taken; this pass stayed on the pinned `2.41.1` line.
- Server logs reviewed: OK. Portainer started cleanly on `2.41.1`; the familiar "no encryption key file present" message remains unchanged.
- Agent logs reviewed: OK. Agent started cleanly on `2.41.1`; the existing warning about the agent being attached to more than one overlay network remains unchanged.
- Traefik route checked: OK. `https://portainer.format.lu/` returned the expected Cloudflare Access `403` challenge response from the unauthenticated check path.
- UI login checked: Not interactively checked in this run.
- Swarm visibility checked: OK. The single-node Swarm remained `Ready` and `Leader`.
- Backup coverage checked: OK. Portainer data remains under `/data/portainer/data`.
- Latest backup checked: OK. Recent archives were present, including `portainer-data-20260530-201002.tar.gz`.
- Update applied: No.
- Post-update logs checked: Not applicable.
- Notes: During the sweep, `docker service ps` briefly showed fresh task history while the current `2.41.1` tasks settled, but the services ended in the expected `1/1` healthy state.
- Follow-up: do one authenticated UI sanity check when convenient, mainly for environment and stack visibility.

## Maintenance Template

Date:

Maintainer:

Stack version before:

Stack version after:

Checks:

- Portainer server health checked:
- Portainer agent health checked:
- Running images checked:
- Latest Portainer release checked:
- Release notes reviewed:
- Server logs reviewed:
- Agent logs reviewed:
- Traefik route checked:
- UI login checked:
- Swarm visibility checked:
- Backup coverage checked:
- Latest backup checked:
- Update applied:
- Post-update logs checked:
- Notes:
- Follow-up:
