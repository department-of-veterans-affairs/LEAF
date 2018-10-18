'use strict';

var gulp = require('gulp');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
// var cleanCSS = require('gulp-clean-css');

// gulp tasks for nexus pages
gulp.task('build', gulp.series(
    function nexusScriptsDefault() {
        return gulp.src(['LEAF_Nexus/js/employeeSelector.js',
            'LEAF_Nexus/js/positionSelector.js',
            'LEAF_Nexus/js/groupSelector.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/orgchartForm.js'])
            .pipe(concat('default.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsBrowseEmployee() {
        return gulp.src(['LEAF_Nexus/js/employeeSelector.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/orgchartForm.js'])
            .pipe(concat('browseEmployee.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsBrowsePosition() {
        return gulp.src(['LEAF_Nexus/js/positionSelector.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/orgchartForm.js'])
            .pipe(concat('browsePosition.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsBrowseGroup() {
        return gulp.src(['LEAF_Nexus/js/groupSelector.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/orgchartForm.js'])
            .pipe(concat('browseGroup.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsViewGroup() {
        return gulp.src(['LEAF_Nexus/js/positionSelector.js',
            'LEAF_Nexus/js/orgchartForm.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/nationalEmployeeSelector.js'])
            .pipe(concat('viewGroup.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsViewPosition() {
        return gulp.src(['LEAF_Nexus/js/nationalEmployeeSelector.js',
            'LEAF_Nexus/js/orgchartForm.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/groupSelector.js',
            'LEAF_Nexus/js/positionSelector.js'])
            .pipe(concat('viewPosition.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsViewEmployee() {
        return gulp.src(['LEAF_Nexus/js/nationalEmployeeSelector.js',
            'LEAF_Nexus/js/orgchartForm.js',
            'LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/groupSelector.js',
            'LEAF_Nexus/js/positionSelector.js'])
            .pipe(concat('viewEmployee.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsEditor() {
        return gulp.src(['LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/ui/position.js',
            'LEAF_Nexus/js/positionSelector.js'])
            .pipe(concat('editor.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function nexusScriptsNavigator() {
        return gulp.src(['LEAF_Nexus/js/ui/position.js'])
            .pipe(concat('navigator.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function sharedLEAFformScripts() {
        return gulp.src(["libs/js/LEAF/formQuery.js",
            "libs/js/LEAF/formGrid.js"])
            .pipe(concat('LEAFform.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

// gulp tasks for nexus admin page scripts

    function nexusAdminModTemplatesReportsScripts() {
        return gulp.src(['LEAF_Nexus/js/dialogController.js',
            'libs/js/codemirror/lib/codemirror.js',
            'libs/js/codemirror/mode/xml/xml.js',
            'libs/js/codemirror/mode/javascript/javascript.js',
            'libs/js/codemirror/mode/css/css.js',
            'libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
            'libs/js/codemirror/addon/search/search.js',
            'libs/js/codemirror/addon/search/searchcursor.js',
            'libs/js/codemirror/addon/dialog/dialog.js',
            'libs/js/codemirror/addon/scroll/simplescrollbars.js',
            'libs/js/codemirror/addon/scroll/annotatescrollbar.js',
            'libs/js/codemirror/addon/search/matchesonscrollbar.js',
            'libs/js/codemirror/addon/display/fullscreen.js'])
            .pipe(concat('modTemplateReports.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

    function nexusAdminSetupMedCenterScripts() {
        return gulp.src(['LEAF_Nexus/js/dialogController.js',
            'LEAF_Nexus/js/nationalEmployeeSelector.js'])
            .pipe(concat('setupMedCenter.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function minifiedDialogueController() {
        return gulp.src(['LEAF_Nexus/js/dialogController.js'])
            .pipe(concat('dialogueController.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function codeMirrorMergeScripts() {
        return gulp.src(['libs/js/codemirror/addon/merge/merge.js'])
            .pipe(concat('merge.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

// Gulp tasks to minify Request Portal scripts for each page

    function scriptsRequestDefault() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'LEAF_Request_Portal/js/formQuery.js',
            'LEAF_Request_Portal/js/formSearch.js'])
            .pipe(concat('default.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function scriptsRequestReports() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'LEAF_Request_Portal/js/formQuery.js',
            'LEAF_Request_Portal/js/formSearch.js',
            'LEAF_Request_Portal/js/workflow.js',
            'LEAF_Request_Portal/js/lz-string/lz-string.min.js',
            'libs/js/LEAF/XSSHelpers.js',])
            .pipe(concat('reports.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function scriptsRequestInbox() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/workflow.js',
            'LEAF_Request_Portal/js/formGrid.js'])
            .pipe(concat('inbox.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function scriptsRequestView() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'libs/js/LEAF/XSSHelpers.js'])
            .pipe(concat('view.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function scriptsRequestPrintView() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/workflow.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'LEAF_Request_Portal/js/formQuery.js',
            'LEAF_Request_Portal/js/jsdiff.js',
            'libs/js/LEAF/XSSHelpers.js',
            'libs/jsapi/portal/LEAFPortalAPI.js',])
            .pipe(concat('printView.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function minifiedDialogueController() {
        return gulp.src(['LEAF_Request_Portal/js/dialogController.js',])
            .pipe(concat('dialogueController.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function minifiedXSSHelper() {
        return gulp.src(['libs/js/LEAF/XSSHelpers.js'])
            .pipe(concat('XSSHelper.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

    function sharedCodemirrorScripts() {
        return gulp.src(['libs/js/codemirror/lib/codemirror.js',
            'libs/js/codemirror/mode/xml/xml.js',
            'libs/js/codemirror/mode/javascript/javascript.js',
            'libs/js/codemirror/mode/css/css.js',
            'libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
            'libs/js/codemirror/addon/search/search.js',
            'libs/js/codemirror/addon/search/searchcursor.js',
            'libs/js/codemirror/addon/dialog/dialog.js',
            'libs/js/codemirror/addon/scroll/annotatescrollbar.js',
            'libs/js/codemirror/addon/search/matchesonscrollbar.js',
            'libs/js/codemirror/addon/display/fullscreen.js',])
            .pipe(concat('codemirror.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

    function sharedFormScripts() {
        return gulp.src(['libs/js/jquery/trumbowyg/plugins/colors/trumbowyg.colors.min.js',
            'libs/js/filesaver/FileSaver.min.js',
            'libs/js/codemirror/lib/codemirror.js',
            'libs/js/codemirror/mode/xml/xml.js',
            'libs/js/codemirror/mode/javascript/javascript.js',
            'libs/js/codemirror/mode/css/css.js',
            'libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
            'libs/js/codemirror/addon/display/fullscreen.js',
            'libs/js/LEAF/XSSHelpers.js',
            'libs/jsapi/portal/LEAFPortalAPI.js',])
            .pipe(concat('form.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

    function scriptsRequestIframePrintView() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/workflow.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'LEAF_Request_Portal/js/formQuery.js',
            'LEAF_Request_Portal/js/jsdiff.js',])
            .pipe(concat('iframePrintView.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function scriptsRequestShowFTEstatus() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/workflow.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'LEAF_Request_Portal/js/formQuery.js',])
            .pipe(concat('showFTEstatus.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

    function scriptsRequestReportsDefault() {
        return gulp.src(['LEAF_Request_Portal/js/form.js',
            'LEAF_Request_Portal/js/workflow.js',
            'LEAF_Request_Portal/js/formGrid.js',
            'LEAF_Request_Portal/js/formQuery.js',
            'LEAF_Request_Portal/js/formSearch.js',
            'libs/jsapi/nexus/LEAFNexusAPI.js',
            'libs/jsapi/portal/LEAFPortalAPI.js',
            'libs/jsapi/portal/model/FormQuery.js'])
            .pipe(concat('reportsDefault.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Request_Portal/minified/'))
    },

// gulp tasks to minify request portal admin scripts for each page

    function scriptsWorkflow() {
        return gulp.src(['LEAF_Nexus/js/groupSelector.js',
            'libs/js/LEAF/XSSHelpers.js',])
            .pipe(concat('workflow.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function scriptsRequestAdminImportData() {
        return gulp.src(['libs/js/LEAF/XSSHelpers.js',
            'libs/jsapi/nexus/LEAFNexusAPI.js',
            'libs/jsapi/portal/LEAFPortalAPI.js'])
            .pipe(concat('importData.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('libs/minified/'))
    },

    function minifiedNationalEmployeeSelector() {
        return gulp.src(['LEAF_Nexus/js/nationalEmployeeSelector.js'])
            .pipe(concat('nationalEmployeeSelector.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    },

    function scriptsModGroups() {
        return gulp.src(['LEAF_Nexus/js/nationalEmployeeSelector.js',
            "LEAF_Nexus/js/groupSelector.js"])
            .pipe(concat('modGroups.min.js'))
            .pipe(uglify())
            .pipe(gulp.dest('LEAF_Nexus/minified/'))
    })
);

// styles are WIP
// gulp.task('minifiedCodeMirrorStyles', function () {
//     return gulp.src(['libs/js/codemirror/lib/codemirror.css',
//         'libs/js/codemirror/addon/dialog/dialog.css',
//         'libs/js/codemirror/addon/scroll/simplescrollbars.css',
//         'libs/js/codemirror/addon/search/matchesonscrollbar.css',
//         'libs/js/codemirror/addon/display/fullscreen.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('minifiedCodeMirrorStyles.css'))
//         .pipe(gulp.dest('libs/minified/'))
// },
//
// gulp.task('nexusAdminSetupMedCenterStyles', function () {
//     return gulp.src(['LEAF_Nexus/admin/css/mod_groups.css', 'LEAF_Nexus/css/employeeSelector.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusAdminSetupMedCenterStyles.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },

// gulp.task('codeMirrorMergeStyles', function () {
//     return gulp.src(['libs/js/codemirror/addon/merge/merge.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('codeMirrorMergeStyles.css'))
//         .pipe(gulp.dest('libs/minified/'))
// },
//
// gulp.task('stylesNexusDefault', function () {
//     return gulp.src(['LEAF_Nexus/css/employeeSelector.css',
//         'LEAF_Nexus/css/view_employee.css',
//         'LEAF_Nexus/css/positionSelector.css',
//         'LEAF_Nexus/css/view_position.css',
//         'LEAF_Nexus/css/groupSelector.css',
//         'LEAF_Nexus/css/view_group.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesDefault.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusBrowseEmployee', function () {
//     return gulp.src(['LEAF_Nexus/css/groupSelector.css',
//         'LEAF_Nexus/css/view_group.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesBrowseEmployee.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusBrowsePosition', function () {
//     return gulp.src(['LEAF_Nexus/css/positionSelector.css',
//         'LEAF_Nexus/css/view_position.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesBrowsePosition.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusBrowseGroup', function () {
//     return gulp.src(['LEAF_Nexus/css/groupSelector.css',
//         'LEAF_Nexus/css/view_group.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesBrowseGroup.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusViewGroup', function () {
//     return gulp.src(['LEAF_Nexus/css/view_group.css',
//         'LEAF_Nexus/css/positionSelector.css',
//         'LEAF_Nexus/css/employeeSelector.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesViewGroup.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusViewPosition', function () {
//     return gulp.src(['LEAF_Nexus/css/view_position.css',
//         'LEAF_Nexus/css/employeeSelector.css',
//         'LEAF_Nexus/css/groupSelector.css',
//         'LEAF_Nexus/css/positionSelector.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesViewPosition.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusViewEmployee', function () {
//     return gulp.src(['LEAF_Nexus/css/view_employee.css',
//         'LEAF_Nexus/css/view_position.css',
//         'LEAF_Nexus/css/view_group.css',
//         'LEAF_Nexus/css/employeeSelector.css',
//         'LEAF_Nexus/css/groupSelector.css',
//         'LEAF_Nexus/css/positionSelector.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesViewEmployee.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusEditor', function () {
//     return gulp.src(['LEAF_Nexus/css/editor.css',
//         'LEAF_Nexus/css/positionSelector.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesEditor.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('stylesNexusNavigator', function () {
//     return gulp.src(['LEAF_Nexus/css/editor.css',
//         'LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(concat('nexusStylesNavigator.css'))
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
// gulp.task('minifiedNexusStyle', function () {
//     return gulp.src(['LEAF_Nexus/css/style.css'])
//         .pipe(cleanCSS())
//         .pipe(gulp.dest('LEAF_Nexus/minified/'))
// },
//
