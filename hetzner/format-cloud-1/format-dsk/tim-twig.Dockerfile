# Build with a clean TIM API composer.json, composer.lock and vendor tree.
FROM format-security/format-dsk-tim:1.0.0-php8.4.27

RUN rm -rf /var/www/html/API/vendor
COPY --chown=www-data:www-data composer.json composer.lock /var/www/html/API/
COPY --chown=www-data:www-data vendor/ /var/www/html/API/vendor/
RUN php -r 'require "/var/www/html/API/vendor/autoload.php"; exit(PHP_VERSION === "8.4.27" && version_compare(\Twig\Environment::VERSION, "3.30.0", ">=") ? 0 : 1);'
