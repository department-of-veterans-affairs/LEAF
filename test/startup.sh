#!/bin/bash
export DOLLAR="$"
envsubst < /etc/nginx/leaf_nginx.template > /etc/nginx/sites-enabled/default

set -a
export KRB_USER=$(cat /run/secrets/krb_user)
export KRB_PASSWORD=$(cat /run/secrets/krb_pass)
export CDW_PASSWORD=$(cat /run/secrets/cdw_pass)
export CDW_USER=$(cat /run/secrets/cdw_user)
export CDW_HOST=$(cat /run/secrets/cdw_host)
export DATABASE_PASSWORD=$(cat /run/secrets/db_password)
# export DATABASE_HOST=$(cat /run/secrets/db_host)
# export DATABASE_HOST=$(cat /run/secrets/db_host_ip)
export DATABASE_DB_ADMIN=$(cat /run/secrets/db_admin)
export APP_CIPHER_KEY=$(cat /run/secrets/cipher_key)
set +a

source /etc/init.d/krb_wrangler.sh &

nginx

php-fpm --nodaemonize