# Format Server Ops

This repository started as documentation for the `lportainer` VM, but it now serves as a broader operations and maintenance workspace for internal and external Windows and Unix servers.

It currently includes the audited live state of the `lportainer` VM as observed over SSH on `2026-04-04`, sanitized exports of the live compose-managed stacks, SSH runbooks, and server maintenance notes such as the `EASYJOB3` inventory and health check.

The host is currently running a Portainer-managed Docker environment with multiple Paperless-related stacks, Docker named volumes, and a Traefik proxy on a shared `proxy` network. The compose files in this repo now mirror those live stack definitions in sanitized form.

Start with [current-setup.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/current-setup.md), then use:

- [architecture.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/architecture.md)
- [live-compose.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/live-compose.md)
- [backup-restore.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/backup-restore.md)
- [operations.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/operations.md)
- [update-upgrade.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/update-upgrade.md)
- [ssh-config.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/ssh-config.md)
- [ssh-bitwarden.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/ssh-bitwarden.md)
- [windows-ssh.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/windows-ssh.md)
- [security-notes.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/security-notes.md)
- [repo-vs-live.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/docs/repo-vs-live.md)
- [format-cloud-1 host runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/_host/README.md)
- [format-wazuh host runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-wazuh/_host/README.md)
- [Vaultwarden format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/vaultwarden/README.md)
- [Traefik format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/traefik/README.md)
- [Portainer format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/portainer/README.md)
- [phpMyAdmin format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/phpmyadmin/README.md)
- [NoLimits Website format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/nolimits-website/README.md)
- [Duplicati FC1 format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/duplicati-fc1/README.md)
- [Database 1 format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/database-1/README.md)
- [Custom App format-cloud-1 strategy](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/custom-apps/README.md)
- [Custom App format-cloud-1 version matrix](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/custom-apps/version-matrix.md)
- [next-floc format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/next-floc/README.md)
- [format-timesheet-reports format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-reports/README.md)
- [format-timesheet-2026 format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-timesheet-2026/README.md)
- [format-dsk format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/format-dsk/README.md)
- [chargy-loeffler format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/chargy-loeffler/README.md)
- [chargy format-cloud-1 stack runbook](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/chargy/README.md)

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
├── hetzner/
│   ├── format-cloud-1/
│   │   ├── _host/
│   │   ├── chargy/
│   │   ├── chargy-loeffler/
│   │   ├── custom-apps/
│   │   ├── database-1/
│   │   ├── duplicati-fc1/
│   │   ├── format-dsk/
│   │   ├── format-timesheet-2026/
│   │   ├── format-timesheet-reports/
│   │   ├── next-floc/
│   │   ├── nolimits-website/
│   │   ├── phpmyadmin/
│   │   ├── portainer/
│   │   ├── traefik/
│   │   └── vaultwarden/
│   └── format-wazuh/
│       └── _host/
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
