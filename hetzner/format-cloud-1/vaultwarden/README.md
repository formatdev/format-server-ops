# Vaultwarden On format-cloud-1

This folder documents the Vaultwarden container hosted through Portainer on the Hetzner server `hetzner-cloud-1`.

Vaultwarden is security-sensitive because it stores password-manager data. Keep operational notes here, but never commit real secrets, admin passwords, invite links, backup keys, or full production hashes unless they are already intentionally public and rotated.

## Live Service

- service: Vaultwarden
- server: `hetzner-cloud-1`
- placement constraint: `node.hostname == format-cloud-1`
- public URL: `https://bitwarden.format.lu`
- reverse proxy: Traefik on external Docker network `proxy`
- Cloudflare: in front of the public hostname
- data path: `/data/files/vaultwarden/data:/data`
- current target image: `ghcr.io/dani-garcia/vaultwarden:1.35.7`

## Current Decisions

- Use the upstream GHCR image instead of the older Docker Hub image name.
- Pin the image version instead of using `latest`.
- Disable public signup with `SIGNUPS_ALLOWED=false`.
- Store the real admin password in Bitwarden.
- Store only the Argon2 admin-token hash in the Portainer stack.
- Escape `$` characters as `$$` when the Argon2 hash is stored in YAML.
- Treat any admin token pasted into chat, tickets, screenshots, or docs as compromised and rotate it.
- Check `/data/config.json` after changes because Vaultwarden admin UI settings can override stack environment variables.

## What The Admin Token Is

`ADMIN_TOKEN` protects the Vaultwarden `/admin` page only.

It is not:

- a user vault password
- the database encryption key
- the normal login password for `https://bitwarden.format.lu`

Rotating `ADMIN_TOKEN` does not break existing user vault logins. It only changes the password required to access `/admin`.

## Admin Token Rotation

1. Generate a strong new admin password in Bitwarden.
2. Save the plain password in Bitwarden.
3. Generate the Argon2 hash:

```bash
docker run --rm -it ghcr.io/dani-garcia/vaultwarden:1.35.4 /vaultwarden hash
```

4. Paste the plain password when prompted.
5. Copy the generated Argon2 hash.
6. In the Portainer stack, set `ADMIN_TOKEN` to the hash, not the plain password.
7. Escape every `$` as `$$` in YAML.
8. Redeploy the stack.
9. Test `/admin` using the plain password stored in Bitwarden.

Example shape:

```yaml
- ADMIN_TOKEN=$$argon2id$$v=19$$m=65540,t=3,p=4$$...
```

## Signup Policy

`SIGNUPS_ALLOWED=false` means new public account creation is disabled.

This is the safer default for a private or company-managed Vaultwarden instance. Existing users can still log in normally. Admin access still works. User onboarding should be handled deliberately through the admin workflow rather than open registration.

If Vaultwarden logs say `data/config.json` is overriding `SIGNUPS_ALLOWED`, change the setting in `/admin` or update the persisted config. The active setting is the one from `data/config.json`, not the Portainer environment variable.

## Reverse Proxy Notes

The current stack uses Traefik labels for HTTPS routing:

- host rule: `Host(`bitwarden.format.lu`)`
- entrypoint: `websecure`
- certificate resolver: `letsencrypt`
- backend container port: `80`
- middleware chain: `secure-chain,gzip`

Cloudflare protects the public hostname, but it should be treated as one layer only. The recommended defense-in-depth setup is:

- strong hashed `ADMIN_TOKEN`
- `SIGNUPS_ALLOWED=false`
- Cloudflare in front
- Traefik or Cloudflare Access restriction for `/admin` if practical
- firewall/origin rules so direct access to the Hetzner origin is limited where possible

## Maintenance Cadence

Run one combined maintenance check twice per month when requested:

- on the 15th of the month
- on the last day of the month

Each run includes health checks, log review, backup verification, release checks, and safe updates if needed.

## Combined Maintenance Checklist

Use this checklist for both monthly runs.

1. Confirm the container is running and healthy in Portainer.
2. Check the currently deployed image tag.
3. Check the latest Vaultwarden release and read release notes before any bump.
4. Review Vaultwarden logs for login errors, database errors, SMTP errors, admin access attempts, and unusual IP patterns.
5. Review Traefik logs for routing errors, TLS errors, certificate issues, and repeated `/admin` access attempts.
6. Confirm `https://bitwarden.format.lu` loads normally.
7. Confirm normal user login works.
8. Confirm `/admin` works with the admin password stored in Bitwarden.
9. Confirm `SIGNUPS_ALLOWED=false` is still set.
10. Confirm `data/config.json` is not overriding `SIGNUPS_ALLOWED` back to `true`.
11. Confirm `ADMIN_TOKEN` is still stored as an Argon2 hash and not as a plain password.
12. Confirm Vaultwarden startup logs do not warn about a plain text `ADMIN_TOKEN`.
13. Confirm Cloudflare protection is active for `bitwarden.format.lu`.
14. Confirm direct origin access is not accidentally exposed, if practical.
15. Confirm `/data/files/vaultwarden/data` is included in backups.
16. Confirm the latest backup exists and is recent.
17. If an update is needed, confirm a fresh backup exists before changing the image tag.
18. If an update is applied, redeploy through Portainer and watch logs immediately after startup.
19. After any update, test normal login, `/admin`, and browser extension or mobile sync if practical.
20. Record the result in [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/vaultwarden/maintenance-log.md).

## Files

- [stack.example.yml](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/vaultwarden/stack.example.yml): sanitized Portainer stack reference
- [maintenance-log.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/vaultwarden/maintenance-log.md): ongoing maintenance history
