'use strict';

var gulp = require('gulp');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var cleanCSS = require('gulp-clean-css');

//nexus switch case

gulp.task('stylesNexusDefault', function () {
  return gulp.src(['../LEAF_Nexus/css/employeeSelector.css',
      '../LEAF_Nexus/css/view_employee.css',
      '../LEAF_Nexus/css/positionSelector.css',
      '../LEAF_Nexus/css/view_position.css',
      '../LEAF_Nexus/css/groupSelector.css',
      '../LEAF_Nexus/css/view_group.css',
      '../LEAF_Nexus/css/style.css'])
      .pipe(cleanCSS())
      .pipe(concat('nexusStylesDefault.css'))
      .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('scriptsNexusDefault', function() {
    return gulp.src(['../LEAF_Nexus/js/employeeSelector.js',
        '../LEAF_Nexus/js/positionSelector.js',
        '../LEAF_Nexus/js/groupSelector.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/orgchartForm.js'])
        .pipe(concat('nexusScriptsDefault.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('scriptsNexusBrowseEmployee', function() {
    return gulp.src(['../LEAF_Nexus/js/employeeSelector.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/orgchartForm.js'])
        .pipe(concat('nexusScriptsBrowseEmployee.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusBrowseEmployee', function () {
    return gulp.src(['../LEAF_Nexus/css/groupSelector.css',
        '../LEAF_Nexus/css/view_group.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesBrowseEmployee.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('scriptsNexusBrowsePosition', function() {
    return gulp.src(['../LEAF_Nexus/js/positionSelector.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/orgchartForm.js'])
        .pipe(concat('nexusScriptsBrowsePosition.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusBrowsePosition', function () {
    return gulp.src(['../LEAF_Nexus/css/positionSelector.css',
        '../LEAF_Nexus/css/view_position.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesBrowsePosition.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

// Gulp task to minify JavaScript files
gulp.task('scriptsNexusBrowseGroup', function() {
    return gulp.src(['../LEAF_Nexus/js/groupSelector.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/orgchartForm.js'])
        .pipe(concat('nexusScriptsBrowseGroup.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusBrowseGroup', function () {
    return gulp.src(['../LEAF_Nexus/css/groupSelector.css',
        '../LEAF_Nexus/css/view_group.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesBrowseGroup.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusViewGroup', function () {
    return gulp.src(['../LEAF_Nexus/css/view_group.css',
        '../LEAF_Nexus/css/positionSelector.css',
        '../LEAF_Nexus/css/employeeSelector.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesViewGroup.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

// Gulp task to minify JavaScript files
gulp.task('scriptsNexusViewGroup', function() {
    return gulp.src(['../LEAF_Nexus/js/positionSelector.js',
        '../LEAF_Nexus/js/orgchartForm.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/nationalEmployeeSelector.js'])
        .pipe(concat('nexusScriptsViewGroup.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusViewPosition', function () {
    return gulp.src(['../LEAF_Nexus/css/view_position.css',
        '../LEAF_Nexus/css/employeeSelector.css',
        '../LEAF_Nexus/css/groupSelector.css',
        '../LEAF_Nexus/css/positionSelector.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesViewPosition.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

// Gulp task to minify JavaScript files
gulp.task('scriptsNexusViewPosition', function() {
    return gulp.src(['../LEAF_Nexus/js/nationalEmployeeSelector.js',
        '../LEAF_Nexus/js/orgchartForm.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/groupSelector.js',
        '../LEAF_Nexus/js/positionSelector.js'])
        .pipe(concat('nexusScriptsViewPosition.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusViewEmployee', function () {
    return gulp.src(['../LEAF_Nexus/css/view_employee.css',
        '../LEAF_Nexus/css/view_position.css',
        '../LEAF_Nexus/css/view_group.css',
        '../LEAF_Nexus/css/employeeSelector.css',
        '../LEAF_Nexus/css/groupSelector.css',
        '../LEAF_Nexus/css/positionSelector.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesViewEmployee.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

// Gulp task to minify JavaScript files
gulp.task('scriptsNexusViewEmployee', function() {
    return gulp.src(['../LEAF_Nexus/js/nationalEmployeeSelector.js',
        '../LEAF_Nexus/js/orgchartForm.js',
        '../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/groupSelector.js',
        '../LEAF_Nexus/js/positionSelector.js'])
        .pipe(concat('nexusScriptsViewEmployee.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusEditor', function () {
    return gulp.src(['../LEAF_Nexus/css/editor.css',
        '../LEAF_Nexus/css/positionSelector.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesEditor.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

// Gulp task to minify JavaScript files
gulp.task('scriptsNexusEditor', function() {
    return gulp.src(['../LEAF_Nexus/js/dialogController.js',
        '../LEAF_Nexus/js/ui/position.js',
        '../LEAF_Nexus/js/positionSelector.js'])
        .pipe(concat('nexusScriptsEditor.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('stylesNexusNavigator', function () {
    return gulp.src(['../LEAF_Nexus/css/editor.css',
        '../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusStylesNavigator.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('scriptsNexusNavigator', function() {
    return gulp.src(['../LEAF_Nexus/js/ui/position.js'])
        .pipe(concat('nexusScriptsNavigator.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('sharedLEAFformScripts', function() {
    return gulp.src(["../libs/js/LEAF/formQuery.js",
        "../libs/js/LEAF/formGrid.js"])
        .pipe(concat('sharedLEAFformScripts.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('minifiedNexusStyle', function () {
    return gulp.src(['../LEAF_Nexus/css/style.css'])
        .pipe(cleanCSS())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

// files for nexus admin switch case

gulp.task('minifiedCodeMirrorStyles', function () {
    return gulp.src(['../libs/js/codemirror/lib/codemirror.css',
        '../libs/js/codemirror/addon/dialog/dialog.css',
        '../libs/js/codemirror/addon/scroll/simplescrollbars.css',
        '../libs/js/codemirror/addon/search/matchesonscrollbar.css',
        '../libs/js/codemirror/addon/display/fullscreen.css'])
        .pipe(cleanCSS())
        .pipe(concat('minifiedCodeMirrorStyles.css'))
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('nexusAdminModTemplatesReportsScripts', function() {
    return gulp.src(['../LEAF_Nexus/js/dialogController.js',
        '../libs/js/codemirror/lib/codemirror.js',
        '../libs/js/codemirror/mode/xml/xml.js',
        '../libs/js/codemirror/mode/javascript/javascript.js',
        '../libs/js/codemirror/mode/css/css.js',
        '../libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
        '../libs/js/codemirror/addon/search/search.js',
        '../libs/js/codemirror/addon/search/searchcursor.js',
        '../libs/js/codemirror/addon/dialog/dialog.js',
        '../libs/js/codemirror/addon/scroll/simplescrollbars.js',
        '../libs/js/codemirror/addon/scroll/annotatescrollbar.js',
        '../libs/js/codemirror/addon/search/matchesonscrollbar.js',
        '../libs/js/codemirror/addon/display/fullscreen.js'])
        .pipe(concat('nexusAdminModTemplatesReportsScripts.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('nexusAdminSetupMedCenterStyles', function () {
    return gulp.src(['../LEAF_Nexus/admin/css/mod_groups.css', '../LEAF_Nexus/css/employeeSelector.css'])
        .pipe(cleanCSS())
        .pipe(concat('nexusAdminSetupMedCenterStyles.css'))
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('nexusAdminSetupMedCenterScripts', function() {
    return gulp.src(['../LEAF_Nexus/js/dialogController.js', '../LEAF_Nexus/js/nationalEmployeeSelector.js'])
        .pipe(concat('nexusAdminSetupMedCenterScripts.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('minifiedDialogueController', function() {
    return gulp.src(['../LEAF_Nexus/js/dialogController.js'])
        .pipe(concat('minifiedDialogueController.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Nexus/minified/'))
});

gulp.task('codeMirrorMergeStyles', function () {
    return gulp.src(['../libs/js/codemirror/addon/merge/merge.css'])
        .pipe(cleanCSS())
        .pipe(concat('codeMirrorMergeStyles.css'))
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('codeMirrorMergeScripts', function() {
    return gulp.src(['../libs/js/codemirror/addon/merge/merge.js'])
        .pipe(concat('codeMirrorMergeScripts.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

// Gulp tasks to minify Request Portal files

gulp.task('scriptsRequestDefault', function() {
    return gulp.src(['../LEAF_Request_Portal/js/form.js',
        '../LEAF_Request_Portal/js/formGrid.js',
        '../LEAF_Request_Portal/js/formQuery.js',
        '../LEAF_Request_Portal/js/formSearch.js'])
        .pipe(concat('scriptsRequestDefault.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});

gulp.task('scriptsRequestReports', function() {
    return gulp.src(['../LEAF_Request_Portal/js/form.js',
        '../LEAF_Request_Portal/js/formGrid.js',
        '../LEAF_Request_Portal/js/formQuery.js',
        '../LEAF_Request_Portal/js/formSearch.js',
        '../LEAF_Request_Portal/js/workflow.js',
        '../LEAF_Request_Portal/js/lz-string/lz-string.min.js',
        '../libs/js/LEAF/XSSHelpers.js',])
        .pipe(concat('scriptsRequestReports.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});

gulp.task('scriptsRequestInbox', function() {
    return gulp.src(['../LEAF_Request_Portal/js/form.js',
        '../LEAF_Request_Portal/js/workflow.js',
        '../LEAF_Request_Portal/js/formGrid.js'])
        .pipe(concat('scriptsRequestInbox.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});

gulp.task('scriptsRequestView', function() {
    return gulp.src(['../LEAF_Request_Portal/js/form.js',
        '../LEAF_Request_Portal/js/formGrid.js',
        '../libs/js/LEAF/XSSHelpers.js'])
        .pipe(concat('scriptsRequestView.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});

gulp.task('scriptsRequestPrintView', function() {
    return gulp.src(['../LEAF_Request_Portal/js/form.js',
        '../LEAF_Request_Portal/js/workflow.js',
        '../LEAF_Request_Portal/js/formGrid.js',
        '../LEAF_Request_Portal/js/formQuery.js',
        '../LEAF_Request_Portal/js/jsdiff.js',
        '../libs/js/LEAF/XSSHelpers.js',
        '../libs/jsapi/portal/LEAFPortalAPI.js',])
        .pipe(concat('scriptsRequestPrintView.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});

gulp.task('minifiedDialogueController', function() {
    return gulp.src(['../LEAF_Request_Portal/js/dialogController.js',])
        .pipe(concat('minifiedDialogueController.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});

gulp.task('scriptsRequestAdminImportData', function() {
    return gulp.src(['../libs/js/LEAF/XSSHelpers.js',
        '../libs/jsapi/nexus/LEAFNexusAPI.js',
        '../libs/jsapi/portal/LEAFPortalAPI.js'])
        .pipe(concat('scriptsRequestAdminImportData.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('minifiedXSSHelper', function() {
    return gulp.src(['../libs/js/LEAF/XSSHelpers.js'])
        .pipe(concat('minifiedXSSHelper.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('sharedCodemirrorScripts', function() {
    return gulp.src(['../libs/js/codemirror/lib/codemirror.js',
        '../libs/js/codemirror/mode/xml/xml.js',
        '../libs/js/codemirror/mode/javascript/javascript.js',
        '../libs/js/codemirror/mode/css/css.js',
        '../libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
        '../libs/js/codemirror/addon/search/search.js',
        '../libs/js/codemirror/addon/search/searchcursor.js',
        '../libs/js/codemirror/addon/dialog/dialog.js',
        '../libs/js/codemirror/addon/scroll/annotatescrollbar.js',
        '../libs/js/codemirror/addon/search/matchesonscrollbar.js',
        '../libs/js/codemirror/addon/display/fullscreen.js',])
        .pipe(concat('sharedCodemirrorScripts.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('sharedFormScripts', function() {
    return gulp.src(['../libs/js/jquery/trumbowyg/plugins/colors/trumbowyg.colors.min.js',
        '../libs/js/filesaver/FileSaver.min.js',
        '../libs/js/codemirror/lib/codemirror.js',
        '../libs/js/codemirror/mode/xml/xml.js',
        '../libs/js/codemirror/mode/javascript/javascript.js',
        '../libs/js/codemirror/mode/css/css.js',
        '../libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
        '../libs/js/codemirror/addon/display/fullscreen.js',
        '../libs/js/LEAF/XSSHelpers.js',
        '../libs/jsapi/portal/LEAFPortalAPI.js',])
        .pipe(concat('sharedFormScripts.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../libs/minified/'))
});

gulp.task('scriptsRequestIframePrintView', function() {
    return gulp.src(['../LEAF_Request_Portal/js/form.js',
        '../LEAF_Request_Portal/js/workflow.js',
        '../LEAF_Request_Portal/js/formGrid.js',
        '../LEAF_Request_Portal/js/formQuery.js',
        '../LEAF_Request_Portal/js/jsdiff.js',])
        .pipe(concat('scriptsRequestIframePrintView.js'))
        .pipe(uglify())
        .pipe(gulp.dest('../LEAF_Request_Portal/minified/'))
});
