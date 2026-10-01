#!/bin/bash
# End-to-end smoke test for a running pipeline (start it with ./deploy.sh).
# Checks that the sample data, an update, an address change and a delete in
# MySQL all reach ClickHouse. Used by CI; safe to run locally, but it
# changes the sample rows, so run ./terminate.sh && ./deploy.sh afterwards
# for a clean slate.
set -euo pipefail
cd "$(dirname "$0")/.."

TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-120}"

set -a
# shellcheck source=/dev/null
source .env
set +a

mysql_exec() {
  docker compose exec -T -e MYSQL_PWD="$MYSQL_PASSWORD" mysql \
    mysql -u"$MYSQL_USER" streaming_etl_db -e "$1" 2>/dev/null
}

clickhouse_query() {
  docker compose exec -T clickhouse \
    clickhouse-client --user "$CLICKHOUSE_USER" --password "$CLICKHOUSE_PASSWORD" -q "$1"
}

# wait_for DESCRIPTION QUERY EXPECTED: poll ClickHouse until QUERY returns
# EXPECTED, or fail after TIMEOUT_SECONDS.
wait_for() {
  local description="$1" query="$2" expected="$3" actual=""
  local deadline=$((SECONDS + TIMEOUT_SECONDS))
  printf '%s ... ' "$description"
  while ((SECONDS < deadline)); do
    actual="$(clickhouse_query "$query" 2>/dev/null || true)"
    if [[ "$actual" == "$expected" ]]; then
      echo "ok"
      return 0
    fi
    sleep 2
  done
  echo "FAILED"
  echo "  query:    $query" >&2
  echo "  expected: $expected" >&2
  echo "  actual:   $actual" >&2
  exit 1
}

CURRENT="KafkaEngine.person_address_enriched FINAL"

wait_for "Sample data: 50 people, all with a city" \
  "SELECT count(), countIf(CITY IS NULL) FROM $CURRENT" \
  $'50\t0'

wait_for "Coordinates joined from geo" \
  "SELECT round(LAT, 4), round(LNG, 4) FROM $CURRENT WHERE P_ID = 1" \
  $'63.2915\t18.7137'

mysql_exec "UPDATE person SET first_name = 'Renamed', age = 99 WHERE id = 1;"
wait_for "Person update replaces the old row" \
  "SELECT FIRST_NAME, AGE, count() OVER () FROM $CURRENT WHERE P_ID = 1" \
  $'Renamed\t99\t1'

mysql_exec "UPDATE address SET city = 'NewCity' WHERE id = 2;"
wait_for "Address change reaches the person living there" \
  "SELECT CITY FROM $CURRENT WHERE P_ID = 2" \
  "NewCity"

mysql_exec "DELETE FROM person WHERE id = 5;"
wait_for "Person delete removes the person" \
  "SELECT count(), countIf(P_ID = 5) FROM $CURRENT" \
  $'49\t0'

mysql_exec "INSERT INTO person (first_name, address_id) VALUES ('Smoke', 3);"
wait_for "New person arrives with their city" \
  "SELECT CITY FROM $CURRENT WHERE FIRST_NAME = 'Smoke'" \
  "Stockton"

echo "Smoke test passed."
