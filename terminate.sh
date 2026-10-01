#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Stopping Streaming ETL"

docker compose ps -a --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'

# Stops and removes every container, the network and the containers'
# data volumes. The next ./deploy.sh starts from a clean slate.
docker compose down -v

echo "DONE"
