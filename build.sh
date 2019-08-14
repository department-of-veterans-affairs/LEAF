#!/bin/bash
###STUFF FROM OLD PIPELINE

./app.env

#Rename globals.php
pwd
ls -l
cp ./LEAF_Nexus/globals.php.example ./LEAF_Nexus/globals.php

#replace information in Leaf nexus globals.php
sed -i "s/HOSTNAME/$HOSTNAME/g" ./LEAF_Nexus/globals.php
sed -i "s/DB_NAME/$DB_NAME/g" ./LEAF_Nexus/globals.php
sed -i "s/USERNAME/$USERNAME/g" ./LEAF_Nexus/globals.php
sed -i "s/PASSWORD/$PASSWORD/g" ./LEAF_Nexus/globals.php

#Rename config file
cp ./LEAF_Nexus/config-example.php ./LEAF_Nexus/config.php

#replace information in Leaf Nexus config.php
sed -i  "s/SERVER_HOSTNAME/$SERVER_HOSTNAME/g" ./LEAF_Nexus/config.php
sed -i  "s/DATABASE_NAME/$DATABASE_NAME/g" ./LEAF_Nexus/config.php
sed -i  "s/DATABASE_USERNAME/$DATABASE_USERNAME/g" ./LEAF_Nexus/config.php
sed -i  "s/DATABASE_PASSWORD/$DATABASE_PASSWORD/g" ./LEAF_Nexus/config.php
sed -i  "s/CONFIG_USER/$CONFIG_USER/g" ./LEAF_Nexus/config.php

#Rename globals again
cp ./LEAF_Request_Portal/globals.php.example ./LEAF_Request_Portal/globals.php

#replace information in Leaf Request portal globls.php
sed -i  "s/LRP_HOSTNAME/$LRP_HOSTNAME/g" ./LEAF_Request_Portal/globals.php
sed -i  "s/LRP_DB_NAME/$LRP_DB_NAME/g" ./LEAF_Request_Portal/globals.php
sed -i  "s/LRP_USERNAME/$LRP_USERNAME/g" ./LEAF_Request_Portal/globals.php
sed -i  "s/LRP_PASSWORD/$LRP_PASSWORD/g" ./LEAF_Request_Portal/globals.php

#Rename config file 
cp ./LEAF_Request_Portal/db_config-example.php ./LEAF_Request_Portal/db_config.php

#replace information in Leaf Reqeust portal dbconfig
sed -i  "s/LRP_SERVER_HOSTNAME/$LRP_SERVER_HOSTNAME/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_DATABASE_NAME/$LRP_DATABASE_NAME/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_DATABASE_USERNAME/$LRP_DATABASE_USERNAME/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_DATABASE_PASSWORD/$LRP_DATABASE_PASSWORD/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneSERVER_HOSTNAME/$LRP_phoneSERVER_HOSTNAME/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneDATABASE_NAME/$LRP_phoneDATABASE_NAME/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneDATABASE_USERNAME/$LRP_phoneDATABASE_USERNAME/g" ./LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneDATABASE_PASSWORD/$LRP_phoneDATABASE_PASSWORD/g" ./LEAF_Request_Portal/db_config.php

printf "\n\n\n\n**** RUNNING BUILD ********************\n\n"
APPDATE=`date "+%B %d, %Y"`

if [ -z $APP_NAME ] || [ -z $APP_VERSION ]; then
    source ../../../Library/Containers/com.apple.mail/Data/Library/Mail
fi

if [ -z $BUILD_NUMBER ]; then
    BUILD_NUMBER="SNAPSHOT"
fi

if [ -z $JOB_NAME ]; then
    JOB_NAME=$APP_NAME
fi

if [ -z $STAGING_DIR ]; then
    printf "STAGING_DIR not specified, defaulting to dist/\n";
    STAGING_DIR="dist"
else
    STAGING_DIR=$(echo ${STAGING_DIR} | sed 's:/*$::')
    printf "Using staging directory '$STAGING_DIR'\n";
fi

if [ -d $STAGING_DIR ] && [ $STAGING_DIR != "." ]; then
    printf "Cleaning staging directory...\n"
    rm -r $STAGING_DIR
else
    printf "No staging directory to be cleaned at ${STAGING_DIR}\n"
fi

if [ -z $BUILD_DIR ]; then
    printf "Artifact directory 'BUILD_DIR' not specified, defaulting to build/\n";
    BUILD_DIR="build"
else
    BUILD_DIR=$(echo ${BUILD_DIR} | sed 's:/*$::')
    printf "Using build directory '$BUILD_DIR'\n";
fi

if [ -d $BUILD_DIR ] && [ $BUILD_DIR != "." ]; then
    printf "Cleaning build directory...\n"
    rm -r $BUILD_DIR
else
    printf "No build directory to be cleaned at ${BUILD_DIR}\n"
fi

if [ -z ${DTR_PREFIX// }${DTR_ORG// } ]; then
    printf "Both DTR_PREFIX and DTR_ORG not set, pointing Docker images to dev\n"
    DTR_PREFIX=dev
fi

if [ -f $JOB_NAME*.tar.gz ]; then
    printf "Cleaning old build artifacts from workspace root\n"
    rm $JOB_NAME*.tar.gz
fi

# Dependency Check
printf "\n\n**** Mandatory: Dependency Checks ********************\n"

# Determine where the script is located
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
scriptPath="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Build Artifact Production
printf "\n\n**** Optional: Producing Build Artifacts ********************\n\n"

# create directory to copy docker-leaf files
mkdir -p $BUILD_DIR
mkdir -p $STAGING_DIR

# copy files
if [ $STAGING_DIR != "dist" ]; then
    # Need to move the grunt output from dist (where grunt puts it) to staging
    # This is a hack, ideally grunt just builds to the right directory
    cp -R dist/* $STAGING_DIR
fi

cp -R docker $STAGING_DIR
cp -R LEAF_Nexus $STAGING_DIR
cp -R LEAF_Request_Portal $STAGING_DIR
cp app.env $STAGING_DIR


# Set DTR for Docker - Perform against ALL Dockerfiles in your project
/usr/bin/perl -i -pe "s|COPY /|COPY |" docker/mysql/Dockerfile || { echo "FATAL: Could not set DTR Prefix"; exit 1; }
/usr/bin/perl -i -pe "s|COPY /|COPY |" docker/php/Dockerfile || { echo "FATAL: Could not set DTR Prefix"; exit 1; }

ARTIFACT="${BUILD_DIR}/${JOB_NAME}.BUILD-${BUILD_NUMBER}.tar.gz"
printf "${ARTIFACT}==========================\n"
printf "Building application artifact ${ARTIFACT}...\n\n"
tar -C $STAGING_DIR -zcvf $ARTIFACT . || { echo "FATAL: Failed on 'Artifact tar''"; exit 1; }
cp $ARTIFACT .
cp $ARTIFACT out/

printf "\n\n\n\n**** COMPLETED BUILD ********************\n\n"