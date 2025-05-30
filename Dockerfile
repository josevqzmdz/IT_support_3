# time to try multi stage builds
FROM nginx:stable-alpine

# run as root
#USER root

# creates "welcome to nginx!" helloworld
#COPY ./index.html /user/share/nginx/html/index.html

# https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/

# create folder for nginx-logs inside the nginx image
RUN mkdir -p /tmp/nginx-logs && \
    # create access.log and error.log files
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    # bind this folder read write permissions to 1001 user
    chown -R nginx:nginx /tmp/nginx-logs && \
    # grant mostly all read write permissions
    chmod -R 775 /tmp/nginx-logs 

# copy config files to docker
COPY ./nginx/ /etc/nginx/conf.d

# change to non-root
# USER nginx

# expose port 80
EXPOSE 8080 

#entrypoint
CMD ["nginx", "-g", "daemon off;"]

#########################################################################################

# wordpress

FROM wordpress:latest

# manage the user www-data with the same UID / GID than that of
# the official nginx image

# https://docs.bitnami.com/google/apps/wordpress-pro/administration/understand-file-permissions/
# gives the correct permissions to each directory
RUN mkdir -p /var/www/html/wp-content && \
    chown -R www-data:www-data  /var/www/html/wp-content && \
    chmod 775 /var/www/html/wp-content && \
    mkdir -p /var/www/html/wp-content/themes && \
    chown -R www-data:www-data /var/www/html/wp-content/themes && \
    chmod 775 /var/www/html/wp-content/themes && \
    mkdir -p /var/www/html/wp-content/cache && \
    chown -R www-data:www-data /var/www/html/wp-content/cache && \
    chmod 775 /var/www/html/wp-content/cache && \
    mkdir -p /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data /var/www/html/wp-content/uploads && \
    chmod 775 /var/www/html/wp-content/uploads

# copies the wordpress entrypoint AND the script for the memory check
COPY ./other_files/chemiloco /etc/cron.d/chemiloco
COPY ./other_files/memory_protect.sh /usr/local/bin/memory_protect.sh
COPY ./other_files/wp1-entrypoint.sh /wp1-entrypoint.sh
COPY ./other_files/system_monitor.py /usr/local/bin/system_monitor.py

# executes everything and gives each file its required permissions
RUN chmod 644 /etc/cron.d/chemiloco && \
    chmod +x /usr/local/bin/memory_protect.sh && \
    chmod +x /wp1-entrypoint.sh && \
    chmod +x /usr/local/bin/system_monitor.py && \
    touch /var/log/cron.log && \
    chown www-data:www-data  /var/log/cron.log

# boilerplate PHP glue for uploading stuff
RUN echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/uploads.ini

ENTRYPOINT ["/wp1-entrypoint.sh"]
