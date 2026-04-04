# Repo Vs Live

This file records the remaining mismatch between the repository and the audited live VM.

## Live VM

Observed on `2026-04-04`:

- multiple active compose projects
- two separate Paperless instances
- Docker named volumes
- Traefik using the `proxy` network
- Portainer published directly on host ports
- AI-related services already running

## Repo State Now

The repo now contains sanitized versions of the observed live compose stacks for:

- Traefik
- Paperless work instance
- Paperless PCZ instance
- shared Paperless helpers
- Ollama
- Paperless GPT

Secrets have been removed and replaced with env-template placeholders.

## Important Conclusion

The repo is now much closer to the live VM, but it is not yet guaranteed to be the deployment source of truth.

Remaining gaps:

- the live host is still likely running Portainer-internal stack copies
- TLS handling in Traefik still looks transitional and should be reviewed
- backup and restore procedures for the current named-volume layout still need to be documented properly

Until that reconciliation is finished, treat the repo as an audited and partially recovered source of truth rather than the final authoritative deployment source.
