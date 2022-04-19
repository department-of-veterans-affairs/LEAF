#!/bin/sh
echo ${KRB_PASS} | kinit ${KRB_USER}@${KRB_DOMAIN}
echo "Toga one! ${KRB_USER}"