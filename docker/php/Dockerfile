FROM php:7.3.5-apache
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

RUN apt-get update && apt-get install -y wget

COPY /docker/php/trust_ca_certs.sh /tmp/
RUN bash -xc "bash /tmp/trust_ca_certs.sh"


RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev libzip-dev git zip unzip
RUN docker-php-ext-install zip

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git zip unzip iputils-ping netcat vim

RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install gd
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod env
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_connect
RUN apt-get install -y mysql-client

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/leaf.key -out /etc/ssl/certs/leaf.pem -subj "/C=US/ST=VA/L=Chantilly/O=LEAF/OU=LEAF/CN=%"
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN composer global require phpunit/phpunit ^7.4
RUN composer global require robmorgan/phinx ^0.9.2

ENV PATH /root/.composer/vendor/bin:$PATH

EXPOSE 80
EXPOSE 443

# Mail()
RUN apt-get install -y ssmtp && \
  apt-get clean && \
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

# xdebug
RUN pecl config-set php_ini "$PHP_INI_DIR/php.ini" && yes | pecl install xdebug
COPY /docker/php/etc/xdebug.ini "$PHP_INI_DIR/conf.d/xdebug.ini"


COPY /docker/php/ssmtp/ssmtp.conf /etc/ssmtp/
COPY /docker/php/swagger-proxy.conf /etc/apache2/conf-enabled/
COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/default-ssl.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/
COPY /docker/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

ARG BUILD_UID=1000
RUN useradd -u $BUILD_UID -g www-data build_user

RUN chmod +x /usr/local/bin/docker-php-entrypoint
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
