#!/bin/bash
export DOLLAR="$"
envsubst < /etc/nginx/leaf_nginx.template > /etc/nginx/sites-enabled/default

. /etc/init.d/ss.sh

nginx

php-fpm --nodaemonize