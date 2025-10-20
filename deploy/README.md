# Deploy Assets

이 디렉터리는 내부망 서버에서 `podman compose`로 기동할 수 있는 최소 구성 파일과 Nginx 설정을 제공합니다.

## 구성 파일
- `coe-ap-compose.yml` : AP 서버에서 실행할 데이터베이스(Chroma, MariaDB, Redis) 묶음
- `coe-pt-compose.yml` : PT 서버에서 실행할 WAF 포함 Nginx 프록시
- `.env.ap.sample` / `.env.pt.sample` : 서버별 기본값 예시. 실제 배포 시 `.env.ap`, `.env.pt` 등을 복사해 수정하세요.
- `nginx/` : 엣지 프록시용 Nginx 설정(템플릿, WAF 스크립트, 로컬 테스트용 conf 포함)
- `restart_backend_rag.sh` : AP 서버에서 CoE-Backend와 CoE-RagPipeline을 백그라운드로 재기동하는 스크립트 (기존 프로세스 종료 → git 업데이트 → `run.sh` 백그라운드 실행, 로그/ PID는 `logs/background/`에 저장)

## 사전 준비
1. `image/` 디렉터리의 `export_images.sh`로 필요한 이미지를 TAR 로 만들고 내부망에 들여옵니다.
2. `image/import_images.sh`로 해당 서버에 이미지를 등록합니다.
3. Podman 4.x 이상과 `podman compose`가 설치되어 있어야 합니다.

## AP 서버 (데이터베이스 스택)
```bash
cd /path/to/CoE/deploy
cp .env.ap.sample .env.ap           # 필요 값 수정
podman compose -f coe-ap-compose.yml --env-file .env.ap up -d
```
`MARIADB_DATA_ROOT`, `CHROMA_DATA_ROOT`, `REDIS_DATA_ROOT` 경로는 서버 실 경로에 맞게 조정하세요.  
백엔드/RAG 애플리케이션은 host 환경(./venv)에서 직접 실행됩니다.

## PT 서버 (Nginx 프록시)
```bash
cd /path/to/CoE/deploy
cp .env.pt.sample .env.pt           # 인증서/로그 경로 등 수정
podman compose -f coe-pt-compose.yml --env-file .env.pt up -d
```
`NGINX_CONF_ROOT` 아래에 이 디렉터리의 `nginx/` 내용을 복사한 뒤 볼륨 경로를 맞춰 주세요.  
TLS 인증서는 `CERTBOT_ETC`, `CERTBOT_WWW` 경로로 마운트됩니다. 필요 없다면 해당 볼륨을 제거할 수 있습니다.

## 관리 명령 요약
- 상태 확인: `podman compose -f <file> ps`
- 로그 보기: `podman compose -f <file> logs -f`
- 중지/삭제: `podman compose -f <file> down`

## AP 서버 운영 시 참고 사항
- `.env.ap`에서 포트 매핑(예: 6667/6666/6669)과 데이터 경로를 실제 서버 환경과 맞춰야 합니다.
- 오프라인 환경이면 `CoE-Backend/vendor/wheels`와 `CoE-RagPipeline/vendor/wheels`에 필요한 휠을 준비한 뒤 `restart_backend_rag.sh`로 배포 서비스를 재기동합니다.
- `restart_backend_rag.sh` 실행 후 `tail -f logs/background/backend.log` 및 `rag.log`로 기동 상태를 확인합니다.
- DB 스키마는 `schema.sql`을 선적용하거나 각 서비스의 `./run.sh`가 실행 시 Alembic/SQLAlchemy를 통해 자동 생성하도록 구성돼 있습니다.

필요에 따라 볼륨이나 포트 매핑을 추가/수정한 뒤, 동일한 명령으로 재기동하면 됩니다.
