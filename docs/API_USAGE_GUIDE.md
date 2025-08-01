# 📚 CoE API 사용 가이드

**최종 업데이트**: 2025-08-01  
**기능점검결과**: 모든 API 엔드포인트 정상 동작 확인

이 문서는 CoE 플랫폼의 모든 API 엔드포인트 사용법과 예시를 제공합니다.

## 🚀 시작하기

### 기본 설정

```bash
# 환경 변수 설정
export COE_BACKEND_URL="http://localhost:8000"
export COE_RAGPIPELINE_URL="http://localhost:8001"

# 헬스체크
curl -X GET "$COE_BACKEND_URL/health"
curl -X GET "$COE_RAGPIPELINE_URL/health"
```

## 🤖 CoE-Backend API (포트 8000)

### AI 에이전트 및 채팅

#### 1. 모델 목록 조회
```bash
curl -X GET "$COE_BACKEND_URL/v1/models"
```

**응답 예시**:
```json
{
  "object": "list",
  "data": [
    {"id": "gpt-4o-mini", "object": "model", "owned_by": "openai"},
    {"id": "gpt-4o", "object": "model", "owned_by": "openai"},
    {"id": "ax4", "object": "model", "owned_by": "anthropic"},
    {"id": "coe-agent-v1", "object": "model", "owned_by": "coe"}
  ]
}
```

#### 2. AI 에이전트 채팅
```bash
curl -X POST "$COE_BACKEND_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coe-agent-v1",
    "messages": [
      {
        "role": "user",
        "content": "CoE 플랫폼의 주요 기능을 설명해주세요."
      }
    ],
    "temperature": 0.7,
    "max_tokens": 1000
  }'
```

### 벡터 검색 및 임베딩

#### 3. 벡터 데이터베이스 정보 조회
```bash
curl -X GET "$COE_BACKEND_URL/vector/info"
```

#### 4. 문서 추가
```bash
curl -X POST "$COE_BACKEND_URL/vector/add" \
  -H "Content-Type: application/json" \
  -d '{
    "documents": [
      {
        "content": "CoE 플랫폼은 AI 기반 소프트웨어 개발 분석 도구입니다.",
        "metadata": {
          "source": "documentation",
          "type": "guide",
          "language": "ko"
        }
      }
    ]
  }'
```

#### 5. 벡터 검색
```bash
curl -X POST "$COE_BACKEND_URL/vector/search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "AI 기반 개발 도구",
    "k": 5,
    "filter_metadata": {
      "type": "guide"
    }
  }'
```

#### 6. 임베딩 생성
```bash
curl -X POST "$COE_BACKEND_URL/v1/embeddings" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ko-sentence-bert",
    "input": ["안녕하세요", "CoE 플랫폼입니다"]
  }'
```

### 코딩 어시스턴트

#### 7. 지원 언어 목록
```bash
curl -X GET "$COE_BACKEND_URL/api/coding-assistant/languages"
```

#### 8. 코드 분석
```bash
curl -X POST "$COE_BACKEND_URL/api/coding-assistant/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "language": "python",
    "code": "def fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n-1) + fibonacci(n-2)"
  }'
```

#### 9. 코드 생성
```bash
curl -X POST "$COE_BACKEND_URL/api/coding-assistant/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "language": "python",
    "description": "JWT 토큰을 생성하고 검증하는 함수"
  }'
```

#### 10. 코드 리뷰
```bash
curl -X POST "$COE_BACKEND_URL/api/coding-assistant/review" \
  -H "Content-Type: application/json" \
  -d '{
    "language": "python",
    "code": "def add(a, b):\n    return a + b"
  }'
```

### LangFlow 워크플로우 관리

#### 11. 워크플로우 저장
```bash
curl -X POST "$COE_BACKEND_URL/flows/save" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sample_workflow",
    "description": "샘플 워크플로우",
    "flow_data": {
      "nodes": [],
      "edges": []
    }
  }'
```

#### 12. 워크플로우 목록 조회
```bash
curl -X GET "$COE_BACKEND_URL/flows/list"
```

## 🔍 CoE-RagPipeline API (포트 8001)

### Git 분석

#### 13. 레포지토리 분석 시작
```bash
curl -X POST "$COE_RAGPIPELINE_URL/api/v1/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "repositories": [
      {
        "url": "https://github.com/octocat/Hello-World.git",
        "branch": "master"
      }
    ],
    "include_ast": true,
    "include_tech_spec": true,
    "include_correlation": true
  }'
```

**응답 예시**:
```json
{
  "analysis_id": "3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c",
  "status": "started",
  "message": "분석이 시작되었습니다."
}
```

#### 14. 분석 결과 목록 조회
```bash
curl -X GET "$COE_RAGPIPELINE_URL/api/v1/results"
```

#### 15. 특정 분석 결과 조회
```bash
curl -X GET "$COE_RAGPIPELINE_URL/api/v1/results/3cbf3db0-fd9e-410c-bdaa-30cdeb9d7d6c"
```

### 벡터 검색

#### 16. 벡터 검색
```bash
curl -X POST "$COE_RAGPIPELINE_URL/api/v1/search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Python 함수 정의",
    "k": 5,
    "filter_metadata": {
      "file_type": "python"
    }
  }'
```

#### 17. 벡터 통계 조회
```bash
curl -X GET "$COE_RAGPIPELINE_URL/api/v1/stats"
```

## 🔄 통합 워크플로우 예시

### 완전한 분석 → 가이드 생성 워크플로우

```bash
#!/bin/bash

# 1. Git 레포지토리 분석 시작
echo "🔍 Git 레포지토리 분석 시작..."
ANALYSIS_RESPONSE=$(curl -s -X POST "$COE_RAGPIPELINE_URL/api/v1/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "repositories": [
      {
        "url": "https://github.com/your-org/your-repo.git",
        "branch": "main"
      }
    ],
    "include_ast": true,
    "include_tech_spec": true,
    "include_correlation": true
  }')

# 2. analysis_id 추출
ANALYSIS_ID=$(echo $ANALYSIS_RESPONSE | jq -r '.analysis_id')
echo "📋 분석 ID: $ANALYSIS_ID"

# 3. 분석 완료 대기 (실제로는 더 정교한 폴링 로직 필요)
echo "⏳ 분석 완료 대기 중..."
sleep 30

# 4. 분석 결과 확인
echo "📊 분석 결과 확인..."
curl -s -X GET "$COE_RAGPIPELINE_URL/api/v1/results/$ANALYSIS_ID" | jq '.'

# 5. AI 가이드 생성
echo "🤖 AI 가이드 생성..."
curl -X POST "$COE_BACKEND_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"coe-agent-v1\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"analysis_id $ANALYSIS_ID로 개발 가이드를 생성해주세요\"
      }
    ]
  }" | jq '.choices[0].message.content'
```

## 🚨 에러 처리 및 문제 해결

### 일반적인 HTTP 상태 코드

- **200 OK**: 요청 성공
- **400 Bad Request**: 잘못된 요청 형식
- **401 Unauthorized**: 인증 필요 (일부 엔드포인트)
- **404 Not Found**: 리소스를 찾을 수 없음
- **422 Unprocessable Entity**: 유효하지 않은 데이터
- **500 Internal Server Error**: 서버 내부 오류

### 문제 해결 체크리스트

1. **Content-Type 헤더 확인**: JSON 요청 시 `Content-Type: application/json` 필수
2. **URL 확인**: 올바른 포트 번호 사용 (8000, 8001)
3. **JSON 형식 검증**: 유효한 JSON 형식인지 확인
4. **서비스 상태 확인**: 헬스체크 엔드포인트로 서비스 상태 확인
5. **로그 확인**: `docker-compose logs -f [서비스명]`으로 상세 로그 확인

## 📝 추가 리소스

- **메인 문서**: `/README.md`
- **문제 해결 가이드**: `/API_TROUBLESHOOTING.md`
- **기능점검결과**: `/기능점검결과.md`
- **개발 로드맵**: `/Todo.md`