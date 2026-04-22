# ESST Cloud X Runbook

Runbook root for the four servers.com VPS hosts in Luxembourg.

Last updated: 2026-04-19

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

The initial servers.com images use `cloud-user` for SSH access. Direct public
SSH currently works for `esst-cloud-1`; `esst-cloud-2`, `esst-cloud-3`, and
`esst-cloud-4` time out on TCP/22 from this workstation and from
`esst-cloud-1` over the private network.

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

## Safety Rules

- Treat all four hosts as production until their role is confirmed.
- Do not delete Docker volumes, bind mounts, application data, databases, or
  firewall rules without first recording current state.
- Keep at least one working SSH path before changing `sshd_config`.
- Do not commit private keys, provider tokens, server passwords, or Bitwarden
  secure note contents into this repository.
- Record host-level work in the matching `maintenance-log.md`.
