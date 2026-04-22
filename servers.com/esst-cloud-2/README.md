# esst-cloud-2 Runbook

Host-level runbook for `esst-cloud-2`.

Last updated: 2026-04-19

## Host Facts

- Provider: servers.com
- Location: Luxembourg
- SSH alias: `esst-cloud-2`
- SSH user: `cloud-user`
- Public IP: `188.42.62.39`
- Local IP: `192.168.0.5`
- Plan: `SSD.180`
- Provider key label: `key_2021-12-08_15-13-01`
- Status: Active

## Access

```sh
ssh esst-cloud-2
```

Local key:

```text
~/.ssh/esst-cloud-2
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

- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x/esst-cloud-2/maintenance-log.md)
