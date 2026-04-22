# format-wazuh Host Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Wazuh health checks, and reboot decisions for `format-wazuh`.

Do not record passwords, API tokens, backup passwords, registry credentials,
certificate private keys, enrollment secrets, or other secrets here.

## 2026-04-18 - Initial Documentation

Date: 2026-04-18

Maintainer: Codex with Peter

Host before:

- Not inspected in this documentation pass.

Host after:

- Documentation created only.
- Hostname: `format-wazuh`
- SSH alias: `format-wazuh`
- Primary workload: Wazuh
- Portainer: assumed absent until verified

Checks:

- SSH checked: Not checked.
- Firewall checked: Not checked.
- Fail2ban checked: Not checked.
- System health checked: Not checked.
- Disk checked: Not checked.
- Memory checked: Not checked.
- Wazuh deployment model checked: Not checked.
- Wazuh health checked: Not checked.
- Docker checked: Not checked.
- Portainer checked: Not checked; assumed absent until verified.
- Public port exposure checked: Not checked.
- Apt upgrade applied: No.
- Remaining apt upgrades checked: Not checked.
- Reboot requirement checked: Not checked.

Notes:

- Created the initial host runbook for the Wazuh VPS.
- First live maintenance thread should verify hostname, SSH alias, public IP, OS,
  kernel, firewall, Wazuh deployment model, backup paths, and whether Docker or
  Docker Compose is used.

Follow-up:

- Open a dedicated thread from the `format-server-ops` repo and run the
  discovery-first health check before changing the server.

## 2026-04-18 - Discovery-First Host Inspection

Date: 2026-04-18

Maintainer: Codex with Peter

Host before:

- Local SSH alias `format-wazuh` was not defined/resolvable on this workstation.
- Local SSH config contains `hetzner-wazuh` pointing to `116.203.114.188` as
  `root` with `/Users/czibulapeter/.ssh/hetzner-wazuh_ed25519`.
- Connected with `ssh hetzner-wazuh`; remote hostname verified as
  `format-wazuh`.

Host after:

- Hostname: `format-wazuh`
- Provider/model: Hetzner vServer, KVM virtual machine.
- Public IPv4: `116.203.114.188`
- Public IPv6: `2a01:4f8:1c1c:9a62::1/64`
- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-107-generic`
- Uptime at inspection: 13 days, 10 hours.
- Root filesystem: `/dev/sda1`, 75G total, 44G used, 29G free, 61% used.
- Hetzner volume: `/dev/sdb`, mounted at `/mnt/HC_Volume_104575658`, 79G
  total, 24G used, 51G free, 33% used.
- Wazuh indexer data is bind-mounted from
  `/mnt/HC_Volume_104575658/wazuh-indexer` to `/var/lib/wazuh-indexer`.
- Memory: 7.6Gi total, 4.2Gi used, 235Mi free, 3.5Gi buff/cache, 3.4Gi
  available; swap 4.0Gi total, 1.4Gi used.

Checks:

- SSH checked: Yes. Effective `sshd` settings show
  `permitrootlogin without-password`, `passwordauthentication no`,
  `kbdinteractiveauthentication no`, `pubkeyauthentication yes`,
  `maxauthtries 3`.
- Firewall checked: Yes. `ufw` active with default deny incoming, allow
  outgoing. Allowed inbound: `443/tcp`, `1514/tcp`, `1515/tcp`, and
  `22/tcp` rate-limited, for IPv4 and IPv6.
- Fail2ban checked: Yes. `fail2ban` active; `sshd` jail active with 7 IPs
  banned at inspection.
- System health checked: Yes. `systemctl --failed` reported 0 failed units.
- Disk checked: Yes. Root and Wazuh indexer volume have available space.
- Memory checked: Yes. Memory pressure acceptable, with swap in use.
- Wazuh deployment model checked: Yes. Wazuh is package/systemd-managed, not
  Docker-based. Active services: `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat`.
- Wazuh health checked: Yes. `wazuh-control status` showed core manager
  services running. Expected inactive components included `wazuh-clusterd`,
  `wazuh-maild`, `wazuh-agentlessd`, `wazuh-integratord`, `wazuh-dbd`, and
  `wazuh-csyslogd`. `agent_control -lc` listed the local manager and active
  enrolled agents. Dashboard on `https://127.0.0.1` returned HTTP 302 to
  login. Wazuh API on `https://127.0.0.1:55000/` returned expected
  unauthenticated JSON. Indexer on `https://127.0.0.1:9200/` returned
  `Unauthorized`.
- Docker checked: Yes. `docker` command not found; no Docker Compose or Swarm
  detected.
- Portainer checked: Yes by deployment evidence. No Docker installation and no
  Portainer deployment found.
- Public port exposure checked: Yes. Listening ports include SSH on `22`,
  Wazuh enrollment on `1515`, Wazuh agent events on `1514`, dashboard on
  public `443`, Wazuh API on local `127.0.0.1:55000`, and indexer on local
  `127.0.0.1:9200`/`9300`.
- Apt upgrade applied: No. No package upgrades were requested or applied.
- Remaining apt upgrades checked: Yes, via `apt list --upgradable`; 16
  packages were listed, mainly `systemd`, `udev`, `apparmor`, `rsyslog`,
  `snapd`, and `ubuntu-drivers-common`. Wazuh packages were already at
  candidate version `4.14.4-1`.
- Reboot requirement checked: Yes. `/var/run/reboot-required` exists.
  Reported packages: `linux-image-6.8.0-110-generic` and `linux-base`.

Notes:

- Wazuh package versions installed: `wazuh-manager 4.14.4-1`,
  `wazuh-indexer 4.14.4-1`, `wazuh-dashboard 4.14.4-1`, and
  `filebeat 7.10.2-2`.
- Wazuh paths verified: `/var/ossec`, `/etc/wazuh-indexer`,
  `/etc/wazuh-dashboard`, `/usr/share/wazuh-indexer`,
  `/usr/share/wazuh-dashboard`, and `/var/lib/wazuh-indexer`.
- Backup/data locations observed: `/var/ossec/backup` exists and is small
  (~60K). Indexer data lives on the Hetzner volume at
  `/mnt/HC_Volume_104575658/wazuh-indexer`. No separate full backup location
  was verified during this pass.
- Recent warning logs were mostly UFW blocks and public internet scan noise.
  Dashboard logs also showed unauthenticated/scanner requests against public
  `443`.
- Current workstation should either add a `format-wazuh` SSH alias pointing to
  the verified host or update this repo's docs to use the existing
  `hetzner-wazuh` alias consistently.

Follow-up:

- Decide whether to install the pending Ubuntu package updates. If updates are
  applied, re-check Wazuh services and plan a reboot window because a reboot is
  already required.
- Verify the intended backup strategy for Wazuh configuration and indexer data;
  the indexer data volume was located, but no full backup target was confirmed.

## 2026-04-18 - Package Maintenance and Reboot

Date: 2026-04-18

Maintainer: Codex with Peter

Host before:

- User confirmed maintenance could be performed immediately.
- User confirmed there is no backup of this host because it stores logging data
  only.
- Added local SSH alias `format-wazuh` pointing to `116.203.114.188` as `root`
  with `/Users/czibulapeter/.ssh/hetzner-wazuh_ed25519`.
- Pre-maintenance host state: Ubuntu 24.04.4 LTS, running kernel
  `6.8.0-107-generic`, uptime 13 days 10 hours.
- `systemctl --failed` reported 0 failed units before maintenance.
- `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` were
  active before maintenance.
- 16 apt upgrades were listed before maintenance.
- `/var/run/reboot-required` existed before maintenance for
  `linux-image-6.8.0-110-generic` and `linux-base`.

Maintenance performed:

- Ran `apt-get update`.
- Ran non-interactive `apt-get upgrade` with existing dpkg config preserved.
- Upgraded 15 packages:
  `apparmor`, `libapparmor1`, `libnss-systemd`, `libpam-systemd`,
  `libsystemd-shared`, `libsystemd0`, `libudev1`, `rsyslog`, `systemd`,
  `systemd-dev`, `systemd-resolved`, `systemd-sysv`, `systemd-timesyncd`,
  `ubuntu-drivers-common`, and `udev`.
- `snapd` was not upgraded because apt deferred it due to Ubuntu phased
  updates.
- Rebooted the host with `systemctl reboot`.

Host after:

- Host returned over SSH as `format-wazuh`.
- Running kernel after reboot: `6.8.0-110-generic`.
- Uptime at post-reboot verification: approximately 1 minute.
- Root filesystem after reboot: `/dev/sda1`, 75G total, 43G used, 30G free,
  59% used.
- Hetzner volume after reboot: `/dev/sdb`, 79G total, 24G used, 51G free,
  32% used.
- Memory after reboot: 7.6Gi total, 4.6Gi used, 1.5Gi free, 1.8Gi buff/cache,
  3.0Gi available; swap 4.0Gi total, 0B used.

Checks:

- SSH checked: Yes. `format-wazuh` alias works and SSH returned after reboot.
- Firewall checked: Yes. `ufw` active with the same allowed inbound ports:
  `443/tcp`, `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`, for IPv4 and
  IPv6.
- Fail2ban checked: Yes. `fail2ban` active; `sshd` jail active after reboot.
- System health checked: Yes. `systemctl --failed` reported 0 failed units
  after reboot.
- Disk checked: Yes. Root and Wazuh indexer volume have available space.
- Memory checked: Yes. Memory and swap state acceptable after reboot.
- Wazuh deployment model checked: Yes. Still package/systemd-managed.
- Wazuh health checked: Yes. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` active after reboot. `wazuh-control status`
  showed core manager services running. `agent_control -lc` listed the local
  manager and active enrolled agents. Wazuh API returned the expected
  unauthenticated JSON. Indexer returned expected `Unauthorized`. Dashboard
  initially returned temporary HTTP 503 during startup, then returned normal
  HTTP 302 to `/app/login?` after warm-up.
- Docker checked: Not rechecked during upgrade; prior same-day discovery found
  Docker absent.
- Portainer checked: Not rechecked during upgrade; prior same-day discovery
  found no Docker/Portainer deployment.
- Public port exposure checked: Yes. Listening ports after reboot: SSH `22`,
  Wazuh enrollment `1515`, Wazuh agent events `1514`, dashboard `443`, Wazuh
  API local `127.0.0.1:55000`, and indexer local `127.0.0.1:9200`/`9300`.
- Apt upgrade applied: Yes.
- Remaining apt upgrades checked: Yes. Only `snapd` remained listed, deferred
  by phased updates.
- Reboot requirement checked: Yes. No reboot required after reboot.

Notes:

- No entries were reported by `journalctl -b -p err..alert` after the reboot.
- Dashboard logs showed expected startup-time OpenSearch connection errors
  while the indexer was still coming up. The dashboard recovered and returned
  the normal login redirect after warm-up.
- No data cleanup, Docker prune, or Wazuh data deletion was performed.

Follow-up:

- Recheck `apt list --upgradable` later; `snapd` should become available once
  Ubuntu phased updates include this host.
- Keep the `format-wazuh` SSH alias in local SSH config as the primary alias.

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
- Wazuh deployment model checked:
- Wazuh health checked:
- Docker checked:
- Portainer checked:
- Public port exposure checked:
- Apt upgrade applied:
- Remaining apt upgrades checked:
- Reboot requirement checked:
- Notes:
- Follow-up:
