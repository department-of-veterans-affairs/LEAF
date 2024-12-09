FROM quay.vapo.va.gov/vapo_prd/2195-leaf-prd/leaf:2.8

COPY php-entra.ini "$PHP_INI_DIR/php.ini"

# Installation of composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
ENV PATH /root/.composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1

# install minimal procps (ps aux) and cleanup afterwards
RUN apt update && apt install --no-install-recommends -y procps && apt clean
COPY lets_talk.php /var/www/html/entraId/
COPY ttwgtt.php /var/www/html/entraId/
RUN composer require microsoft/microsoft-graph