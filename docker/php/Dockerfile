FROM php:7.3.5-apache
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git
RUN yes | apt-get install mysql-client
RUN yes | apt-get install vim
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install gd
RUN a2enmod rewrite
RUN a2enmod setenvif

COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/

RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
RUN chmod o+r /etc/resolv.conf
