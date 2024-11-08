# Use PHP with Apache image as the base
FROM php:8.2-apache

# Install PHP extensions required by Laravel
RUN docker-php-ext-install pdo pdo_mysql

# Set the ServerName to avoid Apache warnings
RUN echo "ServerName myapp.local" >> /etc/apache2/apache2.conf

# Install system dependencies required by Composer
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html/

# Copy the application files into the container with specified ownership
COPY --chown=www-data:www-data . /var/www/html/

# Copy custom Apache configuration file
COPY ./docker-compose/apache/apache-config.conf /etc/apache2/sites-available/000-default.conf

# Run composer install inside the container after copying project files
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# Enable the Apache site and mod_rewrite for Laravel
RUN a2ensite 000-default.conf
RUN a2enmod rewrite

# Set appropriate permissions for Laravel directories
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
