<div id="maincontent">
    <div id="group">
        <div tabindex="0" id="groupHeader">
            <span id="groupTitle"><!--{$group[0].groupTitle|sanitize}-->
            <!--{if $group[0].groupAbbreviation != ''}-->
                (<!--{$group[0].groupAbbreviation}-->)
            <!--{/if}-->
            </span><br />
        </div>
        <div id="groupBody">
            <div style="visibility: visible; text-align: center; font-size: 24px; font-weight: bold; padding: 16px; height: 95%; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
        </div>


        <div id="position" class="position">
            <div tabindex="0" id="positionHeader" class="positionHeader">
                <span id="positionName" class="positionName">Positions</span><br />
            </div>
            <div tabindex="0" id="positionBody" class="positionBody">
                <div tabindex="0" style="visibility: visible; text-align: center; font-size: 24px; font-weight: bold; padding: 16px; height: 95%; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
            </div>
        </div>

        <div id="employee" class="employee">
            <div tabindex="0" id="employeeHeader" class="employeeHeader">
                <span id="employeeName" class="employeeName">Employees</span><br />
            </div>
            <div tabindex="0" id="employeeBody" class="employeeBody" style="line-height: 220%">
                <div tabindex="0" style="visibility: visible; text-align: center; font-size: 24px; font-weight: bold; padding: 16px; height: 95%; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
            </div>
        </div>
    </div>
</div>

<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools"><h1 tabindex="0">Options</h1>
        <!--{if array_search('service', $tags) !== false}-->
        <div id="view_orgchart" ><a role="button" href="?a=navigator&amp;rootID=<!--{$groupLeader|sanitize}-->"></a><img src="../libs/dynicons/?img=preferences-system-windows.svg&amp;w=32" style="vertical-align: middle" alt="View Org Chart" title="View Org Chart" /> View in Org Chart</div>
        <br />
        <!--{/if}-->
        <button class="options" onclick="editGroupName()" style="width: 100%"><img src="../libs/dynicons/?img=edit-select-all.svg&amp;w=32" style="vertical-align: middle" alt="Edit" title="Edit" /> Edit Group Name</button>
        <button class="options" id="button_addEmployeePosition" onclick="addEmployeePosition()" style="width: 100%"><img src="../libs/dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="Add Employee/" title="Add Employee/Position" /> Add Employee/Position</button>
        <br />
        <br />
        <button class="options" onclick="confirmRemove()" style="width: 100%"><img src="../libs/dynicons/?img=process-stop.svg&amp;w=16" style="vertical-align: middle" alt="Delete Position" title="Delete Position" /> Delete Group</div>
    </button>

    <div class="toolbar_tags"><h1 tabindex="0">Tags</h1>
        <div class="tags">
            <!--{foreach $tags as $tag}-->
            <span tabindex="0" onkeypress="triggerClick(event, confirmDeleteTag('<!--{$tag}-->'))" onclick="confirmDeleteTag('<!--{$tag}-->')"><!--{$tag}--></span>
            <!--{/foreach}-->
            <!--{if $groupPrivileges[$groupID].write == 1}-->
            <br /><br />
            <!--{foreach $tag_hierarchy as $tag}-->
            <button class="buttonNorm" style="width: 100%" onclick="writeTag('<!--{$tag.tag}-->');">Add '<!--{$tag.tag}-->'</button>
            <!--{/foreach}-->
            <br />
            <br />
            <button class="buttonNorm" style="width: 100%" onclick="addTag();">Add Custom Tag</button>
            <!--{/if}-->
        </div>
    </div>
<br />
    <div class="toolbar_security"><h1 tabindex="0">Security Permissions</h1>
        <div tabindex="0">
        <!--{if $groupPrivileges[$groupID].read != 0}-->
            <img src="../libs/dynicons/?img=edit-find.svg&amp;w=32" alt="Read Access" style="vertical-align: middle" /> You have read access
        <!--{else}-->
            <img src="../libs/dynicons/?img=emblem-readonly.svg&amp;w=32" alt="No Read Access" style="vertical-align: middle" /> You do not have read access
        <!--{/if}-->
        </div>
        <div tabindex="0">
        <!--{if $groupPrivileges[$groupID].write != 0}-->
            <img src="../libs/dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="Write Access" style="vertical-align: middle" /> You have write access
        <!--{else}-->
            <img src="../libs/dynicons/?img=emblem-readonly.svg&amp;w=32" alt="No Write Access" style="vertical-align: middle" /> You do not have write access
        <!--{/if}-->
        </div>
        <!--{if $groupPrivileges[$groupID].grant != 0}-->
        <button class="buttonPermission"  style="width: 100%" onclick="window.open('index.php?a=view_group_permissions&amp;groupID=<!--{$groupID}-->','OrgChart','width=840,resizable=yes,scrollbars=yes,menubar=yes');">
            <img src="../libs/dynicons/?img=emblem-system.svg&amp;w=32" alt="Change Permissions" style="vertical-align: middle" tabindex="0" /> Change Permissions
        </button>
        <!--{/if}-->
    </div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<div id="orgchartForm"></div>

<script type="text/javascript">

var tags = {};
<!--{foreach $tags as $tag}-->
tags['<!--{$tag}-->'] = '<!--{$tag}-->';
<!--{/foreach}-->

function triggerClick(e, id) {
    if(e.keyCode === 13) {
        $('#' + id).trigger('click');
    }
}

$('#view_orgchart').on('focusin', function() {
    $('#view_orgchart').css('background-color', '#2372b0');
    $('#view_orgchart').css('color', 'white');
});
$('#view_orgchart').on('focusout', function() {
    $('#view_orgchart').css('background-color', '#e8f2ff');
    $('#view_orgchart').css('color', 'black');
});

function editGroupName() {
    dialog.setContent('<div tabindex="0" style="display: inline">Group Name: </div><input id="inputtitle" style="width: 300px" class="dialogInput" value="<!--{$group[0].groupTitle}-->"></input><br /><br />\
    		<div tabindex="0" style="display: inline">Alternate Names: </div><input id="abrinputtitle" style="width: 300px" class="dialogInput" value="<!--{$group[0].groupAbbreviation}-->"></input>');
    dialog.show(); // need to show early because of ie6

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
            type: 'POST',
            url: './api/?a=group/<!--{$groupID}-->/title',
            data: {title: $('#inputtitle').val(),
            	abbreviatedTitle: $('#abrinputtitle').val(),
            	CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
}

function addEmployeePosition() {
    dialog.setContent('<div tabindex="0" style="display: inline">Employee/Position: </div><div id="positionSelector"></div><div id="employeeSelector"></div><br />\
    		       		<fieldset><legend>Options</legend>\
    		       		<div tabindex="0" id="container_ignorePositions"><input id="ignorePositions" type="checkbox" value="employeeOnly" /> Search Employees Only</div>\
    		       		<div tabindex="0" id="container_includeSub"><input id="includeSub" type="checkbox" value="applyRecursive" disable="disabled" /> Apply to all subordinates</div>\
    		       		</fieldset>');
    dialog.show(); // need to show early because of ie6

    var isService = 0;
    // If this is a service, don't allow adding all subordinates
    if(tags['service'] != undefined) {
    	isService = 1;
    	$('#container_ignorePositions').css('display', 'none');
        $('#container_includeSub').css('display', 'none');
    }

    empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.initialize();
//    empSel.setDomain('<!--{$userDomain}-->');
    empSel.hideInput();

    posSel = new positionSelector('positionSelector');
    posSel.initialize();
    posSel.enableEmployeeSearch();

    var ignorePositions = false;
    $('#ignorePositions').on('click', function() {
    	if($('#ignorePositions:checked').val() != undefined) {
    		ignorePositions = true;
    		empSel.showInput();
    		posSel.hideInput();
    		posSel.hideResults();
            empSel.showResults();
    		empSel.forceSearch(posSel.q);
    	}
    	else{
    		ignorePositions = false;
    		empSel.hideInput();
            posSel.showInput();
            posSel.showResults();
            empSel.hideResults();
    	}
    });

    posSel.setResultHandler(function() {
    	if(ignorePositions == false) {
            if(posSel.numResults == 0
            	&& isService == 0) {
                posSel.hideResults();
                empSel.showResults();
                empSel.forceSearch(posSel.q);
            }
            else {
                posSel.showResults();
                empSel.hideResults();
            }
    	}
    });

    dialog.setSaveHandler(function() {
        if(posSel.selection != ''
        	&& ignorePositions == false) {
            dialog.indicateBusy();
            $.ajax({
                type: 'POST',
                url: './api/?a=group/<!--{$groupID}-->/position',
                data: {positionID: posSel.selection,
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(response) {
                    window.location.reload();
                },
                cache: false
            });
        }
        else if(empSel.selection != '') {
            dialog.indicateBusy();
            var selectedUserName = empSel.selectionData[empSel.selection].userName;
            $.ajax({
                type: 'POST',
                url: './api/employee/import/_' + selectedUserName,
                data: {CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                    if(!isNaN(res)) {
                        $.ajax({
                            type: 'POST',
                            url: './api/?a=group/<!--{$groupID}-->/employee',
                            data: {empUID: res,
                                CSRFToken: '<!--{$CSRFToken}-->'},
                            success: function(response) {
                                window.location.reload();
                            },
                            cache: false
                        });
                    }
                    else {
                        alert(res);
                    }
                }
            });
        }
        else {
        	alert('You must select an employee or position');
        }
    });
}

function confirmRemove() {
	var warning = '';
	<!--{if count($tags) > 1}-->
	   warning = '<br /><span style="color: red">WARNING: This group may be shared by other projects. Check &quot;Tags&quot; to see which projects are using this group.</span>';
	<!--{/if}-->
    confirm_dialog.setContent('<img src="../libs/dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to delete this group?</span>' + warning);
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
    	$.ajax({
            type: 'DELETE',
            url: './api/?a=group/<!--{$groupID}-->&' + $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
            	if(response == 1) {
            		alert('Group has been deleted.');
                    history.back();
            	}
            	else {
            		alert(response);
            	}
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

function confirmUnlinkPosition(positionID) {
	confirm_dialog.setContent('<img src="../libs/dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to remove this position?</span>');
	confirm_dialog.setTitle('Confirmation');
	confirm_dialog.setSaveHandler(function() {
		$.ajax({
            type: 'DELETE',
            url: './api/?a=group/<!--{$groupID}-->/position/' + positionID + '&'
                    + $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
	confirm_dialog.show();
}

function confirmUnlinkEmployee(empUID) {
    confirm_dialog.setContent('<img src="../libs/dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to remove this employee?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'DELETE',
            url: './api/?a=group/<!--{$groupID}-->/employee/' + empUID + '&'
            		+ $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

function confirmDeleteTag(inTag) {
    confirm_dialog.setContent('<img src="../libs/dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to delete this tag?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'DELETE',
            url: './api/?a=group/<!--{$groupID}-->/tag&'
            		+ $.param({tag: inTag,
            		    CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

function writeTag(input) {
    $.ajax({
    	type: 'POST',
        url: './api/?a=group/<!--{$groupID}-->/tag',
        data: {tag: input,
            CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
        	if(response == true) {
        		window.location.reload();
        	}
        	else {
        		alert(response);
        	}
        },
        cache: false
    });
}

function addTag() {
    dialog.setContent('Tag Name: <input tabindex="0" id="inputtitle" style="width: 300px" class="dialogInput" value=""></input>');
    dialog.show(); // need to show early because of ie6

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        writeTag($('#inputtitle').val());
    });
}

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->

var dialog;
$(function() {
    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();

    // Load group form and data
    $.ajax({
        url: "ajaxGroup.php?a=getForm&groupID=" + <!--{$groupID}-->,
        success: function(response) {
            if(response != '') {
                $('#groupBody').html(response);
            }
            else {
                $('#groupBody').html('');
            }
        },
        cache: false
    });
    $.ajax({
        url: "./api/group/" + <!--{$groupID}--> + "/positions",
        dataType: 'json',
        success: function(response) {
            if(response != '') {
            	positions = '';
            	for(var id in response) {
            		positions += '<div style="background-color: #e6f5ff">&#10148; <a href="?a=view_position&positionID='+response[id].positionID+'" style="font-size: 120%; font-weight: bold">' + response[id].positionTitle + '</a> [ <a href="#" onclick="confirmUnlinkPosition('+ response[id].positionID +'); return false;">Remove</a> ]<ul id="pos_'+ response[id].positionID +'"></ul></div>';
            	}
                $('#positionBody').html(positions);

                // discourage users from adding more than one position for services
                if(response.length >= 1
                	&& tags['service'] != undefined) {
                	$('#button_addEmployeePosition').css('display', 'none');
                }

                for(var id in response) {
                    $.ajax({
                        url: "./api/position/" + response[id].positionID + "/employees",
                        dataType: 'json',
                        success: function(employees) {
                            if(employees != '') {
                            	for(var t in employees) {
                            		name = '<span style="color: red">VACANT</span>';
                            		if(employees[t].lastName) {
                            			name = employees[t].lastName + ', ' + employees[t].firstName;
                            		}
                            		$('#pos_' + employees[t].positionID).append('<li>' + name + '</li>');
                            	}
                            }
                        },
                        cache: false
                    });
                }
            }
            else {
                $('#positionBody').html('');
            }
        },
        cache: false
    });
    $.ajax({
        url: "./api/group/" + <!--{$groupID}--> + "/employees",
        dataType: 'json',
        success: function(response) {
            if(response != '') {
                employees = '';
                for(var id in response) {
                	employees += '<div><a class="buttonNorm" href="?a=view_employee&empUID='+response[id].empUID+'">' + response[id].lastName + ', ' + response[id].firstName +'</a> [ <a href="#" onclick="confirmUnlinkEmployee('+ response[id].empUID +'); return false;"> Remove</a> ]</div>';
                }
            	$('#employeeBody').html(employees);
            }
            else {
                $('#employeeBody').html('');
            }
        },
        cache: false
    });

    <!--{if $groupID >= 2 && $groupID <= 10}-->
    alert('This is a special group for internal use. Do not modify.');
    <!--{/if}-->

    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
});

</script>
