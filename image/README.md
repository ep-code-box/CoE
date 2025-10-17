# Offline Image Logistics

이 디렉터리는 내부망 배포 전에 준비해야 하는 컨테이너 이미지를 모아 두기 위한 자리입니다.  
아래 목록의 이미지를 외부망에서 내려받아 TAR 파일로 저장한 뒤 이 폴더에 복사하세요.

## 필요한 이미지
- `mariadb:latest`
- `redis:7-alpine`
- `chromadb/chroma:latest`
- `nginx:1.28-alpine` _(WAF 미사용 기본 프록시가 필요할 때)_
- `owasp/modsecurity-crs:nginx` _(엣지 WAF 프록시가 필요할 때)_
- `grafana/grafana:10.4.1` _(모니터링을 사용하는 경우)_
- `grafana/loki:2.9.4` _(모니터링을 사용하는 경우)_
- `grafana/promtail:2.9.4` _(모니터링을 사용하는 경우)_

## 외부망에서 이미지 저장
```bash
chmod +x export_images.sh
# AP 서버(DB)용만 추출하려면
./export_images.sh ap
# PT 서버(Nginx)까지 포함하려면
./export_images.sh ap pt
# 모니터링까지 포함하려면
./export_images.sh ap pt monitoring
```
`export_images.sh`는 지정한 프로파일의 이미지를 `podman pull` 한 뒤  
`YYYYMMDDHHMMSS_<profile>_<image>.tar` 형태로 저장합니다. 인자를 생략하면 기본적으로 `ap pt` 두 프로파일이 모두 export 됩니다.

## 내부망에서 이미지 등록
외부망에서 받은 TAR 파일을 이 디렉터리에 복사한 뒤 다음 스크립트를 실행하세요.
```bash
chmod +x import_images.sh
./import_images.sh
```
각 TAR 파일이 `podman load` 로 등록된 후 바로 사용할 수 있습니다.  
특정 서버에서 필요한 이미지 프로파일만 로드하려면 `./import_images.sh ap` 또는 `./import_images.sh pt` 식으로 호출하세요.

> **참고**  
> Nginx를 패키지 설치로 운영할 계획이라면 `nginx:1.28-alpine`,  
> `owasp/modsecurity-crs:nginx` 이미지는 생략해도 됩니다.
