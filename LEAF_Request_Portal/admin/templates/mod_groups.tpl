<style>
    .employeeSelectorInput {
        border: 1px solid #bbb;
    table, th, td{
        text-align: left;
        border-left: 0px solid;
        border-right: 0px solid;
        border-bottom: 1.5px solid #DFE1E2;
        border-collapse: collapse;
        min-width: 6rem;
    }

    table, td {
        border-top: 1.5px solid #DFE1E2;
    }

    table, th {
        border-top: 0px solid;
        font-size: 0.9em;
    }
</style>

<div class="leaf-center-content">

    <!-- LEFT SIDE NAV -->
    <!--{assign var=left_uag_content value="
        <aside class='sidenav'>
            <h3 class='navhead'>Access categories</h3>
            <ul class='usa-sidenav'>
                <li class='usa-sidenav__item'><a href='javascript:void(0)' id='allGroupsLink' class='usa-current'>All groups (<span id='allGroupsCount'>-</span>)</a></li>
                <li class='usa-sidenav__item'><a href='javascript:void(0)' id='sysAdminsLink'>System administrators (<span id='sysAdminsCount'>-</span>)</a></li>
                <li class='usa-sidenav__item'><a href='javascript:void(0)' id='userGroupsLink'>User groups (<span id='userGroupsCount'>-</span>)</a></li>
            </ul>
        </aside>
        </br>
        <aside class='sidenav'>
            <h3 class='navhead'>Access groups</h3>
            <button class='usa-button leaf-btn-green leaf-btn-med leaf-side-btn' onclick='createGroup();'>
                + Create group
            </button>
            <button class='usa-button usa-button--outline leaf-btn-med leaf-side-btn' onclick='importGroup();'>
                Import group
            </button>
            <button class='usa-button usa-button--outline leaf-btn-med leaf-side-btn' onclick='showAllGroupHistory();'>
                Show group history
            </button>
        </aside>
    "}-->
    <!--{include file="partial_layouts/left_uag_nav.tpl" contentLeft="$left_uag_content"}-->

    <main class="main-content">

        <h2><a href="../admin" class="leaf-crumb-link">Admin</a><i class="fas fa-caret-right leaf-crumb-caret"></i>User access</h2>

        <div class="leaf-user-search">
            <p><label for="userGroupSearch">Filter by group or user name</label></p>
            <input id="userGroupSearch" class="leaf-user-search-input" type="text" title="" onkeyup="searchGroups();" disabled />
        </div>

        <div id="noResultsMsg" class="leaf-no-results usa-alert usa-alert--error usa-alert--slim" role="alert">
            <p><i class="fas fa-exclamation-circle" alt=""></i>No matching groups or users found.</p>
        </div>

        <div id="sysAdmins" class="leaf-marginTop-1rem">
            <h3 role="heading" tabindex="-1" class="groupHeaders groupSysAdmins">System administrators</h3>
            <div class="leaf-displayFlexRow">
                <span id="adminList"></span>
                <span id="primaryAdmin"></span>
            </div>
        </div>

        <div id="userGroups" class="leaf-marginTop-1rem">
            <div class="leaf-clear-both">
                <h3 role="heading" tabindex="-1" class="groupHeaders groupUserGroups">User groups</h3>
                <div id="groupList" class="leaf-displayFlexRow"></div>
            </div>
        </div>
    </main>
</div>
<!--Loading Modal-->
<!--{include file="<!--{$app_libs}-->/smarty/loading_spinner.tpl" title='User Groups'}-->

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/import_dialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_OkDialog.tpl"}-->

<script>
$(document).ready(function() {
    // side nav show/hide
    // all groups
    $('#allGroupsLink').click(function() {
        $('#userGroupSearch').val('');
        searchGroups();
        $('#userGroupSearch').focus();
        $('#sysAdmins').show();
        $('#userGroups').show();
        $('#sysAdminsLink, #userGroupsLink').removeClass('usa-current');
        $(this).addClass('usa-current');
    });
    // sys admins
    $('#sysAdminsLink').click(function() {
        $('#userGroupSearch').val('');
        searchGroups();
        $('#userGroupSearch').focus();
        $('#userGroups').hide();
        $('#sysAdmins').show();
        $('#userGroupsLink, #allGroupsLink').removeClass('usa-current');
        $(this).addClass('usa-current');
    });
    // user groups
    $('#userGroupsLink').click(function() {
        $('#userGroupSearch').val('');
        searchGroups();
        $('#userGroupSearch').focus();
        $('#sysAdmins').hide();
        $('#userGroups').show();
        $('#sysAdminsLink, #allGroupsLink').removeClass('usa-current');
        $(this).addClass('usa-current');
    });
});

let tz = '<!--{$timeZone}-->';
/* <![CDATA[ */

// handle any case for user group text search
jQuery.expr[":"].Contains = jQuery.expr.createPseudo(function(arg) {
    return function( elem ) {
        return jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
    };
});

function searchGroups() {
    let srchInput = document.getElementById('userGroupSearch').value;
    $('.groupName, .groupUser').removeClass('leaf-search-hilite');
    $('.groupBlockWhite, .groupBlock, .groupName, .groupUserFirst, .groupHeaders').show();
    $('#noResultsMsg, .groupUser').hide();

    if (srchInput.length >= 2) {
        $('.groupUserFirst').hide();
        $('.groupUser').show();
        let isSysAdmin = $('.groupBlock:Contains(' + srchInput + ')').length > 0,
            isUserGroup = $('.groupBlockWhite:Contains(' + srchInput + ')').length > 0,
            findUser = $('.groupUser:Contains(' + srchInput + ')').length > 0,
            findGroup = $('.groupName:Contains(' + srchInput + ')').length > 0;
        if (findUser) {
            $('.groupUser:Contains(' + srchInput + ')').addClass('leaf-search-hilite');
            $('.groupName:Contains(' + srchInput + ')').addClass('leaf-search-hilite');
            if (isSysAdmin && isUserGroup) {
                $('.groupBlock').hide();
                $('.groupBlock:Contains(' + srchInput + ')').show();
                $('.groupSysAdmins').show();
                $('.groupUser').each(function() {
                    $(this).not(':Contains(' + srchInput + ')').hide();
                    $('.groupUser:Contains(' + srchInput + ')').show();
                });
                $('.groupBlockWhite').each(function() {
                    $(this).not(':Contains(' + srchInput + ')').hide();
                    $('.groupBlockWhite:Contains(' + srchInput + ')').show();
                });
            }
            else if (!isSysAdmin && isUserGroup) {
                $('.groupSysAdmins').hide();
                $('.groupBlock').hide();
                $('.groupUser:Contains(' + srchInput + ')').show();
                $('.groupBlockWhite').each(function() {
                    $(this).not(':Contains(' + srchInput + ')').hide();
                    $('.groupName:Contains(' + srchInput + ')').show();
                });
            }
            else if (isSysAdmin && !isUserGroup) {
                $('.groupUserGroups').hide();
                $('.groupBlockWhite').hide();
                $('.groupUser:Contains(' + srchInput + ')').show();
                $('.groupBlock').each(function() {
                    $(this).not(':Contains(' + srchInput + ')').hide();
                    $('.groupName:Contains(' + srchInput + ')').show();
                });
            }
            else {
                $('.groupSysAdmins, .groupBlock').hide();
            }
            (findGroup) ? $('.groupUser').show() : $('.groupUser').not(':Contains(' + srchInput + ')').hide();
        }
        else if (findGroup) {
            $('.groupUser:Contains(' + srchInput + ')').addClass('leaf-search-hilite');
            $('.groupName:Contains(' + srchInput + ')').addClass('leaf-search-hilite');
            if (isSysAdmin && isUserGroup) {
                $('.groupBlock').hide();
                $('.groupBlock:Contains(' + srchInput + ')').show();
                $('.groupBlockWhite').each(function() {
                    $(this).not(':Contains(' + srchInput + ')').hide();
                });
            }
            else if (isSysAdmin && !isUserGroup) {
                $('.groupBlock, .groupBlockWhite, .groupHeaders').hide();
                $('.groupBlock:Contains(' + srchInput + ')').show();
                $('.groupSysAdmins').show();
            }
            else if (!isSysAdmin && isUserGroup) {
                $('.groupBlock, .groupBlockWhite, .groupHeaders').hide();
                $('.groupBlockWhite:Contains(' + srchInput + ')').show();
                $('.groupBlockWhite').each(function() {
                    $(this).not(':Contains(' + srchInput + ')').hide();
                });
                $('.groupUserGroups').show();
            }
            else {
                $('.groupSysAdmins, .groupBlock').hide();
            }
        }
        else {
            $('#noResultsMsg').show();
            $('.groupBlockWhite, .groupBlock, .groupHeaders').hide();
        }

    }

}

function getMembers(groupID) {
    let response;

    getMemberList(groupID, function(data) {
        response = data;
    });

    if (response.status['code'] == 2) {
        $('#members' + groupID).fadeOut();
        populateMembers(groupID, response.data);
        $('#members' + groupID).fadeIn();
    } else {
        displayDialogOk(response.status['message']);
    }
}

// All in one update for member groups (sync)
function updateAndGetMembers(groupID) {
    $.ajax({
        type: 'GET',
        url: '../api/system/updateGroup/' + groupID,
        success: function(res) {
            let response;

            getMemberList(groupID, function(data) {
                response = data;
            });

            if (response.status['code'] == 2) {
                $('#members' + groupID).fadeOut();
                populateMembers(groupID, response.data);
                $('#members' + groupID).fadeIn();
            } else {
                displayDialogOk(response.status['message']);
            }
        },
        error: function (err) {
            console.log(err);
        },
        cache: false
    });
}

function getPrimaryAdmin() {
    let response;

    getMemberList(1, function(data) {
        response = data;
    });

    let res = response.data;

    if (response.status['code'] == 2) {
        $('#membersPrimaryAdmin').fadeOut();
        $('#membersPrimaryAdmin').html('');
        let foundPrimary = false;
        for(let i in res) {
            if(res[i].primary_admin == 1)
            {
                foundPrimary = true;
                $('#membersPrimaryAdmin').append('<div class="groupUserFirst">' + toTitleCase(res[i].Fname) + ' ' + toTitleCase(res[i].Lname) + ' </div>');
            }
        }
        if(!foundPrimary)
        {
            $('#membersPrimaryAdmin').append("Primary Administrator has not been set");
        }
        $('#membersPrimaryAdmin').fadeIn();
    } else {
        displayDialogOk(response.status['message']);
    }
}

function displayDialogOk(message) {
    dialog_ok.setTitle('User Groups');
    dialog_ok.setContent(message);
    dialog_ok.setSaveHandler(function() {
        dialog_ok.clearDialog();
        dialog_ok.hide();
    });
    dialog_ok.show();
}

function populateMembers(groupID, members) {
    $('#members' + groupID).html('');
    let memberCt = -1;
    let adminCt = (members.length - 1);
    for(let i in members) {
        if(members[i].active == 1 && members[i].backupID == "") {
            memberCt++;
        }
    }
    let j = 0;
    let countTxt = (memberCt > 0) ? (' + ' + memberCt + ' others') : '';
    let countAdminTxt = (adminCt > 0) ? (' + ' + adminCt + ' others') : '';
    for(let i in members) {
        if (members[i].active == 1 && members[i].backupID == "" && groupID != 1) {
            if (j == 0) {
                $('#members' + groupID).append('<div class="groupUserFirst">' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + countTxt + '</div>');
            }
            $('#members' + groupID).append('<div class="groupUser">' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + '</div>');
            j++;
        } else if (groupID == 1) {
            if (i == 0) {
                $('#members' + groupID).append('<div class="groupUserFirst">' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + countAdminTxt + '</div>');
            }
            $('#members' + groupID).append('<div class="groupUser">' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + '</div>');
        }
    }
}

function removeMember(groupID, userID) {
    $.ajax({
        type: 'POST',
        url: "../api/group/" + groupID + "/members/_" + userID,
        data: {'CSRFToken': '<!--{$CSRFToken}-->'},
        error: function(err) {
            console.log(err);
        },
        cache: false
    });
}

/**
 * removeTempMember: Removes preview placeholder for user that has not been added to group yet.
 * @param htmlNode table
 * @param int id
 */
function removeTempMember(table, id) {
    for (let i = 1; i <= table.rows.length; i++) {
        if (table.rows[i]?.classList?.contains(`id-${id}`)) {
            table.deleteRow(i);
        }
    }
}

function pruneMember(groupID, userID) {
    $.ajax({
        type: 'POST',
        url: "../api/group/" + groupID + "/members/_" + userID + "/prune",
        data: {'CSRFToken': '<!--{$CSRFToken}-->'},
        error: function(err) {
            console.log(err);
        },
        cache: false
    });
}

function reactivateMember(groupID, userID) {
    $.ajax({
        type: 'POST',
        url: "../api/group/" + groupID + "/members/_" + userID + "/reactivate",
        data: {'CSRFToken': '<!--{$CSRFToken}-->'},
        error: function(err) {
            console.log(err);
        },
        cache: false
    });
}

function addNexusMember(groupID, empUID) {
    $.ajax({
        type: 'POST',
        url: `<!--{$orgchartPath}-->/api/?a=group/${groupID}/employee`,
        data: {
            CSRFToken: '<!--{$CSRFToken}-->',
            empUID: empUID
        },
        error: function(err) {
            console.log(err);
        },
        cache: false
    });
}

function addMember(groupID, userID) {
    $.ajax({
        type: 'POST',
        url: "../api/group/" + groupID + "/members",
        data: {'userID': userID,
        'CSRFToken': '<!--{$CSRFToken}-->'},
        cache: false
    });
}
// convert to title case
function toTitleCase(str) {
    return (str == "" || str == null) ? "" : str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function addAdmin(userID) {
    if (userID === '') {
        return;
    } else {
        $.ajax({
            type: 'POST',
            url: "../api/group/" + 1 + "/members",
            data: {'userID': userID,
                'CSRFToken': '<!--{$CSRFToken}-->'},
            success: function(response) {
                getMembers(1);
            },
            cache: false
        });
    }
}

function removeAdmin(userID) {
    if (userID === '') {
        return;
    } else {
        $.ajax({
            type: 'DELETE',
            url: "../api/group/" + 1 + "/members/_" + userID + "?" +
                            $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
            success: function(response) {
                getMembers(1);
            },
            cache: false
        });
    }
}

function unsetPrimaryAdmin() {
    $.ajax({
    	type: 'POST',
        url: "../api/system/unsetPrimaryadmin",
        data: {'CSRFToken': '<!--{$CSRFToken}-->'},
        success: function(response) {
        	getPrimaryAdmin();
        },
        cache: false
    });
}

function setPrimaryAdmin(userID) {
        $.ajax({
    	type: 'POST',
        url: "../api/system/setPrimaryadmin",
        data: {'userID': userID, 'CSRFToken': '<!--{$CSRFToken}-->'},
        success: function(response) {
        	getPrimaryAdmin();
        },
        error: function (err) {
            console.log(err);
        },
        cache: false
    });
}

function getGroupList() {

    // reset dialog for regular content
    $(".ui-dialog>div").css('width', 'auto');
    $(".leaf-dialog-content").css('width', 'auto');
    // vars for group counts
    let allGroupsCount = 0, userGroupCount = 0, sysAdminCount = 0;

    $('#body').addClass("loading");
    dialog.showButtons();
    $.ajax({
        type: 'GET',
        url: "../api/group/members",
        dataType: "json",
        success: function(res) {
            $('#groupList').html('');
            for(let i in res) {
            	// only show explicit groups, not ELTs
            	if(res[i].parentGroupID == null && res[i].groupID != 1) {
                    userGroupCount++;
                    $('#groupList').append('<div tabindex="0" id="'+ res[i].groupID +'" title="groupID: '+ res[i].groupID +'" class="groupBlockWhite">\
                        <h2 id="groupTitle'+ res[i].groupID +'" class="groupName">'+ res[i].name +' </h2>\
                        <div id="members' + res[i].groupID + '" class="groupMemberList"></div>\
                        </div>');
            	}
            	else if(res[i].groupID == 1) {
                    sysAdminCount++;
                    $('#adminList').append('<div tabindex="0" id="'+ res[i].groupID +'" title="groupID: '+ res[i].groupID +'" class="groupBlock">\
                        <h2 id="groupTitle'+ res[i].groupID +'" class="groupName">'+ res[i].name +' </h2>\
                        <div id="members'+ res[i].groupID +'"></div>\
                        </div>');
            	}

                if(res[i].groupID != 1) { // if not admin
                    function openGroup(groupID, parentGroupID, groupName) {
                        $.ajax({
                            type: 'GET',
                            url: '../api/group/' + groupID + '/membersWBackups',
                            success: function(response) {
                                if (response.status.code == 2) {
                                    let res = response.data;
                                    dialog.clear();
                                    dialog.setTitle("Edit Group");
                                    let button_deleteGroup = '<div><button id="deleteGroup_' + groupID + '" class="usa-button usa-button--secondary leaf-btn-small leaf-marginTop-1rem">Delete Group</button></div>';
                                    dialog.setContent(
                                        '<div class="leaf-float-right"><div><button class="usa-button leaf-btn-small" onclick="viewHistory('+groupID+')">View History</button></div>' + button_deleteGroup + '</div>' +
                                        '<a class="leaf-group-link" href="<!--{$orgchartPath}-->/?a=view_group&groupID=' + groupID + '" title="groupID: ' + groupID + '" target="_blank"><h2 role="heading" tabindex="-1">' + groupName + '</h2></a><br /><h3 role="heading" tabindex="-1" class="leaf-marginTop-1rem">Add Employee</h3><div id="employeeSelector"></div><br/><br/><hr/><div id="employees"></div>');

                                    $('#employees').html('<div id="employee_table" style="display: table-header-group"></div><br /><div id="showInactive" class="fas fa-angle-right" style="cursor: pointer;"></div><div id="inactive_table" style="display: none"></div>');
                                    let employee_table = '<br/><table class="table-bordered"><thead><tr><th>Name</th><th>Username</th><th>Backups</th><th>Local</th><th>Nexus</th><th>Actions</th></tr></thead><tbody>';
                                    let inactive_table = '<br/><table class="table-bordered"><thead><tr><th>Name</th><th>Username</th><th>Backups</th><th>Local</th><th>Nexus</th><th>Actions</th></tr></thead><tbody>';
                                    let counter = 0;
                                    for(let i in res) {
                                        if (res[i].backupID == '') {
                                            let employeeName = `<td class="leaf-user-link" title="${res[i].empUID} - ${res[i].userName}" style="font-size: 1em; font-weight: 700;"><a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=${res[i].empUID}" target="_blank">${toTitleCase(res[i].Lname)}, ${toTitleCase(res[i].Fname)}</a></td>`;
                                            let employeeUserName = `<td  class="leaf-user-link" title="${res[i].empUID} - ${res[i].userName}" style="font-size: 1em; font-weight: 600;"><a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=${res[i].empUID}" target="_blank">${res[i].userName}</a></td>`;
                                            let backups = `<td style="font-size: 0.8em">`;
                                            let isLocal = `<td style="font-size: 0.8em;">${res[i].locallyManaged > 0 ? '<span style="color: green; font-size: 1.2rem; margin: 1rem;">&#10004;</span>' : ''}</td>`;
                                            let isRegional = `<td style="font-size: 0.8em;">${res[i].regionallyManaged ? '<span style="color: green; font-size: 1.2rem; margin: 1rem;">&#10004;</span>' : ''}</td>`;
                                            let removeButton = `<td style="font-size: 0.8em; text-align: center;"><button id="removeMember_${counter}" class="usa-button usa-button--secondary leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Remove this user from this group">Remove</button>`;
                                            let addToNexusButton = `<button id="addNexusMember_${counter}" class="usa-button leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; margin-left: 2px !important; min-width: 4rem;" title="Add this user to Nexus group">Add to Nexus</button>`;

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
                                                if (res[i].regionallyManaged === false) {
                                                    actions += `${addToNexusButton}`;
                                                }
                                                actions += '</td>';
                                                employee_table += `<tr class="id-${res[i].empUID}">${employeeName}${employeeUserName}${backups}${isLocal}${isRegional}${actions}</tr>`;
                                            } else {
                                                let pruneMemberButton = '';
                                                if (res[i].regionallyManaged === false) {
                                                    pruneMemberButton = `<td style="font-size: 0.8em; text-align: center;"><button id="pruneMember_${counter}" class="usa-button usa-button--secondary leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Prune this user from this group">Prune</button>`;
                                                } else {
                                                    pruneMemberButton = `<td style="font-size: 0.8em; text-align: center;"><button id="reActivateMember_${counter}" class="usa-button usa-button leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Reactivate this user for this group">Reactivate</button>`;
                                                }
                                                let actions = `${pruneMemberButton}`;
                                                actions += '</td>';
                                                inactive_table += `<tr>${employeeName}${employeeUserName}${backups}${isLocal}${isRegional}${actions}</tr>`;
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
                                                        removeMember(groupID, res[i].userName);
                                                        dialog_confirm.hide();
                                                        dialog.hide();
                                                    });
                                                    dialog_confirm.show();
                                                });
                                                $('#addNexusMember_' + counter).on('click', function () {
                                                    dialog_confirm.setContent('Are you sure you want to add this member to Nexus group?');
                                                    dialog_confirm.setSaveHandler(function () {
                                                        addNexusMember(groupID, res[i].empUID);
                                                        dialog_confirm.hide();
                                                        dialog.hide();
                                                    });
                                                    dialog_confirm.show();
                                                });
                                            } else {
                                                $('#pruneMember_' + counter).on('click', function () {
                                                    dialog_confirm.setContent('Are you sure you want to prune this member?');
                                                    dialog_confirm.setSaveHandler(function () {
                                                        pruneMember(groupID, res[i].userName);
                                                        dialog_confirm.hide();
                                                        dialog.hide();
                                                    });
                                                    dialog_confirm.show();
                                                });

                                                $('#reActivateMember_' + counter).on('click', function () {
                                                    dialog_confirm.setContent('Are you sure you want to Reactivate this member?');
                                                    dialog_confirm.setSaveHandler(function () {
                                                        reactivateMember(groupID, res[i].userName);
                                                        dialog_confirm.hide();
                                                        dialog.hide();
                                                    });
                                                    dialog_confirm.show();
                                                });
                                            }
                                            counter++;
                                        }
                                    }

                                    $('#deleteGroup_' + groupID).on('click', function() {
                                        // first check that this group is not used in any workflows at the moment
                                        // if it is used then list the workflow and steps that it is used.
                                        $.ajax({
                                            type: 'GET',
                                            url: "../api/group/" + groupID + '/associated_workflows',
                                            success: function(response) {
                                                console.log(response);
                                                //location.reload();
                                                if (response.status.code == 2) {
                                                    // loop through data to display the workflow and steps within
                                                    let data = response.data;
                                                    let currentWF = '';
                                                    let display = 'This group is associated with the following Workflows and their<br /> cooresponding steps.<br /> It is recommended that you remove this group from the related steps<br /> before deleting this group.<ul>';

                                                    if (data.length > 0) {
                                                        for (let i in data) {
                                                            if (data[i].workflowID !== null) {
                                                                if (currentWF == '') {
                                                                    // first time through set it up
                                                                    display += '<li>#' + data[i].workflowID + ' - ' + data[i].description + '</li>';
                                                                    display += '<ul><li>#' + data[i].stepID + ' - ' + data[i].stepTitle + '</li>';
                                                                    currentWF = data[i].workflowID;
                                                                } else if (data[i].workflowID == currentWF) {
                                                                    // same workflow add step title
                                                                    display += '<li>#' + data[i].stepID + ' - ' + data[i].stepTitle + '</li>';
                                                                } else {
                                                                    // not the first time through, and not the same WF, close out last workflow
                                                                    display += '</ul>';
                                                                    display += '<li>#' + data[i].workflowID + ' - ' + data[i].description + '</li>';
                                                                    display += '<ul><li>#' + data[i].stepID + ' - ' + data[i].stepTitle + '</li>';
                                                                    currentWF = data[i].workflowID;
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // display is complete, close out the ul's
                                                    if (currentWF !== '') {
                                                        display += '</ul></ul> Are you sure you want to continue with deleting this group?';
                                                    } else {
                                                        display = 'Are you sure you want to delete this group?';
                                                    }

                                                    dialog_confirm.setContent(display);
                                                    dialog_confirm.setSaveHandler(function() {
                                                        $.ajax({
                                                            type: 'DELETE',
                                                            url: "../api/group/" + groupID + '?' +
                                                                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                                                            success: function(response) {
                                                                location.reload();
                                                            },
                                                            cache: false
                                                        });
                                                        $.ajax({
                                                            type: 'DELETE',
                                                            url: '<!--{$orgchartPath}-->/api/group/' + groupID + '/local/tag?' +
                                                                $.param({tag: '<!--{$orgchartImportTag}-->',
                                                                        CSRFToken: '<!--{$CSRFToken}-->'}),
                                                            success: function() {
                                                            },
                                                            cache: false
                                                        });
                                                    });
                                                    dialog_confirm.show();
                                                } else {
                                                    console.log(response.status.message);
                                                }
                                            },
                                            error: function (err) {
                                                console.log(err);
                                            },
                                            cache: false
                                        });
                                    });

                                    empSel = new nationalEmployeeSelector('employeeSelector');
                                    empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
                                    empSel.rootPath = '<!--{$orgchartPath}-->/';
                                    empSel.outputStyle = 'micro';
                                    empSel.selectHandler = () => {
                                        if(empSel.selection != '') {
                                            let selectedUser = empSel.selectionData[empSel.selection];
                                            let selectedUserName = selectedUser.userName;
                                            // Check if the user does not already exist.
                                            let idExists = false;
                                            let table = document.querySelector('#employee_table > table.table-bordered');
                                            for (let i = 1; i <= table.rows.length; i++) {
                                                if (table.rows[i]?.classList?.contains(`id-${selectedUser.empUID}`)) {
                                                    idExists = true;
                                                }
                                            }
                                            if (!idExists) {
                                                $.ajax({
                                                    type: 'POST',
                                                    url: '<!--{$orgchartPath}-->/api/employee/import/_' + selectedUserName,
                                                    data: {CSRFToken: '<!--{$CSRFToken}-->'},
                                                    success: function(res) {
                                                        if(!isNaN(res)) {
                                                            // Add the user to the table.
                                                            let table = document.querySelector('#employee_table > table.table-bordered');
                                                            let row = table.insertRow(table.rows.length);
                                                            row.style.backgroundColor = "#aea";
                                                            row.classList.add(`id-${selectedUser.empUID}`);
                                                            row.classList.add(`user-to-add`);
                                                            
                                                            let employeeName = row.insertCell(0);
                                                            employeeName.classList.add("leaf-user-link");
                                                            employeeName.title = `${selectedUser.empUID} - ${selectedUser.userName}`;
                                                            employeeName.style.cssText = "font-size: 1em; font-weight: 700; color: #333;";

                                                            let employeeUserName = row.insertCell(1);
                                                            employeeUserName.classList.add("leaf-user-link");
                                                            employeeUserName.title = `${selectedUser.empUID} - ${selectedUser.userName}`;
                                                            employeeUserName.style.cssText = "font-size: 1em; font-weight: 600;";

                                                            let backups = row.insertCell(2);
                                                            let isLocal = row.insertCell(3);
                                                            let isRegional = row.insertCell(4);

                                                            let removeButton = row.insertCell(5);
                                                            removeButton.style.cssText = "font-size: 0.8em; text-align: center;";

                                                            employeeName.innerHTML = `+ <a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=${selectedUser.empUID}" target="_blank">${toTitleCase(selectedUser.lastName)}, ${toTitleCase(selectedUser.firstName)}</a>`;
                                                            employeeUserName.innerHTML = `<a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=${selectedUser.empUID}" target="_blank">${selectedUser.userName}</a>`;
                                                            removeButton.innerHTML = `<button id="removeTempMember_${table.rows.length}" class="usa-button usa-button--secondary leaf-btn-small leaf-font0-8rem" style="font-size: 0.8em; display: inline-block; float: left; margin: auto; min-width: 4rem;" title="Remove this user from this group">Remove</button>`;

                                                            document.querySelector('#removeTempMember_' + table.rows.length).addEventListener('click', function () {
                                                                removeTempMember(table, selectedUser.empUID);
                                                            });
                                                        }
                                                    },
                                                    error: function(err) {
                                                        console.log(err);
                                                    },
                                                    cache: false
                                                });
                                            }
                                            empSel.selection = '';
                                            empSel.clearSearch();
                                        }
                                    };
                                    empSel.initialize();
                                    // Update on any action
                                    dialog.setCancelHandler(function() {
                                        updateAndGetMembers(groupID);
                                    });
                                    dialog.setSaveHandler(function() {
                                        let table = document.querySelector('#employee_table > table.table-bordered');
                                        for (let i = 1; i <= table.rows.length; i++) {
                                            if (table.rows[i]?.classList?.contains(`user-to-add`)) {
                                                let cells = table.rows[i].getElementsByTagName("td");
                                                let selectedUserName = cells[1].innerText;
                                                $.ajax({
                                                    type: 'POST',
                                                    url: '<!--{$orgchartPath}-->/api/employee/import/_' + selectedUserName,
                                                    data: {CSRFToken: '<!--{$CSRFToken}-->'},
                                                    success: function(res) {
                                                        if(!isNaN(res)) {
                                                            addMember(groupID, selectedUserName);
                                                            updateAndGetMembers(groupID);
                                                        }
                                                        else {
                                                            alert(res);
                                                        }
                                                    },
                                                    error: function(err) {
                                                        console.log(err);
                                                    },
                                                    cache: false
                                                });
                                                dialog.hide();
                                            }
                                            else { // if there are no users to save to the group
                                                dialog.hide();
                                            }
                                        }
                                    });
                                    //508 fix
                                    setTimeout(function () {
                                        $("#simplebutton_cancelchange").remove();
                                        $("#simplebutton_save").remove();
                                        dialog.show();
                                    }, 0);
                                } else {
                                    displayDialogOk(response.status['message']);
                                }
                            },
                            cache: false
                        });
                    }

                    //508 fix
                    $('#' + res[i].groupID).on('click', function(groupID, parentGroupID, groupName) {
                        return function() {
                            openGroup(groupID, parentGroupID, groupName);
                        };
                    }(res[i].groupID, res[i].parentGroupID, res[i].name));
                    $('#' + res[i].groupID).on('keydown', function(groupID, parentGroupID, groupName) {
                        return function(event) {
                            if(event.keyCode === 13 || event.keyCode === 32) {
                                openGroup(groupID, parentGroupID, groupName);
                            }
                        };
                    }(res[i].groupID, res[i].parentGroupID, res[i].name));
                }
                else { // if is admin
                    function openAdminGroup(){
                         // reset dialog for regular content
                        $(".ui-dialog>div").css('width', 'auto');
                        $(".leaf-dialog-content").css('width', 'auto');
                        dialog.showButtons();
                        dialog.setTitle('Editor');
                        dialog.setContent(
                            '<button class="usa-button leaf-btn-small leaf-float-right" onclick="viewHistory(1)">View History</button>'+
                            '<h2 role="heading" tabindex="-1">System Administrators</h2><h3 role="heading" tabindex="-1" class="leaf-marginTop-1rem">Add Administrator</h3></div><div id="employeeSelector"></div></br><div id="adminSummary"></div><div class="leaf-marginTop-2rem">');

                        empSel = new nationalEmployeeSelector('employeeSelector');
                        empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
                        empSel.rootPath = '<!--{$orgchartPath}-->/';
                        empSel.outputStyle = 'micro';
                        empSel.initialize();
                        dialog.setCancelHandler(function() {
                            updateAndGetMembers(1);
                        });
                        dialog.setSaveHandler(function() {
                            if(empSel.selection != '') {
                                let selectedUserName = empSel.selectionData[empSel.selection].userName;
                                $.ajax({
                                    type: 'POST',
                                    url: '<!--{$orgchartPath}-->/api/employee/import/_' + selectedUserName,
                                    data: {CSRFToken: '<!--{$CSRFToken}-->'},
                                    success: function(res) {
                                        if(!isNaN(res)) {
                                            addAdmin(selectedUserName);
                                        }
                                        else {
                                            alert(res);
                                        }
                                    },
                                    cache: false
                                });
                            }
                            dialog.hide();
                        });
                        let response;

                        getMemberList(1, function(data) {
                            response = data;
                        });

                        let res = response.data;

                        if (response.status['code'] == 2) {
                            $('#adminSummary').html('');
                            let counter = 0;
                            for(let i in res) {
                                $('#adminSummary').append('<a class="leaf-user-link" href="<!--{$orgchartPath}-->/?a=view_employee&empUID=' + res[i].empUID + '" title="' + res[i].empUID + ' - ' + res[i].userName + '" target="_blank"><div class="leaf-marginTop-qtrRem leaf-marginLeft-qtrRem"><span class="leaf-bold leaf-font0-8rem">'+ toTitleCase(res[i].Lname) +', '+toTitleCase(res[i].Fname)+'</span></a> - <a tabindex="0" aria-label="REMOVE ' + toTitleCase(res[i].Lname)+', '+ toTitleCase(res[i].Fname)  +'" href="#" class="text-secondary-darker leaf-font0-8rem" id="removeAdmin_'+ counter +'">REMOVE</a></div>');
                                $('#removeAdmin_' + counter).on('click', function(userID) {
                                    return function() {
                                        removeAdmin(userID);
                                        dialog.hide();
                                    };
                                }(res[i].userName));
                                counter++;
                            }
                            dialog.show();
                        } else {
                            displayDialogOk(response.status['message']);
                        }

                    }
                	$('#' + res[i].groupID).on('click', function() {
                		openAdminGroup();
                	});

                    //508 fix
                    $('#' + res[i].groupID).on('keydown', function(event) {
                        if(event.keyCode === 13 || event.keyCode === 32) {
                            openAdminGroup();
                        }
                    });
                }
                populateMembers(res[i].groupID, res[i].members);

                //Primary Admin Section
                if(res[i].groupID == 1) {
                    sysAdminCount++;
                    $('#primaryAdmin').append('<div tabindex="0" class="groupBlock">\
                        <h3 id="groupTitlePrimaryAdmin" class="groupName">Primary Admin</h3>\
                        <div id="membersPrimaryAdmin"></div>\
                        </div>');

                    function openPrimaryAdminGroup(){
                        let response;

                        getMemberList(1, function(data) {
                            response = data;
                        });

                        let admin_list = response.data;

                        if (response.status['code'] == 2) {
                            let dropdown = '<select id="employeeSelectorDropdown"><option value="">Unset (No Primary Admin selected)</option>';

                            for (let i in admin_list) {
                                let primary = '';

                                if (admin_list[i].primary_admin) {
                                    primary = 'selected="selected"';
                                }
                                dropdown += '<option value="'+admin_list[i].userName+'" '+ primary +'>'+admin_list[i].lastName+', '+admin_list[i].firstName+'</option>';
                            }

                            dialog.setContent('<button class="usa-button leaf-btn-small leaf-float-right" onclick="viewHistory()">View History</button>'+
                                '<h2 role="heading" tabindex="-1">Primary Administrator</h2><h3 role="heading" tabindex="-1" class="leaf-marginTop-1rem">Set Primary Administrator</h3><div id="employeeSelector">'+dropdown+'</div></br></br><div id="primaryAdminSummary"></div>');

                            dialog.showButtons();

                            // reset dialog for regular content
                            $(".ui-dialog>div").css('width', 'auto');
                            $(".leaf-dialog-content").css('width', 'auto');
                            dialog.setSaveHandler(function() {
                                let selectedUserName = $('#employeeSelectorDropdown').val();

                                if (selectedUserName) {
                                    setPrimaryAdmin(selectedUserName);
                                } else {
                                    unsetPrimaryAdmin();
                                }

                                dialog.hide();
                            });
                            dialog.show();
                        } else {
                            displayDialogOk(response.status['message']);
                        }
                    }
                    $('#primaryAdmin').on('click', function() {
                		openPrimaryAdminGroup();
                	});

                    //508 fix
                    $('#primaryAdmin').on('keydown', function(event) {
                        if(event.keyCode === 13 || event.keyCode === 32) {
                            openPrimaryAdminGroup();
                        }
                    });
                    $('#membersPrimaryAdmin').html('');
                    let primaryAdminName = "Primary Admin has not been set.";
                    for(let j in res[i].members) {
                        if(res[i].members[j].primary_admin == 1)
                        {
                             primaryAdminName = toTitleCase(res[i].members[j].Fname) + ' ' + toTitleCase(res[i].members[j].Lname);
                        }
                    }
                    $('#membersPrimaryAdmin').append('<div class="groupUserFirst">' + primaryAdminName + '</div>');
                    $('#membersPrimaryAdmin').append('<div class="groupUser">' + primaryAdminName + ' </div>');
                }
            }
            // update total numbers in left nav
            allGroupsCount = userGroupCount + sysAdminCount;
            $('#allGroupsCount').text(allGroupsCount);
            $('#userGroupsCount').text(userGroupCount);
            $('#sysAdminsCount').text(sysAdminCount);
            // enable search box
            $('#userGroupSearch').attr('disabled',false);
            // focus on search box
            $('#userGroupSearch').focus();
        },
        cache: false
    });
}

$(function() {
    $('#employeeSelectorDropdown').chosen({disable_search_threshold: 5, allow_single_deselect: true, width: '80%'});
    $('#employeeSelectorDropdown_chosen input.chosen-search-input').attr('aria-labelledby', 'format_label_employeeSelectorDropdown');
});

function getMemberList(group_id, callback) {
    $.ajax({
        async: false,
        type: 'GET',
        url: "../api/group/"+ group_id +"/list_members",
        dataType: "json",
        success: function (res) {
            callback(res);
        },
        error: function (err) {
            callback(err);
        },
        cache: false
    });
}

function viewHistory(groupID){
     // reset dialog for regular content
    $(".ui-dialog>div").css('width', 'auto');
    $(".leaf-dialog-content").css('width', 'auto');
    dialog_simple.setContent('');
    dialog_simple.setTitle('Group history');
    dialog_simple.indicateBusy();
    dialog.showButtons();

    let type = (groupID)? "group": "primaryAdmin";
    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistory&type='+type+'&id='+groupID+'&tz='+tz,
        dataType: 'text',
        success: function(res) {
            dialog_simple.setContent(res);
            dialog_simple.indicateIdle();
            dialog_simple.show();
        },
        cache: false
    });

}

function viewPrimaryAdminHistory(){
     // reset dialog for regular content
    $(".ui-dialog>div").css('width', 'auto');
    $(".leaf-dialog-content").css('width', 'auto');
    dialog_simple.setContent('');
    dialog_simple.setTitle('Primary Admin History');
	dialog_simple.indicateBusy();
    dialog.showButtons();
    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistory&type=primaryAdmin&tz='+tz,
        dataType: 'text',
        success: function(res) {
            dialog_simple.setContent(res);
            dialog_simple.indicateIdle();
            dialog_simple.show();
        },
        cache: false
    });
}

// used to import and add groups
function tagAndUpdate(groupID, callback) {
    $.when(
            $.ajax({
                type: 'POST',
                url: '<!--{$orgchartPath}-->/api/group/'+ groupID + '/tag',
                data: {
                    tag: '<!--{$orgchartImportTag}-->',
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function() {
                },
                cache: false
            }),
            $.ajax({
                type: 'GET',
                url: '../api/system/importGroup/' + groupID,
                success: function() {
                },
                cache: false
            })
        ).then(function() {
        	if(callback != undefined) {
        		callback();
        	}
            window.location.reload();
    });
}

function importGroup() {
    // reset dialog for regular content
    $(".ui-dialog>div").css('width', 'auto');
    $(".leaf-dialog-content").css('width', 'auto');
    dialog_import.setTitle('Import Group');
    dialog_import.setContent('<p role="heading" tabindex="-1">Import a group from another LEAF site:</p><div class="leaf-marginTop-1rem"><label>Group Title</label><div id="groupSel_container"></div></div>');
    dialog_import.showButtons();
    let groupSel = new groupSelector('groupSel_container');
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
            if(groupSel.jsonResponse[i]?.tags?.service != undefined) {
                $('#' + groupSel.prefixID + 'grp' + groupSel.jsonResponse[i].groupID).css('display', 'none');
            }
        }
    });
    groupSel.initialize();

    dialog_import.setSaveHandler(function() {
        if(groupSel.selection != '') {
        	tagAndUpdate(groupSel.selection);
            $.ajax({
                type: 'POST',
                url: "../api/group/import",
                data: {title: groupSel.selectionData[groupSel.selection].groupTitle,
                CSRFToken: '<!--{$CSRFToken}-->'},
                cache: false
            });
        }
    });
    dialog_import.show();
}

function createGroup() {
    dialog.setTitle('Create a new group');
    dialog.setContent('<div><label for="groupNameInput">Group Title</label><div class="leaf-marginTop-halfRem"><input id="groupNameInput" class="usa-input" size="36"/></div></div>');
    dialog.showButtons();
    dialog.setSaveHandler(function() {
    	dialog.indicateBusy();
        //list of possible errors returned by the api call
        possibleErrors = [
            "Group title must not be blank",
            "Group title already exists",
            "invalid parent group"
        ];
        $.ajax({
            type: 'POST',
            url: "../api/group/",
            data: {title: $('#groupNameInput').val(),
            CSRFToken: '<!--{$CSRFToken}-->'},
            cache: false
        });
        $.ajax({
            type: 'POST',
            url: '<!--{$orgchartPath}-->/api/group',
            data: {title: $('#groupNameInput').val(),
                   CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if(possibleErrors.indexOf(res) != -1) {
                    alert(res);
                    dialog.hide();
                }
                else {
                    tagAndUpdate(res, function() {
                    dialog.indicateIdle();
                    });
                }
            },
            cache: false
        });
    });
    dialog.show();
    $('input:visible:first, select:visible:first').focus();
}

// convert to title case
function toTitleCase(str) {
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function showAllGroupHistory() {
     // reset dialog for regular content
    $(".ui-dialog>div").css('width', 'auto');
    $(".leaf-dialog-content").css('width', 'auto');
    dialog_simple.setContent('');
    dialog_simple.setTitle('All group history');
    dialog_simple.indicateBusy();
    dialog.showButtons();
    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistoryall&type=group&tz='+tz,
        dataType: 'text',
        success: function(res) {
            dialog_simple.setContent(res);
            dialog_simple.indicateIdle();
            dialog_simple.show();
        },
        cache: false
    });

}

// Define dialog boxes
let dialog;
let dialog_simple;
let dialog_confirm;
let dialog_import;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_import = new dialogController('import_dialog', 'import_xhr', 'importloadIndicator', 'button_import', 'importbutton_cancelchange');
	dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    getGroupList();
    dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok', 'confirm_button_cancelchange');
});

/* ]]> */
</script>
