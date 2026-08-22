#!/bin/sh
set -e

/usr/local/x-ui/x-ui setting -username 2053 -password 2053 -port 8080 -webBasePath /

# تغییر نام 3x-ui به xui
find /usr/local/x-ui -type f \( -name "*.js" -o -name "*.html" -o -name "*.json" \) -exec sed -i 's/3x-ui/xui/gI; s/3X-UI/xui/gI; s/3X-ui/xui/gI' {} + 2>/dev/null || true

envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

nginx
exec /usr/local/x-ui/x-ui
