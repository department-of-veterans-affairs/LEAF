#!/bin/bash

export SCA_VM_OPTS=-Xmx800M

#cd
#cd workspace/$(cat workspace/workspaces.txt | tail -n 1)

#BUILD_NUMBER="${BUILD_NUMBER:-SNAPSHOT}"
#FILE_PREFIX="leaf-${BUILD_NUMBER}"
#ARTIFACT_ID="${FILE_PREFIX}"
#FPR="fortify/${FILE_PREFIX}.fpr"
#PDF="fortify/${FILE_PREFIX}.pdf"

# Using hardcoded values for now. Will update when integrate with pipeline
BUILD_NUMBER="1"
FILE_PREFIX="leaf"
ARTIFACT_ID="${FILE_PREFIX}"
FPR="$PWD/fort_report/${FILE_PREFIX}.fpr"
FPR_ORIG="$PWD/fort_report/${FILE_PREFIX}_orig.fpr"
FPR_MERGED="$PWD/fort_report/${FILE_PREFIX}_merged.fpr"
PDF="$PWD/fort_report/${FILE_PREFIX}.pdf"
PROPERTIES_FILE="$PWD/fort_report/fortify.properties"

MEMORY="-Xmx1600M -Xms1000M -Xss48M"

TEMPLATE="/workspace/fortify_templates/Security_Report.xml"
REPORT_OPTIONS="-showRemoved -showSuppressed -showHidden -verbose"

set -x
# enable debug

set -eo pipefail
# strict mode
#   script aborts if any command returns non-zero exit-code
#   http://redsymbol.net/articles/unofficial-bash-strict-mode/

# fortifyupdate 

echo --------------------------------------
echo Cleaning previous scan artifacts...
sourceanalyzer $MEMORY -b $ARTIFACT_ID -build-label $ARTIFACT_ID -clean -verbose 

echo --------------------------------------
echo Translating project...
sourceanalyzer -php-source-root libs/ $MEMORY $LAUNCHERSWITCHES -b $ARTIFACT_ID -build-label $ARTIFACT_ID @$PROPERTIES_FILE

echo --------------------------------------
echo Starting scan
sourceanalyzer $MEMORY $LAUNCHERSWITCHES -b $ARTIFACT_ID -build-label $ARTIFACT_ID -scan -f $FPR -verbose

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


