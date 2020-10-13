#!/usr/bin/env bash


printf '\n\nRunning sql scripts...'

mysql -uroot -p$MYSQL_ROOT_PASSWORD <<CREATE_DATABASE
CREATE DATABASE leaf_users;
CREATE DATABASE leaf_portal;
CREATE DATABASE leaf_queue;
CREATE DATABASE nexus_testing;
CREATE DATABASE portal_testing;
CREATE DATABASE leaf_config;
CREATE_DATABASE
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<GRANT_PRIVILEGES
GRANT ALL PRIVILEGES ON *.* TO 'tester'@'%' IDENTIFIED BY 'tester';
GRANT_PRIVILEGES
mysql -utester -p$MYSQL_ROOT_PASSWORD leaf_users < /orgchart_boilerplate_empty.sql;
mysql -utester -p$MYSQL_ROOT_PASSWORD leaf_portal < /resource_database_boilerplate.sql;
mysql -utester -p$MYSQL_ROOT_PASSWORD leaf_config < /setup_config.sql

printf '\n\nInserting data to tables...'
mysql -utester -p$MYSQL_ROOT_PASSWORD <<INSERT_DATA
INSERT INTO leaf_users.employee (empUID, userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, AD_objectGUID) VALUES ('1', 'tester', 'lastName', 'firstName', 'middleName', 'FN', 'LN', 'adobjectguid');
INSERT INTO leaf_users.relation_group_employee (groupID, empUID) VALUES ('1', '1');
INSERT INTO leaf_portal.users (userID, groupID) VALUES ('tester', '1');

INSERT INTO leaf_config.orgchart_configs (id, name, url, database_name, path, launchpad_id, upload_directory, active_directory_path, title, city, adminLogonName,leaf_secure,libs_path) values (1,"Organizational Chart","http://localhost/LEAF_Nexus/","leaf_users","/LEAF_Nexus/",1,"./UPLOADS/",'["OU=Users,DC=va,DC=gov"]',"Organizational Chart","Washington D.C. VAMC","admin",0,''), (2,"Test Organizational Chart","http://localhost/test/orgchart/","nexus_testing","/test/orgchart/",2,"./UPLOADS/",'["OU=Users,DC=va,DC=gov"]',"Organizational Chart","Washington D.C. VAMC","admin",0,'');
INSERT INTO leaf_config.portal_configs (id,name,url,database_name,path,launchpad_id,upload_directory,active_directory_path,leaf_secure,title,city,adminLogonName,libs_path,descriptionID,emailPrefix,emailCC,emailBCC,orgchart_id,orgchart_tags) VALUES (1,"Resources","http://localhost/LEAF_Request_Portal/","leaf_portal","/LEAF_Request_Portal/",0,"./UPLOADS/","[]",0,"Resources","Anytown, USA","admin","",16,"Resources: ","[]","[]",1,'["resources_site_access"]'), (2,"Test Resources","http://localhost/test/","portal_testing","/test/",0,"./UPLOADS/","[]",1,"Resources","Anytown, USA","admin","",16,"Resources: ","[]","[]",2,'["resources_site_access"]');
INSERT_DATA
