# Base image for PHP with necessary extensions
FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel application code
COPY . .

# Install application dependencies
RUN composer install --no-dev --optimize-autoloader

# Set appropriate permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Run the necessary Laravel commands
RUN php artisan storage:link

# Expose port 8000 for Laravel application
EXPOSE 80

# Start Laravel application server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
