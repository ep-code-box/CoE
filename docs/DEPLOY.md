# CoE 배포 가이드 (HTTP only)

이 문서는 HTTP 기반(HTTPS 미사용) 배포의 최소 절차를 제공합니다. Edge Nginx는 prod를 80 포트, dev를 8080 포트로 프록시합니다.

요약
- Prod: http://greatcoe.cafe24.com → prod backend(:18000), /rag/ → prod RAG(:18001)
- Dev: http://greatcoe.cafe24.com:8080 → dev backend(:18002), /rag/ → dev RAG(:18003)
- Monitoring: http://greatcoe.cafe24.com/grafana/ (공용 Grafana), /loki/ (옵션: Loki API)

준비
- DNS: greatcoe.cafe24.com → 서버 공인 IP
- 방화벽: 80 포트(필수), 8080(선택) 오픈
- 환경파일: 각 서비스의 .env.example을 복사해 사용(실제 키는 커밋 금지)

one shot.

sudo docker compose -p coe-dev -f docker-compose.dev.yml build backend ragpipeline && \
sudo docker compose -p coe-dev -f docker-compose.dev.yml run --rm backend alembic upgrade head && \
sudo docker compose -p coe-dev -f docker-compose.dev.yml up -d backend ragpipeline

sudo docker compose -p coe-prod -f docker-compose.prod.yml build backend ragpipeline && \
sudo docker compose -p coe-prod -f docker-compose.prod.yml run --rm backend alembic upgrade head && \
sudo docker compose -p coe-prod -f docker-compose.prod.yml up -d backend ragpipeline

복사 기반 분리 배포(권장)
1) 디렉토리 준비(한 번)
```
cd /home/greatjlim/projects
git clone <repo-url> CoE-prod
git clone <repo-url> CoE-dev
```
2) 환경 파일 준비
```
# Prod
cd /home/greatjlim/projects/CoE-prod
cp CoE-Backend/.env.example CoE-Backend/.env.prod
cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env.prod

# Dev
cd /home/greatjlim/projects/CoE-dev
cp CoE-Backend/.env.example CoE-Backend/.env.dev
cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env.dev
```
3) 기동
```
# Prod
cd /home/greatjlim/projects/CoE-prod
git fetch && git checkout main && git pull --ff-only
sudo docker compose -p coe-prod -f docker-compose.prod.yml up -d --build 

# Dev
cd /home/greatjlim/projects/CoE-dev
git fetch && git checkout develop && git pull --ff-only
sudo docker compose -p coe-dev -f docker-compose.dev.yml up -d --build 

# Edge (HTTP 프록시)
cd /home/greatjlim/projects/CoE-prod
sudo docker compose -p coe -f docker-compose.edge.yml up -d 
```
4) 헬스 체크
```
curl -I http://greatcoe.cafe24.com
curl -I http://greatcoe.cafe24.com:8080
curl -I http://greatcoe.cafe24.com:8080/rag/health
```
5) 업데이트(재배포)
```
# Prod
cd /home/greatjlim/projects/CoE-prod && git pull --ff-only
sudo docker compose -p coe-prod -f docker-compose.prod.yml up -d --build

# Dev
cd /home/greatjlim/projects/CoE-dev && git pull --ff-only
sudo docker compose -p coe-dev -f docker-compose.dev.yml up -d --build
```
6) 중지/정리
```
sudo docker compose -p coe-prod -f docker-compose.prod.yml down
sudo docker compose -p coe-dev  -f docker-compose.dev.yml  down 
sudo docker compose -p edge     -f docker-compose.edge.yml down
```

참고 문서
- 마이그레이션 운영: docs/OPERATIONS.md
- Swagger/UI: docs/SWAGGER_GUIDE.md
- cURL 예시 모음: docs/curl-checks.md
 - 모니터링: docs/MONITORING.md

## Nginx 재시작/재로드

구성 파일 변경(예: `/rag` → `/rag/` 리다이렉트) 후에는 Nginx 컨테이너를 재시작하거나 설정을 재로드하세요.

일반(기본 compose)
```
docker compose restart nginx
# 또는 설정만 재적용
docker compose exec nginx nginx -s reload
```

로컬 개발(`docker-compose.local.yml`)
```
docker compose -f docker-compose.local.yml restart nginx
# 또는
docker compose -f docker-compose.local.yml exec nginx nginx -s reload
```

엣지 프록시(edge 전용 compose)
```
docker compose -f docker-compose.edge.yml restart nginx-edge
# 또는
docker compose -f docker-compose.edge.yml exec nginx-edge nginx -s reload
```

## 모니터링 스택(Loki/Promtail/Grafana)

한 개의 모니터링 스택이 dev/prod/local 모든 로그를 수집/표시합니다.

- 실행
  - 모니터링만: `docker compose -f docker-compose.monitoring.yml up -d`
  - 전체/인프라와 함께: `./run_all.sh full --with-monitoring` 또는 `./run_all.sh local --with-monitoring`
- 접근 경로
  - 로컬: `http://localhost/grafana/`
  - Prod(Edge): `http://greatcoe.cafe24.com/grafana/`
- 참고
  - Grafana 기본 계정: `admin/admin` (운영 전 변경 필수)
  - Loki API는 `/loki/` 경로로 프록시됩니다(필요 시 사용).
  - 변경 후 Nginx 재시작 필요(위 "Nginx 재시작/재로드" 참조).

로그 경로(호스트)
- Edge(Nginx): `/home/greatjlim/projects/logs/nginx/` (prod.access.log, dev.access.log 등)
- Backend:
  - Prod: `/home/greatjlim/projects/logs/coe-backend/prod/`
  - Dev: `/home/greatjlim/projects/logs/coe-backend/dev/`
- RagPipeline:
  - Prod: `/home/greatjlim/projects/logs/coe-ragpipeline/prod/`
  - Dev: `/home/greatjlim/projects/logs/coe-ragpipeline/dev/`
