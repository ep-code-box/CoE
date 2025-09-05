#!/usr/bin/env bash
set -euo pipefail

# Rebuild and restart only Backend + RAG (Prod)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

PROJECT="coe-prod"
PROFILE="prod"
COMPOSE="docker compose -f docker-compose.full.yml"

echo "[run_prd] Building prod services: backend + rag..."
$COMPOSE -p "$PROJECT" --profile "$PROFILE" build coe-backend-prod coe-ragpipeline-prod

echo "[run_prd] Restarting prod services: backend + rag..."
$COMPOSE -p "$PROJECT" --profile "$PROFILE" up -d coe-backend-prod coe-ragpipeline-prod

echo "[run_prd] Done. Quick health checks:"
echo "  - Backend(local):  curl -I http://127.0.0.1:18000"
echo "  - RAG(local):      curl -I http://127.0.0.1:18001/rag/health"
echo "  - Edge(prod):      curl -I http://greatcoe.cafe24.com"

