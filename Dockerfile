FROM ghcr.io/just-containers/s6-overlay:3.2.0.2 AS s6
FROM bassmaster187/teslalogger-webserver:latest AS webserver
FROM bassmaster187/teslalogger:latest AS runtime

# The NET8 image contains the logger/API. The companion image contains the PHP admin UI.
COPY --from=s6 / /
RUN apt-get update \
    && apt-get install -y --no-install-recommends apache2 libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-zip jq \
    && a2enmod rewrite headers \
    && sed -ri 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && rm -rf /var/lib/apt/lists/*

COPY --from=webserver /var/www/html/ /var/www/html/
COPY --from=webserver /usr/local/etc/php/php.ini /tmp/upstream-php.ini
COPY rootfs/ /
COPY run.sh /run.sh

RUN php_version="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')" \
    && cp /tmp/upstream-php.ini "/etc/php/${php_version}/apache2/php.ini" \
    && rm -f /tmp/upstream-php.ini \
    && chown -R www-data:www-data /var/www/html \
    && chmod +x /run.sh /etc/cont-init.d/00-config /etc/services.d/teslalogger/run /etc/services.d/webserver/run

ENV S6_KEEP_ENV=1
EXPOSE 80 5000
ENTRYPOINT ["/init"]