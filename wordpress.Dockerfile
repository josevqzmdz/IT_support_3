FROM bitnami/wordpress-nginx:latest

USER root

#install sudo
RUN install_packages sudo && \
    echo 'bitnami ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -aG sudo bitnami

RUN { \
    echo '[www]'; \
    echo 'listen = 9000'; \
    echo 'listen.allowed_clients = 0.0.0.0'; \
    echo 'pm = dynamic'; \
    echo 'pm.max_children = 20'; \
    echo 'pm.start_servers = 5'; \
    echo 'pm.min_spare_servers = 2'; \
    echo 'pm.max_spare_servers = 8'; \
    echo 'clear_env = no'; \
    echo 'pm.status_path = /status'; \
} > /usr/local/etc/php-fpm.d/zz-custom.conf


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

COPY sudo --chown=www-data:www-data ./other_files/wp1-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN sudo chmod +x /usr/local/bin/wp-entrypoint.sh

# script that checks if memory > 70
COPY sudo --chown=www-data:www-data ./other_files/chemiloco /usr/local/bin/chemiloco
RUN sudo chmod +x /usr/local/bin/chemiloco

#RUN echo 'pm.status_path = /status' >> /usr/local/etc/php-fpm.d/zz-custom.conf

USER www-data

#HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
#    CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["wp-entrypoint.sh"]
CMD ["php-fpm"]