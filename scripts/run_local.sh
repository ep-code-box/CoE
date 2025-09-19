#!/usr/bin/env bash
set -euo pipefail

# Launch the full local stack (nginx + backend + ragpipeline + infra)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-local"
COMPOSE="docker compose -f docker-compose.local.yml"

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
