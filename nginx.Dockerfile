FROM bitnami/nginx:latest

USER root

# Configure logs directory
RUN mkdir -p /tmp/nginx-logs && \
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    chown -R 1001:1001 /tmp/nginx-logs && \
    chmod -R 775 /tmp/nginx-logs

# Update nginx config
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/nginx.conf && \
    sed -i -r "s#(\s+worker_connections\s+)[0-9]+;#\1512;#" /opt/bitnami/nginx/conf/nginx.conf

# Copy config files
COPY ./nginx/default.conf /opt/bitnami/nginx/conf/nginx.conf
COPY ./nginx/my_stream_server_block.conf /opt/bitnami/nginx/conf/server_blocks/
COPY ./nginx/wordpress-fpm.conf /opt/bitnami/nginx/conf/server_blocks/
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/server_blocks/*.conf

# Configure WordPress directory
RUN mkdir -p /var/www/html/wp-content/uploads && \
    chown -R 1001:1001 /var/www/html && \
    chmod -R 775 /var/www/html && \
    find /var/www/html -type d -exec chmod 2775 {} \; && \
    find /var/www/html -type f -exec chmod 664 {} \;

# Create proper entrypoint
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'chown -R 1001:1001 /var/www/html' >> /entrypoint.sh && \
    echo 'find /var/www/html -type d -exec chmod 775 {} \;' >> /entrypoint.sh && \
    echo 'find /var/www/html -type f -exec chmod 664 {} \;' >> /entrypoint.sh && \
    echo 'exec /opt/bitnami/scripts/nginx/entrypoint.sh "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 80 443

USER 1001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]