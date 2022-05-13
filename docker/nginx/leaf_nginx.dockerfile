FROM nginx:1.21-alpine
COPY ./docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./docker/nginx/src/index.php /var/www/html/index.php