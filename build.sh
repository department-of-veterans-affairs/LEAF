#!/bin/bash
###STUFF FROM OLD PIPELINE

#./app.env
source app.env


#Rename globals.php
cp $WORKSPACE/LEAF_Nexus/globals.php.example $WORKSPACE/LEAF_Nexus/globals.php

#replace information in Leaf nexus globals.php
sed -i "s/HOSTNAME/$HOSTNAME/g" $WORKSPACE/LEAF_Nexus/globals.php
sed -i "s/DB_NAME/$DB_NAME/g" $WORKSPACE/LEAF_Nexus/globals.php
sed -i "s/USERNAME/$USERNAME/g" $WORKSPACE/LEAF_Nexus/globals.php
sed -i "s/PASSWORD/$PASSWORD/g" $WORKSPACE/LEAF_Nexus/globals.php

#Rename config file
cp $WORKSPACE/LEAF_Nexus/config-example.php $WORKSPACE/LEAF_Nexus/config.php

#replace information in Leaf Nexus config.php
sed -i  "s/SERVER_HOSTNAME/$SERVER_HOSTNAME/g" $WORKSPACE/LEAF_Nexus/config.php
sed -i  "s/DATABASE_NAME/$DATABASE_NAME/g" $WORKSPACE/LEAF_Nexus/config.php
sed -i  "s/DATABASE_USERNAME/$DATABASE_USERNAME/g" $WORKSPACE/LEAF_Nexus/config.php
sed -i  "s/DATABASE_PASSWORD/$DATABASE_PASSWORD/g" $WORKSPACE/LEAF_Nexus/config.php
sed -i  "s/CONFIG_USER/$CONFIG_USER/g" $WORKSPACE/LEAF_Nexus/config.php

#Rename globals again
cp $WORKSPACE/LEAF_Request_Portal/globals.php.example $WORKSPACE/LEAF_Request_Portal/globals.php

#replace information in Leaf Request portal globls.php
sed -i  "s/LRP_HOSTNAME/$LRP_HOSTNAME/g" $WORKSPACE/LEAF_Request_Portal/globals.php
sed -i  "s/LRP_DB_NAME/$LRP_DB_NAME/g" $WORKSPACE/LEAF_Request_Portal/globals.php
sed -i  "s/LRP_USERNAME/$LRP_USERNAME/g" $WORKSPACE/LEAF_Request_Portal/globals.php
sed -i  "s/LRP_PASSWORD/$LRP_PASSWORD/g" $WORKSPACE/LEAF_Request_Portal/globals.php

#Rename config file 
cp $WORKSPACE/LEAF_Request_Portal/db_config-example.php $WORKSPACE/LEAF_Request_Portal/db_config.php

#replace information in Leaf Reqeust portal dbconfig
sed -i  "s/LRP_SERVER_HOSTNAME/$LRP_SERVER_HOSTNAME/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_DATABASE_NAME/$LRP_DATABASE_NAME/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_DATABASE_USERNAME/$LRP_DATABASE_USERNAME/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_DATABASE_PASSWORD/$LRP_DATABASE_PASSWORD/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneSERVER_HOSTNAME/$LRP_phoneSERVER_HOSTNAME/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneDATABASE_NAME/$LRP_phoneDATABASE_NAME/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneDATABASE_USERNAME/$LRP_phoneDATABASE_USERNAME/g" $WORKSPACE/LEAF_Request_Portal/db_config.php
sed -i  "s/LRP_phoneDATABASE_PASSWORD/$LRP_phoneDATABASE_PASSWORD/g" $WORKSPACE/LEAF_Request_Portal/db_config.php

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

#cp package.json package.json.bak
#/usr/bin/perl -i -pe "s|%%NAME%%|$APP_NAME|" package.json
#/usr/bin/perl -i -pe "s|%%VERSION%%|$APP_VERSION|" package.json

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

# Set GEM_HOME location to local, project directory
#WORKSPACE="$scriptPath"
#export GEM_HOME=$WORKSPACE/.gems
#export GEM_PATH=$GEM_HOME:$GEM_PATH
#export PATH=$GEM_HOME/bin:$WORKSPACE/bin:$PATH

#npm install || { echo "FATAL: Failed on 'npm install'";
#    rm package.json
#    mv package.json.bak package.json
#    exit 1;
#}

#gem install bundler || { echo "FATAL: Failed on 'gem install bundler'";
    # restore the changed files
#    rm package.json
#    mv package.json.bak package.json
#    exit 1;
#}

#bundle update || { echo "FATAL: Failed on 'bundle update'";
    # restore the changed files
#    rm package.json
#    mv package.json.bak package.json
#    exit 1;
#}

#bundle install || { echo "FATAL: Failed on 'bundle install'";
    # restore the changed files
#    rm package.json
#    mv package.json.bak package.json
#    exit 1;
#}

#if [ "$BUILD_NUMBER" = "SNAPSHOT" ]; then
 #   grunt build:dev || { echo "FATAL: Failed on 'grunt build:dev'";
        # restore the changed files
  #      rm package.json
   #     mv package.json.bak package.json
 #       exit 1;
 #   }
#else
 #   grunt build || { echo "FATAL: Failed on 'grunt build'";
        # restore the changed files
  #      rm package.json
  #      mv package.json.bak package.json
   #     exit 1;
 #   }
#fi

# Unit Tests
#printf "\n\n**** Mandatory: Testing ********************\n"
#grunt karma || { echo "FATAL: Failed on 'grunt karma'";
    # restore the changed files
#    rm package.json
#    mv package.json.bak package.json
#    exit 1;
#}

# Build Artifact Production
printf "\n\n**** Optional: Producing Build Artifacts ********************\n\n"

# remove temp package.json and replace it with our backup
#rm package.json
#mv package.json.bak package.json

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
#cp -R LEAF_Nexus $STAGING_DIR
#cp -R LEAF_Nexus_Tests $STAGING_DIR
#cp -R LEAF_Request_Portal $STAGING_DIR
cp app.yml $STAGING_DIR
cp app.env $STAGING_DIR
cp .dockerignore $STAGING_DIR
cp Dockerfile $STAGING_DIR
#cp docker-leaf-compose.yml $STAGING_DIR
cp docker-compose-fortify.yml $STAGING_DIR

# Set DTR for Docker - Perform against ALL Dockerfiles in your project
/usr/bin/perl -i -pe "s|%%DTR_PREFIX%%|$DTR_PREFIX|" $STAGING_DIR/Dockerfile || { echo "FATAL: Could not set DTR Prefix"; exit 1; }
/usr/bin/perl -i -pe "s|%%DTR_ORG%%|$DTR_ORG|" $STAGING_DIR/Dockerfile || { echo "FATAL: Could not set DTR Ogranization"; exit 1; }
/usr/bin/perl -i -pe "s|%%CONTEXT_ROOT%%|$CONTEXT_ROOT|" $STAGING_DIR/Dockerfile || { echo "FATAL: Could not set Context Root"; exit 1; }
/usr/bin/perl -i -pe "s|%%CONTEXT_VERSION%%|$CONTEXT_VERSION|" $STAGING_DIR/Dockerfile || { echo "FATAL: Could not set Context Version"; exit 1; }

#rm "${BUILD_DIR}/_temp-resource-directory.json"

ARTIFACT="${BUILD_DIR}/${JOB_NAME}.BUILD-${BUILD_NUMBER}.tar.gz"
printf "${ARTIFACT}=========================="
printf "Building application artifact ${ARTIFACT}...\n\n"
tar -C $STAGING_DIR -zcvf $ARTIFACT . || { echo "FATAL: Failed on 'Artifact tar''"; exit 1; }
cp $ARTIFACT .

printf "\n\n\n\n**** COMPLETED BUILD ********************\n\n"