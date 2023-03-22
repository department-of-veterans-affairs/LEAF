#!/bin/bash
export DOLLAR="$"
envsubst < /etc/nginx/leaf_nginx.template > /etc/nginx/sites-enabled/default

./ss.sh

nginx

php-fpm --nodaemonize