FROM php:7.3.5-apache
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git subversion wget curl zip unzip
RUN yes | apt-get install mysql-client
RUN yes | apt-get install vim
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install gd
RUN a2enmod rewrite
RUN a2enmod setenvif

COPY /docker/php/trust_ca_certs.sh /tmp/
RUN bash -xc "bash /tmp/trust_ca_certs.sh"

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

ENV PATH /root/.composer/vendor/bin:$PATH

COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/
COPY /LEAF_Nexus/ /var/www/html/LEAF_Nexus/
COPY /LEAF_Request_Portal/ /var/www/html/LEAF_Request_Portal/
COPY /libs/ /var/www/html/libs/
COPY /index.html /var/www/html/index.html
Copy /routing/ /var/www/html/routing
Copy /composer.json /var/www/html/composer.json
Copy /index.php /var/www/html/index.php

RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
RUN cd /var/www/html && composer install
RUN chmod o+r /etc/resolv.conf