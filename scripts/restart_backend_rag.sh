#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
BACKEND_DIR="$ROOT_DIR/CoE-Backend"
RAG_DIR="$ROOT_DIR/CoE-RagPipeline"

LOG_ROOT="$ROOT_DIR/logs/background"
mkdir -p "$LOG_ROOT"

stop_service() {
    local label="$1"
    local pattern="$2"

    if pgrep -f "$pattern" >/dev/null 2>&1; then
        echo "[stop] Stopping $label processes matching pattern: $pattern"
        pkill -f "$pattern" || true
        sleep 2
    else
        echo "[stop] No running $label processes found for pattern: $pattern"
    fi
}

update_repo() {
    local dir="$1"
    echo "[git] Updating $(basename "$dir")"
    git -C "$dir" fetch --all --prune
    git -C "$dir" pull --ff-only
}

start_service() {
    local dir="$1"
    local label="$2"
    local log_file="$LOG_ROOT/${label}.log"

    echo "[start] Launching $label (logs -> $log_file)"
    (
        cd "$dir"
        nohup ./run.sh >"$log_file" 2>&1 &
        echo $! > "$LOG_ROOT/${label}.pid"
    )
}

# Stop existing processes for both services
stop_service "CoE-Backend" "$BACKEND_DIR"
stop_service "CoE-RagPipeline" "$RAG_DIR"

# Update repositories
update_repo "$BACKEND_DIR"
update_repo "$RAG_DIR"

# Start services in background
start_service "$BACKEND_DIR" "backend"
start_service "$RAG_DIR" "rag"

echo "[done] Backend and RAG services restarted. PID files stored in $LOG_ROOT."
