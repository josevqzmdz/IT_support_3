
# https://gist.github.com/md5/d9206eacb5a0ff5d6be0

FROM php:8.2-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd zip mysqli pdo pdo_mysql bcmath calendar gettext opcache pcntl && \
    pecl install redis-6.1.0 xdebug-3.2.1 && \
    docker-php-ext-enable redis xdebug

COPY php.ini /usr/local/etc/php/conf.d/
COPY ./nginx/default.conf /usr/local/etc/php-fpm.d/www.conf