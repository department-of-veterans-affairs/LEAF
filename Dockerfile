FROM php:7.3.5-apache
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-install gd

RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod env

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/leaf.key -out /etc/ssl/certs/leaf.pem -subj "/C=US/ST=VA/L=Chantilly/O=LEAF/OU=LEAF/CN=%"

EXPOSE 80
EXPOSE 443

COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/default-ssl.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/
COPY /docker/php/update_env.sh /usr/local/bin/update_env.sh
COPY /docker/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

COPY /LEAF_Nexus  /var/www/html/LEAF_Nexus
COPY /LEAF_Request_Portal  /var/www/html/LEAF_Request_Portal
COPY /libs  /var/www/html/libs
COPY index.php.redirect /var/www/html/index.php

RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www

