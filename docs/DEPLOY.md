# CoE 배포 가이드 (HTTP only)

이 문서는 HTTP 기반(HTTPS 미사용) 배포의 최소 절차를 제공합니다. Edge Nginx는 prod를 80 포트, dev를 8080 포트로 프록시합니다.

요약
- Prod: http://greatcoe.cafe24.com → prod backend(:18000), /rag/ → prod RAG(:18001)
- Dev: http://greatcoe.cafe24.com:8080 → dev backend(:18002), /rag/ → dev RAG(:18003)

준비
- DNS: greatcoe.cafe24.com → 서버 공인 IP
- 방화벽: 80 포트(필수), 8080(선택) 오픈
- 환경파일: 각 서비스의 .env.example을 복사해 사용(실제 키는 커밋 금지)

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
sudo docker compose -f docker-compose.full.yml --profile prod up -d --build -p coe-prod

# Dev
cd /home/greatjlim/projects/CoE-dev
git fetch && git checkout develop && git pull --ff-only
sudo docker compose -f docker-compose.full.yml --profile dev up -d --build -p coe-dev

# Edge (HTTP 프록시, 1회 실행)
cd /home/greatjlim/projects/CoE-prod
sudo docker compose -f docker-compose.full.yml --profile edge up -d -p edge
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
sudo docker compose -f docker-compose.full.yml --profile prod up -d --build -p coe-prod

# Dev
cd /home/greatjlim/projects/CoE-dev && git pull --ff-only
sudo docker compose -f docker-compose.full.yml --profile dev up -d --build -p coe-dev
```
6) 중지/정리
```
sudo docker compose -f docker-compose.full.yml --profile prod down -p coe-prod
sudo docker compose -f docker-compose.full.yml --profile dev down -p coe-dev
sudo docker compose -f docker-compose.full.yml --profile edge down -p edge
```

참고 문서
- 마이그레이션 운영: docs/OPERATIONS.md
- Swagger/UI: docs/SWAGGER_GUIDE.md
- cURL 예시 모음: docs/curl-checks.md
