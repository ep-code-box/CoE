# 모니터링 가이드 (Loki + Promtail + Grafana)

개요
- 단일 모니터링 스택으로 dev/prod/local의 컨테이너 로그를 중앙집중 수집/조회합니다.
- Promtail이 Docker 소켓을 통해 모든 컨테이너 로그를 읽고, Loki에 저장합니다.
- Grafana는 `/grafana/` 서브패스에서 동작하며, Loki 데이터소스가 자동 등록됩니다.

구성 요소
- Loki: 로그 저장소 (`:3100`)
- Promtail: 로그 수집기 (Docker SD)
- Grafana: 대시보드/Explore (`:3000`, Nginx를 통해 `/grafana/`)

파일
- `docker-compose.monitoring.yml`: 모니터링 스택 Compose 정의
- `promtail-config.yml`: Promtail 설정 (Docker 소켓, 라벨링 규칙 포함)
- `grafana/provisioning/datasources/datasource.yml`: Grafana에서 Loki 자동 등록

실행/중지
```
# 모니터링만 실행
docker compose -f docker-compose.monitoring.yml up -d

# 전체/인프라 실행과 함께 (옵션 플래그)
./run_all.sh full --with-monitoring
./run_all.sh local --with-monitoring

# 중지
docker compose -f docker-compose.monitoring.yml down
```

접속 경로
- 로컬: `http://localhost/grafana/`
- 엣지(공용): `http://greatcoe.cafe24.com/grafana/`
- Loki API(옵션): `/loki/` 아래로 프록시됨 (prod 서버에서만 노출)

라벨(필터링)
- Promtail이 다음 라벨을 부여합니다.
  - `env`: coe-dev|coe-prod|coe-edge 프로젝트 → dev/prod/edge, 그 외 → local
  - `service`: Compose 서비스명 (예: `coe-backend-dev`)
  - `compose_project`: Compose 프로젝트명 (예: `coe-dev`)
  - `container`: 컨테이너 이름
- Grafana Explore에서 `env="dev"`, `service="coe-backend-dev"` 등으로 필터링하세요.

보안/운영 팁
- Grafana 기본 계정(admin/admin)을 반드시 변경하세요.
- 외부 노출을 제한하려면 Nginx에 IP 제한 또는 기본 인증을 추가하세요.
- Linux에서 `host.docker.internal`이 동작하지 않으면 Nginx 서비스에
  `extra_hosts: ["host.docker.internal:host-gateway"]`를 추가하세요.

문제 해결
- Grafana에서 데이터소스 오류 시: Grafana 컨테이너 로그 확인 후, 데이터소스 URL이 `http://loki:3100`인지 확인
- 로그가 보이지 않을 때: Promtail 컨테이너 로그 확인(도커 소켓/권한, 경로 마운트 확인)
- /grafana 404: Nginx 컨테이너 재시작 및 설정 반영 확인
