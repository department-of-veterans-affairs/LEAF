#!/usr/bin/env bash

if [ "$1" = "install" ]
then
    npm i gulp
    npm i gulp-clean-css
    npm i gulp-uglify
    npm i gulp-concat
fi

echo 'Starting...'
# nexus
#gulp stylesNexusDefault
#gulp stylesNexusBrowseEmployee
#gulp stylesNexusBrowseGroup
#gulp stylesNexusBrowsePosition
#gulp stylesNexusViewGroup
#gulp stylesNexusViewPosition
#gulp stylesNexusViewEmployee
#gulp stylesNexusEditor
#gulp stylesNexusNavigator
gulp scriptsNexusDefault
gulp scriptsNexusBrowseEmployee
gulp scriptsNexusBrowseGroup
gulp scriptsNexusBrowsePosition
gulp scriptsNexusViewGroup
gulp scriptsNexusViewPosition
gulp scriptsNexusViewEmployee
gulp scriptsNexusEditor
gulp scriptsNexusNavigator
gulp sharedLEAFformScripts
gulp minifiedNexusStyle
gulp minifiedCodeMirrorStyles

# nexus admin
gulp nexusAdminModTemplatesReportsScripts
#gulp nexusAdminSetupMedCenterStyles
gulp nexusAdminSetupMedCenterScripts
gulp minifiedDialogueController
#gulp codeMirrorMergeStyles
gulp codeMirrorMergeScripts

# request
gulp scriptsRequestDefault
gulp scriptsRequestReports
gulp scriptsRequestInbox
gulp scriptsRequestView
gulp scriptsRequestPrintView
gulp minifiedDialogueController
gulp scriptsRequestIframePrintView

# request admin
gulp scriptsRequestAdminImportData
gulp minifiedXSSHelper
gulp sharedCodemirrorScripts
gulp sharedFormScripts

echo 'Done'