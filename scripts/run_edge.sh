#!/usr/bin/env bash
set -euo pipefail

# Edge Nginx launcher (80: prod, 8080: dev)
# Usage:
#   ./scripts/run_edge.sh            # map 80 and 8080
#   ./scripts/run_edge.sh --dev-only # map 8080 only

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
EDGE_NAME="${EDGE_NAME:-coe-nginx-edge-1}"

DEV_ONLY=0
if [[ "${1:-}" == "--dev-only" ]]; then
  DEV_ONLY=1
fi

echo "[run_edge] Removing existing container if present: ${EDGE_NAME}"
docker rm -f "${EDGE_NAME}" >/dev/null 2>&1 || true

PORT_ARGS=("-p" "8080:8080")
if [[ "${DEV_ONLY}" -eq 0 ]]; then
  PORT_ARGS=("-p" "80:80" "-p" "8080:8080")
fi

echo "[run_edge] Starting edge nginx (container: ${EDGE_NAME})..."
docker run -d --name "${EDGE_NAME}" \
  "${PORT_ARGS[@]}" \
  --add-host host.docker.internal:host-gateway \
  --tmpfs /var/cache/nginx:rw,mode=1777 \
  --tmpfs /var/run:rw,mode=755 \
  --tmpfs /tmp:rw,mode=1777 \
  -v "${ROOT_DIR}/nginx/nginx.edge.conf:/etc/nginx/templates/nginx.conf.template:ro" \
  -v "${ROOT_DIR}/nginx/ip-allowlist.conf:/etc/nginx/templates/conf.d/ip-allowlist.conf.template:ro" \
  -v "${ROOT_DIR}/nginx/waf/modsecurity-override.conf:/etc/nginx/templates/modsecurity.d/modsecurity-override.conf.template:ro" \
  owasp/modsecurity-crs:nginx nginx -g 'daemon off;'

echo "[run_edge] Done. Quick checks:"
if [[ "${DEV_ONLY}" -eq 0 ]]; then
  echo "  - Prod Backend:  curl -I http://localhost/health"
  echo "  - Prod RAG:      curl -I http://localhost/rag/health"
fi
echo "  - Dev Backend:   curl -I http://localhost:8080/health"
echo "  - Dev RAG:       curl -I http://localhost:8080/rag/health"
echo "  - Dev RAG Swagger: http://localhost:8080/rag/docs"

