# RAG Proxy API Guide / RAG 프록시 API 가이드

Backend now mediates all calls to CoE-RagPipeline. Use these `/v1/rag/*`
endpoints from tools, frontends, or external callers instead of hitting
the RAG service directly.

백엔드가 이제 CoE-RagPipeline 호출을 중개합니다. 파이프라인을 직접
호출하지 말고, 도구·프론트엔드·외부 시스템 모두 `/v1/rag/*`
엔드포인트를 이용하세요.

- **Backend base URL (direct FastAPI)**: `http://localhost:8000`
- **Backend base URL (via nginx compose profile)**: `http://localhost/agent`
- **Effective prefix**: append `/v1/rag` to the base URL above
- **Env override**: set `RAG_PIPELINE_URL` or legacy `RAG_PIPELINE_BASE_URL`
  if the pipeline runs on a non-default host. Timeout defaults to 300s;
  adjust with `RAG_PIPELINE_TIMEOUT` when long analyses are expected.

- **백엔드 기본 URL (FastAPI 직접 접근)**: `http://localhost:8000`
- **백엔드 기본 URL (nginx compose 프로필)**: `http://localhost/agent`
- **공통 프리픽스**: 위 기본 URL 뒤에 항상 `/v1/rag`를 붙입니다.
- **환경 변수**: 파이프라인이 다른 호스트에서 동작하면
  `RAG_PIPELINE_URL`(또는 `RAG_PIPELINE_BASE_URL`)을 설정하세요. 기본
  타임아웃은 300초이며, 장시간 분석에는 `RAG_PIPELINE_TIMEOUT`으로
  조정할 수 있습니다.

> Example base path with nginx proxy: `http://localhost/agent/v1/rag`
> Direct FastAPI example: `http://localhost:8000/v1/rag`

> nginx 프록시 예시 기본 경로: `http://localhost/agent/v1/rag`
> FastAPI 직접 호출 예시: `http://localhost:8000/v1/rag`

## 1. Start or Reuse an Analysis / 분석 시작 또는 재사용

```
POST /v1/rag/analyze
Content-Type: application/json
```

```json
{
  "repositories": [
    {
      "url": "https://github.com/octocat/Hello-World.git",
      "branch": "main",
      "name": "hello"
    }
  ],
  "include_ast": true,
  "include_tech_spec": true,
  "include_correlation": true,
  "include_tree_sitter": true,
  "include_static_analysis": true,
  "include_dependency_analysis": true,
  "generate_report": true,
  "group_name": "coe-core-team"
}
```

### Response (analysis queued)

```json
{
  "analysis_id": "4f5e0f9d-3b6d-4c46-8e81-a6fe0ba9913e",
  "status": "started",
  "message": "분석이 시작되었습니다. /results/... 엔드포인트로 결과를 확인하세요.",
  "existing_analyses": null
}
```

If the target repo/branch was analyzed previously, `status` will be
`existing` and `existing_analyses` lists the reusable IDs.

target 레포지토리/브랜치가 이미 분석된 적이 있다면 `status`가 `existing`
으로 표시되고, `existing_analyses`에 재사용 가능한 분석 ID가 포함됩니다.

## 2. Fetch Analysis Results / 분석 결과 조회

```
GET /v1/rag/results/{analysis_id}
```

Returns the full analysis document (repositories, summaries, metrics,
etc.). Useful when a tool needs to inspect AST or generated reports.

전체 분석 문서를 반환합니다(레포지토리, 요약, 지표 등). AST나 생성 리포트를
확인해야 하는 도구에서 활용하세요.

### List Available Results / 사용 가능한 결과 목록

```
GET /v1/rag/results
```

Returns recent analyses with metadata (`status`, timestamps,
`repository_count`). Use this before asking for a specific result.

최근 분석 목록과 메타데이터(`status`, 타임스탬프, `repository_count`)를
반환합니다. 특정 분석 ID를 요청하기 전에 확인하면 좋습니다.

## 3. Semantic Search / 시맨틱 검색

```
POST /v1/rag/search
Content-Type: application/json
```

```json
{
  "query": "결제 모듈",
  "k": 5,
  "group_name": "coe-core-team"
}
```

Optional filters:
- `analysis_id`: restrict to a specific analysis snapshot.
- `repository_url`: prefer the latest analysis of a repo.
- `group_name`: scope results to repositories analyzed for a specific group.
- `filter_metadata`: pass any field supported by the pipeline’s vector
  store (e.g., `{"document_type": "tech_spec"}`).

선택 필터:
- `analysis_id`: 특정 분석 결과로 검색 범위를 제한합니다.
- `repository_url`: 해당 레포지토리의 최신 분석을 우선 사용합니다.
- `group_name`: 지정한 그룹에 속한 분석 결과로 범위를 한정합니다.
- `filter_metadata`: 파이프라인 벡터 저장소가 지원하는 메타데이터 필드를 전달합니다
  (예: `{"document_type": "tech_spec"}`).

Response is an array of documents with `content`, `metadata`,
`score`, and (when available) `rerank_score`.

응답은 `content`, `metadata`, `score`, (가능한 경우) `rerank_score`를 포함한
문서 배열입니다.

## 4. Ingest RDB Schema / RDB 스키마 임베딩

```
POST /v1/rag/ingest/rdb-schema
```

Triggers the pipeline’s database schema extractor and embedding job.
Returns a status payload describing how many tables/columns were
embedded.

MariaDB 스키마(테이블/컬럼)를 추출해 벡터 저장소에 임베딩합니다. 임베딩된
항목 수 등을 담은 상태 응답을 반환합니다.

## Quick Curl Snippets / 빠른 Curl 예시

Use `jq` for readability and adjust the base URL for your profile.

`jq`를 사용하면 출력 가독성이 좋아집니다. 사용하는 docker-compose 프로필에 맞춰
`BASE` 값을 조정하세요.

```bash
# Compose (nginx) example
BASE=http://localhost/agent/v1/rag

curl -sS -X POST "$BASE/analyze" \
  -H 'Content-Type: application/json' \
  -d '{
        "repositories": [
          {"url": "https://github.com/octocat/Hello-World.git", "branch": "main"}
        ]
      }' | jq .

curl -sS "$BASE/results" | jq '.[:3]'

curl -sS "$BASE/results/4f5e0f9d-3b6d-4c46-8e81-a6fe0ba9913e" | jq '.analysis_id'

curl -sS -X POST "$BASE/search" \
  -H 'Content-Type: application/json' \
  -d '{"query": "CQRS 패턴", "group_name": "coe-core-team"}' | jq .
```

## Integration Tips / 통합 팁

- Tools under `services/tool_dispatcher.py` can now call the backend
  endpoints without handling RagPipeline auth or host discovery.
- When building new tools, prefer async `httpx` clients so FastAPI can
  reuse the event loop.
- Propagate the user’s `group_name` when available so search and
  analysis respect access filters.
- Monitor backend logs for `RAG pipeline returned` messages to track
  upstream issues (timeouts, auth, etc.).

- `services/tool_dispatcher.py` 기반 도구는 RagPipeline 인증이나 호스트 정보를
  직접 다루지 않고 백엔드 엔드포인트만 호출하면 됩니다.
- 새 도구 작성 시 비동기 `httpx` 클라이언트를 사용하면 FastAPI 이벤트 루프를
  효율적으로 재활용할 수 있습니다.
- 세션의 `group_name`을 전달해 검색 및 분석에 그룹 필터가 적용되도록 하세요.
- 백엔드 로그에서 `RAG pipeline returned` 메시지를 모니터링하면 타임아웃·권한 등
  업스트림 이슈를 빠르게 파악할 수 있습니다.

## Troubleshooting / 문제 해결

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `502 Failed to reach RAG pipeline` | Pipeline service is down or env var points to the wrong host | Ensure `CoE-RagPipeline` stack is running and `RAG_PIPELINE_URL` resolves from the backend container |
| `HTTP 401/403` | Upstream auth middleware rejecting the request | Check pipeline service auth, tokens, or IP allowlist |
| Hangs beyond 5 minutes | Large repo + default 300s timeout | Increase `RAG_PIPELINE_TIMEOUT` and redeploy backend |

| 증상 | 추정 원인 | 해결 방법 |
| --- | --- | --- |
| `502 Failed to reach RAG pipeline` | 파이프라인이 내려가 있거나 환경 변수가 잘못된 호스트를 가리킴 | `CoE-RagPipeline` 스택을 실행하고 백엔드 컨테이너에서 `RAG_PIPELINE_URL`이 해석되는지 확인 |
| `HTTP 401/403` | 업스트림 인증/권한 체계에서 거부 | 파이프라인 서비스의 인증 설정, 토큰, IP 화이트리스트를 점검 |
| 5분 이상 응답 없음 | 대규모 레포지토리 + 기본 300초 타임아웃 | `RAG_PIPELINE_TIMEOUT` 값을 늘린 뒤 백엔드 재배포 |

For more curl examples, see `docs/curl-checks.md`. Update scripts and
UI integrations to route through `/v1/rag` before direct access is
sunset.

추가 curl 예시는 `docs/curl-checks.md`에서 확인할 수 있습니다. 직접 호출이 제거되기
전에 모든 스크립트와 UI를 `/v1/rag` 경유 방식으로 업데이트하세요.
