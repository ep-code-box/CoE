#!/usr/bin/env bash
set -euo pipefail

# Plain (no security) edge Nginx launcher
# Usage:
#   ./scripts/run_edge_nosec.sh              # run compose (80+8080)
#   ./scripts/run_edge_nosec.sh --dev-only   # run standalone container on 8080 only

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

DEV_ONLY=0
if [[ "${1:-}" == "--dev-only" ]]; then
  DEV_ONLY=1
fi

if [[ ${DEV_ONLY} -eq 0 ]]; then
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.edge.nosec.yml"
  echo "[run_edge_nosec] Bringing up plain edge via compose: ${COMPOSE_FILE}"
  docker compose -p coe-nosec -f "${COMPOSE_FILE}" up -d nginx-edge-nosec
  echo "[run_edge_nosec] Running (80=prod, 8080=dev). Quick checks:"
  echo "  - Prod Backend:   curl -I http://localhost/health"
  echo "  - Prod RAG:       curl -I http://localhost/rag/health"
  echo "  - Dev Backend:    curl -I http://localhost:8080/health"
  echo "  - Dev RAG:        curl -I http://localhost:8080/rag/health"
  echo "  - Logs:           docker compose -p coe-nosec -f ${COMPOSE_FILE} logs -f nginx-edge-nosec"
  exit 0
fi

# Dev-only: run a standalone container binding only 8080
EDGE_NAME="${EDGE_NAME:-coe-edge-nosec-devonly}"
echo "[run_edge_nosec] Removing existing container if present: ${EDGE_NAME}"
docker rm -f "${EDGE_NAME}" >/dev/null 2>&1 || true

echo "[run_edge_nosec] Starting plain nginx on :8080 (container: ${EDGE_NAME})..."
docker run -d --name "${EDGE_NAME}" \
  -p 8080:8080 \
  --add-host host.docker.internal:host-gateway \
  -v "${ROOT_DIR}/nginx/nginx.edge.nosec.conf:/etc/nginx/nginx.conf:ro" \
  nginx:1.28-alpine nginx -g 'daemon off;'

echo "[run_edge_nosec] Done. Quick checks:"
echo "  - Dev Backend:    curl -I http://localhost:8080/health"
echo "  - Dev RAG:        curl -I http://localhost:8080/rag/health"
echo "  - Logs:           docker logs -f ${EDGE_NAME}"

