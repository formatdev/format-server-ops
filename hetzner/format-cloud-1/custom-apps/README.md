# Custom App Maintenance Strategy

This folder defines the shared maintenance strategy for self-written apps deployed through Portainer on `hetzner-cloud-1`.

Use this for:

- `next-floc`
- `format-timesheet-reports`
- `format-timesheet-2026`
- `format-dsk`
- `chargy-loeffler`
- `chargy`

## Version Policy

For self-written apps, "up to date" means the deployed container image matches the latest approved build from the app's own repository.

Current release model:

- Peter updates dependencies in the app repo.
- Peter builds and publishes the production image.
- The Portainer stack may keep using the `latest` tag.
- Because `latest` is mutable, always record the source repo commit and the live image digest after deployment.
- Treat `latest` as current only when it was rebuilt from the intended repo commit after dependency checks were reviewed.

## Twice-Monthly Check

Run these checks on the 15th and the last day of each month:

1. Confirm all services are running `1/1`.
2. Compare the live image tag and digest with the latest approved repo build.
3. Check whether the app repo has newer commits since the deployed build.
4. Run the repo dependency freshness commands and record whether newer versions are available.
5. Review CI status for the latest main/release branch.
6. Check the public route with `curl -sSI`.
7. Review recent service logs for errors, crashes, failed auth, database errors, or queue/worker failures.
8. Confirm backup coverage for persistent mounts, databases, and Redis volumes where applicable.
9. If an update is available, deploy during a maintenance window and record the before/after image.
10. Keep rollback notes: previous image tag/digest and any data migration steps.

## Commands

List live custom app services:

```bash
ssh hetzner-cloud-1 'docker service ls --format "{{.Name}}|{{.Image}}|{{.Replicas}}" | sort'
```

Inspect one service image, labels, and mounts:

```bash
ssh hetzner-cloud-1 'docker service inspect SERVICE_NAME --format "Image={{.Spec.TaskTemplate.ContainerSpec.Image}} Labels={{json .Spec.Labels}} Mounts={{json .Spec.TaskTemplate.ContainerSpec.Mounts}}"'
```

Check recent logs:

```bash
ssh hetzner-cloud-1 'docker service logs --since 30m --tail 200 SERVICE_NAME'
```

Check task health:

```bash
ssh hetzner-cloud-1 'docker service ps SERVICE_NAME --no-trunc --format "{{.Name}} {{.CurrentState}} {{.Error}}"'
```

## Dependency Freshness Commands

Use these commands only to inspect available updates. They should not modify dependencies.

For npm projects:

```bash
npm outdated
npm audit
```

For pnpm projects:

```bash
pnpm outdated
pnpm audit
```

For Composer projects:

```bash
composer outdated --direct
composer audit
```

For Dockerfile-only stacks, check base images before rebuilding:

```bash
docker pull IMAGE_FROM_DOCKERFILE
docker image inspect IMAGE_FROM_DOCKERFILE --format '{{index .RepoDigests 0}}'
```

## Follow-Up Standardization

These stacks intentionally use `latest` or channel tags in places. The maintenance requirement is to record the repo commit, dependency check result, image build date, and deployed image digest so the mutable tag remains traceable.

Use [version-matrix.md](/Users/czibulapeter/Documents/GitHub/format-server-ops/hetzner/format-cloud-1/custom-apps/version-matrix.md) as the quick overview during maintenance.
