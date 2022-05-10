FROM nginx:1.21-alpine
COPY ./docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf