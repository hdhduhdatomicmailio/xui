#!/bin/bash
set -e

export PORT=${PORT:-8080}
export XUI_PORT=2053
DB="/etc/x-ui/x-ui.db"

envsubst '${PORT} ${XUI_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

/usr/local/x-ui/x-ui > /var/log/x-ui/x-ui.log 2>&1 &
sleep 5

# یوزر 2053 / پسورد 2053
/usr/local/x-ui/x-ui setting -username 2053 -password 2053 > /dev/null 2>&1 || true
/usr/local/x-ui/x-ui setting -port $XUI_PORT > /dev/null 2>&1 || true

# فیکس اتوماتیک لینک ساب
DOMAIN=$(echo $RAILWAY_PUBLIC_DOMAIN | sed 's|https://||' | sed 's|http://||')
if [ -z "$DOMAIN" ]; then
  DOMAIN=$(echo $RAILWAY_STATIC_URL | sed 's|https://||')
fi

if [ ! -z "$DOMAIN" ]; then
  echo "Fixing sub for domain: $DOMAIN"
  sqlite3 $DB "UPDATE settings SET value='$DOMAIN' WHERE key='subDomain';" 2>/dev/null || true
  sqlite3 $DB "UPDATE settings SET value='443' WHERE key='subPort';" 2>/dev/null || true
  sqlite3 $DB "UPDATE settings SET value='' WHERE key='subPath';" 2>/dev/null || true
fi

pkill x-ui || true
sleep 2
/usr/local/x-ui/x-ui > /var/log/x-ui/x-ui.log 2>&1 &

echo "=== READY v2.9.4 === Login: 2053 / 2053 | Domain: $DOMAIN"
nginx -g "daemon off;"
