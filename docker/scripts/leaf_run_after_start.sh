#!/bin/bash

export KRB_USER=$(cat /run/secrets/krb_user)
export KRB_PASSWORD=$(cat /run/secrets/krb_pass)
export CDW_PASSWORD=$(cat /run/secrets/cdw_pass)
export CDW_USER=$(cat /run/secrets/cdw_user)
export CDW_HOST=$(cat /run/secrets/cdw_host)
export DATABASE_PASSWORD=$(cat /run/secrets/db_password)
export CIPHER_KEY=$(cat /run/secrets/cipher_key)
