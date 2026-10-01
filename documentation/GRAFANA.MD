## Grafana Dashboard

Grafana shows the pipeline's output live: it queries ClickHouse every 5 seconds, so inserts, updates and deletes made in MySQL appear on the dashboard within seconds.

Open **http://localhost:3000** after `./deploy.sh`. The dashboard **Streaming ETL: Real-time Analytics** is the home page and can be viewed without logging in. To edit it, log in as `admin` / `admin`.

## Setup

Grafana runs as the `grafana` service in `docker-compose.yaml` (`grafana/grafana:11.6.0`), and everything is provisioned from files, with no manual steps:

| File | What it sets up |
|------|-----------------|
| `grafana/provisioning/datasources/clickhouse.yaml` | The `ClickHouse` datasource (uid `clickhouse`): native protocol to `clickhouse:9000`, database `KafkaEngine` |
| `grafana/provisioning/dashboards/dashboards.yaml` | Loads every JSON file in `grafana/dashboards/` |
| `grafana/dashboards/streaming-etl.json` | The dashboard itself |

On its first start, Grafana installs the official [ClickHouse plugin](https://grafana.com/grafana/plugins/grafana-clickhouse-datasource/) (version 4.22.0, pinned in `GF_INSTALL_PLUGINS`) from grafana.com, so it needs internet access then. If the download fails, Grafana exits. `./deploy.sh` still brings the rest of the pipeline up and prints a warning; see `docker compose logs grafana` for the cause.

## Panels

Every panel reads current people only: `KafkaEngine.person_address_enriched FINAL WHERE IS_DELETED = 0` (see [ClickHouse](ClickHouse.MD)).

| Panel | Type | Shows |
|-------|------|-------|
| People | Stat | People currently in MySQL |
| New people (time range) | Stat | People created during the selected time range |
| Average age | Stat | Average age of current people |
| Cities | Stat | Distinct cities with at least one person |
| New people per interval | Time series (bars) | People created per interval, by `CREATED_AT` |
| Top cities | Bar chart | 10 cities with the most people (no address counts as `Unknown`) |
| Top states | Bar chart | 10 states with the most people |
| Age groups | Bar chart | People per age decade |
| Where people live | Geomap | One marker per person, from the `geo` coordinates of their address |
| Recently changed people | Table | The 20 most recently created or updated people |

The seed data is created when the pipeline starts, so it shows up as one tall bar in **New people per interval**. Run `python data/fake-events.py` from the `data` folder to see new bars arrive.

Every panel shows a single series in one colour (`#3987e5`), checked for contrast and lightness against Grafana's dark panel background. Each panel's data is also available as a table through **Inspect → Data**.

## Changing the Dashboard

The dashboard is provisioned read-only. To change it:

1. Log in as `admin`, open the dashboard, and use **Save as** to make an editable copy.
2. Edit the copy, then use **Export → Export as JSON**.
3. Replace `grafana/dashboards/streaming-etl.json` with the export, keeping `"uid": "streaming-etl"` and the title.
4. Restart Grafana with `docker compose restart grafana`, and run `tests/dashboard-check.sh` (it is also run in CI).

## Testing

`tests/dashboard-check.sh` checks the dashboard against a running pipeline:

1. The ClickHouse datasource health check passes.
2. Every panel's query, run through Grafana's `/api/ds/query` API over the last hour, returns rows without errors.

CI runs it after `tests/smoke-test.sh`.
