<div class="leaf-width-100pct">
    <h2>Form Editor</h2>
    <div id="menu" style="float: left; width: 180px"></div>
    <div id="formEditor_content" style="margin-left: 184px; padding-left: 8px"></div>
</div>
<div id="LEAF_conditions_editor"></div><!-- vue IFTHEN app mount -->
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->

<script>
const orgchartPath = '<!--{$orgchartPath}-->';
let ifThenIndicatorID = 0; //used by conditions editor app.  set to specific indicatorID when the app is used, and reset to 0 when closed
/* update ifThen indicator ID and dispatch a click event to a hidden button on the conditions editor app to update the childID */
function updateVueData(indicatorID = 0) {
    ifThenIndicatorID = parseInt(indicatorID);
    document.getElementById('btn-vue-update-trigger').dispatchEvent(new Event("click"));
}

//variables used within this scope, type, and approx. locations of def/redef (if applicable)
const CSRFToken = '<!--{$CSRFToken}-->';
const gridBodyElement = 'div#container_indicatorGrid > div';
let currCategoryID = '';            //string, def @ ~1762, 1774, 1818, 1864, 2055
let indicatorEditing = {}           //object, def @ ~1261
let gridJSON = [];                  //array of objects, def @ ~1267
let postRenderFormBrowser;          //func @ ~2104
let categories = {};                //object, def @ ~1853
let dialog, dialog_confirm, dialog_simple;   //dialogController instances, @ready
let portalAPI;                      //@ready
let columns = 0;                    //number, def @ ~1268
</script>

<script src="<!--{$app_js_path}-->/vue3/vue.global.prod.js"></script>
<script src="../js/vue_conditions_editor/LEAF_conditions_editor.js"></script>
<link rel="stylesheet" href="../js/vue_conditions_editor/LEAF_conditions_editor.css" />


<script>

/**
 * Purpose: Check if an indicator is sensitive (needs to be masked)
 * @param indicator
 * @returns {number}
 */
function checkSensitive(indicator) {
    let result = 0;
    $.each(indicator, function( index, value )
    {
        if (parseInt(value.is_sensitive) === 1) {
            result = 1;
        } else if(result === 0 && !$.isEmptyObject(value.child)){
            result = checkSensitive(value.child);
        }
        if(result)
        {
            return false;
        }
    });
    return result;
}

/**
 * Purpose: Edit the form (or Sub form)
 * @param isSubForm
 */
function editProperties(isSubForm) {
    dialog.setTitle('Edit Properties');
    dialog.setContent('<table>\
                             <tr>\
                                 <td>Name</td>\
                                 <td><input id="name" type="text" maxlength="50"></input></td>\
                             </tr>\
                             <tr>\
                                 <td>Description</td>\
                                 <td><textarea id="description" maxlength="255"></textarea></td>\
                             </tr>\
                             <tr class="isSubForm">\
                                 <td>Workflow</td>\
                                 <td id="container_workflowID"></td>\
                             </tr>\
                             <tr class="isSubForm">\
                                 <td>Need to Know mode <img src="../dynicons/?img=emblem-notice.svg&w=16" title="When turned on, the people associated with the workflow are the only ones who have access to view the form.  Forced on if form contains sensitive information."></td>\
                                 <td><select id="needToKnow"><option value="0">Off</option><option value="1">On</option></select></td>\
                             </tr>\
                             <tr class="isSubForm">\
                                 <td>Availability <img src="../dynicons/?img=emblem-notice.svg&w=16" title="When hidden, users will not be able to select this form as an option."></td>\
                                 <td><select id="visible"><option value="1">Available</option><option value="0">Hidden</option></select></td>\
                             </tr>\
                             <tr class="isSubForm">\
                                 <td>Sort Priority</td>\
                                 <td><input id="sort" type="number"></input></td>\
                             </tr>\
                             <tr class="isSubForm">\
                            	 <td>Type <img src="../dynicons/?img=emblem-notice.svg&w=16" title="Changes type of form."></td>\
                            	 <td><select id="formType"><option value="">Standard</option><option value="parallel_processing">Parallel Processing</option></select></td>\
                             </tr>\
                           </table>');
    $.ajax({
        type: 'GET',
        url: '../api/form/_' + currCategoryID,
        success: function(res) {
            if(res.length > 0) {
                if(checkSensitive(res) === 1) {
                    $("#needToKnow option[value='0']").remove();
                    $("#needToKnow option[value='1']").html('Forced on because sensitive fields are present');
                }
            }
        }
    });
    $('#name').val(categories[currCategoryID].categoryName);
    $('#description').val(categories[currCategoryID].categoryDescription);
    $('#workflowID').val(categories[currCategoryID].workflowID);
    $('#needToKnow').val(categories[currCategoryID].needToKnow);
    $('#visible').val(categories[currCategoryID].visible);
    $('#sort').val(categories[currCategoryID].sort);
    $('#formType').val(categories[currCategoryID].type);
    if(isSubForm) {
        $('.isSubForm').css('display', 'none');
    }

    dialog.show();

    // load workflow data
    dialog.indicateBusy();
    $.ajax({
        type: 'GET',
        url: '../api/workflow',
        success: function(res) {
            if(res.length > 0) {
                let buffer = '<select id="workflowID">';
                buffer += '<option value="0">No Workflow</option>';
                for(let i in res) {
                    if(res[i].workflowID > 0) {
                        buffer += '<option value="'+ res[i].workflowID +'">'+ res[i].description +' (ID: #'+ res[i].workflowID +')</option>';
                    }
                }
                buffer += '</select>';
                $('#container_workflowID').html(buffer);
                $('#workflowID').val(categories[currCategoryID].workflowID);
            }
            else {
                $('#container_workflowID').html('<span style="color: red">A workflow must be set up first</span>');
            }
            dialog.indicateIdle();
        },
        error: function(err) {
            console.error(err?.responseText);
        },
        cache: false
    });

    dialog.setSaveHandler(function() {
        let calls = [];
        let nameChanged = (categories[currCategoryID].categoryName || "") !== $('#name').val();
        let descriptionChanged  = (categories[currCategoryID].categoryDescription || "") !== $('#description').val();
        let workflowChanged  = +categories[currCategoryID].workflowID !== +$('#workflowID').val();
        let needToKnowChanged = +categories[currCategoryID].needToKnow !== +$('#needToKnow').val();
        let sortChanged = +categories[currCategoryID].sort !== +$('#sort').val();
        let visibleChanged = +categories[currCategoryID].visible !== +$('#visible').val();
        let typeChanged = (categories[currCategoryID].type || "") !== $('#formType').val();

        if(nameChanged){
            calls.push($.ajax({
                type: 'POST',
                url: '../api/formEditor/formName',
                data: {name: $('#name').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    categories[currCategoryID].name = $('#name').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }

        if(descriptionChanged){
            calls.push($.ajax({
                type: 'POST',
                url: '../api/formEditor/formDescription',
                data: {description: $('#description').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    categories[currCategoryID].description = $('#description').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }

        if(workflowChanged){
            calls.push(
                $.ajax({
                type: 'POST',
                url: '../api/formEditor/formWorkflow',
                data: {workflowID: $('#workflowID').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if(res == false) {
                        alert('Workflow cannot be set because this form has been merged into another form');
                    }
                    categories[currCategoryID].workflowID = $('#workflowID').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }

        if(needToKnowChanged){
            calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/formEditor/formNeedToKnow',
                data: {needToKnow: $('#needToKnow').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    categories[currCategoryID].needToKnow = $('#needToKnow').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }

        if(sortChanged){
            calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/formEditor/formSort',
                data: {sort: $('#sort').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    categories[currCategoryID].sort = $('#sort').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }

        if(visibleChanged){
            calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/formEditor/formVisible',
                data: {visible: $('#visible').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    categories[currCategoryID].visible= $('#visible').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }

        if(typeChanged){
            calls.push(
                $.ajax({
                type: 'POST',
                url: '../api/formEditor/formType',
                data: {type: $('#formType').val(),
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    categories[currCategoryID].formType = $('#formType').val();
                },
                error: function(err) {
                    console.error(err?.responseText);
                }
            }));
        }
        $.when.apply(undefined, calls).then(function() {
            categories[currCategoryID].categoryName = $('#name').val();
            categories[currCategoryID].categoryDescription = $('#description').val();
            categories[currCategoryID].description = '';
            categories[currCategoryID].workflowID = $('#workflowID').val();
            categories[currCategoryID].needToKnow = $('#needToKnow').val();
            categories[currCategoryID].visible = $('#visible').val();
            categories[currCategoryID].type = $('#formType').val();
            categories[currCategoryID].sort = $('#sort').val();
            openContent('ajaxIndex.php?a=printview&categoryID='+ currCategoryID);
            dialog.hide();
        });
    });
}

/**
 * Purpose: Opens form content
 * @param url
 */
function openContent(url) {
    let isSubForm = categories[currCategoryID].parentID == '' ? false : true;
    let formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;
    let workflow = '';
    if(categories[currCategoryID].workflowID != 0) {
        workflow = categories[currCategoryID].description + ' (ID #' + categories[currCategoryID].workflowID + ')';
    } else {
        workflow = '<span style="color: red">No workflow. Users will not be able to select this form.</span>';
    }
    $("#formEditor_content").html('<div style="padding: 8px; border: 1px solid black; background-color: white">' +
    		                      '<div style="float: right"><div id="editFormData" tabindex="0" onkeydown="onKeyPressClick(event)" class="buttonNorm">Edit Properties</div><br /><div tabindex="0" id="editFormPermissions" onkeydown="onKeyPressClick(event)" onclick="editPermissions();" class="buttonNorm">Edit Collaborators</div></div>' +
    		                      '<div style="padding: 8px">' +
    		                          '<b aria-label="'+ formTitle +'" tabindex="0" title="categoryID: '+ currCategoryID +'">' + formTitle + '</b><br /><span tabindex="0">' +
    		                          categories[currCategoryID].categoryDescription +
    		                          '</span><br /><span tabindex="0" class="isSubForm">Workflow: ' + workflow + '</span>' +
    		                          '<br /><span tabindex="0"class="isSubForm">Need to Know mode: ' + (categories[currCategoryID].needToKnow == 1 ? 'On' : 'Off') + '</span>' +
    		                      '</div>' +
                                  '</div><br /><div id="formEditor_form" style="background-color: white"><div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="" /></div></div>');
    if(isSubForm) {
        $('.isSubForm').css('display', 'none');
    }

    $('#editFormData').on('click', function() {
        editProperties(isSubForm);
    });

    $('#editFormData').on('keyPress', function(event) {
        editProperties(event, isSubForm);
    });

    $.ajax({
        type: 'GET',
        url: url,
        dataType: 'text',  // IE9 issue
        success: function(res) {
            $('#formEditor_form').empty().html(res);
            updateVueData(0);
        },
        error: function(res) {
            $('#formEditor_form').empty().html(res);
        },
        cache: false
    });
}

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
        url: '../api/system/groups',
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
            url: '../api/formEditor/_'+ categoryID +'/privileges',
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
        url: '../api/formEditor/_'+ currCategoryID +'/privileges',
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
		url: '../api/formEditor/_'+ currCategoryID +'/privileges',
		success: function(res) {
			let buffer = '<ul>';
			for(let i in res) {
				buffer += '<li>' + res[i].name + ' [ <a href="#" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="removePermission(\''+ res[i].groupID +'\');">Remove</a> ]</li>';
			}
			buffer += '</ul>';
			buffer += '<span tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="addPermission(currCategoryID);" role="button">Add Group</span>';
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
function addIndicatorPrivilege(indicatorID, indicatorName = '[blank]') {
    dialog.setTitle(`Edit Privileges - ${indicatorID}`);
    dialog.setContent(`What group should have access to the following?<div style="max-width:500px; margin-top:0.25em"><b>${indicatorName}</b></div><hr/><div id="groups" style="margin: 0.25em 0"></div>`);
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/system/groups',
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
            let indicatorName = indicator[indicatorID]?.name || '[blank]';
            indicatorName = indicatorName.replace(/"/g, '&quot;').replace(/'/g, '\\\'');
            indicatorName = indicatorName.replaceAll('\n', '').trim();
            dialog_simple.setTitle('Edit Indicator Read Privileges - ' + indicatorID);
            portalAPI.FormEditor.getIndicatorPrivileges(indicatorID,
                function (groups) {
                    let buffer = '<ul>';
                    let count = 0;
                    for (let group in groups) {
                        if (groups[group].id !== undefined) {
                            buffer += '<li>' + groups[group].name + ' [ <a href="#" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="removeIndicatorPrivilege(' + indicatorID + ',' + groups[group].id + ');">Remove</a> ]</li>';
                            count++;
                        }
                    }
                    buffer += '</ul>';
                    buffer += `<span tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="addIndicatorPrivilege(${indicatorID},'${indicatorName}');">Add Group</span>`;
                    let statusMessage = "Special access restrictions are not enabled. Normal access rules apply.";
                    if(count > 0) {
                        statusMessage = "Special access restrictions are enabled!";
                    }
                    buffer += '<p style="margin-top: 1em">'+ statusMessage +'</p>';
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
 * Purpose: Generates Unique ID to track columns to update user input with grid format
 * @returns {string}
 */
function makeColumnID(){
    return "col_" + (((1+Math.random())*0x10000)|0).toString(16).substring(1);
}

/**
 * Purpose: common listener methods
 */
function onKeyPressClick(event){
    if(event.keyCode === 13) {
        $(event.target).trigger('click');
    }
}


/**
 * Purpose: returns template for the indicator modal
 * @param isEditingModal (bool) adds content associated with editing (vs new) to the template
 */
function getIndicatorModalTemplate(isEditingModal = false) {
    const parentArchDel = `<tr>
            <td>Parent Question ID</td>
            <td colspan="2"><div id="container_parentID"></div></td>
        </tr>
        <tr>
            <td>Archive</td>
            <td colspan="1"><input id="archived" name="disable_or_delete" type="checkbox" value="archived" onkeydown="onKeyPressClick(event)" /></td>
            <td style="width: 275px;">
                <span id="archived-warning" style="color: red; visibility: hidden;">
                This field will be archived.  It can be<br/>re-enabled by using <a href="?a=disabled_fields" target="_blank">Restore Fields</a>.
                </span>
            </td>
        </tr>
        <tr>
            <td>Delete</td>
            <td colspan="1"><input id="deleted" name="disable_or_delete" type="checkbox" value="deleted" onkeydown="onKeyPressClick(event)" /></td>
            <td style="width: 275px;">
                <span id="deletion-warning" style="color: red; visibility: hidden;">
                Deleted items can only be re-enabled<br/>within 30 days by using <a href="?a=disabled_fields" target="_blank">Restore Fields</a>.
                </span>
            </td>
        </tr>`;
    const advancedOptions = `<span id="button_advanced" class="buttonNorm" tabindex="0" onkeydown="onKeyPressClick(event)">Advanced Options</span>
        <div>
            <fieldset id="advanced" style="visibility: collapse; height: 0;"><legend>Advanced Options</legend>
                Template Variables:<br />
                <table class="table" style="border-collapse: inherit">
                    <tr>
                        <td><b>{{ iID }}</b></td>
                        <td>The indicatorID # of the current data field.</td>
                    </tr>
                    <tr>
                        <td><b>{{ recordID }}</b></td>
                        <td>The record ID # of the current request.</td>
                    </tr>
                    <tr>
                        <td><b>{{ data }}</b></td>
                        <td>The contents of the current data field as stored in the database.</td>
                    </tr>
                </table><br />
                html (for pages where the user can edit data):
                <button id="btn_codeSave_html" class="buttonNorm" title="Save Code">
                    <img id="saveIndicator" src="../dynicons/?img=media-floppy.svg&w=16" alt="" />
                    Save Code<span id="codeSaveStatus_html"></span>
                </button>
                <textarea id="html"></textarea><br />
                htmlPrint (for pages where the user can only read data):
                <button id="btn_codeSave_htmlPrint" class="buttonNorm" title="Save Code">
                    <img id="saveIndicator" src="../dynicons/?img=media-floppy.svg&w=16" alt="" />
                    Save Code<span id="codeSaveStatus_htmlPrint"></span>
                </button>
                <textarea id="htmlPrint"></textarea>
            </fieldset>
        </div>`;
    return `<fieldset><legend>Field Name</legend>
            <textarea id="name" style="width: 99%"></textarea>
            <button class="buttonNorm" id="rawNameEditor" style="display: none">Show formatted code</button>
            <button class="buttonNorm" id="advNameEditor">Advanced Formatting</button>
        </fieldset>
        <fieldset><legend>Short Label (Describe this field in 1-2 words)</legend>
            <input type="text" id="description" maxlength="50" />
        </fieldset>
        <fieldset><legend>Input Format</legend>
            <select id="indicatorType" style="margin-bottom:1em;">
                <option value="">None</option>
                <option value="text">Single line text</option>
                <option value="textarea">Multi-line text</option>
                <option value="grid">Grid (Table with rows and columns)</option>
                <option value="number">Numeric</option>
                <option value="currency">Currency</option>
                <option value="date">Date</option>
                <option value="radio">Radio (single select, multiple options)</option>
                <option value="checkbox">Checkbox (A single checkbox)</option>
                <option value="checkboxes">Checkboxes (Multiple Checkboxes)</option>
                <option value="multiselect">Multi-Select Dropdown</option>
                <option value="dropdown">Dropdown Menu (single select, multiple options)</option>
                <option value="fileupload">File Attachment</option>
                <option value="image">Image Attachment</option>
                <option value="orgchart_group">Orgchart Group</option>
                <option value="orgchart_position">Orgchart Position</option>
                <option value="orgchart_employee">Orgchart Employee</option>
                <option value="raw_data">Raw Data (for programmers)</option>
                <!-- <option value="signature">Signature</option> -->
            </select>
            <div id="container_indicatorSingleAnswer" style="display: none">Text for checkbox:<br/>
                <input type="text" id="indicatorSingleAnswer" />
            </div>
            <div id="container_indicatorMultiAnswer" style="display: none">One option per line:<br/>
                <textarea id="indicatorMultiAnswer" style="width: 80%; height: 150px"></textarea>
                <textarea style="display: none" id="format"></textarea>
            </div>
            <div id="container_indicatorGrid" style="display: none">
                <span style="position: absolute; color: transparent" aria-atomic="true" aria-live="polite" id="tableStatus" role="status"></span><br/>
                <button class="buttonNorm" onclick="addCells(\'column\')"><img src="../dynicons/?img=list-add.svg&w=16" style="height: 25px;"/>Add column</button><br/><br/>
                Columns:
                <div border="1" style="overflow-x: scroll; max-width: 100%;"></div>
            </div>
            <fieldset><legend>Default Answer</legend>
                <div id="default-answer"></div>
            </fieldset>
        </fieldset>
        <fieldset><legend>Attributes</legend>
            <table>
                <tr>
                    <td>Required</td>
                    <td colspan="2" style="width: 300px;"><input id="required" name="required" type="checkbox" onkeydown="onKeyPressClick(event)" /></td>
                </tr>
                </tr>
                    <td>Sensitive Data (PHI/PII)</td>
                    <td colspan="2"><input id="sensitive" name="sensitive" type="checkbox" onkeydown="onKeyPressClick(event)" /></td>
                </tr>
                <tr>
                    <td>Sort Priority</td>
                    <td colspan="2"><input id="sort" name="sort" type="number" style="width: 40px" /></td>
                </tr>
                ${isEditingModal ? parentArchDel : ''}
            </table>
        </fieldset>
        ${isEditingModal ? advancedOptions : ''}`;
}

/**
 * Purpose: Renders the UI for input entry for each format type
 * @param indFormat - indicator's format type
 * @formatOptionsStr - option values as string (when loading saved options)
 * @gridCols - number of grid columns (when loading saved options)
 */
function renderFormatEntryUI(indFormat, formatOptionsStr = '', gridCols = 0) {
    $('#container_indicatorGrid').css('display', 'none');
    $('#container_indicatorMultiAnswer').css('display', 'none');
    $('#container_indicatorSingleAnswer').css('display', 'none');
    $('#default-answer').html('<textarea id="default" style="width: 50%;"></textarea>');
    switch(indFormat?.toLowerCase()) {
        case 'grid':
            $('#container_indicatorGrid').css('display', 'block');
            makeGrid(gridCols);
            break;
        case 'checkbox':   //single option entry box
        case 'signature':
            $('#container_indicatorSingleAnswer').css('display', 'block');
            if (formatOptionsStr !== '') $('#indicatorSingleAnswer').val(formatOptionsStr);
            break;
        case 'orgchart_employee':
            $('#default-answer').html('<div id="default"></div>');
            empSel = new employeeSelector('default');
            empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
            empSel.rootPath = '<!--{$orgchartPath}-->/';
            empSel.outputStyle = 'micro';
            empSel.initialize();
            empSel.setSelectHandler(function () {
                $('#default').val(empSel.selectionData[empSel.selection].empUID);
                $('#default input.employeeSelectorInput').val('userName:' + empSel.selectionData[empSel.selection].userName);
            });
            break;
        case 'orgchart_group':
            $('#default-answer').html('<div id="default"></div>');
            let groupSel = new groupSelector('default');
            groupSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
            groupSel.basePath = '../';
            groupSel.setResultHandler(function() {
                if(groupSel.numResults == 0) {
                    groupSel.hideResults();
                }
                else {
                    groupSel.showResults();
                }

                // prevent services from showing up as search results
                for(let i in groupSel.jsonResponse) {
                    $('#' + groupSel.prefixID + 'grp' + groupSel.jsonResponse[i].groupID).attr('tabindex', '0');
                    if(groupSel.jsonResponse[i].tags.service != undefined) {
                        $('#' + groupSel.prefixID + 'grp' + groupSel.jsonResponse[i].groupID).css('display', 'none');
                    }
                }
            });
            groupSel.setSelectHandler(function() {
                $('#default').val(groupSel.selectionData[groupSel.selection].groupID);
                $('#default input.groupSelectorInput').val(String('group#' + groupSel.selectionData[groupSel.selection].groupID));
            });
            groupSel.initialize();

            break;
        case 'orgchart_position':
            $('#default-answer').html('<div id="default"></div>');
            let posSel = new positionSelector('default');
            posSel.apiPath = '<!--{$orgchartPath}-->/api/';
            posSel.rootPath = '<!--{$orgchartPath}-->/';
            posSel.enableEmployeeSearch();

            posSel.setSelectHandler(function() {
                $('#default').val(posSel.selection)
                $('#default input.positionSelectorInput').val('#'+posSel.selection);
            });
            posSel.setResultHandler(function() {
                $('#default').val(posSel.selection)
            });
            posSel.initialize();

            break;
        case 'radio':      //multiple option entry box
        case 'checkboxes':
        case 'multiselect':
        case 'dropdown':
            $('#container_indicatorMultiAnswer').css('display', 'block');
            if (formatOptionsStr !== '') $('#indicatorMultiAnswer').val(formatOptionsStr);
            break;
        default:
            break;
    }
}
/**
 * Purpose: adds listeners to indicator modal.
 * adds archive, del and advanced options if editing (vs new question)
 */
function addIndicatorModalListeners(isEditingModal = false) {
    //all indicator modals have format render, description, required, sensitive and raw/adv (text formatter)
    $('#indicatorType').on('change', event => renderFormatEntryUI(event.target.value));
    $('#required').on('click', function() {
        if($('#indicatorType').val() == '') {
            $('#required').prop('checked', false);
            alert('You can\'t mark a field as required if the Input Format is "None".');
        }
    });
    $('#sensitive').on('click', function() {
        if($('#indicatorType').val() == '') {
            $('#sensitive').prop('checked', false);
            alert('You can\'t mark a field as sensitive if the Input Format is "None".');
        }
    });
    $('#rawNameEditor').on('click', function() {
        $('#advNameEditor').css('display', 'inline');
        $('#rawNameEditor').css('display', 'none');
        $('#name').trumbowyg('destroy');
    });
    $('#advNameEditor').on('click', function() {
        $('#advNameEditor').css('display', 'none');
        $('#rawNameEditor').css('display', 'inline');
        $('#name').trumbowyg({
            resetCss: true,
            btns: ['formatting', 'bold', 'italic', 'underline', '|',
                'unorderedList', 'orderedList', '|',
                'link', '|',
                'foreColor', '|',
                'justifyLeft', 'justifyCenter', 'justifyRight']
        });
        $('.trumbowyg-box').css({
            'min-height': '130px'
        });
        $('.trumbowyg-editor, .trumbowyg-texteditor').css({
            'min-height': '100px',
            'height': '100px'
        });
    });
    if (isEditingModal === true) {  //archive, delete, advanced options
        $('#archived').on('change', function(event) {
            if($(this).is(':checked')) {
                $('#deleted').prop('checked', false);
                $('#deletion-warning').css('visibility','hidden');
                $('#archived-warning').css('visibility','visible');
            } else {
                $('#archived').prop('checked', false);
                $('#archived-warning').css('visibility','hidden');
            }
        });
        $('#deleted').on("change", function(event) {
            if($(this).is(':checked')) {
                $('#archived').prop('checked', false);
                $('#deletion-warning').css('visibility','visible');
                $('#archived-warning').css('visibility','hidden');
            } else {
                $('#deleted').prop('checked', false);
                $('#deletion-warning').css('visibility','hidden');
            }
        });
        $('#button_advanced').on('click', function() {
            if(<!--{$hasDevConsoleAccess}--> == 1) {
                $('#button_advanced').css('display', 'none');
                $('#advanced').css('height', 'auto');
                $('#advanced').css('visibility', 'visible');
                $('.table').css('border-collapse', 'collapse');
            } else {
                alert('Notice: Please go to Admin Panel -> LEAF Programmer to ensure continued access to this area.');
                $('#button_advanced').css('display', 'none');
                $('#advanced').css('visibility', 'visible');
            }
        });
    }
}

/**
 * Purpose: called in save handler callback for indicator modal.  uses #indicatorType val,
 * and option values from respective elements to update #format value for subsequent POST
 */
function setFormatElementValue() {
    const formatName = $('#indicatorType').val();

    let fullFormat = formatName;
    switch(formatName?.toLowerCase()) {
        case 'grid':
            let gridJSON = [];
            //gather column names and column types
            //if column type is dropdown, adds property.options
            $(gridBodyElement).find('div.cell').each(function() {
                let properties = new Object();
                if($(this).children('input:eq(0)').val() === 'undefined'){
                    properties.name = 'No title';
                } else {
                    properties.name = $(this).children('input:eq(0)').val();
                }
                properties.id = $(this).attr('id');
                properties.type = $(this).find('select[id^="grid_cell_type"]').val();
                if(properties.type !== undefined){
                    if(properties.type === 'dropdown'){
                        properties.options = gridDropdown($(this).find('textarea').val().replace(/,/g, ""));
                    }
                    if(properties.type === 'dropdown_file'){
                        properties.file = $(this).find('select[id^="dropdown_file_select"]').val();
                        properties.hasHeader = Boolean(+$(this).find('select[id^="dropdown_file_header_select"]').val());
                    }
                } else {
                    properties.type = 'textarea';
                }
                gridJSON.push(properties);
            });
            fullFormat += "\n" + JSON.stringify(gridJSON);
            break;
        case 'radio':
        case 'checkboxes':
        case 'multiselect':
        case 'dropdown':
            fullFormat += "\n" + formatIndicatorMultiAnswer($('#indicatorMultiAnswer').val());
            break;
        case 'signature':
        case 'checkbox':
            fullFormat += "\n" + $('#indicatorSingleAnswer').val();
            break;
        default:
            break;
    }
    $('#format').val(fullFormat);
}

/**
 * Purpose: Add a new question to Form
 * @param parentIndicatorID
 */
function newQuestion(parentIndicatorID = null) {
    const title = parentIndicatorID === null ? 'Adding New Question': `Adding Question to ${parentIndicatorID}`;
    dialog.setTitle(title);
    dialog.setContent(getIndicatorModalTemplate(false));
    addIndicatorModalListeners(false);
    dialog.show();
    dialog.setSaveHandler(function() {
    	let isRequired = $('#required').is(':checked') ? 1 : 0;
        let isSensitive = $('#sensitive').is(':checked') ? 1 : 0;
        if (isSensitive === 1) {
            $.ajax({
                type: 'POST',
                url: '../api/formEditor/formNeedToKnow',
                data: {
                    needToKnow: '1',
                    categoryID: currCategoryID,
                    CSRFToken: '<!--{$CSRFToken}-->'
                }
            });
            categories[currCategoryID].needToKnow = 1;
        }
        setFormatElementValue();
        $.ajax({
            type: 'POST',
            url: '../api/formEditor/newIndicator',
            data: {name: $('#name').val(),
            	format: $('#format').val(),
            	description: $('#description').val(),
            	default: $('#default').val(),
            	parentID: parentIndicatorID,
            	categoryID: currCategoryID,
            	required: isRequired,
                is_sensitive: isSensitive,
                CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if(res != null) {
                    if($('#sort').val() != '') {
                        $.ajax({
                            type: 'POST',
                            url: '../api/formEditor/' + res + '/sort',
                            data: {sort: $('#sort').val(),
                                CSRFToken: '<!--{$CSRFToken}-->'}
                        });
                    }
                }
                dialog.hide();
                openContent('ajaxIndex.php?a=printview&categoryID=' + currCategoryID);
            }
        });
    });
}

/**
 * Purpose: Update Input Name
 */
function updateNames(){
    $(gridBodyElement).children('div').each(function(i) {
        if (gridJSON[i] === undefined) {
            gridJSON.push(new Object);
        }
        gridJSON[i].name = $(this).children('input').val();
        gridJSON[i].id = gridJSON[i].id === undefined ? makeColumnID() : gridJSON[i].id;
    });
}
/**
 * Purpose: Add basic HTML input areas to the grid cell
 */
function gridCellBasicInputs(name = '', columnNumber = '', id = makeColumnID(), isNewRow = false) {
    return `<div tabindex="0" id="${id}" class="cell">
      <img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="moveLeft(event)" src="../dynicons/?img=go-previous.svg&w=16" title="Move column left" alt="" style="cursor: pointer;" />
      <img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="moveRight(event)" src="../dynicons/?img=go-next.svg&w=16" title="Move column right" alt="" style="cursor: pointer; display: ${isNewRow ? 'none;' : 'inline;'}" />
      </br>
      <span class="columnNumber">Column #${columnNumber}: </span>
      <img role="button" tabindex="0" onkeydown="onKeyPressClick(event);" onclick="deleteColumn(event)" src="../dynicons/?img=process-stop.svg&w=16" title="Delete column" alt="" style="cursor: pointer; vertical-align: middle;" />
      </br>&nbsp;
      <input type="text" value="${name}" onchange="updateNames();" />
      </br>&nbsp;</br>
      <label for="grid_cell_type_${columnNumber}" style="display: block; text-align: left;">Type: </label>
      <select id="grid_cell_type_${columnNumber}" style="width: 185px;" onchange="toggleDropDown(this.value, this, ${columnNumber});">
        <option value="text">Single line input</option>
        <option value="date">Date</option>
        <option value="dropdown">Drop Down</option>
        <option value="dropdown_file">Dropdown From File</option>
        <option value="textarea">Multi-line text</option>
      </select>`;
}
/**
 * Purpose: Make Grid for Input Option
 * @param columns
 */
function makeGrid(columns) {
    $(gridBodyElement).html('');
    if(columns === 0){
        gridJSON = [];
        columns = 1;
    }
    for (let i = 0; i < columns; i++) {
        if(gridJSON[i] === undefined){
            gridJSON.push(new Object());
        }
        let name = gridJSON[i].name === undefined ? 'No title' : gridJSON[i].name;
        let id = gridJSON[i].id === undefined ? makeColumnID() : gridJSON[i].id;
        $(gridBodyElement).append(gridCellBasicInputs(name, i + 1, id, false));
        if(columns === 1){
            rightArrows($(gridBodyElement + ' > div:last'), false);
            leftArrows($(gridBodyElement + ' > div:last'), false);
        } else {
            switch (i) {
                case 0:
                    leftArrows($(gridBodyElement + ' > div:last'), false);
                    break;
                case columns - 1:
                    rightArrows($(gridBodyElement + ' > div:last'), false);
                    break;
                default:
                    break;
            }
        }
        if(gridJSON[i].type !== undefined){
            $(gridBodyElement + '> div:eq(' + i + ') > select option[value="' + gridJSON[i].type + '"]').attr('selected', 'selected');
            if(gridJSON[i].type.toString() === 'dropdown'){
                if(gridJSON[i].options !== ""){
                    var options = gridJSON[i].options.join("\n").toString();
                } else {
                    var options = "";
                }
                $(gridBodyElement + ' > div:eq(' + i + ')').css('padding-bottom', '11px');
                if($(gridBodyElement + ' > div:eq(' + i + ') > span.dropdown').length === 0){
                    $(gridBodyElement + ' > div:eq(' + i + ')').append(
                        `<span class="dropdown">
                            <div>One option per line</div>
                            <textarea aria-label="Dropdown options, one option per line" style="width: 153px; resize: none;"value="">${options}</textarea>
                        </span>`
                    );
                }
            }
            if(gridJSON[i].type.toString() === 'dropdown_file') {
                if($(gridBodyElement + ' > div:eq(' + i + ') > div.dropdown_file').length === 0) {
                    const gridFile = gridJSON[i]?.file;
                    const hasHeader = gridJSON[i]?.hasHeader;
                    let options = '<option value="">Select a File</option>';
                    for (let f = 0; f < fileManagerTextFiles.length; f++) {
                        const filename = XSSHelpers.stripAllTags(fileManagerTextFiles[f]);
                        const attrSelected = gridFile === filename ? 'selected' : '';
                        options += `<option value=${filename} ${attrSelected}>${filename}</option>`
                    }
                    $(gridBodyElement + ' > div:eq(' + i + ')').append(`
                        <div class="dropdown_file" style="margin-top: 0.5rem;">
                            <label for="dropdown_file_select_${i}" style="display: block; text-align: left;">File (csv or txt format):</label>
                            <select id="dropdown_file_select_${i}" style="width: 185px; margin-bottom:0.25rem;">${options}</select>
                            <label for="dropdown_file_header_select_${i}" style="display: block; text-align: left;">Does file contain headers</label>
                            <select id="dropdown_file_header_select_${i}" style="width: 185px;">
                                <option value="0" ${hasHeader === false ? 'selected': ''}>No</option>
                                <option value="1" ${hasHeader === true ? 'selected': ''}>Yes</option>
                            </select>
                        </div>`
                    );
                }
            }
        }
    }
}

/**
 * Purpose: handle Dropdowns for normal and file Grid options, update aria status
 * @param type
 * @param cell
 * @param columnNumber
 */
function toggleDropDown(type, cell, columnNumber) {
    elJQDropDown = $(cell).parent().find('span.dropdown');
    elJQDropDownFile = $(cell).parent().find('div.dropdown_file');
    let ariaStatus = '';

    switch(type) {
        case 'dropdown':
            if(elJQDropDownFile.length === 1) {
                elJQDropDownFile.remove();
                ariaStatus += `Source file select removed.  `;
            }
            ariaStatus += `Dropdown options box added.  Make drop options in the space below, one option per line.`;
            $(cell).parent().append(
                `<span class="dropdown">
                    <div>One option per line</div>
                    <textarea aria-label="Dropdown options, one option per line" value="" style="width: 153px; resize:none"></textarea>
                </span>`
            );
            $('#tableStatus').attr('aria-label', ariaStatus);
            break;
        case 'dropdown_file':
            if(elJQDropDown.length === 1) {
                elJQDropDown.remove();
                ariaStatus += 'Dropdown options box removed. ';
            }
            let options = '<option value="">Select File</option>';
            for (let i = 0; i < fileManagerTextFiles.length; i++) {
                options += `<option value=${XSSHelpers.stripAllTags(fileManagerTextFiles[i])}>${fileManagerTextFiles[i]}</option>`
            }
            $(cell).parent().append(`
                <div class="dropdown_file" style="margin-top: 0.5rem;">
                    <label for="dropdown_file_select_${columnNumber}" style="display: block; text-align: left;">File (csv or txt format):</label>
                    <select id="dropdown_file_select_${columnNumber}" style="width: 185px; margin-bottom:0.25rem;">${options}</select>
                    <label for="dropdown_file_header_select_${columnNumber}" style="display: block; text-align: left;">Does file contain headers</label>
                    <select id="dropdown_file_header_select_${columnNumber}" style="width: 185px;">
                        <option value="0">No</option>
                        <option value="1">Yes</option>
                    </select>
                </div>`
            );
            ariaStatus += 'Source file select added.';
            $('#tableStatus').attr('aria-label', ariaStatus);
            break;
        default:
            if(elJQDropDown.length === 1) {
                elJQDropDown.remove();
                ariaStatus += 'Dropdown options box removed.';
            }
            if(elJQDropDownFile.length === 1) {
                elJQDropDownFile.remove();
                ariaStatus += 'Source file select removed.';
            }
            $('#tableStatus').attr('aria-label', ariaStatus);
            break;
	}
}

/**
 * Purpose: Left arrow for Grid
 * @param cell
 * @param toggle
 */
function leftArrows(cell, toggle){
    if(toggle){
        cell.find('[title="Move column left"]').css('display', 'inline');
    } else {
        cell.find('[title="Move column left"]').css('display', 'none');
    }
}

/**
 * Purpose: Right arrow for Grid
 * @param cell
 * @param toggle
 */
function rightArrows(cell, toggle){
    if(toggle){
        cell.find('[title="Move column right"]').css('display', 'inline');
    } else {
        cell.find('[title="Move column right"]').css('display', 'none');
    }
}

/**
 * Purpose: Add Cells for Grid Input Option
 */
function addCells(){
    columns = columns + 1;
    rightArrows($(gridBodyElement + ' > div:last'), true);
    $(gridBodyElement).append(gridCellBasicInputs('No Title', columns, makeColumnID(), true));
    $('#tableStatus').attr('aria-label', 'Column added, ' + $(gridBodyElement).children().length + ' total.');
    $(gridBodyElement + ' > div:last').focus();
    updateColumnNumbers();
}

/**
 * Purpose: Update the number of columns
 */
function updateColumnNumbers(){
    $(gridBodyElement).find('span.columnNumber').each(function(index) {
        $(this).html('Column #' + (index + 1) +':&nbsp;');
    });
}

/**
 * Purpose: Delete a column from Grid
 * @param event
 */
function deleteColumn(event){
    let column = $(event.target).closest('div');
    let tbody = $(event.target).closest('div').parent('div');
    let columnDeleted = parseInt($(column).index()) + 1;
    let focus;
    switch(tbody.find('div').length){
        case 1:
            alert('Cannot remove initial column.');
            break;
        case 2:
            column.remove();
            focus = $('div.cell:first');
            rightArrows(tbody.find('div'), false);
            leftArrows(tbody.find('div'), false);
            break;
        default:
            focus = column.next().find('[title="Delete column"]');
            if(column.find('[title="Move column right"]').css('display') === 'none'){
                rightArrows(column.prev(), false);
                leftArrows(column.prev(), true);
                focus = column.prev().find('[title="Delete column"]');
            }
            if(column.find('[title="Move column left"]').css('display') === 'none'){
                leftArrows(column.next(), false);
                rightArrows(column.next(), true);
            }
            column.remove();
            break;
    }
    columns = columns - 1;
    $('#tableStatus').attr('aria-label', 'Row ' + columnDeleted + ' removed, ' + $(tbody).children().length + ' total.');

    //stack clear
    setTimeout(function () {
        focus.focus();
    }, 0);
    updateColumnNumbers();
}

/**
 * Purpose: Move Column Right
 * @param event
 */
function moveRight(event){
    let column = $(event.target).closest('div');
    let nextColumnLast = column.next().find('[title="Move column right"]').css('display') === 'none';
    let first = column.find('[title="Move column left"]').css('display') === 'none';
    leftArrows(column, true);
    if(first){
        leftArrows(column.next(), false);
    }
    if(nextColumnLast){
        rightArrows(column, false);
        rightArrows(column.next(), true);
    }
    column.insertAfter(column.next());
    if(nextColumnLast){
        column.find('[title="Move column left"]').focus();
    } else {
        column.find('[title="Move column right"]').focus();
    }
    $('#tableStatus').attr('aria-label', 'Moved right to column ' + (parseInt($(column).index()) + 1) + ' of ' + column.parent().children().length);
    updateColumnNumbers();
}

/**
 * Purpose: Move Column Left
 * @param event
 */
function moveLeft(event){
    let column = $(event.target).closest('div.cell');
    let nextColumnFirst = column.prev().find('[title="Move column left"]').css('display') === 'none';
    let last = column.find('[title="Move column right"]').css('display') === 'none';
    rightArrows(column, true);
    if(last){
        rightArrows(column.prev(), false);
    }
    if(nextColumnFirst){
        leftArrows(column, false);
        leftArrows(column.prev(), true);
    }
    column.insertBefore(column.prev());
    if(nextColumnFirst){
        column.find('[title="Move column right"]').focus();
    } else {
        column.find('[title="Move column left"]').focus();
    }
    $('#tableStatus').attr('aria-label', 'Moved left to column ' + (parseInt($(column).index()) + 1) + ' of ' + column.parent().children().length);
    updateColumnNumbers();
}

/**
 * Purpose: Edit existing Indicator
 * @param indicatorID
 * @param series
 */
function getForm(indicatorID, series) {
    dialog.setTitle('Editing indicatorID: ' + indicatorID);
    dialog.setContent(getIndicatorModalTemplate(true));
    addIndicatorModalListeners(true);
    /**
     * Purpose: Save custom HTML Code
     */
    function saveCodeHTML() {
        $.ajax({
            type: 'POST',
            url: '../api/formEditor/' + indicatorID + '/html',
            data: {
                html: codeEditorHtml.getValue(),
                CSRFToken: '<!--{$CSRFToken}-->'
            },
            success: function(res) {
                const time = new Date().toLocaleTimeString();
                $('#codeSaveStatus_html').html('<br /> Last saved: ' + time);
            },
            error: function(err) {
                console.error(err?.responseText);
            }
        });
    }
    /**
     * Purpose: Save custom HTML Print Code
     */
    function saveCodeHTMLPrint() {
        $.ajax({
            type: 'POST',
            url: '../api/formEditor/' + indicatorID + '/htmlPrint',
            data: {
                htmlPrint: codeEditorHtmlPrint.getValue(),
                CSRFToken: '<!--{$CSRFToken}-->'
            },
            success: function(res) {
                const time = new Date().toLocaleTimeString();
                $('#codeSaveStatus_htmlPrint').html('<br /> Last saved: ' + time);
            }
        });
    }
    $('#btn_codeSave_html').on('click', saveCodeHTML);
    $('#btn_codeSave_htmlPrint').on('click', saveCodeHTMLPrint);
    let codeEditorHtml = CodeMirror.fromTextArea(document.getElementById("html"), {
        mode: "htmlmixed",
        lineNumbers: true,
        extraKeys: {
            "F11": function(cm) {
                cm.setOption("fullScreen", !cm.getOption("fullScreen"));
            },
            "Esc": function(cm) {
                if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
            },
            "Ctrl-S": function(cm) {
                saveCodeHTML();
            }
          }
    });
    let codeEditorHtmlPrint = CodeMirror.fromTextArea(document.getElementById("htmlPrint"), {
        mode: "htmlmixed",
        lineNumbers: true,
        extraKeys: {
            "F11": function(cm) {
                cm.setOption("fullScreen", !cm.getOption("fullScreen"));
            },
            "Esc": function(cm) {
                if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
            },
            "Ctrl-S": function(cm) {
                saveCodeHTMLPrint();
            }
          }
    });
    $('.CodeMirror').css('border', '1px solid black');

    dialog.show();
    dialog.indicateBusy();

    $.when(
        // populate indicator list for parentIDs
        $.ajax({
            type: 'GET',
            url: '../api/form/_' + currCategoryID + '/flat',
            success: function(res) {
                let buffer = '<select id="parentID" style="width: 300px">';
                buffer += '<option value="">None</option>';
                for(let i in res) {
                    if(indicatorID != i) {
                        buffer += '<option value="'+ i +'">' + i + ': ' + res[i][1].name +'</option>';
                    }
                }
                buffer += '</select>';
                $('#container_parentID').html(buffer);
            },
            cache: false
        })
    ).done(function() {
        $.ajax({
            type: 'GET',
            url: '../api/formEditor/indicator/' + indicatorID,
            success: function(res) {
                indicatorEditing = res[indicatorID]; //NOTE: indicatorEditing defined
                const formatName = res[indicatorID]?.format || '';
                const formatOptions = res[indicatorID]?.options || [];
                const formatOptionsStr = formatOptions.join('\n');
                if(formatName === 'grid'){
                    gridJSON = JSON.parse(formatOptions[0]);  //NOTE: gridJSON and columns defined
                    columns = gridJSON.length;
                }
                $('#name').html(res[indicatorID].name);
                // auto select advanced editor if it was previously used
                if(XSSHelpers.containsTags(res[indicatorID].name, ['<b>','<i>','<u>','<ol>','<li>','<br>','<p>','<td>'])) {
                    $('#advNameEditor').click();
                }
                //#format looks like it gets redefined on the save handler, might not be needed here
                $('#format').val(`${formatName}${formatOptionsStr}`);
                $('#indicatorType').val(formatName);
                $('#description').val(res[indicatorID].description);
                if(res[indicatorID].required == 1) {
                    $('#required').prop('checked', true);
                }
                if(res[indicatorID].is_sensitive == 1) {
                    $('#sensitive').prop('checked', true);
                }
                $('#parentID').val(res[indicatorID].parentID);
                $('#sort').val(res[indicatorID].sort);
                codeEditorHtml.setValue((res[indicatorID].html == null ? '' : res[indicatorID].html));
                codeEditorHtmlPrint.setValue((res[indicatorID].htmlPrint == null ? '' : res[indicatorID].htmlPrint));
                renderFormatEntryUI(formatName, formatOptionsStr, columns);
                $('#default').val(res[indicatorID].default);
                // this only works after all the required elements are rendered.
                const updateDefaultValue = (event) => {
                    const val = parseInt(event.currentTarget.value) || '';
                    if (val === '' || Number.isInteger(val)) {
                        $('#default').val(val);
                    }
                }
                if (formatName === 'orgchart_employee') {
                    $('#default-answer input.employeeSelectorInput').val(res[indicatorID].default ? '#' + res[indicatorID].default : '');
                    document.querySelector(`input.employeeSelectorInput`)?.addEventListener('change', updateDefaultValue);
                }
                if (formatName === 'orgchart_group') {
                    $('#default-answer input.groupSelectorInput').val(res[indicatorID].default ? 'group#' + res[indicatorID].default : '');
                    document.querySelector(`input.groupSelectorInput`)?.addEventListener('change', updateDefaultValue);
                }
                if (formatName === 'orgchart_position') {
                    $('#default-answer input.positionSelectorInput').val(res[indicatorID].default ? '#' + res[indicatorID].default : '');
                    document.querySelector(`input.positionSelectorInput`)?.addEventListener('change', updateDefaultValue);
                }
                $('#xhr').scrollTop(0);
                dialog.indicateIdle();
            },
            error: function(err) {
                console.error(err?.responseText);
            },
            cache: false
        });
    });
    dialog.setSaveHandler(function() {
        /*the below values are used by the indicators table*/
        let requiredIndicator = $('#required').is(':checked') ? 1 : 0;
        let sensitiveIndicator = $('#sensitive').is(':checked') ? 1 : 0;
        let archivedIndicator = $('#archived').is(':checked') ? 1 : 0;
        let deletedIndicator =  $('#deleted').is(':checked')  ? 2 : 0;

        if (sensitiveIndicator === 1) {
            $.ajax({
                type: 'POST',
                url: '../api/formEditor/formNeedToKnow',
                data: {needToKnow: '1',
                categoryID: currCategoryID,
                CSRFToken: '<!--{$CSRFToken}-->'}
            });
            categories[currCategoryID].needToKnow = 1;
        }
        setFormatElementValue();
        dialog.indicateBusy();

        // check if the user is trying to set an invalid parent ID
        if(indicatorID == $('#parentID').val()) {
            alert('Invalid parentID.');
            $('#parentID').val('');
            dialog.indicateIdle();
            return false;
        }

        let calls = [];
        let nameChanged = (indicatorEditing.name || "") !== $('#name').val();
        let options = (indicatorEditing?.options) ? '\n' + indicatorEditing?.options.join('\n') : '';
        let formatChanged = (indicatorEditing.format || "") + options !== $('#format').val();
        let descriptionChanged = (indicatorEditing.description || "") !== $('#description').val();
        let defaultChanged = (indicatorEditing.default || "") !== $('#default').val();
        let requiredChanged = +indicatorEditing.required !== +requiredIndicator;
        let sensitiveChanged = +indicatorEditing.is_sensitive !== +sensitiveIndicator;
        //+null (possible parentID value) and +'' (empty parentID input value) both eval to 0
        let parentIDChanged = +indicatorEditing.parentID !== +$("#parentID").val();
        let sortChanged = +indicatorEditing.sort !== +$("#sort").val();
        let htmlChanged = (indicatorEditing.html || "") !== codeEditorHtml.getValue();
        let htmlPrintChanged =  (indicatorEditing.htmlPrint || "") !== codeEditorHtmlPrint.getValue();

        if(nameChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/name',
                    data: {name: $('#name').val(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                })
            );
        }

        if(formatChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/format',
                    data: {
                        format: $('#format').val(),
                        CSRFToken: '<!--{$CSRFToken}-->'
                    },
                    success: function(res) {
                        if (res === 'size limit exceeded') {
                            alert(`The input format was not saved because it was too long.\nIf you require extended length, please submit a YourIT ticket.`);
                        }
                    },
                    error: function(response) {
                        console.log(response);
                    }
                })
            );
        }

        if(descriptionChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/description',
                    data: {description: $('#description').val(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                })
            );
        }

        if(defaultChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/default',
                    data: {default: $('#default').val(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                })
            );
        }

        if(requiredChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/required',
                    data: {required: requiredIndicator,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                }));
        }

        if(sensitiveChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/sensitive',
                    data: {is_sensitive: sensitiveIndicator,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                }));
        }

        if(archivedIndicator == 1){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/disabled',
                    data: {disabled: archivedIndicator,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                }));
        }
        if(deletedIndicator == 2) {
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/deleted',
                    data: {deleted: deletedIndicator,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                }));
        }

        if(parentIDChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/parentID',
                    data: {parentID: $('#parentID').val(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                            alert(res);
                        }
                    },
                    error: function(response) {
                        console.log(response);
                    }
                })
            );
        }

        if(sortChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/sort',
                    data: {sort: $('#sort').val(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
            }));
        }

        if(htmlChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/html',
                    data: {html: codeEditorHtml.getValue(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
            }));
        }

        if(htmlPrintChanged){
            calls.push(
                $.ajax({
                    type: 'POST',
                    url: '../api/formEditor/' + indicatorID + '/htmlPrint',
                    data: {htmlPrint: codeEditorHtmlPrint.getValue(),
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    error: function(response) {
                        console.log(response);
                    }
                }));
        }

    	$.when.apply(undefined, calls).then(function() {
   	    	openContent('ajaxIndex.php?a=printview&categoryID='+ currCategoryID);
   	    	dialog.hide();
   	     });
    });
}

/**
 * Purpose: Create Array for Dropdown Options
 * @param dropDownOptions
 * @returns {[]|*}
 */
function gridDropdown(dropDownOptions){
    if(dropDownOptions == null || dropDownOptions.length === 0){
        return dropDownOptions;
    }
    let uniqueNames = dropDownOptions.split("\n");
    let returnArray = [];
    uniqueNames = uniqueNames.filter(function(elem, index, self) {
        return index == self.indexOf(elem);
    });

    $.each(uniqueNames, function(i, el){
        if(el === "no") {
            uniqueNames[i] = "No";
        }
        returnArray.push(uniqueNames[i]);
    });

    return returnArray;
}

/**
 * Purpose: Create Array for Multi-Answer Text
 * @param multiAnswerValue
 * @returns {string|*}
 */
function formatIndicatorMultiAnswer(multiAnswerValue){
    if(multiAnswerValue == null || multiAnswerValue.length === 0){
        return multiAnswerValue;
    }
    let uniqueNames = multiAnswerValue.split("\n");
    uniqueNames = uniqueNames.filter(function(elem, index, self) {
       return index == self.indexOf(elem);
    });

    $.each(uniqueNames, function(i, el){
      if(el === "no") {
           uniqueNames[i] = "No";
        }
    });

    multiAnswerValue = uniqueNames.join("\n");
    return multiAnswerValue;
}

/**
 * Purpose: Merge Stapled Forms
 * @param categoryID
 */
function mergeForm(categoryID) {
    dialog.setTitle('Staple other form');
    dialog.setContent('Select a form to staple: <div id="formOptions"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/formStack/categoryList/all',
        success: function(res) {
            let buffer = '<select id="stapledCategoryID">';
            for(let i in res) {
            	if(res[i].workflowID == 0
            		&& res[i].categoryID != categoryID
            		&& res[i].parentID == '') {
            		buffer += '<option value="'+ res[i].categoryID +'">'+ res[i].categoryName +'</option>';
            	}
            }
            buffer += '</select>';
            $('#formOptions').html(buffer);
            dialog.indicateIdle();
        },
        cache: false
    });

    dialog.setSaveHandler(function() {
        $.ajax({
            type: 'POST',
            url: '../api/formEditor/_'+ categoryID +'/stapled',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
                   stapledCategoryID: $('#stapledCategoryID').val()},
            success: function(res) {
            	if(res == 1) {
                    dialog.hide();
                    mergeFormDialog(categoryID);
            	}
            	else {
            		alert(res);
            	}
            },
            cache: false
        });
    });

	dialog.show();

}

/**
 * Purpose: Remove Stapled Form
 * @param categoryID
 * @param stapledCategoryID
 */
function unmergeForm(categoryID, stapledCategoryID) {
    $.ajax({
        type: 'DELETE',
        url: '../api/formEditor/_'+ categoryID +'/stapled/_'+ stapledCategoryID + '?' +
            $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
        success: function() {
        	mergeFormDialog(categoryID);
        }
    });
}

/**
 * Purpose: Merge another Form Dialog Box
 * @param categoryID
 */
function mergeFormDialog(categoryID) {
    dialog_simple.setTitle('Staple other form');
    dialog_simple.setContent('Stapled forms will show up on the same page as the primary form.<div id="mergedForms"></div>');
    dialog_simple.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/formEditor/_'+ categoryID +'/stapled',
        success: function(res) {
            let buffer = '<ul>';
            for(let i in res) {
                buffer += '<li>' + res[i].categoryName + ' [ <a href="#" onkeydown="onKeyPressClick(event)" onclick="unmergeForm(\''+ categoryID +'\', \''+ res[i].stapledCategoryID +'\');">Remove</a> ]</li>';
            }
            buffer += '</ul>';
            buffer += '<span class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="mergeForm(\''+ categoryID +'\');" tabindex="0" role="button">Select a form to merge</span>';
            $('#mergedForms').html(buffer);
            dialog_simple.indicateIdle();
        },
        cache: false
    });

	dialog_simple.show();
}

/**
 * Purpose: Export Form
 * @param categoryID
 */
function exportForm(categoryID) {
	let packet = {};
	packet.form = {};
	packet.subforms = {};

	let defer = $.Deferred();
	let promise = defer.promise();
	promise = promise.then(function() {
		return $.ajax({
	        type: 'GET',
	        url: '../api/form/_' + categoryID + '/export',
	        success: function(res) {
	            packet.form = res;
	            packet.categoryID = categoryID;
	        }
	    });
	});

    promise = promise.then(function() {
        return $.ajax({
            type: 'GET',
            url: '../api/form/_' + categoryID + '/workflow',
            success: function(res) {
                packet.workflowID = res[0].workflowID;
            }
        });
    });

	for(let i in categories) {
        if(categories[i].parentID == categoryID) {
        	promise = promise.then(
            	function(subCategoryID) {
                    return $.ajax({
                        type: 'GET',
                        url: '../api/form/_' + subCategoryID + '/export',
                        success: function(res) {
                        	packet.subforms[subCategoryID] = {};
                        	packet.subforms[subCategoryID].name = categories[subCategoryID].categoryName;
                        	packet.subforms[subCategoryID].description = categories[subCategoryID].categoryDescription;
                            packet.subforms[subCategoryID].packet = res;
                        }
                    });
                }(categories[i].categoryID)
            );
        }
	}
	defer.resolve();

	promise.done(function() {
		let outPacket = {};
		outPacket.version = 1;
		outPacket.name = categories[categoryID].categoryName + ' (Copy)';
		outPacket.description = categories[categoryID].categoryDescription;
		outPacket.packet = packet;

		let outBlob = new Blob([JSON.stringify(outPacket).replace(/[^ -~]/g,'')], {type : 'text/plain'}); // Regex replace needed to workaround IE11 encoding issue
		saveAs(outBlob, 'LEAF_FormPacket_'+ categoryID +'.txt');
	});
}

/**
 * Purpose: Delete Form
 */
function deleteForm() {
	let formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;
	dialog_confirm.setTitle('Delete Form?');
	dialog_confirm.setContent('Are you sure you want to delete the <b>'+ formTitle +'</b> form?');

	dialog_confirm.setSaveHandler(function() {
		$.ajax({
			type: 'DELETE',
			url: '../api/formStack/_' + currCategoryID + '?' +
                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
			success: function(res) {
			    if(res != true) {
			        alert(res);
			    }
		        window.location.reload();
			}
		});
	});

	dialog_confirm.show();

}

/**
 * Purpose: Build Menu on Left Nav
 * @param categoryID
 */
function buildMenu(categoryID) {
	$('#menu').html('<div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="postRenderFormBrowser = null; showFormBrowser(); fetchFormSecureInfo();" role="button"><img src="../dynicons/?img=system-file-manager.svg&w=32" alt="" /> View All Forms</div><br />');
	$('#menu').append('<div tabindex="0" id="'+ categoryID +'" class="buttonNorm" onkeydown="onKeyPressClick(event)" role="button"><img src="../dynicons/?img=document-open.svg&w=32" alt="Open Form" />'+ categories[categoryID].categoryName +'</div>');
    $('#' + categoryID).on('click', function(categoryID) {
        return function() {
            $('#menu>div').removeClass('buttonNormSelected');
            $('#' + categoryID).addClass('buttonNormSelected');
            currCategoryID = categoryID;
            openContent('ajaxIndex.php?a=printview&categoryID='+ categoryID);
        };
    }(categoryID));

	for(let i in categories) {
		if(categories[i].parentID == categoryID) {
			$('#menu').append('<div tabindex="0" id="'+ categories[i].categoryID +'" onkeydown="onKeyPressClick(event)" class="buttonNorm" role="button"><img src="../dynicons/?img=text-x-generic.svg&w=32" alt="Open Form" /> '+ categories[i].categoryName +'</div>');
            $('#' + categories[i].categoryID).on('click', function(categoryID) {
                return function() {
                    $('#menu>div').removeClass('buttonNormSelected');
                    $('#' + categoryID).addClass('buttonNormSelected');
                    currCategoryID = categoryID;
                    openContent('ajaxIndex.php?a=printview&categoryID='+ categoryID);
                };
            }(categories[i].categoryID));
		}
	}

	$('#menu').append('<div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event);" onclick="createForm(\''+ categoryID +'\');" role="button"><img src="../dynicons/?img=list-add.svg&w=32" alt="" /> Add Internal-Use</div><br />');

    $('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event);" onclick="mergeFormDialog(\''+ categoryID +'\');" role="button"><img src="../dynicons/?img=tab-new.svg&w=32" alt="" /> Staple other form</div>\
                          <div id="stapledArea"></div><br />');

    $('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event);" onclick="viewHistory(\''+ categoryID +'\');" role="button"><img src="../dynicons/?img=appointment.svg&amp;w=32" alt="" /> View History</div>\
                        <div id="viewHistory"></div><br />');


    // show stapled forms in the menu area
    $.ajax({
        type: 'GET',
        url: '../api/formEditor/_'+ categoryID + '/stapled',
        success: function(res) {
            let buffer = '<ul>';
            for(let i in res) {
                buffer += '<li>'+ res[i].categoryName +'</li>';
            }
            buffer += '</ul>';
            if(res.length > 0) {
                $('#stapledArea').append(buffer);
            }
        }
    });


	$('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="exportForm(\''+ categoryID +'\');"role="button"><img src="../dynicons/?img=network-wireless.svg&w=32" alt="" /> Export Form</div><br />');
    $('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="deleteForm();"><img src="../dynicons/?img=user-trash.svg&w=32" alt="Delete Form" /> Delete this form</div>');
    $('#menu').append('<br /><br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="window.location = \'?a=disabled_fields\';" role="button"><img src="../dynicons/?img=user-trash-full.svg&w=32" alt="" /> Restore Fields</div>');
	$('#' + categoryID).addClass('buttonNormSelected');
}

/**
 * Purpose: Select a Form
 * @param categoryID
 */
function selectForm(categoryID) {
    currCategoryID = categoryID;
    buildMenu(categoryID);
    openContent('ajaxIndex.php?a=printview&categoryID='+ categoryID);
}

/**
 * Purpose: Show Form Nav
 */
function showFormBrowser() {
    window.location = '#';
    $('#menu').html('<div tabindex="0" role="button" class="buttonNorm" onkeydown="onKeyPressClick(event)" id="createFormButton" onclick="createForm();"><img src="../dynicons/?img=document-new.svg&w=32" alt="" /> Create Form</div><br />');
    $('#menu').append('<div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="formLibrary();" role="button"><img src="../dynicons/?img=system-file-manager.svg&w=32" alt="" /> LEAF Library</div><br />');
    $('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="importForm();" role="button"><img src="../dynicons/?img=package-x-generic.svg&w=32" alt="" /> Import Form</div><br />');
    $('#menu').append('<br /><br /><div tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="window.location = \'?a=disabled_fields\';" role="button"><img src="../dynicons/?img=user-trash-full.svg&w=32" alt="" /> Restore Fields</div>');
    $.ajax({
        type: 'GET',
        url: '../api/formStack/categoryList/all',
        success: function(res) {
            let buffer = '<div id="forms" style="padding: 8px"></div><br style="clear: both" /><hr style="margin-top: 32px" tabindex="0" aria-label="Not associated with a workflow" />Not associated with a workflow:<div id="forms_inactive" style="padding: 8px"></div>';
            $('#formEditor_content').html(buffer);
            for(let i in res) {
                categories[res[i].categoryID] = res[i];  //NOTE: categories set
                if(res[i].parentID == '') {
                    const formTitle = res[i].categoryName == '' ? 'Untitled' : res[i].categoryName;
                    const availability = res[i].visible == 1 ? '' : 'Hidden. Users cannot submit new requests.';
                    let needToKnow = '';
                    if(res[i].needToKnow == 1) {
                        needToKnow = ' <img style="position:absolute; right: 6px;" src="../dynicons/?img=emblem-readonly.svg&w=16" alt="" title="Need to know mode enabled" />';
                    }
                    let formActiveID = '';
                    if(res[i].workflowID > 0) {
                        formActiveID = '#forms';
                    }
                    else {
                        formActiveID = '#forms_inactive';
                    }
                    const workflow = res[i].description != null ? 'Workflow: ' + res[i].description : '';
                    $(formActiveID).append('<div tabindex="0"  onkeydown="onKeyPressClick(event)" class="formPreview formLibraryID_'+ res[i].formLibraryID +'" id="'+ res[i].categoryID +'" title="'+ res[i].categoryID +'">\
                            <div class="formPreviewTitle">'+ formTitle + needToKnow + '</div>\
                            <div class="formPreviewDescription">'+ res[i].categoryDescription +'</div>\
                            <div class="formPreviewStatus">'+ availability +'</div>\
                            <div class="formPreviewWorkflow">'+ workflow +'</div>\
                            </div>');
                    $('#' + res[i].categoryID).on('click', function(categoryID) {
                        return function() {
                            currCategoryID = categoryID;
                            buildMenu(categoryID);
                            window.location = '#' + categoryID;
                            openContent('ajaxIndex.php?a=printview&categoryID='+ categoryID);
                        };
                    }(res[i].categoryID));
                }
            }

            if(postRenderFormBrowser != undefined) {
                postRenderFormBrowser();
            }
        },
        cache: false
    });
}

/**
 * Purpose: Show Secure Form Info
 * @param res
 */
function renderSecureFormsInfo(res) {
    $('#formEditor_content').prepend('<div id="secure_forms_info" style="padding: 8px; background-color: red; display:none;" ></div>');
    $('#secure_forms_info').append('<span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span> ');
    $('#secure_forms_info').append('<a id="secureBtn" class="buttonNorm">View Details</a>');
    if(res['leafSecure'] >= 1) { // Certified
        $.when(fetchIndicators(), fetchLEAFSRequests(true)).then(function(indicators, leafSRequests) {
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
                    if (Object.keys(unresolvedLeafSRequests).length == 0) { // if no new request, create one
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
 * Purpose: History for Forms
 * @param categoryId
 */
function viewHistory(categoryId){
    dialog_simple.setContent('');
    dialog_simple.setTitle('Form History');
    dialog_simple.show();
    dialog_simple.indicateBusy();

    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistory&type=form&id='+categoryId,
        dataType: 'text',
        success: function(res) {
            dialog_simple.setContent(res);
            dialog_simple.indicateIdle();
        },
        cache: false
    });
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
        url: '../api/form/indicator/list',
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
        const siteType = res?.siteType || '';
        if (siteType.toLowerCase() === 'national_subordinate') {
            let warnContent = `<div id="subordinate_site_warning"><h3>This is a Nationally Standardized Subordinate Site</h3>`;
            warnContent += `<span>Do not make modifications! &nbsp;Synchronization problems will occur. &nbsp;`;
            warnContent += `Please contact your process POC if modifications need to be made.</span></div>`;
            $('#bodyarea').prepend(warnContent);
        }
        renderSecureFormsInfo(res)
    });
}
/**
 * Purpose: Get text files from file mngr for use with grid questions
*/
let fileManagerTextFiles = [];
function fetchDropdownFiles() {
    $.ajax({
        type: 'GET',
        url: '../api/system/files',
        success: (res) => {
            const files = res || [];
            fileManagerTextFiles = files.filter(filename => filename.indexOf('.txt') > -1 || filename.indexOf('.csv') > -1);
        },
        error: (err) => {
            console.log(err);
        },
        cache: false
    });
}

/**
 * Purpose: Create New form
 * @param parentID
 */
function createForm(parentID) {
    if(parentID == undefined) {
        parentID = '';
        dialog.setTitle('New Form');
    }
    else {
        dialog.setTitle('New Internal-Use Form');
    }
    dialog.setContent('<table>\
                            <tr>\
                                <td>Form Label</td>\
                                <td><input tabindex="0" id="name" type="text" maxlength="50"></input></td>\
                            </tr>\
                            <tr>\
                                <td>Form Description</td>\
                                <td><textarea tabindex="0" id="description" maxlength="255"></textarea></td>\
                            </tr>\
                        </table>');

    dialog.show();

    dialog.setSaveHandler(function() {
        let categoryName = $('#name').val();
        let categoryDescription = $('#description').val();
        $.ajax({
            type: 'POST',
            url: '../api/formEditor/new',
            data: {name: $('#name').val(),
                    description: $('#description').val(),
                    parentID: parentID,
                    CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                dialog.hide();
                currCategoryID = res;
                categories[res] = {};
                categories[res].categoryID = res;
                categories[res].categoryName = categoryName;
                categories[res].categoryDescription = categoryDescription;
                categories[res].workflowID = 0;
                categories[res].parentID = '';
                categories[res].needToKnow = 0;
                categories[res].visible = 1;
                categories[res].sort = 0;
                if(parentID != '') {
                    categories[res].parentID = parentID;
                    buildMenu(parentID);
                    // hightlight the newly created form in the menu
                    $('#menu>div').removeClass('buttonNormSelected');
                    $('#' + res).addClass('buttonNormSelected');
                }
                buildMenu(res);
                openContent('ajaxIndex.php?a=printview&categoryID='+ res);
            }
        });
    });
}

/**
 * Purpose: Import Form
 */
function importForm() {
	window.location.href = './?a=importForm';
}

/**
 * Purpose: Import Form from Library
 */
function formLibrary() {
    window.location.href = './?a=formLibrary';
}


$(function() {
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
    $('#simplexhrDialog').dialog({minWidth: ($(window).width() * .78) + 30});

    portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('../api/');
    portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

    showFormBrowser();
    fetchFormSecureInfo();
    fetchDropdownFiles();

    <!--{if $form != ''}-->
    postRenderFormBrowser = function() { selectForm('<!--{$form}-->') };
    <!--{/if}-->

    <!--{if $referFormLibraryID != 0}-->
    postRenderFormBrowser = function() {
        $('.formLibraryID_<!--{$referFormLibraryID}-->')
        .animate({'background-color': 'yellow'}, 1000)
        .animate({'background-color': 'white'}, 1000)
        .animate({'background-color': 'yellow'}, 1000);
    };
    <!--{/if}-->
});

</script>
