#!/usr/bin/env bash
set -euo pipefail

# Simple DEV monitoring: tails service logs and periodically checks health.

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$ROOT_DIR"

COMPOSE=(docker compose -p coe-dev -f docker-compose.full.yml --profile dev)

BACKEND_HEALTH="http://localhost:18002/health"
RAG_HEALTH="http://localhost:18003/health"

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

echo "== DEV monitor: coe-backend-dev, coe-ragpipeline-dev, mariadb-dev, redis-dev, chroma-dev =="
"${COMPOSE[@]}" ps

health_loop & HL_PID=$!

# Combined logs with service prefixes
"${COMPOSE[@]}" logs -f --tail=200 \
  coe-backend-dev coe-ragpipeline-dev mariadb-dev redis-dev chroma-dev

