#!/bin/sh
set -e
TARGET="/etc/modsecurity.d/owasp-crs/crs-setup.conf"
if [ -f "$TARGET" ]; then
    exit 0
fi
mkdir -p /etc/modsecurity.d/owasp-crs
for candidate in \
    /usr/local/owasp-crs \
    /opt/owasp-crs \
    /usr/share/modsecurity-crs \
    /etc/modsecurity.d/owasp-crs.dist
do
    if [ -d "$candidate" ]; then
        if [ -f "$candidate/crs-setup.conf" ] || [ -f "$candidate/crs-setup.conf.example" ]; then
            cp -R "$candidate"/. /etc/modsecurity.d/owasp-crs/
            if [ ! -f "$TARGET" ] && [ -f "/etc/modsecurity.d/owasp-crs/crs-setup.conf.example" ]; then
                cp "/etc/modsecurity.d/owasp-crs/crs-setup.conf.example" "$TARGET"
            fi
            exit 0
        fi
    fi
done
# Fallback: try to locate crs-setup.conf anywhere
FOUND=$(find / -maxdepth 6 -type f -name "crs-setup.conf" 2>/dev/null | head -n 1)
if [ -n "$FOUND" ]; then
    SRC_DIR=$(dirname "$FOUND")
    cp -R "$SRC_DIR"/. /etc/modsecurity.d/owasp-crs/
fi
if [ ! -f "$TARGET" ] && [ -f "/etc/modsecurity.d/owasp-crs/crs-setup.conf.example" ]; then
    cp "/etc/modsecurity.d/owasp-crs/crs-setup.conf.example" "$TARGET"
fi
exit 0
