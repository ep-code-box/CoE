# CoE Platform TODO List

## ✅ 완료된 기능

### 🚀 CoE-Backend
- **AI Agent & Chat**
    - [x] LangGraph 기반 AI 에이전트 구축
    - [x] OpenAI 호환 채팅 API (`/v1/chat/completions`)
    - [x] 다중 모델 지원 API (`/v1/models`)
    - [x] 동적 도구 라우팅 및 자동 등록 시스템
- **Vector Search & Embeddings**
    - [x] OpenAI 호환 임베딩 API (`/v1/embeddings`)
    - [x] ChromaDB 연동 벡터 검색 및 관리 API
- **Coding Assistant**
    - [x] 코드 분석, 생성, 리팩토링, 리뷰 API
    - [x] 지원 언어 목록 API
- **Workflow Management**
    - [x] LangFlow 워크플로우 저장 및 목록 API
- **Core & Services**
    - [x] FastAPI 기반 비동기 서버 구축
    - [x] 데이터베이스 서비스 및 스키마 관리
    - [x] 시스템 상태 확인 API (`/health`)

### 🔬 CoE-RagPipeline
- **Analysis Engine**
    - [x] Git 리포지토리 클론 및 분석 기능
    - [x] 커밋 해시 기반 스마트 변경 감지 기능
    - [x] AST(추상 구문 트리) 분석기 (Python, JS, Java, TS 등)
    - [x] 기술 스택 정적 분석기 (`requirements.txt`, `package.json` 등)
- **LLM & Document Services**
    - [x] LLM을 활용한 소스코드 요약 서비스
    - [x] 분석 기반 자동 문서 생성 서비스 (7가지 유형)
    - [x] 생성된 문서 및 분석 결과 검색 기능
- **API & Infrastructure**
    - [x] 분석, 문서 생성, 검색 등 주요 기능 API
    - [x] 분석 결과 영구 저장 (JSON, Markdown)
    - [x] 시스템 상태 및 DB 연결 확인 API (`/health`)

### 🔧 Infrastructure & DevOps
- [x] 전체 서비스 통합 Docker Compose 환경 (`docker-compose.yml`)
- [x] 로컬 개발용 인프라 Docker Compose 환경 (`docker-compose.local.yml`)
- [x] 통합 실행/중지 스크립트 (`run_all.sh`, `stop_all.sh`)
- [x] 각 서비스별 실행 스크립트 (`run.sh`)

## 📝 향후 개발 계획

### 🚀 CoE-Backend
- [ ] **고급 인증 및 보안**
    - [ ] OAuth 2.0 기반 사용자 인증 시스템
    - [ ] 역할 기반 접근 제어(RBAC)
    - [ ] API 요청 속도 제한 및 로깅 강화
- [ ] **채팅 기능 고도화**
    - [ ] 대화 히스토리 요약 및 관리 기능
    - [ ] 파일 업로드 및 처리 기능 (이미지, 문서 등)
    - [ ] 실시간 스트리밍 응답 성능 개선

### 🔬 CoE-RagPipeline
- [ ] **분석 기능 확장**
    - [ ] 리포지토리 간의 연관 관계 시각화
    - [ ] 코드 품질 메트릭(복잡도, 중복도 등) 분석
    - [ ] 보안 취약점 정적 분석 (SAST)
- [ ] **문서 생성 품질 향상**
    - [ ] 다국어 문서 생성 지원 (현재 한국어 위주)
    - [ ] 사용자 정의 템플릿 기반 문서 생성

### 🌐 플랫폼 통합 및 UI
- [ ] **CI/CD 파이프라인 연동**
    - [ ] GitHub Actions, Jenkins 등과 연동하여 코드 분석 자동화
- [ ] **웹 기반 대시보드**
    - [ ] 분석 결과 및 생성된 문서를 시각적으로 보여주는 UI
    - [ ] 프로젝트 상태 및 통계 대시보드
- [ ] **알림 기능**
    - [ ] 분석 완료, 문서 생성 완료 시 Slack, 이메일 등 알림
