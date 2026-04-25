#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="/data/backups/databases"
RETENTION_DAYS="14"
TIMESTAMP="$(date +%F-%H%M%S)"

mkdir -p \
  "$BACKUP_ROOT/glitchtip-postgres" \
  "$BACKUP_ROOT/vtiger-mysql" \
  "$BACKUP_ROOT/website-mariadb"
chmod 700 "$BACKUP_ROOT" "$BACKUP_ROOT"/*

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

  docker exec "$container" sh -lc \
    'PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall -U "$POSTGRES_USER"' \
    | gzip > "$out_file"
  chmod 600 "$out_file"
  ls -lh "$out_file"
}

dump_vtiger_mysql() {
  local container out_file
  container="$(find_container esst-vtiger_mysql)"
  out_file="$BACKUP_ROOT/vtiger-mysql/vtiger-mysql-all-databases-$TIMESTAMP.sql.gz"

  if [[ -z "$container" ]]; then
    echo "No running esst-vtiger_mysql container found" >&2
    return 1
  fi

  docker exec "$container" sh -lc \
    '/usr/local/mysql/bin/mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --all-databases --single-transaction --quick --routines --events --triggers' \
    | gzip > "$out_file"
  chmod 600 "$out_file"
  ls -lh "$out_file"
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

  docker exec -e DB_ENV="$db_env" "$container" sh -lc \
    'set -- $DB_ENV; DB_NAME="$(printf %s "$1" | base64 -d)"; DB_USER="$(printf %s "$2" | base64 -d)"; DB_PASS="$(printf %s "$3" | base64 -d)"; mariadb-dump -u"$DB_USER" -p"$DB_PASS" -h127.0.0.1 --single-transaction --quick --routines --events --triggers "$DB_NAME"' \
    | gzip > "$out_file"
  chmod 600 "$out_file"
  ls -lh "$out_file"
}

dump_glitchtip_postgres
dump_vtiger_mysql
dump_website_mariadb

# Keep local dump staging tidy. Duplicati handles off-host retention.
find "$BACKUP_ROOT/glitchtip-postgres" -maxdepth 1 -type f -name "glitchtip-postgres-all-databases-*.sql.gz" -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_ROOT/vtiger-mysql" -maxdepth 1 -type f -name "vtiger-mysql-all-databases-*.sql.gz" -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_ROOT/website-mariadb" -maxdepth 1 -type f -name "website-mariadb-all-databases-*.sql.gz" -mtime +"$RETENTION_DAYS" -delete
