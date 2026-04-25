# esst-cloud-4 Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker maintenance, and reboot decisions for `esst-cloud-4`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-25 - Duplicati EC4 Preparation

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- `esst-cloud-4` runs the Swarm manager role, Portainer server, and Traefik.
- No node-local Duplicati stack was present for EC4.

Host after:

- Prepared `duplicati-ec4` stack definition, pinned to `esst-cloud-4`.
- Backup scope selected as `/opt/esst` and `/etc`.
- `/data` intentionally excluded because EC4 currently holds stale application
  and database copies; active production data is backed up on EC1, EC2, and EC3.

Checks:

- Portainer data found under `/opt/esst/deployment/portainer/data`.
- Traefik certificates and configuration found under `/opt/esst/deployment/traefik`.
- Traefik access logs are large and should be excluded from Duplicati.
- Added `/opt/esst/maintenance/backup-portainer-data-files.sh` to snapshot
  Portainer DB/key files into `/opt/esst/deployment/portainer/backups/current-data-files/`.
- Added root cron to run the Portainer snapshot at `21:45 UTC`, before the
  EC4 Duplicati schedule.
- Configured and ran the initial `duplicati-ec4` backup job.
- Initial backup checked: completed successfully after excluding live locked
  Portainer DB files and backing up the snapshot copies instead.
- Follow-up: Monitor the next scheduled Portainer snapshot and EC4 Duplicati run.

## 2026-04-22 - Portainer Agent Version Aligned

Date: 2026-04-22

Maintainer: Codex with Peter

Host before:

- Direct SSH to `esst-cloud-4` worked as `cloud-user`.
- `esst-cloud-4` was the Docker Swarm leader.
- Docker Engine was `29.4.1`.
- `portainer_portainer` was running `portainer/portainer-ee:2.39.1`.
- `portainer_agent` was running `portainer/agent:2.33.6` on all four nodes.
- Portainer UI was unstable: Environment and Stack menu items appeared after
  refreshes and then disappeared again.

Host after:

- `portainer_agent` was updated to `portainer/agent:2.39.1`.
- `portainer_portainer` remained on `portainer/portainer-ee:2.39.1`.
- Portainer server and agent versions now match.
- `portainer_agent` converged at `4/4`.
- `portainer_portainer` remained `1/1`.
- Peter confirmed the Portainer UI looked stable after the change.

Checks:

- SSH checked: OK. `ssh esst-cloud-4` returned hostname `esst-cloud-4`.
- Docker checked: OK. Swarm showed four Ready nodes with `esst-cloud-4` as
  Leader.
- Portainer backup checked: Created before the agent update:
  `/opt/esst/deployment/portainer/backups/portainer-data-before-agent-2391-20260422T191029Z.tar.gz`.
- Portainer logs checked: Before the update, `portainer_portainer` logged
  repeated snapshot failures: `The agent was unable to contact any other agent
  located on a manager node`.
- Agent logs checked: Before the update, agents logged repeated `unable to
  redirect request to a manager node: no manager node found` errors.
- Post-update logs checked: The manager-node contact error did not reappear
  after waiting through the next scheduled snapshot window. Some non-blocking
  image digest fetch errors for `bitnami/redis` remained.
- Notes: Portainer's published compatibility matrix for Business `2.39.1 LTS`
  lists Docker Engine `28.5.1` and `29.2.1` as tested versions. This host is on
  Docker `29.4.1`, so Docker lifecycle work should be handled in a larger
  maintenance window rather than as an incidental Portainer fix.
- Follow-up: Keep Portainer server and agent versions aligned during future
  updates. Plan a separate Docker maintenance window to decide whether to hold,
  downgrade, or advance Docker Engine after checking Portainer, Docker Swarm,
  and application compatibility.

## 2026-04-19 - Local SSH Alias And Key Prepared

Date: 2026-04-19

Maintainer: Codex with Peter

Host before:

- Local SSH alias was not present.
- Local per-host key was not present.

Host after:

- Provider private key validates locally with `ssh-keygen -y`.
- Local SSH alias `esst-cloud-4` points to `cloud-user@172.255.248.244`.
- Local SSH alias uses `~/.ssh/esst-cloud-4`.

Checks:

- SSH checked: Not yet reachable from this workstation. Port 22 connection timed
  out during a non-interactive probe. TCP/22 also timed out from `esst-cloud-1`
  to private IP `192.168.0.14`, although ICMP ping works.
- Notes: The timeout likely indicates host firewall policy, provider firewall,
  SSH listening on a different port/interface, or sshd not running.
- Follow-up: Use servers.com console or Swarm manager access to confirm SSH
  service and firewall state.

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
