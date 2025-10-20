#!/usr/bin/env bash

# Helper to download Linux/Python3.11 wheel files for offline installs.
# Uses the Docker Compose file in this directory.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/wheels.compose.yml"

usage() {
  cat <<'EOF'
Usage: ./scripts/download_wheels.sh [backend|rag|all]

Downloads Python wheels (and required sdists) for:
  backend - CoE-Backend/requirements.in + uv
  rag     - CoE-RagPipeline/requirements.txt + uv
  all     - both targets (default)

Requires Docker Engine with compose plugin (`docker compose`).
EOF
}

ensure_compose() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "Using docker compose"
    return 0
  fi
  echo "❌ docker compose 명령을 찾을 수 없습니다. Docker Desktop 또는 compose plugin을 확인하세요." >&2
  exit 1
}

run_service() {
  local service="$1"
  echo "🚚 Downloading wheels for ${service}..."
  docker compose -f "${COMPOSE_FILE}" run --rm "${service}"
}

target="${1:-all}"

case "${target}" in
  backend|rag|all)
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
esac

ensure_compose

case "${target}" in
  backend)
    run_service backend-wheels
    ;;
  rag)
    run_service rag-wheels
    ;;
  all)
    run_service backend-wheels
    run_service rag-wheels
    ;;
esac

echo "✅ Wheel download complete."
