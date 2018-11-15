<div id="menu" style="float: left; width: 180px"></div>
<div id="formEditor_content" style="margin-left: 184px; padding-left: 8px"></div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<script>
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
                                 <td>Need to Know mode <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" title="When turned on, the people associated with the workflow are the only ones who have access to view the form."></td>\
                                 <td><select id="needToKnow"><option value="0">Off</option><option value="1">On</option></select></td>\
                             </tr>\
                             <tr class="isSubForm">\
                                 <td>Availability <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" title="When hidden, users will not be able to select this form as an option."></td>\
                                 <td><select id="visible"><option value="1">Available</option><option value="0">Hidden</option></select></td>\
                             </tr>\
                             <tr class="isSubForm">\
                                 <td>Sort Priority</td>\
                                 <td><input id="sort" type="number"></input></td>\
                             </tr>\
                             <tr class="isSubForm">\
                            	 <td>Type <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" title="Changes type of form."></td>\
                            	 <td><select id="formType"><option value="">Standard</option><option value="parallel_processing">Parallel Processing</option></select></td>\
                             </tr>\
                           </table>');
        $('#name').val(categories[currCategoryID].categoryName);
        $('#description').val(categories[currCategoryID].categoryDescription);
        $('#workflowID').val(categories[currCategoryID].workflowID);
        $('#needToKnow').val(categories[currCategoryID].needToKnow);
        $('#visible').val(categories[currCategoryID].visible);
        $('#sort').val(categories[currCategoryID].sort);
        $('#formType').val(categories[currCategoryID].type);if(isSubForm) {
        	$('.isSubForm').css('display', 'none');
        }
        //ie11 fix
		setTimeout(function () {dialog.show();}, 0);

        // load workflow data
        dialog.indicateBusy();
        $.ajax({
        	type: 'GET',
        	url: '../api/?a=workflow',
        	success: function(res) {
        		if(res.length > 0) {
                    var buffer = '<select id="workflowID">';
                    buffer += '<option value="0">No Workflow</option>';
                    for(var i in res) {
                        buffer += '<option value="'+ res[i].workflowID +'">'+ res[i].description +' (ID: #'+ res[i].workflowID +')</option>';
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
        	cache: false
        });

        dialog.setSaveHandler(function() {
            $.when(
                $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formName',
                    data: {name: $('#name').val(),
                    	categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                        }
                    }
                }),
                $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formDescription',
                    data: {description: $('#description').val(),
                    	categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                        }
                    }
                }),
                $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formWorkflow',
                    data: {workflowID: $('#workflowID').val(),
                    	categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res == false) {
                        	alert('Workflow cannot be set because this form has been merged into another form');
                        }
                    }
                }),
                $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formNeedToKnow',
                    data: {needToKnow: $('#needToKnow').val(),
                        categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                        }
                    }
                }),
                $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formSort',
                    data: {sort: $('#sort').val(),
                        categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                        }
                    }
                }),
                $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formVisible',
                    data: {visible: $('#visible').val(),
                        categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                        }
                    }
                }),
             $.ajax({
                    type: 'POST',
                    url: '../api/?a=formEditor/formType',
                    data: {type: $('#formType').val(),
                        categoryID: currCategoryID,
                        CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(res) {
                        if(res != null) {
                        }
                    }
                })).then(function() {
                categories[currCategoryID].categoryName = $('#name').val();
                categories[currCategoryID].categoryDescription = $('#description').val();
                categories[currCategoryID].description = '';
                categories[currCategoryID].workflowID = $('#workflowID').val();
                categories[currCategoryID].needToKnow = $('#needToKnow').val();
                categories[currCategoryID].visible = $('#visible').val();categories[currCategoryID].type = $('#formType').val();
                categories[currCategoryID].sort = $('#sort').val();
                openContent('ajaxIndex.php?a=printview&categoryID='+ currCategoryID);
                dialog.hide();
             });
        });}
var currCategoryID = '';
function openContent(url) {
	var isSubForm = categories[currCategoryID].parentID == '' ? false : true;
	var formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;
	var workflow = '';
	if(categories[currCategoryID].workflowID != 0) {
		workflow = categories[currCategoryID].description + ' (ID #' + categories[currCategoryID].workflowID + ')';
	}
	else {
		workflow = '<span style="color: red">No workflow. Users will not be able to select this form.</span>';
	}
    $("#formEditor_content").html('<div style="padding: 8px; border: 1px solid black; background-color: white">' +
    		                      '<div style="float: right"><div id="editFormData" tabindex="0" onkeypress="onKeyPressClick(event)" class="buttonNorm">Edit Properties</div><br /><div tabindex="0" id="editFormPermissions" onkeypress="onKeyPressClick(event)" onclick="editPermissions();" class="buttonNorm">Edit Collaborators</div></div>' +
    		                      '<div style="padding: 8px">' +
    		                          '<b aria-label="'+ formTitle +'" tabindex="0" title="categoryID: '+ currCategoryID +'">' + formTitle + '</b><br /><span tabindex="0">' +
    		                          categories[currCategoryID].categoryDescription +
    		                          '</span><br /><span tabindex="0" class="isSubForm">Workflow: ' + workflow + '</span>' +
    		                          '<br /><span tabindex="0"class="isSubForm">Need to Know mode: ' + (categories[currCategoryID].needToKnow == 1 ? 'On' : 'Off') + '</span>' +
    		                      '</div>' +
                                  '</div><br /><div id="formEditor_form" style="background-color: white"><div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="loading..." /></div></div>');
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
        },
        error: function(res) {
            $('#formEditor_form').empty().html(res);
        },
        cache: false
    });
}

function addPermission(categoryID, group) {
    dialog.setTitle('Edit Collaborators');
    dialog.setContent('Add collaborators to the <b>'+ formTitle +'</b> form:<div id="groups"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=system/groups',
        success: function(res) {
            var buffer = '<select id="groupID">';
            for(var i in res) {
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
            url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
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

		//ie11 fix
		setTimeout(function () {
			dialog.show();
		}, 0);

}


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

function editPermissions() {
	formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;

	dialog_simple.setTitle('Edit Collaborators - ' + formTitle);
	dialog_simple.setContent('<h2>Collaborators have access to fill out data fields at any time in the workflow.</h2><br />'
	                             + 'This is typically used to give groups access to fill out internal-use fields.<br />'
	                             + '<div id="formPrivs"></div>');
	dialog_simple.indicateBusy();

	$.ajax({
		type: 'GET',
		url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
		success: function(res) {
			var buffer = '<ul>';
			for(var i in res) {
				buffer += '<li>' + res[i].name + ' [ <a href="#" tabindex="0" onkeypress="onKeyPressClick(event);" onclick="removePermission(\''+ res[i].groupID +'\');">Remove</a> ]</li>';
			}
			buffer += '</ul>';
			buffer += '<span tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="addPermission();" role="button">Add Group</span>';
			$('#formPrivs').html(buffer);
			dialog_simple.indicateIdle();
		},
		cache: false
	});
	//ie11 fix
	setTimeout(function () {
		dialog_simple.show();
	}, 0);

}

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

function addIndicatorPrivilege(indicatorID) {
    dialog.setTitle('Edit Privileges');
    dialog.setContent('Add privileges to the <b>'+ currentIndicator.name +'</b> form:<div id="groups"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=system/groups',
        success: function(res) {
            var buffer = '<select id="groupID">';
            buffer += '<option value="1">System Administrators</option>';
            for(var i in res) {
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
                console.log(results);
                if (results == true) {

                    console.log('it worked!');
                } else {
                    console.log('it NO work: ' + results);
                }
                dialog.hide();
                editIndicatorPrivileges(indicatorID);
            },
            function (error) {
                console.log('it no work!: ' + error);
                dialog.hide();
                editIndicatorPrivileges(indicatorID);
            }
        );
    });

    dialog.show();
}

var currentIndicator = {};
function editIndicatorPrivileges(indicatorID) {
    dialog_simple.setContent('<h2>Only those Groups with Read Privileges will be able to view the data contained by the indicator</h2><br />'
                            + 'All others will see "[protected data]".<br /><div id="indicatorPrivs"></div>');

    dialog_simple.indicateBusy();

    portalAPI.FormEditor.getIndicator(
        indicatorID,
        function(indicator) {
            currentIndicator = indicator[indicatorID];

            dialog_simple.setTitle('Edit Indicator Read Privileges - ' + indicatorID);

            portalAPI.FormEditor.getIndicatorPrivileges(indicatorID,
                function (groups) {
                    var buffer = '<ul>';
                    for (var group in groups) {
                        if (groups[group].id !== undefined) {
                            buffer += '<li>' + groups[group].name + ' [ <a href="#" tabindex="0" onkeypress="onKeyPressClick(event);" onclick="removeIndicatorPrivilege(' + indicatorID + ',' + groups[group].id + ');">Remove</a> ]</li>';
                        }
                    }
                    buffer += '</ul>';
                    buffer += '<span tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="addIndicatorPrivilege(' + indicatorID + ');">Add Group</span>';
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
var gridJSON = [];
var gridBodyElement = 'div#container_indicatorGrid > div';
if(columns === undefined) {
    var columns = 1;
}

function newQuestion(parentIndicatorID) {
	var title = '';
	if(parentIndicatorID == null) {
		title = 'Adding New Question';
	}
	else {
		title = 'Adding Question to ' + parentIndicatorID;
	}
    dialog.setTitle(title);
    dialog.setContent('<fieldset><legend>Field Name</legend><textarea id="name" style="width: 99%"></textarea><button class="buttonNorm" id="advNameEditor">Advanced Formatting</button></fieldset> \
            <fieldset><legend>Short Label (Describe this field in 1-2 words)</legend>\
                <input type="text" id="description" maxlength="50"></input>\
            </fieldset>\
            <fieldset><legend>Input Format</legend>\
                <select id="indicatorType">\
                    <option value="">None</option>\
                    <option value="text">Single line text</option>\
                    <option value="textarea">Multi-line text</option>\
                    <option value="grid">Grid (Table with rows and columns)</option>\
                    <option value="number">Numeric</option>\
                    <option value="currency">Currency</option>\
                    <option value="date">Date</option>\
                    <option value="radio">Radio (single select, multiple options)</option>\
                    <option value="checkbox">Checkbox (A single checkbox)</option>\
                    <option value="checkboxes">Checkboxes (Multiple Checkboxes)</option>\
                    <option value="dropdown">Dropdown Menu (single select, multiple options)</option>\
                    <option value="fileupload">File Attachment</option>\
                    <option value="image">Image Attachment</option>\
                    <option value="orgchart_group">Orgchart Group</option>\
                    <option value="orgchart_position">Orgchart Position</option>\
                    <option value="orgchart_employee">Orgchart Employee</option>\
                    <option value="raw_data">Raw Data (for programmers)</option>\
                </select>\
                <div id="container_indicatorSingleAnswer" style="display: none">Text for checkbox: <input type="text" id="indicatorSingleAnswer"></input></div>\
                <div id="container_indicatorMultiAnswer" style="display: none">One option per line: <textarea id="indicatorMultiAnswer" style="width: 80%; height: 150px"></textarea><textarea style="display: none" id="format"></textarea></div>\
                <div id="container_indicatorGrid" style="display: none"></br><button class="buttonNorm" onclick="addCells()"><img src="../../libs/dynicons/?img=list-add.svg&w=16" style="height: 25px;"/>Add column</button>\
                <br/><br/>Columns:<table border="1" style="max-width: 100%; border: 1px black;"><tbody style="display: flex; flex-wrap: wrap;"></tbody></table></div>\n                <div style="float: right">Default Answer<br /><textarea id="default"></textarea></div></fieldset>\
                    <fieldset><legend>Attributes</legend>\
                        <table>\
                            <tr>\
                                <td>Required</td>\
                                <td><input id="required" name="required" type="checkbox" /></td>\
                            </tr>\
                        </table>\
                </fieldset>');
    $('#indicatorType').on('change', function() {
        switch($('#indicatorType').val()) {
            case 'grid':
                $('#container_indicatorGrid').css('display', 'block');
                $('#container_indicatorMultiAnswer').css('display', 'none');
                $('#container_indicatorSingleAnswer').css('display', 'none');
                makeGrid(columns);
                break;
            case 'radio':
            case 'checkboxes':
            case 'dropdown':
                $('#container_indicatorGrid').css('display', 'none');
                $('#container_indicatorMultiAnswer').css('display', 'block');
                $('#container_indicatorSingleAnswer').css('display', 'none');
                break;
            case 'checkbox':
                $('#container_indicatorGrid').css('display', 'none');
                $('#container_indicatorMultiAnswer').css('display', 'none');
            	$('#container_indicatorSingleAnswer').css('display', 'block');
            	break;
            default:
                $('#container_indicatorGrid').css('display', 'none');
                $('#container_indicatorMultiAnswer').css('display', 'none');
                $('#container_indicatorSingleAnswer').css('display', 'none');
                break;
        }
    });
    $('#advNameEditor').on('click', function() {
        $('#advNameEditor').css('display', 'none');
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
    $('#description').keypress(function(event) {
        if(event.keyCode === 13) {
            event.preventDefault();
        }
    });
    $('#required').keypress(function(event) {
        if(event.keyCode === 13) {
            event.preventDefault();
        }
    });
    $('#disabled').keypress(function(event) {
        if(event.keyCode === 13) {
            event.preventDefault();
        }
    });
    $('#required').keypress(function(e){
        if((e.keyCode ? e.keyCode : e.which) === 13){
            $(this).trigger('click');
        }
    });
    $('#disabled').keypress(function(e){
        if((e.keyCode ? e.keyCode : e.which) === 13){
            $(this).trigger('click');
        }
    });
    $('#required').on('click', function() {
    	if($('#indicatorType').val() == '') {
    		$('#required').prop('checked', false);
    		alert('You can\'t mark a field as required if the Input Format is "None".');
    	}
    });

		//ie11 fix
		setTimeout(function () {
			dialog.show();
		}, 0);

    dialog.setSaveHandler(function() {
    	var isRequired = $('#required').is(':checked') ? 1 : 0;

        switch($('#indicatorType').val()) {
            case 'grid':
                var gridJSON = [];

                //gather column names and column types
                //if column type is dropdown, adds property.options
                $(gridBodyElement).find('div').each(function() {
                    alert($(this).html());
                    var properties = new Object();
                    if($(this).children('input:eq(0)').val() === 'undefined'){
                        properties.name = 'No title';
                    } else {
                        properties.name = $(this).children('input:eq(0)').val();
                    }
                    properties.type = $(this).find('select').val();
                    if(properties.type !== undefined){
                        if(properties.type === 'dropdown'){
                            properties.options = gridDropdown($(this).find('textarea').val().replace(/,/g, ""));
                        }
                    } else {
                        properties.type = 'textarea';
                    }
                    gridJSON.push(properties);
                });
                var buffer = $('#indicatorType').val();
                buffer += "\n" + JSON.stringify(gridJSON);
                $('#format').val(buffer);
                break;
            case 'radio':
            case 'checkboxes':
            case 'dropdown':
                $('#container_indicatorMultiAnswer').css('display', 'block');
                var buffer = $('#indicatorType').val();
                buffer += "\n" + formatIndicatorMultiAnswer($('#indicatorMultiAnswer').val());
                $('#format').val(buffer);
                break;
            case 'checkbox':
                var buffer = $('#indicatorType').val();
                buffer += "\n" + $('#indicatorSingleAnswer').val();
                $('#format').val(buffer);
            	break;
            default:
                $('#format').val($('#indicatorType').val());
                break;
        }

        $.ajax({
            type: 'POST',
            url: '../api/?a=formEditor/newIndicator',
            data: {name: $('#name').val(),
            	format: $('#format').val(),
            	description: $('#description').val(),
            	default: $('#default').val(),
            	parentID: parentIndicatorID,
            	categoryID: currCategoryID,
            	required: isRequired,
                CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if(res != null) {
//                      console.log('ok');
                }
                dialog.hide();
                openContent('ajaxIndex.php?a=printview&categoryID=' + currCategoryID);
            }
        });
    });
}

function updateNames(){
    $(gridBodyElement).children('div').each(function(i) {
        if (gridJSON[i] === undefined) {
            gridJSON.push(new Object);
        }
        gridJSON[i].name = $(this).children('input').val();
    });
}


function makeGrid(columns) {
    for (var i = 0; i < columns; i++) {
        if(gridJSON[i] === undefined){
            gridJSON.push(new Object());
        }
        var name = gridJSON[i].name === undefined ? 'No title' : gridJSON[i].name;
        $(gridBodyElement).append(
            '<div style="padding: 10px; vertical-align: top; display: inline-block; flex: 1;"><span class="columnNumber">Column #' + (i + 1) + ': </span><img role="button" tabindex="0" onkeydown="triggerClick();" onclick="deleteColumn()" src="../../libs/dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer; vertical-align: middle;" />' +
            '</br>&nbsp;<input type="text" value="' + name + '" onchange="updateNames();"></input></br><img src=""/></br>Type:<select onchange="toggleDropDown(this.value, this);"><option value="textarea">Text Area</option>' +
            '<option value="dropdown">Drop Down</option></select></br>' +
            '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveFirst()" src="../../libs/dynicons/?img=go-first.svg&w=16" title="Move column first" alt="Move column first" style="cursor: pointer" />' +
            '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveLeft()" src="../../libs/dynicons/?img=go-previous.svg&w=16" title="Move column left" alt="Move column left" style="cursor: pointer" />' +
            '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveRight()" src="../../libs/dynicons/?img=go-next.svg&w=16" title="Move column right" alt="Move column right" style="cursor: pointer" />' +
            '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveLast()" src="../../libs/dynicons/?img=go-last.svg&w=16" title="Move column last" alt="Move column last" style="cursor: pointer" /></div>');
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
            $(gridBodyElement+ '> div:eq(' + i + ') > select option[value="' + gridJSON[i].type + '"]').attr('selected', 'selected');
            if(gridJSON[i].type.toString() === 'dropdown'){
                if(gridJSON[i].options !== ""){
                    var options = gridJSON[i].options.join("\n").toString();
                } else {
                    var options = "";
                }
                $(gridBodyElement + ' > div:eq(' + i + ')').append('<span class="dropdown"><div>One option per line</div><textarea style="resize: none;"value="">' + options + '</textarea></span>');
            }
        }
    }
}

function toggleDropDown(type, cell){
    if(type === 'dropdown'){
        $(cell).parent().append('<span class="dropdown"><div>One option per line</div><textarea value="" style="resize:none"></textarea></span>');
    } else {
        $(cell).parent().find('span.dropdown').remove();
    }
}

function leftArrows(cell, toggle){
    if(toggle){
        cell.find('[title="Move column left"]').css('display', 'inline');
        cell.find('[title="Move column first"]').css('display', 'inline');
    } else {
        cell.find('[title="Move column left"]').css('display', 'none');
        cell.find('[title="Move column first"]').css('display', 'none');
    }
}
function rightArrows(cell, toggle){
    if(toggle){
        cell.find('[title="Move column right"]').css('display', 'inline');
        cell.find('[title="Move column last"]').css('display', 'inline');
    } else {
        cell.find('[title="Move column right"]').css('display', 'none');
        cell.find('[title="Move column last"]').css('display', 'none');
    }
}

function addCells(){
    columns = columns + 1;
    rightArrows($(gridBodyElement + ' > div:last'), true);
    $(gridBodyElement).append(
        '<div style="padding: 10px; vertical-align: top; display: inline-block; flex: 1;"><span class="columnNumber"></span><img role="button" tabindex="0" onkeydown="triggerClick();" onclick="deleteColumn()" src="../../libs/dynicons/?img=process-stop.svg&w=16" title="Delete column" alt="Delete column" style="cursor: pointer; vertical-align: middle;" />' +
        '</br>&nbsp;<input type="text" value="No title" onchange="updateNames();"></input></br>Type:<select onchange="toggleDropDown(this.value, this);"><option value="textarea">Text Area</option>' +
        '<option value="dropdown">Drop Down</option></select></br>' +
        '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveFirst()" src="../../libs/dynicons/?img=go-first.svg&w=16" title="Move column first" alt="Move column first" style="cursor: pointer; display: inline" />' +
        '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveLeft()" src="../../libs/dynicons/?img=go-previous.svg&w=16" title="Move column left" alt="Move column left" style="cursor: pointer; display: inline" />' +
        '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveRight()" src="../../libs/dynicons/?img=go-next.svg&w=16" title="Move column right" alt="Move column right" style="cursor: pointer; display: none" />' +
        '<img role="button" tabindex="0" onkeydown="triggerClick();" onclick="moveLast()" src="../../libs/dynicons/?img=go-last.svg&w=16" title="Move column last" alt="Move column last" style="cursor: pointer; display: none" /></div>');
    updateColumnNumbers();
}

function updateColumnNumbers(){
    $(gridBodyElement).find('span.columnNumber').each(function(index) {
        $(this).html('Column #' + (index + 1) +':&nbsp;');
    });
}

function deleteColumn(){
    var column = $(event.target).closest('div');
    var tbody = $(event.target).closest('div').parent('div');
    switch(tbody.find('div').length){
        case 1:
            alert('Cannot remove inital column.');
            break;
        case 2:
            column.remove();
            rightArrows(tbody.find('div'), false);
            leftArrows(tbody.find('div'), false);
            break;
        default:
            if(column.find('[title="Move column right"]').css('display') === 'none'){
                rightArrows(column.prev(), false);
                leftArrows(column.prev(), true);
            }
            if(column.find('[title="Move column left"]').css('display') === 'none'){
                leftArrows(column.next(), false);
                rightArrows(column.next(), true);
            }
            column.remove();
            break;
    }
    updateColumnNumbers();
}

function moveRight(){
    var column = $(event.target).closest('div');
    var nextColumnLast = column.next().find('[title="Move column right"]').css('display') === 'none';
    var first = column.find('[title="Move column left"]').css('display') === 'none';
    leftArrows(column, true);
    if(first){
        leftArrows(column.next(), false);
    }
    if(nextColumnLast){
        rightArrows(column, false);
        rightArrows(column.next(), true);
    }
    column.insertAfter(column.next());
    updateColumnNumbers();
}

function moveLast(){
    var column = $(event.target).closest('div');
    var first = column.find('[title="Move column left"]').css('display') === 'none';
    rightArrows(column, false);
    leftArrows(column, true);
    if(first) {
        leftArrows(column.next(), false);
    }
    rightArrows($(gridBodyElement + ' > div:last'), true);
    leftArrows($(gridBodyElement + ' > div:last'), true);
    column.insertAfter($(gridBodyElement + ' > div:last'));
    updateColumnNumbers();
}

function moveLeft(){
    var column = $(event.target).closest('div');
    var nextColumnFirst = column.prev().find('[title="Move column left"]').css('display') === 'none';
    var last = column.find('[title="Move column right"]').css('display') === 'none';
    rightArrows(column, true);
    if(last){
        rightArrows(column.prev(), false);
    }
    if(nextColumnFirst){
        leftArrows(column, false);
        leftArrows(column.prev(), true);
    }
    column.insertBefore(column.prev());
    updateColumnNumbers();
}
function moveFirst(){
    var column = $(event.target).closest('div');
    var last = column.find('[title="Move column right"]').css('display') === 'none';
    leftArrows(column, false);
    if(last) {
        rightArrows(column.prev(), false);
    }
    rightArrows(column, true);
    leftArrows($(gridBodyElement + ' > div:first'), true);
    rightArrows($(gridBodyElement + ' > div:first'), true);
    column.insertBefore($(gridBodyElement + ' > div:first'));
    updateColumnNumbers();
}

// edit question
function getForm(indicatorID, series) {
	dialog.setTitle('Editing indicatorID: ' + indicatorID);
    dialog.setContent('<fieldset><legend>Field Name</legend><textarea id="name" style="width: 99%"></textarea><button class="buttonNorm" id="rawNameEditor" style="display: none">Show formatted code</button><button class="buttonNorm" id="advNameEditor">Advanced Formatting</button></fieldset> \
            <fieldset><legend>Short Label (Describe this field in 1-2 words)</legend>\
                <input type="text" id="description" maxlength="50"></input>\
            </fieldset>\
            <fieldset><legend>Input Format</legend>\
                <select id="indicatorType">\
                    <option value="">None</option>\
                    <option value="text">Single line text</option>\
                    <option value="textarea">Multi-line text</option>\
                    <option value="grid">Grid (Table with rows and columns)</option>\
                    <option value="number">Numeric</option>\
                    <option value="currency">Currency</option>\
                    <option value="date">Date</option>\
                    <option value="radio">Radio (single select, multiple options)</option>\
                    <option value="checkbox">Checkbox (A single checkbox)</option>\
                    <option value="checkboxes">Checkboxes (Multiple Checkboxes)</option>\
                    <option value="dropdown">Dropdown Menu (single select, multiple options)</option>\
                    <option value="fileupload">File Attachment</option>\
                    <option value="image">Image Attachment</option>\
                    <option value="orgchart_group">Orgchart Group</option>\
                    <option value="orgchart_position">Orgchart Position</option>\
                    <option value="orgchart_employee">Orgchart Employee</option>\
                    <option value="raw_data">Raw Data (for programmers)</option>\
                </select>\
                <div id="container_indicatorSingleAnswer" style="display: none">Text for checkbox: <input type="text" id="indicatorSingleAnswer"></input></div>\
                <div id="container_indicatorMultiAnswer" style="display: none">One option per line: <textarea id="indicatorMultiAnswer" style="width: 80%; height: 150px"></textarea><textarea style="display: none" id="format"></textarea></div>\
                <div id="container_indicatorGrid" style="display: none"></br><button class="buttonNorm" onclick="addCells(\'column\')"><img src="../../libs/dynicons/?img=list-add.svg&w=16" style="height: 25px;"/>Add column</button>&nbsp;\
                </br></br>Columns:<div border="1" style="max-width: 100%; border: 1px black;"></div></div>\
                <div style="float: right">Default Answer<br /><textarea id="default"></textarea></div></fieldset>\
            <fieldset><legend>Attributes</legend>\
                <table>\
                    <tr>\
                        <td>Required</td>\
                        <td><input id="required" name="required" type="checkbox" /></td>\
                    </tr>\
                    <tr>\
                        <td>Sort Priority</td>\
                        <td><input id="sort" name="sort" type="number" style="width: 40px" /></td>\
                    </tr>\
                    <tr>\
                        <td>Parent Question ID</td>\
                        <td><div id="container_parentID"></div></td>\
                    </tr>\
                    <tr>\
                        <td>Disabled</td>\
                        <td><input id="disabled" name="disabled" type="checkbox" /></td>\
                    </tr>\
                </table>\
        </fieldset>\
        <span class="buttonNorm" id="button_advanced">Advanced Options</span>\
        <div><fieldset id="advanced" style="visibility: hidden"><legend>Advanced Options</legend>\
            html (for pages where the user can edit data): <button id="btn_codeSave_html" class="buttonNorm"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" /> Save Code<span id="codeSaveStatus_html"></span></button><textarea id="html"></textarea><br />\
            htmlPrint (for pages where the user can only read data): <button id="btn_codeSave_htmlPrint" class="buttonNorm"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" /> Save Code<span id="codeSaveStatus_htmlPrint"></span></button><textarea id="htmlPrint"></textarea><br />\
            Template Variables:<br />\
            <b>{{ iID }}</b> will be replaced with the indicatorID # of the data field\
        </div></div>');

    $('#indicatorType').on('change', function() {
    	switch($('#indicatorType').val()) {
            case 'grid':
                $('#container_indicatorGrid').css('display', 'block');
                $('#container_indicatorMultiAnswer').css('display', 'none');
                $('#container_indicatorSingleAnswer').css('display', 'none');
                makeGrid(columns);
                break;
    	    case 'radio':
    	    case 'checkboxes':
    	    case 'dropdown':
                $('#container_indicatorGrid').css('display', 'none');
    	    	$('#container_indicatorMultiAnswer').css('display', 'block');
    	    	$('#container_indicatorSingleAnswer').css('display', 'none');
    		    break;
    	    case 'checkbox':
                $('#container_indicatorGrid').css('display', 'none');
    	    	$('#container_indicatorMultiAnswer').css('display', 'none');
    	    	$('#container_indicatorSingleAnswer').css('display', 'block');
    	    	break;
    	    default:
                $('#container_indicatorGrid').css('display', 'none');
                $('#container_indicatorMultiAnswer').css('display', 'none');
    	        $('#container_indicatorSingleAnswer').css('display', 'none');
    	    	break;
    	}
    });
    $('#description').keypress(function(event) {
        if(event.keyCode === 13) {
            event.preventDefault();
        }
    });
    $('#required').keypress(function(event) {
        if(event.keyCode === 13) {
            event.preventDefault();
        }
    });
    $('#disabled').keypress(function(event) {
        if(event.keyCode === 13) {
            event.preventDefault();
        }
    });
    $('#required').keypress(function(e){
        if((e.keyCode ? e.keyCode : e.which) === 13){
            $(this).trigger('click');
        }
    });
    $('#disabled').keypress(function(e){
        if((e.keyCode ? e.keyCode : e.which) === 13){
            $(this).trigger('click');
        }
    });
    $('#required').on('click', function() {
        if($('#indicatorType').val() == '') {
            $('#required').prop('checked', false);
            alert('You can\'t mark a field as required if the Input Format is "None".');
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
    $('#button_advanced').on('click', function() {
    	$('#button_advanced').css('display', 'none');
    	$('#advanced').css('visibility', 'visible');
    });

    function saveCodeHTML() {
        $.ajax({
            type: 'POST',
            url: '../api/?a=formEditor/' + indicatorID + '/html',
            data: {html: codeEditorHtml.getValue(),
                CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                var time = new Date().toLocaleTimeString();
                $('#codeSaveStatus_html').html('<br /> Last saved: ' + time);
                if(res != null) {
                }
            }
        });
    }

    function saveCodeHTMLPrint() {
        $.ajax({
            type: 'POST',
            url: '../api/?a=formEditor/' + indicatorID + '/htmlPrint',
            data: {htmlPrint: codeEditorHtmlPrint.getValue(),
                CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
            	var time = new Date().toLocaleTimeString();
            	$('#codeSaveStatus_htmlPrint').html('<br /> Last saved: ' + time);
                if(res != null) {
                }
            }
        });
    }
    $('#btn_codeSave_html').on('click', function() {
    	saveCodeHTML();
    });
    $('#btn_codeSave_htmlPrint').on('click', function() {
        saveCodeHTMLPrint();
    });
    var codeEditorHtml = CodeMirror.fromTextArea(document.getElementById("html"), {
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
    var codeEditorHtmlPrint = CodeMirror.fromTextArea(document.getElementById("htmlPrint"), {
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
    	            var buffer = '<select id="parentID" style="width: 300px">';
    	            buffer += '<option value="">None</option>';
    	            for(var i in res) {
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
                var format = res[indicatorID].format;
                if(res[indicatorID].options != undefined
                    && res[indicatorID].options.length > 0
                        && format != 'grid') {
                    for(var i in res[indicatorID].options) {
                        format += "\n" + res[indicatorID].options[i];
                    }
                }
                if(format === 'grid'){
                    gridJSON = JSON.parse(res[indicatorID].options[0]);
                    columns = gridJSON.length;
                }

                $('#name').html(res[indicatorID].name);
                // auto select advanced editor if it was previously used
                if(XSSHelpers.containsTags(res[indicatorID].name, ['<b>','<i>','<u>','<ol>','<li>','<br>','<p>','<td>'])) {
                    $('#advNameEditor').click();
                }
                $('#format').val(format);
                $('#indicatorType').val(format);
                $('#description').val(res[indicatorID].description);
                $('#default').val(res[indicatorID].default);
                if(res[indicatorID].required == 1) {
                    $('#required').prop('checked', true);
                }
                $('#parentID').val(res[indicatorID].parentID);
                $('#sort').val(res[indicatorID].sort);
                codeEditorHtml.setValue((res[indicatorID].html == null ? '' : res[indicatorID].html));
                codeEditorHtmlPrint.setValue((res[indicatorID].htmlPrint == null ? '' : res[indicatorID].htmlPrint));

                // render input format UI
                var formatIdx = format === 'grid' ? 4 : format.indexOf('\n');
                if(formatIdx != -1 && format.substr(0, formatIdx) != '') {
                    switch(format.substr(0, formatIdx)) {
                        case 'grid':
                            $('#indicatorType').val(format.substr(0, formatIdx));
                            $('#container_indicatorGrid').css('display', 'block');
                            $('#container_indicatorMultiAnswer').css('display', 'none');
                            $('#container_indicatorSingleAnswer').css('display', 'none');
                            makeGrid(columns);
                            break;
                        case 'checkbox':
                            $('#indicatorType').val(format.substr(0, formatIdx));
                            $('#indicatorSingleAnswer').val(format.substr(formatIdx + 1));
                            $('#container_indicatorSingleAnswer').css('display', 'block');
                            break;
                        case 'radio':
                        case 'checkboxes':
                        case 'dropdown':
                        default:
                            $('#indicatorType').val(format.substr(0, formatIdx));
                            $('#indicatorMultiAnswer').val(format.substr(formatIdx + 1));
                            $('#container_indicatorMultiAnswer').css('display', 'block');
                            break;
                    }
                }
                dialog.indicateIdle();
                $('#xhr').scrollTop(0);
            },
            cache: false
        });
    });

    dialog.setSaveHandler(function() {
    	var isRequired = $('#required').is(':checked') ? 1 : 0;
    	var isDisabled = $('#disabled').is(':checked') ? 1 : 0;

        switch($('#indicatorType').val()) {
            case 'grid':
                var gridJSON = [];

                //gather column names and column types
                //if column type is dropdown, adds property.options
                $(gridBodyElement).find('div').each(function() {
                    var properties = new Object();
                    if($(this).children('input:eq(0)').val() === 'undefined'){
                        properties.name = 'No title';
                    } else {
                        properties.name = $(this).children('input:eq(0)').val();
                    }
                    properties.type = $(this).find('select').val();
                    if(properties.type !== undefined){
                        if(properties.type === 'dropdown'){
                            properties.options = gridDropdown($(this).find('textarea').val().replace(/,/g, ""));
                        }
                    } else {
                        properties.type = 'textarea';
                    }
                    gridJSON.push(properties);
                });
                var buffer = $('#indicatorType').val();
                buffer += "\n" + JSON.stringify(gridJSON);
                $('#format').val(buffer);
                break;
            case 'radio':
            case 'checkboxes':
            case 'dropdown':
                $('#container_indicatorMultiAnswer').css('display', 'block');
                var buffer = $('#indicatorType').val();
                buffer += "\n" + formatIndicatorMultiAnswer($('#indicatorMultiAnswer').val());
                $('#format').val(buffer);
                break;
            case 'checkbox':
            	var buffer = $('#indicatorType').val();
                buffer += "\n" + $('#indicatorSingleAnswer').val();
                $('#format').val(buffer);
            	break;
            default:
                $('#format').val($('#indicatorType').val());
                break;
        }
    	dialog.indicateBusy();

        // check if the user is trying to set an invalid parent ID
        if(indicatorID == $('#parentID').val()) {
        	alert('Invalid parentID.');
        	$('#parentID').val('');
        	dialog.indicateIdle();
        	return false;
        }


    	$.when(
   	        $.ajax({
   	            type: 'POST',
   	            url: '../api/?a=formEditor/' + indicatorID + '/name',
   	            data: {name: $('#name').val(),
   	                CSRFToken: '<!--{$CSRFToken}-->'},
   	            success: function(res) {
   	                if(res != null) {
   	                }
   	            }
   	        }),
   	        $.ajax({
   	            type: 'POST',
   	            url: '../api/?a=formEditor/' + indicatorID + '/format',
   	            data: {format: $('#format').val(),
   	                CSRFToken: '<!--{$CSRFToken}-->'},
   	            success: function(res) {
   	                if(res != null) {
   	                }
   	            }
   	        }),
   	        $.ajax({
   	            type: 'POST',
   	            url: '../api/?a=formEditor/' + indicatorID + '/description',
   	            data: {description: $('#description').val(),
   	                CSRFToken: '<!--{$CSRFToken}-->'},
   	            success: function(res) {
   	                if(res != null) {
   	                }
   	            }
   	        }),
   	        $.ajax({
   	            type: 'POST',
   	            url: '../api/?a=formEditor/' + indicatorID + '/default',
   	            data: {default: $('#default').val(),
   	                CSRFToken: '<!--{$CSRFToken}-->'},
   	            success: function(res) {
   	                if(res != null) {
   	                }
   	            }
   	        }),
   	        $.ajax({
   	            type: 'POST',
   	            url: '../api/?a=formEditor/' + indicatorID + '/required',
   	            data: {required: isRequired,
   	                CSRFToken: '<!--{$CSRFToken}-->'},
   	            success: function(res) {
   	                if(res != null) {
   	                }
   	            }
   	        }),
   	        $.ajax({
   	            type: 'POST',
   	            url: '../api/?a=formEditor/' + indicatorID + '/disabled',
   	            data: {disabled: isDisabled,
   	                CSRFToken: '<!--{$CSRFToken}-->'},
   	            success: function(res) {
   	                if(res != null) {
   	                }
   	            }
   	        }),
    	    $.ajax({
                type: 'POST',
                url: '../api/?a=formEditor/' + indicatorID + '/parentID',
                data: {parentID: $('#parentID').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if(res != null) {
                    	alert(res);
                    }
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=formEditor/' + indicatorID + '/sort',
                data: {sort: $('#sort').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if(res != null) {
                    }
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=formEditor/' + indicatorID + '/html',
                data: {html: codeEditorHtml.getValue(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if(res != null) {
                    }
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=formEditor/' + indicatorID + '/htmlPrint',
                data: {htmlPrint: codeEditorHtmlPrint.getValue(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if(res != null) {
                    }
                }
            })
   	     ).then(function() {
   	    	openContent('ajaxIndex.php?a=printview&categoryID='+ currCategoryID);
   	    	dialog.hide();
   	     });
    });
}

//this is a modified version formatIndicatorMultiAnswer() in order to returns array
function gridDropdown(dropDownOptions){
    if(dropDownOptions == null || dropDownOptions.length === 0){
        return dropDownOptions;
    }
    var uniqueNames = dropDownOptions.split("\n");
    var returnArray = [];
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

function formatIndicatorMultiAnswer(multiAnswerValue){
    if(multiAnswerValue == null || multiAnswerValue.length === 0){
        return multiAnswerValue;
    }
    var uniqueNames = multiAnswerValue.split("\n");
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

function mergeForm(categoryID) {
    dialog.setTitle('Staple other form');
    dialog.setContent('Select a form to staple: <div id="formOptions"></div>');
    dialog.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/formStack/categoryList/all',
        success: function(res) {
            var buffer = '<select id="stapledCategoryID">';
            for(var i in res) {
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

		//ie11 fix
		setTimeout(function () {
			dialog.show();
		}, 0);

}

function unmergeForm(categoryID, stapledCategoryID) {
    $.ajax({
        type: 'DELETE',
        url: '../api/formEditor/_'+ categoryID +'/stapled/_'+ stapledCategoryID + '&CSRFToken=<!--{$CSRFToken}-->',
        success: function() {
        	mergeFormDialog(categoryID);
        }
    });
}

function mergeFormDialog(categoryID) {
    dialog_simple.setTitle('Staple other form');
    dialog_simple.setContent('Stapled forms will show up on the same page as the primary form.<div id="mergedForms"></div>');
    dialog_simple.indicateBusy();

    $.ajax({
        type: 'GET',
        url: '../api/?a=formEditor/_'+ categoryID +'/stapled',
        success: function(res) {
            var buffer = '<ul>';
            for(var i in res) {
                buffer += '<li>' + res[i].categoryName + ' [ <a href="#" onkeypress="onKeyPressClick(event)" onclick="unmergeForm(\''+ categoryID +'\', \''+ res[i].stapledCategoryID +'\');">Remove</a> ]</li>';
            }
            buffer += '</ul>';
            buffer += '<span class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="mergeForm(\''+ categoryID +'\');" tabindex="0" role="button">Select a form to merge</span>';
            $('#mergedForms').html(buffer);
            dialog_simple.indicateIdle();
        },
        cache: false
    });
		//ie11 fix
		setTimeout(function () {
				dialog_simple.show();
		}, 0);

}

function exportForm(categoryID) {
	var packet = {};
	packet.form = {};
	packet.subforms = {};

	var defer = $.Deferred();
	var promise = defer.promise();
	promise = promise.then(function() {
		return $.ajax({
	        type: 'GET',
	        url: '../api/?a=form/_' + categoryID + '/export',
	        success: function(res) {
	            packet.form = res;
	            packet.categoryID = categoryID;
	        }
	    });
	});

    promise = promise.then(function() {
        return $.ajax({
            type: 'GET',
            url: '../api/?a=form/_' + categoryID + '/workflow',
            success: function(res) {
                packet.workflowID = res[0].workflowID;
            }
        });
    });

	for(var i in categories) {
        if(categories[i].parentID == categoryID) {
        	promise = promise.then(
            	function(subCategoryID) {
                    return $.ajax({
                        type: 'GET',
                        url: '../api/?a=form/_' + subCategoryID + '/export',
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
		var outPacket = {};
		outPacket.version = 1;
		outPacket.name = categories[categoryID].categoryName + ' (Copy)';
		outPacket.description = categories[categoryID].categoryDescription;
		outPacket.packet = packet;

		var outBlob = new Blob([JSON.stringify(outPacket).replace(/[^ -~]/g,'')], {type : 'text/plain'}); // Regex replace needed to workaround IE11 encoding issue
		saveAs(outBlob, 'LEAF_FormPacket_'+ categoryID +'.txt');
	});
}
// click function for 508 compliance
function triggerClick(){
    if(event.keyCode === 13){
        $(event.target).trigger('click');
    }
}

function deleteForm() {
	var formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;
	dialog_confirm.setTitle('Delete Form?');
	dialog_confirm.setContent('Are you sure you want to delete the <b>'+ formTitle +'</b> form?');

	dialog_confirm.setSaveHandler(function() {
		$.ajax({
			type: 'DELETE',
			url: '../api/?a=formStack/_' + currCategoryID + '&CSRFToken=<!--{$CSRFToken}-->',
			success: function(res) {
			    if(res != true) {
			        alert(res);
			    }
		        window.location.reload();
			}
		});
	});

	//ie11 fix
	setTimeout(function () {
		dialog_confirm.show();
	}, 0);

}

function buildMenu(categoryID) {
	$('#menu').html('<div tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="postRenderFormBrowser = null; showFormBrowser();" style="font-size: 120%" role="button"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="View All Forms" /> View All Forms</div><br />');
	$('#menu').append('<div tabindex="0" id="'+ categoryID +'" class="buttonNorm" style="font-size: 120%" onkeypress="onKeyPressClick(event)" role="button"><img src="../../libs/dynicons/?img=document-open.svg&w=32" alt="Open Form" />'+ categories[categoryID].categoryName +'</div>');
    $('#' + categoryID).on('click', function(categoryID) {
        return function() {
            $('#menu>div').removeClass('buttonNormSelected');
            $('#' + categoryID).addClass('buttonNormSelected');
            currCategoryID = categoryID;
            openContent('ajaxIndex.php?a=printview&categoryID='+ categoryID);
        };
    }(categoryID));

	for(var i in categories) {
		if(categories[i].parentID == categoryID) {
			$('#menu').append('<div tabindex="0" id="'+ categories[i].categoryID +'" onkeypress="onKeyPressClick(event)" class="buttonNorm" style="font-size: 120%" role="button"><img src="../../libs/dynicons/?img=text-x-generic.svg&w=32" alt="Open Form" /> '+ categories[i].categoryName +'</div>');
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

	$('#menu').append('<div tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event);" onclick="createForm(\''+ categoryID +'\');" style="font-size: 120%" role="button"><img src="../../libs/dynicons/?img=list-add.svg&w=32" alt="Create Form" /> Add Internal-Use</div><br />');

    $('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event);" onclick="mergeFormDialog(\''+ categoryID +'\');" style="font-size: 120%" role="button"><img src="../../libs/dynicons/?img=tab-new.svg&w=32" alt="Staple Form" /> Staple other form</div>\
                          <div id="stapledArea"></div><br />');

    // show stapled forms in the menu area
    $.ajax({
        type: 'GET',
        url: '../api/formEditor/_'+ categoryID + '/stapled',
        success: function(res) {
            let buffer = '<ul>';
            for(var i in res) {
                buffer += '<li>'+ res[i].categoryName +'</li>';
            }
            buffer += '</ul>';
            if(res.length > 0) {
                $('#stapledArea').append(buffer);
            }
        }
    });
    
    
	$('#menu').append('<br /><div tabindex="0"class="buttonNorm" onkeypress="onKeyPressClick(event)"onclick="exportForm(\''+ categoryID +'\');" style="font-size: 120%"role="button"><img src="../../libs/dynicons/?img=network-wireless.svg&w=32" alt="Export Form" /> Export Form</div><br />');

	$('#menu').append('<br /><div class="buttonNorm" onclick="deleteForm();" style="font-size: 120%"><img src="../../libs/dynicons/?img=user-trash.svg&w=32" alt="Export Form" /> Delete this form</div><br />');
	
	$('#' + categoryID).addClass('buttonNormSelected');
}

function selectForm(categoryID) {
    currCategoryID = categoryID;
    buildMenu(categoryID);
    openContent('ajaxIndex.php?a=printview&categoryID='+ categoryID);
}

var postRenderFormBrowser;

var categories = {};
function showFormBrowser() {
    window.location = '#';
	$('#menu').html('<div tabindex="0" role="button" class="buttonNorm" onkeypress="onKeyPressClick(event)" id="createFormButton" onclick="createForm();" style="font-size: 120%"><img src="../../libs/dynicons/?img=document-new.svg&w=32" alt="Create Form" /> Create Form</div><br />');
	$('#menu').append('<div tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="formLibrary();" style="font-size: 120%" role="button"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="Import Form" /> LEAF Library</div><br />');
	$('#menu').append('<br /><div tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="importForm();" style="font-size: 120%" role="button"><img src="../../libs/dynicons/?img=package-x-generic.svg&w=32" alt="Import Form" /> Import Form</div><br />');
	$('#menu').append('<br /><br /><div tabindex="0" class="buttonNorm" onkeypress="onKeyPressClick(event)" onclick="window.location = \'?a=disabled_fields\';" style="font-size: 120%" role="buttz"><img src="../../libs/dynicons/?img=user-trash-full.svg&w=32" alt="Restore fields" /> Restore Fields</div>');
    $.ajax({
        type: 'GET',
        url: '<!--{$APIroot}-->?a=formStack/categoryList/all',
        success: function(res) {
            var buffer = '<div id="forms" style="padding: 8px"></div><br style="clear: both" /><hr style="margin-top: 32px" tabindex="0" aria-label="Not associated with a workflow" />Not associated with a workflow:<div id="forms_inactive" style="padding: 8px"></div>';
            $('#formEditor_content').html(buffer);
            for(var i in res) {
            	categories[res[i].categoryID] = res[i];
            	if(res[i].parentID == '') {
            		formTitle = res[i].categoryName == '' ? 'Untitled' : res[i].categoryName;
            		availability = res[i].visible == 1 ? '' : 'Hidden. Users cannot submit new requests.';
            		var needToKnow = '';
            		if(res[i].needToKnow == 1) {
            			needToKnow = ' <img src="../../libs/dynicons/?img=emblem-readonly.svg&w=16" alt="Need to know mode enabled" title="Need to know mode enabled" />';
            		}
            		var formActiveID = '';
            		if(res[i].workflowID > 0) {
            			formActiveID = '#forms';
            		}
            		else {
            			formActiveID = '#forms_inactive';
            		}
            		var workflow = res[i].description != null ? 'Workflow: ' + res[i].description : '';
                    $(formActiveID).append('<div tabindex="0"  onkeypress="onKeyPressClick(event)"class="formPreview formLibraryID_'+ res[i].formLibraryID +'" id="'+ res[i].categoryID +'" title="'+ res[i].categoryID +'">\
                    		<div tabindex="0" class="formPreviewTitle">'+ formTitle + needToKnow + '</div>\
                    		<div tabindex="0" class="formPreviewDescription">'+ res[i].categoryDescription +'</div>\
                    		<div tabindex="0" class="formPreviewStatus">'+ availability +'</div>\
                    		<div tabindex="0" class="formPreviewWorkflow">'+ workflow +'</div>\
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
			//ie11 fix
		setTimeout(function () {
			dialog.show();
		}, 0);


    dialog.setSaveHandler(function() {
    	var categoryName = $('#name').val();
    	var categoryDescription = $('#description').val();
    	$.ajax({
    		type: 'POST',
    		url: '<!--{$APIroot}-->?a=formEditor/new',
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

function importForm() {
	window.location.href = './?a=importForm';
}

function formLibrary() {
    window.location.href = './?a=formLibrary';
}

var dialog, dialog_confirm, dialog_simple;
var portalAPI;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
	dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');

    portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('../api/');
    portalAPI.setCSRFToken('<!--{$CSRFToken}-->');

    showFormBrowser();
    <!--{if $form != ''}-->
    postRenderFormBrowser = function() { selectForm('<!--{$form}-->') };
    <!--{/if}-->

    <!--{if $referFormLibraryID != ''}-->
    postRenderFormBrowser = function() { $('.formLibraryID_<!--{$referFormLibraryID}-->')
        .animate({'background-color': 'yellow'}, 1000)
        .animate({'background-color': 'white'}, 1000)
        .animate({'background-color': 'yellow'}, 1000);
    };
    <!--{/if}-->
});


// keypress functions for 508 compliance
function onKeyPressClick(e){
	if((e.keyCode ? e.keyCode : e.which) === 13){
			$(e.target).trigger('click');
	}
}
</script>
