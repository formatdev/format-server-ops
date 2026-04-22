# esst-cloud-3 Runbook

Host-level runbook for `esst-cloud-3`.

Last updated: 2026-04-19

## Host Facts

- Provider: servers.com
- Location: Luxembourg
- SSH alias: `esst-cloud-3`
- SSH user: `cloud-user`
- Public IP: `188.42.62.60`
- Local IP: `192.168.0.20`
- Plan: `SSD.80`
- Provider key label: `key_2023-03-09_09-43-44`
- Status: Active

## Access

```sh
ssh esst-cloud-3
```

Local key:

```text
~/.ssh/esst-cloud-3
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

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-3/maintenance-log.md)
