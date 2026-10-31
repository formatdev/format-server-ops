# Format Wazuh Host Runbook

Runbook for maintaining the Hetzner VPS that hosts Wazuh for the Format
environment.

Last updated: 2026-10-31

## Current Verified State

Last verified: 2026-10-31. See
[maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/maintenance-log.md)
for the inspection details.

- Hostname: `format-wazuh`
- Working SSH alias on this workstation: `format-wazuh`
- Alternate legacy SSH alias on this workstation: `hetzner-wazuh`
- Public IPv4: `116.203.114.188`
- Public IPv6: `2a01:4f8:1c1c:9a62::1/64`
- OS: Ubuntu 24.04.5 LTS
- Running kernel: `6.8.0-147-generic`
- Primary workload: Wazuh 4.14.9, package/systemd deployment
- Active services: `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`,
  `filebeat`
- Recommended agent endpoint: `wazuh-agent.format.lu`
- Docker/Compose/Swarm: not installed/detected
- Portainer: not present by current deployment evidence
- Wazuh indexer data: `/var/lib/wazuh-indexer`, bind-mounted from
  `/mnt/HC_Volume_104575658/wazuh-indexer`
- Reboot state: reboot completed on 2026-10-31; no reboot marker remains
- Remaining apt upgrades as of 2026-10-31: none
- Public ingress: dashboard 443/tcp, agent events 1514/tcp, rate-limited SSH
  22/tcp. Enrollment 1515/tcp is blocked by UFW on IPv4 and IPv6.
- Enrollment defense in depth: password required, automatic duplicate-agent
  replacement disabled, enrollment TLS certificate renewed through 2027-10-31.
- Security case closed at Peter's request on 2026-10-31: unrecognized agent
  `045 poc-f9b33373` key revoked, source `46.55.225.40` blocked, enrollment
  hardened and evidence retained. Closure is not forensic clearance; see the
  security review for scope and limitations.
- Searchable alert retention: 90 days through ISM policy
  `wazuh-alert-retention-90d`
- Local rotated alert retention: 30 days through
  `wazuh-local-alert-retention.timer`
- Internal Wazuh log retention: 31 days through the existing
  `monitord.keep_log_days` setting
- Storage after 2026-10-31 maintenance: root 58% used and indexer data
  volume 43% used
- Full valid agent inventory: 16 remote agents active, 19 disconnected, none
  never connected; local manager active. `021 NUC-MTX3` is active again.
- Agent state: canonical Mac agent `043 MBP-PCZ` active after starting its
  stopped local 4.14.8 processes on 2026-10-31. Server route uses en0.
  The persistent VPN route exception is documented in the August 23 log;
  VPN reconnect behavior was not retested this round.
- Configuration recovery copy: root-only
  `/root/wazuh-maintenance-20261031-8Iy6j8/config-before.tgz`; this is not an
  index-data backup. The same directory holds registration/log evidence.
  Historical archive remains at
  `/root/wazuh-backup-2025-08-03.tar.gz`.

## Host Files

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/maintenance-log.md): host-level maintenance history
- [new-thread-prompt.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/new-thread-prompt.md): prompt for opening a dedicated maintenance thread
- [retention/README.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/retention/README.md): tracked index and local alert retention configuration
- [security-review-2026-10-31.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/security-review-2026-10-31.md): unrecognized enrollment, investigation, containment and verified hardening

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

Public agent enrollment is closed following the October 31 security finding.
Existing agents use their current keys over TCP 1514. Authd now requires a
256-bit random password stored only in `/var/ossec/etc/authd.pass`
(`0640 root:wazuh`), and `<auth><force><enabled>no</enabled></force></auth>`
prevents automatic replacement of an existing registration. Do not restore a
general public 1515 allow rule.

### New Agent Registration

SSH forwarding is disabled (`AllowTcpForwarding no`); a local SSH tunnel was
tested and rejected. Preserve this restriction. Register new agents through
authenticated SSH administration without opening 1515:

1. Verify the endpoint owner and intended unique agent name. Inspect the
   existing roster with `/var/ossec/bin/manage_agents -l` on the manager.
   A renamed or temporarily disconnected endpoint normally keeps its key;
   do not automatically delete or replace its registration.
2. From `ssh format-wazuh`, use `/var/ossec/bin/manage_agents` interactively
   to add the approved endpoint and extract only its new client key.
3. Transfer the extracted key through a protected, authenticated admin channel.
   On the endpoint, stop the agent and import it using the interactive
   `manage_agents` tool. Keep the key out of shell command arguments, shell
   history, chat transcripts and this repository. On macOS the tool is
   `/Library/Ossec/bin/manage_agents`; on Linux, `/var/ossec/bin/manage_agents`.
4. Set the agent's event server to `wazuh-agent.format.lu`, TCP 1514, and
   start the agent. Confirm its expected name/ID is Active on the manager
   and that current events are arriving. Do not re-enroll a healthy agent.

The enrollment password is defense in depth for the blocked TLS listener,
not a requirement for existing 1514 sessions or manually imported client keys.
Any future network-enrollment exception needs a separate scoped plan, source
restriction, password/certificate validation, and removal of the temporary rule.
The self-signed enrollment certificate is not publicly CA-trusted. It was
validated against its exact certificate and DNS name during the local tests;
future network clients must use a securely distributed trust anchor too.
Renew it before **2027-10-31 13:59:33 UTC**. Dashboard/indexer certificates were
not replaced.

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
