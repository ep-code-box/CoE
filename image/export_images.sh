#!/usr/bin/env bash

# Offline export helper for required container images.
# Run on an external network host with podman installed.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}"
TIMESTAMP="$(date +"%Y%m%d%H%M%S")"

declare -A PROFILE_IMAGES=(
  [ap]="mariadb:latest redis:7-alpine chromadb/chroma:latest"
  [pt]="nginx:1.28-alpine owasp/modsecurity-crs:nginx"
  [monitoring]="grafana/grafana:10.4.1 grafana/loki:2.9.4 grafana/promtail:2.9.4"
)

usage() {
  cat <<'EOF'
Usage: ./export_images.sh [profile ...]

Profiles:
  ap           Export database images (MariaDB, Redis, Chroma)
  pt           Export Nginx edge images (standard + ModSecurity)
  monitoring   Export Grafana/Loki/Promtail images

Without arguments all profiles are exported.
EOF
}

collect_profiles() {
  local requested=("$@")
  if [ "${#requested[@]}" -eq 0 ]; then
    echo "ap pt"
    return
  fi

  local valid=()
  for profile in "${requested[@]}"; do
    if [[ -z "${PROFILE_IMAGES[$profile]:-}" ]]; then
      echo "Unknown profile: ${profile}" >&2
      usage
      exit 1
    fi
    valid+=("${profile}")
  done
  printf "%s " "${valid[@]}"
}

profiles=($(collect_profiles "$@"))

mkdir -p "${OUTPUT_DIR}"

for profile in "${profiles[@]}"; do
  images=${PROFILE_IMAGES[$profile]}
  for image in ${images}; do
    echo "==> Pulling ${image} (profile: ${profile})"
    podman pull "${image}"

    sanitized_name="$(echo "${image}" | tr '/:' '__')"
    tar_path="${OUTPUT_DIR}/${TIMESTAMP}_${profile}_${sanitized_name}.tar"

    echo "==> Saving ${image} to ${tar_path}"
    podman save -o "${tar_path}" "${image}"
  done
done

echo "✅ Export complete. TAR files are in ${OUTPUT_DIR}"
