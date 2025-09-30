#!/usr/bin/env bash
set -euo pipefail

# Rebuild and restart only Backend + RAG (Dev)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-dev"
COMPOSE="docker compose -f docker-compose.dev.yml"

PID_SRC="$ROOT_DIR/docs/pid-1.3.19/pidpy-1.3.19-py3-none-linux_x86_64.whl"
PID_DEST="$ROOT_DIR/CoE-Backend/vendor/pidpy/pidpy-1.3.19-py3-none-linux_x86_64.whl"

if [ -f "$PID_SRC" ]; then
  mkdir -p "$(dirname "$PID_DEST")"
  if [ ! -f "$PID_DEST" ] || ! cmp -s "$PID_SRC" "$PID_DEST"; then
    echo "[run_dev] Copying pidpy wheel into backend vendor..."
    cp "$PID_SRC" "$PID_DEST"
  fi
else
  echo "[run_dev] WARNING: pidpy wheel not found at $PID_SRC" >&2
fi

echo "[run_dev] Building dev services: backend + ragpipeline..."
$COMPOSE -p "$PROJECT" build backend ragpipeline

echo "[run_dev] Restarting dev services: backend + ragpipeline..."
$COMPOSE -p "$PROJECT" up -d backend ragpipeline

echo "[run_dev] Done. Quick health checks:"
echo "  - Backend(local):  curl -I http://127.0.0.1:18002"
echo "  - RAG(local):      curl -I http://127.0.0.1:18003/rag/health"
echo "  - Network:         docker network ls | grep coe-dev-net"
