# Prod Deploy (Concise)

This is the minimal, copy-paste guide for production.

Requirements
- DNS: `greatcoe.cafe24.com` points to this server.
- Firewall: inbound `80/tcp` open. (HTTPS not used)

Start (one-shot cutover)
1) Stop any existing Nginx on 80/443
   - `docker stop nginx` (if present)

2) Start prod stack (isolated infra)
   - `docker compose -f docker-compose.full.yml --profile prod up -d`

3) Start edge (reverse proxy, HTTP only)
   - `docker compose -f docker-compose.full.yml --profile edge up -d`

4) Health checks
   - `curl -I http://greatcoe.cafe24.com`

Runtime layout
- Prod backend: host `:18000`
- Prod RAG: host `:18001`
- Edge: `80/443` (public)

Common ops
- Reload Nginx: `docker exec nginx-edge nginx -s reload`
- Migrations (if needed):
  - `docker compose -f docker-compose.full.yml exec coe-backend-prod alembic upgrade head`
  - `docker compose -f docker-compose.full.yml exec coe-ragpipeline-prod alembic upgrade head`

Rollback
- `docker compose -f docker-compose.full.yml --profile edge down`
- `docker start nginx` (old)
