#!/bin/sh
# Runs ksqldb/pipeline.sql, then checks that the final join is running.
# Run by the ksqldb-init service in docker-compose.yaml. `ksql --file`
# exits 0 even when a statement fails, hence the explicit check.
set -eu

KSQL_URL="${KSQL_URL:-http://ksqldb-server:8088}"

ksql "$KSQL_URL" --file /ksqldb/pipeline.sql

if ksql "$KSQL_URL" --execute "SHOW QUERIES;" | grep -q "PERSON_ADDRESS_ENRICHED"; then
  echo "ksqlDB pipeline is running."
else
  echo "ksqlDB pipeline query PERSON_ADDRESS_ENRICHED is not running; see the output above." >&2
  exit 1
fi
