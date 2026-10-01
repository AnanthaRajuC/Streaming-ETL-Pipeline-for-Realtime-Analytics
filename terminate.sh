#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Stopping Streaming ETL"

docker compose ps --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'

# Stops and removes every container and the network. Add -v to also
# drop volumes, so MySQL and ClickHouse re-run their init scripts next time.
docker compose down

echo "DONE"
