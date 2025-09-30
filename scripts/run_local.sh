#!/usr/bin/env bash
set -euo pipefail

# Launch the full local stack (nginx + backend + ragpipeline + infra)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-local"
COMPOSE="docker compose -f docker-compose.local.yml"

PID_SRC="$ROOT_DIR/docs/pid-1.3.19/pidpy-1.3.19-py3-none-linux_x86_64.whl"
PID_DEST="$ROOT_DIR/CoE-Backend/vendor/pidpy/pidpy-1.3.19-py3-none-linux_x86_64.whl"

if [ -f "$PID_SRC" ]; then
  mkdir -p "$(dirname "$PID_DEST")"
  if [ ! -f "$PID_DEST" ] || ! cmp -s "$PID_SRC" "$PID_DEST"; then
    echo "[run_local] Copying pidpy wheel into backend vendor..."
    cp "$PID_SRC" "$PID_DEST"
  fi
else
  echo "[run_local] WARNING: pidpy wheel not found at $PID_SRC" >&2
fi

echo "[run_local] Building local images (backend, ragpipeline)..."
$COMPOSE -p "$PROJECT" build backend ragpipeline

echo "[run_local] Starting local stack..."
$COMPOSE -p "$PROJECT" up -d setup-local-ssl mariadb redis chroma backend ragpipeline nginx

DB_USER=${MARIADB_USER:-coe_user}
DB_PASSWORD=${MARIADB_PASSWORD:-coe_password}
DB_NAME=${MARIADB_DATABASE:-coe_db}

echo "[run_local] Stack is up. Useful checks:"
echo "  - Nginx proxy: curl -I https://localhost --insecure"
echo "  - Backend logs: $COMPOSE -p $PROJECT logs -f backend"
echo "  - RAG logs:     $COMPOSE -p $PROJECT logs -f ragpipeline"
echo "  - MariaDB:      mysql -h 127.0.0.1 -P 6667 -u\"$DB_USER\" -p\"$DB_PASSWORD\" $DB_NAME"
