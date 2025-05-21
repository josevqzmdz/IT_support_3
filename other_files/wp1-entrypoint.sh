#!/bin/sh

if ! command -v php-fpm >/dev/null 2>&1; then
  echo "php-fpm not found. installing..."
  apk add --no-cache php8-fpm
fi

exec php-fpm