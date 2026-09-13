# ESST Cloud X Runbook

Runbook root for the four servers.com VPS hosts in Luxembourg.

Last updated: 2026-09-13

## Fleet

| Host | Public IP | Local IP | Plan | Provider key label | Status |
| --- | --- | --- | --- | --- | --- |
| `esst-cloud-1` | `188.42.62.40` | `192.168.0.101` | `SSD.120` | `key_2024-07-29_17-19-51` | Active |
| `esst-cloud-2` | `188.42.62.39` | `192.168.0.5` | `SSD.180` | `key_2021-12-08_15-13-01` | Active |
| `esst-cloud-3` | `188.42.62.60` | `192.168.0.20` | `SSD.80` | `key_2023-03-09_09-43-44` | Active |
| `esst-cloud-4` | `172.255.248.244` | `192.168.0.14` | `SSD.100` | `key_2023-03-29_08-26-13` | Active |

## Host Folders

- [esst-cloud-1](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-1/README.md)
- [esst-cloud-2](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-2/README.md)
- [esst-cloud-3](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-3/README.md)
- [esst-cloud-4](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-4/README.md)
- [swarm-analysis-2026-04-19.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/swarm-analysis-2026-04-19.md): first-pass Swarm and Portainer topology analysis

## Access

Local SSH aliases have been prepared:

```sh
ssh esst-cloud-1
ssh esst-cloud-2
ssh esst-cloud-3
ssh esst-cloud-4
```

Local key files:

```text
~/.ssh/esst-cloud-1
~/.ssh/esst-cloud-2
~/.ssh/esst-cloud-3
~/.ssh/esst-cloud-4
```

The servers use `cloud-user` for SSH access. On September 13, 2026, fresh SSH
connections worked to all four hosts from the office egress IP `217.31.68.238`.
The custom iptables rules restrict SSH by source IP, including private-network
SSH. Cloud-2 and cloud-3 have additional existing exceptions.

See [Firewall Maintenance](firewall-maintenance.md) for the exact policy and
the mandatory checks after every reboot or Docker restart. An inactive UFW
does not establish whether these custom iptables rules are present.

## Baseline Maintenance Flow

For each host:

```sh
ssh esst-cloud-1
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

Package maintenance:

```sh
apt update
apt list --upgradable
apt upgrade
test -f /var/run/reboot-required && cat /var/run/reboot-required
test -f /var/run/reboot-required.pkgs && cat /var/run/reboot-required.pkgs
```

## Required Post-Restart Firewall Check

Maintenance is not complete until the custom firewall rules have been verified
and, when missing, restored:

- All four hosts: `/opt/esst/deployment/iptables-general.sh`.
- Traefik host only (currently cloud-4): also
  `/opt/esst/deployment/iptables-cloudflare.sh`, after Docker is running.
- Confirm the current SSH source is allowed, snapshot the rules and prepare
  timed rollback before applying them. Keep the existing session open and test
  a fresh SSH connection before canceling rollback.
- Verify the rule chains and hooks, all Swarm nodes/services, permitted office
  SSH, blocked non-allowed SSH, Cloudflare access and blocked direct-origin HTTPS.
- Record evidence in the host maintenance log. Check published Docker ports
  separately; these scripts do not impose a blanket office-only firewall.

No automatic boot restoration was found or installed as of September 13, 2026.
Follow the [firewall runbook](firewall-maintenance.md) after every restart.

## Safety Rules

- Treat all four hosts as production until their role is confirmed.
- Do not delete Docker volumes, bind mounts, application data, databases, or
  firewall rules without first recording current state.
- Keep at least one working SSH path before changing `sshd_config`.
- Do not commit private keys, provider tokens, server passwords, or Bitwarden
  secure note contents into this repository.
- Record host-level work in the matching `maintenance-log.md`.
