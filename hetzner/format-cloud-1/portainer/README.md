# Portainer On format-cloud-1

This folder documents the Portainer services hosted on the Hetzner server `hetzner-cloud-1`.

Portainer is the control plane for this Docker Swarm environment. Treat updates carefully because a broken Portainer deployment can make future stack management harder, even if running containers continue working.

## Live Services

- server: `hetzner-cloud-1`
- stack namespace: `portainer`
- Portainer service: `portainer_portainer`
- Agent service: `portainer_agent`
- Portainer image: `portainer/portainer-ce:2.45.0`
- Agent image: `portainer/agent:2.45.0`
- live replica state during documentation: `1/1` for both services
- public hostname in labels: `portainer.format.lu`
- reverse proxy: Traefik on external Docker network `proxy`
- Portainer backend port for Traefik: `9000`
- Portainer data path: `/data/portainer/data:/data`
- Portainer connects to the agent with `-H tcp://tasks.agent:9001 --tlsskipverify`
- Agent mounts Docker socket and Docker volumes:
  - `/var/run/docker.sock:/var/run/docker.sock`
  - `/var/lib/docker/volumes:/var/lib/docker/volumes`

## Current Decisions

- Pin Portainer and Portainer Agent image versions instead of using `latest`.
- Keep Portainer server and agent on the same version.
- Prefer LTS releases for this production management UI unless there is a
  specific reason to take the STS line.
- Confirm backup status before any Portainer update.
- Update Portainer deliberately through Portainer or Swarm, not blindly.
- Treat the Portainer data directory as critical state.
- Avoid exposing Portainer directly without Traefik, TLS, and access controls.

## Known Issues

- Portainer is reachable through Traefik at `portainer.format.lu`; access
  policy should be reviewed later together with the broader Hetzner
  origin-hardening work.
- Portainer `2.41.x STS` changes CSRF trusted-origin handling. If a future
  upgrade fails with trusted-origin or CSRF errors, review the configured
  origins and use full URLs including scheme.

## Update Policy

Before updating:

1. Confirm Portainer data is backed up.
2. Check Portainer release notes.
3. Confirm the target version is appropriate for CE and preferably LTS.
4. Update `portainer_portainer` and `portainer_agent` together.
5. Watch service convergence.
6. Test the Portainer UI and agent connectivity immediately after the update.
7. For `2.41.x`, verify that any trusted-origin settings use full URLs.

## Maintenance Cadence

Run Portainer checks as part of the combined Hetzner platform maintenance run on the 15th and the last day of each month when requested.

Use this checklist:

1. Confirm `portainer_portainer` is running `1/1`.
2. Confirm `portainer_agent` is running `1/1`.
3. Confirm both services use the same image version.
4. Check the latest Portainer CE release and release notes.
5. Review Portainer server logs for auth, database, backup, API, and update errors.
6. Review Portainer agent logs for socket, environment, and connectivity errors.
7. Confirm Traefik route for `portainer.format.lu` returns a healthy status.
8. Confirm Portainer can see the local Swarm environment.
9. Confirm `/data/portainer/data` is included in backups.
10. Confirm a recent backup exists before any update.
11. If an update is applied, redeploy server and agent together.
12. After an update, test UI login and stack/service visibility.
13. Record the result in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/portainer/maintenance-log.md).

## Backup Automation

Portainer uses SQLite state under:

```text
/data/portainer/data
```

Because `portainer.db` is live and frequently locked while Portainer is
running, the reliable backup flow is:

1. Scale `portainer_portainer` to `0`
2. Archive `/data/portainer/data`
3. Scale `portainer_portainer` back to `1`
4. Keep only the most recent 7 days of local archives

Reference script in this repo:

```text
/Users/czibulapeter/Documents/GitHub/format-server-ops/scripts/backup-portainer.sh
```

Recommended host install path:

```text
/usr/local/sbin/backup-portainer.sh
```

Recommended host cron entry:

```cron
10 20 * * * /usr/local/sbin/backup-portainer.sh >> /data/backups/portainer/backup-portainer.log 2>&1
```

Expected archive output:

```text
/data/backups/portainer/portainer-data-YYYYMMDD-HHMMSS.tar.gz
```

Local archive retention:

```text
7 days
```

These archives live under `/data`, so Duplicati can ship them off-host during
its normal backup run.

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/portainer/stack.example.yml): sanitized live-style Portainer stack reference
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/portainer/maintenance-log.md): ongoing maintenance history
