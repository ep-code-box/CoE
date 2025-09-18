# 📚 CoE Swagger UI 사용 가이드

CoE 프로젝트의 두 서비스 모두 **Swagger UI**를 통해 API를 쉽게 테스트하고 문서를 확인할 수 있습니다.

문서 맵
- 배포/기동: `docs/DEPLOY.md`
- 마이그레이션: `docs/OPERATIONS.md`
- cURL 예시 모음: `docs/curl-checks.md`

## 🔐 운영 공개 정책

- 운영/엣지 Nginx는 `/docs`, `/redoc`, `/openapi.json` (및 `/agent/*`, `/rag/*` 하위 경로)을 404로 차단합니다.
- FastAPI 서비스도 기본값으로 문서를 비활성화합니다. 임시로 열어야 한다면 컨테이너 환경변수 `ENABLE_DOCS=true`(또는 `1`, `yes`, `on`)를 지정한 뒤 재시작하세요.
- 개발 프로필은 `APP_ENV=development`이면 자동으로 문서를 노출합니다. 운영에서 열었으면 점검 후 다시 끄는 것을 권장합니다.

## 🔗 Swagger UI 접근 경로

### CoE-Backend (Nginx 프록시)
- **Swagger UI**: http://localhost/docs
- **ReDoc**: http://localhost/redoc  
- **OpenAPI JSON**: http://localhost/openapi.json

> 운영 도메인에서는 기본적으로 404가 반환됩니다. 임시 공개 시 `ENABLE_DOCS=true`를 설정하고 서비스 재시작 후 접근하세요.

### CoE-RagPipeline (포트 8001, Nginx 프록시 제공)

NOTE: RAG는 Backend 경유 사용이 권장되며, 직접 접근은 유예 기간 이후 중단될 예정입니다.
테스트/스크립트는 Backend 엔드포인트를 기준으로 마이그레이션 해 주세요.

또한, 기존 `/api/v1/enhanced/*` 엔드포인트는 제거되었습니다. 고급 분석(트리시터/정적/의존성 분석)은 `/api/v1/analyze` 요청 본문에 다음 플래그를 포함해 사용하세요:

- `include_tree_sitter`, `include_static_analysis`, `include_dependency_analysis`, `generate_report`
- **Swagger UI (직접 접근)**: http://localhost:8001/docs
- **ReDoc (직접 접근)**: http://localhost:8001/redoc
- **OpenAPI JSON (직접 접근)**: http://localhost:8001/openapi.json
- **Swagger UI (Nginx 경유)**: http://localhost/rag/docs
- **ReDoc (Nginx 경유)**: http://localhost/rag/redoc
- **OpenAPI JSON (Nginx 경유)**: http://localhost/rag/openapi.json

> Edge(dev) 프록시(8080) 사용 시: http://localhost:8080/rag/docs

> 운영 및 Edge WAF 구간에서는 위 경로가 404로 차단됩니다. 점검이 필요하면 RAG 컨테이너에 `ENABLE_DOCS=true`를 지정하고 로컬 포트 포워딩 등 제한된 경로로만 접근하세요.

문자가 깨지거나 리소스가 로드되지 않으면, RAG 서비스에 루트 경로를 지정하세요.

- 옵션 A: FastAPI 루트 경로 설정 (권장)
  - `CoE-RagPipeline/.env`에 `ROOT_PATH=/rag` 추가 (Edge/dev에서만)
  - 또는 컨테이너 환경변수로 `ROOT_PATH=/rag` 지정
- 옵션 B: Nginx에서 프리픽스 헤더 전달
  - `location /rag/ { ... proxy_set_header X-Forwarded-Prefix /rag; }`

이렇게 하면 Swagger UI가 `/rag/openapi.json`, `/rag/docs/*` 정적 리소스를 올바르게 참조합니다.

## 🚀 주요 기능

### 🤖 CoE-Backend API 기능
1. **🏥 Health Check**: 서비스 상태 확인
2. **🤖 AI Chat**: OpenAI 호환 채팅 API
3. **👨‍💻 Coding Assistant**: 코드 생성, 분석, 리팩토링
4. **🔍 Vector Search**: ChromaDB 기반 벡터 검색
5. **🔐 Authentication**: JWT 기반 사용자 인증
6. **🔄 LangFlow**: 워크플로우 관리
7. **🛠️ Dynamic Tools**: 동적 도구 관리

### 🔍 CoE-RagPipeline API 기능
1. **🏥 Health Check**: 서비스 상태 확인
2. **🔍 Git Analysis**: Git 레포지토리 분석
3. **🔍 Vector Search**: 벡터 유사도 검색

## 📝 Swagger UI 사용 방법

### 1. API 탐색
- 각 엔드포인트를 클릭하여 상세 정보 확인
- 요청/응답 스키마 확인
- 예시 데이터 확인

### 2. API 테스트
1. **"Try it out"** 버튼 클릭
2. 필요한 파라미터 입력
3. **"Execute"** 버튼 클릭
4. 응답 결과 확인

### 3. 인증이 필요한 API 테스트
1. `/auth/register` 또는 `/auth/login`으로 계정 생성/로그인
2. 응답에서 `access_token` 복사
3. Swagger UI 상단의 **"Authorize"** 버튼 클릭
4. `Bearer {access_token}` 형식으로 입력
5. 인증이 필요한 API 테스트

## 🎯 주요 API 테스트 예시

자세한 CLI 예시는 `docs/curl-checks.md`에서 관리합니다. Swagger UI에서는 각 엔드포인트의 "Try it out" 버튼으로 동일한 테스트를 수행할 수 있습니다.

## 🔧 고급 기능

### 1. 스키마 다운로드
- OpenAPI JSON을 다운로드하여 코드 생성 도구에 활용
- Postman, Insomnia 등에서 컬렉션 생성

### 2. 코드 생성
- Swagger Codegen을 사용하여 클라이언트 SDK 생성
- 다양한 언어 지원 (Python, JavaScript, Java 등)

### 3. 문서 공유
- Swagger UI URL을 팀원들과 공유
- API 문서를 실시간으로 확인 가능

## 💡 팁과 주의사항

### ✅ 권장사항
- 테스트 전에 서비스가 정상 실행 중인지 헬스체크로 확인
- 인증이 필요한 API는 먼저 로그인 후 토큰 설정
- 큰 데이터 분석 시 백그라운드 처리 시간 고려

### ⚠️ 주의사항
- 프로덕션 환경에서는 민감한 데이터 입력 주의
- 대용량 Git 레포지토리 분석 시 시간이 오래 걸릴 수 있음
- 동시에 많은 분석 요청 시 서버 부하 주의

## 🔗 관련 링크

- [CoE-Backend README](../CoE-Backend/README.md)
- [CoE-RagPipeline README](../CoE-RagPipeline/README.md)
- [전체 프로젝트 README](../README.md)
- [FastAPI 공식 문서](https://fastapi.tiangolo.com/)
- [Swagger UI 공식 문서](https://swagger.io/tools/swagger-ui/)
