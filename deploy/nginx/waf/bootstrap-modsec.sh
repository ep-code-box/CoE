#!/bin/sh
set -e


MODSEC_DIR="/etc/modsecurity.d"
CRS_TARGET="$MODSEC_DIR/owasp-crs/crs-setup.conf"

mkdir -p "$MODSEC_DIR"

# Seed base ModSecurity config (modsecurity.conf, unicode.mapping, etc.) if missing
if [ ! -f "$MODSEC_DIR/modsecurity.conf" ]; then
    for base in \
        /etc/modsecurity.d.dist \
        /usr/share/modsecurity-crs/base-config \
        /usr/local/etc/modsecurity.d
    do
        if [ -d "$base" ]; then
            cp -R "$base"/. "$MODSEC_DIR"/
            break
        fi
    done
fi

# Ensure unicode mapping exists (some images keep it outside the base dir)
if [ ! -f "$MODSEC_DIR/unicode.mapping" ]; then
    for mapping in \
        /etc/modsecurity.d.dist/unicode.mapping \
        /usr/local/owasp-modsecurity-crs/unicode.mapping \
        /usr/local/owasp-crs/unicode.mapping \
        /usr/share/modsecurity-crs/unicode.mapping
    do
        if [ -f "$mapping" ]; then
            cp "$mapping" "$MODSEC_DIR/unicode.mapping"
            break
        fi
    done
fi

mkdir -p "$MODSEC_DIR/owasp-crs"
if [ ! -f "$CRS_TARGET" ]; then
    for candidate in \
        /usr/local/owasp-modsecurity-crs \
        /usr/local/owasp-crs \
        /opt/owasp-crs \
        /usr/share/modsecurity-crs \
        /etc/modsecurity.d/owasp-crs.dist
    do
        if [ -d "$candidate" ]; then
            if [ -f "$candidate/crs-setup.conf" ] || [ -f "$candidate/crs-setup.conf.example" ]; then
                cp -R "$candidate"/. "$MODSEC_DIR/owasp-crs"/
                break
            fi
        fi
    done

    # Fallback: try to locate crs-setup.conf anywhere
    if [ ! -f "$CRS_TARGET" ]; then
        FOUND=$(find / -maxdepth 6 -type f -name "crs-setup.conf" 2>/dev/null | head -n 1)
        if [ -n "$FOUND" ]; then
            SRC_DIR=$(dirname "$FOUND")
            cp -R "$SRC_DIR"/. "$MODSEC_DIR/owasp-crs"/
        fi
    fi

    if [ -f "$MODSEC_DIR/owasp-crs/crs-setup.conf.example" ] && [ ! -f "$CRS_TARGET" ]; then
        cp "$MODSEC_DIR/owasp-crs/crs-setup.conf.example" "$CRS_TARGET"
    fi
fi

# Ensure base setup.conf exists for downstream scripts
if [ ! -f "$MODSEC_DIR/setup.conf" ]; then
    printf '%s\n' "SecRuleEngine DetectionOnly" > "$MODSEC_DIR/setup.conf"
fi

# Install our override config if provided via template
OVERRIDE_TEMPLATE="/etc/nginx/templates/modsecurity.d/modsecurity-override.conf.template"
if [ -f "$OVERRIDE_TEMPLATE" ]; then
    cp "$OVERRIDE_TEMPLATE" "$MODSEC_DIR/modsecurity-override.conf"
fi

exit 0
