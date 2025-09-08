# Repository Guidelines

## Project Structure & Module Organization
- `CoE-Backend/`: FastAPI AI agent server (routers in `api/`, orchestration in `core/`, business logic in `services/`, tools in `tools/`, entry `main.py`).
- `CoE-RagPipeline/`: RAG/analysis service (routers, services, analyzers, entry `main.py`).
- `docs/`: Deployment, operations, Swagger, and cURL guides.
- `docker-compose.*.yml`, `nginx/`, `run_all.sh`, `stop_all.sh`, `scripts/`: Compose profiles and helper scripts.
- Tests (when added): place under `*/tests/` with `test_*.py` files.

## Build, Test, and Development Commands
- Run full stack (all services): `./run_all.sh full`
- Infra-only for local dev: `./run_all.sh local`
- Dev profile (backend+rag): `./scripts/run_dev.sh`
- Prod profile (backend+rag): `./scripts/run_prd.sh`
- Stop stack: `./stop_all.sh`
- Run a service locally (Python):
  - Backend: `(cd CoE-Backend && ./run.sh)` → serves on `:8000`
  - RAG: `(cd CoE-RagPipeline && ./run.sh)` → serves on `:8001`
- Compose (explicit): `docker compose -f docker-compose.full.yml --profile dev up -d`

## Coding Style & Naming Conventions
- Language: Python 3.11, 4-space indent, type hints for public APIs.
- Naming: `snake_case` for files/functions, `PascalCase` for classes.
- Module layout: API routers in `api/`, domain logic in `services/`, app wiring in `core/`, tool modules as `*_tool.py` with maps as `*_map.py`.
- Lint/format: Backend uses `ruff`; RAG uses `flake8` and `mypy` (see each `requirements*.txt`).
  - Examples: `ruff check CoE-Backend`, `flake8 CoE-RagPipeline`, `mypy CoE-RagPipeline`.

## Testing Guidelines
- Framework: `pytest` (+ `pytest-asyncio` where applicable).
- Structure: `*/tests/test_*.py`; mirror package paths for clarity.
- Run: `cd CoE-Backend && pytest -q` or `cd CoE-RagPipeline && pytest -q`.
- Optional coverage (RAG has pytest-cov): `pytest --cov=.`

## Commit & Pull Request Guidelines
- Observed history: short, informal Korean summaries; no strict convention.
- Recommended style (new work): Conventional Commits.
  - Examples: `feat(backend): add dynamic tools API`, `fix(rag): handle large repo clone timeout`.
- PRs should include: clear description, linked issues, affected services/profiles, config notes (`.env` keys, `RUN_MIGRATIONS` usage), screenshots or sample cURL for API changes, and docs updates when relevant.

## Security & Configuration Tips
- Never commit secrets; use `.env` files. Seed from `*.env.example`.
- Control DB migrations via `RUN_MIGRATIONS` (default skip in ops docs); run intentionally in prod.
- For endpoints and examples, see `docs/SWAGGER_GUIDE.md` and `docs/curl-checks.md`.

## 운영/설계 주의사항
- 프로파일 분리: `full.yml`의 `dev|prod|edge` 프로파일을 섞지 말 것. 엣지에서 `/rag/`는 RAG로 프록시되며 `/rag`는 리다이렉트됨.
- 헬스 체크: 백엔드 `GET /health`, RAG `GET /rag/health`. `HEAD`는 405가 정상, 루트 `/` 404도 정상(Prod에서 문서 비공개).
- 마이그 순서: 백엔드 → RAG. 테이블 부재 시 RAG 마이그 실패 가능. 필요 시 `scripts/bootstrap_db_dev.sh`로 기초 테이블 생성.
- RUN_MIGRATIONS: 로컬/개발은 `false` 권장, 운영은 배포 타이밍에만 `true`로 명시 실행.
- Nginx 변경 반영: `docker compose restart nginx` (local), `--profile edge restart nginx-edge`(prod 엣지).
- DB 설정: MariaDB는 `utf8mb4`/`utf8mb4_unicode_ci` 사용. 볼륨 마운트 경로(Chroma/Maria/Redis) 용량 확인 후 배포.
- 환경변수: 컨테이너 내 주소 사용(예: Backend→RAG `RAG_PIPELINE_URL=http://coe-ragpipeline-dev:8001`). 호스트 접근은 `host.docker.internal` 필요.
- 로그: 호스트 로그 경로는 `docs/DEPLOY.md` 참고. 에러 시 `docker compose logs -f <svc>` 우선 확인.
- 대용량 분석: 대형 Git은 CPU/메모리 소모 큼. RAG 워커/타임아웃 조정 및 단일 요청량 제한 고려.
- 보안: 키/토큰은 `.env.*`에만, 리포에 커밋 금지. 필요 시 `nginx`에서 IP 제한/기본 인증 추가.
