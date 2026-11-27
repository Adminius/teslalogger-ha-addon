# TeslaLogger Home Assistant add-on (work in progress)

This add-on runs the TeslaLogger NET8 service and its PHP admin webserver in one container. MariaDB and Grafana remain separate Home Assistant add-ons.

## Setup

1. Install and start the Home Assistant MariaDB add-on. Create a database named `teslalogger` and a MariaDB user with access to it.
2. Configure this add-on's `DB_SERVER`, `DB_DATABASE`, `DB_USER`, and `DB_PASSWORD`. The default database host is `core-mariadb`.
3. Initialize the TeslaLogger SQL schema in that database before starting the add-on. The Compose install imports the schema through MariaDB's first-start init directory; the MariaDB Home Assistant add-on does not consume that Compose mount.
4. Start TeslaLogger and open `http://<Home Assistant IP>:8888/admin/`. Port 80 serves the admin UI on host port 8888. The TeslaLogger API is published on host port 5010 for external clients.
5. In TeslaLogger's Admin UI, set the Grafana URL to the browser-reachable URL of your Grafana add-on.
6. Import TeslaLogger dashboards into Grafana and install any required TeslaLogger panels/plugins there. Grafana does not automatically share the upstream TeslaLogger Grafana image's data or plugins.

Persistent TeslaLogger data, backups, and invoices are stored in this add-on's `/config` directory.