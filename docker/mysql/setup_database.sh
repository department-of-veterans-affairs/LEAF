#!/usr/bin/env bash


printf '\n\nRunning sql scripts...'

mysql -uroot -p$MYSQL_ROOT_PASSWORD <<CREATE_DATABASE
CREATE DATABASE leaf_users;
CREATE DATABASE leaf_portal;
CREATE DATABASE nexus_testing;
CREATE DATABASE portal_testing;
CREATE_DATABASE
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<GRANT_PRIVILEGES
GRANT ALL PRIVILEGES ON *.* TO 'tester'@'%' IDENTIFIED BY 'tester';
GRANT_PRIVILEGES
mysql -utester -p$MYSQL_ROOT_PASSWORD leaf_users < /orgchart_boilerplate_empty.sql;
mysql -utester -p$MYSQL_ROOT_PASSWORD leaf_portal < /resource_database_boilerplate.sql;

printf '\n\nInserting data to tables...'
mysql -utester -p$MYSQL_ROOT_PASSWORD <<INSERT_DATA
INSERT INTO leaf_users.employee (empUID, userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, AD_objectGUID) VALUES ('1', 'tester', 'lastName', 'firstName', 'middleName', 'FN', 'LN', 'adobjectguid');
INSERT INTO leaf_users.relation_group_employee (groupID, empUID) VALUES ('1', '1');
INSERT INTO leaf_portal.users (userID, groupID) VALUES ('tester', '1');
INSERT_DATA
