# TeslaLogger Home Assistant add-on

This add-on runs the TeslaLogger NET8 service and its PHP admin webserver in one container. MariaDB and Grafana remain separate Home Assistant add-ons.

## Setup

1. Install and start the Home Assistant MariaDB add-on. Create a database named teslalogger and a MariaDB user with permissions to create and manage tables in it.
2. Start the Grafana add-on. The default GRAFANA_HOST is a0d7b954-grafana; change it if your Grafana add-on uses a different repository slug. TeslaLogger expects grafana:3000, so this add-on maps that name to Grafana on the internal Home Assistant network.
3. In the Grafana add-on configuration, add these entries under env_vars so Grafana reads the shared dashboards and plugins:
   ~~~yaml
   - name: GF_PATHS_PROVISIONING
     value: /share/teslalogger/grafana/provisioning
   - name: GF_PATHS_PLUGINS
     value: /share/teslalogger/grafana/plugins
   - name: GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS
     value: natel-discrete-panel,pr0ps-trackmap-panel,teslalogger-timeline-panel
   ~~~
4. Set the complete DBConnectionstring option for the MariaDB database. The default host is core-mariadb; edit the database name, user, and password to match your MariaDB add-on.
5. On startup, the add-on imports TeslaLogger's sqlschema.sql when the configured database contains no tables. It skips the import if any tables already exist because the upstream SQL dump contains DROP TABLE statements; this protects existing data. If startup reports that tables already exist but TeslaLogger's tables are missing, inspect the database before importing the schema manually.
6. Open http://<Home Assistant IP>:8888/admin/. Port 80 serves the admin UI on host port 8888. The TeslaLogger API is published on host port 5010 for external clients.
7. In Grafana, configure a MySQL data source for the TeslaLogger database using the host, database, username, and password from DBConnectionstring. In TeslaLogger's Admin UI, set the Grafana URL to the browser-reachable URL of your Grafana add-on.
8. After TeslaLogger has started and created its dashboard provisioning file, restart the Grafana add-on once. Grafana then loads TeslaLogger dashboards from /share/teslalogger/grafana/dashboards; TeslaLogger plugin files use /share/teslalogger/grafana/plugins.

Both add-ons access these files through Home Assistant's /share folder. TeslaLogger cannot restart the separate Grafana add-on through Docker's socket; after TeslaLogger updates its Grafana plugins, restart Grafana manually from Home Assistant.

Persistent TeslaLogger data, backups, and invoices are stored in this add-on's /config directory.
