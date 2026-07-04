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

## 2026-05-03 - Bi-Monthly Host Upgrade And Reboot

Date: 2026-05-03

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-110-generic`
- Docker Engine: `29.4.1`
- Docker Swarm state: active manager and leader
- Root filesystem: `/dev/vda1` 34% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active manager and leader
- Root filesystem: remained healthy at about 34% used during this run

Checks:

- SSH checked: OK. `cloud-user` key login worked before and after reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. No failed systemd units before or after.
- Disk checked: OK. Root filesystem stayed at about 34% used with about 60G free.
- Memory checked: OK before maintenance. About 4.5 GiB available.
- Docker checked: OK. Docker upgraded to `29.4.2`.
- Public port exposure checked: Not rechecked directly during this run, but Traefik and Portainer services converged after reboot.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `iproute2`, `linux-firmware`, `ubuntu-pro-client`, and the `6.8.0-111` virtual kernel package set.
- Remaining apt upgrades checked: Upgrade completed without held-back packages.
- Reboot requirement checked: Reboot required after package install; controlled reboot completed during this maintenance run.
- Notes: Swarm leadership and the Portainer/Traefik control plane were briefly unavailable during the reboot window, then recovered. After reboot the manager returned as `Leader`, all four nodes showed `Ready`, and watched services converged at `1/1`.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-4`.

## 2026-05-03 - Portainer Environment Recovery After Host Updates

Date: 2026-05-03 09:22 CEST

Maintainer: Codex with Peter

Context:

- Monitoring and Portainer login were available after the host update pass.
- The Portainer environment UI showed `Failed loading environment` and
  `Unable to connect to the Docker environment`.

Findings:

- `portainer_portainer` logs showed repeated snapshot failures against
  `tcp://tasks.portainer_agent:9001` with `The agent was unable to contact any
  other agent located on a manager node`.
- `portainer_agent` logs showed stale agent-cluster membership after the Swarm
  node reboot sequence.
- Docker overlay connectivity on `portainer_agent_network` was healthy when
  tested from a throwaway BusyBox container; DNS and TCP/9001 connectivity to
  all current agent task IPs worked.

Actions:

- Ran `docker service update --force portainer_agent` to rebuild the global
  Portainer agent mesh.
- Ran `docker service update --force portainer_portainer` to refresh the
  Portainer server after the agent mesh converged.

Result:

- `portainer_agent` converged at `4/4`.
- `portainer_portainer` converged at `1/1`.
- Fresh `portainer_portainer` logs no longer showed current environment
  connection errors.
- Fresh `portainer_agent` logs no longer showed current `no manager node found`
  errors.

Follow-up:

- Browser/UI refresh recommended to confirm the Portainer environment loads
  normally again.

## 2026-05-03 - Portainer Upgrade To 2.41.0

Date: 2026-05-03 10:00 CEST

Maintainer: Codex with Peter

Actions:

- Verified `portainer/agent:2.41.0` and `portainer/portainer-ee:2.41.0` were
  pullable before rollout.
- Updated the global `portainer_agent` service from `2.39.1` to `2.41.0`.
- Waited for the agent rollout to converge across all four nodes.
- Updated the `portainer_portainer` service from `2.39.1` to `2.41.0`.
- Waited for the Portainer server task to converge on the manager.

Result:

- `portainer_agent` converged at `4/4` on `portainer/agent:2.41.0`.
- `portainer_portainer` converged at `1/1` on
  `portainer/portainer-ee:2.41.0`.
- Fresh Portainer logs showed normal startup with no current environment
  connection errors.
- Fresh agent logs showed expected rolling-update membership churn only; no
  fresh `no manager node found` or redirect errors remained.

Follow-up:

- Open Portainer and do a quick environment/stacks smoke check after the UI
  refreshes.

## 2026-05-03 - Traefik Upgrade To 3.6.15

Date: 2026-05-03 10:03 CEST

Maintainer: Codex with Peter

Actions:

- Verified `traefik:3.6.15` was pullable on `esst-cloud-4` before rollout.
- Updated the `traefik_traefik` service from `traefik:3.6.6` to
  `traefik:3.6.15`.
- Confirmed the manager-pinned single replica converged after replacement.

Result:

- `traefik_traefik` converged at `1/1` on `traefik:3.6.15`.
- Fresh Traefik logs showed no startup errors in the immediate post-upgrade
  window.
- Published `:443` bindings remained attached to the new task on
  `esst-cloud-4`.

Follow-up:

- Do a quick browser smoke test across the main public endpoints routed through
  Traefik.

## 2026-05-16 - Monthly Host Upgrade And Reboot

Date: 2026-05-16

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active manager and leader
- Root filesystem: `/dev/vda1` 35% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active manager and leader
- Root filesystem: `/dev/vda1` 36% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 36% used with about 59G free.
- Memory checked: OK. About 4.9 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.0`.
- Public port exposure checked: Not rechecked directly during this run, but Traefik and Portainer both reconverged after the manager reboot.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `docker-buildx-plugin`, `open-vm-tools`, `distro-info-data`, and the `6.8.0-117` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: On the first post-reboot manager check, `esst-cloud-1` and `esst-cloud-2` were still marked `Unknown` briefly and `traefik_traefik` / `portainer_portainer` had not reconverged yet. A short wait was enough for all four nodes to return to `Ready`, the manager to remain `Leader`, `portainer_agent` to return to `4/4`, `portainer_portainer` to return to `1/1`, and `traefik_traefik` to return to `1/1`.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-4`.

## 2026-05-31 - End-Of-Month Host Upgrade And Reboot

Date: 2026-05-31

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active manager and leader
- Root filesystem: `/dev/vda1` 35% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active manager and leader
- Root filesystem: `/dev/vda1` 36% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 36% used with about 59G free.
- Memory checked: OK. About 5.0 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.2`.
- Public port exposure checked: Not rechecked directly during this run, but Traefik and Portainer both remained converged after the manager reboot.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `snapd`, and the `6.8.0-124` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: On the first post-reboot manager check, `esst-cloud-2` and `esst-cloud-3` briefly showed `Unknown` before returning to `Ready`. The previously degraded `esst-monitoring-beta_app` and `esst-monitoring-mcp-server_mcp` services remained `0/1`; they were already in that state before this maintenance run and did not appear to be caused by the host upgrades.
- Follow-up: Review the pre-existing `esst-monitoring-beta_app` and `esst-monitoring-mcp-server_mcp` service failures separately from host maintenance when convenient.

## 2026-06-14 - Twice-Monthly Host Upgrade And Reboot

Date: 2026-06-14

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active manager, `Leader`
- Root filesystem: `/dev/vda1` 36% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Docker Swarm state: active manager, returned as `Leader`
- Root filesystem: `/dev/vda1` 36% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 36% used with about 59G free.
- Memory checked: OK. About 5.0 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.3`. The manager returned as Swarm `Leader`, all four nodes reconverged as `Ready`, `portainer_agent` returned to `4/4`, `portainer_portainer` returned to `1/1`, and `traefik_traefik` returned to `1/1`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `apparmor`, `cloud-init`, `libapparmor1`, `libjcat1`, and `libxmlb2`.
- Remaining apt upgrades checked: `fwupd` remained held back.
- Reboot requirement checked: Reboot required after package install due to `apparmor`; controlled reboot completed during this maintenance run.
- Notes: Immediately after the manager reboot, all three workers briefly showed `Unknown` and both Portainer and Traefik had not reconverged yet. A short wait was enough for the cluster to recover naturally. `esst-monitoring-mcp-server_mcp` remained `0/1` after the host maintenance run, and `traefik_delay-start` still shows its old failed one-shot task history; both remain separate application-level issues.
- Follow-up: Keep `esst-monitoring-mcp-server_mcp` on the application maintenance list; it was not caused by host patching.

## 2026-07-04 - July Host Upgrade And Reboot

Date: 2026-07-04

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Docker Swarm state: active manager, `Leader`
- Root filesystem: `/dev/vda1` 37% used
- Reboot-required marker was already present from an earlier kernel install and listed `linux-image-6.8.0-134-generic` plus `linux-base`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Docker Engine: `29.6.1`
- Docker Swarm state: active manager, returned as `Leader`
- Root filesystem: `/dev/vda1` 37% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 37% used with about 58G free.
- Memory checked: Not rechecked separately after reboot during this run.
- Docker checked: OK. Docker upgraded to `29.6.1`. The manager returned as Swarm `Leader`, all four nodes reconverged as `Ready`, `portainer_agent` returned to `4/4`, `portainer_portainer` returned to `1/1`, and `traefik_traefik` returned to `1/1`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `iproute2`, `kpartx`, and `multipath-tools`.
- Remaining apt upgrades checked: `fwupd` remained deferred by phasing.
- Reboot requirement checked: Reboot required before maintenance due to the pending `6.8.0-134` kernel. Controlled reboot completed and the flag cleared.
- Notes: Immediately after the manager reboot, `esst-cloud-3` briefly showed `Unknown` before returning to `Ready`. All monitored production services and the four Duplicati services converged cleanly after the cluster settled. `traefik_delay-start` still shows its old failed one-shot task history; it remains separate from host patching.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-4`.

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
