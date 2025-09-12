#!/usr/bin/env bash
set -euo pipefail

# Rebuild and restart only Backend + RAG (Dev)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-dev"
COMPOSE="docker compose -f docker-compose.dev.yml"

echo "[run_dev] Building dev services: backend + ragpipeline..."
$COMPOSE -p "$PROJECT" build backend ragpipeline

echo "[run_dev] Restarting dev services: backend + ragpipeline..."
$COMPOSE -p "$PROJECT" up -d backend ragpipeline

echo "[run_dev] Done. Quick health checks:"
echo "  - Backend(local):  curl -I http://127.0.0.1:18002"
echo "  - RAG(local):      curl -I http://127.0.0.1:18003/rag/health"
echo "  - Network:         docker network ls | grep coe-dev-net"
