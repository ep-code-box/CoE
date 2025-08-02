# 🤖 CoE: AI 기반 소프트웨어 개발 분석 및 가이드 자동화 플랫폼

**CoE(Center of Excellence) for AI** 프로젝트는 소프트웨어 개발의 효율성과 품질을 극대화하기 위해 설계된 AI 기반 자동화 플랫폼입니다. Git 레포지토리를 심층적으로 분석하고, 그 결과를 바탕으로 표준 개발 가이드, 공통 코드, 공통 함수 등을 자동으로 생성하여 개발팀의 생산성을 높이는 것을 목표로 합니다.

이 프로젝트는 두 개의 핵심 마이크로서비스와 완전한 인프라 스택으로 구성되어 있습니다:

1.  **`CoE-Backend`**: LangGraph 기반 AI 에이전트 및 FastAPI 서버 (포트 8000)
2.  **`CoE-RagPipeline`**: Git 분석 및 RAG 파이프라인 엔진 (포트 8001)
3.  **인프라 서비스**: ChromaDB, MariaDB, Redis

## ✨ 주요 기능

### 🔍 코드 분석 및 처리
- **자동 Git 분석**: 레포지토리 클론, AST 분석, 기술 스택 감지, 의존성 분석
- **레포지토리간 연관관계 분석**: 공통 의존성, 코드 패턴, API 호출 관계, 개발자 협업 네트워크 분석
- **다중 언어 지원**: Python, JavaScript, TypeScript, Java, C++, C#, Go, Rust, Kotlin, Swift (10개 언어)
- **벡터 검색**: ChromaDB 기반 고성능 벡터 검색 및 RAG 시스템
- **실시간 임베딩**: OpenAI 임베딩 모델 지원

### 🤖 AI 에이전트 및 도구
- **LangGraph 에이전트**: AI4X 모델(Claude-3-Sonnet) 기반 동적 도구 라우팅 및 자동 도구 등록 시스템
- **지능형 도구 선택**: 의미적 유사성 기반 도구 선택 및 코사인 유사도 최적화
- **코딩 어시스턴트**: 코드 생성, 리팩토링, 리뷰, 테스트 생성 (10개 언어 지원)
- **가이드 생성**: LLM 기반 표준 개발 가이드, 공통 코드화 가이드, 공통 함수 가이드 자동 생성
- **OpenWebUI 호환**: 표준 OpenAI API 규격 지원

### 🔐 사용자 관리 및 보안
- **JWT 기반 인증**: FastAPI-Users를 활용한 안전한 사용자 인증 및 세션 관리
- **3턴 멀티턴 대화**: 사용자별 대화 세션 관리 및 자동 요약 기능
- **권한 기반 접근 제어**: 역할별 권한 관리 (admin, user, developer)
- **대화 히스토리 관리**: 모든 채팅 메시지 데이터베이스 저장 및 컨텍스트 유지

### 🔧 통합 및 확장성
- **모듈형 아키텍처**: 도구 레지스트리 패턴으로 코드 수정 없이 기능 확장
- **LangFlow 연동**: 워크플로우 저장 및 관리 API
- **다중 LLM 지원**: OpenAI, Anthropic, SKAX(AI4X) 등 다양한 LLM 제공업체 지원
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
2. **코드 분석**: AST 분석, 기술 스택 감지, 의존성 분석, 레포지토리간 연관관계 추출 수행
3. **문서 수집**: README, doc 폴더, 참조 URL에서 개발 문서 자동 수집
4. **벡터화**: 분석 결과 및 문서를 임베딩하여 ChromaDB에 저장
5. **가이드 생성**: CoE-Backend가 분석 결과를 기반으로 LLM을 통해 AI 가이드 생성
6. **결과 제공**: 표준 개발 가이드, 공통 코드화 가이드, 재활용 함수 가이드를 사용자에게 제공
7. **대화형 상호작용**: OpenWebUI를 통해 생성된 가이드에 대한 질의응답 및 추가 분석

## 📂 프로젝트 구조

```
CoE/
├── CoE-Backend/            # LangGraph 에이전트 및 FastAPI 서버
│   ├── Dockerfile
│   ├── main.py
│   └── README.md
├── CoE-RagPipeline/        # Git 분석 및 RAG 파이프라인
│   ├── Dockerfile
│   ├── main.py
│   └── README.md
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

### 2. 환경 변수 설정

각 서비스에 필요한 환경 변수를 설정해야 합니다.

**CoE-Backend 환경 변수 설정:**
```bash
cd CoE-Backend
cp .env.example .env
```

`.env` 파일을 편집하여 다음 값들을 설정하세요:
```bash
# === API 키 사용 정책 ===
# SKAX_API_KEY: ax4 모델(sktax provider) 전용
# OPENAI_API_KEY: OpenAI 서비스(임베딩, GPT 모델 등) 전용

# SKAX API 설정 (ax4 모델 전용)
SKAX_API_BASE=https://guest-api.sktax.chat/v1
SKAX_API_KEY=your_skax_api_key_here
SKAX_MODEL_NAME=ax4

# OpenAI API 설정 (임베딩 및 OpenAI 모델 전용)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here  # 선택사항

# 데이터베이스 설정
DATABASE_URL=mysql://coe_user:coe_password@mariadb:3306/coe_db

# 벡터 데이터베이스 설정
CHROMA_HOST=chroma
CHROMA_PORT=6666

# 임베딩 서비스 설정 (OpenAI 사용)
# EMBEDDING_SERVICE_URL은 더 이상 사용하지 않음 - OpenAI API 직접 사용

# Redis 설정
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=coe_redis_password
```

**CoE-RagPipeline 환경 변수 설정:**
```bash
cd ../CoE-RagPipeline
cp .env.example .env
```

`.env` 파일을 편집하여 다음 값들을 설정하세요:
```bash
# === API 키 사용 정책 ===
# SKAX_API_KEY: ax4 모델(sktax provider) 전용
# OPENAI_API_KEY: OpenAI 서비스(임베딩, GPT 모델 등) 전용

# SKAX API 설정 (ax4 모델 전용)
SKAX_API_BASE=https://guest-api.sktax.chat/v1
SKAX_API_KEY=your_skax_api_key_here
SKAX_MODEL_NAME=ax4

# OpenAI API 설정 (임베딩 및 OpenAI 모델 전용)
OPENAI_API_KEY=your_openai_api_key_here

# 데이터베이스 설정
DATABASE_URL=mysql://coe_user:coe_password@mariadb:3306/coe_db

# 벡터 데이터베이스 설정
CHROMA_HOST=chroma
CHROMA_PORT=6666

# 임베딩 서비스 설정 (OpenAI 사용)
# EMBEDDING_SERVICE_URL은 더 이상 사용하지 않음 - OpenAI API 직접 사용

# Redis 설정
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=coe_redis_password

# Git 분석 설정
MAX_REPO_SIZE_MB=500
ANALYSIS_TIMEOUT_MINUTES=30
```

```bash
cd ..
```

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
- **ChromaDB**: 벡터 데이터베이스 (포트 6666)
- **MariaDB**: 관계형 데이터베이스 - 사용자 관리, 세션, 분석 결과 저장 (포트 6667)  
- **Redis**: 캐싱 및 세션 관리 - JWT 토큰, 임베딩 캐시 (포트 6669)
- **CoE-Backend**: AI 에이전트 및 API 서버 - LangGraph, 인증, 도구 라우팅 (포트 8000)
- **CoE-RagPipeline**: Git 분석 및 RAG 파이프라인 - 코드 분석, 연관관계 추출, 가이드 생성 (포트 8001)

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

### 4. 환경 변수 설정

각 환경에 맞는 환경 변수 파일이 자동으로 설정됩니다:

#### 🔧 환경별 .env 파일

| 환경 | CoE-Backend | CoE-RagPipeline | 설명 |
|------|-------------|-----------------|------|
| **local** | `.env.local` → `.env` | `.env.local` → `.env` | 로컬 개발용 (localhost 연결) |
| **docker** | `.env.docker` | `.env.docker` | Docker 네트워크용 (컨테이너명 연결) |
| **native** | `.env.example` → `.env` | `.env.example` → `.env` | 완전 로컬용 (수동 설정 필요) |

#### ⚙️ 주요 설정 차이점

**로컬 개발 환경 (.env.local):**
```bash
# 인프라 서비스는 Docker 컨테이너에 연결
DB_HOST=localhost
DB_PORT=6667
CHROMA_HOST=localhost
CHROMA_PORT=6666
REDIS_HOST=localhost
REDIS_PORT=6669
```

**Docker 환경 (.env.docker):**
```bash
# 모든 서비스가 Docker 네트워크에서 연결
DB_HOST=mariadb
DB_PORT=3306
CHROMA_HOST=chroma
CHROMA_PORT=8000
REDIS_HOST=redis
REDIS_PORT=6379
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

# 응답에서 analysis_id 확인
# 예: {"analysis_id": "3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c", "status": "started"}
```

### 🤖 2단계: AI 가이드 생성

```bash
# CoE-RagPipeline에서 직접 가이드 생성
curl -X POST "http://localhost:8001/api/v1/generate/guide" \
  -H "Content-Type: application/json" \
  -d '{
    "analysis_id": "3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c",
    "guide_types": ["dev_guide", "common_code", "reusable_functions"]
  }'

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

### 🎯 3단계: 결과 확인

AI가 생성하는 가이드 예시:
- **표준 개발 가이드**: 코딩 스타일, 네이밍 컨벤션, 아키텍처 패턴
- **공통 코드화 가이드**: 중복 코드 패턴 및 모듈화 방안
- **공통 함수 가이드**: 재사용 가능한 유틸리티 함수 추천

### 🌐 OpenWebUI 사용법

1. OpenWebUI 설정에서 API Base URL을 `http://localhost:8000/v1`로 설정
2. 모델 선택에서 `CoE Agent v1` 선택
3. 채팅창에서 직접 대화:
   ```
   "analysis_id [분석ID]로 개발 가이드를 생성해주세요"
   ```

## 🔧 문제 해결 (Troubleshooting)

### 📋 현재 시스템 상태 (2025-08-01 기준)

**✅ 정상 동작 확인된 기능**:
- 모든 Docker 컨테이너 정상 실행 (5개 서비스)
- 모든 API 엔드포인트 정상 응답 (CoE-Backend 21개, CoE-RagPipeline 4개)
- 데이터베이스 연결 및 CRUD 작업 정상
- AI 에이전트 및 코딩 어시스턴트 정상 동작

**⚠️ 알려진 개선 필요 사항**:
1. OpenAI 호환 임베딩 API 구현 (`/v1/embeddings`)
2. 벡터 문서 추가 기능 개선 (임베딩 서비스 연동)
3. API 문서 및 사용 예시 보완

### 일반적인 문제들

#### 🐳 Docker 관련 문제

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

#### 🔑 환경 변수 관련 문제

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

#### 🌐 네트워크 연결 문제

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

#### 📊 데이터베이스 연결 문제

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

#### 🔍 API 요청 문제

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
   - `/docs/API_USAGE_GUIDE.md`: 완전한 API 사용 가이드
   - `/API_TROUBLESHOOTING.md`: 상세한 문제 해결 가이드
   - `/기능점검결과.md`: 최신 시스템 상태 보고서

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
```

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

자세한 개발 현황 및 계획은 [Todo.md](Todo.md) 파일에서 확인하실 수 있습니다.

## 📄 라이선스

이 프로젝트는 [MIT License](LICENSE) 하에 배포됩니다.

---

더 자세한 내용은 각 하위 프로젝트의 `README.md` 파일을 참고해 주세요:
- [CoE-Backend README](CoE-Backend/README.md)
- [CoE-RagPipeline README](CoE-RagPipeline/README.md)