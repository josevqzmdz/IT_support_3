FROM nginx:stable-alpine

# run as non-root
USER www-data

# creates "welcome to nginx!" helloworld
#COPY ./index.html /user/share/nginx/html/index.html

# https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/

# expose port 80
EXPOSE 8080 

# create folder for nginx-logs inside the nginx image
RUN mkdir -p /tmp/nginx-logs && \
    # create access.log and error.log files
    touch /tmp/nginx-logs/access.log /tmp/nginx-logs/error.log && \
    # bind this folder read write permissions to www-data user
    chown -R www-data:www-data /tmp/nginx-logs && \
    # grant mostly all read write permissions
    chmod -R 775 /tmp/nginx-logs 

# copy config files to docker
COPY ./nginx/ /etc/nginx/conf.d

# create & configure permissions for wordpress' directory
RUN mkdir -p /var/www/html && \
    usermod -u www-data www-data && \
    groupmod -g www-data www-data && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html
    
#entrypoint
CMD ["nginx", "-g", "daemon off;"]
