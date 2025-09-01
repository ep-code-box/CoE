#!/bin/bash

# CoE 전체 시스템 중지 스크립트

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_error() {
    echo -e "${RED}❌ $1${NC}"
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

echo "🛑 CoE 시스템을 중지합니다..."

# Docker Compose로 모든 서비스 중지
$DOCKER_COMPOSE_CMD down

echo ""
echo "🧹 완전 정리를 원하시나요? (볼륨과 이미지까지 삭제)"
echo "1) 일반 중지 (데이터 보존)"
echo "2) 볼륨까지 삭제 (데이터 삭제)"
echo "3) 볼륨과 이미지까지 삭제 (완전 정리)"
echo ""
read -p "선택하세요 (1-3, 기본값: 1): " choice

case $choice in
    2)
        echo "🗑️  볼륨까지 삭제합니다..."
        $DOCKER_COMPOSE_CMD down -v
        ;;
    3)
        echo "🗑️  볼륨과 이미지까지 삭제합니다..."
        $DOCKER_COMPOSE_CMD down -v --rmi all
        ;;
    *)
        echo "✅ 일반 중지가 완료되었습니다. 데이터는 보존됩니다."
        ;;
esac

echo ""
echo "✅ CoE 시스템이 중지되었습니다."
echo ""
