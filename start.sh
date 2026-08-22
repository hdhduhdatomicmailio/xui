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

# حالت کاملا اتوماتیک: subDomain رو خالی میذاریم تا x-ui خودش از Host هدر بخونه
# اینجوری نیازی به ست کردن RAILWAY_PUBLIC_DOMAIN نیست
sqlite3 $DB "UPDATE settings SET value='' WHERE key='subDomain';" 2>/dev/null || true
sqlite3 $DB "UPDATE settings SET value='443' WHERE key='subPort';" 2>/dev/null || true
sqlite3 $DB "UPDATE settings SET value='' WHERE key='subPath';" 2>/dev/null || true
sqlite3 $DB "UPDATE settings SET value='https://' WHERE key='subURI';" 2>/dev/null || true

pkill x-ui || true
sleep 2
/usr/local/x-ui/x-ui > /var/log/x-ui/x-ui.log 2>&1 &

echo "=== READY v2.9.4 AUTO-SUB === Login: 2053 / 2053"
nginx -g "daemon off;"
