# esst-cloud-4 Runbook

Host-level runbook for `esst-cloud-4`.

Last updated: 2026-04-22

## Host Facts

- Provider: servers.com
- Location: Luxembourg
- SSH alias: `esst-cloud-4`
- SSH user: `cloud-user`
- Public IP: `172.255.248.244`
- Local IP: `192.168.0.14`
- Plan: `SSD.100`
- Provider key label: `key_2023-03-29_08-26-13`
- Status: Active

## Access

```sh
ssh esst-cloud-4
```

Local key:

```text
~/.ssh/esst-cloud-4
```

## Baseline Check

```sh
hostnamectl
ip -brief address
uptime
free -h
df -h
systemctl --failed
sshd -T | grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|maxauthtries|logingracetime) '
```

If Docker is present:

```sh
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
docker compose ls
docker system df
```

## Portainer

`esst-cloud-4` runs the Portainer server task for the Swarm.

Current observed Portainer services after the 2026-04-22 repair:

```text
portainer_portainer   portainer/portainer-ee:2.39.1
portainer_agent       portainer/agent:2.39.1
```

Portainer data is mounted from:

```text
/opt/esst/deployment/portainer/data
```

Before Portainer maintenance, create a host-side backup of this directory. A
known-good pre-agent-update backup exists at:

```text
/opt/esst/deployment/portainer/backups/portainer-data-before-agent-2391-20260422T191029Z.tar.gz
```

Upgrade rule:

- Keep `portainer_portainer` and `portainer_agent` on the same Portainer
  version.
- Update the agent service deliberately after server updates, then verify
  `portainer_agent` is `4/4` and Portainer can still load the Swarm
  Environment and Stack menus.
- Watch for these errors after any Portainer or Docker update:
  - `The agent was unable to contact any other agent located on a manager node`
  - `unable to redirect request to a manager node: no manager node found`

Useful checks:

```sh
docker service ls --filter name=portainer
docker service ps portainer_portainer --no-trunc
docker service ps portainer_agent --no-trunc
docker service logs --tail 150 portainer_portainer
docker service logs --tail 150 portainer_agent
```

## Docker Maintenance Note

On 2026-04-22, the host was observed running Docker Engine `29.4.1`.
Portainer's published tested matrix for Business `2.39.1 LTS` lists Docker
Engine `28.5.1` and `29.2.1`.

Do not change Docker Engine casually while Portainer is the practical Swarm
control plane. Treat Docker upgrades, downgrades, package holds, or daemon
configuration changes as a larger maintenance-window task.

Before a Docker maintenance window:

- Confirm Portainer server and agent are healthy and version-aligned.
- Export or otherwise preserve Portainer-managed stack definitions.
- Back up `/opt/esst/deployment/portainer/data`.
- Record `docker node ls`, `docker service ls`, and `docker network ls`.
- Review Docker Engine release notes and Portainer's current compatibility
  matrix.
- Decide whether the goal is to hold the current Docker version, move to a
  tested version, or upgrade Portainer first.
- Plan rollback before changing packages on any Swarm node.

## Logs

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-4/maintenance-log.md)
