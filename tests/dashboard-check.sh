#!/bin/bash
# Checks the Grafana dashboard against a running pipeline (start it with
# ./deploy.sh). Verifies the ClickHouse datasource is healthy, then runs
# every panel's query through Grafana's query API and fails if any query
# errors or returns no rows. Used by CI after tests/smoke-test.sh.
set -euo pipefail
cd "$(dirname "$0")/.."

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
set -a
# shellcheck source=/dev/null
source .env
set +a
AUTH="$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD"
DASHBOARD_UID="streaming-etl"

api() {
  curl -sS --fail-with-body -u "$AUTH" -H 'Content-Type: application/json' "$@"
}

printf 'ClickHouse datasource health ... '
health="$(api "$GRAFANA_URL/api/datasources/uid/clickhouse/health" || true)"
if [[ "$(jq -r '.status // empty' <<<"$health" 2>/dev/null)" != "OK" ]]; then
  echo "FAILED"
  echo "  response: $health" >&2
  exit 1
fi
echo "ok"

dashboard="$(api "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID")"
panel_count="$(jq '.dashboard.panels | length' <<<"$dashboard")"
echo "Dashboard '$(jq -r '.dashboard.title' <<<"$dashboard")' has $panel_count panels"

failures=0
for i in $(seq 0 $((panel_count - 1))); do
  title="$(jq -r ".dashboard.panels[$i].title" <<<"$dashboard")"
  request="$(jq -c --argjson i "$i" '{
      from: "now-1h", to: "now",
      queries: [.dashboard.panels[$i].targets[0] + {intervalMs: 60000, maxDataPoints: 500}]
    }' <<<"$dashboard")"
  printf 'Panel "%s" ... ' "$title"
  response="$(api -X POST "$GRAFANA_URL/api/ds/query" -d "$request" || true)"
  error="$(jq -r '.results.A.error // empty' <<<"$response" 2>/dev/null || echo "invalid response")"
  rows="$(jq -r '[.results.A.frames[]?.data.values[0]? | length] | add // 0' <<<"$response" 2>/dev/null || echo 0)"
  if [[ -n "$error" ]]; then
    echo "FAILED: $error"
    failures=$((failures + 1))
  elif [[ "$rows" -eq 0 ]]; then
    echo "FAILED: no rows"
    echo "  response: $response" >&2
    failures=$((failures + 1))
  else
    echo "ok ($rows rows)"
  fi
done

if ((failures > 0)); then
  echo "$failures panel(s) failed." >&2
  exit 1
fi
echo "Dashboard check passed."
