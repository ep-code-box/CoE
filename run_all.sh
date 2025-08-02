#!/bin/bash

# CoE 전체 시스템 실행 스크립트
# 이 스크립트는 다양한 환경과 옵션으로 서비스를 실행합니다.

set -e  # 에러 발생 시 스크립트 중단

# 기본 설정
DEFAULT_ENV="full"
DEFAULT_MODE="all"

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
    
    local ports=(6666 6667 6668 6669 8000 8001)
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

# 환경 변수 파일 확인 및 생성
setup_env_files() {
    log_info "환경 변수 파일을 확인합니다..."

    if [ ! -f "CoE-Backend/.env" ]; then
        log_warning "CoE-Backend/.env 파일이 없습니다."
        if [ -f "CoE-Backend/.env.example" ]; then
            log_info ".env.example을 복사하여 .env 파일을 생성합니다..."
            cp CoE-Backend/.env.example CoE-Backend/.env
            log_success "CoE-Backend/.env 파일이 생성되었습니다. 필요한 값들을 설정해주세요."
        else
            log_error ".env.example 파일도 없습니다. 수동으로 .env 파일을 생성해주세요."
            exit 1
        fi
    else
        log_success "CoE-Backend/.env 파일이 존재합니다."
    fi

    if [ ! -f "CoE-RagPipeline/.env" ]; then
        log_warning "CoE-RagPipeline/.env 파일이 없습니다."
        if [ -f "CoE-RagPipeline/.env.example" ]; then
            log_info ".env.example을 복사하여 .env 파일을 생성합니다..."
            cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env
            log_success "CoE-RagPipeline/.env 파일이 생성되었습니다."
        else
            log_error ".env.example 파일도 없습니다. 수동으로 .env 파일을 생성해주세요."
            exit 1
        fi
    else
        log_success "CoE-RagPipeline/.env 파일이 존재합니다."
    fi
}

# 필요한 디렉토리 생성
create_directories() {
    log_info "필요한 디렉토리를 생성합니다..."
    
    local directories=(
        "db/chroma"
        "db/maria" 
        "db/redis"
        "CoE-Backend/flows"
        "CoE-RagPipeline/output"
        "CoE-RagPipeline/chroma_db"
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
    log_info "Docker Compose로 모든 서비스를 시작합니다..."
    
    if ! docker-compose up -d --build; then
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

    
    # MariaDB와 Redis는 헬스체크가 docker-compose.yml에 정의되어 있음
    log_info "MariaDB와 Redis 헬스체크를 확인합니다..."
    
    local healthy_services=0
    local total_services=5
    
    for i in {1..30}; do
        local mariadb_health=$(docker inspect --format='{{.State.Health.Status}}' mariadb 2>/dev/null || echo "none")
        local redis_health=$(docker inspect --format='{{.State.Health.Status}}' redis 2>/dev/null || echo "none")
        
        if [[ "$mariadb_health" == "healthy" && "$redis_health" == "healthy" ]]; then
            log_success "MariaDB와 Redis가 준비되었습니다."
            break
        fi
        
        if [ $i -eq 30 ]; then
            log_warning "MariaDB 또는 Redis 헬스체크가 완료되지 않았습니다."
        fi
        
        sleep 2
    done
    
    # 애플리케이션 서비스 확인
    wait_for_service "CoE-Backend" "http://localhost:8000/health" || true
    wait_for_service "CoE-RagPipeline" "http://localhost:8001/health" || true
    
    echo ""
    log_info "최종 서비스 상태:"
    docker-compose ps
}

# 사용법 출력
show_usage() {
    echo "🚀 CoE 시스템 실행 스크립트"
    echo ""
    echo "사용법: $0 [환경] [모드] [옵션]"
    echo ""
    echo "환경 (Environment):"
    echo "  full    - 전체 Docker 환경 (기본값)"
    echo "  local   - 로컬 개발 환경 (인프라만 Docker)"
    echo ""
    echo "모드 (Mode):"
    echo "  all       - 모든 서비스 실행 (기본값)"
    echo "  infra     - 인프라 서비스만 실행 (ChromaDB, MariaDB, Redis)"
    echo "  backend   - CoE-Backend만 실행"
    echo "  pipeline  - CoE-RagPipeline만 실행"
    echo ""
    echo "옵션 (Options):"
    echo "  --build   - 이미지 강제 재빌드"
    echo "  --clean   - 기존 컨테이너 및 볼륨 정리 후 실행"
    echo "  --help    - 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0                    # 전체 Docker 환경으로 모든 서비스 실행"
    echo "  $0 local              # 로컬 개발 환경으로 인프라만 Docker 실행"
    echo "  $0 full infra         # 전체 Docker 환경으로 인프라만 실행"
    echo "  $0 local all --build  # 로컬 환경으로 모든 서비스 실행 (재빌드)"
    echo ""
}

# 인수 파싱
parse_arguments() {
    ENV=${1:-$DEFAULT_ENV}
    MODE=${2:-$DEFAULT_MODE}
    BUILD_FLAG=""
    CLEAN_FLAG=""
    
    # 옵션 처리
    for arg in "$@"; do
        case $arg in
            --build)
                BUILD_FLAG="--build"
                ;;
            --clean)
                CLEAN_FLAG="true"
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
        esac
    done
    
    # 환경 검증
    if [[ "$ENV" != "full" && "$ENV" != "local" ]]; then
        log_error "잘못된 환경: $ENV (full 또는 local만 지원)"
        show_usage
        exit 1
    fi
    
    # 모드 검증
    if [[ "$MODE" != "all" && "$MODE" != "infra" && "$MODE" != "backend" && "$MODE" != "pipeline" ]]; then
        log_error "잘못된 모드: $MODE (all, infra, backend, pipeline만 지원)"
        show_usage
        exit 1
    fi
    
    log_info "실행 설정: 환경=$ENV, 모드=$MODE"
}

# 환경별 Docker Compose 파일 선택
get_compose_file() {
    case $ENV in
        "local")
            echo "docker-compose.local.yml"
            ;;
        "full")
            echo "docker-compose.yml"
            ;;
    esac
}

# 모드별 서비스 선택
get_services() {
    case $MODE in
        "infra")
            echo "chroma mariadb redis"
            ;;
        "backend")
            if [[ "$ENV" == "local" ]]; then
                echo "chroma mariadb redis"  # 로컬 환경에서는 인프라만
            else
                echo "chroma mariadb redis coe-backend"
            fi
            ;;
        "pipeline")
            if [[ "$ENV" == "local" ]]; then
                echo "chroma redis"  # 로컬 환경에서는 인프라만
            else
                echo "chroma redis coe-rag-pipeline"
            fi
            ;;
        "all")
            if [[ "$ENV" == "local" ]]; then
                echo "chroma mariadb redis"  # 로컬 환경에서는 인프라만
            else
                echo ""  # 모든 서비스
            fi
            ;;
    esac
}

# 기존 컨테이너 정리
clean_containers() {
    if [[ "$CLEAN_FLAG" == "true" ]]; then
        log_info "기존 컨테이너 및 볼륨을 정리합니다..."
        
        local compose_file=$(get_compose_file)
        
        if docker-compose -f "$compose_file" ps -q | grep -q .; then
            docker-compose -f "$compose_file" down -v
            log_success "기존 컨테이너 및 볼륨이 정리되었습니다."
        else
            log_info "정리할 컨테이너가 없습니다."
        fi
    fi
}

# 환경별 환경 변수 파일 설정
setup_env_files_by_environment() {
    log_info "환경별 환경 변수 파일을 설정합니다..."
    
    case $ENV in
        "local")
            # 로컬 환경용 .env 파일 복사
            if [ ! -f "CoE-Backend/.env" ]; then
                if [ -f "CoE-Backend/.env.local" ]; then
                    cp CoE-Backend/.env.local CoE-Backend/.env
                    log_success "CoE-Backend/.env.local을 .env로 복사했습니다."
                else
                    cp CoE-Backend/.env.example CoE-Backend/.env
                    log_warning "CoE-Backend/.env.example을 .env로 복사했습니다. 설정을 확인해주세요."
                fi
            fi
            
            if [ ! -f "CoE-RagPipeline/.env" ]; then
                if [ -f "CoE-RagPipeline/.env.local" ]; then
                    cp CoE-RagPipeline/.env.local CoE-RagPipeline/.env
                    log_success "CoE-RagPipeline/.env.local을 .env로 복사했습니다."
                else
                    cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env
                    log_warning "CoE-RagPipeline/.env.example을 .env로 복사했습니다. 설정을 확인해주세요."
                fi
            fi
            ;;
        "full")
            # Docker 환경용 .env 파일 확인
            if [ ! -f "CoE-Backend/.env.docker" ]; then
                cp CoE-Backend/.env.example CoE-Backend/.env.docker
                log_warning "CoE-Backend/.env.docker 파일을 생성했습니다. 설정을 확인해주세요."
            fi
            
            if [ ! -f "CoE-RagPipeline/.env.docker" ]; then
                cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env.docker
                log_warning "CoE-RagPipeline/.env.docker 파일을 생성했습니다. 설정을 확인해주세요."
            fi
            ;;
    esac
}

# Docker Compose 서비스 시작
start_services() {
    log_info "Docker Compose로 서비스를 시작합니다..."
    
    local compose_file=$(get_compose_file)
    local services=$(get_services)
    
    log_info "사용할 Compose 파일: $compose_file"
    log_info "실행할 서비스: ${services:-'모든 서비스'}"
    
    if ! docker-compose -f "$compose_file" up -d $BUILD_FLAG $services; then
        log_error "Docker Compose 실행에 실패했습니다."
        exit 1
    fi
    
    log_success "서비스가 시작되었습니다."
}

# 로컬 환경 안내
show_local_instructions() {
    if [[ "$ENV" == "local" ]]; then
        echo ""
        log_info "🔧 로컬 개발 환경 설정 안내:"
        echo ""
        
        if [[ "$MODE" == "all" || "$MODE" == "backend" ]]; then
            echo "📦 CoE-Backend 로컬 실행:"
            echo "   cd CoE-Backend"
            echo "   python -m venv .venv"
            echo "   source .venv/bin/activate  # Windows: .venv\\Scripts\\activate"
            echo "   pip install -r requirements.txt"
            echo "   python main.py"
            echo ""
        fi
        
        if [[ "$MODE" == "all" || "$MODE" == "pipeline" ]]; then
            echo "📦 CoE-RagPipeline 로컬 실행:"
            echo "   cd CoE-RagPipeline"
            echo "   python -m venv .venv"
            echo "   source .venv/bin/activate  # Windows: .venv\\Scripts\\activate"
            echo "   pip install -r requirements.txt"
            echo "   python main.py"
            echo ""
        fi
    fi
}

# 서비스 상태 확인 (환경별)
check_services() {
    log_info "서비스 상태를 확인합니다..."
    
    local compose_file=$(get_compose_file)
    
    # 기본 대기 시간
    sleep 5
    
    # ChromaDB 헬스체크
    if docker-compose -f "$compose_file" ps | grep -q chroma; then
        wait_for_service "ChromaDB" "http://localhost:6666/api/v1/heartbeat" || true
    fi
    
    # MariaDB와 Redis 헬스체크
    if docker-compose -f "$compose_file" ps | grep -q mariadb; then
        log_info "MariaDB 헬스체크를 확인합니다..."
        for i in {1..30}; do
            local mariadb_health=$(docker inspect --format='{{.State.Health.Status}}' mariadb-* 2>/dev/null | head -1 || echo "none")
            if [[ "$mariadb_health" == "healthy" ]]; then
                log_success "MariaDB가 준비되었습니다."
                break
            fi
            if [ $i -eq 30 ]; then
                log_warning "MariaDB 헬스체크가 완료되지 않았습니다."
            fi
            sleep 2
        done
    fi
    
    if docker-compose -f "$compose_file" ps | grep -q redis; then
        log_info "Redis 헬스체크를 확인합니다..."
        for i in {1..30}; do
            local redis_health=$(docker inspect --format='{{.State.Health.Status}}' redis-* 2>/dev/null | head -1 || echo "none")
            if [[ "$redis_health" == "healthy" ]]; then
                log_success "Redis가 준비되었습니다."
                break
            fi
            if [ $i -eq 30 ]; then
                log_warning "Redis 헬스체크가 완료되지 않았습니다."
            fi
            sleep 2
        done
    fi
    
    # 애플리케이션 서비스 확인 (full 환경에서만)
    if [[ "$ENV" == "full" ]]; then
        if docker-compose -f "$compose_file" ps | grep -q coe-backend; then
            wait_for_service "CoE-Backend" "http://localhost:8000/health" || true
        fi
        
        if docker-compose -f "$compose_file" ps | grep -q coe-rag-pipeline; then
            wait_for_service "CoE-RagPipeline" "http://localhost:8001/health" || true
        fi
    fi
    
    echo ""
    log_info "최종 서비스 상태:"
    docker-compose -f "$compose_file" ps
}

# 메인 실행 함수
main() {
    echo "🚀 CoE 시스템을 시작합니다..."
    echo ""
    
    parse_arguments "$@"
    check_docker
    check_ports
    clean_containers
    setup_env_files_by_environment
    create_directories
    start_services
    check_services
    show_local_instructions
    
    echo ""
    log_success "CoE 시스템이 성공적으로 시작되었습니다!"
    echo ""
    echo "📍 서비스 접속 정보:"
    echo "   - CoE-Backend (AI 에이전트): http://localhost:8000"
    echo "   - CoE-RagPipeline (분석 엔진): http://localhost:8001"
    echo "   - ChromaDB: http://localhost:6666"
    echo "   - MariaDB: localhost:6667"
    echo "   - Redis: localhost:6669"
    echo ""
    echo "📝 유용한 명령어:"
    local compose_file=$(get_compose_file)
    echo "   - 로그 확인: docker-compose -f $compose_file logs -f"
    echo "   - 특정 서비스 로그: docker-compose -f $compose_file logs -f [서비스명]"
    echo "   - 서비스 상태: docker-compose -f $compose_file ps"
    echo "   - 시스템 중지: docker-compose -f $compose_file down"
    echo "   - 완전 정리: docker-compose -f $compose_file down -v"
    echo ""
}

# 스크립트 실행
main "$@"