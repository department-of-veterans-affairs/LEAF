#!/bin/sh
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER tester@'localhost' IDENTIFIED BY 'tester'; FLUSH PRIVILEGES;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON * . * TO 'tester'@'localhost'; FLUSH PRIVILEGES;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON * . * TO 'tester'@'%'; FLUSH PRIVILEGES;"

mysql -u tester -p$MYSQL_PASSWORD -e "create database national_leaf_launchpad"
mysql -u tester -p$MYSQL_PASSWORD -e "create database national_orgchart"
mysql -u tester -p$MYSQL_PASSWORD -e "create database leaf_portal"
mysql -u tester -p$MYSQL_PASSWORD -e "create database leaf_users"

mysql -u tester -p$MYSQL_PASSWORD national_leaf_launchpad < /leaf-boilerplate/resource_database_boilerplate.sql
mysql -u tester -p$MYSQL_PASSWORD national_leaf_launchpad < /leaf-dev_db/dev_national_leaf_launchpad.sql

mysql -u tester -p$MYSQL_PASSWORD national_orgchart < /leaf-boilerplate/orgchart_boilerplate_empty.sql
mysql -u tester -p$MYSQL_PASSWORD national_orgchart < /leaf-dev_db/dev_leaf_users.sql

mysql -u tester -p$MYSQL_PASSWORD leaf_portal < /leaf-boilerplate/resource_database_boilerplate.sql
mysql -u tester -p$MYSQL_PASSWORD leaf_portal < /leaf-dev_db/dev_leaf_portal.sql

mysql -u tester -p$MYSQL_PASSWORD leaf_users < /leaf-boilerplate/orgchart_boilerplate_empty.sql
mysql -u tester -p$MYSQL_PASSWORD leaf_users < /leaf-dev_db/dev_leaf_users.sql
