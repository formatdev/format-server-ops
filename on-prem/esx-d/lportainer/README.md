# LPORTAINER Runbook

Starter runbook for the `Lportainer` VM on ESX-D.

Last updated: 2026-04-18

## Known State

- VM name in vCenter: `Lportainer`
- Expected SSH alias: `lportainer`
- Role: Docker/Portainer host
- Existing repo documentation starts in the top-level [README.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/README.md) and `docs/`

## First Checks

```sh
ssh lportainer hostname
ssh lportainer uptime
```

```sh
docker ps
docker compose ls
docker volume ls
df -h
```

Record verified facts in [maintenance-log.md](maintenance-log.md).

