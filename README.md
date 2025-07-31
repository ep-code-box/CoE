# 🤖 CoE: AI 기반 소프트웨어 개발 분석 및 가이드 자동화 플랫폼

**CoE(Center of Excellence) for AI** 프로젝트는 소프트웨어 개발의 효율성과 품질을 극대화하기 위해 설계된 AI 기반 자동화 플랫폼입니다. Git 레포지토리를 심층적으로 분석하고, 그 결과를 바탕으로 표준 개발 가이드, 공통 코드, 공통 함수 등을 자동으로 생성하여 개발팀의 생산성을 높이는 것을 목표로 합니다.

이 프로젝트는 두 개의 핵심 마이크로서비스로 구성되어 있습니다:

1.  **`CoE-RagPipeline`**: 소스 코드 분석 및 데이터 처리 엔진
2.  **`CoE-Backend`**: LLM 기반 추론 및 가이드 생성 에이전트

## ✨ 주요 기능

- **자동 코드 분석**: Git 레포지토리를 클론하여 AST(추상 구문 트리), 기술 스택, 의존성, 코드 메트릭 등을 자동으로 분석합니다.
- **AI 기반 가이드 생성**: 분석된 데이터를 기반으로 LLM이 다음과 같은 맞춤형 개발 가이드를 생성합니다.
  - **표준 개발 가이드**: 코딩 스타일, 네이밍 컨벤션, 아키텍처 패턴 제안
  - **공통 코드화 가이드**: 중복되거나 유사한 코드 패턴을 찾아 모듈화 방안 제시
  - **공통 함수 가이드**: 재사용 가능한 유틸리티 및 헬퍼 함수 추천
- **모듈형 에이전트 아키텍처**: `CoE-Backend`는 LangGraph와 '도구 레지스트리' 패턴을 사용하여 새로운 기능을 코드 수정 없이 쉽게 확장할 수 있습니다.
- **Docker 지원**: 각 서비스를 Docker 컨테이너로 실행하여 일관되고 안정적인 배포 환경을 제공합니다.

## 🏗️ 아키텍처

CoE 플랫폼은 두 서비스가 유기적으로 연동하여 동작합니다.

```
+-----------------------+      +-------------------------+      +------------------------+
|                       |      |                         |      |                        |
|   User / CI/CD        +----->+      CoE-Backend        +----->+   Large Language Model |
| (API, Client, etc.)   |      | (LangGraph Agent & API) |      |         (LLM)          |
|                       |      |                         |      |                        |
+-----------------------+      +-----------+-------------+      +------------------------+
                                          |
                                          | 1. 분석 결과 요청
                                          v
                                +-----------+-------------+
                                |                         |
                                |    CoE-RagPipeline      |
                                | (Git Analysis & RAG)    |
                                |                         |
                                +-----------+-------------+
                                            |
                                            | 2. Git 레포지토리 분석
                                            v
                                +-----------+-------------+
                                |                         |
                                |   Git Repositories      |
                                |                         |
                                +-------------------------+
```

1.  **분석 단계**: `CoE-RagPipeline`이 지정된 Git 레포지토리를 분석하여 코드 구조, 의존성, 패턴 등에 대한 데이터를 JSON 형식으로 저장합니다.
2.  **추론 및 생성 단계**: 사용자가 `CoE-Backend`에 가이드 생성을 요청하면, 백엔드는 `CoE-RagPipeline`의 분석 결과를 가져와 LLM에게 전달하여 최종 가이드 문서를 생성합니다.

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
# LLM API 설정
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here  # 선택사항

# 데이터베이스 설정
DATABASE_URL=mysql://coe_user:coe_password@mariadb:3306/coe_db

# 벡터 데이터베이스 설정
CHROMA_HOST=chroma
CHROMA_PORT=6666

# 임베딩 서비스 설정
EMBEDDING_SERVICE_URL=http://koEmbeddings:6668
```

**CoE-RagPipeline 환경 변수 설정:**
```bash
cd ../CoE-RagPipeline
cp .env.example .env
```

`.env` 파일을 편집하여 다음 값들을 설정하세요:
```bash
# 데이터베이스 설정
DATABASE_URL=mysql://coe_user:coe_password@mariadb:3306/coe_db

# 벡터 데이터베이스 설정
CHROMA_HOST=chroma
CHROMA_PORT=6666

# 임베딩 서비스 설정
EMBEDDING_SERVICE_URL=http://koEmbeddings:6668

# Git 분석 설정
MAX_REPO_SIZE_MB=500
ANALYSIS_TIMEOUT_MINUTES=30
```

```bash
cd ..
```

### 3. Docker Compose를 사용하여 전체 시스템 실행 (권장)

**간편 실행 스크립트 사용:**
```bash
# 전체 시스템 시작 (자동으로 환경 설정 및 디렉토리 생성)
./run_all.sh

# 전체 시스템 중지
./stop_all.sh
```

**수동 Docker Compose 명령어:**
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

**실행되는 서비스들:**
- **ChromaDB**: 벡터 데이터베이스 (포트 6666)
- **MariaDB**: 관계형 데이터베이스 (포트 6667)  
- **Korean Embeddings**: 한국어 임베딩 서비스 (포트 6668)
- **CoE-Backend**: AI 에이전트 및 API 서버 (포트 8000)
- **CoE-RagPipeline**: Git 분석 및 RAG 파이프라인 (포트 8001)

### 4. 개별 서비스 Docker 실행

필요한 경우 개별 서비스만 실행할 수 있습니다:

**인프라 서비스만 실행:**
```bash
docker-compose up -d chroma mariadb koEmbeddings
```

**애플리케이션 서비스만 실행:**
```bash
docker-compose up -d coe-backend coe-rag-pipeline
```

### 5. 로컬에서 직접 실행

각 프로젝트의 `README.md` 파일을 참고하여 가상 환경 설정 및 서버를 실행할 수 있습니다.

- **CoE-RagPipeline 시작 가이드**: `CoE-RagPipeline/README.md`
- **CoE-Backend 시작 가이드**: `CoE-Backend/README.md`

## 📖 사용 예시: 개발 가이드 추출하기

1.  **Git 레포지토리 분석 요청** (`CoE-RagPipeline`에 요청)
    - `http://127.0.0.1:8001/analyze` 엔드포인트에 분석할 Git 레포지토리 정보를 POST 요청으로 보냅니다.
    - 응답으로 받은 `analysis_id`를 복사합니다.

2.  **가이드 생성 요청** (`CoE-Backend`에 요청)
    - `CoE-Backend`의 채팅 클라이언트(`python client.py`)나 API(`http://127.0.0.1:8000/v1/chat/completions`)를 통해 다음과 같이 요청합니다.
    > "analysis_id [복사한 ID]로 개발 가이드를 추출해줘"

3.  **결과 확인**
    - 잠시 후, AI가 생성한 표준 개발 가이드, 공통 코드화, 공통 함수 가이드가 포함된 응답을 받게 됩니다.

## 🔧 문제 해결 (Troubleshooting)

### 일반적인 문제들

#### Docker 관련 문제

**문제**: `docker-compose up` 실행 시 포트 충돌 오류
```
Error: bind: address already in use
```

**해결방법**:
```bash
# 사용 중인 포트 확인
sudo lsof -i :8000
sudo lsof -i :8001

# 충돌하는 프로세스 종료 후 재시도
docker-compose down
docker-compose up -d
```

**문제**: 컨테이너가 시작되지 않거나 즉시 종료됨

**해결방법**:
```bash
# 로그 확인
docker-compose logs [서비스명]

# 환경 변수 확인
docker-compose config

# 컨테이너 재빌드
docker-compose up -d --build --force-recreate
```

#### 환경 변수 관련 문제

**문제**: API 키 관련 오류 또는 인증 실패

**해결방법**:
1. `.env` 파일이 올바른 위치에 있는지 확인
2. API 키가 올바르게 설정되었는지 확인
3. 환경 변수가 컨테이너에 전달되는지 확인:
```bash
docker-compose exec coe-backend env | grep API_KEY
```

#### 네트워크 연결 문제

**문제**: 서비스 간 통신 실패

**해결방법**:
```bash
# Docker 네트워크 상태 확인
docker network ls
docker network inspect coe_default

# 서비스 간 연결 테스트
docker-compose exec coe-backend ping coe-rag-pipeline
```

### 성능 최적화

#### 메모리 사용량 최적화
```bash
# Docker 메모리 사용량 확인
docker stats

# 불필요한 컨테이너 정리
docker system prune -a
```

#### 로그 관리
```bash
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