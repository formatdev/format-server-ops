# Operations Runbook

This runbook reflects the current live host shape observed on `lportainer` and the sanitized compose exports now stored in the repo.

## Daily Or Weekly Checks

- confirm `traefik`, both Paperless instances, both PostgreSQL containers, both Redis containers, and Portainer are healthy
- review Traefik routing health and dashboard access
- review Paperless ingestion and OCR behavior on both instances
- confirm Docker volume usage and host free space
- confirm backups include Docker volumes plus configuration outside Git

## Common Commands

From the VM over SSH:

```bash
ssh lportainer 'docker ps'
ssh lportainer 'docker network ls'
ssh lportainer 'docker volume ls'
```

Inspect a specific service:

```bash
ssh lportainer 'docker logs --tail=200 paperless'
ssh lportainer 'docker logs --tail=200 paperless-pcz'
ssh lportainer 'docker logs --tail=200 traefik'
```

Inspect routing labels and network attachment:

```bash
ssh lportainer 'docker inspect paperless'
ssh lportainer 'docker inspect paperless-pcz'
ssh lportainer 'docker inspect traefik'
```

## Update Workflow

The host appears to be managed primarily through Portainer-managed compose projects and at least one local compose directory for Traefik. Use the repo compose files as audited references until you deliberately switch the live deployment workflow to pull from Git.

## Log Review

- watch for OCR failures
- watch for database connection issues
- watch for Traefik routing or certificate errors
- watch for disk pressure and backup failures

## Administrative Guidance

- treat the audited live host and this repo as two different states until migration is completed
- document changes made directly in Portainer or on the host until the stack is moved under Git control
- when you are ready, redeploy one stack at a time from the sanitized repo definitions rather than trying to flip everything at once
