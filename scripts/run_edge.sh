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
  echo "[run_edge] Pre-clean old edge containers and networks (if any)"
  # Old container name from previous full-profile project
  docker rm -f coe-nginx-edge-1 >/dev/null 2>&1 || true
  # Current container name from edge-only compose
  docker rm -f coe-edge-nginx-edge-1 >/dev/null 2>&1 || true
  # Old/new networks (ignore errors if in use or missing)
  docker network rm coe_coe-edge-net >/dev/null 2>&1 || true
  docker network rm coe-edge_coe-edge-net >/dev/null 2>&1 || true

  # Compose-based edge (separate file)
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.edge.yml"
  echo "[run_edge] Bringing up edge via compose: ${COMPOSE_FILE} (project: coe)"
  docker compose -p coe -f "${COMPOSE_FILE}" up -d nginx-edge
  echo "[run_edge] Edge running (ports: 80 prod, 8080 dev). Quick checks:"
  echo "  - LangFlow(prod): curl -I http://localhost/"
  echo "  - Backend(prod):  curl -I http://localhost/agent/health"
  echo "  - RAG(prod):      curl -I http://localhost/rag/health"
  echo "  - LangFlow(dev):  curl -I http://localhost:8080/"
  echo "  - Backend(dev):   curl -I http://localhost:8080/agent/health"
  echo "  - RAG(dev):       curl -I http://localhost:8080/rag/health"
  echo "  - Edge logs:      docker compose -p coe -f ${COMPOSE_FILE} logs -f nginx-edge"
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
echo "  - LangFlow(dev):  curl -I http://localhost:8080/"
echo "  - Backend(dev):   curl -I http://localhost:8080/agent/health"
echo "  - Dev RAG:        curl -I http://localhost:8080/rag/health"
echo "  - Edge logs:      docker logs -f ${EDGE_NAME}"
