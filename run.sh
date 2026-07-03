#!/usr/bin/env bash

export TZ=${TZ:-Europe/Berlin}
export DB_SERVER=core-mariadb
export DB_DATABASE=teslalogger
export DB_USER=teslalogger
export DB_PASSWORD=${DB_PASSWORD:-teslalogger}
export GRAFANA_URL=${GRAFANA_URL:-http://core-grafana:3000}

echo "DB_SERVER = $DB_SERVER"
echo "GRAFANA_URL = $GRAFANA_URL"

exec /app/TeslaLogger
