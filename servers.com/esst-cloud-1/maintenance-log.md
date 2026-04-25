# esst-cloud-1 Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker maintenance, and reboot decisions for `esst-cloud-1`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-25 - GlitchTip Hardened And Upgraded To 5.2.1

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- `esst-glitchtip_web`, `esst-glitchtip_worker`, and `esst-glitchtip_migrate`
  were running `glitchtip/glitchtip:v5.0.5`.
- Worker was attached to the `proxy` network even though it is not
  user-facing.
- Public host restrictions were not explicitly set in tracked config.
- User registration policy was commented out in the provided stack snippet.

Host after:

- GlitchTip app services updated to `glitchtip/glitchtip:v5.2.1`.
- Worker kept on the internal network only.
- Tracked stack baseline added under `glitchtip/` with secret placeholders.
- Public host hardening included in tracked config:
  `ALLOWED_HOSTS=glitchtip.esst.lu`,
  `CSRF_TRUSTED_ORIGINS=https://glitchtip.esst.lu`,
  `ENABLE_USER_REGISTRATION=false`.
- Manual `pgpartition --yes` run completed after the upgrade to create missing
  current-day partitions for event tables.

Checks:

- App version checked: OK.
- Logs checked: OK. Event ingestion continued after the upgrade and worker
  partition errors cleared after `pgpartition`.
- Config tracked in repo: OK.
- Notes: Redis remains on `6.2`; that is fine for GlitchTip 5.x but would need
  a planned upgrade before moving to GlitchTip 6.x.
- Follow-up: Use the tracked stack example as the baseline for the next planned
  maintenance window and prepare a dedicated Redis + worker-command migration
  for GlitchTip 6.x.

## 2026-04-19 - Provider SSH Key Restored And Baseline Checked

Date: 2026-04-19

Maintainer: Codex with Peter

Host before:

- Local SSH alias initially used a fresh key that had not been installed on the
  server.
- Provider private key file initially had invalid local formatting and could not
  be parsed by `ssh`.

Host after:

- Provider private key validates locally with `ssh-keygen -y`.
- Local SSH alias `esst-cloud-1` points to `cloud-user@188.42.62.40`.
- Local SSH alias uses `~/.ssh/esst-cloud-1`.
- OS: Ubuntu 24.04.3 LTS.
- Kernel: `6.8.0-110-generic`.
- Docker Engine: `29.1.3`.
- Docker Swarm state: active worker, not a manager.
- Root filesystem: 113G total, 106G used, 2.1G available, 99% used.
- Memory: 7.8Gi total, 4.6Gi available.
- Reboot requirement: none.

Checks:

- SSH checked: OK. Provider key login works as `cloud-user`.
- Sudo checked: OK. `cloud-user` has passwordless sudo.
- Firewall checked: `ufw` is inactive.
- System health checked: OK. No failed systemd units.
- Docker checked: OK. Containers are running. This host is a Swarm worker, so
  manager-only commands such as `docker stack ls` are not available here.
- Disk checked: Warning. Root filesystem is 99% used.
- Docker disk usage checked: Warning. Docker reports 46.29GB of images with
  12.8GB reclaimable, plus 7.084GB reclaimable stopped-container data.
- Private network checked: OK for ICMP to `192.168.0.5`, `192.168.0.20`, and
  `192.168.0.14`; TCP/22 to all three is closed or filtered from
  `esst-cloud-1`.
- Notes: The server explicitly rejects root SSH and instructs login as
  `cloud-user`.
- Follow-up: Prioritize disk cleanup planning before package upgrades. Identify
  the Swarm manager node before making stack changes.

## Maintenance Template

Date:

Maintainer:

Host before:

Host after:

Checks:

- SSH checked:
- Firewall checked:
- Fail2ban checked:
- System health checked:
- Disk checked:
- Memory checked:
- Docker checked:
- Public port exposure checked:
- Apt upgrade applied:
- Remaining apt upgrades checked:
- Reboot requirement checked:
- Notes:
- Follow-up:
