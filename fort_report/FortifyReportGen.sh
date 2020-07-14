#!/bin/bash

export SCA_VM_OPTS=-Xmx800M

# Contents of PROJECT_ID, VERSION_ID, and BUILD_ID will be present the published artifact

# SPRINT_ID is used to name the artifacts published to S3
PROJECT_ID="${SPRINT_ID}"
VERSION_ID="${GIT_BRANCH}_${GIT_COMMIT}"

FILE_PREFIX="leaf"
BUILD_ID="${FILE_PREFIX}"
FPR="$PWD/fort_report/${FILE_PREFIX}.fpr"
FPR_ORIG="$PWD/fort_report/${FILE_PREFIX}_orig.fpr"
FPR_MERGED="$PWD/fort_report/${FILE_PREFIX}_merged.fpr"
PDF="$PWD/fort_report/${FILE_PREFIX}.pdf"
PROPERTIES_FILE="$PWD/fort_report/fortify.properties"

MEMORY="-Xmx1600M -Xms1000M -Xss48M"
TEMPLATE="/workspace/fortify_templates/Security_Report.xml"
REPORT_OPTIONS="-showRemoved -showSuppressed -showHidden -verbose"
LAUNCHERSWITCHES="-build-label $BUILD_ID -build-version $VERSION_ID -build-project $PROJECT_ID"

set -x
# enable debug

set -eo pipefail
# strict mode
#   script aborts if any command returns non-zero exit-code
#   http://redsymbol.net/articles/unofficial-bash-strict-mode/

echo --------------------------------------
echo Cleaning previous scan artifacts...
sourceanalyzer $MEMORY -b $BUILD_ID -build-label $BUILD_ID -clean -verbose 

echo --------------------------------------
echo Translating project...
sourceanalyzer -php-source-root libs/ $MEMORY $LAUNCHERSWITCHES -b $BUILD_ID @$PROPERTIES_FILE

echo --------------------------------------
echo Starting scan
sourceanalyzer $MEMORY $LAUNCHERSWITCHES -b $BUILD_ID -scan -f $FPR -verbose

if [ -f $FPR_ORIG ]; then
echo --------------------------------------
echo Merging FPR...
FPRUtility -merge -project $FPR_ORIG -source $FPR -f $FPR_MERGED
fi

echo --------------------------------------
echo -e "\nGenerating PDF report...";
if [ -f $FPR_MERGED ]; then
        export FPR_SRC="$FPR_MERGED"
else
        export FPR_SRC="$FPR"
fi

ReportGenerator -format pdf -f $PDF -source "${FPR_SRC}" -template $TEMPLATE $REPORT_OPTIONS || true;


