#!/usr/bin/env bash
set -euo pipefail

# Simple PROD monitoring: tails service logs and periodically checks health.

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$ROOT_DIR"

COMPOSE=(docker compose -p coe-prod -f docker-compose.full.yml --profile prod)

BACKEND_HEALTH="http://localhost:18000/health"
RAG_HEALTH="http://localhost:18001/health"

health_loop() {
  while true; do
    ts="$(date '+%H:%M:%S')"
    bhc=$(curl -s -o /dev/null -w '%{http_code} %{time_total}' "$BACKEND_HEALTH" || true)
    rhc=$(curl -s -o /dev/null -w '%{http_code} %{time_total}' "$RAG_HEALTH" || true)
    echo "[${ts}] [HEALTH] backend: ${bhc} | rag: ${rhc}"
    sleep 5
  done
}

cleanup() {
  [[ -n "${HL_PID:-}" ]] && kill "$HL_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo "== PROD monitor: coe-backend-prod, coe-ragpipeline-prod, mariadb-prod, redis-prod, chroma-prod =="
"${COMPOSE[@]}" ps

health_loop & HL_PID=$!

# Combined logs with service prefixes
"${COMPOSE[@]}" logs -f --tail=200 \
  coe-backend-prod coe-ragpipeline-prod mariadb-prod redis-prod chroma-prod

