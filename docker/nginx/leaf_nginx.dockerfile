FROM nginx:1.21-alpine
COPY ./docker/nginx/leaf_nginx.conf.template /etc/nginx/templates/default.conf.template
COPY ./docker/nginx/src/index.php /var/www/html/index.php
COPY ./LEAF_Nexus /var/www/html/LEAF_Nexus
COPY ./LEAF_Request_Portal /var/www/html/LEAF_Request_Portal