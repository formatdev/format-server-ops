# ESST Cloud X Swarm Analysis

Date: 2026-04-19

Maintainer: Codex with Peter

Scope: read-only discovery from `esst-cloud-1`.

## Executive Summary

The four servers.com VPS hosts are part of one Docker Swarm cluster.

`esst-cloud-1` is reachable over SSH and is a Swarm worker. Docker reports the
Swarm manager as `192.168.0.14:2377`, which matches `esst-cloud-4`.

`esst-cloud-2`, `esst-cloud-3`, and `esst-cloud-4` are visible on the private
network and participate in Swarm overlay networking, but SSH on TCP/22 currently
times out from both this workstation and from `esst-cloud-1`.

## Node Map

| Host | Public IP | Private IP | Observed role | SSH status |
| --- | --- | --- | --- | --- |
| `esst-cloud-1` | `188.42.62.40` | `192.168.0.101` | Swarm worker | Works as `cloud-user` |
| `esst-cloud-2` | `188.42.62.39` | `192.168.0.5` | Swarm node, likely worker | TCP/22 times out |
| `esst-cloud-3` | `188.42.62.60` | `192.168.0.20` | Swarm node, likely worker | TCP/22 times out |
| `esst-cloud-4` | `172.255.248.244` | `192.168.0.14` | Swarm manager | TCP/22 times out |

Evidence from `docker info` on `esst-cloud-1`:

```text
Swarm: active
NodeID: omv3t5ltzu3fme2blec5tdwlu
Is Manager: false
Node Address: 192.168.0.101
Manager Addresses:
 192.168.0.14:2377
```

## Control Plane

`esst-cloud-4` is the active Swarm manager endpoint from the worker's point of
view. Port checks from `esst-cloud-1` show:

| Private IP | Open ports observed |
| --- | --- |
| `192.168.0.101` | `22`, `7946`, `58917` |
| `192.168.0.5` | `7946` |
| `192.168.0.20` | `7946` |
| `192.168.0.14` | `443`, `2377`, `7946` |

Interpretation:

- `2377` on `192.168.0.14` is Docker Swarm manager traffic.
- `7946` on all nodes is Docker Swarm gossip/control traffic.
- `443` on `192.168.0.14` returns an HTTP/2 404 consistent with a reverse proxy
  such as Traefik handling HTTPS without a matching host rule.
- `58917` is published on `esst-cloud-1` by `esst-monitoring-lwp-bridge`.

## Portainer

`esst-cloud-1` runs a Portainer agent task:

```text
stack=portainer
service=portainer_agent
image=portainer/agent:2.33.6
AGENT_CLUSTER_ADDR=tasks.portainer_agent
```

The agent has access to:

```text
/var/run/docker.sock
/var/lib/docker/volumes
```

This is a standard Portainer Swarm agent layout. The Portainer server container
itself is not on `esst-cloud-1`; it is likely placed on `esst-cloud-4`, because
that node is the Swarm manager and exposes HTTPS.

## Overlay Networks

Overlay network peer membership observed from `esst-cloud-1`:

| Network | Peers |
| --- | --- |
| `ingress` | `192.168.0.14`, `192.168.0.5`, `192.168.0.20`, `192.168.0.101` |
| `portainer_agent_network` | `192.168.0.14`, `192.168.0.5`, `192.168.0.20`, `192.168.0.101` |
| `proxy` | `192.168.0.14`, `192.168.0.5`, `192.168.0.101` |
| `esst-monitoring-production_internal` | `192.168.0.5`, `192.168.0.20`, `192.168.0.101` |
| Most local app internal networks | `192.168.0.101` only |

Interpretation:

- All four nodes are part of the Swarm.
- Portainer agent networking spans all four nodes.
- The public proxy network currently spans manager `esst-cloud-4`, worker
  `esst-cloud-2`, and worker `esst-cloud-1`; `esst-cloud-3` does not currently
  appear as a `proxy` peer.
- `esst-monitoring-production` appears to be spread across workers
  `esst-cloud-1`, `esst-cloud-2`, and `esst-cloud-3`.

## Local Workload On esst-cloud-1

Running local Swarm tasks observed on `esst-cloud-1`:

| Stack | Services observed locally |
| --- | --- |
| `esst-monitoring-beta` | `app`, `mariadb` |
| `esst-monitoring-dev` | `app`, `mariadb` |
| `esst-monitoring-lwp-bridge` | `app` |
| `esst-vaultwarden` | `bitwarden` |
| `esst-vtiger` | `vtiger`, `mysql` |
| `esst-website` | `wordpress`, `mariadb` |
| `gotenberg` | `gotenberg` |
| `n8n` | `app` |
| `phpmyadmin` | `phpmyadmin` |
| `portainer` | `agent` |
| `redis` | `redis` |
| `smtp-dev` | `smtp` |

Notable images observed locally:

- `portainer/agent:2.33.6`
- `vaultwarden/server:1.35.2`
- `docker.n8n.io/n8nio/n8n:stable`
- `esst/php:5.6-apache`
- `mysql:5.5`
- `wordpress:6.7-php8.3-apache`
- `mariadb:10.11.8`
- `mariadb:11.4`
- `phpmyadmin/phpmyadmin:latest`
- `gotenberg/gotenberg:8`

## Data Placement On esst-cloud-1

Local bind mounts observed:

| Stack/service | Host path | Container path |
| --- | --- | --- |
| `esst-vaultwarden_bitwarden` | `/data/files/esst/bitwarden/data` | `/data` |
| `esst-vtiger_mysql` | `/data/database/esst/vtiger` | `/var/lib/mysql` |
| `esst-vtiger_vtiger` | `/data/files/esst/vtiger/html` | `/var/www/html` |
| `esst-website_mariadb` | `/data/database/esst/website` | `/var/lib/mysql` |
| `esst-website_wordpress` | `/data/files/esst/website/wp-content` | `/var/www/html/wp-content` |
| `n8n_app` | `/data/files/esst/n8n` | `/home/node/.n8n` |
| `n8n_app` | `/opt/esst/ftp` | `/opt/esst` |

Local Docker volumes observed:

- `esst-monitoring-beta_mariadb`
- `esst-monitoring-beta_oauth`
- `esst-monitoring-beta_uploads`
- `esst-monitoring-dev_mariadb`
- `esst-monitoring-dev_oauth`
- `esst-monitoring-dev_uploads`
- `esst-website_wordpress`
- `n8n_data`
- `redis_data`
- `smtp-dev_data`

## Immediate Risk

`esst-cloud-1` root filesystem is nearly full:

```text
/dev/vda1  113G  106G  2.1G  99% /
```

Docker reports reclaimable space:

```text
Images: 46.29GB total, 12.8GB reclaimable
Containers: 7.63GB total, 7.084GB reclaimable
```

Do not prune volumes or bind-mounted application data without a backup plan.
The likely first cleanup candidate is stopped containers and unused images, but
that should be confirmed from the Swarm manager before any action.

## Open Questions

- Why is SSH closed or filtered on `esst-cloud-2`, `esst-cloud-3`, and
  `esst-cloud-4`?
- What hostname routes are configured in the reverse proxy on `esst-cloud-4`?
- Where exactly is the Portainer server task placed, and what data path backs
  it?
- Are stack definitions stored only in Portainer, or are any deployed from Git?
- Which node backs up `/data` and Docker named volumes?

## Recommended Next Steps

1. Restore or confirm SSH access to `esst-cloud-4` first, because it is the
   Swarm manager.
2. From `esst-cloud-4`, run `docker node ls`, `docker service ls`, and
   `docker stack ls`.
3. Export or document Portainer stack definitions before making changes.
4. Plan disk cleanup for `esst-cloud-1`, starting with stopped containers and
   unused images only after confirming running services and backup coverage.
5. Review firewall policy for public SSH and private SSH between Swarm nodes.
