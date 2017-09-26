<div id="menu" style="float: left; width: 180px"></div>
<div id="formEditor_content" style="margin-left: 184px; padding-left: 8px"></div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<script>

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
    		                      '<div style="float: right"><div id="editFormData" class="buttonNorm">Edit Properties</div><br /><div id="editFormPermissions" onclick="editPermissions();" class="buttonNorm">Edit Collaborators</div></div>' +
    		                      '<div style="padding: 8px">' +
    		                          '<b title="categoryID: '+ currCategoryID +'">' + formTitle + '</b><br />' +
    		                          categories[currCategoryID].categoryDescription +
    		                          '<br /><span class="isSubForm">Workflow: ' + workflow + '</span>' +
    		                          '<br /><span class="isSubForm">Need to Know mode: ' + (categories[currCategoryID].needToKnow == 1 ? 'On' : 'Off') + '</span>' +
    		                      '</div>' +
                                  '</div><br /><div id="formEditor_form" style="background-color: white"><div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="loading..." /></div></div>');
    if(isSubForm) {
        $('.isSubForm').css('display', 'none');
    }

    $('#editFormData').on('click', function() {
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
                                 <td>Sort Priority</td>\
                                 <td><input id="sort" type="number"></input></td>\
                             </tr>\
                           </table>');
        $('#name').val(categories[currCategoryID].categoryName);
        $('#description').val(categories[currCategoryID].categoryDescription);
        $('#workflowID').val(categories[currCategoryID].workflowID);
        $('#needToKnow').val(categories[currCategoryID].needToKnow);
        $('#sort').val(categories[currCategoryID].sort);
        if(isSubForm) {
        	$('.isSubForm').css('display', 'none');
        }
        dialog.show();

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
                })
             ).then(function() {
                categories[currCategoryID].categoryName = $('#name').val();
                categories[currCategoryID].categoryDescription = $('#description').val();
                categories[currCategoryID].description = '';
                categories[currCategoryID].workflowID = $('#workflowID').val();
                categories[currCategoryID].needToKnow = $('#needToKnow').val();
                categories[currCategoryID].sort = $('#sort').val();
                openContent('ajaxIndex.php?a=printview&categoryID='+ currCategoryID);
                dialog.hide();
             });
        });
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
    dialog.show();
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

	dialog_simple.setTitle('Edit Collaborators');
	dialog_simple.setContent('Groups listed below have access to write on the <b>'+ formTitle +'</b> form.<div id="formPrivs"></div>');
	dialog_simple.indicateBusy();

	$.ajax({
		type: 'GET',
		url: '../api/?a=formEditor/_'+ currCategoryID +'/privileges',
		success: function(res) {
			var buffer = '<ul>';
			for(var i in res) {
				buffer += '<li>' + res[i].name + ' [ <a href="#" onclick="removePermission(\''+ res[i].groupID +'\');">Remove</a> ]</li>';
			}
			buffer += '</ul>';
			buffer += '<span class="buttonNorm" onclick="addPermission();">Add Group</span>';
			$('#formPrivs').html(buffer);
			dialog_simple.indicateIdle();
		},
		cache: false
	});

	dialog_simple.show();
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
    dialog.setContent('<fieldset><legend>Field Name</legend><textarea id="name" style="width: 99%"></textarea><button class="buttonNorm" id="advNameEditor">Advanced Formatting</button><div style="float: right">Describe field in 1-2 words<br /><input type="text" id="description" maxlength="50"></input></div></fieldset> \
            <fieldset><legend>Input Format</legend>\
                <select id="indicatorType">\
                    <option value="">None</option>\
                    <option value="text">Single line text</option>\
                    <option value="textarea">Multi-line text</option>\
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
                <div style="float: right">Default Answer<br /><textarea id="default"></textarea></div></fieldset> \
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
            case 'radio':
            case 'checkboxes':
            case 'dropdown':
                $('#container_indicatorMultiAnswer').css('display', 'block');
                $('#container_indicatorSingleAnswer').css('display', 'none');
                break;
            case 'checkbox':
            	$('#container_indicatorMultiAnswer').css('display', 'none');
            	$('#container_indicatorSingleAnswer').css('display', 'block');
            	break;
            default:
            	$('#container_indicatorMultiAnswer').css('display', 'none');
                $('#container_indicatorSingleAnswer').css('display', 'none');
                break;
        }
    });
    $('#advNameEditor').on('click', function() {
        $('#advNameEditor').css('display', 'none');
        $('#name').trumbowyg({
            resetCss: true,
            btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'link', '|', 'foreColor', '|', 'viewHTML']
        });
        
        $('.trumbowyg-box').css({
            'min-height': '130px'
        });
        $('.trumbowyg-editor, .trumbowyg-texteditor').css({
            'min-height': '100px',
            'height': '100px'
        });
    });
    $('#required').on('click', function() {
    	if($('#indicatorType').val() == '') {
    		$('#required').prop('checked', false);
    		alert('You can\'t mark a field as required if the Input Format is "None".');
    	}
    });

    dialog.show();

    dialog.setSaveHandler(function() {
    	var isRequired = $('#required').is(':checked') ? 1 : 0;

        switch($('#indicatorType').val()) {
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

// edit question
function getForm(indicatorID, series) {
	dialog.setTitle('Editing indicatorID: ' + indicatorID);
    dialog.setContent('<fieldset><legend>Field Name</legend><textarea id="name" style="width: 99%"></textarea><button class="buttonNorm" id="advNameEditor">Advanced Formatting</button><div style="float: right">Describe field in 1-2 words<br /><input type="text" id="description" maxlength="50"></input></div></fieldset> \
            <fieldset><legend>Input Format</legend>\
                <select id="indicatorType">\
                    <option value="">None</option>\
                    <option value="text">Single line text</option>\
                    <option value="textarea">Multi-line text</option>\
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
                <div style="float: right">Default Answer<br /><textarea id="default"></textarea></div></fieldset> \
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
            html (for pages where the user can edit data): <button id="btn_codeSave_html" type="button" class="buttonNorm"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" /> Save Code<span id="codeSaveStatus_html"></span></button><textarea id="html"></textarea><br />\
            htmlPrint (for pages where the user can only read data): <button id="btn_codeSave_htmlPrint" type="button" class="buttonNorm"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" /> Save Code<span id="codeSaveStatus_htmlPrint"></span></button><textarea id="htmlPrint"></textarea><br />\
            Template Variables:<br />\
            <b>{{ iID }}</b> will be replaced with the indicatorID # of the data field\
        </div></div>');

    $('#indicatorType').on('change', function() {
    	switch($('#indicatorType').val()) {
    	    case 'radio':
    	    case 'checkboxes':
    	    case 'dropdown':
    	    	$('#container_indicatorMultiAnswer').css('display', 'block');
    	    	$('#container_indicatorSingleAnswer').css('display', 'none');
    		    break;
    	    case 'checkbox':
    	    	$('#container_indicatorMultiAnswer').css('display', 'none');
    	    	$('#container_indicatorSingleAnswer').css('display', 'block');
    	    	break;
    	    default:
    	    	$('#container_indicatorMultiAnswer').css('display', 'none');
    	        $('#container_indicatorSingleAnswer').css('display', 'none');
    	    	break;
    	}
    });
    $('#required').on('click', function() {
        if($('#indicatorType').val() == '') {
            $('#required').prop('checked', false);
            alert('You can\'t mark a field as required if the Input Format is "None".');
        }
    });
    $('#advNameEditor').on('click', function() {
    	$('#advNameEditor').css('display', 'none');
        $('#name').trumbowyg({
            resetCss: true,
            btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'link', '|', 'foreColor', '|', 'viewHTML']
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
                    && res[indicatorID].options.length > 0) {
                    for(var i in res[indicatorID].options) {
                        format += "\n" + res[indicatorID].options[i];
                    }
                }

                $('#name').html(res[indicatorID].name);
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
                var formatIdx = format.indexOf('\n');
                if(formatIdx != -1 && format.substr(0, formatIdx) != '') {
                    switch(format.substr(0, formatIdx)) {
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
    dialog.show();
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
                buffer += '<li>' + res[i].categoryName + ' [ <a href="#" onclick="unmergeForm(\''+ categoryID +'\', \''+ res[i].stapledCategoryID +'\');">Remove</a> ]</li>';
            }
            buffer += '</ul>';
            buffer += '<span class="buttonNorm" onclick="mergeForm(\''+ categoryID +'\');">Select a form to merge</span>';
            $('#mergedForms').html(buffer);
            dialog_simple.indicateIdle();
        },
        cache: false
    });

    dialog_simple.show();
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

function deleteForm() {
	var formTitle = categories[currCategoryID].categoryName == '' ? 'Untitled' : categories[currCategoryID].categoryName;
	dialog_confirm.setTitle('Delete Form?');
	dialog_confirm.setContent('Are you sure you want to delete the <b>'+ formTitle +'</b> form?');
	
	dialog_confirm.setSaveHandler(function() {
		$.ajax({
			type: 'DELETE',
			url: '../api/?a=formStack/_' + currCategoryID + '&CSRFToken=<!--{$CSRFToken}-->',
			success: function(res) {
				window.location.reload();
			}
		});
	});
	dialog_confirm.show();
}

function buildMenu(categoryID) {
	$('#menu').html('<div class="buttonNorm" onclick="postRenderFormBrowser = null; showFormBrowser();" style="font-size: 120%"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="View All Forms" /> View All Forms</div><br />');
	$('#menu').append('<div id="'+ categoryID +'" class="buttonNorm" style="font-size: 120%"><img src="../../libs/dynicons/?img=document-open.svg&w=32" alt="Open Form" />'+ categories[categoryID].categoryName +'</div>');
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
			$('#menu').append('<div id="'+ categories[i].categoryID +'" class="buttonNorm" style="font-size: 120%"><img src="../../libs/dynicons/?img=text-x-generic.svg&w=32" alt="Open Form" /> '+ categories[i].categoryName +'</div>');
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
	
	$('#menu').append('<br /><div class="buttonNorm" onclick="createForm(\''+ categoryID +'\');" style="font-size: 120%"><img src="../../libs/dynicons/?img=document-new.svg&w=32" alt="Create Form" /> Add Internal-Use</div><br />');
	
    $('#menu').append('<br /><div class="buttonNorm" onclick="mergeFormDialog(\''+ categoryID +'\');" style="font-size: 120%"><img src="../../libs/dynicons/?img=edit-copy.svg&w=32" alt="Staple Form" /> Staple other form</div><br />');

	$('#menu').append('<br /><div class="buttonNorm" onclick="exportForm(\''+ categoryID +'\');" style="font-size: 120%"><img src="../../libs/dynicons/?img=network-wireless.svg&w=32" alt="Export Form" /> Export Form</div><br />');

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
	$('#menu').html('<div class="buttonNorm" onclick="createForm();" style="font-size: 120%"><img src="../../libs/dynicons/?img=document-new.svg&w=32" alt="Create Form" /> Create Form</div><br />');
	$('#menu').append('<div class="buttonNorm" onclick="formLibrary();" style="font-size: 120%"><img src="../../libs/dynicons/?img=system-file-manager.svg&w=32" alt="Import Form" /> Form Library</div><br />');
	$('#menu').append('<br /><div class="buttonNorm" onclick="importForm();" style="font-size: 120%"><img src="../../libs/dynicons/?img=package-x-generic.svg&w=32" alt="Import Form" /> Import Form</div><br />');
	$('#menu').append('<br /><br /><div class="buttonNorm" onclick="window.location = \'?a=disabled_fields\';" style="font-size: 120%"><img src="../../libs/dynicons/?img=user-trash-full.svg&w=32" alt="Restore fields" /> Restore Fields</div>');
    $.ajax({
        type: 'GET',
        url: '<!--{$APIroot}-->?a=formStack/categoryList/all',
        success: function(res) {
            var buffer = '<div id="forms" style="padding: 8px"></div><br style="clear: both" /><hr style="margin-top: 32px" />Not associated with a workflow:<div id="forms_inactive" style="padding: 8px"></div>';
            $('#formEditor_content').html(buffer);
            for(var i in res) {
            	categories[res[i].categoryID] = res[i];
            	if(res[i].parentID == '') {
            		formTitle = res[i].categoryName == '' ? 'Untitled' : res[i].categoryName;
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
                    $(formActiveID).append('<div class="formPreview formLibraryID_'+ res[i].formLibraryID +'" id="'+ res[i].categoryID +'" title="'+ res[i].categoryID +'"><b>'+ formTitle + needToKnow + '</b>\
                    		<br /><br />\
                    		'+ res[i].categoryDescription +'\
                    		<br /><br />\
                    		<span style="vertical-align: bottom">'+ workflow +'</span>\
                    		</div>');
                    $('#' + res[i].categoryID).on('click', function(categoryID) {
                        return function() {
                            currCategoryID = categoryID;
                            buildMenu(categoryID);
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
	}
    dialog.setTitle('New Form');
    dialog.setContent('<table>\
    		             <tr>\
    		                 <td>Name for Form</td>\
    		                 <td><input id="name" type="text" maxlength="50"></input></td>\
    		             </tr>\
    		             <tr>\
    		                 <td>Description for Form</td>\
                             <td><textarea id="description" maxlength="255"></textarea></td>\
                         </tr>\
    		           </table>');
    dialog.show();

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
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
	dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
	
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

</script>