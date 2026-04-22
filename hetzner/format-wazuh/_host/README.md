# Format Wazuh Host Runbook

Runbook for maintaining the Hetzner VPS that hosts Wazuh for the Format
environment.

Last updated: 2026-04-18

## Current Verified State

Last verified: 2026-04-18. See
[maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/maintenance-log.md)
for the inspection details.

- Hostname: `format-wazuh`
- Working SSH alias on this workstation: `format-wazuh`
- Alternate legacy SSH alias on this workstation: `hetzner-wazuh`
- Public IPv4: `116.203.114.188`
- Public IPv6: `2a01:4f8:1c1c:9a62::1/64`
- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Primary workload: Wazuh 4.14.4, package/systemd deployment
- Active services: `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`,
  `filebeat`
- Docker/Compose/Swarm: not installed/detected
- Portainer: not present by current deployment evidence
- Wazuh indexer data: `/var/lib/wazuh-indexer`, bind-mounted from
  `/mnt/HC_Volume_104575658/wazuh-indexer`
- Reboot state: no reboot required after 2026-04-18 maintenance
- Remaining apt upgrades: `snapd` deferred by Ubuntu phased updates as of
  2026-04-18

## Host Files

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/maintenance-log.md): host-level maintenance history
- [new-thread-prompt.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/new-thread-prompt.md): prompt for opening a dedicated maintenance thread

## Safety Rules

- Treat this host as production security infrastructure.
- Do not remove Wazuh indices, volumes, certificates, or configuration without a
  verified backup and explicit confirmation.
- Do not assume Portainer, Docker Swarm, or a specific compose layout exists.
- Before package upgrades, verify whether Wazuh components are managed by Docker,
  Docker Compose, systemd packages, or another supervisor.
- Avoid broad prune commands on Docker hosts unless every volume and image has
  been reviewed.
- Reboots may interrupt alert ingestion, dashboards, API access, and agent
  connectivity.

## Access

Try the currently working local SSH alias:

```sh
ssh format-wazuh
```

The older local alias also points at the same host:

```sh
ssh hetzner-wazuh
```

If the alias is missing or points to the wrong host, inspect local SSH config
before guessing:

```sh
grep -n "format-wazuh\|wazuh" ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null
```

Confirm the expected host before making changes:

```sh
hostnamectl
ip -brief address
uptime
who
```

Record the verified hostname, public IP, OS, kernel, and Wazuh deployment model
in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/maintenance-log.md).

## Baseline Health Check

Run these checks before and after maintenance:

```sh
uptime
free -h
df -h /
findmnt -D
systemctl --failed --no-pager
journalctl -p warning..alert --since "1 hour ago" --no-pager
```

Check pending updates and reboot state:

```sh
apt update
apt list --upgradable
test -f /var/run/reboot-required && cat /var/run/reboot-required || echo "no reboot required"
test -f /var/run/reboot-required.pkgs && cat /var/run/reboot-required.pkgs || true
```

## Deployment Discovery

First identify how Wazuh is installed.

Check for Docker:

```sh
docker version
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
docker compose version
docker compose ls
docker stack ls
```

Check for systemd-managed Wazuh services:

```sh
systemctl list-units --type=service --all | grep -Ei 'wazuh|indexer|dashboard|filebeat|opensearch|elastic'
systemctl status wazuh-manager --no-pager
systemctl status wazuh-indexer --no-pager
systemctl status wazuh-dashboard --no-pager
```

Check common Wazuh paths:

```sh
ls -la /var/ossec 2>/dev/null
ls -la /etc/wazuh* /usr/share/wazuh* /var/lib/wazuh* 2>/dev/null
find /opt /srv /data -maxdepth 3 -iname '*wazuh*' -print 2>/dev/null
```

## Wazuh Health Check

Use the checks that match the actual deployment model.

For package or systemd deployments:

```sh
systemctl is-active wazuh-manager wazuh-indexer wazuh-dashboard 2>/dev/null || true
journalctl -u wazuh-manager --since "30 minutes ago" --no-pager
journalctl -u wazuh-indexer --since "30 minutes ago" --no-pager
journalctl -u wazuh-dashboard --since "30 minutes ago" --no-pager
```

For Docker or Compose deployments:

```sh
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | grep -Ei 'wazuh|indexer|dashboard|filebeat|opensearch'
docker compose ls
docker compose ps
docker logs --since 30m --tail 200 "$(docker ps --format '{{.Names}}' | grep -Ei 'wazuh.*manager|wazuh-manager' | head -1)"
```

Check Wazuh API and dashboard if exposed locally:

```sh
curl -k -I --max-time 10 https://127.0.0.1
curl -k --max-time 10 https://127.0.0.1:55000/
```

Check agent connectivity on the manager:

```sh
/var/ossec/bin/agent_control -lc 2>/dev/null || true
/var/ossec/bin/wazuh-control status 2>/dev/null || true
```

## Security Baseline

The host should keep these properties:

- SSH is key-only.
- Root login is allowed only with SSH keys, or disabled if a sudo user exists.
- `ufw` or another firewall is active.
- `fail2ban` or equivalent SSH protection is active.
- Wazuh ports are exposed only as intentionally required.
- Dashboard/API access is restricted by firewall, VPN, tunnel, or strong
  authentication.

Verify SSH daemon settings:

```sh
sshd -T | grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|maxauthtries|logingracetime) '
```

Verify firewall and listening ports:

```sh
ss -tulpn
ufw status verbose
systemctl status fail2ban --no-pager
fail2ban-client status sshd 2>/dev/null || true
```

Common Wazuh-related ports to review:

- `1514/tcp` and `1514/udp`: agent event ingestion
- `1515/tcp`: agent enrollment
- `55000/tcp`: Wazuh API
- `9200/tcp`: indexer or OpenSearch API
- `5601/tcp` or `443/tcp`: dashboard, depending on deployment

## Package Updates

Before upgrading, confirm the Wazuh deployment model and current health.

Standard update flow:

```sh
apt update
apt list --upgradable
apt upgrade
```

After updates:

```sh
systemctl --failed --no-pager
test -f /var/run/reboot-required && cat /var/run/reboot-required || echo "no reboot required"
test -f /var/run/reboot-required.pkgs && cat /var/run/reboot-required.pkgs || true
```

If Docker is present:

```sh
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
docker system df
```

If Wazuh is package-managed:

```sh
systemctl is-active wazuh-manager wazuh-indexer wazuh-dashboard 2>/dev/null || true
```

## Backup Checks

Before Wazuh upgrades or cleanup, identify and verify backups for:

- Wazuh manager configuration
- Wazuh indexer data
- Wazuh dashboard configuration
- Certificates and keys
- Agent enrollment keys and API credentials
- Docker volumes or bind mounts, if used

Discovery commands:

```sh
du -h -d 1 /var/ossec /var/lib /opt /srv /data 2>/dev/null | sort -h
docker volume ls 2>/dev/null | grep -Ei 'wazuh|indexer|dashboard|opensearch' || true
docker inspect $(docker ps -q) 2>/dev/null | grep -Ei 'wazuh|indexer|dashboard|opensearch|Source|Destination' || true
```

Do not delete old Wazuh data until the current live data path and backup status
are both confirmed.

## Disk And Docker Reclaim Checks

Inspect disk usage:

```sh
df -h /
du -h -d 1 /var /opt /srv /data 2>/dev/null | sort -h
docker system df 2>/dev/null || true
```

Only review reclaimable Docker data after confirming Wazuh volumes:

```sh
docker system df -v
docker image prune
```

Avoid `docker volume prune` on Wazuh hosts unless every volume is mapped and
known to be disposable.

## Troubleshooting

If Wazuh agents stop reporting:

```sh
ss -tulpn | grep -E ':1514|:1515|:55000'
journalctl -u wazuh-manager --since "1 hour ago" --no-pager
/var/ossec/bin/agent_control -lc 2>/dev/null || true
```

If the dashboard is down:

```sh
systemctl status wazuh-dashboard --no-pager
journalctl -u wazuh-dashboard --since "1 hour ago" --no-pager
curl -k -I --max-time 10 https://127.0.0.1
```

If the indexer is unhealthy:

```sh
systemctl status wazuh-indexer --no-pager
journalctl -u wazuh-indexer --since "1 hour ago" --no-pager
curl -k --max-time 10 https://127.0.0.1:9200/_cluster/health?pretty
```

If Docker is unhealthy:

```sh
systemctl status docker containerd --no-pager
journalctl -u docker --since "1 hour ago" --no-pager
docker ps -a
```
