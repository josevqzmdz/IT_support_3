#!/bin/sh
set -e

echo "Setting WordPress permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

if [ -d "/opt/bitnami/nginx" ]; then
    echo "Configuring Nginx..."
    chown -R 1001:1001 /opt/bitnami/nginx/conf
    chmod -R 777 /opt/bitnami/nginx/conf/server_blocks
fi

if [ -f "/var/www/html/wp-config.php" ]; then
    echo "Updating wp-config.php..."
    sed -i "s|define('DB_HOST', '.*');|define('DB_HOST', '${WORDPRESS_DB_HOST:-db}');|" /var/www/html/wp-config.php
    sed -i "s|define('DB_USER', '.*');|define('DB_USER', '${WORDPRESS_DB_USER:-wordpress}');|" /var/www/html/wp-config.php
    sed -i "s|define('DB_PASSWORD', '.*');|define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD:-wordpress}');|" /var/www/html/wp-config.php
fi

if [ ! -f "/etc/nginx/certs/server.crt" ]; then
    echo "Generating self-signed certificate..."
    mkdir -p /etc/nginx/certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/certs/server.key \
        -out /etc/nginx/certs/server.crt \
        -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost"
fi

echo "Starting Nginx..."
chown -R 1001:1001 /var/www/html
exec /opt/bitnami/scripts/nginx/entrypoint.sh "$@"