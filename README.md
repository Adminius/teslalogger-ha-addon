# TeslaLogger Home Assistant add-on (work in progress)

This add-on runs the TeslaLogger NET8 service and its PHP admin webserver in one container. MariaDB and Grafana remain separate Home Assistant add-ons.

## Setup

1. Install and start the Home Assistant MariaDB add-on. Create a database named `teslalogger` and a MariaDB user with permissions to create and manage tables in it.
2. Set the complete `DBConnectionstring` option for that database. The default host is `core-mariadb`; edit the database name, user, and password to match your MariaDB add-on.
3. On startup, the add-on imports TeslaLogger's `sqlschema.sql` when the configured database contains no tables. It skips the import if any tables already exist because the upstream SQL dump contains `DROP TABLE` statements; this protects existing data. If startup reports that tables already exist but TeslaLogger's tables are missing, inspect the database before importing the schema manually.
4. Open `http://<Home Assistant IP>:8888/admin/`. Port 80 serves the admin UI on host port 8888. The TeslaLogger API is published on host port 5010 for external clients.
5. In TeslaLogger's Admin UI, set the Grafana URL to the browser-reachable URL of your Grafana add-on.
6. Import TeslaLogger dashboards into Grafana and install any required TeslaLogger panels/plugins there. Grafana does not automatically share the upstream TeslaLogger Grafana image's data or plugins.

Persistent TeslaLogger data, backups, and invoices are stored in this add-on's `/config` directory.