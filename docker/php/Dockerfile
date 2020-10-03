FROM ubuntu:18.04
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -q && apt-get install software-properties-common -y && \
	add-apt-repository ppa:ondrej/php && apt-get update && \
	apt-get install -y python python-pip \
	git composer nginx php7.3-fpm php7.3-intl php7.3-common php7.3-mbstring \
	php7.3-zip php7.3-cli php7.3-gd php7.3-zip php7.3-simplexml php7.3-xml \
	php7.3-pdo php7.3-curl php7.3-imagick pkg-config \
	php7.3-mysql gcc make autoconf libc-dev pkg-config php7.3-dev

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git subversion zlib1g-dev libzip-dev net-tools iputils-ping zip mysql-client vim wget nginx ssmtp netcat

COPY /docker/php/trust_ca_certs.sh /tmp/
RUN bash -xc "bash /tmp/trust_ca_certs.sh"

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/leaf.key -out /etc/ssl/certs/leaf.pem -subj "/C=US/ST=VA/L=Chantilly/O=LEAF/OU=LEAF/CN=%"
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN composer global require phpunit/phpunit ^7.4
RUN composer global require robmorgan/phinx ^0.9.2

ENV PATH /root/.composer/vendor/bin:$PATH

EXPOSE 80
EXPOSE 443

# xdebug
RUN pecl config-set php_ini "/etc/php/7.3/fpm/php.ini" && yes | pecl install xdebug
COPY /docker/php/etc/xdebug.ini "/etc/php/7.3/fpm/conf.d/xdebug.ini"

RUN sed -i.bak "s/;clear_env = no/clear_env = no/g" /etc/php/7.3/fpm/pool.d/www.conf

RUN echo "upload_max_filesize = 100M" | tee -a /etc/php/7.3/fpm/php.ini
RUN echo "expose_php = Off" | tee -a /etc/php/7.3/fpm/php.ini
RUN echo "memory_limit = 2048M" | tee -a /etc/php/7.3/fpm/php.ini
RUN echo "max_input_time = 600" | tee -a /etc/php/7.3/fpm/php.ini
RUN echo 'sendmail_path = "/usr/sbin/ssmtp -t"' | tee -a /etc/php/7.3/fpm/php.ini
RUN echo "error_log = /var/www/php-logs/error_log" | tee -a /etc/php/7.3/fpm/php.ini

COPY /docker/nginx/nginx.conf /etc/nginx/sites-available/default
COPY /docker/php/ssmtp/ssmtp.conf /etc/ssmtp/
COPY /docker/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY /LEAF_Nexus/ /var/www/html/LEAF_Nexus/
COPY /LEAF_Request_Portal/ /var/www/html/LEAF_Request_Portal/
COPY /libs/ /var/www/html/libs/
COPY /index.html /var/www/html/index.html
Copy /routing/ /var/www/html/routing
Copy /composer.json /var/www/html/composer.json
Copy /index.php /var/www/html/index.php

ARG BUILD_UID=1000
RUN useradd -u $BUILD_UID -g www-data build_user

RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www

WORKDIR /var/www/html/

CMD /etc/init.d/php7.3-fpm start && nginx -g 'daemon off;'
