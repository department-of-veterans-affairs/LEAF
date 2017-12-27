#!/usr/bin/env bash

printf '\n\nRunning sql scripts...'
mysql -uroot -p$MYSQL_ROOT_PASSWORD leaf_users < /LEAF_Nexus/orgchart_boilerplate_empty.sql;
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<SETUP_DATABASE
CREATE DATABASE leaf_portal;
SETUP_DATABASE
mysql -uroot -p$MYSQL_ROOT_PASSWORD leaf_portal < /LEAF_Request_Portal/resource_database_boilerplate.sql;

printf '\n\nInserting data to tables...'
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<INSERT_DATA
INSERT INTO leaf_users.employee (empUID, userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, AD_objectGUID) VALUES ('1', 'tester', 'last_name', 'first_name', 'middle_name', 'phonetic_first_name', 'phonetic_last_name', 'adobjectguid');
INSERT INTO leaf_users.relation_group_employee (groupID, empUID) VALUES ('1', '1');
INSERT INTO leaf_portal.users (userID, groupID) VALUES ('tester', '1');
INSERT_DATA
