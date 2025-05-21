FROM bitnami/nginx:latest

USER root

WORKDIR ./nginx/

RUN chmod -R g+rwX ./nginx/

# links the nginx users to wordpress
RUN usermod -u 1001 www-data && \
    groupmod -g 1001 www-data && \
    chown -R www-data:www-data /var/www/html

# Configure logs directory
RUN mkdir -p /tmp/nginx-logs && \
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    chown -R 1001:1001 /tmp/nginx-logs && \
    chmod -R 777 /tmp/nginx-logs

# Update nginx config
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/nginx.conf && \
    sed -i -r "s#(\s+worker_connections\s+)[0-9]+;#\1512;#" /opt/bitnami/nginx/conf/nginx.conf

# Copy config files
COPY ./nginx/default.conf /opt/bitnami/nginx/conf/nginx.conf
COPY ./nginx/my_stream_server_block.conf /opt/bitnami/nginx/conf/server_blocks/
COPY ./nginx/wordpress-fpm.conf /opt/bitnami/nginx/conf/server_blocks/
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/server_blocks/*.conf

# Configure WordPress directory
RUN chown -R 1001:1001 /var/www/html && \
    chmod -R 777 /var/www/html && \
    find /var/www/html -type d -exec chmod 775 {} \; && \
    find /var/www/html -type f -exec chmod 777 {} \;

# https://docs.bitnami.com/google/apps/wordpress-pro/administration/understand-file-permissions/
# gives the correct permissions to each directory
RUN     chown -R 1001:1001 /var/www/html/wp-content && \
        find /var/www/html/wp-content -type d -exec chmod 777 {} \; && \
        find /var/www/html/wp-content -type f -exec chmod 777 {} \; && \
        chmod 777 /var/www/html/wp-content && \

        chown -R 1001:1001 /var/www/html/wp-content/themes && \
        find /var/www/html/wp-content/themes -type d -exec chmod 777 {} \; && \
        find /var/www/html/wp-content/themes -type f -exec chmod 777 {} \; && \
        chmod 777 /var/www/html/wp-content/themes && \

        chown -R 1001:1001 /var/www/html/wp-content/cache && \
        find /var/www/html/wp-content/cache  -type d -exec chmod 775 {} \; && \
        find /var/www/html/wp-content/cache  -type f -exec chmod 664 {} \; && \
        chmod 777 /var/www/html/wp-content/cache && \
        mkdir -p /var/www/html/wp-content/uploads && \

        chown -R 1001:1001 /var/www/html/wp-content/uploads && \
        find /var/www/html/wp-content/uploads  -type d -exec chmod 777 {} \; && \
        find /var/www/html/wp-content/uploads -type f -exec chmod 777 {} \; && \
        chmod 777 /var/www/html/wp-content/uploads

EXPOSE 80 443

# Create proper entrypoint
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'chown -R 1001:1001 /var/www/html' >> /entrypoint.sh && \
    echo 'find /var/www/html -type d -exec chmod 777 {} \;' >> /entrypoint.sh && \
    echo 'find /var/www/html -type f -exec chmod 777 {} \;' >> /entrypoint.sh && \
    echo 'exec /opt/bitnami/scripts/nginx/entrypoint.sh "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh


USER 1001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]