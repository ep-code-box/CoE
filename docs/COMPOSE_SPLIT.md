Compose split: unified service names for dev/prod

Summary
- New files provide cleaner service names and fixed network names.
- Use these instead of docker-compose.full.yml profiles when you want simplicity and clarity.

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
- Dev: ./scripts/run_dev.sh
- Prod: ./scripts/run_prd.sh

Notes
- Existing full/profile file remains for advanced setups; the split files aim for readability.
- Service-to-service hosts in both files are unified:
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

