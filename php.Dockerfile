
FROM php:8.2.27-fpm-bookworm
# https://gist.github.com/md5/d9206eacb5a0ff5d6be0

RUN apt-get update && apt-get install -y libfreetype-dev libjpeg62-turbo-dev libpng-dev libzip-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-install zip mysqli pdo pdo_mysql bcmath calendar gettext opcache \
	&& docker-php-ext-install pcntl \
	&& pecl install redis-6.1.0 \
	&& pecl install xdebug-3.2.1 \
	&& docker-php-ext-enable redis xdebug \
	&& docker-php-source delete

COPY php.ini * /usr/local/etc/php/conf.d/
COPY ./nginx/default.conf /usr/local/etc/php-fpm.d/default.conf