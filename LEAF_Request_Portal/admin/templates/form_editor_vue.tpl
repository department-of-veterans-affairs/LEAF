<div id="vue-formeditor-app">
    <mod-form-menu></mod-form-menu>
    <div style="display:flex; max-width: 2000px; margin: auto;">
        <!-- CATEGORY BROWSER / RESTORE FIELDS -->
        <template v-if="restoringFields===false">
            <div v-if="currCategoryID===null && appIsLoadingCategoryList === false" id="formEditor_content">
                <!-- secure form section -->
                <div v-show="showCertificationStatus" id="secure_forms_info" style="padding: 8px; background-color: #d00; margin-bottom:1em;">
                    <span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span>
                    <a id="secureBtn" class="buttonNorm">View Details</a>
                </div>
                <!-- form broswer -->
                <div id="forms" style="display:flex; flex-wrap:wrap">
                    <category-card v-for="c in activeCategories" :categories-record="c" :key="c.categoryID"></category-card>
                </div>
                <hr style="margin-top: 32px; border-top:1px solid #556;" aria-label="Not associated with a workflow" />
                <p>Not associated with a workflow:</p>
                <div id="forms_inactive" style="display:flex; flex-wrap:wrap">
                    <category-card v-for="c in inactiveCategories" :categories-record="c" :key="c.categoryID"></category-card>
                </div>
            </div>
            <!-- SPECIFIC CATEGORY / FORM CONTENT -->
            <div v-else id="form_content_view">
                <form-view-controller v-if="currCategoryID !== null && appIsLoadingCategoryList === false"
                    :key="currentCategorySelection.categoryID + String(indicatorCountSwitch)"
                    orgchart-path='<!--{$orgchartPath}-->'>
                </form-view-controller>
            </div>
        </template>
        <restore-fields v-else></restore-fields>
    </div>
    <!-- DIALOGS -->
    <leaf-form-dialog v-if="showFormDialog" :has-dev-console-access='<!--{$hasDevConsoleAccess}-->'>  
        <template #dialog-content-slot>
        <component :is="dialogFormContent" :ref="dialogFormContent"></component>
        </template>
    </leaf-form-dialog>
</div>

<div id="LEAF_conditions_editor"></div><!-- vue IFTHEN app mount -->

<script>
//variables used within this scope, type, and approx. locations of def/redef (if applicable)
const CSRFToken = '<!--{$CSRFToken}-->';

let postRenderFormBrowser;          //func @ ~184
let portalAPI;                      //@ready

let vueData = {
    formID: 0,
    indicatorID: 0,
    updateIndicatorList: false
}
</script>

<script src="https://unpkg.com/vue@3"></script> <!--DEV -->
<!--<script src="../../libs/js/vue3/vue.global.prod.js"></script>-->
<script src="../js/vue_conditions_editor/LEAF_conditions_editor.js"></script>
<link rel="stylesheet" href="../js/vue_conditions_editor/LEAF_conditions_editor.css" />

<script type="text/javascript" src="../../libs/js/vue-dest/LEAF_FormEditor_main_build.js" defer></script>


<script>
/**
 * Purpose: Remove specific Indicator Privileges
 * @param indicatorID
 * @param groupID
 */
function removeIndicatorPrivilege(indicatorID, groupID) {
    portalAPI.FormEditor.removeIndicatorPrivilege(
        indicatorID,
        groupID,
        function (success) {
            editIndicatorPrivileges(indicatorID);
        },
        function (error) {
            editIndicatorPrivileges(indicatorID);
            console.log(error);
        }
    );
}
/**
 * Purpose: Add specific Indicator Privileges
 * @param indicatorID
 */
function addIndicatorPrivilege(indicatorID, indicatorName = '') {
    dialog.setTitle('Edit Privileges');
    dialog.setContent('Add privileges to the <b>'+ indicatorName +'</b> form:<div id="groups"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=system/groups',
        success: function(res) {
            let buffer = '<select id="groupID">';
            buffer += '<option value="1">System Administrators</option>';
            for(let i in res) {
                buffer += '<option value="'+ res[i].groupID +'">'+ res[i].name +'</option>';
            }
            buffer += '</select>';
            $('#groups').html(buffer);
            dialog.indicateIdle();
        },
        cache: false
    });
    dialog.setSaveHandler(function() {
        portalAPI.FormEditor.setIndicatorPrivileges(
            indicatorID,
            [$('#groupID').val()],
            function(results) {
                dialog.hide();
                editIndicatorPrivileges(indicatorID);
            },
            function (error) {
                console.log('an error has occurred: ', error);
                dialog.hide();
                editIndicatorPrivileges(indicatorID);
            }
        );
    });
    dialog.show();
}
/**
 * Purpose: Edit exisitng Indicator Privileges
 * @param indicatorID
 */
function editIndicatorPrivileges(indicatorID) {
    dialog_simple.setContent('<h2>Special access restrictions for this field</h2>'
                            + '<p>These restrictions will limit view access to the request initiator and members of any groups you specify.</p>'
                            + '<p>Additionally, these restrictions will only allow the groups specified below to apply search filters for this field.</p>'
                            + 'All others will see "[protected data]".<br /><div id="indicatorPrivs"></div>');
    dialog_simple.indicateBusy();

    portalAPI.FormEditor.getIndicator(
        indicatorID,
        function(indicator) {
            const indicatorName= indicator[indicatorID]?.name;

            dialog_simple.setTitle('Edit Indicator Read Privileges - ' + indicatorID);

            portalAPI.FormEditor.getIndicatorPrivileges(indicatorID,
                function (groups) {
                    let buffer = '<ul>';
                    let count = 0;
                    for (let group in groups) {
                        if (groups[group].id !== undefined) {
                            buffer += '<li>' + groups[group].name + ' [ <a href="#" tabindex="0" onkeypress="onKeyPressClick(event);" onclick="removeIndicatorPrivilege(' + indicatorID + ',' + groups[group].id + ');">Remove</a> ]</li>';
                            count++;
                        }
                    }
                    buffer += '</ul>';
                    buffer += `<span tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="addIndicatorPrivilege(${indicatorID},'${indicatorName}');">Add Group</span>`;
                    let statusMessage = "Special access restrictions are not enabled. Normal access rules apply.";
                    if(count > 0) {
                        statusMessage = "Special access restrictions are enabled!";
                    }
                    buffer += '<p>'+ statusMessage +'</p>';
                    $('#indicatorPrivs').html(buffer);
                    dialog_simple.indicateIdle();
                    dialog_simple.show();
                },
                function (error) {
                    $('#indicatorPrivs').html("There was an error retrieving the Indicator Privileges. Please try again.");
                    console.log(error);
                }
            );
        },
        function(err) {

        }
    );
}




$(function() {
    portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('../api/');
    portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

    <!--{if $referFormLibraryID != ''}-->
    //postRenderFormBrowser = function() { 
    //    $('.formLibraryID_<!--{$referFormLibraryID}-->')
    //    .animate({'background-color': 'yellow'}, 1000)
    //    .animate({'background-color': 'white'}, 1000)
    //    .animate({'background-color': 'yellow'}, 1000);
    //};
    <!--{/if}-->
});
</script>