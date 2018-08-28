FROM mariadb
MAINTAINER Nick Ciardiello <nick.ciardiello@ablevets.com>

ENV MYSQL_ROOT_PASSWORD tester

COPY /LEAF_Nexus/orgchart_boilerplate_empty.sql /
COPY /LEAF_Request_Portal/resource_database_boilerplate.sql /
COPY /docker/mysql/setup_database.sh /docker-entrypoint-initdb.d/setup_database.sh
COPY /docker/mysql/leaf_portal_test_data.sql /
COPY /docker/mysql/leaf_users_test_data.sql /
