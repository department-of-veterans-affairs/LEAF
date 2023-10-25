<style>
    .employeeSelectorInput {
        border: 1px solid #bbb;
    }
</style>

<div class="leaf-center-content">


    <!-- LEFT SIDE NAV -->
    <!--{assign var=left_nav_content value="
        <aside class='sidenav'>
            <div id='sideBar'>
                <button id='btn_uploadFile' class='usa-button leaf-width-12rem' onclick='syncServices();'>
                    Import from Nexus
                </button>
            </div>
        </aside>
    "}-->
    <!--{include file="partial_layouts/left_side_nav.tpl" contentLeft="$left_nav_content"}-->

    <main class="main-content">

        <h2>Service Chiefs</h2>

        <div>
            <div id="groupList"></div>
        </div>

        <div class="leaf-row-space"></div>

    </main>

    <!-- RIGHT SIDE NAV -->
    <!--{assign var=right_nav_content value="
        <aside class='sidenav-right'></aside>
    "}-->
    <!--{include file="partial_layouts/right_side_nav.tpl" contentRight="$right_nav_content"}-->

</div>


<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

/**
 * Sync current list of services to that in the Nexus.
 */
function syncServices() {
    dialog_simple.setTitle('Importing from Nexus...');
    dialog_simple.show();
    $.ajax({
        type: 'GET',
        url: "../scripts/sync_services.php",
        success: function(response) {
            dialog_simple.setContent(response);
        },
        fail: function(error) {
            console.log(error);
        },
        cache: false
    });
    dialog_simple.setCancelHandler(function() {
        location.reload();
    });
}

/**
 * Create new service. [DEPRECATED]
 */
function createGroup() {
	/*
	dialog.clear();
    dialog.setTitle('Create new service');
    dialog.setContent('<b><span style="color: red">Before you proceed</span>, You should contact your Org Chart Administrators to determine whether the service needs to be added to the Org. Chart.</b>\
    		<br /><br />If the service is created in the Org. Chart, DO NOT create it here. Instead, click on "Sync Services" in the Admin Panel.\
    		<br /><br />Select Division: <select id="division"></select>\
    		<br /><br />Service Name: <input id="service" type="text"></input>');

    $.ajax({
    	type: 'GET',
    	url: '../api/service/quadrads',
    	success: function(res) {
    		for(let i in res) {
                $('#division').append('<option value="'+ res[i].groupID+'">'+ res[i].name +'</option>');
    		}
    	},
        cache: false
    });

    dialog.setSaveHandler(function() {
         $.ajax({
             type: 'POST',
             url: '../api/service',
             data: {'service': $('#service').val(),
            	 'groupID': $('#division').val(),
                 'CSRFToken': '<!--{$CSRFToken}-->'},
             success: function(res) {
                 location.reload();
             },
             cache: false
         });

        dialog.hide();
    });

    dialog.show();*/

    dialog_simple.setTitle('Create new service');
    dialog_simple.setContent('Changes to services must be made through Links->Nexus at the moment.');

    dialog_simple.show();
}

/**
 * Get members for given service.
 * @param {int} groupID - ID for group
 */
function getMembers(groupID = -1) {
    $.ajax({
        type: 'GET',
        url: '../api/system/updateService/' + groupID,
        success: function(res) {
            $.ajax({
                url: "../api/service/" + groupID + "/members",
                dataType: "json",
                success: function(response) {
                    $('#members' + groupID).fadeOut();
                    populateMembers(groupID, response);
                    $('#members' + groupID).fadeIn();
                },
                fail: function(error) {
                    console.log(error);
                },
                cache: false
            });
        },
        cache: false
    });
}

/**
 * Populate the members of a given service.
 * @param {int} groupID - ID of given group
 * @param {array} members - list object of all members in group
 */
function populateMembers(groupID = -1, members = []) {
    if (groupID < 0 || members.length === 0) {
        return;
    }
    $('#members' + groupID).html('');
    let memberCt = -1;
    for (let i in members) {
        if (members[i].active == 1 && members[i].backupID == '') {
            memberCt++;
        }
    }
    let countTxt = (memberCt > 0) ? (' + ' + memberCt + ' others') : '';
    for (let i in members) {
        if (members[i].active == 1 && members[i].backupID == '') {
            if ($('#members' + groupID).html('')) {
                $('#members' + groupID).append('<div class="groupUserFirst">' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + countTxt + '</div>');
            }
            $('#members' + groupID).append('<div class="groupUser">' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + ' <div>');
        }
    }
}

/**
 * Add user to portal
 * @param {int} groupID - ID of group
 * @param {int} userID - ID of user being added
 */
function addUser(groupID = -1, userID = '') {
    if (groupID < 0 || userID == '') {
        return;
    } else {
        $.ajax({
            type: 'POST',
            url: "../api/service/" + groupID + "/members",
            data: {'userID': userID,
                'CSRFToken': '<!--{$CSRFToken}-->'},
            cache: false
        });
    }
}

/**
 * Remove user from portal.
 * @param {int} groupID - ID of group
 * @param {int} userID - ID of user being removed
 */
function removeUser(groupID = -1, userID = '') {
    if (groupID < 0 || userID == '') {
        return;
    } else {
        $.ajax({
            async: false,
            type: 'POST',
            url: "../api/service/" + groupID + "/members/_" + userID,
            data: {'CSRFToken': '<!--{$CSRFToken}-->'},
            fail: function(err) {
                console.log(err);
            },
            cache: false
        });
    }
}

/**
 * Import user from orgchart.
 * @param {int} serviceID - ID of service
 * @param {string} selectedUserName - Username being imported
 */
function importUser(serviceID = 0, selectedUserName = '') {
    if (serviceID === 0 || selectedUserName === '') {
        return;
    } else {
        $.ajax({
            type: 'POST',
            url: '<!--{$orgchartPath}-->/api/employee/import/_' + selectedUserName,
            data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if (!isNaN(res)) {
                    addUser(serviceID, selectedUserName); // add identified user into portal.
                } else {
                    alert(res);
                }
            },
            fail: function(err) {
                console.log(err);
            },
            cache: false
        });
    }
}

/**
 * Delete given service.
 * @param {int} serviceID - ID of the service
 */
function deleteService(serviceID = 0) {
    if (serviceID === 0) {
        return;
    } else {
        $.ajax({
            type: 'DELETE',
            url: "../api/service/" + serviceID + '?' +
                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
            success: function(response) {
                location.reload();
            },
            fail: function(error) {
                console.log(error);
            },
            cache: false
        });
    }
}

/**
 * Build the modal for when the user selects a service.
 * @param {int} serviceID - ID of service
 * @param {string} serviceName - Name of the service
 */
function initiateModal(serviceID = 0, serviceName = '') {
    if (serviceID === 0 || serviceName === '') {
        return;
    } else {
        $.ajax({
            type: 'GET',
            url: '../api/service/' + serviceID + '/members',
            success: function(res) {
                dialog.clear();
                let button_deleteGroup = '<button id="deleteGroup_'+serviceID+'" class="usa-button usa-button--secondary leaf-btn-small leaf-marginTop-1rem">Delete Group</button>';
                if(serviceID > 0) {
                    button_deleteGroup = '';
                }
                dialog.setContent(
                    '<div class="leaf-float-right"><button class="usa-button leaf-btn-small" onclick="viewHistory('+serviceID+')">View History</button></div>' +
                    '<a class="leaf-group-link" href="<!--{$orgchartPath}-->/?a=view_group&groupID=' + serviceID + '" title="groupID: ' + serviceID + '" target="_blank"><h2 role="heading" tabindex="-1">' + serviceName + '</h2></a><h3 role="heading" tabindex="-1" class="leaf-marginTop-1rem">Add Employee</h3><div id="employeeSelector"></div></br><div id="employees"></div>');

                $('#employees').html('<div id="employee_table" style="display: table-header-group"></div><br /><div id="showInactive" class="fas fa-angle-right" style="cursor: pointer;"></div><div id="inactive_table" style="display: none"></div>');
                let employee_table = '<br/><table class="table-bordered"><thead><tr><th>Name</th><th>Username</th><th>Backups</th><th>Local</th><th>Actions</th></tr></thead><tbody>';
                let inactive_table = '<br/><table class="table-bordered"><thead><tr><th>Name</th><th>Username</th><th>Backups</th><th>Local</th><th>Actions</th></tr></thead><tbody>';

                let counter = 0;
                for(let i in res) {
                    if (res[i].backupID == '') {
                        let employeeName = `<td class="leaf-user-link" title="${res[i].empUID} - ${res[i].userName}" style="font-size: 1em; font-weight: 700;"><a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=${res[i].empUID}" target="_blank">${toTitleCase(res[i].Lname)}, ${toTitleCase(res[i].Fname)}</a></td>`;
                        let employeeUserName = `<td  class="leaf-user-link" title="${res[i].empUID} - ${res[i].userName}" style="font-size: 1em; font-weight: 600;"><a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=${res[i].empUID}" target="_blank">${res[i].userName}</a></td>`;
                        let backups = `<td style="font-size: 0.8em">`;
                        let isLocal = `<td style="font-size: 0.8em;">${res[i].locallyManaged > 0 ? '<span style="color: green; font-size: 1.2rem; margin: 1rem;">&#10004;</span>' : ''}</td>`;
                        let isRegional = `<td style="font-size: 0.8em;">${res[i].regionallyManaged ? '<span style="color: green; font-size: 1.2rem; margin: 1rem;">&#10004;</span>' : ''}</td>`;
                        let removeButton = `<td style="font-size: 0.8em; text-align: center;"><button id="removeMember_${counter}" class="usa-button usa-button--secondary leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Remove this user from this group">Remove</button>`;

                        // Check for Backups
                        for (let j in res) {
                            if (res[i].userName == res[j].backupID) {
                                backups += ('<div class="leaf-font0-8rem">' + toTitleCase(res[j].Fname) + ' ' + toTitleCase(res[j].Lname) + '\n');
                            }
                        }
                        // close of actions and backups column
                        backups += '</td>';

                        if (res[i].active === 1) {
                            let actions = `${removeButton}`;

                            actions += '</td>';
                            employee_table += `<tr>${employeeName}${employeeUserName}${backups}${isLocal}${actions}</tr>`;
                        } else {
                            let pruneMemberButton = '';

                            if (res[i].locallyManaged == 1) {
                                pruneMemberButton = `<td style="font-size: 0.8em; text-align: center;"><button id="pruneMember_${counter}" class="usa-button usa-button--secondary leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Prune this user from this group">Prune</button>`;
                            } else {
                                pruneMemberButton = `<td style="font-size: 0.8em; text-align: center;"><button id="reactivateMember_${counter}" class="usa-button usa-button leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Reactivate this user for this group">Reactivate</button>`;
                            }

                            let actions = `${pruneMemberButton}`;
                            actions += '</td>';
                            inactive_table += `<tr>${employeeName}${employeeUserName}${backups}${isLocal}${actions}</tr>`;
                        }
                        counter++;
                    }
                }
                employee_table += '</tbody></table>';
                inactive_table += '</tbody></table>';
                // generate formatted table
                $('#employee_table').html(employee_table);
                $('#inactive_table').html(inactive_table);

                if ($('#inactive_table > .table-bordered > tbody > tr').length === null || $('#inactive_table > .table-bordered > tbody > tr').length === 0){
                    $('#showInactive').hide();
                } else {
                    $('#showInactive').on('click', function () {
                        $('#showInactive').toggleClass("fa-angle-right fa-angle-down");
                        $('#inactive_table').slideToggle();
                    });
                }

                // add functionality to action buttons after table generation
                counter = 0;
                for (let i in res) {
                    if (res[i].backupID == "") {
                        if (res[i].active === 1) {
                            $('#removeMember_' + counter).on('click', function () {
                                dialog_confirm.setContent('Are you sure you want to remove this member?');
                                dialog_confirm.setSaveHandler(function () {
                                    removeUser(serviceID, res[i].userName);
                                    dialog_confirm.hide();
                                    dialog.hide();
                                });
                                dialog_confirm.show();
                            });
                        } else {
                            $('#pruneMember_' + counter).on('click', function () {
                                dialog_confirm.setContent('Are you sure you want to prune this member?');
                                dialog_confirm.setSaveHandler(function () {
                                    pruneMember(serviceID, res[i].userName);
                                    dialog_confirm.hide();
                                    dialog.hide();
                                });
                                dialog_confirm.show();
                            });
                            $('#reactivateMember_' + counter).on('click', function () {
                                dialog_confirm.setContent('Are you sure you want to reactivate this member?');
                                dialog_confirm.setSaveHandler(function () {
                                    reactivateMember(serviceID, res[i].userName);
                                    dialog_confirm.hide();
                                    dialog.hide();
                                });
                                dialog_confirm.show();
                            });
                        }
                        counter++;
                    }
                }

                $('#deleteGroup_' + serviceID).on('click', function() {
                    dialog_confirm.setContent('Are you sure you want to delete this service?');
                    dialog_confirm.setSaveHandler(function() {
                        deleteService(serviceID);
                    });
                    dialog_confirm.show();
                });

                empSel = new nationalEmployeeSelector('employeeSelector');
                empSel.apiPath = '<!--{$leaf_domain}-->';
                empSel.rootPath = '<!--{$orgchartPath}-->/';
                empSel.outputStyle = 'micro';
                empSel.initialize();
                // Update on any action
                dialog.setCancelHandler(function() {
                    getMembers(serviceID);
                });
                dialog.setSaveHandler(function() {
                    if(empSel.selection != '') {
                        let selectedUserName = empSel.selectionData[empSel.selection].userName;
                        importUser(serviceID, selectedUserName);
                    }
                    dialog.hide();
                });

                dialog.show();
            },
            fail: function(error) {
                console.log(error);
            },
            cache: false
        });
    }
}

function pruneMember(groupID, userID) {
    if (groupID === 0 || userID === '') {
        return;
    } else {
        $.ajax({
            async: false,
            type: 'POST',
            url: "../api/service/" + groupID + "/members/_" + userID + "/prune",
            data: {'CSRFToken': '<!--{$CSRFToken}-->'},
            fail: function(err) {
                console.log(err);
            },
            cache: false
        });
    }

}

function reactivateMember(groupID, userID) {
    if (groupID === 0 || userID === '') {
        return;
    } else {
        $.ajax({
            async: false,
            type: 'POST',
            url: "../api/service/" + groupID + "/members/_" + userID + "/reactivate",
            data: {'CSRFToken': '<!--{$CSRFToken}-->'},
            fail: function(err) {
                console.log(err);
            },
            cache: false
        });
    }
}

/**
 * Initiate widgets for each service
 * @param {int} serviceID - ID for service being represented
 * @param {string} serviceName - name of service being represented
 * @return function
 */
function initiateWidget(serviceID = 0, serviceName = '') {
    if (serviceID === 0 || serviceName === '') {
        return;
    } else {
        $('#' + serviceID).on('click keydown', function(e) {
            if (e.type === 'keydown' && e.which === 13 || e.type === 'click') {
                initiateModal(serviceID, serviceName);
            }
        });
    }
}

/**
 * Get list of present services in portal.
 */
function getGroupList() {
	$.when(
	    $.ajax({
	        type: 'GET',
	        url: '../api/service/quadrads',
	        cache: false
	    }),
        $.ajax({
            type: 'GET',
            url: '../api/service',
            cache: false
        })
     )
	.done(function(res1, res2) {
		let quadrads = res1[0];
		let services = res2[0];
	    for(let i in quadrads) {
	    	$('#groupList').append('<h2>'+ toTitleCase(quadrads[i].name) +'</h2><div class="leaf-displayFlexRow" id="group_'+ quadrads[i].groupID +'"></div>');
	    }
	    for(let i in services) {
            $('#group_' + services[i].groupID).append('<div tabindex="0" id="'+ services[i].serviceID +'" title="serviceID: '+ services[i].serviceID +'" class="groupBlockWhite">'
                    + '<h2 id="groupTitle'+ services[i].serviceID +'">'+ services[i].service +'</h2>'
                    + '<div id="members'+ services[i].serviceID +'"></div>'
                    + '</div>');
	    	initiateWidget(services[i].serviceID, services[i].service);
	    	populateMembers(services[i].serviceID, services[i].members);
	    }
	});
}

/**
 * View history of given group by ID.
 * @param {int} groupID - ID of given group
 */
function viewHistory(groupID = -1){
    if (groupID < 0) {
        return;
    }
    dialog_simple.setContent('');
    dialog_simple.setTitle('Service chief history');
	dialog_simple.show();
	dialog_simple.indicateBusy();

    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistory&type=service&id='+groupID,
        dataType: 'text',
        success: function(res) {
            dialog_simple.setContent(res);
            dialog_simple.indicateIdle();
        },
        fail: function(error) {
            console.log(error);
        },
        cache: false
    });
}

/**
 * Convert to title case.
 * @param {string} str - string to be converted
 */
function toTitleCase(str = '') {
    return (str == "" || str == null) ? "" : str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

// Define dialog boxes
let dialog;
let dialog_simple;
let dialog_confirm;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    getGroupList();
});

/* ]]> */
</script>
