FROM nginxinc/nginx-unprivileged:1.22-alpine
COPY ./docker/nginxapi/leaf_nginx.conf.template /etc/nginx/templates/default.conf.template
COPY ./docker/nginx/src/index.html /var/www/html/index.html

USER 1001