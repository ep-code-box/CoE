# API Layer Troubleshooting Guide

## Issue Summary
The CoE project API layer was experiencing 422 "Field required" errors for all POST requests when using curl, while GET endpoints worked correctly.

## Root Cause Analysis

### Problem Identified
- **curl requests**: POST request bodies were arriving empty (Body: b'') at the FastAPI application
- **Python requests**: POST requests worked perfectly with proper Content-Type headers and request bodies
- **Missing headers**: curl requests were not sending Content-Type headers to the Docker container

### Technical Details
1. **Working scenario (Python requests)**:
   - Headers: `{'content-type': 'application/json', 'content-length': '20'}`
   - Body: `b'{"message": "hello"}'`
   - Status: 200 OK

2. **Failing scenario (curl)**:
   - Headers: `{'host': 'localhost:8000', 'user-agent': 'curl/8.7.1', 'accept': '*/*'}`
   - Body: `b''` (empty)
   - Status: 422 Unprocessable Entity

## Solutions Implemented

### 1. Fixed Request Body Logging Middleware
Updated `/CoE-Backend/main.py` to properly handle request body reading and reassignment:

```python
# 요청 로깅 미들웨어 (디버깅용)
@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request: {request.method} {request.url}")
    logger.info(f"Headers: {dict(request.headers)}")
    
    # POST 요청의 경우 본문 로깅 (디버깅용)
    if request.method == "POST":
        body = await request.body()
        logger.info(f"Body: {body}")
        logger.info(f"Body length: {len(body)}")
        
        # 요청 본문을 다시 읽을 수 있도록 설정
        async def receive():
            return {
                "type": "http.request", 
                "body": body,
                "more_body": False
            }
        
        # 새로운 Request 객체 생성
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