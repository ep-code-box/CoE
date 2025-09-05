# Dev Deploy (Concise)

Dev runs behind the same domain using ports.

Access
- HTTP: `http://greatcoe.cafe24.com:8080`

Start
1) Start dev stack (isolated infra)
   - `docker compose -f docker-compose.full.yml --profile dev up -d`

2) Ensure edge is running (for proxying, HTTP only)
   - `docker compose -f docker-compose.full.yml --profile edge up -d`

3) Health checks
   - `curl -I http://greatcoe.cafe24.com:8080`
   - (HTTPS not used)

Notes
- No separate dev DNS is required.
- HTTPS is not used in this setup.
- Dev backend: host `:18002`, Dev RAG: host `:18003`.
