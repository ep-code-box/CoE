# CoE 배포 가이드 (Local / Dev / Prod)

본 문서는 Local, Dev(dev.greatcoe.cafe24.com), Prod(greatcoe.cafe24.com) 환경에서 CoE 시스템을 기동/중지/배포/인증서 운영하는 방법을 정리합니다.

## 개요
- 구성: `docker-compose.yml`(공통) + 환경별 오버라이드 3종
- 리버스 프록시: Nginx (Backend `/`, RagPipeline `/rag/`)
- 인증서: Let’s Encrypt(무료, 이메일 없이) 자동 발급/자동 갱신

## 사전 요구 사항
- DNS
  - `dev.greatcoe.cafe24.com` → 서버 공인 IP
  - `greatcoe.cafe24.com` → 서버 공인 IP
- 방화벽: 80/443 포트 외부 개방
- 로컬(Local)은 HTTPS 미사용(또는 자체서명) 권장
- 환경파일: 실제 키는 커밋하지 말고 예시 파일을 복사해 사용
  - Backend: `cp CoE-Backend/.env.example CoE-Backend/.env` (필요 시 `.env.dev`, `.env.prod` 등 분리)
  - RagPipeline: `cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env`
  - 실제 키는 `__REPLACE_ME__` 항목 교체 후, `.gitignore`에 의해 추적 제외됨

## 환경 파일 관리 (.env)

- 커밋 금지: 모든 `.env*`는 `.gitignore`로 무시됩니다. 실제 키/토큰은 레포에 올리지 않습니다.
- 예시 파일: 각 서비스에 `.env.example`가 있으니 복사해 사용하세요.
  - Dev/Prod 생성 예:
    - `cp CoE-Backend/.env.example CoE-Backend/.env.dev`
    - `cp CoE-Backend/.env.example CoE-Backend/.env.prod`
    - `cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env.dev`
    - `cp CoE-RagPipeline/.env.example CoE-RagPipeline/.env.prod`
- 필수 키 입력: `SKAX_API_KEY`, `OPENAI_API_KEY`, `JWT_SECRET_KEY` 등은 실제 값으로 교체 필요
- Compose 오버라이드: 완전 격리 스택(`*.full.yml`) 사용 시 DB/Chroma/Redis 접속값은 compose가 덮어쓰므로 `.env` 기본값 그대로 둬도 무방합니다.

## 비밀 유출 대응 (GitHub Push Protection 차단 시)

증상: push 시 "Push cannot contain secrets"로 차단되는 경우.

1) 현재 워킹 트리에서 `.env` 추적 해제(이미 적용된 경우 건너뜀)
```
files=(.env .env.dev .env.prod .env.local \
       CoE-Backend/.env CoE-Backend/.env.dev CoE-Backend/.env.prod CoE-Backend/.env.local \
       CoE-RagPipeline/.env CoE-RagPipeline/.env.dev CoE-RagPipeline/.env.prod CoE-RagPipeline/.env.local)
for f in $files; do
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    git rm --cached "$f"
  fi
done
git add -A && git commit -m "chore: untrack env files and add .env.example templates"
```

2) 여전히 차단되면(과거 커밋에 비밀 존재), 히스토리에서 `.env` 제거
- 설치(택1): `brew install git-filter-repo` 혹은 `pipx install git-filter-repo`
- 실행(레포 루트):
```
git filter-repo --force \
  --path .env --path .env.dev --path .env.prod --path .env.local \
  --path CoE-Backend/.env --path CoE-Backend/.env.dev --path CoE-Backend/.env.prod --path CoE-Backend/.env.local \
  --path CoE-RagPipeline/.env --path CoE-RagPipeline/.env.dev --path CoE-RagPipeline/.env.prod --path CoE-RagPipeline/.env.local \
  --invert-paths
# origin이 제거되므로 재등록 후 강제 푸시
git remote add origin <원격URL>
git push --force -u origin main
```

3) 키 회전: 노출된 `OPENAI_API_KEY`/`SKAX_API_KEY`/`JWT_SECRET_KEY`는 즉시 폐기·재발급하여 교체하세요.

## 파일 구조 요약
- `docker-compose.yml`: 공통 인프라/서비스 정의
- `docker-compose.local.yml`: 로컬 개발용 오버라이드 (핫리로드, 코드 바인드, 마이그 OFF)
- `docker-compose.dev.yml`: Dev용 오버라이드 (마이그 ON, HTTPS 자동 발급/갱신)
- `docker-compose.prod.yml`: Prod용 오버라이드 (마이그 ON, HTTPS 자동 발급/갱신)
- `nginx/nginx.dev.conf`, `nginx/nginx.prod.conf`: 각 환경용 Nginx 설정
- `nginx/certbot/www`, `nginx/certbot/conf`: Certbot 웹루트/인증서 볼륨 경로

## Local (개발 환경)
- 기동
  - `docker compose -f docker-compose.yml -f docker-compose.local.yml up -d --build --remove-orphans`
- 중지/정리
  - `docker compose -f docker-compose.yml -f docker-compose.local.yml down --remove-orphans`
- 특정 서비스 재빌드/재기동 예시 (RagPipeline)
  - `docker compose -f docker-compose.yml -f docker-compose.local.yml build coe-ragpipeline`
  - `docker compose -f docker-compose.yml -f docker-compose.local.yml up -d coe-ragpipeline`
- 로그 확인
  - 전체: `docker compose -f docker-compose.yml -f docker-compose.local.yml logs -f`
  - 특정: `docker compose -f docker-compose.yml -f docker-compose.local.yml logs -f nginx`
- 특징
  - Backend/RagPipeline: `uvicorn --reload`
  - 소스 디렉토리 바인드 마운트, Alembic 마이그레이션 비활성(RUN_MIGRATIONS=false)

## Dev (dev.greatcoe.cafe24.com)
- 기동(최초 인증서 발급 포함)
  - `docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build --remove-orphans`
- 중지/정리
  - `docker compose -f docker-compose.yml -f docker-compose.dev.yml down --remove-orphans`
- 인증서 상태 확인
  - 발급 로그: `docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f certbot`
  - 갱신 로그: `docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f certbot-renew`
- 특정 서비스 재배포 예시 (Backend)
  - `docker compose -f docker-compose.yml -f docker-compose.dev.yml build coe-backend`
  - `docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d coe-backend`
- 헬스체크
  - `curl -I https://dev.greatcoe.cafe24.com/`
  - `curl -I https://dev.greatcoe.cafe24.com/rag/health`
- 특징
  - Backend/RagPipeline: gunicorn, Alembic 마이그레이션 활성(RUN_MIGRATIONS=true)
  - HTTPS 자동 발급/자동 갱신

## Prod (greatcoe.cafe24.com)
- 기동(최초 인증서 발급 포함)
  - `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build --remove-orphans`
- 중지/정리
  - `docker compose -f docker-compose.yml -f docker-compose.prod.yml down --remove-orphans`
- 인증서 상태 확인
  - 발급 로그: `docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f certbot`
  - 갱신 로그: `docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f certbot-renew`
- 특정 서비스 재배포 예시 (RagPipeline)
  - `docker compose -f docker-compose.yml -f docker-compose.prod.yml build coe-ragpipeline`
  - `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d coe-ragpipeline`
- 헬스체크
  - `curl -I https://greatcoe.cafe24.com/`
  - `curl -I https://greatcoe.cafe24.com/rag/health`
- 특징
  - Backend/RagPipeline: gunicorn, Alembic 마이그레이션 활성(RUN_MIGRATIONS=true)
  - HTTPS 자동 발급/자동 갱신

## SSL/TLS (Let’s Encrypt)
- 방식: 웹루트(HTTP-01), 이메일 없이 발급(`--register-unsafely-without-email`)
- 최초 기동
  - `setup-ssl-dummy`가 자가서명 임시 인증서 생성 → Nginx가 443 시작
  - `certbot` 컨테이너가 실인증서 발급 → Nginx가 인증서 변경 감지 시 자동 reload
- 자동 갱신
  - `certbot-renew` 컨테이너가 12시간마다 `certbot renew --keep-until-expiring` 실행
  - Nginx는 인증서 변경 감지 시 자동 reload
- 인증서 저장 위치(호스트)
  - `./nginx/certbot/conf` ↔ 컨테이너 `/etc/letsencrypt`
- 주의: 이메일 미사용 구성으로 만료/갱신 실패 알림 메일은 수신하지 않습니다.

## 공통 운영 명령
- 상태 확인: `docker compose -f <...> ps`
- 로그 실시간: `docker compose -f <...> logs -f [service]`
- 고아 컨테이너 정리: `docker compose -f <...> up -d --remove-orphans` 또는 `docker compose -f <...> down --remove-orphans`
- 마이그레이션 수동 실행(필요 시)
  - RagPipeline: `docker compose -f <...> exec coe-ragpipeline alembic upgrade head`
  - Backend: `docker compose -f <...> exec coe-backend alembic upgrade head`

## 트러블슈팅
- 고아 컨테이너 경고(WARN Found orphan containers)
  - 원인: 이전 이름의 서비스 컨테이너가 남아 있음
  - 해결: `--remove-orphans` 옵션으로 up/down 실행 또는 `docker rm -f <container>`
- HTTPS 접속 시 인증서 경고(초기)
  - 원인: 최초 기동 직후 실인증서가 발급되기 전(자가서명)
  - 해결: 수 초~수십 초 후 실인증서 적용 및 Nginx 자동 reload 확인
- 인증서 발급 실패
  - 체크: DNS가 올바르게 서버 IP를 가리키는지, 80/443이 외부에 열려 있는지
  - 로그: `certbot`, `nginx` 서비스 로그 확인

---
본 가이드는 레포지토리 내 환경 파일과 Compose 오버라이드 파일을 기준으로 작성되었습니다. 운영 정책에 따라 경로/도메인/주기 등을 조정해 사용할 수 있습니다.

---

## 완전 격리 배포(Edge + Prod Full + Dev Full)

목표: 기존 컨테이너들과 충돌 없이 Dev/Prod를 각자 인프라(MariaDB/Chroma/Redis)까지 완전 격리하고, 단일 Nginx(Edge)로 두 도메인을 프록시합니다.

구성 파일
- `docker-compose.edge.yml`: Edge Nginx + Certbot (80/443)
- `nginx/nginx.edge.conf`: Edge 라우팅 (prod→18000/18001, dev→18002/18003)
- `docker-compose.prod.full.yml`: Prod 풀 스택 (격리 인프라 포함)
- `docker-compose.dev.full.yml`: Dev 풀 스택 (격리 인프라 포함)

포트 맵핑(호스트)
- Prod: Backend `18000`, Rag `18001`
- Dev: Backend `18002`, Rag `18003`
- Edge: `80/443`

사전 준비
- DNS: `greatcoe.cafe24.com`, `dev.greatcoe.cafe24.com` → 운영 서버 IP
- 방화벽: `80`, `443` 오픈

배포 순서(원샷 전환)
1) 기존 Nginx 중단 (현재 80/443 점유 중)
   - `docker stop nginx`

2) Prod 풀 스택 기동(마이그 자동)
   - `docker compose -p coe-prod-full -f docker-compose.prod.full.yml up -d`

3) Dev 풀 스택 기동(마이그 자동)
   - `docker compose -p coe-dev-full -f docker-compose.dev.full.yml up -d`

4) Edge(80/443) 기동 + 인증서 발급
   - `docker compose -p coe-edge -f docker-compose.edge.yml up -d`
   - 발급 로그 확인: `docker logs certbot-edge -n 200`

5) 헬스 체크
   - Prod: `curl -I https://greatcoe.cafe24.com`
   - Dev: `curl -I https://dev.greatcoe.cafe24.com`

롤백(필요 시)
- Edge 중지: `docker compose -p coe-edge -f docker-compose.edge.yml down`
- 기존 nginx 재기동: `docker start nginx`

운영 팁
- 마이그 실패 시: `docker compose -p coe-*-full exec <svc> alembic upgrade head`
- 인증서 자동 갱신: `certbot-renew-edge`가 주기 실행, Nginx는 cert 변경 시 자동 reload
- 완전 격리: 각 스택은 고유 네트워크/볼륨을 사용 (`*-prod`, `*-dev` 접미사 리소스)
