#!/usr/bin/env bash
# Generates runtime/portal-ext.properties and runtime/nginx.conf from .env
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$BASE_DIR/.env" ]; then
  set -a; source "$BASE_DIR/.env"; set +a
fi

mkdir -p "$BASE_DIR/runtime"

# ── portal-ext.properties ─────────────────────────────────────────────────
cat > "$BASE_DIR/runtime/portal-ext.properties" << EOF
jdbc.default.driverClassName=org.postgresql.Driver
jdbc.default.url=jdbc:postgresql://postgresql:5432/${POSTGRES_DB:-lportal}
jdbc.default.username=${POSTGRES_USER:-liferay}
jdbc.default.password=${POSTGRES_PASSWORD}

com.liferay.portal.search.elasticsearch7.configuration.ElasticsearchConfiguration.operationMode=REMOTE
com.liferay.portal.search.elasticsearch7.configuration.ElasticsearchConfiguration.networkHostAddresses=["http://elasticsearch:9200"]

dl.store.impl=com.liferay.portal.store.file.system.AdvancedFileSystemStore

web.server.protocol=${SSL_ENABLED:-false} == "true" && echo "https" || echo "http"
web.server.host=${PORTAL_DOMAIN:-localhost}
web.server.http.port=-1
web.server.https.port=-1

virtual.hosts.valid.hosts=localhost,127.0.0.1,${PORTAL_DOMAIN:-localhost}

company.name=${PORTAL_COMPANY_NAME:-${BRAND_NAME:-Liferay}}
company.default.name=${PORTAL_COMPANY_NAME:-${BRAND_NAME:-Liferay}}
default.guest.friendly.url=/web/exp

auth.token.check.enabled=false
session.timeout=30
company.security.strangers=false
setup.wizard.enabled=false
EOF

# Add SMTP if configured
if [ -n "${SMTP_HOST:-}" ]; then
  cat >> "$BASE_DIR/runtime/portal-ext.properties" << EOF

mail.session.mail=true
mail.session.mail.smtp.host=${SMTP_HOST}
mail.session.mail.smtp.port=${SMTP_PORT:-587}
mail.session.mail.smtp.user=${SMTP_USER}
mail.session.mail.smtp.password=${SMTP_PASSWORD}
mail.session.mail.smtp.auth=true
mail.session.mail.smtp.starttls.enable=${SMTP_TLS:-true}
EOF
fi

echo "Generated: runtime/portal-ext.properties"

# Fix web.server.protocol (bash in heredoc doesn't evaluate conditionals)
if [ "${SSL_ENABLED:-false}" = "true" ]; then
  sed -i 's/web.server.protocol=.*/web.server.protocol=https/' "$BASE_DIR/runtime/portal-ext.properties"
else
  sed -i 's/web.server.protocol=.*/web.server.protocol=http/' "$BASE_DIR/runtime/portal-ext.properties"
fi

# ── nginx.conf ────────────────────────────────────────────────────────────
DOMAIN="${PORTAL_DOMAIN:-localhost}"

if [ "${SSL_ENABLED:-false}" = "true" ]; then
  cat > "$BASE_DIR/runtime/nginx.conf" << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 301 https://${DOMAIN}\$request_uri; }
}
server {
    listen 443 ssl;
    http2 on;
    server_name ${DOMAIN};
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    client_max_body_size 100M;
    location / {
        proxy_pass http://liferay:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300s;
        proxy_buffering off;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff2?)$ {
        proxy_pass http://liferay:8080;
        proxy_set_header Host \$host;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF
else
  cat > "$BASE_DIR/runtime/nginx.conf" << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    client_max_body_size 100M;
    location / {
        proxy_pass http://liferay:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300s;
        proxy_buffering off;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff2?)$ {
        proxy_pass http://liferay:8080;
        proxy_set_header Host \$host;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF
fi

mkdir -p "$BASE_DIR/runtime/certs"
echo "Generated: runtime/nginx.conf"
echo ""
echo "Done. Run: docker compose up -d"
