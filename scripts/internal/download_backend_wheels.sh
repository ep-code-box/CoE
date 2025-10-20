#!/usr/bin/env bash
set -euo pipefail

cd /workspace/CoE-Backend

mkdir -p vendor/wheels

python -m pip install --upgrade pip
python -m pip download --dest vendor/wheels --requirement requirements.in
python -m pip download --dest vendor/wheels uv
