# 🤖 CoE: AI 기반 소프트웨어 개발 분석 및 가이드 자동화 플랫폼

**CoE for AI** 프로젝트는 소프트웨어 개발의 효율성과 품질을 극대화하기 위해 설계된 AI 기반 자동화 플랫폼입니다. Git 레포지토리를 심층적으로 분석하고, 그 결과를 바탕으로 표준 개발 가이드, 공통 코드, 공통 함수 등을 자동으로 생성하여 개발팀의 생산성을 높이는 것을 목표로 합니다.

이 프로젝트는 두 개의 핵심 마이크로서비스와 완전한 인프라 스택으로 구성되어 있습니다:

1.  **`CoE-Backend`**: LangGraph 기반 AI 에이전트 및 FastAPI 서버 (포트 8000)
2.  **`CoE-RagPipeline`**: Git 분석 및 RAG 파이프라인 엔진 (포트 8001)
3.  **인프라 서비스**: ChromaDB, MariaDB, Redis

## ✨ 주요 기능

### 🔍 코드 분석 및 처리
- **스마트 Git 분석**: 레포지토리 클론, AST 분석, 기술 스택 감지, 의존성 분석
- **Commit 기반 변경 감지**: 동일 commit은 기존 결과 재사용, 변경 시에만 새로운 분석 수행으로 효율성 극대화 ⭐ **NEW**
- **레포지토리간 연관관계 분석**: 공통 의존성, 코드 패턴, API 호출 관계, 개발자 협업 네트워크 분석
- **다중 언어 지원**: Python, JavaScript, TypeScript, Java, C++, C#, Go, Rust, Kotlin, Swift (10개 언어)
- **벡터 검색**: ChromaDB 기반 고성능 벡터 검색 및 RAG 시스템
- **분석별 RAG 검색**: analysis_id 기반으로 특정 분석 결과만 검색하여 정확도 향상 ⭐ **NEW**
- **실시간 임베딩**: OpenAI 임베딩 모델 지원

### 🤖 AI 에이전트 및 도구
- **LangGraph 에이전트**: SKAX 모델(Claude-3-Sonnet) 기반 동적 도구 라우팅 및 자동 도구 등록 시스템
- **지능형 도구 선택**: 의미적 유사성 기반 도구 선택 및 코사인 유사도 최적화
- **코딩 어시스턴트**: 코드 생성, 리팩토링, 리뷰, 테스트 생성 (10개 언어 지원)
- **LLM 기반 문서 자동 생성**: 분석 결과를 바탕으로 7가지 타입의 개발 문서 자동 생성 ⭐ **NEW**
  - 개발 가이드, API 문서, 아키텍처 개요, 코드 리뷰 요약, 기술 명세서, 배포 가이드, 문제 해결 가이드
- **마크다운 리포트 자동 생성**: 분석 완료 시 상세한 마크다운 형식의 분석 리포트 자동 생성 ⭐ **NEW**
- **OpenWebUI 호환**: 표준 OpenAI API 규격 지원

### 🔐 사용자 관리 및 보안
- **JWT 기반 인증**: FastAPI-Users를 활용한 안전한 사용자 인증 및 세션 관리
- **3턴 멀티턴 대화**: 사용자별 대화 세션 관리 및 자동 요약 기능
- **권한 기반 접근 제어**: 역할별 권한 관리 (admin, user, developer)
- **대화 히스토리 관리**: 모든 채팅 메시지 데이터베이스 저장 및 컨텍스트 유지

### 🔧 통합 및 확장성
- **모듈형 아키텍처**: 도구 레지스트리 패턴으로 코드 수정 없이 기능 확장
- **LangFlow 연동**: 워크플로우 저장 및 관리 API
- **다중 LLM 지원**: OpenAI, Anthropic, SKAX(SKAX) 등 다양한 LLM 제공업체 지원
- **영구 저장소**: 모든 분석 결과를 JSON 형태로 저장하여 서버 재시작 후에도 유지 ⭐ **NEW**
- **완전한 Docker 지원**: 5개 서비스 통합 Docker Compose 환경 (ChromaDB, MariaDB, Redis 포함)

## 🏗️ 시스템 아키텍처

CoE 플랫폼은 마이크로서비스 아키텍처로 설계되어 각 서비스가 독립적으로 동작하면서 유기적으로 연동합니다.

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                CoE Platform                                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│  User Interface Layer                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                    │
│  │   OpenWebUI     │  │   LangFlow      │  │   Direct API    │                    │
│  │   (Chat UI)     │  │  (Workflow)     │  │   (REST/cURL)   │                    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                    │
├─────────────────────────────────────────────────────────────────────────────────────┤
│  Application Layer                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│  │                        CoE-Backend (Port 8000)                                 │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │ │
│  │  │  LangGraph      │  │  Coding         │  │  Vector         │                │ │
│  │  │  Agent          │  │  Assistant      │  │  Search         │                │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘                │ │
│  └─────────────────────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│  │                     CoE-RagPipeline (Port 8001)                                │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │ │
│  │  │  Git Analysis   │  │  AST Parser     │  │  Embedding      │                │ │
│  │  │  Engine         │  │  & Tech Stack   │  │  Service        │                │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘                │ │
│  └─────────────────────────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────┤
│  Infrastructure Layer                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐                    │
│  │   ChromaDB      │  │    MariaDB      │  │     Redis     │                    │
│  │  (Vector DB)    │  │  (Relational)   │  │  (Cache/Sess) │                    │
│  │  (Port 6666)    │  │  (Port 6667)    │  │  (Port 6669)  │                    │
│  └─────────────────┘  └─────────────────┘  └───────────────┘                    │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 🔄 워크플로우
1. **분석 요청**: 사용자가 Git 레포지토리 분석을 CoE-RagPipeline에 요청
2. **스마트 분석 결정**: Commit hash 기준으로 변경사항 감지, 동일 commit은 기존 결과 재사용 ⭐ **NEW**
3. **코드 분석**: AST 분석, 기술 스택 감지, 의존성 분석, 레포지토리간 연관관계 추출 수행
4. **문서 수집**: README, doc 폴더, 참조 URL에서 개발 문서 자동 수집
5. **벡터화**: 분석 결과 및 문서를 임베딩하여 ChromaDB에 저장 (analysis_id별 분리 저장)
6. **자동 리포트 생성**: 분석 완료 시 마크다운 형식의 상세 분석 리포트 자동 생성 ⭐ **NEW**
7. **LLM 문서 생성**: 분석 결과를 바탕으로 7가지 타입의 개발 문서 자동 생성 ⭐ **NEW**
8. **결과 제공**: 표준 개발 가이드, 공통 코드화 가이드, 재활용 함수 가이드를 사용자에게 제공
9. **대화형 상호작용**: OpenWebUI를 통해 생성된 가이드에 대한 질의응답 및 추가 분석

## 📂 프로젝트 구조

```
CoE/
├── CoE-Backend/            # LangGraph 에이전트 및 FastAPI 서버
│   ├── tools/              # 도구 레지스트리 패턴 (자동 등록)
│   ├── api/                # API 엔드포인트 (21개)
│   ├── core/               # 핵심 비즈니스 로직
│   ├── services/           # 서비스 레이어
│   ├── Dockerfile
│   ├── main.py
│   └── README.md
├── CoE-RagPipeline/        # Git 분석 및 RAG 파이프라인
│   ├── analyzers/          # Git/AST 분석 엔진
│   ├── services/           # LLM 문서 생성 서비스
│   ├── routers/            # API 라우터 (문서 생성 포함)
│   ├── output/             # 분석 결과 저장소
│   │   ├── results/        # JSON 분석 결과
│   │   ├── markdown/       # 마크다운 리포트
│   │   └── documents/      # LLM 생성 문서
│   ├── Dockerfile
│   ├── main.py
│   └── README.md
├── db/                     # 데이터베이스 스키마 및 마이그레이션
│   ├── init/               # 초기 설정 스크립트
│   ├── migrate/            # 마이그레이션 스크립트
│   └── README.md
├── docs/                   # 프로젝트 문서
├── run_all.sh              # 통합 실행 스크립트
├── run_backend.sh          # Backend 개별 실행
├── run_pipeline.sh         # Pipeline 개별 실행
├── stop_all.sh             # 전체 중지 스크립트
├── docker-compose.yml      # 전체 Docker 환경
├── docker-compose.local.yml # 로컬 개발 환경
├── .gitignore
└── README.md               # 현재 보고 있는 파일
```

## 🚀 시작하기

### 전제 조건

시작하기 전에 다음 소프트웨어가 설치되어 있는지 확인하세요:

- **Docker** (20.10 이상) 및 **Docker Compose** (2.0 이상)
- **Git** (레포지토리 클론용)
- **Python 3.9+** (로컬 개발 시)

### 1. 프로젝트 클론 및 초기 설정

```bash
# 프로젝트 클론
git clone <repository-url>
cd CoE

# 서브모듈 초기화 (있는 경우)
git submodule update --init --recursive
```

### 2. 환경 변수 설정 ⭐ **환경별 .env 파일 관리**

CoE 프로젝트는 각 서비스 디렉토리 내의 `.env` 파일을 통해 환경 변수를 관리합니다. 로컬 개발 환경과 Docker 환경 모두에서 일관된 설정을 유지하면서도, 각 환경의 특성에 맞게 자동으로 환경 변수가 로드되도록 설계되었습니다.

**환경 변수 설정 방법:**
각 서비스 디렉토리(`CoE-Backend`, `CoE-RagPipeline`)로 이동하여 `.env.example` 파일을 `.env` 또는 `.env.local`로 복사하고 필요한 API 키를 설정합니다.

```bash
# CoE-Backend 설정
cd CoE-Backend
cp .env.example .env.local # 로컬 개발 시 .env.local 사용
# 또는 cp .env.example .env # Docker 환경에서 직접 빌드 시 .env 사용
# API 키만 설정하면 됩니다 - 나머지는 자동으로 환경에 맞게 적용

# CoE-RagPipeline 설정  
cd ../CoE-RagPipeline
cp .env.example .env.local # 로컬 개발 시 .env.local 사용
# 또는 cp .env.example .env # Docker 환경에서 직접 빌드 시 .env 사용
# API 키만 설정하면 됩니다 - 나머지는 자동으로 환경에 맞게 적용

cd ..
```

**필수 설정 항목 (API 키만 설정하면 됩니다):**
```bash
# SKAX API 설정 (메인 LLM용)
SKAX_API_KEY=your_skax_api_key_here

# OpenAI API 설정 (임베딩용)
OPENAI_API_KEY=your_openai_api_key_here
```

**자동 환경 감지 및 오버라이드:**
- **로컬 개발**: `run.sh` 스크립트가 `.env.local` 파일을 로드하여 `localhost` 기반의 인프라 서비스(MariaDB, ChromaDB, Redis)에 연결합니다.
- **Docker 환경**: `docker-compose.yml` 파일이 컨테이너 내부에서 사용할 환경 변수를 자동으로 오버라이드하여 서비스 이름(예: `mariadb`, `chroma`, `redis`) 기반으로 연결합니다.

#### 📋 환경별 설정 차이

| 설정 항목 | 로컬 환경 (.env.local 기본값) | Docker 환경 (오버라이드) |
|-----------|------------------------|-------------------------|
| **데이터베이스** |
| DB_HOST | localhost | mariadb |
| DB_PORT | 6667 | 3306 |
| **ChromaDB** |
| CHROMA_HOST | localhost | chroma |
| CHROMA_PORT | 6666 | 8000 |
| **Redis** |
| REDIS_HOST | localhost | redis |
| REDIS_PORT | 6669 | 6379 |
| **애플리케이션** |
| APP_ENV | development | production |
| DEBUG | true | false |
| LOG_LEVEL | DEBUG | INFO |
| RELOAD | true | false |

#### 🔧 .env 파일 구조 예시

```bash
# ===================================================================
# CoE 환경 설정 파일 예시
# ===================================================================
# 이 파일은 각 서비스 디렉토리 내에 위치하며, 로컬 개발 및 Docker 환경에서 사용됩니다.
# 
# 사용법:
# - 로컬 개발: .env.example을 .env.local로 복사하여 사용 (run.sh 스크립트가 자동 로드)
# - Docker 환경: docker-compose.yml에서 환경 변수로 오버라이드되거나,
#                Dockerfile 빌드 시 .env 파일을 복사하여 사용될 수 있습니다.
# 
# 환경 변수 우선순위:
# 1. 시스템 환경 변수 (Docker에서 설정)
# 2. .env 파일의 설정값 (로컬 개발용 기본값)
# ===================================================================

# === API 키 사용 정책 ===
# SKAX_API_KEY: ax4 모델(sktax provider) 전용
# OPENAI_API_KEY: OpenAI 서비스(임베딩, GPT 모델 등) 전용

# SKAX API 설정 (메인 LLM용 - ax4 모델)
SKAX_API_BASE=https://guest-api.sktax.chat/v1
SKAX_API_KEY=[YOUR_SKAX_API_KEY]
SKAX_MODEL_NAME=ax4

# OpenAI API 설정
OPENAI_API_KEY=[YOUR_OPENAI_API_KEY]
OPENAI_EMBEDDING_MODEL_NAME=text-embedding-3-large

# === 데이터베이스 설정 ===
# 로컬 환경 기본값: localhost:6667
# Docker 환경에서는 docker-compose.yml에서 mariadb:3306으로 오버라이드
DB_HOST=localhost
DB_PORT=6667
DB_USER=coe_user
DB_PASSWORD=coe_password
DB_NAME=coe_db

# === ChromaDB 설정 ===
# 로컬 환경 기본값: localhost:6666
# Docker 환경에서는 docker-compose.yml에서 chroma:8000으로 오버라이드
CHROMA_HOST=localhost
CHROMA_PORT=6666
CHROMA_COLLECTION_NAME=coe_documents

# === Redis 설정 ===
# 로컬 환경 기본값: localhost:6669
# Docker 환경에서는 docker-compose.yml에서 redis:6379로 오버라이드
REDIS_HOST=localhost
REDIS_PORT=6669
REDIS_PASSWORD=coe_redis_password
REDIS_AUTH_DB=1

# === JWT 인증 설정 ===
JWT_SECRET_KEY=your-super-secret-jwt-key-change-this-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# === 보안 설정 ===
ENFORCE_AUTH=false
RATE_LIMIT_PER_MINUTE=60

# === 애플리케이션 환경 ===
# 로컬 환경 기본값: development
# Docker 환경에서는 docker-compose.yml에서 production으로 오버라이드
APP_ENV=development

# === Git 분석 설정 ===
MAX_REPO_SIZE_MB=500
ANALYSIS_TIMEOUT_MINUTES=30

# === 개발 설정 ===
# 로컬 환경 기본값
# Docker 환경에서는 docker-compose.yml에서 오버라이드
DEBUG=true
LOG_LEVEL=DEBUG
RELOAD=true
```

#### 🚀 로컬 개발 환경 설정 가이드

##### 미리 만들어둔 .sh 스크립트 활용 (권장)

```bash
# 1. 인프라 서비스만 Docker로 실행
docker-compose -f docker-compose.local.yml up -d

# 2. 각 애플리케이션을 .sh 스크립트로 실행 (.venv 가상환경 자동 생성/활성화)
cd CoE-Backend
./run.sh

# 새 터미널에서
cd CoE-RagPipeline  
./run.sh
```

##### 📦 .venv 가상환경 자동 관리

각 `run.sh` 스크립트는 다음 작업을 자동으로 수행합니다:

- **가상환경 자동 생성**: `.venv` 디렉토리가 없으면 `python3 -m venv .venv`로 생성
- **가상환경 활성화**: `source .venv/bin/activate` 자동 실행
- **의존성 자동 설치**: `pip install -r requirements.txt` 자동 실행
- **환경변수 로드**: `.env.local` 파일에서 환경변수 자동 로드
- **서버 실행**: 설정된 환경에서 `python main.py` 실행

##### 🔧 환경 설정 파일

각 애플리케이션은 `.env.local` 파일을 사용합니다:

```bash
# CoE-Backend/.env.local 생성
cd CoE-Backend
cp .env.example .env.local
# API 키 등 필요한 설정 편집

# CoE-RagPipeline/.env.local 생성  
cd CoE-RagPipeline
cp .env.example .env.local
# API 키 등 필요한 설정 편집
```

##### 🔄 수동 실행 방식 (선택사항)

스크립트 없이 수동으로 실행하려면:

```bash
# 1. 인프라 서비스만 Docker로 실행
docker-compose -f docker-compose.local.yml up -d

# 2. 각 애플리케이션 수동 실행
cd CoE-Backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py

# 새 터미널에서
cd CoE-RagPipeline
python3 -m venv .venv
source .venv/bin/activate  
pip install -r requirements.txt
python main.py
```

**설정값**: .env.local 파일의 기본값 사용

## 🔧 문제 해결 (Troubleshooting)

### macOS에서 chroma-hnswlib 컴파일 오류

**문제**: macOS에서 ChromaDB 설치 시 다음과 같은 오류가 발생할 수 있습니다:
```
clang++: error: unsupported argument 'native' to option '-march='
error: command '/usr/bin/clang++' failed with exit code 1
```

**원인**: macOS의 clang++ 컴파일러는 `-march=native` 플래그를 지원하지 않습니다.

**해결방법**:
1. **환경변수 설정**: 터미널에서 다음 명령어를 실행하세요:
   ```bash
   export HNSWLIB_NO_NATIVE=1
   ```

2. **자동 해결**: 프로젝트의 `run.sh` 스크립트는 이미 이 환경변수를 자동으로 설정하므로, 스크립트를 사용하면 문제가 자동으로 해결됩니다.

3. **수동 설치**: 직접 pip install을 실행하는 경우:
   ```bash
   export HNSWLIB_NO_NATIVE=1
   pip install chromadb
   ```

**참고**: 이 설정은 CoE-Backend와 CoE-RagPipeline의 `run.sh` 스크립트에 이미 포함되어 있습니다.
- DB_HOST=localhost, DB_PORT=6667
- CHROMA_HOST=localhost, CHROMA_PORT=6666
- REDIS_HOST=localhost, REDIS_PORT=6669

### 3. 다양한 실행 환경 옵션

CoE 시스템은 개발 및 배포 환경에 맞춰 다양한 실행 옵션을 제공합니다.

#### 🚀 통합 실행 스크립트 (권장)

**전체 시스템 실행:**
```bash
# 전체 Docker 환경으로 모든 서비스 실행 (기본값)
./run_all.sh

# 로컬 개발 환경으로 인프라만 Docker 실행
./run_all.sh local

# 인프라 서비스만 실행
./run_all.sh full infra

# 기존 컨테이너 정리 후 실행
./run_all.sh full all --clean

# 이미지 재빌드 후 실행
./run_all.sh full all --build

# 도움말 확인
./run_all.sh --help
```

#### 🔧 개별 서비스 실행

**CoE-Backend 개별 실행:**
```bash
# 로컬 개발 환경 (인프라는 Docker, 앱은 로컬)
./run_backend.sh local

# 완전 Docker 환경
./run_backend.sh docker

# 도움말 확인
./run_backend.sh --help
```

**CoE-RagPipeline 개별 실행:**
```bash
# 로컬 개발 환경 (인프라는 Docker, 앱은 로컬)
./run_pipeline.sh local

# 완전 Docker 환경
./run_pipeline.sh docker

# 도움말 확인
./run_pipeline.sh --help
```

#### 📋 환경별 특징

| 환경 | 설명 | 인프라 | 애플리케이션 | 용도 |
|------|------|--------|-------------|------|
| **full** | 전체 Docker 환경 | Docker | Docker | 배포, 통합 테스트 |
| **local** | 로컬 개발 환경 | Docker | 로컬 Python | 개발, 디버깅 |
| **native** | 완전 로컬 환경 | 로컬 설치 | 로컬 Python | 네이티브 개발 |

#### 🐳 수동 Docker Compose 명령어

**전체 Docker 환경:**
```bash
# 모든 서비스 빌드 및 실행
docker-compose up -d --build

# 로그 확인
docker-compose logs -f

# 특정 서비스 로그 확인
docker-compose logs -f coe-backend
docker-compose logs -f coe-rag-pipeline

# 서비스 중지
docker-compose down

# 볼륨까지 삭제하여 완전 정리
docker-compose down -v
```

**로컬 개발 환경:**
```bash
# 인프라 서비스만 실행
docker-compose -f docker-compose.local.yml up -d

# 인프라 서비스 중지
docker-compose -f docker-compose.local.yml down
```

#### 🔄 시스템 중지

```bash
# 전체 시스템 중지
./stop_all.sh

# 또는 수동으로
docker-compose down
docker-compose -f docker-compose.local.yml down
```

**실행되는 서비스들:**
- **ChromaDB**: 벡터 데이터베이스 - 코드/문서 임베딩, analysis_id별 분리 저장 (포트 6666)
- **MariaDB**: 관계형 데이터베이스 - 사용자 관리, 채팅 히스토리, 분석 결과, 문서 생성 작업 저장 (포트 6667)  
- **Redis**: 캐싱 및 세션 관리 - JWT 토큰, 임베딩 캐시, 대화 세션 (포트 6669)
- **CoE-Backend**: AI 에이전트 및 API 서버 - LangGraph, 인증, 도구 라우팅, 멀티턴 대화 (포트 8000)
- **CoE-RagPipeline**: Git 분석 및 RAG 파이프라인 - 스마트 분석, LLM 문서 생성, 마크다운 리포트 (포트 8001)

### 📊 시스템 상태 확인

시스템이 정상적으로 실행되었는지 확인하려면:

```bash
# 모든 컨테이너 상태 확인
docker-compose ps

# 헬스체크 확인
curl http://localhost:8000/health  # CoE-Backend
curl http://localhost:8001/health  # CoE-RagPipeline

# 서비스별 로그 확인
docker-compose logs -f coe-backend
docker-compose logs -f coe-rag-pipeline
```



### 5. 로컬 개발 가이드

로컬 개발 환경에서는 인프라는 Docker로, 애플리케이션은 로컬 Python으로 실행합니다.

#### 📦 CoE-Backend 로컬 개발

```bash
# 1. 인프라 서비스 시작
./run_backend.sh local

# 또는 수동으로
docker-compose -f docker-compose.local.yml up -d chroma mariadb redis

# 2. 별도 터미널에서 Backend 실행
cd CoE-Backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

#### 📦 CoE-RagPipeline 로컬 개발

```bash
# 1. 인프라 서비스 시작
./run_pipeline.sh local

# 또는 수동으로
docker-compose -f docker-compose.local.yml up -d chroma redis

# 2. 별도 터미널에서 Pipeline 실행
cd CoE-RagPipeline
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

#### 🔍 개발 환경 장점

- **빠른 재시작**: 코드 변경 시 Python 프로세스만 재시작
- **디버깅 용이**: IDE에서 직접 디버깅 가능
- **로그 확인**: 콘솔에서 직접 로그 확인
- **핫 리로딩**: 코드 변경 시 자동 재시작 (개발 모드)

## 📚 Swagger UI로 API 테스트하기

CoE 프로젝트의 모든 API는 **Swagger UI**를 통해 쉽게 테스트할 수 있습니다!

### 🔗 Swagger UI 접근
- **CoE-Backend**: http://localhost:8000/docs
- **CoE-RagPipeline**: http://localhost:8001/docs

### 🎯 주요 기능 테스트
1. **AI 채팅**: `/v1/chat/completions`에서 CoE 에이전트와 대화
2. **Git 분석**: `/api/v1/analyze`로 레포지토리 분석 시작
3. **벡터 검색**: `/api/v1/search`로 코드/문서 검색
4. **코딩 어시스턴트**: `/api/coding-assistant/`로 코드 생성/분석

자세한 사용법은 [Swagger UI 가이드](docs/SWAGGER_GUIDE.md)를 참고하세요.

## 📖 사용 예시: 개발 가이드 추출하기

### 🔍 1단계: Git 레포지토리 분석

```bash
# CoE-RagPipeline에 분석 요청 (CoE 프로젝트 레포지토리들)
curl -X POST "http://localhost:8001/api/v1/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "repositories": [
      {
        "url": "https://github.com/ep-code-box/CoE.git",
        "branch": "main"
      },
      {
        "url": "https://github.com/ep-code-box/CoE-RagPipeline.git",
        "branch": "main"
      },
      {
        "url": "https://github.com/ep-code-box/CoE-Backend.git",
        "branch": "main"
      }
    ],
    "include_ast": true,
    "include_tech_spec": true,
    "include_correlation": true
  }'

# 스마트 분석 응답 예시:
# 새로운 분석: {"analysis_id": "3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c", "status": "started"}
# 기존 결과 재사용: {"analysis_id": "existing-id", "status": "existing", "message": "동일 commit으로 기존 결과 사용"}
```

### 🤖 2단계: LLM 기반 문서 자동 생성 ⭐ **NEW**

```bash
# 7가지 타입의 문서 자동 생성
curl -X POST "http://localhost:8001/api/v1/documents/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "analysis_id": "3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c",
    "document_types": ["development_guide", "api_documentation", "architecture_overview"],
    "language": "korean",
    "custom_prompt": "FastAPI와 LangGraph 관련 내용을 중심으로 작성해주세요."
  }'

# 문서 생성 상태 확인
curl -X GET "http://localhost:8001/api/v1/documents/status/{task_id}"

# 또는 CoE-Backend AI 에이전트를 통한 대화형 가이드 생성
curl -X POST "http://localhost:8000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "model": "coe-agent-v1",
    "messages": [
      {
        "role": "user",
        "content": "analysis_id 3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c로 개발 가이드를 추출해줘. 특히 공통 함수와 재활용 가능한 코드에 집중해주세요."
      }
    ]
  }'
```

### 🔍 3단계: 분석별 RAG 검색 ⭐ **NEW**

```bash
# 특정 분석 결과에서만 검색 (정확도 향상)
curl -X POST "http://localhost:8001/api/v1/search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FastAPI 라우터 구조와 의존성 주입 패턴",
    "k": 5,
    "analysis_id": "3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c"
  }'
```

### 🎯 4단계: 결과 확인

AI가 생성하는 문서 타입별 예시:
- **개발 가이드**: 코딩 스타일, 네이밍 컨벤션, 아키텍처 패턴
- **API 문서**: 엔드포인트 설명, 요청/응답 예시, 사용법 가이드
- **아키텍처 개요**: 시스템 구조, 컴포넌트 관계, 데이터 흐름
- **코드 리뷰 요약**: 발견된 이슈, 개선 사항, 권장사항
- **기술 명세서**: 기술 스택, 의존성 정보, 버전 정보
- **배포 가이드**: 환경 설정, 빌드 과정, 배포 단계
- **문제 해결 가이드**: 일반적 오류, 해결 방법, 디버깅 팁

### 📄 자동 생성된 파일 위치
- **마크다운 리포트**: `output/markdown/{analysis_id}_analysis_report.md`
- **LLM 생성 문서**: `output/documents/{analysis_id}/`
- **JSON 분석 결과**: `output/results/{analysis_id}.json`

### 🌐 OpenWebUI 사용법

1. OpenWebUI 설정에서 API Base URL을 `http://localhost:8000/v1`로 설정
2. 모델 선택에서 `CoE Agent v1` 선택
3. 채팅창에서 직접 대화:
   ```
   "analysis_id [분석ID]로 개발 가이드를 생성해주세요"
   ```

## 🔧 문제 해결 (Troubleshooting)

일반적인 문제 해결 방법은 다음과 같습니다. 더 자세한 내용은 각 서비스의 `README.md` 파일을 참조해주세요.

### 🐳 Docker 관련 문제

**문제**: `docker-compose up` 실행 시 포트 충돌 오류
```
Error: bind: address already in use
```

**해결방법**:
```bash
# 사용 중인 포트 확인
sudo lsof -i :8000
sudo lsof -i :8001
sudo lsof -i :6666-6669

# 충돌하는 프로세스 종료 후 재시도
docker-compose down
docker-compose up -d
```

**문제**: 컨테이너가 시작되지 않거나 즉시 종료됨

**해결방법**:
```bash
# 로그 확인
docker-compose logs coe-backend
docker-compose logs coe-rag-pipeline

# 환경 변수 확인
docker-compose config

# 컨테이너 재빌드
docker-compose up -d --build --force-recreate
```

### 🔑 환경 변수 관련 문제

**문제**: API 키 관련 오류 또는 인증 실패

**해결방법**:
```bash
# 1. .env 파일 위치 확인
ls -la CoE-Backend/.env
ls -la CoE-RagPipeline/.env

# 2. API 키 설정 확인
docker-compose exec coe-backend env | grep API_KEY

# 3. 환경 변수 재로드
docker-compose down
docker-compose up -d
```

### 🌐 네트워크 연결 문제

**문제**: 서비스 간 통신 실패

**해결방법**:
```bash
# Docker 네트워크 상태 확인
docker network ls
docker network inspect coe_default

# 서비스 간 연결 테스트
docker-compose exec coe-backend ping coe-rag-pipeline
docker-compose exec coe-backend curl http://chroma:8000/api/v1/heartbeat
docker-compose exec coe-backend curl http://koEmbeddings:6668/health
```

### 📊 데이터베이스 연결 문제

**문제**: MariaDB 또는 ChromaDB 연결 실패

**해결방법**:
```bash
# MariaDB 연결 테스트
docker-compose exec coe-backend curl http://localhost:8000/test/db

# ChromaDB 연결 테스트
docker-compose exec coe-backend curl http://localhost:8000/test/vector

# 데이터베이스 서비스 재시작
docker-compose restart mariadb chroma
```

### 🔍 API 요청 문제

**문제**: curl로 POST 요청 시 422 오류 발생

**해결방법**:
```bash
# ✅ 올바른 curl 사용법 (Content-Type 헤더 필수)
curl -X POST "http://localhost:8000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coe-agent-v1",
    "messages": [{"role": "user", "content": "안녕하세요"}]
  }'

# ❌ 잘못된 방법 (헤더 누락)
curl -X POST "http://localhost:8000/v1/chat/completions" \
  -d '{"model": "coe-agent-v1", "messages": [{"role": "user", "content": "안녕하세요"}]}'
```

### 성능 최적화

#### 메모리 사용량 최적화
```bash
# Docker 메모리 사용량 확인
docker stats

# 불필요한 컨테이너 정리
docker system prune -a

# 메모리 제한 설정 (docker-compose.yml)
services:
  coe-backend:
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
```

#### 로그 관리
```bash
# 로그 크기 확인
docker-compose logs --tail=100 coe-backend

# 로그 파일 정리
docker-compose down
docker system prune --volumes
docker-compose up -d
```

### 📞 추가 지원

문제가 지속되는 경우:

1. **상세 문서 참조**:
   - `CoE-Backend/README.md`: CoE-Backend 상세 문제 해결 가이드
   - `CoE-RagPipeline/README.md`: CoE-RagPipeline 상세 문제 해결 가이드
   - `docs/SWAGGER_GUIDE.md`: Swagger UI 사용 가이드

2. **로그 수집**:
   ```bash
   # 전체 시스템 로그 수집
   docker-compose logs > coe_system_logs.txt
   ```

3. **시스템 정보 수집**:
   ```bash
   # 시스템 상태 정보
   docker-compose ps > coe_system_status.txt
   docker stats --no-stream >> coe_system_status.txt
   ```
# 로그 크기 제한 설정 (docker-compose.yml에 추가)
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"


## 🤝 기여하기 (Contributing)

### 개발 환경 설정

1. **Fork** 및 **Clone**:
```bash
git clone https://github.com/your-username/CoE.git
cd CoE
```

2. **개발 브랜치 생성**:
```bash
git checkout -b feature/your-feature-name
```

3. **로컬 개발 환경 설정**:
```bash
# 각 서비스별로 가상 환경 설정
cd CoE-Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

cd ../CoE-RagPipeline
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 코드 스타일 가이드

- **Python**: PEP 8 준수, Black 포매터 사용
- **커밋 메시지**: Conventional Commits 형식 사용
- **문서화**: 모든 새로운 기능에 대해 README 업데이트

### 테스트

```bash
# Backend 테스트
cd CoE-Backend
python -m pytest

# RagPipeline 테스트
cd CoE-RagPipeline
python -m pytest
```

## 📞 지원 및 문의

- **이슈 리포팅**: GitHub Issues 사용
- **기능 요청**: GitHub Discussions 사용
- **보안 문제**: 별도 연락처로 비공개 보고

## 🗺️ 로드맵

### 🎯 완료된 주요 기능 (2025-08-03)
- ✅ **스마트 레포지토리 분석**: Commit 기반 변경 감지로 효율성 극대화
- ✅ **LLM 기반 문서 자동 생성**: 7가지 타입의 개발 문서 자동 생성
- ✅ **분석별 RAG 검색**: analysis_id 기반 정확도 향상된 검색
- ✅ **마크다운 리포트 자동 생성**: 분석 완료 시 상세 리포트 자동 생성
- ✅ **영구 저장소**: JSON 파일 기반 분석 결과 영구 보존
- ✅ **채팅 히스토리 관리**: 멀티턴 대화 및 세션별 요약 기능
- ✅ **도구 레지스트리 패턴**: 코드 수정 없는 기능 확장 시스템

### 🚀 향후 계획
- 🔄 **실시간 협업 기능**: 팀 단위 분석 결과 공유 및 협업 도구
- 🔄 **고급 코드 분석**: 보안 취약점 분석 및 성능 최적화 제안
- 🔄 **CI/CD 통합**: GitHub Actions, GitLab CI와의 자동 연동
- 🔄 **대시보드 UI**: 웹 기반 분석 결과 시각화 대시보드

자세한 개발 현황 및 계획은 [Todo.md](Todo.md) 파일에서 확인하실 수 있습니다.

## 📄 라이선스

이 프로젝트는 [MIT License](LICENSE) 하에 배포됩니다.

---

더 자세한 내용은 각 하위 프로젝트의 `README.md` 파일을 참고해 주세요:
- [CoE-Backend README](CoE-Backend/README.md)
- [CoE-RagPipeline README](CoE-RagPipeline/README.md)