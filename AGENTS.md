# Repository Guidelines

## Project Structure & Module Organization
The repository hosts two Python services: `CoE-Backend/` for the FastAPI agent backend and `CoE-RagPipeline/` for retrieval and analysis. Each service organizes HTTP routers under `api/`, orchestration in `core/`, business logic in `services/`, and shared helpers in `tools/`. Entry points live in `main.py`. Tests mirror package paths under `*/tests/test_*.py`. Operational assets, including `docker-compose.*.yml`, `nginx/`, `scripts/`, `run_all.sh`, and `stop_all.sh`, sit at the root. Docs covering deployment, Swagger, and cURL flows reside in `docs/`.

## Build, Test, and Development Commands
Use `./run_all.sh full` to boot every service and dependency, or `./run_all.sh local` when you only need infrastructure for API development. `./scripts/run_dev.sh` and `./scripts/run_prd.sh` compose backend + RAG stacks in their respective profiles. For focused work, run `(cd CoE-Backend && ./run.sh)` or `(cd CoE-RagPipeline && ./run.sh)`. Execute `pytest -q` from each service directory to run tests; add `--cov=.` in the RAG pipeline when coverage is required.

## Coding Style & Naming Conventions
Target Python 3.11 with four-space indentation. Expose public APIs with explicit type hints. Follow `snake_case` for modules and functions, `PascalCase` for classes, and suffix tooling modules with `_tool.py` alongside optional `_map.py`. Run `ruff check CoE-Backend` to lint the backend, and use `flake8` plus `mypy` inside `CoE-RagPipeline` per the service-specific `requirements*.txt`.

## Testing Guidelines
Author tests with `pytest` (and `pytest-asyncio` for async flows). Place fixtures near their consuming modules. Name test files `test_*.py`, mirroring the code directory structure. Run the relevant service test suite before committing, and prefer regression tests for behavioral fixes.

## Commit & Pull Request Guidelines
Adopt Conventional Commits, e.g., `feat(backend): add dynamic tools API`. Pull requests should link issues, note affected services or profiles, summarize config/env changes (such as `RUN_MIGRATIONS` or `.env` keys), and include sample cURL commands or screenshots for API-facing updates. Update docs when behavior shifts and flag rollout or migration sequencing as needed.

## Security & Configuration Tips
Keep secrets out of version control; bootstrap from `.env.example`. Default `RUN_MIGRATIONS=false` unless explicitly deploying with migrations enabled. When services communicate in containers, use internal hostnames like `coe-ragpipeline-dev:8001`; fall back to `host.docker.internal` only when the host must reach a container. Inspect service logs via `docker compose logs -f <service>` and restart Nginx with the profile-specific command after config changes.
