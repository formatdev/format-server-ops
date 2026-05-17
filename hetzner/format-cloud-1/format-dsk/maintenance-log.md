# format-dsk Maintenance Log

Use this log for `format-dsk` checks during the combined Hetzner platform maintenance run on the 15th and the last day of each month.

Do not record credentials, tokens, customer data, or other secrets here.

## 2026-05-03 - Twice-Monthly Check

Date: 2026-05-03 08:31 CEST

Maintainer: Codex with Peter

Repo/ref checked: `/Users/czibulapeter/Documents/GitHub/dsk`, branch `main`, commit `2648029f0df71a304a227a55380bc80f01ce6d7b`

Source commit recorded: Yes

Dependency freshness checked: Partial. The live Dockerfiles currently use
`php:8.4-apache-bookworm` for both PM and TIM, but the local Docker daemon was
not available on this workstation, so the base-image freshness pull/inspect step
was not completed.

Dependency updates available: Not confirmed in this run.

Stack version before: `esst/format-dsk-pm:1.0.0@sha256:03a1e4226effdffedaac89519c2b2e7bb572c2ac1979ac7e9d7577bc98568c7a`, `esst/format-dsk-tim:1.0.0@sha256:6def5a48e543832b29a357e199e3a9a3fad4a8bdb05f0c4a7381f2eadf2615bc`

Stack version after: `esst/format-dsk-pm:1.0.0@sha256:03a1e4226effdffedaac89519c2b2e7bb572c2ac1979ac7e9d7577bc98568c7a`, `esst/format-dsk-tim:1.0.0@sha256:6def5a48e543832b29a357e199e3a9a3fad4a8bdb05f0c4a7381f2eadf2615bc`

Checks:

- PM service health checked: Superseded. `format-dsk_pm` has since been
  intentionally disabled and removed from the live Swarm stack.
- TIM service health checked: OK. `format-dsk_tim` is `1/1`.
- PM image tag/digest checked: OK. Live image is the digest above.
- TIM image tag/digest checked: OK. Live image is the digest above.
- Latest approved repo/CI builds checked: OK. GitHub shows a successful
  `format-dsk-images` workflow run for the same commit.
- PM public route checked: Superseded. `https://dsk-pm.format.lu/` now returns
  Traefik `404`, which is expected while PM is intentionally disabled.
- TIM public route checked: OK. `https://dsk-tim.format.lu/` returns `200`.
- Logs reviewed: TIM OK in the original maintenance pass. The earlier PM
  document-root follow-up is no longer actionable while PM remains disabled.
- Update applied: No.
- Rollback images recorded: `esst/format-dsk-pm:1.0.0@sha256:03a1e4226effdffedaac89519c2b2e7bb572c2ac1979ac7e9d7577bc98568c7a`, `esst/format-dsk-tim:1.0.0@sha256:6def5a48e543832b29a357e199e3a9a3fad4a8bdb05f0c4a7381f2eadf2615bc`
- Notes: The local repo contains many untracked duplicate vendor files with
  ` 2` suffixes; they were not modified in this maintenance run.
- Follow-up: Keep PM documented as intentionally disabled unless it is brought
  back, and complete the base-image freshness check from a machine with a
  working Docker daemon.

## 2026-05-03 - PM Service Disabled Verification

Date: 2026-05-03 09:06 CEST

Maintainer: Codex with Peter

Checks:

- PM service state checked: OK. `format-dsk_pm` is no longer present as a live
  Swarm service.
- TIM service state checked: OK. `format-dsk_tim` remains `1/1`.
- PM public route checked: OK. `https://dsk-pm.format.lu/` returns Traefik
  `404`, which is expected with no matching live service/router backend.
- TIM public route checked: OK. `https://dsk-tim.format.lu/` still returns
  `200`.
- Notes: The earlier PM `index.php` follow-up is obsolete now that PM has been
  intentionally disabled rather than left broken in place.
- Follow-up: Leave the PM service documented as intentionally disabled until you
  decide to restore or delete that part of the stack more permanently.

## 2026-05-03 - PM DNS Cleanup

Date: 2026-05-03 09:09 CEST

Maintainer: Codex with Peter

Checks:

- Cloudflare DNS checked: OK. `dsk-pm.format.lu` still had a proxied CNAME
  record pointing to `format.lu`.
- Cloudflare DNS cleanup applied: OK. Deleted the stale DNS record for
  `dsk-pm.format.lu`.
- Post-delete verification checked: OK. Cloudflare now returns no remaining DNS
  records for `dsk-pm.format.lu`.
- Notes: This aligns public DNS with the current application state: PM is
  intentionally disabled and no longer exposed.
- Follow-up: Remove any stale PM-specific labels or stack-definition fragments
  later if you want the config to match the live footprint more tightly.

## Maintenance Template

Date:

Maintainer:

Repo/ref checked:

Source commit recorded:

Dependency freshness checked:

Dependency updates available:

Stack version before:

Stack version after:

Checks:

- PM service health checked:
- TIM service health checked:
- PM image tag/digest checked:
- TIM image tag/digest checked:
- Latest approved repo/CI builds checked:
- PM public route checked:
- TIM public route checked:
- Logs reviewed:
- Update applied:
- Rollback images recorded:
- Notes:
- Follow-up:
