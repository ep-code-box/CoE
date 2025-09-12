#!/usr/bin/env bash
set -euo pipefail

# Edge Nginx launcher (80: prod proxy, 8080: dev proxy)
# Preferred: use compose edge profile to mirror repo config exactly.
# Usage:
#   ./scripts/run_edge.sh              # use compose edge profile (80+8080)
#   ./scripts/run_edge.sh --dev-only   # standalone container on 8080 only

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

DEV_ONLY=0
if [[ "${1:-}" == "--dev-only" ]]; then
  DEV_ONLY=1
fi

if [[ ${DEV_ONLY} -eq 0 ]]; then
  # Compose-based edge (recommended, matches docker-compose.full.yml)
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.full.yml"
  echo "[run_edge] Bringing up edge via compose: ${COMPOSE_FILE} --profile edge"
  docker compose -f "${COMPOSE_FILE}" --profile edge up -d nginx-edge
  echo "[run_edge] Edge running (ports: 80 prod, 8080 dev). Quick checks:"
  echo "  - Prod Backend:   curl -I http://localhost/health"
  echo "  - Prod RAG:       curl -I http://localhost/rag/health"
  echo "  - Dev Backend:    curl -I http://localhost:8080/health"
  echo "  - Dev RAG:        curl -I http://localhost:8080/rag/health"
  echo "  - Edge logs:      docker compose -f ${COMPOSE_FILE} --profile edge logs -f nginx-edge"
  exit 0
fi

# Dev-only mode: run a standalone container that binds only 8080
EDGE_NAME="${EDGE_NAME:-coe-edge-devonly}"
echo "[run_edge] Removing existing container if present: ${EDGE_NAME}"
docker rm -f "${EDGE_NAME}" >/dev/null 2>&1 || true

echo "[run_edge] Starting edge nginx (dev-only) on :8080 (container: ${EDGE_NAME})..."
docker run -d --name "${EDGE_NAME}" \
  -p 8080:8080 \
  --add-host host.docker.internal:host-gateway \
  --tmpfs /var/cache/nginx:rw,mode=1777 \
  --tmpfs /var/run:rw,mode=755 \
  --tmpfs /tmp:rw,mode=1777 \
  -e MODSECURITY_DETECTION_ONLY=off \
  -v "${ROOT_DIR}/nginx/nginx.edge.conf:/etc/nginx/templates/nginx.conf.template:ro" \
  -v "${ROOT_DIR}/nginx/ip-allowlist.conf:/etc/nginx/templates/conf.d/ip-allowlist.conf.template:ro" \
  -v "${ROOT_DIR}/nginx/waf/modsecurity-override.conf:/etc/nginx/templates/modsecurity.d/modsecurity-override.conf.template:ro" \
  owasp/modsecurity-crs:nginx nginx -g 'daemon off;'

echo "[run_edge] Done. Quick checks:"
echo "  - Dev Backend:    curl -I http://localhost:8080/health"
echo "  - Dev RAG:        curl -I http://localhost:8080/rag/health"
echo "  - Edge logs:      docker logs -f ${EDGE_NAME}"
