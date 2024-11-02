# Use PHP with Apache image as the base
FROM php:8.2-apache

# Install PHP extensions required by Laravel
RUN docker-php-ext-install pdo pdo_mysql

RUN echo "ServerName myapp.local" >> /etc/apache2/apache2.conf

# Copy custom Apache configuration file
COPY ./docker-compose/apache/apache-config.conf /etc/apache2/sites-available/000-default.conf
# Set working directory
WORKDIR /var/www/html/

RUN a2ensite 000-default.conf
# Enable Apache mod_rewrite for Laravel
RUN a2enmod rewrite

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]
