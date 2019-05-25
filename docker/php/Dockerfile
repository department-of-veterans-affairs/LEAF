FROM php:7.3.5-apache
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git subversion zlib1g-dev libzip-dev python
RUN yes | apt-get install mysql-client
RUN yes | apt-get install vim

RUN apt-get install -y ssmtp && \
  apt-get clean && \
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

RUN curl -sL "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN python -m zipfile -e awscli-bundle.zip .
RUN chmod +x ./awscli-bundle/install
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -rf awscli-bundle

RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install gd
RUN docker-php-ext-install zip
RUN a2enmod rewrite
RUN a2enmod setenvif

COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/

RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
RUN chmod o+r /etc/resolv.conf
