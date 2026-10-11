# ESST Cloud X Runbook

Local historical records and verification aids for the servers.com ESST fleet.

Last updated: 2026-09-21

## Canonical Conventions

Use [esstdev/esst-infrastructure](https://github.com/esstdev/esst-infrastructure)
for current topology, procedures and new maintenance records. Read its current
conventions before each intervention, as described in [AGENTS.md](AGENTS.md).
Historical logs here remain unchanged; they have not been migrated.

- [Canonical estate](https://github.com/esstdev/esst-infrastructure/blob/main/servers/estate.md)
- [Maintenance checklist](https://github.com/esstdev/esst-infrastructure/blob/main/runbooks/maintenance-checklist.md)
- [Backup requirements](https://github.com/esstdev/esst-infrastructure/blob/main/runbooks/backups.md)
- [Intervention log template](https://github.com/esstdev/esst-infrastructure/blob/main/logs/_template.md)

The canonical reboot order is currently 3 -> 2 -> 1 -> 4. Verify live state,
prepare backups and rollback, pin production images, and check recovery between
hosts. New logs belong in upstream `logs/YYYY-MM-DD-short-description.md`;
unresolved work belongs in linked issues, not completed-maintenance issues.

## Host Folders

- [esst-cloud-1](esst-cloud-1/README.md)
- [esst-cloud-2](esst-cloud-2/README.md)
- [esst-cloud-3](esst-cloud-3/README.md)
- [esst-cloud-4](esst-cloud-4/README.md)
- [swarm-analysis-2026-04-19.md](swarm-analysis-2026-04-19.md): historical first-pass topology analysis

## Access

Local SSH aliases have been prepared:

```sh
ssh esst-cloud-1
ssh esst-cloud-2
ssh esst-cloud-3
ssh esst-cloud-4
```

Local key files:

```text
~/.ssh/esst-cloud-1
~/.ssh/esst-cloud-2
~/.ssh/esst-cloud-3
~/.ssh/esst-cloud-4
```

The servers use `cloud-user` for SSH access. On September 13, 2026, fresh SSH
connections worked to all four hosts from the office egress IP `217.31.68.238`.
The custom iptables rules restrict SSH by source IP, including private-network
SSH. Cloud-2 and cloud-3 have additional existing exceptions.

See [Firewall Maintenance](firewall-maintenance.md) for the exact policy and
the mandatory checks after every reboot or Docker restart. An inactive UFW
does not establish whether these custom iptables rules are present.

## Baseline Inspection Commands

These commands are aids, not a substitute for the canonical pre-upgrade
checklist. Production changes default to an operator-executed plan unless the
user explicitly authorizes execution. Do not start a service-changing command
until its window, backups, pinned targets and rollback have been addressed.

For each host:

```sh
ssh esst-cloud-1
hostnamectl
ip -brief address
uptime
free -h
df -h
systemctl --failed
sshd -T | grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|maxauthtries|logingracetime) '
```

If Docker is present:

```sh
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
docker compose ls
docker system df
```

Package maintenance:

```sh
apt update
apt list --upgradable
apt upgrade
test -f /var/run/reboot-required && cat /var/run/reboot-required
test -f /var/run/reboot-required.pkgs && cat /var/run/reboot-required.pkgs
```

## Required Post-Restart Firewall Check

Maintenance is not complete until the custom firewall rules have been verified
and, when missing, restored:

- All four hosts: `/opt/esst/deployment/iptables-general.sh`.
- Traefik host only (currently cloud-4): also
  `/opt/esst/deployment/iptables-cloudflare.sh`, after Docker is running.
- Confirm the current SSH source is allowed, snapshot the rules and prepare
  timed rollback before applying them. Keep the existing session open and test
  a fresh SSH connection before canceling rollback.
- Verify the rule chains and hooks, all Swarm nodes/services, permitted office
  SSH, blocked non-allowed SSH, Cloudflare access and blocked direct-origin HTTPS.
- Record evidence in the canonical intervention log. Check published Docker ports
  separately; these scripts do not impose a blanket office-only firewall.

No automatic boot restoration was found or installed as of September 13, 2026.
Follow the [firewall runbook](firewall-maintenance.md) after every restart.

## Safety Rules

- Treat all four hosts as production until their role is confirmed.
- Do not delete Docker volumes, bind mounts, application data, databases, or
  firewall rules without first recording current state.
- Keep at least one working SSH path before changing `sshd_config`.
- Do not commit private keys, provider tokens, server passwords, or Bitwarden
  secure note contents into this repository.
- Record new work in `esst-infrastructure/logs/` using its current template.
