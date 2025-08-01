#!/bin/bash

# DB와 임베딩 모델만 실행하는 스크립트
# - chroma: 벡터 데이터베이스 (포트 6666)
# - mariadb: 관계형 데이터베이스 (포트 6667)  
# - koEmbeddings: 한국어 임베딩 서비스 (포트 6668)
# - redis: 캐싱 및 세션 관리 (포트 6669)

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Docker 설치 및 실행 상태 확인
check_docker() {
    log_info "Docker 설치 및 실행 상태를 확인합니다..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다. Docker를 먼저 설치해주세요."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker가 실행되고 있지 않습니다. Docker를 시작해주세요."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose가 설치되어 있지 않습니다. Docker Compose를 먼저 설치해주세요."
        exit 1
    fi
    
    log_success "Docker 환경이 준비되었습니다."
}

# 포트 사용 여부 확인
check_ports() {
    log_info "포트 사용 상태를 확인합니다..."
    
    local ports=(6666 6667 6668 6669)
    local used_ports=()
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            used_ports+=($port)
        fi
    done
    
    if [ ${#used_ports[@]} -gt 0 ]; then
        log_warning "다음 포트들이 이미 사용 중입니다: ${used_ports[*]}"
        log_warning "기존 서비스를 중지하거나 포트를 변경해주세요."
        read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "스크립트를 중단합니다."
            exit 1
        fi
    else
        log_success "모든 포트가 사용 가능합니다."
    fi
}

# 필요한 디렉토리 생성
create_directories() {
    log_info "필요한 디렉토리를 생성합니다..."
    
    local directories=(
        "db/chroma"
        "db/maria" 
        "db/koEmbeddings"
        "db/redis"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
    done
    
    log_success "디렉토리 생성이 완료되었습니다."
}

# 서비스 헬스체크
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    log_info "${service_name} 서비스가 준비될 때까지 기다립니다..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            log_success "${service_name} 서비스가 준비되었습니다."
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    log_warning "${service_name} 서비스가 준비되지 않았습니다. (${url})"
    return 1
}

# Docker Compose 서비스 시작
start_services() {
    log_info "DB와 임베딩 서비스를 시작합니다..."
    
    # 서비스 시작 순서 고려 (의존성 순서)
    local services=("chroma" "mariadb" "koEmbeddings" "redis")
    
    if ! docker-compose up -d "${services[@]}"; then
        log_error "Docker Compose 실행에 실패했습니다."
        exit 1
    fi
    
    log_success "모든 서비스가 시작되었습니다."
}

# 서비스 상태 확인
check_services() {
    log_info "서비스 상태를 확인합니다..."
    
    # 기본 대기 시간
    sleep 5
    
    # 각 서비스 헬스체크
    wait_for_service "ChromaDB" "http://localhost:6666/api/v1/heartbeat"
    wait_for_service "Korean Embeddings" "http://localhost:6668/health"
    
    # MariaDB와 Redis는 헬스체크가 docker-compose.yml에 정의되어 있음
    log_info "MariaDB와 Redis 헬스체크를 확인합니다..."
    
    for i in {1..30}; do
        local mariadb_health=$(docker inspect --format='{{.State.Health.Status}}' mariadb 2>/dev/null || echo "none")
        local redis_health=$(docker inspect --format='{{.State.Health.Status}}' redis 2>/dev/null || echo "none")
        
        if [[ "$mariadb_health" == "healthy" && "$redis_health" == "healthy" ]]; then
            log_success "MariaDB와 Redis가 준비되었습니다."
            break
        fi
        
        if [ $i -eq 30 ]; then
            log_warning "MariaDB 또는 Redis 헬스체크가 완료되지 않았습니다."
            log_info "MariaDB 상태: $mariadb_health"
            log_info "Redis 상태: $redis_health"
        fi
        
        sleep 2
    done
    
    echo ""
    log_info "최종 서비스 상태:"
    docker-compose ps chroma mariadb koEmbeddings redis
}

# 메인 실행 함수
main() {
    echo "🚀 DB와 임베딩 서비스를 시작합니다..."
    echo ""
    
    check_docker
    check_ports
    create_directories
    start_services
    check_services
    
    echo ""
    log_success "DB와 임베딩 서비스가 성공적으로 시작되었습니다!"
    echo ""
    echo "📍 서비스 접속 정보:"
    echo "   - ChromaDB: http://localhost:6666"
    echo "   - MariaDB: localhost:6667"
    echo "   - Korean Embeddings: http://localhost:6668"
    echo "   - Redis: localhost:6669"
    echo ""
    echo "📝 유용한 명령어:"
    echo "   - 로그 확인: docker-compose logs -f chroma mariadb koEmbeddings redis"
    echo "   - 특정 서비스 로그: docker-compose logs -f [서비스명]"
    echo "   - 서비스 상태: docker-compose ps chroma mariadb koEmbeddings redis"
    echo "   - 서비스 중지: docker-compose stop chroma mariadb koEmbeddings redis"
    echo "   - 완전 정리: docker-compose down -v"
    echo ""
    echo "💡 팁: 애플리케이션 서비스를 시작하려면 './run_all.sh'를 실행하세요."
    echo ""
}

# 스크립트 실행
main "$@"