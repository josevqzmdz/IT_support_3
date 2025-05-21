FROM bitnami/nginx:latest

USER root

# Create necessary directories and set permissions
RUN mkdir -p /tmp/nginx-logs && \
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    mkdir -p /opt/bitnami/nginx/conf/server_blocks && \
    mkdir -p /etc/nginx/certs && \
    chown -R 1001:1001 /tmp/nginx-logs && \
    chmod -R 775 /tmp/nginx-logs

# Update nginx config to use our log location
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/nginx.conf

# Copy configuration files
COPY ./nginx/default.conf /opt/bitnami/nginx/conf/nginx.conf
COPY ./nginx/my_stream_server_block.conf /opt/bitnami/nginx/conf/server_blocks/
COPY ./nginx/wordpress-fpm.conf /opt/bitnami/nginx/conf/server_blocks/

# Update paths in config files
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/server_blocks/*.conf && \
    sed -i -r "s#(\s+worker_connections\s+)[0-9]+;#\1512;#" /opt/bitnami/nginx/conf/nginx.conf

# Set permissions for WordPress directory
RUN mkdir -p /var/www/html && \
    mkdir -p /var/www/html/wp-content && \
    chown -R 1001:1001 /var/www/html && \
    chmod -R 775 /var/www/html && \
    find /var/www/html -type d -exec chmod 2775 {} \; && \
    find /var/www/html -type f -exec chmod 664 {} \;

# Create and set permissions for uploads directory (important for WordPress)
RUN mkdir -p /var/www/html/wp-content/uploads && \
    chown -R 1001:1001 /var/www/html/wp-content/uploads && \
    chmod -R 775 /var/www/html/wp-content/uploads

# Create custom entrypoint
RUN echo '#!/bin/bash\n\
# Fix permissions\n\
chown -R 1001:1001 /var/www/html\n\
find /var/www/html -type d -exec chmod 775 {} \;\n\
find /var/www/html -type f -exec chmod 664 {} \;\n\
# Special permissions for wp-content\n\
chmod -R 775 /var/www/html/wp-content\n\
chown -R 1001:1001 /var/www/html/wp-content\n\
# Execute original entrypoint\n\
exec /opt/bitnami/scripts/nginx/entrypoint.sh "$@"' > ./nginx/docker-entrypoint.sh && \
    chmod +x ./nginx/docker-entrypoint.sh

EXPOSE 8080 443 80

USER 1001

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]