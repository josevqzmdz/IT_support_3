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
