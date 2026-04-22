# Portainer Maintenance Log

Use this log for Portainer checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record Portainer passwords, API tokens, backup passwords, registry credentials, or other secrets here.

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
