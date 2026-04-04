# Update And Upgrade

This runbook matches the current live setup, where Portainer still appears to be the primary deployment control plane for most stacks.

## Before Updating

- confirm recent backups exist
- export Portainer stack data if you changed stack definitions there
- review release notes for Paperless, PostgreSQL, Redis, Traefik, Ollama, and Portainer
- schedule a maintenance window if updating multiple stacks together

## Current Safe Update Order

1. Traefik
2. shared helper services such as Tika and Gotenberg
3. one Paperless instance at a time
4. Ollama and Paperless GPT
5. Portainer last if you are updating it

## Current Operational Reality

Do not assume a `git pull` on this repository updates production by itself. The live host may still be running Portainer-internal stack copies.

## Recommended Transition Path

- reconcile each live stack with the matching compose file in this repo
- once matched, redeploy that stack from the repo-managed compose directory
- only then treat the repo as the authoritative deployment source for that stack

## Manual Verification After Each Update

- `traefik` is healthy and routing expected hosts
- `paperless.format.lu` loads
- `paperless-pcz.format.lu` loads
- document search and document rendering still work
- OCR/conversion still works through Tika and Gotenberg
- `paperless-pcz-gpt.format.lu` works if you rely on it
- Portainer remains accessible on `9443`

## Risk Notes

- Traefik is currently configured around the `web` entrypoint in observed live labels, so any TLS cleanup should be handled deliberately
- updating Portainer before exporting its internal stack data adds avoidable risk
