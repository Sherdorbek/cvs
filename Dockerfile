FROM php:8.3-fpm-alpine

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

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for better layer caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Copy application code
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/var/cache /var/www/html/var/log

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
