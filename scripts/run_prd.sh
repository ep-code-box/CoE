#!/usr/bin/env bash
set -euo pipefail

# Rebuild and restart only Backend + RAG (Prod)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-prod"
COMPOSE="docker compose -f docker-compose.prod.yml"

echo "[run_prd] Building prod services: backend + ragpipeline..."
$COMPOSE -p "$PROJECT" build backend ragpipeline

echo "[run_prd] Restarting prod services: backend + ragpipeline..."
$COMPOSE -p "$PROJECT" up -d backend ragpipeline

echo "[run_prd] Done. Quick health checks:"
echo "  - Backend(local):  curl -I http://127.0.0.1:18000"
echo "  - RAG(local):      curl -I http://127.0.0.1:18001/rag/health"
echo "  - Network:         docker network ls | grep coe-prod-net"
