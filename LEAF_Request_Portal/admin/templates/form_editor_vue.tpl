<div id="vue-formeditor-app">

    <mod-form-menu></mod-form-menu>

    <div style="display:flex; max-width: 1800px; margin: auto;">
        <!-- CATEGORY BROWSER WITH CARDS / RESTORE FIELDS -->
        <template v-if="restoringFields===false">
            <div v-if="currCategoryID===null && appIsLoadingCategoryList === false" id="formEditor_content"
                style="width: 100%; margin: 0 auto;">
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
        <component v-if="dialogContentIsComponent" :is="dialogFormContent" :ref="dialogFormContent"></component>
        <div v-else v-html="dialogFormContent"></div>
        </template>
    </leaf-form-dialog>
</div>

<div id="LEAF_conditions_editor"></div><!-- vue IFTHEN app mount -->

<script>
//variables used within this scope, type, and approx. locations of def/redef (if applicable)
const CSRFToken = '<!--{$CSRFToken}-->';

let postRenderFormBrowser;          //func @ ~2104
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
 * Purpose: Add Permissions to Form
 * @param categoryID
 */
function addPermission(categoryID) {
    let formTitle = categories[categoryID].categoryName == '' ? 'Untitled' : categories[categoryID].categoryName;
    dialog.setTitle('Edit Collaborators');
    dialog.setContent('Add collaborators to the <b>'+ formTitle +'</b> form:<div id="groups"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=system/groups',
        success: function(res) {
            let buffer = '<select id="groupID">';
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
        $.ajax({
            type: 'POST',
            url: '../api/?a=formEditor/_'+ categoryID +'/privileges',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
            	   groupID: $('#groupID').val(),
                   read: 1,
                   write: 1},
            success: function(res) {
            	dialog.hide();
                editPermissions();
            },
            cache: false
        });
    });
    dialog.show();
}
/**
 * Purpose: Remove Permissions from Form
 * @param groupID
 */
function removePermission(groupID) {
    $.ajax({
        type: 'POST',
        url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
        data: {CSRFToken: '<!--{$CSRFToken}-->',
        	   groupID: groupID,
        	   read: 0,
        	   write: 0},
        success: function(res) {
            editPermissions();
        }
    });
}
/**
 * Purpose: Edit existing Permissions
 */
function editPermissions() {
	let formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;

	dialog_simple.setTitle('Edit Collaborators - ' + formTitle);
	dialog_simple.setContent('<h2>Collaborators have access to fill out data fields at any time in the workflow.</h2><br />'
	                             + 'This is typically used to give groups access to fill out internal-use fields.<br />'
	                             + '<div id="formPrivs"></div>');
	dialog_simple.indicateBusy();

	$.ajax({
		type: 'GET',
		url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
		success: function(res) {
			let buffer = '<ul>';
			for(let i in res) {
				buffer += '<li>' + res[i].name + ' [ <a href="#" tabindex="0" onkeypress="onKeyPressClick(event);" onclick="removePermission(\''+ res[i].groupID +'\');">Remove</a> ]</li>';
			}
			buffer += '</ul>';
			buffer += '<span tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="addPermission(currCategoryID);" role="button">Add Group</span>';
			$('#formPrivs').html(buffer);
			dialog_simple.indicateIdle();
		},
		cache: false
	});
	dialog_simple.show();
}
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





/**
 * Purpose: Show Secure Form Info
 * @param res (settings)
 */
function renderSecureFormsInfo(res) {
    $('#formEditor_content').prepend('<div id="secure_forms_info" style="padding: 8px; background-color: #d00; display:none; margin-bottom:1em;" ></div>');
    $('#secure_forms_info').append('<span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span> ');
    $('#secure_forms_info').append('<a id="secureBtn" class="buttonNorm">View Details</a>');

    if(res['leafSecure'] >= 1) { // Certified
        $.when(fetchIndicators(), fetchLEAFSRequests(true)).then(function(indicators, leafSRequests) {
            console.log(indicators, leafSRequests); //all non DELETED ind and headers
            let mostRecentID = null;
            let newIndicator = false;
            let mostRecentDate = 0;

            for(let i in leafSRequests) {
                if(leafSRequests[i].recordResolutionData.lastStatus === 'Approved'
                    && leafSRequests[i].recordResolutionData.fulfillmentTime > mostRecentDate) {
                    mostRecentDate = leafSRequests[i].recordResolutionData.fulfillmentTime;
                    mostRecentID = i;
                }
            }
            $('#secureBtn').attr('href', '../index.php?a=printview&recordID='+ mostRecentID);
            let mostRecentTimestamp = new Date(parseInt(mostRecentDate)*1000); // converts epoch secs to ms
            // check for new indicators since certification
            for(let i in indicators) {
                if(new Date(indicators[i].timeAdded).getTime() > mostRecentTimestamp.getTime()) {
                    newIndicator = true;
                    break;
                }
            }
            // if newIndicator found, look for existing leaf-s request and assign proper next step
            if (newIndicator) {
                fetchLEAFSRequests(false).then(function(unresolvedLeafSRequests) {
                    if (unresolvedLeafSRequests.length == 0) { // if no new request, create one
                        $('#secureStatus').text('Forms have been modified.');
                        $('#secureBtn').text('Please Recertify Your Site');
                        $('#secureBtn').attr('href', '../report.php?a=LEAF_start_leaf_secure_certification');
                    } else {
                        let recordID = unresolvedLeafSRequests[Object.keys(unresolvedLeafSRequests)[0]].recordID;
                        $('#secureStatus').text('Re-certification in progress.');
                        $('#secureBtn').text('Check Certification Progress');
                        $('#secureBtn').attr('href', '../index.php?a=printview&recordID='+ recordID);
                    }
                    $('#secure_forms_info').show();
                });
            }
        });
    }
}
/**
 * Purpose: Check for Secure Form Certifcation
 * @param searchResolved
 * @returns { *|jQuery}
 */
function fetchLEAFSRequests(searchResolved) {
    let deferred = $.Deferred();
    let query = new LeafFormQuery();
    query.setRootURL('../');
    query.addTerm('categoryID', '=', 'leaf_secure');

    if (searchResolved) {
        query.addTerm('stepID', '=', 'resolved');
        query.join('recordResolutionData');
    } else {
        query.addTerm('stepID', '!=', 'resolved');
    }
    query.onSuccess(function(data) {
        deferred.resolve(data);
    });
    query.execute();
    return deferred.promise();
}
/**
 * Purpose: Get all Indicators on Form
 * @returns { *|jQuery}
 */
function fetchIndicators() {
    let deferred = $.Deferred();
    $.ajax({
        type: 'GET',
        url: '../api/form/indicator/list', //all non DELETED ind and headers
        cache: false,
        success: function(resp) {
            deferred.resolve(resp);
        }
    });
    return deferred.promise();
}
/**
 * Purpose: Get Form Secure Information
 */
function fetchFormSecureInfo() {
    $.ajax({
        type: 'GET',
        url: '../api/system/settings',
        cache: false
    })
    .then(function(res) {
        console.log(res)  //obj setting: data, from portal settings table
        renderSecureFormsInfo(res)
    });
}



$(function() {
    portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('../api/');
    portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

    fetchFormSecureInfo();

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