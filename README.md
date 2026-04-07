# On-Prem Paperless-ngx Stack on ESXi

This repository now documents the audited live state of the `lportainer` VM as observed over SSH on `2026-04-04`, and includes sanitized exports of the live compose-managed stacks.

The host is currently running a Portainer-managed Docker environment with multiple Paperless-related stacks, Docker named volumes, and a Traefik proxy on a shared `proxy` network. The compose files in this repo now mirror those live stack definitions in sanitized form.

Start with [current-setup.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/current-setup.md), then use:

- [architecture.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/architecture.md)
- [live-compose.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/live-compose.md)
- [backup-restore.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/backup-restore.md)
- [operations.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/operations.md)
- [update-upgrade.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/update-upgrade.md)
- [ssh-config.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/ssh-config.md)
- [ssh-bitwarden.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/ssh-bitwarden.md)
- [windows-ssh.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/windows-ssh.md)
- [security-notes.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/security-notes.md)
- [repo-vs-live.md](/Users/czibulapeter/Documents/GitHub/lportainer/docs/repo-vs-live.md)

## Repository Layout

```text
.
├── compose/
│   ├── paperless-ai/
│   ├── paperless-core/
│   ├── paperless-pcz/
│   ├── paperless-pcz-gpt/
│   ├── paperless-work/
│   ├── portainer/
│   └── traefik/
├── docs/
├── env-templates/
└── README.md
```

## Live Setup Summary

- host alias: `lportainer`
- reverse proxy: Traefik
- admin UI: Portainer
- active application stacks:
  - `traefik`
  - `paperless-work`
  - `paperless-pcz`
  - `paperless-core`
- `paperless-ai`
- `paperless-pcz-gpt`
- storage model: Docker named volumes
- Portainer is now reconstructed in repo-managed compose form from live container inspection

## What Changed In The Docs

- removed runbooks that described a not-yet-deployed target architecture
- replaced them with current-state documentation from the live VM
- replaced the earlier draft compose definitions with sanitized exports of the live stack definitions where available
