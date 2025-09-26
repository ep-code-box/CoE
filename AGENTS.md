# Repository Guidelines

## Project Structure & Module Organization
The repo hosts two Python services: `CoE-Backend/` (FastAPI agent backend) and `CoE-RagPipeline/` (retrieval and analysis). Each service organizes HTTP routers under `api/`, orchestration in `core/`, business logic in `services/`, shared helpers in `tools/`, and entry points via `main.py`. Tests mirror this layout in `*/tests/test_*.py`. Top-level operational assets live alongside the services: `docker-compose.*.yml`, `nginx/`, `scripts/`, `run_all.sh`, `stop_all.sh`, and monitoring utilities such as `grafana/` and `promtail-config.yml`.

## Build, Test, and Development Commands
- `./run_all.sh full` boots every dependency and service; use `./run_all.sh local` to start infrastructure only.
- Focus on a single service with `(cd CoE-Backend && ./run.sh)` or `(cd CoE-RagPipeline && ./run.sh)`.
- Run suites with `pytest -q`; append `--cov=.` inside `CoE-RagPipeline` when coverage reporting is required.
- Compose profile-specific stacks through `./scripts/run_dev.sh` or `./scripts/run_prd.sh`, and tail container output via `docker compose logs -f <service>`.

## Coding Style & Naming Conventions
Target Python 3.11, four-space indentation, and explicit type hints on public APIs. Prefer `snake_case` for modules/functions, `PascalCase` for classes, and suffix tooling helpers with `_tool.py` (optionally `_map.py`). Enforce style with `ruff check CoE-Backend`, and `flake8` plus `mypy` inside `CoE-RagPipeline` per its `requirements*.txt`.

## Testing Guidelines
Use `pytest` (and `pytest-asyncio` for async flows), keeping test files named `test_*.py` near the code they cover. Co-locate fixtures in the consuming package, run the relevant service suite before committing, and prioritize regression cases when squashing bugs.

## Commit & Pull Request Guidelines
Follow Conventional Commits, e.g., `feat(backend): add dynamic tools API`. Pull requests must link issues, call out impacted services or profiles, and document any config or environment deltas (`RUN_MIGRATIONS`, new `.env` keys). Include sample cURL commands or screenshots for API changes and note rollout or migration sequencing when relevant.

## Security & Configuration Tips
Keep secrets out of version control—bootstrap from `.env.example`. Default `RUN_MIGRATIONS=false` unless deployments demand migrations. Within Docker networks, prefer service hostnames such as `coe-ragpipeline-dev:8001`; fall back to `host.docker.internal` only from host-to-container. Restart Nginx with the profile-specific command after making configuration changes.
