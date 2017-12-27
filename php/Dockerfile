FROM php:7-apache
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

RUN apt-get update
RUN docker-php-ext-install mysqli pdo pdo_mysql

EXPOSE 80
EXPOSE 443

COPY /LEAF/ /var/www/html/
COPY /php/apache2.conf /etc/apache2/apache2.conf
COPY /php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

RUN chmod +x /usr/local/bin/docker-php-entrypoint
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www

VOLUME /var/www/html/
