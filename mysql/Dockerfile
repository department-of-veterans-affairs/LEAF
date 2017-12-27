FROM mysql/mysql-server
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

ENV MYSQL_ROOT_PASSWORD tester

COPY /LEAF/ /
COPY /mysql/setup_database.sh /docker-entrypoint-initdb.d/setup_database.sh
