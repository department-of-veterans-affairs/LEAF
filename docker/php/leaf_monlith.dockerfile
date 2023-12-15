FROM php:8.2-fpm as base

RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

COPY docker/php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/php/conf.d/* /usr/local/etc/php/conf.d/

# Stuff that might need to get into the base image
WORKDIR /var/www/php-logs
# WORKDIR /var/www/apache-logs
WORKDIR /var/www/html

# ssmtp
# ARG SMTP_HOST
COPY docker/php/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY docker/php/ssmtp/revaliases /etc/ssmtp/revaliases

FROM base as dev 
# xdebug
# RUN pecl config-set php_ini "$PHP_INI_DIR/php.ini"
# RUN pecl install xdebug && docker-php-ext-enable xdebug
# COPY /docker/php/etc/xdebug.ini "$PHP_INI_DIR/conf.d/xdebug.ini"

FROM base as prod
COPY ./LEAF_Nexus /var/www/html/LEAF_Nexus
COPY ./LEAF_Request_Portal /var/www/html/LEAF_Request_Portal
COPY ./libs /var/www/html/libs
COPY ./health_checks /var/www/html/health_checks
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
# USER www-data
