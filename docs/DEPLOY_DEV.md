# Dev Deploy (Concise)

Dev runs behind the same domain using ports.

Access
- HTTP: `http://greatcoe.cafe24.com:8080`
- HTTPS: `https://greatcoe.cafe24.com:8443` (reuses prod certificate)

Start
1) Start dev stack (isolated infra)
   - `docker compose -f docker-compose.full.yml --profile dev up -d`

2) Ensure edge is running (for proxying)
   - `docker compose -f docker-compose.full.yml --profile edge up -d`

3) Health checks
   - `curl -I http://greatcoe.cafe24.com:8080`
   - `curl -k -I https://greatcoe.cafe24.com:8443`

Notes
- No separate dev DNS is required.
- Prod cert is used for 8443; no additional cert issuance for dev.
- Dev backend: host `:18002`, Dev RAG: host `:18003`.

