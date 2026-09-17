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

# Copy application code first (or at least bin/, config/, public/, src/, templates/)
COPY . .

# Then install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/var
# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
