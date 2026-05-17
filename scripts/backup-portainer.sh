#!/usr/bin/env bash

set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-portainer_portainer}"
DATA_DIR="${DATA_DIR:-/data/portainer/data}"
BACKUP_DIR="${BACKUP_DIR:-/data/backups/portainer}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-120}"
POLL_SECONDS="${POLL_SECONDS:-2}"

timestamp="$(date +%Y%m%d-%H%M%S)"
archive_path="${BACKUP_DIR}/portainer-data-${timestamp}.tar.gz"
tmp_archive_path="${archive_path}.tmp"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$*"
}

cleanup() {
  rm -f "$tmp_archive_path"
}

trap cleanup EXIT

wait_for_replicas() {
  local expected="$1"
  local deadline=$(( $(date +%s) + WAIT_TIMEOUT_SECONDS ))
  local replicas

  while :; do
    replicas="$(docker service ls --filter "name=${SERVICE_NAME}" --format '{{.Replicas}}' | head -n1)"
    if [[ "$replicas" == "$expected" ]]; then
      return 0
    fi

    if (( $(date +%s) >= deadline )); then
      log "Timed out waiting for ${SERVICE_NAME} replicas=${expected}; current=${replicas:-missing}"
      return 1
    fi

    sleep "$POLL_SECONDS"
  done
}

if ! docker service inspect "$SERVICE_NAME" >/dev/null 2>&1; then
  log "Service ${SERVICE_NAME} not found"
  exit 1
fi

if [[ ! -d "$DATA_DIR" ]]; then
  log "Data directory ${DATA_DIR} not found"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

log "Scaling ${SERVICE_NAME} to 0"
docker service scale "${SERVICE_NAME}=0" >/dev/null
wait_for_replicas "0/0"

log "Creating backup archive ${archive_path}"
tar -C "$(dirname "$DATA_DIR")" -czf "$tmp_archive_path" "$(basename "$DATA_DIR")"
mv "$tmp_archive_path" "$archive_path"

log "Scaling ${SERVICE_NAME} back to 1"
docker service scale "${SERVICE_NAME}=1" >/dev/null
wait_for_replicas "1/1"

log "Pruning backup archives older than ${RETENTION_DAYS} days"
find "$BACKUP_DIR" -maxdepth 1 -type f -name 'portainer-data-*.tar.gz' -mtime +"$RETENTION_DAYS" -delete

log "Backup completed: ${archive_path}"
