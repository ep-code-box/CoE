#!/usr/bin/env bash

set -euo pipefail

# Color codes for readable logging
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_usage() {
    cat <<'USAGE'
🚀 CoE 시스템 Podman 실행 스크립트

사용법: ./run_all_podman.sh <full|local> [--with-monitoring]

옵션 설명:
  full                 - podman compose로 모든 서비스를 실행합니다.
  local                - 로컬 개발용 인프라 서비스만 실행합니다.
  --with-monitoring    - (선택) Loki + Promtail + Grafana 모니터링 스택 실행

예시:
  ./run_all_podman.sh full
  ./run_all_podman.sh local --with-monitoring
USAGE
}

PODMAN_COMPOSE_BIN=""
PODMAN_COMPOSE_SUBCMD=""

get_podman_compose_cmd() {
    if command -v podman >/dev/null 2>&1; then
        if podman compose version >/dev/null 2>&1; then
            PODMAN_COMPOSE_BIN="podman"
            PODMAN_COMPOSE_SUBCMD="compose"
            return
        fi
    fi

    if command -v podman-compose >/dev/null 2>&1; then
        PODMAN_COMPOSE_BIN="podman-compose"
        PODMAN_COMPOSE_SUBCMD=""
        return
    fi

    PODMAN_COMPOSE_BIN=""
    PODMAN_COMPOSE_SUBCMD=""
}

check_podman() {
    if ! command -v podman >/dev/null 2>&1; then
        log_error "Podman 명령어를 찾을 수 없습니다. Podman을 설치하고 PATH를 확인해주세요."
        exit 1
    fi

    if ! podman info >/dev/null 2>&1; then
        log_error "Podman 환경에 접속할 수 없습니다. 'podman machine start' 또는 Podman 데몬 실행 상태를 확인해주세요."
        exit 1
    fi

    get_podman_compose_cmd

    if [[ -z "$PODMAN_COMPOSE_BIN" ]]; then
        log_error "Podman Compose 명령어를 찾을 수 없습니다. 'podman compose' 플러그인 또는 'podman-compose'를 설치해주세요."
        exit 1
    fi
}

run_compose() {
    local file=$1
    shift

    if [[ "$PODMAN_COMPOSE_BIN" == "podman" ]]; then
        podman compose -f "$file" "$@"
    else
        podman-compose -f "$file" "$@"
    fi
}

main() {
    if [[ $# -lt 1 ]]; then
        log_error "실행 모드가 필요합니다."
        show_usage
        exit 1
    fi

    check_podman

    local mode=$1
    shift || true

    local with_monitoring=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --with-monitoring)
                with_monitoring=true
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                show_usage
                exit 1
                ;;
        esac
        shift || true
    done

    case "$mode" in
        full)
            log_info "모든 서비스를 Podman Compose로 시작합니다... (docker-compose.yml)"
            run_compose docker-compose.yml up -d --build
            log_success "모든 서비스가 시작되었습니다."
            run_compose docker-compose.yml ps

            if [[ "$with_monitoring" == true ]]; then
                log_info "모니터링 스택을 시작합니다... (docker-compose.monitoring.yml)"
                run_compose docker-compose.monitoring.yml up -d --build
                log_success "모니터링 스택이 시작되었습니다. Grafana: http://127.0.0.1:3000  Loki: http://127.0.0.1:3100"
            fi
            ;;
        local)
            log_info "로컬 개발 인프라 서비스를 Podman Compose로 시작합니다... (docker-compose.local.yml)"
            run_compose docker-compose.local.yml up -d --build
            log_success "인프라 서비스가 시작되었습니다."
            run_compose docker-compose.local.yml ps

            if [[ "$with_monitoring" == true ]]; then
                log_info "모니터링 스택을 시작합니다... (docker-compose.monitoring.yml)"
                run_compose docker-compose.monitoring.yml up -d --build
                log_success "모니터링 스택이 시작되었습니다. Grafana: http://127.0.0.1:3000  Loki: http://127.0.0.1:3100"
            fi
            ;;
        *)
            log_error "지원하지 않는 실행 모드입니다: $mode"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
