FROM bitnami/nginx:latest

USER root

# install sudo
RUN install_packages sudo && \
    echo 'root-lite (1001) ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -aG sudo root

# Configure logs directory
RUN sudo mkdir -p /tmp/nginx-logs && \
    sudo touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    sudo chown -R 1001:1001 /tmp/nginx-logs && \
    sudo chmod -R 777 /tmp/nginx-logs

# Update nginx config
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/nginx.conf && \
    sed -i -r "s#(\s+worker_connections\s+)[0-9]+;#\1512;#" /opt/bitnami/nginx/conf/nginx.conf

# Copy config files
COPY ./nginx/default.conf /opt/bitnami/nginx/conf/nginx.conf
COPY ./nginx/my_stream_server_block.conf /opt/bitnami/nginx/conf/server_blocks/
COPY ./nginx/wordpress-fpm.conf /opt/bitnami/nginx/conf/server_blocks/
RUN sed -i 's|/var/log/nginx|/tmp/nginx-logs|g' /opt/bitnami/nginx/conf/server_blocks/*.conf

# create & Configure WordPress directory
RUN sudo mkdir -p /var/www/html && \
    sudo usermod -u 1001 www-data && \
    sudo groupmod -g 1001 www-data && \
    sudo chown -R www-data:www-data /var/www/html && \
    sudo chown -R 1001:1001 /var/www/html && \
    sudo chmod -R 777 /var/www/html && \
    sudo find /var/www/html -type d -exec chmod 777 {} \; && \
    sudo find /var/www/html -type f -exec chmod 777 {} \;

# https://docs.bitnami.com/google/apps/wordpress-pro/administration/understand-file-permissions/
# gives the correct permissions to each directory
RUN     sudo mkdir -p /var/www/html/wp-content && \
        sudo chown -R 1001:1001 /var/www/html/wp-content && \
        sudo find /var/www/html/wp-content -type d -exec chmod 777 {} \; && \
        sudo find /var/www/html/wp-content -type f -exec chmod 777 {} \; && \
        sudo chmod 777 /var/www/html/wp-content && \
        #
        sudo mkdir -p /var/www/html/wp-content/themes && \
        sudo chown -R 1001:1001 /var/www/html/wp-content/themes && \
        sudo find /var/www/html/wp-content/themes -type d -exec chmod 777 {} \; && \
        sudo find /var/www/html/wp-content/themes -type f -exec chmod 777 {} \; && \
        sudo chmod 777 /var/www/html/wp-content/themes && \
        #
        sudo mkdir -p /var/www/html/wp-content/cache && \
        sudo chown -R 1001:1001 /var/www/html/wp-content/cache && \
        sudo find /var/www/html/wp-content/cache  -type d -exec chmod 775 {} \; && \
        sudo find /var/www/html/wp-content/cache  -type f -exec chmod 664 {} \; && \
        sudo chmod 777 /var/www/html/wp-content/cache && \
        #
        sudo mkdir -p /var/www/html/wp-content/uploads && \
        sudo chown -R 1001:1001 /var/www/html/wp-content/uploads && \
        sudo find /var/www/html/wp-content/uploads  -type d -exec chmod 777 {} \; && \
        sudo find /var/www/html/wp-content/uploads -type f -exec chmod 777 {} \; && \
        sudo chmod 777 /var/www/html/wp-content/uploads && \
        #
        sudo chown -R www-data:www-data /var/www/html/wp-content && \
        sudo chown -R www-data:www-data /var/www/html/wp-content/themes && \
        sudo chown -R www-data:www-data /var/www/html/wp-content/cache && \
        sudo chown -R www-data:www-data /var/www/html/wp-content/uploads 

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