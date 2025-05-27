FROM wordpress:latest

USER www-data

# https://docs.bitnami.com/google/apps/wordpress-pro/administration/understand-file-permissions/
# gives the correct permissions to each directory
RUN mkdir -p /var/www/html/wp-content && \
    chown -R www-data:www-data  /var/www/html/wp-content && \
    chmod 775 /var/www/html/wp-content && \
    #
    mkdir -p /var/www/html/wp-content/themes && \
    chown -R www-data:www-data /var/www/html/wp-content/themes && \
    chmod 775 /var/www/html/wp-content/themes && \
    #
    mkdir -p /var/www/html/wp-content/cache && \
    chown -R www-data:www-data /var/www/html/wp-content/cache && \
    chmod 775 /var/www/html/wp-content/cache && \
    #
    mkdir -p /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data  /var/www/html/wp-content/uploads && \
    chmod 775 /var/www/html/wp-content/uploads && \
    #
    chown -R www-data:www-data /var/www/html/wp-content && \
    chown -R www-data:www-data /var/www/html/wp-content/themes && \
    chown -R www-data:www-data /var/www/html/wp-content/cache && \
    chown -R www-data:www-data /var/www/html/wp-content/uploads 

# copies a python image for the memory check
FROM python:3
WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# copies the wordpress entrypoint AND the script for the memory check
COPY ./other_files/chemiloco /etc/cron.d/chemiloco
COPY ./other_files/memory_protect.sh /etc/cron.d/memory_protect.sh
COPY ./other_files/wp1.entrypoint.sh /wp1.entrypoint.sh
COPY ./other_files/system_monitor.py /etc/cron.d/system_monitor.py

# executes everything and gives each file its required permissions
RUN chmod 775 /etc/crond.d/chemiloco && \
    chmod 775 /etc/cron.d/memory_protect.sh && \
    chmod 775 /wp1.entrypoint.sh && \
    chmod 775 /etc/cron.d/system_monitor.py && \

    chmod +x /etc/crond.d/chemiloco && \
    chmod +x /etc/cron.d/memory_protect.sh && \
    chmod +x /wp1.entrypoint.sh && \
    chmod +x /etc/cron.d/system_monitor.py && \

    touch /var/log/cron.log

ENTRYPOINT ["/wp1.entrypoint.sh"]
