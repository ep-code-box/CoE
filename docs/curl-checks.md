# Quick Curl Checks

IMPORTANT: RAG Pipeline는 향후 Backend를 통해서만 호출하도록 전환될 예정입니다.
직접 접근(예: localhost:8001, /rag/*) 예시는 점진적으로 제거됩니다. 새로운 스크립트/클라이언트는
반드시 Backend 엔드포인트를 사용하세요. (적용은 유예 기간 후 순차적 진행)

> 참고: docker-compose.local.yml 또는 dev.yml로 올렸다면
- Backend: `http://localhost/agent` (nginx 프록시, prefix strip)
> - RAG Pipeline: `http://localhost:8001` (직접 호출은 곧 중단 예정, Backend 경유 권장)
> - 로컬 self-signed HTTPS를 쓰면 `-k` 옵션을 추가하세요.

## Backend

- List LangFlows (GET)

```
curl -sS http://localhost/agent/flows/ | jq .
```

- Register/Upsert a LangFlow (POST)

```
curl -sS -X POST http://localhost/agent/flows/ \
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
curl -sS -X POST http://localhost/agent/v1/embeddings \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "text-embedding-3-large",
    "input": ["hello world"]
  }' | jq .
```

## RAG (직접 호출 예시 — 점진적 중단 예정)

- Start analysis with enhanced flags (POST)
```
curl -sS -X POST http://localhost/rag/api/v1/analyze \
  -H 'Content-Type: application/json' \
  -d '{
    "repositories": [{"url": "https://github.com/octocat/Hello-World.git", "branch": "main"}],
    "include_ast": true,
    "include_tech_spec": true,
    "include_correlation": true,
    "include_tree_sitter": true,
    "include_static_analysis": true,
    "include_dependency_analysis": true,
    "generate_report": true,
    "group_name": "MyTeamA"
  }' | jq .
```

- Get analysis result (GET)
```
curl -sS http://localhost/rag/api/v1/results/<analysis_id> | jq .
```

- Vector search with group filter (POST)
```
curl -sS -X POST http://localhost/rag/api/v1/search \
  -H 'Content-Type: application/json' \
  -d '{ "query": "결제 모듈", "k": 5, "group_name": "MyTeamA" }' | jq .
```

- Embed arbitrary content (POST)
```
curl -sS -X POST http://localhost/rag/api/v1/embed-content \
  -H 'Content-Type: application/json' \
  -d '{
    "source_type": "text",
    "source_data": "This is a sample content to embed",
    "group_name": "docs",
    "title": "Sample"
  }' | jq .
```

- List all groups (GET)
```
curl -sS http://localhost/rag/api/v1/groups | jq .
```

- Ingest RDB schema (POST)
```
curl -sS -X POST http://localhost/rag/api/v1/ingest_rdb_schema | jq .
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

- Chat completion with group filter (optional)

```
curl -sS -X POST http://localhost/agent/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "ax4",
    "messages": [ {"role": "user", "content": "만나이 계산 19850421"} ],
    "context": "aider",
    "group_name": "dev-team"
  }' | jq .
```

## RAG Pipeline

- Health (GET)

```
curl -sS http://localhost/rag/health | jq .
```

- Vector search (POST)

```
curl -sS -X POST http://localhost/rag/api/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "FastAPI 라우터",
    "k": 3
  }' | jq .
```

- Create embeddings (POST)

```
curl -sS -X POST http://localhost/rag/api/v1/embeddings \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "text-embedding-3-large",
    "input": ["hello world"]
  }' | jq .
```

- Vector DB stats (GET)

```
curl -sS http://localhost/rag/api/v1/stats | jq .
```

## Tips

- HTTPS 로컬 인증서 사용 시: `curl -k https://localhost/...`
- Backend 컨테이너 포트(8000)는 직접 노출되지 않습니다. `nginx`를 통해 `http://localhost`로 접근하세요.
- 모델 설정은 `CoE-Backend/config/models.json`과 `.env`를 참고하세요.
문서 맵
- 배포/기동: `docs/DEPLOY.md`
- 마이그레이션: `docs/OPERATIONS.md`
- Swagger/UI 경로: `docs/SWAGGER_GUIDE.md`
 - 모니터링: `docs/MONITORING.md`

## Monitoring quick checks

- Grafana (local)
```
curl -I http://localhost/grafana/
```

- Grafana (edge)
```
curl -I http://greatcoe.cafe24.com/grafana/
```

- Loki API (optional)
```
curl -sS 'http://localhost/loki/loki/api/v1/label/__name__/values' | jq .  # local
curl -sS 'http://greatcoe.cafe24.com/loki/loki/api/v1/status/build' | jq . # prod edge
```
