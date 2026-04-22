# Traefik On format-cloud-1

This folder documents the Traefik container hosted through Portainer on the Hetzner server `hetzner-cloud-1`.

Traefik is the public ingress layer for this host. Treat changes carefully because a broken Traefik deployment can affect every routed application on the platform.

## Live Service

- service: Traefik
- server: `hetzner-cloud-1`
- Docker service: `traefik_traefik`
- public dashboard hostname in labels: `traefik.format.lu`
- current live image: `traefik:3.6.13`
- live replica state during documentation: `1/1`
- shared Docker network: `proxy`
- published ports: `443/tcp` and `443/udp`
- internal HTTP entrypoint: `:80`
- HTTPS entrypoint: `:443`
- provider: Docker Swarm
- provider network: `proxy`
- certificates: Let's Encrypt using Cloudflare DNS challenge
- ACME storage: `/data/traefik/certificates:/letsencrypt`
- access logs: `/data/traefik/logs:/var/log`
- Docker socket mount: `/var/run/docker.sock:/var/run/docker.sock`

## Current Decisions

- Use a pinned Traefik image tag instead of `latest`.
- Keep Swarm provider enabled with `exposedByDefault=false`.
- Route containers only through explicit Traefik labels.
- Use the shared external `proxy` network for routed services.
- Keep ACME storage on persistent host storage.
- Keep access logs on persistent host storage.
- Review Traefik logs during each Hetzner platform maintenance run because Traefik errors can signal broken certificates or broken routing before users report issues.

## Current Live Arguments

The live service currently uses these important arguments:

```text
--entrypoints.web.address=:80
--entrypoints.websecure.address=:443
--entrypoints.websecure.http3
--providers.swarm=true
--providers.swarm.watch=true
--providers.swarm.network=proxy
--providers.swarm.exposedByDefault=false
--providers.swarm.endpoint=unix:///var/run/docker.sock
--api=false
--api.insecure=false
--api.dashboard=false
--certificatesresolvers.letsencrypt.acme.dnschallenge=true
--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare
--certificatesresolvers.letsencrypt.acme.email=server@esst.lu
--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
--log.level=ERROR
--accesslog=true
--accesslog.filepath=/var/log/access.log
--accesslog.bufferingsize=500
--accessLog.filters.statusCodes=400-599
```

## Known Issues

- The live service is running `traefik:3.6.13`, but the Swarm stack image label still says `traefik:3.6.6`. This can happen after image updates and should be cleaned up when the stack is next reconciled through Portainer.
- Traefik logs show repeated ACME renewal errors for `novaculture.lu` and `www.novaculture.lu`. The error says the Cloudflare DNS challenge cannot find the expected zone.
- Traefik labels still define a router for `traefik.format.lu` pointing to `api@internal`, but `--api=false` and `--api.dashboard=false` are set. This causes repeated `api is not enabled` log errors when the dashboard route is accessed.
- The live Traefik service currently publishes `443`, but the inspected live port output did not show host port `80` published. Confirm whether HTTP-to-HTTPS redirects are intentionally handled elsewhere before changing this.

## Dashboard Policy

The current live configuration disables the Traefik API and dashboard:

```text
--api=false
--api.insecure=false
--api.dashboard=false
```

If the dashboard should stay disabled, remove or disable the `traefik.format.lu` router labels to stop `api is not enabled` errors.

If the dashboard should be enabled, protect it with strong authentication and preferably Cloudflare Access or IP allowlisting before enabling `api@internal`.

## Maintenance Cadence

Run Traefik checks as part of the combined Hetzner platform maintenance run on the 15th and the last day of each month when requested.

Use this checklist:

1. Confirm `traefik_traefik` is running `1/1`.
2. Confirm the running image tag.
3. Check the latest Traefik release before any image bump.
4. Review Traefik service logs for `ERR`, `WRN`, ACME, TLS, certificate, and provider errors.
5. Review access logs for repeated `4xx`/`5xx` patterns on sensitive routes such as `/admin`.
6. Confirm routed applications still return expected HTTP statuses.
7. Confirm Let's Encrypt certificate renewal is healthy for active domains.
8. Confirm `proxy` network membership includes Traefik and expected routed services.
9. Confirm ACME storage exists and is persisted.
10. Confirm log storage exists and is persisted.
11. Confirm Docker socket mount is still read/write only if required; prefer least privilege where practical.
12. If an update is applied, redeploy through Portainer and watch logs immediately after startup.
13. After any update, test at least one public routed service and one internal Traefik host-header route.
14. Record the result in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/traefik/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/traefik/stack.example.yml): sanitized live-style Portainer stack reference
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/traefik/maintenance-log.md): ongoing maintenance history
