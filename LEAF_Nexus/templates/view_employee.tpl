<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools"><h1>Tools</h1>
    <!--{if $is_admin == true}-->
        <button type="button" class="options" onclick="refreshEmp('<!--{$summary.employee.userName|escape:"quotes"}-->');"><img src="dynicons/?img=system-software-update.svg&w=32" style="vertical-align: middle" alt="Refresh Employee" title="Refresh Employee" /> Refresh Employee</button>
      <!--{/if}-->
        <button type="button" class="options" onclick="assignBackup();"><img src="dynicons/?img=gnome-system-users.svg&amp;w=32" style="vertical-align: middle" alt="" /> Assign Backup</button>
<!--{if $summary.employee.deleted == 0}-->
        <button type="button" class="options" id="disable_account_<!--{$empUID}-->" onclick="disableAccount();"><img src="dynicons/?img=process-stop.svg&amp;w=32" style="vertical-align: middle" alt="" /> Disable Account</button>
        <button type="button" class="options notrequired" id="enable_account_<!--{$empUID}-->" onclick="enableAccount();"><img src="dynicons/?img=edit-redo.svg&amp;w=32" style="vertical-align: middle" alt="" /> Enable Account</button>
<!--{else}-->
        <button type="button" class="options notrequired" id="disable_account_<!--{$empUID}-->" onclick="disableAccount();"><img src="dynicons/?img=process-stop.svg&amp;w=32" style="vertical-align: middle" alt="" /> Disable Account</button>
        <button type="button" class="options" id="enable_account_<!--{$empUID}-->" class="" onclick="enableAccount();"><img src="dynicons/?img=edit-redo.svg&amp;w=32" style="vertical-align: middle" alt="" /> Enable Account</button>
<!--{/if}-->
<!--         <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=emblem-train.svg&amp;w=32" style="vertical-align: middle" alt=""  /> Request Travel/Training</div>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=car.svg&amp;w=32" style="vertical-align: middle" alt="" /> Request Govt. Vehicle</div>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=emblem-parking.svg&amp;w=32" style="vertical-align: middle" alt="" /> Request Parking Decal</div>
        <div onclick="alert('Not implemented yet');"><img src="dynicons/?img=award-ribbon.svg&amp;w=32" style="vertical-align: middle" alt="" /> Recommend for Award</div>
 -->
    </div>
</div>

<div id="maincontent">
    <div id="employee" style="max-width: 400px">
        <div id="employeeHeader">
            <div id="employeeName">Employee Search:</div>
            <div id="employeeAccount"></div>
        </div>
        <div id="employeeBody">
                <div id="employeeSelector"></div>
        </div>
    </div>
    <div id="position" style="width: 400px; margin-left: 8px">
        <div id="positionHeader">
            <span id="positionTitle">Position Assignments</span>
        </div>
        <div id="positionBody">
            <ul>
        <!--{foreach $summary.employee.positions as $position}-->
                <li id="pos_<!--{$position.positionID|strip_tags}-->"><!--{$position.positionID|strip_tags}--></li>
        <!--{/foreach}-->
            </ul>
        </div>
    </div>
    <div id="group" style="width: 400px; margin: 8px">
        <div id="groupHeader">
            <span id="groupTitle">Group Assignments</span>
        </div>
        <div id="groupBody" style="width: 100%">
            <ul>
            <!--{foreach $groups as $group}-->
                <li><a href="?a=view_group&groupID=<!--{$group.groupID|strip_tags}-->"><!--{$group.groupTitle|sanitize}--></a></li>
            <!--{/foreach}-->
            </ul>
        </div>
    </div>
    <div id="backup" style="float: left; width: 400px; margin: 8px; border: 1px solid black">
        <div id="backupHeader" style="padding: 4px">
            <span id="backupTitle">Backup for <!--{$summary.employee.firstName|sanitize}--> <!--{$summary.employee.lastName|sanitize}--></span>
        </div>
        <div id="backupBody" style="width: 100%; padding: 4px 4px 4px 16px"></div>
    </div>
    <div id="backupFor" style="float: left; width: 400px; margin: 8px; border: 1px solid black">
        <div id="backupForHeader" style="padding: 4px">
            <span id="backupForTitle"><!--{$summary.employee.firstName|sanitize}--> <!--{$summary.employee.lastName|sanitize}--> serves as a backup for</span>
        </div>
        <div id="backupForBody" style="width: 100%; padding: 4px 4px 4px 16px"></div>
    </div>
</div>

<div id="orgchartForm"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_OkDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->


function refreshEmp(userName) {
    var CSRFToken = '<!--{$CSRFToken}-->';

    $.ajax({
        type: 'POST',
        url: "./api/employee/refresh/_" + userName,
        dataType: "json",
        data: {CSRFToken: CSRFToken},
        success: function(res) {
            let response = $.parseJSON(res);

            if (response.status['code'] == 2) {
                $.each(response.data.user_data, function (index, value) {
                    $('#data_' + value['indicatorID'] + '_1_' + response.data.user[0]['empUID']).html(value['data']);

                    if (value['indicatorID'] == 23) {
                        $('#mainblock_' + value['indicatorID'] + '_' + response.data.user[0]['empUID']).removeClass('notrequired');
                    }
                });
                dialog_ok.setTitle('Employee Refreshed');
                dialog_ok.setContent('The Employee has successfully been updated.');
                dialog_ok.setSaveHandler(function() {
                    dialog_ok.clearDialog();
                    dialog_ok.hide();
                });
                dialog_ok.show();
            } else {
                dialog_ok.setTitle('Employee Disabled');
                dialog_ok.setContent(response.status['message']);
                dialog_ok.setSaveHandler(function() {
                    dialog_ok.clearDialog();
                    dialog_ok.hide();
                    $("#enable_account_<!--{$empUID}-->").show();
                    $("#disable_account_<!--{$empUID}-->").hide();
                    $("#disabled_label").show();
                });
                dialog_ok.show();
            }

            //alert("Employee Refreshed");
            //location.reload();
        },
        error: function (err) {
            console.log(err);
        },
        cache: false
    });
}

function getBackupInfo() {
    // get backup info
    $('#backupBody').html('');
    $.ajax({
        url: "./api/employee/" + <!--{$empUID}--> + "/backup",
        success: function(response) {
            if(response != '') {
                for(var key in response) {
                    $('#backupBody').append('<div id="backup_'+ response[key].backupEmpUID +'">'+response[key].backupEmpUID+'</div>');
                    $.ajax({
                        url: "./api/employee/" + response[key].backupEmpUID,
                        success: function(response) {
                            $('#backup_'+response.employee.empUID).html(response.employee.firstName + ' ' + response.employee.lastName + ' [ <a href="#" onclick="removeBackup('+ response.employee.empUID +');">Remove</a> ]');
                        },
                        cache: false
                    });
                }
            }
            else {
                $('#backupBody').html('None');
            }
        },
        cache: false
    });
}

function getBackupForInfo() {
    // get backup for info
    $('#backupForBody').html('');
    $.ajax({
        url: "./api/employee/" + <!--{$empUID}--> + "/backupFor",
        success: function(response) {
            if(response != '') {
                for(var key in response) {
                    $('#backupForBody').append('<div id="backupFor_'+ response[key].empUID +'">'+response[key].empUID+'</div>');
                    $.ajax({
                        url: "./api/employee/" + response[key].empUID,
                        success: function(response) {
                            $('#backupFor_'+response.employee.empUID).html(response.employee.firstName + ' ' + response.employee.lastName);
                        },
                        cache: false
                    });
                }
            }
            else {
                $('#backupForBody').html('None');
            }
        },
        cache: false
    });
}

function removeBackup(backupEmpUID) {
    confirm_dialog.setContent('<img src="dynicons/?img=help-browser.svg&amp;w=48" alt="" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to remove this backup?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
            type: 'DELETE',
            url: './api/employee/<!--{$empUID}-->/backup/' + backupEmpUID + '?' +
                $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
            	getBackupInfo();
            	confirm_dialog.hide();
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

function assignBackup() {
	dialog.setTitle('Assign backup');
    dialog.setContent('Employee Search: <div id="employeeSelector"></div>');
    dialog.show(); // need to show early because of ie6

    empSel = new nationalEmployeeSelector('employeeSelector');
    empSel.initialize();
    empSel.clearSearch();

    dialog.setSaveHandler(function() {
        if(empSel.selection != '') {
            dialog.indicateBusy();
            var selectedUserName = empSel.selectionData[empSel.selection].userName;
            $.ajax({
                type: 'POST',
                url: './api/employee/import/_' + selectedUserName,
                data: {CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(empUID) {
                    if(!isNaN(empUID)) {
                        $.ajax({
                            type: 'POST',
                            url: './api/employee/<!--{$empUID}-->/backup',
                            data: {backupEmpUID: empUID,
                                CSRFToken: '<!--{$CSRFToken}-->'},
                            success: function(response) {
                                getBackupInfo();
                                dialog.hide();
                            },
                            cache: false
                        });
                    }
                    else {
                        alert(empUID);
                    }
                }
            });
        }
        else {
            alert('An employee has not been selected.');
        }
    });
}

function disableAccount(backupEmpUID) {
    confirm_dialog.setContent('<img src="dynicons/?img=help-browser.svg&amp;w=48" alt="" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to disable this account?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
            type: 'DELETE',
            url: './api/employee/<!--{$empUID}-->' + '?' +
                $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
                confirm_dialog.hide();
                if(response == true) {
                    $("#enable_account_<!--{$empUID}-->").show();
                    $("#disable_account_<!--{$empUID}-->").hide();
                    $("#disabled_label").show();
                    alert('The account has been disabled.');

                    //window.location.reload();
                }
            },
            error: function (err) {
                console.log(err);
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

function enableAccount(backupEmpUID) {
    confirm_dialog.setContent('<img src="dynicons/?img=help-browser.svg&amp;w=48" alt="" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to enable this account?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
            type: 'POST',
            url: './api/employee/<!--{$empUID}-->/activate',
            data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                confirm_dialog.hide();
                if(response == true) {
                    $("#enable_account_<!--{$empUID}-->").hide();
                    $("#disable_account_<!--{$empUID}-->").show();
                    $("#disabled_label").hide();
                    alert('The account has been enabled.');
                    //window.location.reload();
                }
            },
            error: function (err) {
                console.log(err);
            },
            cache: false
        });
    });
    confirm_dialog.show();
}

var empSel;
var intval;
var dialog;
var confirm_dialog;
$(function() {
	var positionData = new Object();

    $.ajax({
        url: "ajaxEmployee.php?a=getForm&empUID=<!--{$empUID}-->",
        success: function(response) {
            if(response != '') {
                const content = '<!--{$summary.employee.firstName|escape}--> <!--{$summary.employee.lastName|escape}-->' +
                 ' <span id="disabled_label" <!--{if $summary.employee.deleted == 0}-->style="display: none;"<!--{/if}-->">(Disabled account)</span>';
                $('#employeeName').html(content);
                $('#employeeAccount').html("<!--{$summary.employee.userName}-->");
                $('#employeeBody').html(response);
            }
            else {
                $('#maincontent').html('');
            }
        },
        cache: false
    });
    $('#tools').css('visibility', 'visible');

    // import position data
    <!--{foreach $summary.employee.positions as $position}-->
    $.ajax({
        url: "./api/position/" + <!--{$position.positionID}-->,
        success: function(response) {
            if(response != '') {
                $("#pos_" + <!--{$position.positionID}-->).html('<a href="?a=view_position&positionID=<!--{$position.positionID}-->">' + response.title + '</a>');
            }
        },
        cache: false
    });
    <!--{/foreach}-->

    getBackupInfo();
    getBackupForInfo();

    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    <!--{include file="site_elements/orgchartForm_updateOutlook.js.tpl"}-->
    dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok', 'confirm_button_cancelchange');
});

/* ]]> */
</script>
