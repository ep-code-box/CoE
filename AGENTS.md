# Repository Guidelines

The CoE workspace contains two Python services—`CoE-Backend/` (FastAPI agent backend) and `CoE-RagPipeline/` (retrieval and analysis)—plus shared operational tooling at the repository root. Each service groups HTTP routers under `api/`, orchestration in `core/`, business logic in `services/`, shared helpers in `tools/`, and entry points in `main.py`. Tests mirror this structure under `*/tests/test_*.py`, while deployment assets such as `docker-compose.*.yml`, `nginx/`, `scripts/`, `run_all.sh`, and `stop_all.sh` remain at the top level.

## Build, Test, and Development Commands
- `./run_all.sh full` boots every service and dependency; use `./run_all.sh local` when only infrastructure is required for API work.
- `./scripts/run_dev.sh` and `./scripts/run_prd.sh` compose backend and RAG stacks with profile-specific configurations.
- Work on a single service with `(cd CoE-Backend && ./run.sh)` or `(cd CoE-RagPipeline && ./run.sh)`, and run `pytest -q` within each directory; add `--cov=.` in the RAG pipeline when coverage matters.
- Restart individual containers via `docker compose` as needed and inspect live output with `docker compose logs -f <service>`.

## Coding Style & Naming Conventions
Target Python 3.11 with four-space indentation and explicit type hints for public APIs. Follow `snake_case` for modules/functions, `PascalCase` for classes, and suffix tooling modules with `_tool.py` (plus optional `_map.py`). Lint the backend using `ruff check CoE-Backend`; within `CoE-RagPipeline`, run `flake8` and `mypy` per its `requirements*.txt`.

## Testing Guidelines
Write tests with `pytest` (and `pytest-asyncio` for async flows). Place fixtures near consuming modules and name files `test_*.py` to mirror the code layout. Execute the relevant service suite before committing and prefer regression coverage when patching bugs.

## Commit & Pull Request Guidelines
Adopt Conventional Commits such as `feat(backend): add dynamic tools API`. Pull requests should link issues, call out affected services or profiles, and document config/env changes (e.g., `RUN_MIGRATIONS`, `.env` keys). Include sample cURL commands or screenshots for API updates and highlight rollout or migration sequencing when applicable.

## Security & Configuration Tips
Keep secrets out of version control—bootstrap from `.env.example`. Default `RUN_MIGRATIONS=false` unless deploying with migrations enabled. When services communicate inside containers, use internal hostnames like `coe-ragpipeline-dev:8001`; fall back to `host.docker.internal` only when the host must reach a container. Restart Nginx with the profile-specific command after configuration changes.
