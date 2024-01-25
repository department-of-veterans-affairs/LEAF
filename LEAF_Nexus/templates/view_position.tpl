<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools"><h1>Tools</h1>
        <div onclick="window.location='?a=navigator&amp;rootID=<!--{$positionID|strip_tags}-->';"><img src="dynicons/?img=preferences-system-windows.svg&amp;w=32" style="vertical-align: middle" alt="Add Employee" title="Add Employee" /> View in Org Chart</div>
        <div onclick="addEmployee()"><img src="dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="Add Employee" title="Add Employee" /> Add Employee</div>
        <div onclick="editTitle()"><img src="dynicons/?img=edit-select-all.svg&amp;w=32" style="vertical-align: middle" alt="Edit" title="Edit" /> Edit Title</div>
        <div onclick="changeSupervisor()"><img src="dynicons/?img=system-users.svg&amp;w=32" style="vertical-align: middle" alt="Change Service" title="Change Service" /> Change Supervisor</div>
        <div onclick="window.location='mailto:?subject=FW:%20Org.%20Chart%20-%20&amp;body=Organizational%20Chart%20URL:%20<!--{if $smarty.server.HTTPS == on}-->https<!--{else}-->http<!--{/if}-->://<!--{$smarty.server.SERVER_NAME}--><!--{$smarty.server.REQUEST_URI|escape:'url'}-->%0A%0A'"><img src="dynicons/?img=mail-forward.svg&amp;w=32" style="vertical-align: middle" alt="Forward as Email" title="Forward as Email" /> Forward as Email</div>
        <br />
        <div onclick="confirmRemove()"><img src="dynicons/?img=process-stop.svg&amp;w=16" style="vertical-align: middle" alt="Delete Position" title="Delete Position" /> Delete Position</div>
    </div>

    <!-- <div style="background-color: white; border: 1px solid black; padding: 2px"><h1>Tags</h1>
        <div class="tags">
            <!--{foreach $tags as $tag}-->
            <span><!--{$tag}--> </span>
            <!--{/foreach}-->
            <!--{if $positionPrivileges[$positionID].write == 1}-->
            <span>Add Tag</span>
            <!--{/if}-->
        </div>
    </div> -->

    <div class="toolbar_group"><h1>Groups</h1>
        <div>
            <!--{if count($groups) == 0}-->
                None
            <!--{/if}-->
            <!--{foreach $groups as $group}-->
                <div> - <a href="?a=view_group&amp;groupID=<!--{$group.groupID|strip_tags}-->"><!--{$group.groupTitle|strip_tags}--></a></div>
            <!--{/foreach}-->
            <!--{if $positionPrivileges[$positionID].write == 1}-->
            <br /><br />
            <div class="buttonNorm" onclick="addGroup()">Assign Group</div>
            <!--{/if}-->
        </div>
    </div>
<br />
    <div class="toolbar_security"><h1>Security Permissions</h1>
        <div>
        <!--{if $positionPrivileges[$positionID].read == 1}-->
            <img src="dynicons/?img=edit-find.svg&amp;w=32" alt="Read Access" style="vertical-align: middle" /> You have read access
        <!--{else}-->
            <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="No Read Access" style="vertical-align: middle" /> You do not have read access
        <!--{/if}-->
        </div>
        <div>
        <!--{if $positionPrivileges[$positionID].write == 1}-->
            <img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="Write Access" style="vertical-align: middle" /> You have write access
        <!--{else}-->
            <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="No Write Access" style="vertical-align: middle" /> You do not have write access
        <!--{/if}-->
        </div>
        <!--{if $positionPrivileges[$positionID].grant != 0}-->
        <div class="buttonNorm" onclick="window.open('index.php?a=view_position_permissions&amp;positionID=<!--{$positionID}-->','Orgchart','width=840,resizable=yes,scrollbars=yes,menubar=yes').focus();">
            <img src="dynicons/?img=emblem-system.svg&amp;w=32" alt="Change Permissions" style="vertical-align: middle" /> Change Permissions
        </div>
        <!--{/if}-->
    </div>
</div>

<div id="maincontent">
    <div id="position">
        <div id="positionHeader">
            <span id="positionTitle"><!--{$positionSummary.title|sanitize}--></span><br />
            <!--{$counter = 0}-->
            <!--{foreach $positionSummary.services as $services}-->
            <span id="serviceName"><!--{if $counter++ > 0}-->- <!--{/if}--><!--{$services.groupTitle|sanitize}--></span>
            <!--{/foreach}-->&nbsp;

            <!--{$numSupervisors = 0}-->
            <span id="supervisor" style="float: right">Supervisor:
            <!--{foreach $positionSummary.supervisor as $supervisor}-->
                <!--{if $supervisor.firstName != ''}-->
                <a href="?a=view_position&amp;positionID=<!--{$supervisor.positionID|strip_tags}-->"><!--{$supervisor.firstName|sanitize}--> <!--{$supervisor.lastName|sanitize}-->
                    <!--{if $supervisor.isActing == 1}-->(Acting)<!--{/if}--></a>
                <!--{else if $supervisor.positionID != ''}-->
                <a href="?a=view_position&amp;positionID=<!--{$supervisor.positionID|strip_tags}-->">VACANT</a>
                <!--{/if}-->
            <!--{/foreach}-->
            </span>
        </div>
        <div id="positionBody">
            <div style="visibility: visible; text-align: center; font-size: 24px; font-weight: bold; padding: 16px; height: 95%; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
        </div>
        <!--{assign var=counter value=0}-->
        <!--{assign var=numActing value=0}-->
        <!--{if $positionSummary.employeeList[0].empUID != ''}-->
          <!--{foreach $positionSummary.employeeList as $employee}-->
          <!--{assign var=counter value=$counter + 1}-->
          <!--{if $employee.isActing != 0}-->
            <!--{assign var=numActing value=$numActing + 1}-->
          <!--{/if}-->
          <div id="employee_<!--{$counter}-->" class="employee">
              <div id="employeeHeader_<!--{$counter}-->" class="employeeHeader">
                  <img src="dynicons/?img=process-stop.svg&amp;w=16" style="float: right; cursor: pointer" onclick="confirmUnlink(<!--{$employee.empUID|strip_tags}-->); return false;" alt="Unlink Employee" title="Unlink Employee" />
                  <span id="employeeName_<!--{$counter}-->" class="employeeName" style="cursor: pointer" onclick="window.location='?a=view_employee&amp;empUID=<!--{$employee.empUID|strip_tags}-->'"><!--{$employee.lastName|sanitize}-->, <!--{$employee.firstName|sanitize}--><!--{if $employee.isActing == 1}--> <span style="font-weight: bold; color: blue">(Acting)</span><!--{/if}--></span>
              </div>
              <div id="employeeBody_<!--{$counter}-->" class="employeeBody">
                  <div style="visibility: visible; text-align: center; font-size: 24px; font-weight: bold; padding: 16px; height: 95%; width: 95%">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
              </div>
          </div>
          <!--{/foreach}-->
        <!--{/if}-->
          <!--{if $counter - $numActing < $positionSummary.positionData[19].data && $positionSummary.positionData[19].data != ''}-->
            <div class="employee">
                <div class="employeeHeader">
                    <span class="employeeName" style="cursor: pointer" onclick="addEmployee()">VACANT</span><br />
                </div>
                <div class="employeeBody">
                    <div class="button" onclick="startFTE()"><img src="dynicons/?img=document-new.svg&amp;w=32" style="vertical-align: middle" alt="Add Employee" title="Add Employee" /> Initiate FTE Request to fill Vacancy</div>
                </div>
            </div>
          <!--{else if $positionSummary.positionData[19].data == ''}-->
            <div class="employee">
                <div class="employeeHeader">
                    <span class="employeeName">No Vacancies?</span><br />
                </div>
                <div class="employeeBody">
                    The &quot;Total Headcount&quot; field will need to be increased to support more vacancies.
                </div>
            </div>
          <!--{/if}-->
    </div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<div id="start_requestxhrDialog" style="visibility: hidden">
<form id="start_requestrecord" enctype="multipart/form-data" action="javascript:void(0);">
    <div>
        <span id="start_requestbutton_cancelchange" class="buttonNorm" style="position: absolute; left: 10px"><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="cancel" /> Cancel</span>
        <div style="border-bottom: 2px solid black; line-height: 30px"><br /></div>
        <div id="start_requestloadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 100px; width: 460px">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
        <div id="start_requestxhr" style="width: 540px; height: 100px; overflow: auto; font-size: 12px"></div>
        <div id="start_requestbutton_save" class="buttonNorm" style="width: 80%"><img src="dynicons/?img=go-next.svg&amp;w=32" alt="save" /> Start FTE Request to fill <b><!--{$positionSummary.employeeList[0].positionTitle|sanitize}--></b></div>
        <br /><br />
    </div>
</form>
</div>


<div id="orgchartForm"></div>

<script type="text/javascript">
/* <![CDATA[ */

function assocEmployeePosition(empUID) {
    $.ajax({
        type: 'POST',
        url: './api/position/<!--{$positionID}-->/employee',
        data: {empUID: empUID,
            isActing: $('#isActing').prop('checked') ? 1 : 0,
            CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            window.location.reload();
        },
        cache: false
    });
}

function addEmployee() {
    dialog.setContent('Employee Search: <div id="employeeSelector"></div>\
    		<fieldset><legend>Options</legend>\
            <input id="isActing" type="checkbox"> Acting for vacant position</div>\
            </fieldset>');
    dialog.show(); // need to show early because of ie6

    empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.initialize();
//    empSel.setDomain('<!--{$userDomain}-->');
    empSel.clearSearch();

    dialog.setSaveHandler(function() {
    	if(empSel.selection != '') {
            dialog.indicateBusy();
            var selectedUserName = empSel.selectionData[empSel.selection].userName;
            $.ajax({
            	type: 'POST',
            	url: './api/employee/import/_' + selectedUserName,
            	data: {CSRFToken: '<!--{$CSRFToken}-->'},
            	success: function(res) {
            		if(!isNaN(res)) {
            			assocEmployeePosition(res);
            		}
            		else {
            			alert(res);
            		}
            	}
            });
    	}
    	else {
    		alert('An employee has not been selected.');
    	}
    });
}

function startFTE() {
	if('<!--{$positionSummary.services[0].groupID}-->' == '') {
		alert('Error: <!--{$positionSummary.employeeList[0].positionTitle}--> has not been configured with a service. Please contact your system administrator.');
		return false;
	}

    start_request_dialog.setContent('Description for this request (optional): <input class="dialogInput" id="description" type="text"></input>');
    start_request_dialog.show(); // need to show early because of ie6

    start_request_dialog.setSaveHandler(function() {
    	start_request_dialog.indicateBusy();
    	description = '';
    	if($('#description').val() != '') {
    		description = ' - ' + $('#description').val();
    	}
        $.ajax({
        	type: 'POST',
            url: '<!--{$ERM_site_resource_management}-->api/form/new',
            dataType: 'json',
            data: {service: '<!--{$positionSummary.services[0].groupID}-->',
                      title: '<!--{$positionSummary.title}-->' + description,
                      priority: 0,
                      numGeneral: 1,
                      numFTE: 1,
                      CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
            	var recordID = parseFloat(response);
            	if(!isNaN(recordID) && isFinite(recordID) && recordID != 0) {
            		$.ajax({
            			type: 'POST',
            			url: '<!--{$ERM_site_resource_management}-->api/form/' + recordID,
            			dataType: 'json',
            			data: {
            				7: <!--{$positionID}-->,
            				series: 1,
            				CSRFToken: '<!--{$CSRFToken}-->'
            			},
            			success: function() {
                            window.location = '<!--{$ERM_site_resource_management}-->?a=view&recordID=' + recordID;
            			},
            			cache: false
            		});
            	}
            	else {
            		start_request_dialog.hide();
            		alert(response + ' Error Triggering FTE request. Please visit the Resource Management site, and start your FTE request from there.');
            	}
                return response;
            },
            cache: false
        });
    });
}

function editTitle() {
    dialog.setContent('Position Title: <input id="inputtitle" style="width: 300px" class="dialogInput" value="<!--{$positionSummary.employeeList[0].positionTitle}-->"></input>');
    dialog.show(); // need to show early because of ie6

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
        	type: 'POST',
            url: './api/position/<!--{$positionID}-->/title',
            data: {title: $('#inputtitle').val(),
            	CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
}

function addGroup() {
    dialog.setContent('Group Search: <div id="groupSelector"></div><br /><fieldset><legend>Options</legend><input id="includeSub" type="checkbox" disabled="disabled" /> Apply to all subordinates</fieldset>');
    dialog.show(); // need to show early because of ie6

    grpSel = new groupSelector('groupSelector');
    grpSel.initialize();
    //grpSel.searchTag('service');

    dialog.setSaveHandler(function() {
        if (grpSel.selectionData[grpSel.selection].tags['service'] !== undefined && checkPosition(grpSel.selection)) {
            alert('Group is a Service and already has a set position.');
        } else {
            dialog.indicateBusy();
            $.ajax({
                type: 'POST',
                url: './api/group/'+ grpSel.selection +'/position',
                data: {positionID: <!--{$positionID}-->,
                       CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(response) {
                    window.location.reload();
                },
                cache: false
            });
        }
    });
}

/**
 * Check for Positions in group
 * @param groupID - ID of Group
 * @param returnValue - return value
 * @return true or false
 */
function checkPosition(groupID) {
    let returnValue = false;
    $.ajax({
        type: 'GET',
        async: false,
        url: './api/group/'+ groupID +'/positions',
        datatype: 'json',
        success: function(response) {
            if (response[0] !== undefined) {
                returnValue = true;
            }
        },
        cache: false
    });
    return returnValue;
}

function changeSupervisor() {
    dialog.setContent('Supervisor\'s Name or Title: <div id="positionSelector"></div>');
    dialog.show(); // need to show early because of ie6

    posSel = new positionSelector('positionSelector');
    posSel.initialize();
    posSel.enableEmployeeSearch();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
        	type: 'POST',
            url: './api/position/<!--{$positionID}-->/supervisor',
            data: {positionID: posSel.selection,
                      CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                if (Number.isInteger(response)) {
                    window.location.reload();
                } else {
                    dialog.setContent(`<strong style="display:table;margin:0 auto;"><img src="dynicons/?img=dialog-error.svg&amp;w=32" style="vertical-align:middle;float:left;">${response.errors[0]}</strong>`);
                }
            },
            cache: false
        });
    });
}

function confirmUnlink(empUID) {
	confirm_dialog.setContent('<img src="dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to unlink this employee?</span>');
	confirm_dialog.setTitle('Confirmation');
	confirm_dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'DELETE',
            url: './api/position/<!--{$positionID}-->/employee/' + empUID + '?' +
                $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
	confirm_dialog.show();
}

function confirmRemove() {
    confirm_dialog.setContent('<img src="dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to delete this position?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'DELETE',
            url: './api/position/<!--{$positionID}-->' + '?' +
                $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
            	if(response == 1) {
                    alert('Position has been deleted.');
                    history.back();
            	}
            	else {
            		alert('Error: ' + response);
            	}
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->

var dialog;
$(function() {
    //empSel = new employeeSelector('test');
    //empSel.initialize();

    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();
    orgchartForm.addUpdateEvent(19, function(response) {
        if(($('.employee').length - 1) < $('#data_19_2_<!--{$positionID}-->').html()) {
            window.location.reload();
        }
    });
    // include file="site_elements/orgchartForm_updateOutlook.js.tpl"

    // Load position form and data
    $.ajax({
        url: "ajaxPosition.php?a=getForm&pID=" + <!--{$positionID}-->,
        success: function(response) {
            if(response != '') {
                $('#positionBody').html(response);
            }
            else {
                $('#positionBody').html('');
            }
        },
        cache: false
    });

    // Load employee form and data
    <!--{assign var=counter value=0}-->
    <!--{foreach $positionSummary.employeeList as $employee}-->
    <!--{assign var=counter value=$counter + 1}-->
        <!--{if $employee.empUID != ''}-->
        $.ajax({
            url: "ajaxEmployee.php?a=getForm&empUID=<!--{$employee.empUID}-->",
            success: function(response) {
                if(response != '') {
                    $('#employeeBody_<!--{$counter}-->').html(response);
                    // if it's a long list, use an abridged format
                    if(<!--{$numEmployees}--> > 2) {
                    	$('.employee .printformblock').css({'display': 'none'});
                    	$('#employeeHeader_<!--{$counter}-->').append('<div class="tempText" style="float: right; border: 1px solid black; background-color: #FFE3E3; padding: 2px; margin: 4px">'+ $('span[id^="data_5_1_<!--{$employee.empUID}-->"]').html() +'<br />'+ $('span[id^="data_6_1_<!--{$employee.empUID}-->"]').html() +'</div><br /><br />');
                    }
                }
                else {
                    $('#employeeBody_<!--{$counter}-->').html('');
                }
            },
            cache: false
        });
        <!--{/if}-->
    <!--{/foreach}-->

    // find FTE requests, if available
    <!--{if $ERM_site_resource_management != ''}-->
    //$.ajax({

    //});
    <!--{/if}-->

    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
   	start_request_dialog = new dialogController('start_requestxhrDialog', 'start_requestxhr', 'start_requestloadIndicator', 'start_requestbutton_save', 'start_requestbutton_cancelchange');
    confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
});

/* ]]> */
</script>
