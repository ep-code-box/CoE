#!/bin/bash

# CoE 전체 시스템 실행 스크립트

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 사용법 안내
show_usage() {
    echo "🚀 CoE 시스템 실행 스크립트"
    echo ""
    echo "사용법: $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  full    - Docker Compose를 사용하여 모든 서비스를 실행합니다."
    echo "  local   - 로컬 개발을 위해 인프라 서비스(DB, ChromaDB 등)만 실행합니다."
    echo ""
    echo "예시:"
    echo "  $0 full    # 모든 서비스를 Docker로 실행"
    echo "  $0 local   # 인프라만 Docker로 실행"
}

# Docker Compose 명령어 결정
get_docker_compose_cmd() {
    if command -v docker &> /dev/null; then
        if docker compose version &> /dev/null; then
            echo "docker compose"
        elif docker-compose version &> /dev/null; then
            echo "docker-compose"
        else
            echo ""
        fi
    else
        echo "" # Docker command not found
    fi
}

# Docker 설치 및 실행 상태 확인
check_docker() {
    DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd)

    if ! command -v docker &> /dev/null; then
        log_error "❌ Docker 명령어를 찾을 수 없습니다. Docker가 설치되어 있고 PATH에 추가되었는지 확인해주세요."
        exit 1
    fi

    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        log_error "❌ Docker Compose (v1 또는 v2) 명령어를 찾을 수 없습니다. Docker Compose가 설치되어 있는지 확인해주세요."
        log_error "  - Docker Desktop 사용 시: 'docker compose' (v2)가 기본 포함됩니다."
        log_error "  - 독립형 설치 시: 'docker-compose' (v1) 또는 'docker compose' (v2)를 설치해야 합니다."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "❌ Docker 데몬이 실행되고 있지 않습니다. Docker 애플리케이션을 시작해주세요."
        exit 1
    fi
}

# 메인 실행 로직
main() {
    # Docker 상태 확인
    check_docker
    DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd) # 다시 한번 설정하여 main 함수 내에서 사용 가능하게 함

    # 옵션에 따른 분기 처리
    if [ "$1" == "full" ]; then
        log_info "모든 서비스를 Docker Compose로 시작합니다... (docker-compose.yml)"
        $DOCKER_COMPOSE_CMD -f docker-compose.yml up -d --build
        log_success "모든 서비스가 시작되었습니다."
        echo ""
        $DOCKER_COMPOSE_CMD -f docker-compose.yml ps

    elif [ "$1" == "local" ]; then
        log_info "로컬 개발을 위해 인프라 서비스를 시작합니다... (docker-compose.local.yml)"
        $DOCKER_COMPOSE_CMD -f docker-compose.local.yml up -d --build
        log_success "인프라 서비스가 시작되었습니다."
        echo ""
        $DOCKER_COMPOSE_CMD -f docker-compose.local.yml ps

    else
        log_error "잘못된 옵션입니다."
        show_usage
        exit 1
    fi
}

# 스크립트 실행
main "$@"
