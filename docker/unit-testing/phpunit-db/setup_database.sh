#!/usr/bin/env bash


printf '\n\nRunning sql scripts...'

mysql -uroot -p$MYSQL_ROOT_PASSWORD <<CREATE_DATABASE
CREATE DATABASE nexus_testing;
CREATE DATABASE portal_testing;
CREATE_DATABASE
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<GRANT_PRIVILEGES
GRANT ALL PRIVILEGES ON *.* TO 'tester'@'%' IDENTIFIED BY 'tester';
GRANT_PRIVILEGES
