FROM php:8.5-fpm-alpine

# Install PHP extensions required by Symfony
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libxml2-dev \
    libzip-dev \
    postgresql-dev \
    && docker-php-ext-install \
    pdo_pgsql \
    gd \
    zip
# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy application code
# Copy application code
COPY . .

# Install PHP dependencies (prod env, no dev packages, no scripts)
RUN APP_ENV=prod APP_DEBUG=0 composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress \
    --no-scripts

# Create var directories and set permissions
RUN mkdir -p /var/www/html/var/cache /var/www/html/var/log \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/var
# Warm production cache
RUN APP_ENV=prod APP_DEBUG=0 php bin/console cache:warmup --env=prod || true

# Expose port 9000 for PHP-FPM

EXPOSE 9000

CMD ["php-fpm"]
