FROM php:7.3.5-apache
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git zip unzip
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install gd
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod env
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/leaf.key -out /etc/ssl/certs/leaf.pem -subj "/C=US/ST=VA/L=Chantilly/O=LEAF/OU=LEAF/CN=%"
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN composer global require phpunit/phpunit ^7.4
RUN composer global require robmorgan/phinx ^0.9.2

RUN pecl install xdebug

EXPOSE 80
EXPOSE 443

# Mail()
RUN apt-get install -y ssmtp && \
  apt-get clean && \
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini
# mv php.ini and replace log dir
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN echo 'zend_extension="/usr/local/lib/php/extensions/no-debug-non-zts-20180731/xdebug.so"' >> /usr/local/etc/php/php.ini && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini && \
    echo "xdebug.remote_port=9000" >> /usr/local/etc/php/php.ini


COPY /docker/php/ssmtp/ssmtp.conf /etc/ssmtp/
COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/default-ssl.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/
COPY /docker/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint

RUN chmod +x /usr/local/bin/docker-php-entrypoint
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
