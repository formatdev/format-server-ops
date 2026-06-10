#!/usr/bin/env bash
set -uo pipefail

BACKUP_ROOT="/data/backups/databases"
RETENTION_DAYS="14"
TIMESTAMP="$(date +%F-%H%M%S)"

mkdir -p \
  "$BACKUP_ROOT/glitchtip-postgres" \
  "$BACKUP_ROOT/website-mariadb"
chmod 700 "$BACKUP_ROOT" "$BACKUP_ROOT"/*

prune() {
  for dir in glitchtip-postgres website-mariadb; do
    find "$BACKUP_ROOT/$dir" -maxdepth 1 -type f -name "*.sql.gz" \
      -mtime +"$RETENTION_DAYS" -delete 2>/dev/null || true
    find "$BACKUP_ROOT/$dir" -maxdepth 1 -type f -name "*.sql.gz.partial" \
      -mtime +1 -delete 2>/dev/null || true
  done
}

trap prune EXIT

finish_dump() {
  local partial_file="$1"
  local out_file="$2"

  chmod 600 "$partial_file"
  mv "$partial_file" "$out_file"
  ls -lh "$out_file"
}

run_dump() {
  local label="$1"
  local out_file="$2"
  local dump_cmd="$3"
  local partial_file="${out_file}.partial"

  rm -f "$partial_file"

  if bash -o pipefail -lc "$dump_cmd" >"$partial_file"; then
    finish_dump "$partial_file" "$out_file"
    return 0
  fi

  rm -f "$partial_file"
  echo "Backup failed for $label" >&2
  return 1
}

find_container() {
  local service_name="$1"
  docker ps \
    --filter "label=com.docker.swarm.service.name=$service_name" \
    --format "{{.ID}}" \
    | head -n1
}

dump_glitchtip_postgres() {
  local container out_file
  container="$(find_container esst-glitchtip_postgres)"
  out_file="$BACKUP_ROOT/glitchtip-postgres/glitchtip-postgres-all-databases-$TIMESTAMP.sql.gz"

  if [[ -z "$container" ]]; then
    echo "No running esst-glitchtip_postgres container found" >&2
    return 1
  fi

  run_dump \
    "glitchtip-postgres" \
    "$out_file" \
    "docker exec $container sh -lc 'PGPASSWORD=\"\$POSTGRES_PASSWORD\" pg_dumpall -U \"\$POSTGRES_USER\"' | gzip"
}

dump_website_mariadb() {
  local container wordpress_container db_env out_file
  container="$(find_container esst-website_mariadb)"
  wordpress_container="$(find_container esst-website_wordpress)"
  out_file="$BACKUP_ROOT/website-mariadb/website-mariadb-all-databases-$TIMESTAMP.sql.gz"

  if [[ -z "$container" ]]; then
    echo "No running esst-website_mariadb container found" >&2
    return 1
  fi

  if [[ -z "$wordpress_container" ]]; then
    echo "No running esst-website_wordpress container found" >&2
    return 1
  fi

  db_env="$(
    docker exec "$wordpress_container" sh -lc \
      'php -r "include \"/var/www/html/wp-config.php\"; echo base64_encode(DB_NAME), \" \", base64_encode(DB_USER), \" \", base64_encode(DB_PASSWORD), \"\n\";"'
  )"

  run_dump \
    "website-mariadb" \
    "$out_file" \
    "docker exec -e DB_ENV='$db_env' $container sh -lc 'set -- \$DB_ENV; DB_NAME=\"\$(printf %s \"\$1\" | base64 -d)\"; DB_USER=\"\$(printf %s \"\$2\" | base64 -d)\"; DB_PASS=\"\$(printf %s \"\$3\" | base64 -d)\"; mariadb-dump -u\"\$DB_USER\" -p\"\$DB_PASS\" -h127.0.0.1 --single-transaction --quick --routines --events --triggers \"\$DB_NAME\"' | gzip"
}

status=0

dump_glitchtip_postgres || status=1
dump_website_mariadb || status=1

exit "$status"
