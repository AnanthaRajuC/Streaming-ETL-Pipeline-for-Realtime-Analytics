#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Streaming ETL"

# Start every service and block until the ones with healthchecks are
# healthy and the one-off init services have finished:
#   connector-init  registers the Debezium connector (debeziumConfig.json)
#   ksqldb-init     creates the ksqlDB tables and joins (ksqldb/pipeline.sql)
# MySQL and ClickHouse create their schemas from mysql/init and clickhouse/init.
docker compose up -d --wait

# `--wait` does not wait for one-off services; block until ksqldb-init exits
# and stop here if it failed.
if ! docker compose wait ksqldb-init | grep -q "status code 0$"; then
  echo "ksqldb-init failed:" >&2
  docker compose logs ksqldb-init >&2
  exit 1
fi

docker compose ps -a --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'

cat <<'MSG'

The pipeline is running: MySQL -> Debezium -> Kafka -> ksqlDB -> ClickHouse.

  Kafka UI     http://localhost:9099
  Debezium UI  http://localhost:8080
  Connect API  http://localhost:8083
  ksqlDB       http://localhost:8088
  ClickHouse   http://localhost:8123  (user: default, password: root)
  MySQL        localhost:3306          (user: admin, password: password)

Try it:
  Generate events:  python data/fake-events.py
  Query ClickHouse: docker exec -it clickhouse clickhouse-client --password root \
                      -q "SELECT CITY, count() FROM KafkaEngine.person_address_enriched FINAL WHERE IS_DELETED = 0 GROUP BY CITY ORDER BY 2 DESC LIMIT 5"
  ksqlDB CLI:       docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
MSG
