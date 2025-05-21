FROM bitnami/nginx:latest

USER root

RUN mkdir -p /tmp/nginx-logs && \
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    mkdir -p /opt/bitnami/nginx/conf/server_blocks && \
    mkdir -p /etc/nginx/certs && \
    mkdir -p /tmp/nginx-logs && \
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log /tmp/nginx-logs/nginx.pid && \
    chown -R 1001:1001 /tmp/nginx-logs && \
    chmod -R 0777 /tmp/nginx-logs

RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/nginx.conf

COPY ./nginx/default.conf /opt/bitnami/nginx/conf/nginx.conf
COPY ./nginx/my_stream_server_block.conf /opt/bitnami/nginx/conf/server_blocks/
COPY ./nginx/wordpress-fpm.conf /opt/bitnami/nginx/conf/server_blocks/

RUN if [ -f /opt/bitnami/nginx/conf/server_blocks/my_stream_server_block.conf ]; then \
        sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/server_blocks/my_stream_server_block.conf; \
    fi && \
    if [ -f /opt/bitnami/nginx/conf/server_blocks/wordpress-fpm.conf ]; then \
        sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/server_blocks/wordpress-fpm.conf; \
    fi

RUN sed -i -r "s#(\s+worker_connections\s+)[0-9]+;#\1512;#" /opt/bitnami/nginx/conf/nginx.conf

RUN chown -R 1001:1001 /opt/bitnami/nginx/conf

RUN mkdir -p /var/www/html && \
    mkdir -p /var/www/html/wp-content && \
    chown -R 1001:1001 777 /var/www/html && \
    chmod -R 0777 /var/www/html && \
    chmod -R 0777 /var/www/html/wp-content

COPY ./nginx/wordpress-fpm.conf /opt/bitnami/nginx/conf/server_blocks/

RUN echo '#!/bin/sh\n\
chown -R 1001:1001 /var/www/html\n\
find /var/www/html -type d -exec chmod 777 {} \;\n\
find /var/www/html -type f -exec chmod 777 {} \;\n\
exec "$@"' > ./docker-entrypoint.sh && \
    chmod +x ./docker-entrypoint.sh

EXPOSE 8080 443 22 

COPY ./nginx/docker-entrypoint.sh /opt/bitnami/scripts/docker-entrypoint.sh
RUN chmod +x /opt/bitnami/scripts/docker-entrypoint.sh

USER 1001

ENTRYPOINT ["/opt/bitnami/scripts/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]