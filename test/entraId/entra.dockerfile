FROM leaf-php-fpm
COPY lets_talk.php /var/www/html/entraId/
COPY ttwgtt.php /var/www/html/entraId/
RUN composer require microsoft/microsoft-graph