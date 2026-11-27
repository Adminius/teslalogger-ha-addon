FROM bassmaster187/teslalogger-webserver:latest AS webserver
FROM bassmaster187/teslalogger:latest AS runtime

ARG TARGETARCH
ARG S6_OVERLAY_VERSION=3.2.3.2

# The NET8 image contains the logger/API. The companion image contains the PHP admin UI.
# Install S6 from its public release assets so this build does not depend on GHCR access.
RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends mariadb-client apache2 libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-zip jq curl xz-utils; \
    case "$TARGETARCH" in amd64) s6_arch=x86_64 ;; arm64) s6_arch=aarch64 ;; *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; esac; \
    s6_base="https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}"; \
    mkdir -p /tmp/s6; cd /tmp/s6; \
    for asset in s6-overlay-noarch s6-overlay-${s6_arch}; do \
      curl -fsSL "${s6_base}/${asset}.tar.xz" -o "${asset}.tar.xz"; \
      curl -fsSL "${s6_base}/${asset}.tar.xz.sha256" -o "${asset}.tar.xz.sha256"; \
      sha256sum -c "${asset}.tar.xz.sha256"; \
      tar -C / -Jxpf "${asset}.tar.xz"; \
    done; \
    a2enmod rewrite headers; \
    sed -ri 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf; \
    rm -rf /tmp/s6 /var/lib/apt/lists/*

COPY --from=runtime /etc/teslalogger/sqlschema/sqlschema.sql /usr/share/teslalogger/sqlschema.sql
COPY --from=webserver /var/www/html/ /var/www/html/
COPY --from=webserver /usr/local/etc/php/php.ini /tmp/upstream-php.ini
COPY rootfs/ /
COPY run.sh /run.sh

RUN php_version="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')" \
    && cp /tmp/upstream-php.ini "/etc/php/${php_version}/apache2/php.ini" \
    && rm -f /tmp/upstream-php.ini \
    && chown -R www-data:www-data /var/www/html \
    && chmod +x /run.sh /usr/local/bin/teslalogger-init-db /etc/cont-init.d/00-config /etc/services.d/teslalogger/run /etc/services.d/webserver/run

ENV S6_KEEP_ENV=1
EXPOSE 80 5000
ENTRYPOINT ["/init"]