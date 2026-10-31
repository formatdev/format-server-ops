ARG BUILD_BASE
ARG APP_BASE
FROM ${BUILD_BASE} AS php-build

USER root
ARG PATCH_VERSION
ARG PATCH_SHA256
ARG BUILD_JOBS=3
COPY build-runtime.sh /tmp/build-runtime.sh
RUN sh /tmp/build-runtime.sh

FROM ${APP_BASE}
ARG PATCH_VERSION
ARG PATCH_SHA256
ENV PHP_VERSION=${PATCH_VERSION} \
    PHP_URL=https://www.php.net/distributions/php-${PATCH_VERSION}.tar.xz \
    PHP_SHA256=${PATCH_SHA256}
LABEL lu.format.security.advisories="CVE-2026-109618 CVE-2026-109619" \
      lu.format.security.php-version="${PATCH_VERSION}"
COPY --from=php-build /opt/php-runtime/ /
RUN test "$(php -r 'echo PHP_VERSION;')" = "$PHP_VERSION" \
    && php -m \
    && apache2ctl -t \
    && ! ldd /usr/local/bin/php /usr/lib/apache2/modules/libphp.so | grep 'not found'
