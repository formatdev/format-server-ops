# Format Cloud 1 Host Runbook

Runbook for maintaining the Hetzner VPS that hosts the Portainer-managed Docker
Swarm environment.

Last verified: 2026-04-18

## Host Facts

- SSH alias: `hetzner-cloud-1`
- Hostname: `format-cloud-1`
- Public IP: `188.245.43.92`
- OS: Ubuntu 24.04 LTS
- Docker mode: single-node Docker Swarm
- Primary public entrypoint: Traefik on HTTPS
- Portainer stack: `portainer`
- Portainer target version: `2.39.1 LTS`

## Host Files

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/_host/maintenance-log.md): host-level maintenance history

## Safety Rules

- Treat this host as production.
- Do not run destructive Docker or filesystem cleanup commands without first
  identifying the exact stack, services, volumes, and bind mounts involved.
- Before editing Portainer metadata directly, stop the Portainer service and
  create a database backup.
- Prefer host firewall and Hetzner firewall restrictions for Docker Swarm ports.
- Keep SSH key-based access working before changing SSH configuration.
- This is a single-node Swarm host, so host reboots and Docker daemon restarts
  cause a short service interruption.

## Access

Connect with:

```sh
ssh hetzner-cloud-1
```

Confirm the expected host before making changes:

```sh
hostnamectl
ip -brief address
docker node ls
```

Expected Swarm shape:

- One node
- Node is both manager and worker
- Node availability is `Active`
- Node manager status is `Leader`

## Baseline Health Check

Run these checks before and after maintenance:

```sh
uptime
free -h
df -h /
systemctl --failed
docker node ls
docker stack ls
docker service ls
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
```

Check Portainer specifically:

```sh
docker service ls --filter name=portainer
docker service ps portainer_portainer --no-trunc
docker service ps portainer_agent --no-trunc
docker service logs --tail 100 portainer_portainer
docker service logs --tail 100 portainer_agent
```

## Security Baseline

The host should keep these properties:

- SSH is key-only.
- Root login is allowed only with SSH keys.
- `ufw` is enabled.
- `fail2ban` is enabled for `sshd`.
- Public inbound ports are limited to SSH and HTTPS.
- Docker Swarm control-plane ports are not publicly reachable.

Verify SSH daemon settings:

```sh
sshd -T | grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|maxauthtries|logingracetime) '
```

Expected important values:

```text
permitrootlogin without-password
passwordauthentication no
pubkeyauthentication yes
kbdinteractiveauthentication no
maxauthtries 3
logingracetime 30
```

Verify firewall and fail2ban:

```sh
ufw status verbose
systemctl status fail2ban --no-pager
fail2ban-client status sshd
```

Expected inbound firewall intent:

- Allow `22/tcp`
- Allow `443/tcp`
- Allow `443/udp`
- Deny other inbound traffic by default

## Package Updates

Check for pending updates:

```sh
apt update
apt list --upgradable
```

Apply standard updates:

```sh
apt upgrade
```

After updates, check whether a reboot is required:

```sh
test -f /var/run/reboot-required && cat /var/run/reboot-required
test -f /var/run/reboot-required.pkgs && cat /var/run/reboot-required.pkgs
```

If a reboot is required, expect a brief outage. After reboot, rerun the baseline
health check and confirm the running kernel:

```sh
uname -r
```

## Portainer Backup

Portainer data is stored on the host at:

```text
/data/portainer/data
```

Create a consistent backup by briefly stopping only the Portainer UI service:

```sh
BACKUP_TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/data/portainer/data/backups"
BACKUP_FILE="${BACKUP_DIR}/portainer-data-${BACKUP_TS}.tar.gz"

mkdir -p "$BACKUP_DIR"
docker service scale portainer_portainer=0
tar -C /data/portainer -czf "$BACKUP_FILE" data
docker service scale portainer_portainer=1
docker service ls --filter name=portainer
```

Download the backup from your workstation:

```sh
scp "hetzner-cloud-1:/data/portainer/data/backups/portainer-data-*.tar.gz" ~/Downloads/
```

## Portainer Upgrade

Recommended production track: Portainer LTS.

Before upgrading:

```sh
docker service ls --filter name=portainer
docker service ps portainer_portainer --no-trunc
docker service ps portainer_agent --no-trunc
```

Back up Portainer data first, then update server and agent to the same version.

Example:

```sh
VERSION="2.39.1"

docker pull "portainer/portainer-ce:${VERSION}"
docker pull "portainer/agent:${VERSION}"

docker service update --image "portainer/portainer-ce:${VERSION}" --detach=false portainer_portainer
docker service update --image "portainer/agent:${VERSION}" --detach=false portainer_agent
```

Verify:

```sh
docker service ls --filter name=portainer
docker service logs --tail 150 portainer_portainer
docker service logs --tail 150 portainer_agent
```

## Stack Cleanup

Use this flow when a stack has moved away from this host or is no longer needed.

Identify live Docker objects:

```sh
STACK="example-stack"

docker stack services "$STACK"
docker stack ps "$STACK"
docker ps -a --filter "label=com.docker.stack.namespace=${STACK}"
docker volume ls --filter "label=com.docker.stack.namespace=${STACK}"
```

Find bind mounts and compose data before deleting anything:

```sh
docker service inspect $(docker stack services -q "$STACK") \
  --format '{{json .Spec.TaskTemplate.ContainerSpec.Mounts}}'
```

Common host data roots:

```text
/data/files
/data/portainer/data/compose
```

Remove only after confirming the stack is no longer running and no other stack
references the same paths.

## Known Cleanup History

Wazuh was moved to another VPS and removed from this host. Removed leftovers:

- `/data/files/wazuh`
- `/data/portainer/data/compose/21`
- `wazuh_wazuh-dashboard-config`
- `wazuh_wazuh-dashboard-custom`

A Portainer database backup was created before removing the stale metadata.

## Disk And Docker Reclaim Checks

Inspect disk usage:

```sh
df -h /
du -h -d 1 /data 2>/dev/null | sort -h
du -h -d 1 /data/files 2>/dev/null | sort -h
docker system df
```

Only prune after reviewing what will be removed:

```sh
docker system df -v
docker image prune
docker volume prune
```

Avoid broad prune commands unless the impact is clear.

## Troubleshooting

If Portainer dashboard counts and list pages disagree:

- Clear any active UI filters first.
- Hard refresh the browser.
- Confirm the stack exists in Docker with `docker stack ls`.
- Confirm Portainer services are healthy.
- Review Portainer logs for migration or database errors.

If HTTPS sites are down:

```sh
docker service ls
docker service ps traefik_traefik --no-trunc
docker service logs --tail 150 traefik_traefik
curl -I https://floc.lu
```

If SSH is noisy or under attack:

```sh
journalctl -u ssh --since "1 hour ago"
fail2ban-client status sshd
```

If Docker Swarm looks unhealthy:

```sh
docker info
docker node ls
docker service ls
journalctl -u docker --since "1 hour ago"
```
