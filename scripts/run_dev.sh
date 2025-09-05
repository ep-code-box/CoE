#!/usr/bin/env bash
set -euo pipefail

# Rebuild and restart only Backend + RAG (Dev)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-dev"
PROFILE="dev"
COMPOSE="docker compose -f docker-compose.full.yml"

echo "[run_dev] Building dev services: backend + rag..."
$COMPOSE -p "$PROJECT" --profile "$PROFILE" build coe-backend-dev coe-ragpipeline-dev

echo "[run_dev] Restarting dev services: backend + rag..."
$COMPOSE -p "$PROJECT" --profile "$PROFILE" up -d coe-backend-dev coe-ragpipeline-dev

echo "[run_dev] Done. Quick health checks:"
echo "  - Backend(local):  curl -I http://127.0.0.1:18002"
echo "  - RAG(local):      curl -I http://127.0.0.1:18003/rag/health"
echo "  - Edge(dev):       curl -I http://greatcoe.cafe24.com:8080"

