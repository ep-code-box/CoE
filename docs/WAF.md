WAF (ModSecurity + OWASP CRS) 적용 가이드

개요
- 엣지 프록시(`nginx-edge`)에 ModSecurity v3와 OWASP Core Rule Set(CRS)을 연동했습니다.
- 기본 모드는 DetectionOnly(탐지만)로 설정되어 서비스 영향 없이 룰 튜닝을 먼저 수행할 수 있습니다.

변경 사항 요약
- 이미지: `nginx-edge` 가 `owasp/modsecurity-crs:nginx` 이미지를 사용합니다.
- 설정: `nginx/nginx.edge.conf` 의 `http {}` 블록에 `modsecurity on;` 및 `modsecurity_rules_file /etc/modsecurity/modsecurity.conf;` 추가.
- 규칙: 커스텀 구성은 `nginx/waf/modsecurity.conf` 에 정의하며 CRS를 Include합니다.
- 로그: 컨테이너 `/var/log/modsecurity` 가 호스트 `/home/greatjlim/projects/logs/modsecurity` 로 마운트됩니다.

실행/반영
- edge 프로파일 실행 또는 재시작:
  - `docker compose -f docker-compose.full.yml --profile edge up -d`
  - 설정 변경 반영: `docker compose -f docker-compose.full.yml --profile edge restart nginx-edge`

운영 권장 플로우
1) 모니터링(탐지만): 기본 `DetectionOnly` 로 운영하며 `audit.log` 를 관찰합니다.
   - `docker compose -f docker-compose.full.yml --profile edge logs -f nginx-edge`
   - 호스트 로그: `/home/greatjlim/projects/logs/modsecurity/audit.log`
2) 튜닝: 정상 트래픽에서 반복적으로 탐지되는 룰을 화이트리스트하거나 스코프를 조정합니다.
   - 개별 위치/경로에서만 완화하려면 Nginx `location` 별로 ModSecurity `ctl`/`SecRuleRemoveById` 적용을 고려합니다.
3) 차단 전환: 충분히 튜닝 후 `nginx/waf/modsecurity.conf` 의 `SecRuleEngine On` 으로 변경 → 재시작.

구성 파일 상세
- `nginx/waf/modsecurity.conf`
  - 기본 한도(본문 크기 등), 감사 로깅(JSON), 최소 커스텀 룰 포함.
  - CRS 포함:
    - `Include /usr/local/owasp-modsecurity-crs/crs-setup.conf`
    - `Include /usr/local/owasp-modsecurity-crs/rules/*.conf`
- `nginx/nginx.edge.conf`
  - `http` 블록에 WAF 전역 활성화. 서버/위치 단위로 세분화하려면 해당 블록 안에 `modsecurity on;` 을 배치하고 필요 시 `modsecurity_rules`/`_file` 지정.

추가 팁
- 405/404 등 정상 동작 판정은 기존 운영 문서(`docs/DEPLOY.md`, 운영 주의사항) 기준을 유지하세요.
- 대용량 업로드/스트리밍이 있다면 `SecRequestBodyLimit`, `tx.max_file_size` 를 서비스 요구사항에 맞게 상향 조정하세요.
- 초기에는 `SecDebugLogLevel 0` 으로 두고, 문제 분석 시 일시적으로 3~5로 높여도 됩니다(로그 용량 주의).

로컬/개발 환경 적용(선택)
- 기본 로컬용 nginx는 ModSecurity 모듈이 없는 `nginx:latest` 를 사용합니다.
- 개발/테스트에서 WAF를 확인하려면 별도 compose 오버라이드로 엣지와 동일 이미지를 사용하고, `nginx.local.conf` 에 `modsecurity` 지시어를 추가하십시오.

