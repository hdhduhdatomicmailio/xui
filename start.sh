#!/bin/bash
set -e

export PORT=${PORT:-8080}
cd /usr/local/x-ui
mkdir -p /etc/x-ui /var/log

echo "=== v2.9.4 Auto Setup ==="
echo "Panel: 2053 | User: admin | Pass: 2053"

# تنظیمات پنل بدون دخالت دست
./x-ui setting -port 2053 || true
./x-ui setting -webBasePath /managepanel/ || true
./x-ui setting -username admin || true
./x-ui setting -password 2053 || true
./x-ui setting -subPort 2053 || true
./x-ui setting -subPath /sub/ || true

# ساخت nginx.conf با پورت Railway
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "Starting x-ui on 2053..."
./x-ui > /var/log/x-ui.log 2>&1 &
sleep 4

# فعالسازی اتوماتیک ساب برای همه اینباندهای قبلی
if [ -f /etc/x-ui/x-ui.db ]; then
  echo "Enabling sub for all inbounds..."
  sqlite3 /etc/x-ui/x-ui.db "UPDATE inbounds SET sub=1;" 2>/dev/null || true
  sqlite3 /etc/x-ui/x-ui.db "UPDATE settings SET value='true' WHERE key='subEnable';" 2>/dev/null || true
fi

echo "Starting nginx on $PORT -> 2053"
nginx -t
exec nginx -g "daemon off;"
