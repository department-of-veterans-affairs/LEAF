FROM ubuntu:18.04
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -q && apt-get install software-properties-common -y && \
	add-apt-repository ppa:ondrej/php && apt-get update && \
	apt-get install -y python python-pip \
	git composer nginx php7.3-fpm php7.3-intl php7.3-common php7.3-mbstring \
	php7.3-zip php7.3-cli php7.3-gd php7.3-zip php7.3-simplexml php7.3-xml \
	php7.3-pdo php7.3-curl php7.3-imagick pkg-config \
	php7.3-mysql gcc make autoconf libc-dev pkg-config php7.3-dev libfcgi0ldbl 

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git subversion zlib1g-dev libzip-dev net-tools iputils-ping zip mysql-client vim wget nginx ssmtp netcat

COPY /docker/php/trust_ca_certs.sh /tmp/
RUN bash -xc "bash /tmp/trust_ca_certs.sh"

RUN apt-get install -y locales && locale-gen en_US.UTF-8
RUN bash -xc 'echo LANG="en_US.UTF-8" > /etc/default/locale' 
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
RUN bash -xc 'locale -a' # testing

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

ENV PATH /root/.composer/vendor/bin:$PATH

EXPOSE 80
EXPOSE 443

COPY /docker/php/etc/www.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY /docker/php/etc/fpm/php.ini /etc/php/7.3/fpm/php.ini
COPY /docker/php/etc/cli/php.ini /etc/php/7.3/cli/php.ini

COPY /docker/nginx/default.conf /etc/nginx/sites-available/default
COPY /docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY /docker/php/ssmtp/ssmtp.conf /etc/ssmtp/
COPY /docker/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY /LEAF_Nexus/ /var/www/html/LEAF_Nexus/
COPY /LEAF_Request_Portal/ /var/www/html/LEAF_Request_Portal/
COPY /libs/ /var/www/html/libs/
COPY /index.html /var/www/html/index.html
COPY /routing/ /var/www/html/routing
COPY /composer.json /var/www/html/composer.json
COPY /index.php /var/www/html/index.php
COPY /healthcheck/ /var/www/html/healthcheck
COPY /docker/php/etc/php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
COPY /docker/php/etc/pod-healthcheck.sh /usr/local/bin/pod-healthcheck


COPY /docker/php/etc/php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
COPY /docker/php/etc/pod-healthcheck.sh /usr/local/bin/pod-healthcheck

ARG BUILD_UID=1000
RUN useradd -u $BUILD_UID -g www-data build_user

RUN bash -xc 'mkdir /var/www/php-logs && chown 33:33 /var/www/php-logs'
RUN chmod +x /usr/local/bin/docker-php-entrypoint
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
RUN chmod +x /usr/local/bin/docker-php-entrypoint

RUN cd /var/www/html && composer install

WORKDIR /var/www/html/

CMD /etc/init.d/php7.3-fpm start && nginx -g 'daemon off;'
ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]
