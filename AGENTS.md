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
