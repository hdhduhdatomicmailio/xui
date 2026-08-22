FROM ghcr.io/mhsanaei/3x-ui:v2.9.4

RUN apt-get update && apt-get install -y nginx gettext-base && rm -rf /var/lib/apt/lists/*

COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
