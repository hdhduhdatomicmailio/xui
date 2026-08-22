FROM alpine:3.21

RUN apk add --no-cache \
    curl \
    bash \
    ca-certificates \
    socat \
    tzdata \
    sqlite \
    nginx \
    gettext \
    libgcc \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime \
    && mkdir -p /etc/x-ui /var/log/x-ui /usr/local/x-ui /var/log/nginx /var/run

ARG VERSION=2.9.4
RUN curl -Ls https://github.com/MHSanaei/3x-ui/releases/download/v${VERSION}/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz \
    && tar -xzf /tmp/x-ui.tar.gz -C /tmp/ \
    && mv /tmp/x-ui/x-ui /usr/local/x-ui/x-ui \
    && rm -rf /tmp/x-ui.tar.gz /tmp/x-ui \
    && chmod +x /usr/local/x-ui/x-ui

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
