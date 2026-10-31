#!/bin/sh
set -eu

: "${PATCH_VERSION:?}"
: "${PATCH_SHA256:?}"
: "${BUILD_JOBS:=3}"

# Preserve the original build options and extension ABI for each PHP branch.
configure_flags=$(php-config --configure-options | sed 's/ build_alias=.*//')
extension_dir=$(php-config --extension-dir)

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    ${PHPIZE_DEPS} apache2-dev libargon2-dev libcurl4-openssl-dev \
    libonig-dev libreadline-dev libsodium-dev libsqlite3-dev libssl-dev \
    libxml2-dev zlib1g-dev ca-certificates curl xz-utils

curl -fLsS --retry 3 "https://www.php.net/distributions/php-${PATCH_VERSION}.tar.xz" \
    -o /tmp/php-patched.tar.xz
printf '%s  %s\n' "$PATCH_SHA256" /tmp/php-patched.tar.xz | sha256sum -c -
mkdir /tmp/php-patched
tar -xJf /tmp/php-patched.tar.xz -C /tmp/php-patched --strip-components=1
cd /tmp/php-patched

export CFLAGS="${PHP_CFLAGS:-}"
export CPPFLAGS="${PHP_CPPFLAGS:-}"
export LDFLAGS="${PHP_LDFLAGS:-}"
# The inherited Docker PHP flags contain only single-word options before build_alias.
./configure $configure_flags
make -j "$BUILD_JOBS"
make install

# Stage only PHP-owned runtime artifacts; retain the target application's entrypoint.
mkdir -p /opt/php-runtime/usr/local/bin \
    /opt/php-runtime/usr/local/include \
    /opt/php-runtime/usr/local/lib/php \
    /opt/php-runtime/usr/local/etc/php \
    /opt/php-runtime/usr/lib/apache2/modules \
    "/opt/php-runtime${extension_dir}" \
    /opt/php-runtime/usr/src
for binary in php phpize php-config; do
    cp -a "/usr/local/bin/$binary" /opt/php-runtime/usr/local/bin/
done
cp -a /usr/local/include/php /opt/php-runtime/usr/local/include/
cp -a /usr/local/lib/php/build /opt/php-runtime/usr/local/lib/php/
cp -a /usr/lib/apache2/modules/libphp.so /opt/php-runtime/usr/lib/apache2/modules/
for module in modules/*.so; do
    test -f "$module" || continue
    cp -a "$module" "/opt/php-runtime${extension_dir}/"
done
cp php.ini-development php.ini-production /opt/php-runtime/usr/local/etc/php/
cp /tmp/php-patched.tar.xz /opt/php-runtime/usr/src/php.tar.xz
test "$(php -r 'echo PHP_VERSION;')" = "$PATCH_VERSION"
