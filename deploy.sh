#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Streaming ETL"

# Start every service and block until the ones with healthchecks
# (MySQL, Kafka, Debezium Connect, ksqlDB, ClickHouse) report healthy.
docker compose up -d --wait

docker compose ps --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'

cat <<'MSG'

All services are up.

  Kafka UI     http://localhost:9099
  Debezium UI  http://localhost:8080
  Connect API  http://localhost:8083
  ksqlDB       http://localhost:8088
  ClickHouse   http://localhost:8123  (user: default, password: root)
  MySQL        localhost:3306          (user: admin, password: password)

Next steps:
  Register the Debezium connector:
    curl -i -X POST -H "Content-Type:application/json" localhost:8083/connectors/ -d @debeziumConfig.json
  Open the ksqlDB CLI:
    docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
MSG
