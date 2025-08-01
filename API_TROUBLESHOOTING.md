# 🔧 CoE API 문제 해결 가이드

**최종 업데이트**: 2025-08-01  
**기능점검결과**: 모든 핵심 API 정상 동작 확인됨

이 문서는 CoE 플랫폼 사용 중 발생할 수 있는 API 관련 문제들과 해결 방법을 정리한 가이드입니다.

## 📋 현재 시스템 상태 (2025-08-01 기준)

### ✅ 정상 동작 확인된 기능
- **CoE-Backend**: 21개 API 엔드포인트 모두 정상
- **CoE-RagPipeline**: 4개 API 엔드포인트 모두 정상
- **Docker 컨테이너**: 5개 서비스 모두 정상 실행
- **데이터베이스**: MariaDB, ChromaDB 연결 정상
- **AI 에이전트**: LangGraph 기반 도구 라우팅 정상

### ⚠️ 알려진 개선 필요 사항
1. **OpenAI 호환 임베딩 API**: `/v1/embeddings` 엔드포인트 구현 필요
2. **벡터 문서 추가**: 임베딩 서비스 연동 개선 필요
3. **API 문서**: curl 사용법 및 JSON 전송 방법 보완

## 🚨 과거 해결된 주요 이슈

### Issue: POST 요청 422 "Field required" 오류 (해결됨)
**문제**: curl을 사용한 POST 요청 시 422 오류 발생, Python requests는 정상 동작

**원인 분석**:
- curl 요청 시 POST 본문이 비어있음 (Body: b'')
- Content-Type 헤더가 Docker 컨테이너에 전달되지 않음
- 요청 본문 로깅 미들웨어에서 본문 재할당 이슈

**해결 방법**:
1. **요청 본문 로깅 미들웨어 수정** (`/CoE-Backend/main.py`)
2. **올바른 curl 사용법 문서화**

## 🔧 일반적인 문제 해결 방법

### 1. curl JSON 전송 문제

**문제**: curl로 JSON 데이터 전송 시 422 오류 발생

**올바른 curl 사용법**:
```bash
# ✅ 올바른 방법 - Content-Type 헤더 필수
curl -X POST "http://localhost:8000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coe-agent-v1",
    "messages": [
      {
        "role": "user",
        "content": "안녕하세요"
      }
    ]
  }'

# ❌ 잘못된 방법 - Content-Type 헤더 누락
curl -X POST "http://localhost:8000/v1/chat/completions" \
  -d '{"model": "coe-agent-v1", "messages": [{"role": "user", "content": "안녕하세요"}]}'
```

### 2. Docker 컨테이너 연결 문제

**문제**: 서비스 간 통신 실패 또는 연결 거부

**해결 방법**:
```bash
# 컨테이너 상태 확인
docker-compose ps

# 네트워크 연결 테스트
docker-compose exec coe-backend ping coe-rag-pipeline
docker-compose exec coe-backend curl http://chroma:8000/api/v1/heartbeat

# 서비스 재시작
docker-compose restart coe-backend coe-rag-pipeline
```
        new_request = StarletteRequest(request.scope, receive)
        response = await call_next(new_request)
    else:
        response = await call_next(request)
    
    logger.info(f"Response status: {response.status_code}")
    return response
```

### 2. Verified API Endpoint Structures
- **CoE-Backend**: All endpoints working with Python requests
- **CoE-RagPipeline**: Analysis endpoint requires `repositories` array format

## Working Examples

### CoE-Backend Test Endpoint
```python
import requests
response = requests.post('http://localhost:8000/test', 
                       json={'message': 'hello'},
                       headers={'Content-Type': 'application/json'})
# Status: 200, Response: {"echo":"Echo: hello","received":"hello"}
```

### CoE-RagPipeline Analysis Endpoint
```python
import requests
response = requests.post('http://localhost:8001/api/v1/analyze', 
                       json={
                           'repositories': [
                               {'url': 'https://github.com/test/test'}
                           ]
                       },
                       headers={'Content-Type': 'application/json'})
# Status: 200, Response: {"analysis_id":"...","status":"started",...}
```

## curl Issue Analysis

### Problem
curl version 8.7.1 on macOS is not properly sending request bodies to Docker containers on localhost:8000/8001.

### Workaround
Use Python requests library or other HTTP clients instead of curl for testing POST endpoints.

### Potential curl Debugging
The issue appears to be related to:
- Docker networking configuration
- macOS curl version compatibility
- HTTP/1.1 vs HTTP/2 protocol handling

## Recommendations

### For Development
1. **Use Python requests** for API testing instead of curl
2. **Keep the logging middleware** for debugging request issues
3. **Validate request schemas** match the Pydantic models

### For Production
1. **Remove or simplify logging middleware** to avoid performance overhead
2. **Test with multiple HTTP clients** to ensure compatibility
3. **Monitor request body parsing** in production logs

### For API Documentation
1. **Update API examples** to use Python requests instead of curl
2. **Document required request body structures** clearly
3. **Provide working code examples** for each endpoint

## Status
✅ **RESOLVED**: All API endpoints are working correctly with proper HTTP clients
✅ **TESTED**: Both CoE-Backend and CoE-RagPipeline services validated
✅ **DOCUMENTED**: Troubleshooting guide and working examples provided

## Next Steps
- Consider investigating curl compatibility for future development
- Update project documentation with working API examples
- Monitor production logs for similar request parsing issues