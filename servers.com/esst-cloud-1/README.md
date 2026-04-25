# esst-cloud-1 Runbook

Host-level runbook for `esst-cloud-1`.

Last updated: 2026-04-19

## Host Facts

- Provider: servers.com
- Location: Luxembourg
- SSH alias: `esst-cloud-1`
- SSH user: `cloud-user`
- Public IP: `188.42.62.40`
- Local IP: `192.168.0.101`
- Plan: `SSD.120`
- Provider key label: `key_2024-07-29_17-19-51`
- Status: Active
- OS: Ubuntu 24.04.3 LTS
- Kernel verified: `6.8.0-110-generic`
- Docker Engine verified: `29.1.3`
- Docker Swarm role: worker
- Firewall verified: `ufw` inactive

## Access

```sh
ssh esst-cloud-1
```

Local key:

```text
~/.ssh/esst-cloud-1
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

## Logs

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-1/maintenance-log.md)

## Services

- [duplicati](</Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-1/duplicati>)
- [glitchtip](</Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-1/glitchtip>)
