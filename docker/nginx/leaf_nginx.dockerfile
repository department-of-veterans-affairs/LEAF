FROM nginx:1.21-alpine
COPY ./docker/nginx/leaf_nginx.conf.template /etc/nginx/templates/default.conf.template
COPY ./docker/nginx/src/index.php /var/www/html/index.php
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./LEAF_Nexus /var/www/html/LEAF_Nexus
COPY ./LEAF_Request_Portal /var/www/html/LEAF_Request_Portal

#Setting up "non-privledged"
RUN chown -R nginx:nginx /var/cache/nginx &&  \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d && \
        chown -R nginx:nginx /etc/nginx/templates
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid

USER nginx