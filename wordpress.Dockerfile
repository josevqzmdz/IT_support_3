FROM bitnami/wordpress-nginx:latest

USER root

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
RUN mkdir -p /var/www/html && \
    usermod -u 1001 www-data && \
    groupmod -g 1001 www-data && \
    chown -R www-data:www-data /var/www/html && \
    chown -R 1001:1001 /var/www/html && \
    chmod -R 777 /var/www/html && \
    find /var/www/html -type d -exec chmod 777 {} \; && \
    find /var/www/html -type f -exec chmod 777 {} \;

# https://docs.bitnami.com/google/apps/wordpress-pro/administration/understand-file-permissions/
# gives the correct permissions to each directory
RUN     mkdir -p /var/www/html/wp-content && \
        chown -R 1001:1001 /var/www/html/wp-content && \
        find /var/www/html/wp-content -type d -exec chmod 777 {} \; && \
        find /var/www/html/wp-content -type f -exec chmod 777 {} \; && \
        chmod 777 /var/www/html/wp-content && \
        #
        mkdir -p /var/www/html/wp-content/themes && \
        chown -R 1001:1001 /var/www/html/wp-content/themes && \
        find /var/www/html/wp-content/themes -type d -exec chmod 777 {} \; && \
        find /var/www/html/wp-content/themes -type f -exec chmod 777 {} \; && \
        chmod 777 /var/www/html/wp-content/themes && \
        #
        mkdir -p /var/www/html/wp-content/cache && \
        chown -R 1001:1001 /var/www/html/wp-content/cache && \
        find /var/www/html/wp-content/cache  -type d -exec chmod 775 {} \; && \
        find /var/www/html/wp-content/cache  -type f -exec chmod 664 {} \; && \
        chmod 777 /var/www/html/wp-content/cache && \
        #
        mkdir -p /var/www/html/wp-content/uploads && \
        chown -R 1001:1001 /var/www/html/wp-content/uploads && \
        find /var/www/html/wp-content/uploads  -type d -exec chmod 777 {} \; && \
        find /var/www/html/wp-content/uploads -type f -exec chmod 777 {} \; && \
        chmod 777 /var/www/html/wp-content/uploads && \
        #
        chown -R www-data:www-data /var/www/html/wp-content && \
        chown -R www-data:www-data /var/www/html/wp-content/themes && \
        chown -R www-data:www-data /var/www/html/wp-content/cache && \
        chown -R www-data:www-data /var/www/html/wp-content/uploads 

COPY  --chown=www-data:www-data ./other_files/wp1-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN  chmod +x /usr/local/bin/wp-entrypoint.sh

# script that checks if memory > 70
COPY  --chown=www-data:www-data ./other_files/chemiloco /usr/local/bin/chemiloco
RUN  chmod +x /usr/local/bin/chemiloco

#RUN echo 'pm.status_path = /status' >> /usr/local/etc/php-fpm.d/zz-custom.conf

USER www-data

#HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
#    CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["wp-entrypoint.sh"]
CMD ["php-fpm"]