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

각 서비스는 독립적으로 실행되어야 합니다. 두 개의 터미널을 열고 아래 단계를 따라주세요.

### 1. 환경 변수 설정

`CoE-Backend` 디렉터리에 `.env` 파일을 생성하고 LLM API 키를 설정해야 합니다.

```bash
cd CoE-Backend
echo "OPENAI_API_KEY='your-api-key'" > .env
cd ..
```

### 2. Docker를 사용하여 실행 (권장)

각 프로젝트 디렉터리에서 Docker 이미지를 빌드하고 컨테이너를 실행합니다.

**터미널 1: `CoE-RagPipeline` 실행**
```bash
cd CoE-RagPipeline
docker build -t coe-rag-pipeline .
docker run -d -p 8001:8001 --name rag-pipeline -v $(pwd)/output:/app/output coe-rag-pipeline
```

**터미널 2: `CoE-Backend` 실행**
```bash
# CoE-Backend 디렉터리에 Dockerfile이 필요합니다.
cd CoE-Backend
docker build -t coe-backend .
docker run -d -p 8000:8000 --name backend --env-file .env coe-backend
```

### 3. 로컬에서 직접 실행

각 프로젝트의 `README.md` 파일을 참고하여 가상 환경 설정 및 서버를 실행할 수 있습니다.

- **CoE-RagPipeline 시작 가이드**
- **CoE-Backend 시작 가이드**

## 📖 사용 예시: 개발 가이드 추출하기

1.  **Git 레포지토리 분석 요청** (`CoE-RagPipeline`에 요청)
    - `http://127.0.0.1:8001/analyze` 엔드포인트에 분석할 Git 레포지토리 정보를 POST 요청으로 보냅니다.
    - 응답으로 받은 `analysis_id`를 복사합니다.

2.  **가이드 생성 요청** (`CoE-Backend`에 요청)
    - `CoE-Backend`의 채팅 클라이언트(`python client.py`)나 API(`http://127.0.0.1:8000/chat`)를 통해 다음과 같이 요청합니다.
    > "analysis_id [복사한 ID]로 개발 가이드를 추출해줘"

3.  **결과 확인**
    - 잠시 후, AI가 생성한 표준 개발 가이드, 공통 코드화, 공통 함수 가이드가 포함된 응답을 받게 됩니다.

## 🗺️ 로드맵

자세한 개발 현황 및 계획은 Todo.md 파일에서 확인하실 수 있습니다.

---

더 자세한 내용은 각 하위 프로젝트의 `README.md` 파일을 참고해 주세요.