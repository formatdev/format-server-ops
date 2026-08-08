# esst-cloud-3 Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Docker maintenance, and reboot decisions for `esst-cloud-3`.

Do not record passwords, API tokens, backup passwords, registry credentials, or
other secrets here.

## 2026-04-25 - Duplicati EC3 Preparation

Date: 2026-04-25

Maintainer: Codex with Peter

Host before:

- `esst-cloud-3` holds the production monitoring MariaDB service.
- No Portainer-managed Duplicati stack was present for this node.

Host after:

- Prepared `duplicati-ec3` stack definition for a node-local Duplicati service.
- Prepared logical MariaDB all-database dump script with 14 day local retention.
- Adjusted normal database dump to exclude `monitoring.audit_trail_entry`,
  `monitoring.activity_log`, and `monitoring.failed_jobs`.
- Prepared optional latest-only heavy table dump script for those tables.
- Disabled EC3 database dump scheduling after deciding that EC2 app-generated
  monitoring dumps are the backup source for the `monitoring` database.
- Removed EC3 local monitoring dump staging files.
- Backup design excludes the live MariaDB datadir and backs up dump files instead.

Checks:

- SFTP key copied to the node and verified against NAS4 `/ESSTBF/duplicati/esst-cloud-3`.
- MariaDB root credential file prepared as root-readable only on the node.
- MariaDB connection verified from the running container.
- Notes: The production monitoring database is backed up through the EC2
  app-generated dump folder. EC3 should not back up the live MariaDB datadir or
  scheduled `monitoring` database dumps.
- Follow-up: Deploy `duplicati-ec3` through Portainer, configure the Duplicati job, and run the first backup after EC2 finishes.

## 2026-04-19 - Local SSH Alias And Key Prepared

Date: 2026-04-19

Maintainer: Codex with Peter

Host before:

- Local SSH alias was not present.
- Local per-host key was not present.

Host after:

- Provider private key validates locally with `ssh-keygen -y`.
- Local SSH alias `esst-cloud-3` points to `cloud-user@188.42.62.60`.
- Local SSH alias uses `~/.ssh/esst-cloud-3`.

Checks:

- SSH checked: Not yet reachable from this workstation. Port 22 connection timed
  out during a non-interactive probe. TCP/22 also timed out from `esst-cloud-1`
  to private IP `192.168.0.20`, although ICMP ping works.
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
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 43% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: unchanged at about 43% used during this run

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. No failed systemd units before or after.
- Disk checked: OK. Root filesystem stayed at about 43% used with about 42G free.
- Memory checked: OK before maintenance. About 2.4 GiB available.
- Docker checked: OK. Docker upgraded to `29.4.2` and the watched local Duplicati plus production MariaDB service converged after reboot.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `linux-firmware`, `ubuntu-pro-client`, and the `6.8.0-111` virtual kernel package set.
- Remaining apt upgrades checked: One package remains deferred by Ubuntu phasing: `iproute2`.
- Reboot requirement checked: Reboot required after package install; controlled reboot completed during this maintenance run.
- Notes: Manager reported `esst-cloud-3` down briefly during reboot, then back to `Ready`. Watched services remained healthy at `1/1`.
- Follow-up: Revisit `iproute2` on a later maintenance pass once Ubuntu phasing permits it.

## 2026-05-16 - Monthly Host Upgrade And Reboot

Date: 2026-05-16

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Docker Engine: `29.4.2`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 44% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` remained about 44% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained at about 44% used with about 41G free.
- Memory checked: OK. About 3.1 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.0`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `docker-buildx-plugin`, `iproute2`, `open-vm-tools`, `distro-info-data`, and the `6.8.0-117` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: This pass cleared the previously phased `iproute2` upgrade on `esst-cloud-3`.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-3`.

## 2026-05-31 - End-Of-Month Host Upgrade And Reboot

Date: 2026-05-31

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Docker Engine: `29.5.0`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 44% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` remained about 45% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked after maintenance.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 45% used with about 41G free.
- Memory checked: OK. About 3.2 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.2`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `snapd`, and the `6.8.0-124` virtual kernel package set.
- Remaining apt upgrades checked: OK. No reboot required after the host returned.
- Reboot requirement checked: Reboot required after package install; host returned on the new kernel.
- Notes: Worker maintenance completed cleanly and the node rejoined Swarm normally.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-3`.

## 2026-06-14 - Twice-Monthly Host Upgrade And Reboot

Date: 2026-06-14

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.2`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 45% used

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 45% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 45% used with about 41G free.
- Memory checked: OK. About 3.2 GiB available after reboot.
- Docker checked: OK. Docker upgraded to `29.5.3` and the node returned to Swarm as `Ready`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded Docker CE/CLI, `apparmor`, `cloud-init`, `libapparmor1`, `libjcat1`, and `libxmlb2`.
- Remaining apt upgrades checked: `fwupd` remained held back.
- Reboot requirement checked: Reboot required after package install due to `apparmor`; controlled reboot completed during this maintenance run.
- Notes: `needrestart` reported that no containers required restart during package installation. `apparmor` emitted the same post-install warning seen on the other ESST hosts: `/var/lib/dpkg/info/apparmor.postinst: 148: [: Illegal number: yes`, but the package completed and the host returned healthy.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-3`.

## 2026-07-04 - July Host Upgrade And Reboot

Date: 2026-07-04

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Docker Engine: `29.5.3`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 45% used
- Reboot-required marker was already present from an earlier kernel install and listed `linux-image-6.8.0-134-generic` plus `linux-base`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Docker Engine: `29.6.1`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 45% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 45% used with about 41G free.
- Memory checked: Not rechecked separately after reboot during this run.
- Docker checked: OK. Docker upgraded to `29.6.1` and the node returned to Swarm as `Ready`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `iproute2`, `kpartx`, and `multipath-tools`.
- Remaining apt upgrades checked: `fwupd` remained deferred by phasing.
- Reboot requirement checked: Reboot required before maintenance due to the pending `6.8.0-134` kernel. Controlled reboot completed and the flag cleared.
- Notes: `needrestart` reported that no services, containers, or user sessions required additional restart after package installation.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-3`.

## 2026-08-08 - August Host Upgrade And Reboot

Date: 2026-08-08

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Docker Engine: `29.6.1`
- Docker Swarm state: active worker
- Root filesystem: `/dev/vda1` 46% used
- Reboot-required marker was already present and listed `linux-image-6.8.0-136-generic`, `linux-image-6.8.0-137-generic`, `linux-base`, and `libc6`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-137-generic`
- Docker Engine: `29.7.2`
- Docker Swarm state: active worker, rejoined as `Ready`
- Root filesystem: `/dev/vda1` 48% used

Checks:

- SSH checked: OK. `cloud-user` key login still worked before and after the reboot.
- Firewall checked: Not rechecked during this run.
- Fail2ban checked: Not rechecked during this run.
- System health checked: OK. Upgrade and reboot completed cleanly.
- Disk checked: OK. Root filesystem remained healthy at about 48% used with about 39G free.
- Memory checked: Not rechecked separately after reboot during this run.
- Docker checked: OK. Docker upgraded to `29.7.2` and the node returned to Swarm as `Ready`.
- Public port exposure checked: Not rechecked during this run.
- Apt upgrade applied: Yes. Upgraded `apport`, `apport-core-dump-handler`, `containerd.io`, Docker CE/CLI, `docker-buildx-plugin`, `docker-compose-plugin`, `libplymouth5`, `plymouth`, `plymouth-theme-ubuntu-text`, `python3-apport`, and `python3-problem-report`.
- Remaining apt upgrades checked: `fwupd` remained held back.
- Reboot requirement checked: Reboot required before maintenance due to the pending `6.8.0-136` and `6.8.0-137` kernels. Controlled reboot completed and the flag cleared.
- Notes: `needrestart` reported that no containers needed restart after package installation.
- Follow-up: No immediate host-level follow-up required for `esst-cloud-3`.

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
