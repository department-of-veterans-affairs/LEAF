FROM php:7.2-fpm
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

RUN apt-get update && apt-get install -y git zip unzip
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN composer global require phpunit/phpunit ^6.0
RUN composer global require robmorgan/phinx ^0.9.2
