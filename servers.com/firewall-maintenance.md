# ESST Firewall Maintenance

Verified September 13, 2026, following Ivan's report that weekend reboots remove
the host restrictions. These checks are required after every host reboot and
Docker restart, even when UFW is inactive and all applications appear healthy.

## Current Policy

| Host | Scripts in /opt/esst/deployment/ | SSH source policy |
| --- | --- | --- |
| cloud-1 | iptables-general.sh | Office 217.31.68.238 only |
| cloud-2 | iptables-general.sh | Office plus existing exceptions below |
| cloud-3 | iptables-general.sh | Office plus existing exceptions below |
| cloud-4 | iptables-general.sh and iptables-cloudflare.sh | Office only |

Cloud-2 and cloud-3 also allow SSH from `146.190.226.171`, `85.10.99.123`,
`167.99.196.254` and `67.207.71.241`. Ownership/purpose was not established in
this review; these existing exceptions were preserved. Their SSH chain also
covers TCP 25. Cloud-2/3/4 have additional broad INPUT source accepts, but these
occur after the SSH and Swarm protection hooks and do not override their drops.

The general scripts restrict Swarm TCP 2376/2377/7946 and UDP 7946/4789,
permitting private networks and host-specific exceptions. Swarm advertises
192.168.0.101, 192.168.0.5, 192.168.0.20 and 192.168.0.14; cloud-4 is leader.

Cloud-4's Cloudflare script restricts forwarded TCP/UDP 443 in DOCKER-USER to
Cloudflare IPv4 ranges and private sources. Public websites remain available
through Cloudflare; direct-origin HTTPS is blocked, including from the office.
Use the actual Traefik placement rather than assuming it will always be cloud-4.

These are IPv4 rules. No public global IPv6 address was present on the four
hosts during this review; recheck IPv6 if networking changes.

## Procedure

1. Inspect the current scripts, `iptables -S`, `ip6tables -S`, public interfaces,
   Swarm addresses and Traefik placement. Check `$SSH_CONNECTION`; the current
   source must be allowed before restoring restrictions.
2. Keep the SSH session open. Save `iptables-save` output in a uniquely dated,
   root-only backup directory. Arrange a short timed rollback using
   `systemd-run --on-active=3m` with `iptables-restore` and that snapshot.
3. Run `sudo bash /opt/esst/deployment/iptables-general.sh` on one host at a time
   when its expected chains/hooks are missing. These legacy scripts have a
   malformed shebang, so invoke them explicitly with Bash.
4. On the Traefik host, verify the official Cloudflare IPv4 list is reachable,
   nonempty and contains valid CIDRs, then run
   `sudo bash /opt/esst/deployment/iptables-cloudflare.sh` after Docker is active.
5. Inspect `ssh-protection`, `docker-swarm-only`, their INPUT hooks, and on the
   Traefik host `cloudflare-only` with both DOCKER-USER hooks. Confirm final DROP
   rules and the expected allowlists, not merely the scripts' exit statuses.
6. Open a fresh non-multiplexed SSH connection from the office/VPN. Check Swarm
   nodes, service replicas and public application responses. On cloud-4, check
   that ordinary Cloudflare HTTPS works and direct-origin HTTPS times out.
   Then cancel the rollback timer and confirm it is inactive.
7. From a controlled non-allowed source, test TCP 22 without attempting a login.
   Confirm timeout and an increase in the target's SSH drop counter. Record the
   results and save an after-state snapshot. Do not disconnect the user's VPN
   or change workstation routes just to perform this test.

Initial cleanup commands can report missing chains after reboot. The legacy
scripts continue and create them; verify the resulting rules. Re-running them
blindly can duplicate broad source-accept rules. They should be made idempotent
before being wired into automatic service startup.

Do not restore a full Docker-generated iptables snapshot automatically at boot:
Docker's dynamic container addresses and rules can change. A durable solution
should load only the custom policy, with correct Docker startup ordering and
validated/cached Cloudflare ranges so a failed download cannot empty the allowlist.

## September 13 Restoration

- Custom INPUT and Cloudflare restrictions were absent on all relevant hosts.
  No netfilter-persistent service or startup hook was found in the inspected
  systemd/cron/network/rc.local locations. Automatic persistence remains pending.
- Restored each existing general script; restored Cloudflare on cloud-4 only.
  No script contents or allowlist policy changed.
- Root-only snapshots: `/root/firewall-backups/2026-09-13/before.v4` and
  `after.v4` on each host. Temporary rollback timers were canceled after checks.
- Fresh office SSH worked on all four. Cloud-4-to-workers and cloud-1-to-cloud-4
  public SSH probes timed out; SSH drop counters increased on all four targets.
- Direct HTTPS to cloud-4 timed out and Cloudflare DROP counters increased.
  Monitoring returned 302; website, GlitchTip and Vaultwarden returned 200
  through their normal public URLs. Four Swarm nodes remained Ready, agents
  4/4 and active application services 1/1.
- `esst-monitoring-lwp-bridge_app` publishes TCP 58917 on cloud-1. That port is
  outside these scripts' restrictions and was not changed. Confirm its intended
  clients before adding an allowlist. Disabled SFTP retains a published ingress
  port 63745 in its service configuration but has zero replicas.

References: [Docker iptables behavior](https://docs.docker.com/engine/network/firewall-iptables/)
and [Cloudflare's IPv4 ranges](https://www.cloudflare.com/ips-v4/).
