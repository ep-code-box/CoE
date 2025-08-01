# 📚 CoE Swagger UI 사용 가이드

CoE 프로젝트의 두 서비스 모두 **Swagger UI**를 통해 API를 쉽게 테스트하고 문서를 확인할 수 있습니다.

## 🔗 Swagger UI 접근 경로

### CoE-Backend (포트 8000)
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc  
- **OpenAPI JSON**: http://localhost:8000/openapi.json

### CoE-RagPipeline (포트 8001)
- **Swagger UI**: http://localhost:8001/docs
- **ReDoc**: http://localhost:8001/redoc
- **OpenAPI JSON**: http://localhost:8001/openapi.json

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

### CoE-Backend 테스트

#### 1. 헬스체크
```
GET /health
```

#### 2. AI 채팅 테스트
```
POST /v1/chat/completions
{
  "model": "coe-agent-v1",
  "messages": [
    {
      "role": "user", 
      "content": "안녕하세요! CoE 에이전트를 테스트해보고 싶습니다."
    }
  ],
  "stream": false
}
```

#### 3. 코딩 어시스턴트 테스트
```
POST /api/coding-assistant/generate
{
  "language": "python",
  "description": "FastAPI 헬스체크 엔드포인트 생성"
}
```

### CoE-RagPipeline 테스트

#### 1. Git 분석 시작
```
POST /api/v1/analyze
{
  "repositories": [
    {
      "url": "https://github.com/octocat/Hello-World.git",
      "branch": "master"
    }
  ],
  "include_ast": true,
  "include_tech_spec": true,
  "include_correlation": true
}
```

#### 2. 벡터 검색
```
POST /api/v1/search
{
  "query": "Python 함수 정의",
  "k": 5,
  "filter_metadata": {
    "file_type": "python"
  }
}
```

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