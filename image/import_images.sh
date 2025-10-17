#!/usr/bin/env bash

# Import container image tarballs using podman.
# Run on the internal (air-gapped) server.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./import_images.sh [profile ...]

Profiles:
  ap           Load database images (tar files ending with _ap_*)
  pt           Load Nginx edge images (tar files ending with _pt_*)
  monitoring   Load Grafana/Loki/Promtail images (tar files ending with _monitoring_*)

Without arguments all tar files in this directory are imported.
EOF
}

collect_tarballs() {
  local requested=("$@")
  local tarballs=()

  shopt -s nullglob
  if [ "${#requested[@]}" -eq 0 ]; then
    tarballs+=("${SCRIPT_DIR}"/*.tar)
  else
    for profile in "${requested[@]}"; do
      case "$profile" in
        ap|pt|monitoring)
          tarballs+=("${SCRIPT_DIR}"/*_"${profile}"_*.tar)
          ;;
        *)
          echo "Unknown profile: ${profile}" >&2
          usage
          exit 1
          ;;
      esac
    done
  fi
  shopt -u nullglob

  echo "${tarballs[@]}"
}

read -ra TARBALLS <<<"$(collect_tarballs "$@")"

if [ "${#TARBALLS[@]}" -eq 0 ]; then
  echo "No matching *.tar files found in ${SCRIPT_DIR}"
  exit 0
fi

for tar_path in "${TARBALLS[@]}"; do
  echo "==> Loading ${tar_path}"
  podman load -i "${tar_path}"
done

echo "✅ Import complete. Verify with: podman images"
