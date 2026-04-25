#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="/data/backups/databases"
PASSWORD_FILE="/root/.monitoring-db-root-password"
SERVICE_NAME="esst-monitoring-production_mariadb"

mkdir -p "$BACKUP_ROOT/monitoring-latest-heavy-tables"
chmod 700 "$BACKUP_ROOT" "$BACKUP_ROOT/monitoring-latest-heavy-tables"

container="$(
  docker ps \
    --filter "label=com.docker.swarm.service.name=$SERVICE_NAME" \
    --format "{{.ID}}" \
    | head -n1
)"

if [[ -z "$container" ]]; then
  echo "No running $SERVICE_NAME container found" >&2
  exit 1
fi

if [[ ! -r "$PASSWORD_FILE" ]]; then
  echo "Database password file is missing or not readable: $PASSWORD_FILE" >&2
  exit 1
fi

out_file="$BACKUP_ROOT/monitoring-latest-heavy-tables/monitoring-latest-heavy-tables.sql.gz"
tmp_file="$out_file.tmp"
container_password_file="/tmp/backup-db-password-$$"

cleanup() {
  rm -f "$tmp_file"
  docker exec "$container" sh -c 'rm -f "$1"' sh "$container_password_file" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker cp "$PASSWORD_FILE" "$container:$container_password_file"

docker exec "$container" sh -c '
  set -eu
  password_file="$1"
  defaults_file="$(mktemp)"
  trap "rm -f \"$defaults_file\" \"$password_file\"" EXIT
  chmod 600 "$defaults_file" "$password_file"
  {
    printf "%s\n" "[client]"
    printf "%s\n" "user=root"
    printf "password=%s\n" "$(tr -d "\r\n" < "$password_file")"
    printf "%s\n" "host=127.0.0.1"
  } > "$defaults_file"
  mariadb-dump --defaults-extra-file="$defaults_file" --single-transaction --quick --default-character-set=utf8mb4 monitoring audit_trail_entry activity_log failed_jobs
' sh "$container_password_file" \
  | gzip -1 > "$tmp_file"

chmod 600 "$tmp_file"
mv "$tmp_file" "$out_file"
ls -lh "$out_file"
