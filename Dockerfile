FROM php:8.1-cli

RUN apt-get update && apt-get install -y \
    libzip-dev libpng-dev libonig-dev libxml2-dev libcurl4-openssl-dev libicu-dev \
    zip unzip curl git \
    && docker-php-ext-install pdo pdo_mysql mbstring xml curl fileinfo gd zip intl bcmath ctype opcache

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer install --no-dev --optimize-autoloader

RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

EXPOSE 8080

CMD php artisan migrate --force && php artisan storage:link && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
