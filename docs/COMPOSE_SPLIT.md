Compose split: unified service names for dev/prod

Summary
- The stack uses separate compose files per scope: dev, prod, edge, monitoring.
- docker-compose.full.yml has been removed.

Files
- docker-compose.dev.yml
  - Services: backend, ragpipeline, mariadb, redis, chroma
  - Network: coe-dev-net (fixed name)
  - Exposed ports: backend 18002, ragpipeline 18003
- docker-compose.prod.yml
  - Services: backend, ragpipeline, mariadb, redis, chroma
  - Network: coe-prod-net (fixed name)
  - Exposed ports: backend 18000, ragpipeline 18001

Run
- Dev: ./scripts/run_dev.sh (or `docker compose -f docker-compose.dev.yml up -d`)
- Prod: ./scripts/run_prd.sh (or `docker compose -f docker-compose.prod.yml up -d`)
- Edge: ./scripts/run_edge.sh (or `docker compose -f docker-compose.edge.yml up -d`)
- Monitoring: `docker compose -f docker-compose.monitoring.yml up -d`

Notes
- Service-to-service hosts are unified:
  - DB_HOST=mariadb, CHROMA_HOST=chroma, REDIS_HOST=redis, RAG_PIPELINE_URL=http://ragpipeline:8001

Optional: Prod DB local-only binding overlay (for secure external access via SSH tunnel)
- Create docker-compose.prod.db-local.yml (not committed) with:
  services:
    mariadb:
      ports:
        - "127.0.0.1:3307:3306"
- Apply it with:
  docker compose -f docker-compose.prod.yml -f docker-compose.prod.db-local.yml -p coe-prod up -d mariadb
- Then open a tunnel from your laptop:
  ssh -L 3307:127.0.0.1:3307 <user>@<server>
- Connect in DBeaver: host localhost, port 3307, db coe_db, user coe_user
