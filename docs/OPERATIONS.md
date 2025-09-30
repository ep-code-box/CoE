# 운영 가이드 (DB 마이그레이션 중심)

본 문서는 CoE 시스템(Backend, RagPipeline) 운영 시 데이터베이스 마이그레이션 적용 정책과 실행 방법을 정리합니다.

문서 맵
- 배포/기동: `docs/DEPLOY.md`
- Swagger/UI 경로 및 API 둘러보기: `docs/SWAGGER_GUIDE.md`
- cURL 예시 모음: `docs/curl-checks.md`

## 기본 정책
- 기본값은 “마이그레이션 스킵”입니다. 개발·로컬 환경 및 일반 기동 시 Alembic을 자동 실행하지 않습니다.
- 운영/배포 시점에만 명시적으로 마이그레이션을 실행합니다.
- 배포 자동화(파이프라인)에 “마이그레이션 단계”를 별도 스텝으로 추가하는 것을 권장합니다.

## 환경 변수
- `RUN_MIGRATIONS`
  - `false`(기본): Alembic 미실행
  - `true`: 컨테이너 시작 시 `alembic upgrade head` 수행

## PID 기반 개인정보 차단
- **설치 경로**
  - 원본 휠: `docs/pid-1.3.19/pidpy-1.3.19-py3-none-linux_x86_64.whl`
  - 실행 스크립트(`scripts/run_local.sh`, `scripts/run_dev.sh`, `scripts/run_prd.sh`, `CoE-Backend/run.sh`)가 위 파일을 `CoE-Backend/vendor/pidpy/`로 자동 복사한 뒤 설치합니다.
  - Docker 빌드(`CoE-Backend/Dockerfile`)에서도 동일 휠을 설치하므로 별도 다운로드 없이 일관된 버전을 사용합니다.
- **동작 방식**
  - FastAPI 수명주기에서 PID 사전을 선로드하고 종료 시 해제합니다.
  - 모든 POST 바디·채팅 메시지는 PID로 검사되며, 탐지된 문자열은 로그·DB 저장 전에 마스킹(`*`)됩니다.
  - 민감 정보가 포함된 사용자 메시지는 즉시 차단되며 고정 응답을 반환합니다:
    - `"고객 정보 또는 민감한 데이터가 확인되었습니다. 다시 질문 부탁드립니다."`
  - 차단 응답도 기존 세션 로그에는 마스킹된 상태로 기록됩니다.
- **설정값**
  - `ENABLE_PID_DETECTION` (기본 `true`): PID 스캔을 비활성화해야 할 경우만 `false`로 설정
  - `PID_DATA_PATH`: 기본은 설치된 `pidpy`의 리소스 폴더. 커스텀 사전을 쓸 때만 명시
- **운영 체크**
  - `logs/app.log`에 `[PII] session=... masked_types=...` 로그가 나타나면 감지 성공
  - 차단 시 응답 본문이 위 안내 문구인지 확인하고, 로그에는 원문이 남지 않는지 검증

`docker-compose.yml`에는 아래와 같이 파라미터화되어 있습니다.

```
RUN_MIGRATIONS=${RUN_MIGRATIONS:-false}
```

## 사용 시나리오

### 1) 평시 (로컬/개발)
- 별도 설정 없이 `docker compose up -d` → 마이그레이션 스킵

### 2) 운영 배포 시 1회 적용
- 환경 변수로 일시 활성화하여 기동
```
RUN_MIGRATIONS=true docker compose up -d coe-ragpipeline coe-backend
```
- 또는 이미 띄운 뒤 컨테이너 내에서 원샷 실행
```
docker compose exec coe-ragpipeline alembic upgrade head
docker compose exec coe-backend alembic upgrade head
```
- 이후 평상시 재시작은 기본(스킵) 동작으로 안전

### 3) 로컬 스크립트로 테스트 실행
- Backend 로컬 실행 시
```
cd CoE-Backend
RUN_MIGRATIONS=true ./run.sh   # 적용
./run.sh                        # 스킵
```
- RagPipeline는 Docker 기동 기반을 권장

## 상태 확인
- Backend (Nginx 경유): `GET http://localhost/health`
- RAG (선택):
  - Nginx 경유: `GET http://localhost/rag/health`
  - 직접 접근: `GET http://localhost:8001/health`

## 주의 및 베스트프랙티스
- 초기 리비전에서 테이블/인덱스 대량 드롭/생성이 포함된 마이그는 운영 DB에 위험할 수 있습니다.
  - 본 저장소의 `CoE-RagPipeline/dbmig/versions/18c18bf4111f_...py`는 방어 로직이 포함되어 있지만, 운영 적용 전 충분한 백업/리허설 권장.
- 현재 DB 스키마를 기준으로 Alembic을 유지하고 싶다면:
  1) 현 DB를 기준으로 베이스라인 처리: `alembic stamp head`
  2) 이후 변경만 담은 새 마이그 생성: `alembic revision --autogenerate -m "..."`
- 공통 에러와 대응:
  - `Can't DROP INDEX ...` / `Can't DROP FOREIGN KEY ...` → 존재 검사 후 드롭(IF EXISTS)로 방어. 본 마이그 파일에 반영됨.

## 체크리스트 (운영 전)
- [ ] DB 백업 완료
- [ ] 변경사항 검토 및 스테이징 환경 리허설
- [ ] 배포 파이프라인에서 마이그 단계 분리 또는 일시 활성화(`RUN_MIGRATIONS=true`) 적용 계획 수립
- [ ] 롤백 전략 준비(`alembic downgrade` 또는 백업 복구)

## 참고
- Backend, RagPipeline 컨테이너는 `RUN_MIGRATIONS`를 인지하도록 Dockerfile/run.sh에 반영됨.
- docker-compose 로그에서 `Running Alembic migrations...` 또는 `Skipping Alembic migrations` 메시지로 동작 확인 가능.
