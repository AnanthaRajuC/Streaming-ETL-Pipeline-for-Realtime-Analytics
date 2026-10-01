#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Streaming ETL"

# Create .env with generated passwords on first run, then load it.
scripts/init-env.sh
set -a
# shellcheck source=/dev/null
source .env
set +a

# Start every service and block until the ones with healthchecks are
# healthy and the one-off init services have finished:
#   connector-init  registers the Debezium connector (debeziumConfig.json)
#   ksqldb-init     creates the ksqlDB tables and joins (ksqldb/pipeline.sql)
# MySQL and ClickHouse create their schemas from mysql/init and clickhouse/init.
# Grafana is started on its own below, so a failure there cannot stop the pipeline.
mapfile -t services < <(docker compose config --services | grep -vx grafana)
docker compose up -d --wait "${services[@]}"

# `--wait` does not wait for one-off services; block until ksqldb-init exits
# and stop here if it failed.
if ! docker compose wait ksqldb-init | grep -q "status code 0$"; then
  echo "ksqldb-init failed:" >&2
  docker compose logs ksqldb-init >&2
  exit 1
fi

# Grafana downloads its ClickHouse plugin from grafana.com on first start.
grafana_status="Grafana      http://localhost:3000  (dashboard: Streaming ETL; admin user: $GRAFANA_ADMIN_USER)"
if ! docker compose up -d --wait grafana; then
  grafana_status="Grafana      NOT RUNNING: it could not start; see: docker compose logs grafana
               (it needs internet access to grafana.com to install its ClickHouse plugin)"
  echo "Warning: Grafana failed to start. The pipeline itself is running." >&2
fi

docker compose ps -a --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'

cat <<MSG

The pipeline is running: MySQL -> Debezium -> Kafka -> ksqlDB -> ClickHouse.

  $grafana_status
  Kafka UI     http://localhost:9099
  Debezium UI  http://localhost:8080
  Connect API  http://localhost:8083
  ksqlDB       http://localhost:8088
  ClickHouse   http://localhost:8123  (user: $CLICKHOUSE_USER)
  MySQL        localhost:3306          (user: $MYSQL_USER)

Passwords are in .env.

Try it:
  Generate events:  pip install -r requirements.txt && python data/fake-events.py
  Query ClickHouse: docker exec -it clickhouse sh -c 'clickhouse-client --password "\$CLICKHOUSE_PASSWORD"' \\
                      -q "SELECT CITY, count() FROM KafkaEngine.person_address_enriched FINAL WHERE IS_DELETED = 0 GROUP BY CITY ORDER BY 2 DESC LIMIT 5"
  ksqlDB CLI:       docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
MSG
