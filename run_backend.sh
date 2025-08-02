#!/bin/bash

# CoE-Backend 개별 실행 스크립트
# 이 스크립트는 CoE-Backend를 다양한 환경에서 실행합니다.

set -e  # 에러 발생 시 스크립트 중단

# 기본 설정
DEFAULT_ENV="local"

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

# 사용법 출력
show_usage() {
    echo "🚀 CoE-Backend 실행 스크립트"
    echo ""
    echo "사용법: $0 [환경] [옵션]"
    echo ""
    echo "환경 (Environment):"
    echo "  local   - 로컬 개발 환경 (기본값) - 인프라는 Docker, 앱은 로컬"
    echo "  docker  - Docker 환경 - 모든 서비스를 Docker로 실행"
    echo "  native  - 완전 로컬 환경 - 모든 서비스를 로컬에서 실행"
    echo ""
    echo "옵션 (Options):"
    echo "  --build   - Docker 이미지 강제 재빌드 (docker 환경에서만)"
    echo "  --clean   - 기존 컨테이너 및 볼륨 정리 후 실행"
    echo "  --help    - 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0                # 로컬 개발 환경으로 실행"
    echo "  $0 docker         # Docker 환경으로 실행"
    echo "  $0 local --clean  # 로컬 환경으로 실행 (기존 인프라 정리)"
    echo "  $0 native         # 완전 로컬 환경으로 실행"
    echo ""
}

# 인수 파싱
parse_arguments() {
    ENV=${1:-$DEFAULT_ENV}
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
    if [[ "$ENV" != "local" && "$ENV" != "docker" && "$ENV" != "native" ]]; then
        log_error "잘못된 환경: $ENV (local, docker, native만 지원)"
        show_usage
        exit 1
    fi
    
    log_info "실행 설정: 환경=$ENV"
}

# Docker 설치 및 실행 상태 확인 (local, docker 환경에서만)
check_docker() {
    if [[ "$ENV" == "native" ]]; then
        return 0
    fi
    
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

# Python 환경 확인
check_python() {
    log_info "Python 환경을 확인합니다..."
    
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3가 설치되어 있지 않습니다. Python 3.9 이상을 설치해주세요."
        exit 1
    fi
    
    local python_version=$(python3 --version | cut -d' ' -f2)
    log_success "Python $python_version이 설치되어 있습니다."
}

# 환경별 환경 변수 파일 설정
setup_env_file() {
    log_info "환경 변수 파일을 설정합니다..."
    
    cd CoE-Backend
    
    case $ENV in
        "local")
            if [ ! -f ".env" ]; then
                if [ -f ".env.local" ]; then
                    cp .env.local .env
                    log_success ".env.local을 .env로 복사했습니다."
                else
                    cp .env.example .env
                    log_warning ".env.example을 .env로 복사했습니다. 설정을 확인해주세요."
                fi
            fi
            ;;
        "docker")
            if [ ! -f ".env.docker" ]; then
                cp .env.example .env.docker
                log_warning ".env.docker 파일을 생성했습니다. 설정을 확인해주세요."
            fi
            ;;
        "native")
            if [ ! -f ".env" ]; then
                cp .env.example .env
                log_warning ".env 파일을 생성했습니다. 로컬 서비스 연결 정보를 설정해주세요."
            fi
            ;;
    esac
    
    cd ..
}

# 인프라 서비스 시작 (local 환경에서만)
start_infrastructure() {
    if [[ "$ENV" != "local" ]]; then
        return 0
    fi
    
    log_info "인프라 서비스를 시작합니다..."
    
    # 기존 컨테이너 정리
    if [[ "$CLEAN_FLAG" == "true" ]]; then
        log_info "기존 인프라 컨테이너를 정리합니다..."
        if docker-compose -f docker-compose.local.yml ps -q | grep -q .; then
            docker-compose -f docker-compose.local.yml down -v
            log_success "기존 인프라 컨테이너가 정리되었습니다."
        fi
    fi
    
    # 필요한 디렉토리 생성
    mkdir -p db/chroma db/maria db/redis
    
    # 인프라 서비스 시작
    if ! docker-compose -f docker-compose.local.yml up -d chroma mariadb redis; then
        log_error "인프라 서비스 시작에 실패했습니다."
        exit 1
    fi
    
    log_success "인프라 서비스가 시작되었습니다."
    
    # 서비스 준비 대기
    log_info "인프라 서비스가 준비될 때까지 기다립니다..."
    sleep 10
    
    # ChromaDB 헬스체크
    for i in {1..30}; do
        if curl -s http://localhost:6666/api/v1/heartbeat > /dev/null 2>&1; then
            log_success "ChromaDB가 준비되었습니다."
            break
        fi
        if [ $i -eq 30 ]; then
            log_warning "ChromaDB 헬스체크가 완료되지 않았습니다."
        fi
        sleep 2
    done
}

# Docker 환경에서 전체 시스템 시작
start_docker_environment() {
    if [[ "$ENV" != "docker" ]]; then
        return 0
    fi
    
    log_info "Docker 환경에서 CoE-Backend를 시작합니다..."
    
    # 기존 컨테이너 정리
    if [[ "$CLEAN_FLAG" == "true" ]]; then
        log_info "기존 컨테이너를 정리합니다..."
        if docker-compose ps -q | grep -q .; then
            docker-compose down -v
            log_success "기존 컨테이너가 정리되었습니다."
        fi
    fi
    
    # 필요한 디렉토리 생성
    mkdir -p db/chroma db/maria db/redis CoE-Backend/flows
    
    # 전체 시스템 시작 (Backend 포함)
    if ! docker-compose up -d $BUILD_FLAG chroma mariadb redis coe-backend; then
        log_error "Docker 환경 시작에 실패했습니다."
        exit 1
    fi
    
    log_success "Docker 환경에서 CoE-Backend가 시작되었습니다."
}

# 로컬에서 CoE-Backend 실행
run_backend_locally() {
    if [[ "$ENV" == "docker" ]]; then
        return 0
    fi
    
    log_info "CoE-Backend를 로컬에서 실행합니다..."
    
    cd CoE-Backend
    
    # 가상 환경 확인 및 생성
    if [ ! -d ".venv" ]; then
        log_info "Python 가상 환경을 생성합니다..."
        python3 -m venv .venv
        log_success "가상 환경이 생성되었습니다."
    fi
    
    # 가상 환경 활성화
    source .venv/bin/activate
    
    # 의존성 설치
    log_info "의존성을 설치합니다..."
    pip install -r requirements.txt
    
    # 서버 실행
    log_success "CoE-Backend를 시작합니다..."
    python main.py
}

# 서비스 상태 확인
check_services() {
    log_info "서비스 상태를 확인합니다..."
    
    case $ENV in
        "local")
            echo ""
            log_info "인프라 서비스 상태:"
            docker-compose -f docker-compose.local.yml ps
            ;;
        "docker")
            echo ""
            log_info "전체 서비스 상태:"
            docker-compose ps
            ;;
        "native")
            log_info "네이티브 환경에서는 서비스 상태 확인을 생략합니다."
            ;;
    esac
}

# 환경별 안내 메시지
show_environment_info() {
    echo ""
    log_success "CoE-Backend 실행 환경이 준비되었습니다!"
    echo ""
    
    case $ENV in
        "local")
            echo "📍 로컬 개발 환경:"
            echo "   - 인프라 서비스: Docker 컨테이너"
            echo "   - CoE-Backend: 로컬 Python 프로세스"
            echo ""
            echo "🔗 접속 정보:"
            echo "   - CoE-Backend: http://localhost:8000"
            echo "   - ChromaDB: http://localhost:6666"
            echo "   - MariaDB: localhost:6667"
            echo "   - Redis: localhost:6669"
            echo ""
            echo "📝 유용한 명령어:"
            echo "   - 인프라 로그: docker-compose -f docker-compose.local.yml logs -f"
            echo "   - 인프라 중지: docker-compose -f docker-compose.local.yml down"
            ;;
        "docker")
            echo "📍 Docker 환경:"
            echo "   - 모든 서비스: Docker 컨테이너"
            echo ""
            echo "🔗 접속 정보:"
            echo "   - CoE-Backend: http://localhost:8000"
            echo "   - ChromaDB: http://localhost:6666"
            echo "   - MariaDB: localhost:6667"
            echo "   - Redis: localhost:6669"
            echo ""
            echo "📝 유용한 명령어:"
            echo "   - 전체 로그: docker-compose logs -f"
            echo "   - Backend 로그: docker-compose logs -f coe-backend"
            echo "   - 전체 중지: docker-compose down"
            ;;
        "native")
            echo "📍 네이티브 환경:"
            echo "   - 모든 서비스: 로컬 프로세스"
            echo ""
            echo "🔗 접속 정보:"
            echo "   - CoE-Backend: http://localhost:8000"
            echo ""
            echo "⚠️  주의사항:"
            echo "   - ChromaDB, MariaDB, Redis를 별도로 설치하고 실행해야 합니다."
            echo "   - .env 파일에서 로컬 서비스 연결 정보를 설정해주세요."
            ;;
    esac
    echo ""
}

# 메인 실행 함수
main() {
    echo "🚀 CoE-Backend를 시작합니다..."
    echo ""
    
    parse_arguments "$@"
    check_docker
    check_python
    setup_env_file
    start_infrastructure
    start_docker_environment
    check_services
    show_environment_info
    
    # Docker 환경이 아닌 경우에만 로컬 실행
    if [[ "$ENV" != "docker" ]]; then
        run_backend_locally
    fi
}

# 스크립트 실행
main "$@"