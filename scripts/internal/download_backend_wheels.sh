#!/usr/bin/env bash
set -euo pipefail

cd /workspace/CoE-Backend

mkdir -p vendor/wheels

python -m pip install --upgrade pip
python -m pip download --dest vendor/wheels --requirement requirements.in
python -m pip download --dest vendor/wheels pip setuptools wheel uv caio==0.9.24

# Ensure we have a prebuilt wheel for caio (compiling once in the online environment)
if ! ls vendor/wheels/caio-*-cp*.whl >/dev/null 2>&1; then
  python -m pip wheel --no-deps --wheel-dir vendor/wheels caio==0.9.24
fi
find vendor/wheels -maxdepth 1 -name 'caio-*.tar.gz' -delete
