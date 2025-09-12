# 운영 배포 체크리스트 (Prod)

## 사전 준비
- 브랜치/버전: `main` 기준. 변경 사항/마이그레이션 검토 완료.
- 환경파일: `CoE-Backend/.env.prod`, `CoE-RagPipeline/.env.prod` 최신/정상값 확인(비밀키 노출 금지).
- 자원/볼륨: MariaDB/Chroma/Redis 볼륨 용량 확인. 로그 경로 권한 확인.
- 백업(필요 시): DB/중요 볼륨 스냅샷.

## 배포 절차
1) 코드 동기화
```
cd /home/greatjlim/projects/CoE-prod
git fetch && git checkout main && git pull --ff-only
```

2) 빌드 + 기동 (권장 스크립트)
```
./scripts/run_prd.sh
```
또는 수동으로:
```
docker compose -f docker-compose.prod.yml -p coe-prod build backend ragpipeline
docker compose -f docker-compose.prod.yml -p coe-prod up -d backend ragpipeline
```

3) 마이그레이션 적용
- 기본: prod 프로파일은 `RUN_MIGRATIONS=true`로 자동 적용.
- 필요 시 수동 재적용:
```
docker compose -f docker-compose.prod.yml -p coe-prod exec backend alembic upgrade head
docker compose -f docker-compose.prod.yml -p coe-prod exec ragpipeline alembic upgrade head
```

4) 엣지(Nginx) 반영 (엣지 설정 변경 시에만)
```
docker compose -f docker-compose.edge.yml -p coe exec nginx-edge nginx -s reload
```

## 헬스 체크 / 스모크 테스트
- 백엔드 헬스: `curl -i http://greatcoe.cafe24.com/health` (루트 `/`의 404는 정상)
- RAG 헬스: `curl -i http://greatcoe.cafe24.com/rag/health` (HEAD는 405, GET은 200)
- 추가 API 스모크: `docs/curl-checks.md` 참조 (Flows 등록/실행, Embeddings, Chat 등)

## 모니터링/로그
- 컨테이너 로그(실시간):
```
docker compose -f docker-compose.prod.yml -p coe-prod logs -f backend ragpipeline
```
- 엣지 접근/에러 로그: `/home/greatjlim/projects/logs/nginx/`
- 서비스 로그: 
  - Backend: `/home/greatjlim/projects/logs/coe-backend/prod/`
  - RAG: `/home/greatjlim/projects/logs/coe-ragpipeline/prod/`

## 롤백 가이드
- 애플리케이션 코드 롤백:
```
cd /home/greatjlim/projects/CoE-prod
git checkout <직전_안정_커밋>
./scripts/run_prd.sh
```
- 긴급 서비스 재시작: `docker compose -f docker-compose.prod.yml -p coe-prod restart backend ragpipeline`
- 마이그레이션 영향 최소화: 롤백 중에는 일시적으로 `RUN_MIGRATIONS=false`로 기동 고려.
- DB 롤백이 필요한 경우 사전 백업/스냅샷 활용(운영 표준 절차에 따름).

## 주의사항 요약
- 배포 순서: Backend → RAG (스키마 선행) 
- 프로파일 혼동 금지: `prod`와 `dev/edge` 분리
- 보안: 비밀키는 `.env.*`에만, 리포 커밋 금지
- 대용량 요청/부하: 최초 분석 작업은 워커/타임아웃/동시성 주의
