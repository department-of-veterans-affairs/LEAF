#!/usr/bin/env bash

export DATABASE_NEXUS="${DATABASE_NEXUS-leaf_users}"
export DATABASE_PORTAL="${DATABASE_PORTAL-leaf_portal}"
export DATABASE_USERNAME="${DATABASE_USERNAME-tester}"
export DATABASE_PASSWORD="${DATABASE_PASSWORD-tester}"

cd /var/www/html/

cp ./LEAF_Nexus/globals.php.example ./LEAF_Nexus/globals.php
# Nexus globals 
sed -i  "s/HOSTNAME/$DB_HOST/g" ./LEAF_Nexus/globals.php
sed -i  "s/DB_NAME/$DATABASE_NEXUS/g" ./LEAF_Nexus/globals.php
sed -i  "s/USERNAME/$DATABASE_USERNAME/g" ./LEAF_Nexus/globals.php
sed -i  "s/PASSWORD/$DATABASE_PASSWORD/g" ./LEAF_Nexus/globals.php

cp ./LEAF_Nexus/config-example.php ./LEAF_Nexus/config.php
# Nexus config
sed -i  "s/SERVER_HOSTNAME/$DB_HOST/g" ./LEAF_Nexus/config.php
sed -i  "s/DATABASE_NAME/$DATABASE_NEXUS/g" ./LEAF_Nexus/config.php
sed -i  "s/DATABASE_USERNAME/$DATABASE_USERNAME/g" ./LEAF_Nexus/config.php
sed -i  "s/DATABASE_PASSWORD/$DATABASE_PASSWORD/g" ./LEAF_Nexus/config.php

cp ./LEAF_Request_Portal/globals.php.example ./LEAF_Request_Portal/globals.php
# Portal globals
sed -i -e "s/DIRECTORY_HOST = '.*/DIRECTORY_HOST = '$DB_HOST';/"            ./LEAF_Request_Portal/globals.php
sed -i -e "s/DIRECTORY_DB = '.*/DIRECTORY_DB = '$DATABASE_NEXUS';/"         ./LEAF_Request_Portal/globals.php
sed -i -e "s/DIRECTORY_USER = '.*/DIRECTORY_USER = '$DATABASE_USERNAME';/"  ./LEAF_Request_Portal/globals.php
sed -i -e "s/DIRECTORY_PASS = '.*/DIRECTORY_PASS = '$DATABASE_PASSWORD';/"  ./LEAF_Request_Portal/globals.php

cp ./LEAF_Request_Portal/db_config-example.php ./LEAF_Request_Portal/db_config.php
# Portal db_config
sed -i -e "s/dbHost = '.*/dbHost = '$DB_HOST';/"                      ./LEAF_Request_Portal/db_config.php
sed -i -e "s/dbName = '.*/dbName = '$DATABASE_PORTAL';/"              ./LEAF_Request_Portal/db_config.php
sed -i -e "s/dbUser = '.*/dbUser = '$DATABASE_USERNAME';/"            ./LEAF_Request_Portal/db_config.php
sed -i -e "s/dbPass = '.*/dbPass = '$DATABASE_PASSWORD';/"            ./LEAF_Request_Portal/db_config.php
sed -i -e "s/orgchartPath = '.*/orgchartPath = '..\/LEAF_Nexus';/"    ./LEAF_Request_Portal/db_config.php
sed -i -e "s/phonedbName = '.*/phonedbName = '$DATABASE_NEXUS';/"     ./LEAF_Request_Portal/db_config.php

# Disable AUTH_TYPE
sed -i -e "s/^const AUTH_TYPE/# const AUTH_TYPE/" ./LEAF_Nexus/globals.php

