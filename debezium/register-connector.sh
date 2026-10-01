#!/bin/sh
# Registers the Debezium MySQL connector from debeziumConfig.json.
# Run by the connector-init service in docker-compose.yaml.
# Safe to re-run: a 409 means the connector already exists.
set -eu

CONNECT_URL="${CONNECT_URL:-http://debezium:8083}"

status=$(curl -s -o /tmp/response -w '%{http_code}' -X POST \
  -H 'Content-Type: application/json' \
  --data @/config/debeziumConfig.json \
  "$CONNECT_URL/connectors/")

case "$status" in
  201) echo "Connector registered." ;;
  409) echo "Connector already registered." ;;
  *)   echo "Connector registration failed (HTTP $status):"; cat /tmp/response; exit 1 ;;
esac
