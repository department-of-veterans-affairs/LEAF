FROM php:7.3.5-apache
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

RUN apt-get update && apt-get install -y wget

COPY /docker/php/trust_ca_certs.sh /tmp/
RUN bash -xc "bash /tmp/trust_ca_certs.sh"

RUN apt-get update && apt-get install -y libpng-dev zlib1g-dev git subversion zlib1g-dev libzip-dev python net-tools
RUN yes | apt-get install mysql-client
RUN yes | apt-get install vim

# Mail()
RUN apt-get install -y ssmtp && \
  apt-get clean && \
  echo "FromLineOverride=YES" > /etc/ssmtp/ssmtp.conf && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

# AWS CLI
RUN curl -sL "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN python -m zipfile -e awscli-bundle.zip .
RUN chmod +x ./awscli-bundle/install
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -rf awscli-bundle awscli-bundle.zip

# git ssl error fix
RUN git config --global http.sslVerify false

# mv php.ini and replace log dir
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Mod php.ini
RUN sed -i "s/expose_php = On/expose_php = Off/" "$PHP_INI_DIR/php.ini" && \
    sed -i "s/post_max_size = 8M/post_max_size = 20M/" "$PHP_INI_DIR/php.ini" && \
    sed -i "s#;error_log = php_errors.log#error_log = /var/www/php-logs/php_errors.log#" "$PHP_INI_DIR/php.ini" && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 20M/" "$PHP_INI_DIR/php.ini" && \
    sed -i "s/memory_limit = 128M/memory_limit = 2048M/" "$PHP_INI_DIR/php.ini" && \
    sed -i "s/max_input_time = 60/max_input_time = 600/" "$PHP_INI_DIR/php.ini"

RUN docker-php-ext-install mysqli pdo pdo_mysql zip gd
RUN a2enmod rewrite
RUN a2enmod setenvif
RUN a2enmod speling

COPY /docker/php/000-default.conf /etc/apache2/sites-enabled/
COPY /docker/php/apache2.conf /etc/apache2/

RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
RUN chmod o+r /etc/resolv.conf
