# Base image for PHP with necessary extensions
FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www

# Install dependencies, including prerequisites for SSM Agent
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
    wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install the Amazon SSM Agent
RUN wget https://s3.amazonaws.com/amazon-ssm-region/latest/debian_amd64/amazon-ssm-agent.deb && \
    dpkg -i amazon-ssm-agent.deb && \
    rm amazon-ssm-agent.deb

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel application code
COPY . .

# Install application dependencies
RUN composer install --no-dev --optimize-autoloader

# Set appropriate permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Expose port 80 for Laravel application
EXPOSE 80

# Start the SSM Agent as part of the container startup process
CMD ["sh", "-c", "/usr/bin/amazon-ssm-agent && php artisan serve --host=0.0.0.0 --port=80"]
