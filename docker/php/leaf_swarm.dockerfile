# FROM pelentan/leaf-php-nginx-base:1.3 as base
FROM pelentan/leaf-php-nginx-base:staging as base


# COPY docker/php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# Stuff that might need to get into the base image
WORKDIR /var/www/php-logs
# WORKDIR /var/www/apache-logs
WORKDIR /var/www/html

# ssmtp
# ARG SMTP_HOST
COPY ./docker/php/ssmtp/swarm_ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY ./docker/php/ssmtp/swarm_revaliases /etc/ssmtp/revaliases

FROM base as dev 
# xdebug
# RUN pecl config-set php_ini "$PHP_INI_DIR/php.ini"
# RUN pecl install xdebug && docker-php-ext-enable xdebug
# COPY /docker/php/etc/xdebug.ini "$PHP_INI_DIR/conf.d/xdebug.ini"

FROM base as prod
COPY ./LEAF_Nexus /var/www/app/Orgchart
COPY ./LEAF_Request_Portal /var/www/app/Portal
COPY ./libs /var/www/html/libs
COPY ./health_checks /var/www/app/health_checks
COPY ../LEAF_Request_Portal/vafavicon.ico /var/www/html/favicon.ico
COPY ../LEAF_Request_Portal/vafavicon.ico /var/www/html/LEAF_Nexus/vafavicon.ico
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www
# USER www-data
COPY docker/scripts/startup.sh /startup.sh
RUN chmod +x /startup.sh
# COPY docker/scripts/leaf_run_after_start.sh /leaf_run_after_start.sh
# RUN chmod +x /leaf_run_after_start.sh
# COPY docker/scripts/leaf_run_after_start_sysD.service /etc/systemd/system/leaf_run_after_start_sysD.service

