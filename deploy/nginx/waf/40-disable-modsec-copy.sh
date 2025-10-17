#!/bin/sh
set -e
TARGET_SCRIPT="/docker-entrypoint.d/90-copy-modsecurity-config.sh"
if [ -f "$TARGET_SCRIPT" ]; then
    rm -f "$TARGET_SCRIPT"
fi
