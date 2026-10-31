#!/bin/sh
set -eu

image=$1
expected_version=$2
baseline_modules=$3
probe_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
check_name="php-security-check-$$"

cleanup() {
    docker rm -fv "$check_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

docker run --rm --network none --entrypoint php "$image" -m | diff -u "$baseline_modules" -
docker run -d --network none --name "$check_name" \
    --mount "type=bind,src=$probe_dir/probe.php,dst=/tmp/php-security-probe.php,readonly" \
    --mount "type=bind,src=$probe_dir/probe.conf,dst=/etc/apache2/conf-enabled/php-security-probe.conf,readonly" \
    --entrypoint apache2-foreground "$image" >/dev/null

for attempt in 1 2 3 4 5; do
    if docker exec "$check_name" php -d allow_url_fopen=1 -r '
        $result = @file_get_contents("http://127.0.0.1/__php_security_runtime.php");
        $data = json_decode($result ?: "", true);
        if (($data["version"] ?? null) !== $argv[1] || ($data["sapi"] ?? null) !== "apache2handler") {
            exit(1);
        }
        echo json_encode($data, JSON_THROW_ON_ERROR), PHP_EOL;
    ' "$expected_version"; then
        exit 0
    fi
    sleep 1
done

docker logs --tail 30 "$check_name" >&2
exit 1
