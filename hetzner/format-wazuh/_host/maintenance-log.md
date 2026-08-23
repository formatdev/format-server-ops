# format-wazuh Host Maintenance Log

Use this log for host-level checks, package maintenance, firewall/SSH posture,
Wazuh health checks, and reboot decisions for `format-wazuh`.

Do not record passwords, API tokens, backup passwords, registry credentials,
certificate private keys, enrollment secrets, or other secrets here.

## 2026-08-23 - OS Maintenance, Reboot, And Agent Route Repair

Date: 2026-08-23 15:45 CEST

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and `wazuh-dashboard` at `4.14.7-1`
- `filebeat` package: `7.10.2-2`
- Uptime: about 18 days, 22 hours, 19 minutes.
- Root filesystem: 75G total, 61G used, 12G free, 85% used.
- Wazuh data volume: 79G total, 61G used, 15G free, 82% used.
- Memory: 7.6 GiB total, about 3.4 GiB available, 1.4 GiB swap used.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-138-generic`
- Wazuh packages unchanged at `4.14.7-1`
- `filebeat` package unchanged at `7.10.2-2`
- Root filesystem after retention enforcement: 75G total, 43G used, 30G free, 60% used.
- Wazuh data volume after retention enforcement: 79G total, 28G used, 48G free, 37% used.
- Memory after reboot and warm-up: 7.6 GiB total, about 2.8 GiB available, 14 MiB swap used.

Checks:

- SSH checked: OK. The `format-wazuh` alias still resolves to `116.203.114.188` and worked before and after reboot.
- Firewall checked: OK. `ufw` remains active with inbound `443/tcp`, `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. The `sshd` jail is active; one source was banned at inspection time.
- System health checked: OK. No failed systemd units were reported before or after maintenance.
- Wazuh deployment model checked: OK. Wazuh remains package/systemd-managed; Docker is absent.
- Wazuh services checked: OK. `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` are active.
- Wazuh endpoints checked: OK. Final local checks returned `302` from the dashboard, `401` from the API, and `401` from the indexer.
- Indexer health checked: OK. The single-node cluster recovered to expected yellow with all 692 primary shards active and 31 replica shards unassigned.
- Searchable alert retention applied: Created ISM policy `wazuh-alert-retention-90d` with a `wazuh-alerts-*` template, attached it to all 195 existing alert indices, and verified the newest retained index is managed.
- Initial index retention enforced: Deleted the exact 104 daily alert indices dated 2026-02-10 through 2026-05-24. The remaining 91 indices run from 2026-05-25 through 2026-08-23 and are all managed by the 90-day policy.
- Local alert retention applied: Installed and enabled `wazuh-local-alert-retention.timer`, scheduled daily around 03:35 UTC with randomized delay. Its first successful run removed 694 dated alert and checksum files older than 30 days, reclaiming 18.36 GiB.
- Local alert safety checked: OK. Live `alerts.log` and `alerts.json` remained present, the oldest retained dated file is from 2026-07-24, and the local alert tree now uses about 4.6 GiB.
- Internal and queue retention checked: OK. `monitord.keep_log_days=31` remains unchanged, and `/var/ossec/queue` remained untouched at about 16 GiB.
- Agent checked: OK after route repair. `043 MBP-PCZ` returned to `Active` after the Mac route for `116.203.114.188` was changed from OpenVPN interface `utun7` to the local Wi-Fi gateway.
- Persistent VPN route checked: OK. The OpenVPN Connect profile now ignores only the server-pushed route for `116.203.114.188` and adds that host through `net_gateway`. After a full VPN disconnect and reconnect, the Wazuh host used gateway `10.115.56.1` on `en0`, while `188.245.43.92` remained routed through `192.168.113.1` on `utun7`. TCP ports `1514` and `1515` remained reachable and agent `043 MBP-PCZ` was `Active` on the manager.
- Listening ports checked: OK. SSH `22`, dashboard `443`, agent traffic `1514`, enrollment `1515`, local API `55000`, and local indexer `9200`/`9300` remain as expected.
- Apt upgrade applied: Yes. Applied 19 routine OS and security updates covering Apport, console setup, Kerberos libraries, QEMU guest agent, Snap, Vim, Wget, and related packages. Wazuh itself was already current and was not upgraded.
- Pending apt upgrades checked: One phased `open-vm-tools` update remains. It was not forced outside Ubuntu's rollout phase.
- Reboot requirement checked: OK. Rebooted into `6.8.0-138-generic`; no reboot marker remained.

Notes:

- The pre-existing unused ISM policy `60` had no template and managed zero indices. It was removed after the new policy was attached and verified.
- The 9.6G historical archive at `/root/wazuh-backup-2025-08-03.tar.gz` remains untouched.
- The Mac route exception is persistent in the OpenVPN Connect profile using `pull-filter ignore` for the Wazuh host route plus an explicit `net_gateway` route. A timestamped local backup of the original profile was retained before editing.
- Deletion was limited to the 104 previewed alert indices older than 90 days and dated local alert/checksum files older than 30 days. No queue data, current logs, configuration, certificate, enrollment key, or backup archive was deleted.

Follow-up:

- Monitor the ISM policy and local retention timer during future maintenance rounds.
- Recheck the Wazuh route and agent status if the OpenVPN profile is replaced or re-imported in the future.
- Decide separately whether the 9.6G historical archive should remain on the host.

## 2026-08-04 - Wazuh Upgrade And Reboot

Date: 2026-08-04

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and `wazuh-dashboard` at `4.14.6-1`
- `filebeat` package: `7.10.2-2`
- Uptime: about 2 weeks, 2 days, 7 hours, 21 minutes.
- Root filesystem: 75G total, 59G used, 13G free, 83% used.
- Wazuh data volume: 79G total, 56G used, 19G free, 76% used.
- Memory: 7.6 GiB total, about 3.4 GiB available, 1.2 GiB swap used.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and `wazuh-dashboard` at `4.14.7-1`
- `filebeat` package: `7.10.2-2`
- Root filesystem after package-cache cleanup: 75G total, 57G used, 16G free, 79% used.
- Wazuh data volume: 79G total, 55G used, 20G free, 74% used.
- Memory after reboot and warm-up: 7.6 GiB total, about 3.1 GiB available, negligible swap used.

Checks:

- SSH checked: OK. `ssh format-wazuh` resolves to `116.203.114.188` and worked through the configured alias.
- Firewall checked: OK. `ufw` remains active with inbound `443/tcp`, `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active; three sources were banned at inspection time.
- System health checked: OK. `systemctl --failed` reported 0 failed units.
- Wazuh deployment model checked: OK. Still package/systemd-managed; Docker remains absent.
- Wazuh health checked: OK. `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` are active. Local checks returned `302` from `https://127.0.0.1/`, `401` from `https://127.0.0.1:55000/`, and `401` from `https://127.0.0.1:9200/`.
- Agent list checked: OK. `agent_control -lc` listed the local manager and enrolled active agents, including `043 MBP-PCZ`.
- Public/listening ports checked: OK. Listening ports remain SSH `22`, Wazuh enrollment `1515`, Wazuh agent events `1514`, dashboard `443`, Wazuh API local `127.0.0.1:55000`, and indexer local `127.0.0.1:9200`/`9300`.
- Apt upgrade applied: Yes. Upgraded `wazuh-manager`, `wazuh-indexer`, and `wazuh-dashboard` to `4.14.7-1`, `libssl3t64` and `openssl` to `3.0.13-0ubuntu3.12`, `tzdata` to `2026c-0ubuntu0.24.04.1`, and `distro-info-data` to `0.72-0ubuntu0.24.04.1`.
- Pending apt upgrades checked: OK. No package upgrades remained after maintenance.
- Upgrade simulation checked: OK. `apt-get -s upgrade` and `apt-get -s full-upgrade` both reported 7 upgraded, 0 newly installed, 0 removed, and 0 not upgraded.
- Reboot requirement checked: OK. Reboot completed and no reboot marker remained afterward.

Notes:

- No Wazuh indices, configuration, certificates, logs, or backup archives were deleted.
- During post-reboot warm-up the indexer was red while primary shards recovered in batches of four. Allocation diagnostics reported temporary recovery throttling with in-sync shard stores. The cluster recovered to yellow with all 630 primary shards active, 30 replica shards unassigned as expected for this single-node indexer, and the dashboard returned to HTTP `302`.
- Clearing downloaded apt package installers after the successful upgrade reduced root usage from a transient 90% to 79%.
- A historical 10G archive remains at `/root/wazuh-backup-2025-08-03.tar.gz`; it was identified but left untouched.

Follow-up:

- Continue monitoring Wazuh index growth and retention; the data volume is 74% used.
- Decide separately whether the 10G historical archive in `/root` should be retained or moved off-host.

## 2026-07-19 - Mid-Month Maintenance Round

Date: 2026-07-19

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Installed kernel package: `linux-image-virtual=6.8.0-136.136`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard` at `4.14.6-1`
- `filebeat` package: `7.10.2-2`
- Uptime: about 14 days, 15 hours.
- Root filesystem: 75G total, 54G used, 18G free, 75% used.
- Wazuh data volume: 79G total, 50G used, 25G free, 68% used.
- Memory: 7.6 GiB total, about 3.4 GiB available, 1.5 GiB swap used.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-136-generic`
- Wazuh packages unchanged at `4.14.6-1`
- `filebeat` package unchanged at `7.10.2-2`
- Root filesystem: 75G total, 54G used, 19G free, 75% used.
- Wazuh data volume: 79G total, 50G used, 25G free, 67% used.
- Memory after warm-up: 7.6 GiB total, about 2.9 GiB available, about 9.8 MiB
  swap used.

Checks:

- SSH checked: OK. `ssh format-wazuh` worked through the configured alias
  before and after reboot.
- Local route checked: OK after cleanup. Removed stale local OpenVPN host
  routes for `188.245.43.92` and `116.203.114.188`; both routed through `en0`
  at final verification.
- Firewall checked: OK. `ufw` remains active with inbound `443/tcp`,
  `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active.
- System health checked: OK. `systemctl --failed` reported 0 failed units.
- SSH hardening checked: OK. Password authentication remains disabled,
  public-key authentication remains enabled, and `MaxAuthTries` remains 3.
- Wazuh deployment model checked: OK. Still package/systemd-managed; Docker,
  Compose, Swarm, and Portainer remain absent.
- Wazuh health checked: OK. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` are active after reboot. Final local
  checks returned `401` from `https://127.0.0.1:55000/`, `401` from
  `https://127.0.0.1:9200/`, and `302` from `https://127.0.0.1/`.
- Agent list checked: OK. `043 MBP-PCZ` remained `Active`, and the local Mac
  Wazuh agent processes were running.
- Agent endpoint checked: OK. `wazuh-agent.format.lu` accepted TCP connections
  on `1514` and `1515` after stale local routes were removed.
- Apt upgrade applied: Yes. Ran `apt-get update`, `apt-get upgrade`, and
  `apt-get full-upgrade`.
- Remaining apt upgrades checked: OK. No package upgrades remained after
  maintenance.
- Reboot requirement checked: OK. Rebooted into `6.8.0-136-generic`; no
  reboot marker remained afterward.

Package changes:

- `apport` and related Python packages `2.28.2-0ubuntu0.1`
- `plymouth` packages `24.004.60-1ubuntu7.2`
- `linux-image-virtual` `6.8.0-136.136`

Notes:

- Wazuh application packages did not change in this pass.
- The dashboard returned temporary HTTP `503` for several minutes after reboot
  while the indexer and dashboard finished warming up. It later returned the
  normal HTTP `302`.
- Wazuh disk use is still worth watching: root stayed around 75%, and the Wazuh
  data volume is now around 67%.
- The local OpenVPN host routes returned again and had to be removed again
  before final checks.

Follow-up:

- Keep watching Wazuh disk growth before it crosses the comfort line.
- Watch for OpenVPN recreating stale Hetzner host routes; this has now caused
  Wazuh verification or agent connectivity trouble repeatedly.

## 2026-07-04 - Maintenance Round

Date: 2026-07-04

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Installed kernel package: `linux-image-virtual=6.8.0-134.134`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard` at `4.14.5-1`
- `filebeat` package: `7.10.2-2`
- Uptime: about 19 days, 23 hours
- Root filesystem: 75G total, 54G used, 19G free, 75% used.
- Wazuh data volume: 79G total, 46G used, 29G free, 62% used.
- Memory: 7.6 GiB total, about 3.3 GiB available, 1.2 GiB swap used.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-134-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard` at `4.14.6-1`
- `filebeat` package unchanged at `7.10.2-2`
- Uptime at final verification: about 1 minute when service checks were green.
- Root filesystem: 75G total, 55G used, 18G free, 76% used.
- Wazuh data volume: 79G total, 46G used, 29G free, 62% used.
- Memory: 7.6 GiB total, about 3.2 GiB available, 0B swap used.

Checks:

- SSH checked: OK. `ssh format-wazuh` worked through the configured alias.
- Firewall checked: OK. `ufw` remains active with inbound `443/tcp`,
  `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail are active.
- System health checked: OK. `systemctl --failed` reported 0 failed units.
- SSH hardening checked: OK. Password authentication remains disabled,
  public-key authentication remains enabled, and `MaxAuthTries` remains 3.
- Wazuh deployment model checked: OK. Still package/systemd-managed; Docker,
  Compose, Swarm, and Portainer remain absent.
- Wazuh health checked: OK. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` are active after the upgrade and reboot.
  Final local checks returned `401` from `https://127.0.0.1:55000/`, `401`
  from `https://127.0.0.1:9200/`, and `302` from `https://127.0.0.1/`.
- Agent list checked: OK after local repair. `043 MBP-PCZ` returned to
  `Active`.
- Local Mac agent checked: OK after route and launchd repair. The local Wazuh
  agent was installed at `/Library/Ossec` but stopped; stale host routes through
  OpenVPN interface `utun7` caused TCP 1514/1515 timeouts. Removing the
  `116.203.114.188/32` and `188.245.43.92/32` routes restored direct `en0`
  routing and port connectivity. A direct foreground `wazuh-agentd -fddd` test
  connected and received agent ACKs, and `launchctl kickstart -k
  system/com.wazuh.agent` then restored the normally supervised agent stack.
- Apt upgrade applied: Yes. Ran `apt-get update`, `apt-get upgrade`, and
  `apt-get full-upgrade`.
- Remaining apt upgrades checked: OK. No package upgrades remained after
  maintenance.
- Reboot requirement checked: OK. Rebooted into `6.8.0-134-generic`; no
  reboot marker remained afterward.

Package changes:

- Wazuh `4.14.6-1` for `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard`
- `iproute2` `6.1.0-1ubuntu6.4`
- `kpartx` and `multipath-tools` `0.9.4-5ubuntu8.2`
- `qemu-guest-agent` `1:8.2.2+ds-0ubuntu1.17`
- `linux-image-virtual` already installed at `6.8.0-134.134`; reboot moved
  the running kernel to `6.8.0-134-generic`

Notes:

- Recent warning logs are dominated by expected internet background noise:
  UFW blocks and failed root SSH attempts. `ufw limit` and fail2ban are active.
- Local workstation routes for both Hetzner public IPs initially pointed
  through OpenVPN interface `utun7` via `192.168.113.1`; removing those host
  routes restored direct `en0` routing.
- The dashboard returned temporary HTTP `503` for several minutes after reboot
  while the indexer and dashboard finished warming up. It later returned the
  normal HTTP `302`.
- Disk usage on the Wazuh host continues to climb: root moved from about 68%
  after the 2026-06-14 reboot to 76%, and the Wazuh data volume moved from
  about 54% to 62%.

Follow-up:

- Keep watching Wazuh disk growth before it crosses the comfort line.
- Watch for OpenVPN recreating stale Hetzner host routes; this has now caused
  Wazuh verification or agent connectivity trouble more than once.

## 2026-06-14 - June Maintenance

Date: 2026-06-14

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard` already at `4.14.5-1`
- `filebeat` package: `7.10.2-2`
- `systemctl --failed` reported 0 failed units before maintenance.
- `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` were
  active before maintenance.
- Root filesystem was about 70% used; Wazuh data volume was about 54% used.
- Pending apt work included `apparmor`, `cloud-init`, `libapparmor1`, and
  `libxmlb2`.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Wazuh packages unchanged at `4.14.5-1`
- `filebeat` package unchanged at `7.10.2-2`
- Root filesystem after reboot: 75G total, 49G used, 24G free, 68% used.
- Wazuh data volume after reboot: 79G total, 40G used, 35G free, 54% used.
- Uptime at verification: about 8 minutes.

Checks:

- SSH checked: OK. `ssh format-wazuh` worked before reboot and after the local
  workstation's OpenVPN route to the host was removed.
- Firewall checked: OK. `ufw` remained active with inbound `443/tcp`,
  `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. `systemctl --failed` reported 0 failed units
  after maintenance.
- Disk checked: OK. Root and Wazuh indexer volume still have free space.
- Memory checked: OK. About 2.9 GiB remained available after reboot and swap
  use dropped to about 1 MiB.
- Wazuh deployment model checked: OK. Still package/systemd-managed; Docker,
  Compose, Swarm, and Portainer remain absent.
- Wazuh health checked: OK. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` are active. Final local checks returned
  `401` from `https://127.0.0.1:55000/`, `401` from
  `https://127.0.0.1:9200/`, and `302` to `/app/login` from
  `https://127.0.0.1/`. `agent_control -lc` showed `MBP-PCZ` as active
  agent `043`.
- Docker checked: OK. Still not installed.
- Portainer checked: OK by deployment evidence. Still not present.
- Public port exposure checked: Not re-run externally during this pass; local
  endpoint and listening behavior remained consistent with the documented
  exposure model.
- Apt upgrade applied: Yes. Ran `apt-get update`, `apt-get upgrade`, and
  `apt-get full-upgrade`.
- Remaining apt upgrades checked: OK. No packages remained upgradable after the
  maintenance pass.
- Reboot requirement checked: OK. `apparmor` required a reboot after the
  package run; no reboot was required after the reboot.

Notes:

- Ubuntu package maintenance updated AppArmor packages to
  `4.0.1really4.0.1-0ubuntu0.24.04.7`, `cloud-init` to
  `26.1-0ubuntu1~24.04.1`, and `libxmlb2` to
  `0.3.24-1~ubuntu0.24.04.1`. Wazuh application package versions did not
  change in this pass.
- `apparmor.postinst` printed `Illegal number: yes` while reloading profiles,
  but apt completed successfully and `apparmor.service` was active after
  reboot.
- During startup, the dashboard again returned temporary HTTP `503` while the
  indexer and saved-object migrations finished initializing. Once warm, it
  returned the normal HTTP `302` redirect to `/app/login`.
- Local OpenVPN routes initially made the host appear unreachable from the
  workstation after reboot; removing the `116.203.114.188/32` and
  `188.245.43.92/32` tunnel routes restored direct verification access.

Follow-up:

- Keep `043 MBP-PCZ` as the canonical Mac agent identity.
- Remember to remove or avoid the local OpenVPN host routes before future
  Wazuh/Hetzner verification checks.

## 2026-05-31 - End-Of-Month Maintenance

Date: 2026-05-31

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard` already at `4.14.5-1`
- `filebeat` package: `7.10.2-2`
- `systemctl --failed` reported 0 failed units before maintenance.
- `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` were
  active before maintenance.
- Root filesystem was about 68% used; Wazuh data volume was about 48% used.
- Pending apt work included `linux-libc-dev`, `snapd`, and a kept-back
  `linux-image-virtual` upgrade.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-124-generic`
- Wazuh packages unchanged at `4.14.5-1`
- `filebeat` package unchanged at `7.10.2-2`
- Root filesystem after reboot: 75G total, 49G used, 24G free, 68% used.
- Wazuh data volume after reboot: 79G total, 36G used, 40G free, 48% used.
- Uptime at verification: roughly 5 minutes when the full service checks were
  green.

Checks:

- SSH checked: OK. `ssh format-wazuh` worked before reboot, disappeared during
  reboot, then took a longer-than-usual recovery window before returning.
- Firewall checked: OK. `ufw` remained active with inbound `443/tcp`,
  `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. `systemctl --failed` reported 0 failed units
  after maintenance.
- Disk checked: OK. Root and Wazuh indexer volume still have free space.
- Memory checked: OK. Memory remained within the same general range after
  reboot; swap use dropped back to negligible levels.
- Wazuh deployment model checked: OK. Still package/systemd-managed; Docker,
  Compose, Swarm, and Portainer remain absent.
- Wazuh health checked: OK. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` are active. Final local checks returned
  `401` from `https://127.0.0.1:55000/`, `401` from
  `https://127.0.0.1:9200/`, and `302` to `/app/login` from
  `https://127.0.0.1/`. After Mac agent cleanup, `agent_control -lc` showed
  `MBP-PCZ` as active agent `043`.
- Docker checked: OK. Still not installed.
- Portainer checked: OK by deployment evidence. Still not present.
- Public port exposure checked: Not re-run externally during this pass; local
  endpoint and listening behavior remained consistent with the documented
  exposure model.
- Apt upgrade applied: Yes. Ran `apt-get update`, `apt-get upgrade`, and
  `apt-get full-upgrade`.
- Remaining apt upgrades checked: OK. No packages remained upgradable after the
  maintenance pass.
- Reboot requirement checked: OK. No reboot required after reboot.

Notes:

- Ubuntu package maintenance updated the host kernel to `6.8.0-124-generic`,
  `linux-libc-dev` to `6.8.0-124.124`, and `snapd` to
  `2.75.2+ubuntu24.04`, but Wazuh application package versions did not change
  in this pass.
- During startup, the dashboard again returned temporary HTTP `503` while the
  indexer and saved-object migrations finished initializing. Once warm, it
  returned the normal HTTP `302` redirect to `/app/login`.
- SSH remained unavailable longer than in the previous maintenance pass, but no
  manual repair was needed once the host completed its startup sequence.
- The Mac agent identity was normalized to `MBP-PCZ`: macOS `HostName`,
  `LocalHostName`, and runtime `hostname` now match, and Wazuh agent `043`
  is active as `MBP-PCZ`.
- Stale Wazuh agent records were removed: `040 p-65787` was registered on
  2026-04-30 but never connected, and `042 MBP-PCZ.local` was the prior Mac
  registration.
- `wazuh-agent.format.lu` remains the intended DNS-only Cloudflare hostname for
  Wazuh agents.

Follow-up:

- Continue using `wazuh-agent.format.lu` for agent enrollment and connectivity
  instead of the dashboard hostname.
- Keep `043 MBP-PCZ` as the canonical Mac agent identity.

## 2026-05-16 - Monthly Maintenance

Date: 2026-05-16

Maintainer: Codex with Peter

Host before:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-111-generic`
- Wazuh packages: `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard` already at `4.14.5-1`
- `filebeat` package: `7.10.2-2`
- `systemctl --failed` reported 0 failed units before maintenance.
- `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` were
  active before maintenance.
- Root filesystem was about 66% used; Wazuh data volume was about 43% used.
- Pending apt work included `distro-info-data`, `open-vm-tools`,
  `linux-libc-dev`, `libheif*`, and a kept-back `linux-image-virtual`
  upgrade.

Host after:

- OS: Ubuntu 24.04.4 LTS
- Running kernel: `6.8.0-117-generic`
- Wazuh packages unchanged at `4.14.5-1`
- `filebeat` package unchanged at `7.10.2-2`
- Root filesystem after reboot: 75G total, 47G used, 26G free, 65% used.
- Wazuh data volume after reboot: 79G total, 32G used, 44G free, 42% used.
- Uptime at verification: about 5 minutes.

Checks:

- SSH checked: OK. `ssh format-wazuh` worked before reboot, was briefly
  unavailable during startup, then returned normally.
- Firewall checked: OK. `ufw` remained active with inbound `443/tcp`,
  `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`.
- Fail2ban checked: OK. `fail2ban` and the `sshd` jail remained active.
- System health checked: OK. `systemctl --failed` reported 0 failed units
  after maintenance.
- Disk checked: OK. Root and Wazuh indexer volume still have free space.
- Memory checked: OK. Memory remained within normal range after reboot.
- Wazuh deployment model checked: OK. Still package/systemd-managed; Docker,
  Compose, Swarm, and Portainer remain absent.
- Wazuh health checked: OK. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` are active. Local checks returned
  `401` from `https://127.0.0.1:55000/`, `401` from
  `https://127.0.0.1:9200/`, and `302` to `/app/login?` from
  `https://127.0.0.1/` after warm-up. `agent_control -lc` showed active
  agents including `MBP-PCZ` as agent `041`.
- Docker checked: OK. Still not installed.
- Portainer checked: OK by deployment evidence. Still not present.
- Public port exposure checked: Not re-run externally during this pass; local
  listening shape remained consistent with the documented exposure model.
- Apt upgrade applied: Yes. Ran `apt-get update`, `apt-get upgrade`, and
  `apt-get full-upgrade`.
- Remaining apt upgrades checked: OK. No packages remained upgradable after the
  maintenance pass.
- Reboot requirement checked: OK. No reboot required after reboot.

Notes:

- Ubuntu package maintenance updated the host kernel and base OS packages, but
  Wazuh application package versions did not change in this pass.
- During startup, the dashboard temporarily returned HTTP `503` while the
  indexer finished initializing. Once warm, it returned the normal HTTP `302`
  redirect to `/app/login?`.
- SSH briefly returned `connection refused` during late boot before `sshd`
  finished coming back; no manual repair was needed.
- `wazuh-agent.format.lu` remains the intended DNS-only Cloudflare hostname for
  Wazuh agents.

Follow-up:

- Continue using `wazuh-agent.format.lu` for agent enrollment and connectivity
  instead of the dashboard hostname.

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

## 2026-05-03 - Bi-Monthly Maintenance

Date: 2026-05-03

Maintainer: Codex with Peter

Host before:

- Maintenance started via `ssh format-wazuh`.
- Remote host verified as `format-wazuh` at `116.203.114.188`.
- Pre-maintenance system state: Ubuntu 24.04.4 LTS, kernel
  `6.8.0-110-generic`, uptime 14 days 12 hours.
- `systemctl --failed` reported 0 failed units before maintenance.
- `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, and `filebeat` were
  active before maintenance.
- Firewall and fail2ban were active before maintenance.
- Docker remained absent; this is still a package/systemd Wazuh deployment.
- Available upgrades before maintenance:
  `iproute2`, `linux-image-virtual`, `linux-libc-dev`, `snapd`,
  `ubuntu-pro-client`, `ubuntu-pro-client-l10n`, `wazuh-manager`,
  `wazuh-indexer`, and `wazuh-dashboard`.
- No reboot was required before maintenance.

Maintenance performed:

- Ran `apt-get update`.
- Ran non-interactive `apt-get upgrade` with existing dpkg config preserved.
- First upgrade pass upgraded:
  `iproute2`, `linux-libc-dev`, `snapd`, `ubuntu-pro-client`,
  `ubuntu-pro-client-l10n`, `wazuh-manager`, `wazuh-indexer`, and
  `wazuh-dashboard`.
- `apt-get upgrade` kept back `linux-image-virtual`, so an `apt-get -s
  full-upgrade` simulation was run to confirm it would only advance the kernel
  meta-package and install the matching new kernel/modules.
- Ran non-interactive `apt-get full-upgrade` with existing dpkg config
  preserved.
- Full-upgrade installed `linux-modules-6.8.0-111-generic`,
  `linux-image-6.8.0-111-generic`, and upgraded `linux-image-virtual` to
  `6.8.0-111.111`.
- Rebooted the host with `systemctl reboot`.

Host after:

- Host returned over SSH as `format-wazuh`.
- Running kernel after reboot: `6.8.0-111-generic`.
- Uptime at post-reboot verification: approximately 1 minute.
- Root filesystem after reboot: `/dev/sda1`, 75G total, 44G used, 28G free,
  62% used.
- Hetzner volume after reboot: `/dev/sdb`, 79G total, 28G used, 47G free,
  38% used.
- Memory after reboot: 7.6Gi total, 4.4Gi used, 116Mi free, 3.4Gi buff/cache,
  3.2Gi available; swap 4.0Gi total, almost unused.

Checks:

- SSH checked: Yes. `format-wazuh` alias worked before and after reboot.
- Firewall checked: Yes. `ufw` active with the same allowed inbound ports:
  `443/tcp`, `1514/tcp`, `1515/tcp`, and rate-limited `22/tcp`, for IPv4 and
  IPv6.
- Fail2ban checked: Yes. `fail2ban` active; `sshd` jail active before and
  after reboot.
- System health checked: Yes. `systemctl --failed` reported 0 failed units
  before maintenance, after package upgrades, and after reboot.
- Disk checked: Yes. Root and Wazuh indexer volume have available space.
- Memory checked: Yes. Memory and swap state acceptable before and after
  maintenance.
- Wazuh deployment model checked: Yes. Still package/systemd-managed; Docker
  remains absent.
- Wazuh health checked: Yes. `wazuh-manager`, `wazuh-indexer`,
  `wazuh-dashboard`, and `filebeat` remained active after the package upgrades
  and again after reboot. `wazuh-control status` showed core manager services
  running. `agent_control -lc` listed the local manager and active enrolled
  agents. Wazuh API returned expected unauthenticated JSON. Indexer returned
  expected `Unauthorized`. Dashboard initially returned temporary HTTP 503
  during reboot warm-up, then returned normal HTTP 302 to `/app/login?`.
- Docker checked: Yes. `docker` command not found; no Docker Compose or Swarm
  present.
- Portainer checked: Yes by current deployment evidence. No Docker/Portainer
  deployment found.
- Public port exposure checked: Yes. Listening ports after reboot: SSH `22`,
  Wazuh enrollment `1515`, Wazuh agent events `1514`, dashboard `443`, Wazuh
  API local `127.0.0.1:55000`, and indexer local `127.0.0.1:9200`/`9300`.
- Apt upgrade applied: Yes.
- Remaining apt upgrades checked: Yes. None remained after full-upgrade and
  reboot.
- Reboot requirement checked: Yes. Reboot required after kernel install; no
  reboot required after the reboot completed.

Notes:

- Updated package versions verified after maintenance:
  `wazuh-manager 4.14.5-1`, `wazuh-indexer 4.14.5-1`,
  `wazuh-dashboard 4.14.5-1`, `filebeat 7.10.2-2`,
  `linux-image-virtual 6.8.0-111.111`, `linux-image-6.8.0-111-generic
  6.8.0-111.111`, `snapd 2.74.1+ubuntu24.04.4`, `iproute2 6.1.0-1ubuntu6.3`,
  and `ubuntu-pro-client 37.2ubuntu~24.04`.
- Dashboard logs again showed expected startup-time OpenSearch connection
  errors while the indexer was still coming up after reboot. The dashboard
  recovered and returned the normal login redirect after warm-up.
- The only `journalctl -b -p err..alert` entry after reboot was an SSH
  brute-force attempt that exhausted auth tries for an invalid user.
- No Docker cleanup, Wazuh data cleanup, or backup manipulation was performed.

Follow-up:

- Next routine maintenance should start from Wazuh `4.14.5` and kernel
  `6.8.0-111-generic` as the current baseline.
- Continue watching public dashboard exposure on `443/tcp`; the service is
  protected by authentication and UFW but still receives regular internet scan
  traffic.

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
