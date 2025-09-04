# Quick Curl Checks

> 참고: docker-compose.local.yml 또는 dev.yml로 올렸다면
> - Backend: `http://localhost` (nginx 프록시)
> - RAG Pipeline: `http://localhost:8001`
> - 로컬 self-signed HTTPS를 쓰면 `-k` 옵션을 추가하세요.

## Backend

- List LangFlows (GET)

```
curl -sS http://localhost/flows/ | jq .
```

- Register/Upsert a LangFlow (POST)

```
curl -sS -X POST http://localhost/flows/ \
  -H 'Content-Type: application/json' \
  -d '{
    "endpoint": "hello-flow",                             
    "description": "샘플 LangFlow. hello를 출력합니다.",
    "flow_id": "lf-hello-001",                           
    "flow_body": {                                        
      "name": "hello-flow",                             
      "id": "lf-hello-001",                             
      "description": "A minimal LangFlow JSON stub.",
      "is_component": false,
      "data": { "nodes": [], "edges": [], "viewport": null }
    },
    "contexts": ["openWebUi", "aider"]                  
  }' | jq .
```

Notes
- `endpoint`: 동적 실행 경로로 사용됩니다. 아래 실행 예시 참조.
- `flow_id`: LangFlow 고유 ID(문자열). `flow_body.id`와 일치시키는 것을 권장합니다.
- `flow_body`: LangFlow JSON 스텁. 최소 `name`, `id`, `data.nodes`, `data.edges`가 필요합니다.
- `contexts` 또는 `context`: 이 Flow를 노출할 프론트 컨텍스트 목록입니다(예: `aider`, `continue.dev`, `openWebUi`).

- Execute a registered Flow (POST)

```
curl -sS -X POST http://localhost/flows/run/hello-flow \
  -H 'Content-Type: application/json' \
  -d '{ "text": "Ping" }' | jq .
```

- Embeddings proxy (POST → delegates to RAG Pipeline)

```
curl -sS -X POST http://localhost/v1/embeddings \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "text-embedding-3-large",
    "input": ["hello world"]
  }' | jq .
```

- Chat completion (optional; requires a configured model in Backend)

```
curl -sS -X POST http://localhost/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "ax4",
    "messages": [ {"role": "user", "content": "안녕"} ],
    "context": "openWebUi"
  }' | jq .
```

## RAG Pipeline

- Health (GET)

```
curl -sS http://localhost:8001/health | jq .
```

- Vector search (POST)

```
curl -sS -X POST http://localhost:8001/api/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "FastAPI 라우터",
    "k": 3
  }' | jq .
```

- Create embeddings (POST)

```
curl -sS -X POST http://localhost:8001/api/v1/embeddings \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "text-embedding-3-large",
    "input": ["hello world"]
  }' | jq .
```

- Vector DB stats (GET)

```
curl -sS http://localhost:8001/api/v1/stats | jq .
```

## Tips

- HTTPS 로컬 인증서 사용 시: `curl -k https://localhost/...`
- Backend 컨테이너 포트(8000)는 직접 노출되지 않습니다. `nginx`를 통해 `http://localhost`로 접근하세요.
- 모델 설정은 `CoE-Backend/config/models.json`과 `.env`를 참고하세요.
