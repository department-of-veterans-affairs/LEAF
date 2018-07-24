FROM mysql/mysql-server:5.7
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

ENV MYSQL_ROOT_PASSWORD tester

COPY ./docker/unit-testing/phpunit-db/setup_database.sh /docker-entrypoint-initdb.d/setup_database.sh
