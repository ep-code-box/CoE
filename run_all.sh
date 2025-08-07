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

# Docker 설치 및 실행 상태 확인
check_docker() {
    if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
        log_error "Docker 또는 Docker Compose가 설치되지 않았습니다. 먼저 설치해주세요."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker가 실행되고 있지 않습니다. Docker를 시작해주세요."
        exit 1
    fi
}

# 메인 실행 로직
main() {
    # Docker 상태 확인
    check_docker

    # 옵션에 따른 분기 처리
    if [ "$1" == "full" ]; then
        log_info "모든 서비스를 Docker Compose로 시작합니다... (docker-compose.yml)"
        docker-compose -f docker-compose.yml up -d --build
        log_success "모든 서비스가 시작되었습니다."
        echo ""
        docker-compose -f docker-compose.yml ps

    elif [ "$1" == "local" ]; then
        log_info "로컬 개발을 위해 인프라 서비스를 시작합니다... (docker-compose.local.yml)"
        docker-compose -f docker-compose.local.yml up -d --build
        log_success "인프라 서비스가 시작되었습니다."
        echo ""
        docker-compose -f docker-compose.local.yml ps

    else
        log_error "잘못된 옵션입니다."
        show_usage
        exit 1
    fi
}

# 스크립트 실행
main "$@"
