mysql -u root -ptester -e "CREATE USER tester@'localhost' IDENTIFIED BY 'tester'"
mysql -u root -ptester -e "GRANT ALL PRIVILEGES ON * . * TO 'tester'@'localhost';"
mysql -u root -ptester -e "GRANT ALL PRIVILEGES ON * . * TO 'tester'@'%'; FLUSH PRIVILEGES;"

mysql -u tester -ptester -e "create database national_leaf_launchpad"
mysql -u tester -ptester -e "create database leaf_portal"
mysql -u tester -ptester -e "create database leaf_users"

mysql -u tester -ptester national_leaf_launchpad < /leaf-boilerplate/resource_database_boilerplate.sql
mysql -u tester -ptester leaf_portal < /leaf-boilerplate/resource_database_boilerplate.sql
mysql -u tester -ptester leaf_users < /leaf-boilerplate/orgchart_boilerplate_empty.sql