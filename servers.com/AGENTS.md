# ESST Maintenance Conventions

The operator has selected private `esstdev/esst-infrastructure` as the canonical
home for ESST topology, maintenance procedures and new intervention logs.
This directory retains historical records and local access/verification aids.
Do not maintain a competing current topology or duplicate new intervention logs.

## Read Before Each Intervention

Read the current versions in `esstdev/esst-infrastructure`, not just this summary:

- `README.md` and `CLAUDE.md`: ownership, documentation and execution conventions.
- `servers/estate.md`: canonical roles, paths, reboot order and network exposure.
- `servers/access.md`: access procedure.
- `runbooks/maintenance-checklist.md`: pre-upgrade and recurring checks.
- `runbooks/backups.md`: per-intervention backups and recurring restore checks.
- `logs/_template.md`: required intervention record.
- Relevant application runbook, recent logs and existing open issues.

Use an existing checkout or the authenticated GitHub CLI, for example:

```sh
gh api repos/esstdev/esst-infrastructure/contents/runbooks/maintenance-checklist.md \
  -H 'Accept: application/vnd.github.raw+json'
```

Read any additional applicable instructions in a checkout before editing it.
Conventions reviewed on 2026-09-21 at upstream commit
`370b4a7fb3da42d39d6ea216c6a4a22d0505b0ab`; refresh them each time.

## Planning And Execution

- Start read-only and verify the live topology, paths, image digests, active
  backups, resource use and firewall. Repository descriptions can be stale;
  record discrepancies and correct the owning reference using verified facts.
- Upstream defaults to proposing production changes for operator execution.
  An explicit user request to execute authorizes the named scope; do not ask
  again for actions already authorized. Establish missing window/notification
  details before disruption. Never send stakeholder messages without permission.
- Before any service restart/version change, record the agreed window and
  notification status, baseline, fresh stateful backups, exact target version,
  rollback commands/paths, rollback trigger and maximum recovery time.
- Stateful backups include data-volume/state-directory archives, database dumps,
  app-native exports where supported, and the required secure offline copy.
  Vault exports stay encrypted and outside Git. Do not mark unavailable or
  unperformed checks complete. Do not interrupt active database backups.
- Follow the current estate reboot order: data tier, production app tier, other
  apps, ingress/manager last (currently 3 -> 2 -> 1 -> 4). Verify recovery between
  hosts. Record any necessary departure from this sequence and its reason.
- Pin production image tags/digests; never deploy `latest`. Check floating tags
  before host maintenance too, since recreated tasks may fetch new images.
  Read release notes, change one application per window, and keep the running
  service and authoritative Portainer/compose definition in sync.
- Restore/verify custom firewall rules after every host/Docker restart using
  upstream scope and the local `firewall-maintenance.md` verification procedure.
  Confirm the allowed SSH source, snapshot rules, prepare timed rollback, test
  fresh allowed SSH and blocked paths, then cancel rollback after recovery.
- Diagnose replica failures before forcing restarts. Review pruning candidates
  against rollback requirements; an unused image may still be needed to revert.
- Verify equal Docker versions, node/manager health, service replicas, logs,
  affected applications and authenticated critical flows. HTTP redirects alone
  do not prove application health. Record any unverified flow explicitly.
- A complete recurring backup check includes Duplicati, provider backups, NAS
  receipt/capacity and an actual restore on the NAS. Metadata alone is partial.

## Records And Boundaries

- Open `logs/YYYY-MM-DD-short-description.md` from the upstream template before
  execution and update it as work proceeds, with local-time timestamps/timezone,
  commands, results, failures, before/after versions and verification evidence.
- Write facts concisely and use operator roles, not personal names. Keep reusable
  procedures in their owning runbooks and topology in `servers/estate.md`.
- Files record completed work; issues track unresolved work. Check for existing
  issues before creating remediation tickets and link them from log follow-ups.
  Do not create issues merely to record a completed maintenance window.
- Keep infrastructure details and credentials out of client-deployed
  `esstdev/monitoring`. Never commit secrets, vault exports or sensitive backups.
- Preserve historical logs; any later backfill must identify its retrospective
  source and unknown checks/times. Do not fabricate contemporaneous evidence.
- Keep ESST work separate from Format/Hetzner/on-premise changes. Stage only the
  intended files and publish within the user's authorized scope.
