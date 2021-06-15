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
            <p>Filter by group or user name</p>
            <input id="userGroupSearch" class="leaf-user-search-input" type="text" title="" onkeyup="searchGroups();" disabled />
        </div>

        <div id="noResultsMsg" class="leaf-no-results usa-alert usa-alert--error usa-alert--slim" role="alert">
            <p><i class="fas fa-exclamation-circle" alt="Error Icon"></i>No matching groups or users found.</p>
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
<!--{include file="../../../libs/smarty/loading_spinner.tpl" title='User Groups'}-->

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

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
    $.ajax({
        url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=" + groupID,
        dataType: "json",
        success: function(response) {
            $('#members' + groupID).fadeOut();
            populateMembers(groupID, response);
            $('#members' + groupID).fadeIn();
        },
        cache: false
    });
}

// All in one update for member groups (sync)
function updateAndGetMembers(groupID) {
    $.ajax({
        type: 'GET',
        url: '../api/?a=system/updateGroup/' + groupID,
        success: function() {
            $.ajax({
                url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=" + groupID,
                dataType: "json",
                success: function(response) {
                    $('#members' + groupID).fadeOut();
                    populateMembers(groupID, response);
                    $('#members' + groupID).fadeIn();
                },
                cache: false
            });
        },
        cache: false
    });
}

function getPrimaryAdmin() {
    $.ajax({
        url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=1",
        dataType: "json",
        success: function(response) {
            $('#membersPrimaryAdmin').fadeOut();
            $('#membersPrimaryAdmin').html('');
            let foundPrimary = false;
            for(let i in response) {
                if(response[i].primary_admin == 1)
                {
                    foundPrimary = true;
                    $('#membersPrimaryAdmin').append('<div class="groupUserFirst">' + toTitleCase(response[i].Fname) + ' ' + toTitleCase(response[i].Lname) + ' </div>');
                }
            }
            if(!foundPrimary)
            {
                $('#membersPrimaryAdmin').append("Primary Administrator has not been set");
            }
            $('#membersPrimaryAdmin').fadeIn();
        },
        cache: false
    });
}

function populateMembers(groupID, members) {
    $('#members' + groupID).html('');
    let memberCt = -1;
    let adminCt = (members.length - 1);
    for(let i in members) {
        if(members[i].active == 1 && members[i].backupID == null) {
            memberCt++;
        }
    }
    let j = 0;
    let countTxt = (memberCt > 0) ? (' + ' + memberCt + ' others') : '';
    let countAdminTxt = (adminCt > 0) ? (' + ' + adminCt + ' others') : '';
    for(let i in members) {
        if (members[i].active == 1 && members[i].backupID == null && groupID != 1) {
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
        type: 'DELETE',
        url: "../api/group/" + groupID + "/members/_" + userID + '&CSRFToken=<!--{$CSRFToken}-->',
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
    $.ajax({
        type: 'POST',
        url: "ajaxIndex.php?a=add_user",
        data: {'userID': userID,
               'groupID': 1,
               'CSRFToken': '<!--{$CSRFToken}-->'},
        success: function(response) {
        	getMembers(1);
        },
        cache: false
    });
}

function removeAdmin(userID) {
    $.ajax({
    	type: 'POST',
        url: "ajaxIndex.php?a=remove_user",
        data: {'userID': userID,
        	   'groupID': 1,
        	   'CSRFToken': '<!--{$CSRFToken}-->'},
        success: function(response) {
        	getMembers(1);
        },
        cache: false
    });
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
        cache: false
    });
}

function getGroupList() {

    // reset dialog for regular content
    $(".ui-dialog>div").css('width', '510');
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
                            url: '../api/group/' + groupID + '/members',
                            success: function(res) {
                                dialog.clear();
                                let button_deleteGroup = '<div><button id="deleteGroup_' + groupID + '" class="usa-button usa-button--secondary leaf-btn-small leaf-marginTop-1rem">Delete Group</button></div>';
                                dialog.setContent(
                                    '<div class="leaf-float-right"><div><button class="usa-button leaf-btn-small" onclick="viewHistory('+groupID+')">View History</button></div>' + button_deleteGroup + '</div>' +
                                    '<a class="leaf-group-link" href="<!--{$orgchartPath}-->/?a=view_group&groupID=' + groupID + '" title="groupID: ' + groupID + '" target="_blank"><h2 role="heading" tabindex="-1">' + groupName + '</h2></a><h3 role="heading" tabindex="-1" class="leaf-marginTop-1rem">Add Employee</h3><div id="employeeSelector"></div></br><div id="employees"></div>');
                                $('#employees').html('<div id="employee_table" class="leaf-marginTopBot-1rem"></div>');
                                let counter = 0;
                                for(let i in res) {
                                    // Check for active members to list
                                    if (res[i].active == 1) {
                                        if (res[i].backupID == null) {
                                            let removeButton = '- <a href="#" class="text-secondary-darker leaf-font0-7rem leaf-remove-button" id="removeMember_' + counter + '">REMOVE</a>';
                                            $('#employee_table').append('<a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=' + res[i].empUID + '" class="leaf-user-link" title="' + res[i].empUID + ' - ' + res[i].userName + '" target="_blank"><div class="leaf-marginTop-halfRem leaf-bold leaf-font0-9rem">' + toTitleCase(res[i].Lname) + ', ' + toTitleCase(res[i].Fname) + '</a> <span class="leaf-font-normal">' + removeButton + '</span></div>');
                                            // Check for Backups
                                            for (let j in res) {
                                                if (res[i].userName == res[j].backupID) {
                                                    $('#employee_table').append('<div class="leaf-font0-8rem leaf-marginLeft-qtrRem">&bull; ' + toTitleCase(res[j].Fname) + ' ' + toTitleCase(res[j].Lname) + ' - <span class="text-secondary-darker leaf-font0-7rem">Backup for ' + toTitleCase(res[i].Fname) + ' ' + toTitleCase(res[i].Lname) + '</span></div>');
                                                }
                                            }
                                            $('#removeMember_' + counter).on('click', function (userID) {
                                                return function () {
                                                    removeMember(groupID, userID);
                                                    dialog.hide();
                                                };
                                            }(res[i].userName));
                                            counter++;
                                        }
                                    }
                                }

                                $('#deleteGroup_' + groupID).on('click', function() {
                                    dialog_confirm.setContent('Are you sure you want to delete this group?');
                                    dialog_confirm.setSaveHandler(function() {
                                        $.ajax({
                                            type: 'DELETE',
                                            url: "../api/group/" + groupID + '&CSRFToken=<!--{$CSRFToken}-->',
                                            success: function(response) {
                                                location.reload();
                                            },
                                            cache: false
                                        });
                                        $.ajax({
                                            type: 'DELETE',
                                            url: '<!--{$orgchartPath}-->/api/?a=group/' + groupID + '/local/tag&'
                                                + $.param({tag: '<!--{$orgchartImportTag}-->',
                                                    CSRFToken: '<!--{$CSRFToken}-->'}),
                                            success: function() {
                                            },
                                            cache: false
                                        });
                                    });
                                    dialog_confirm.show();
                                });

                                empSel = new nationalEmployeeSelector('employeeSelector');
                                empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
                                empSel.rootPath = '<!--{$orgchartPath}-->/';
                                empSel.outputStyle = 'micro';
                                empSel.initialize();
                                // Update on any action
                                dialog.setCancelHandler(function() {
                                    updateAndGetMembers(groupID);
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
                                                    addMember(groupID, selectedUserName);
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
                                //508 fix
                                setTimeout(function () {
                                    $("#simplebutton_cancelchange").remove();
                                    $("#simplebutton_save").remove();
                                    dialog.show();
                                }, 0);
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
                        $.ajax({
                            url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=1",
                            dataType: "json",
                            success: function(res) {
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
                            },
                            cache: false
                        });
                        setTimeout(function () {
                            dialog.show();
                        }, 0);
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
                      dialog.setContent('<button class="usa-button leaf-btn-small leaf-float-right" onclick="viewHistory()">View History</button>'+
                            '<h2 role="heading" tabindex="-1">Primary Administrator</h2><h3 role="heading" tabindex="-1" class="leaf-marginTop-1rem">Set Primary Administrator</h3><div id="employeeSelector"></div></br></br><div id="primaryAdminSummary"></div>');

                        empSel = new nationalEmployeeSelector('employeeSelector');
                        empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
                        empSel.rootPath = '<!--{$orgchartPath}-->/';
                        empSel.outputStyle = 'micro';
                        empSel.initialize();
                        dialog.showButtons();
                         // reset dialog for regular content
                        $(".ui-dialog>div").css('width', 'auto');
                        $(".leaf-dialog-content").css('width', 'auto');
                        dialog.setSaveHandler(function() {
                            if(empSel.selection != '') {
                                let selectedUserName = empSel.selectionData[empSel.selection].userName;
                                $.ajax({
                                    url: 'ajaxJSON.php?a=mod_groups_getMembers&groupID=1',
                                    dataType: "json",
                                    data: {CSRFToken: '<!--{$CSRFToken}-->'},
                                    success: function(res) {
                                        let selectedUserIsAdmin = false;
                                        for(let i in res)
                                        {
                                            selectedUserIsAdmin = res[i].userName == selectedUserName;
                                            if(selectedUserIsAdmin){break;}
                                        }
                                        if(selectedUserIsAdmin)
                                        {
                                            setPrimaryAdmin(selectedUserName);
                                        }
                                        else
                                        {
                                            alert('Primary Admin must be a member of the Sysadmin group');
                                        }
                                    },
                                    cache: false
                                });
                            }
                            dialog.hide();
                        });
                        $.ajax({
                            url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=1",
                            dataType: "json",
                            success: function(res) {
                                $('#primaryAdminSummary').html('');
                                let foundPrimary = false;
                                for(let i in res) {
                                    if(res[i].primary_admin == 1)
                                    {
                                        foundPrimary = true;
                                        $('#primaryAdminSummary').append('<a class="leaf-user-link" href="<!--{$orgchartPath}-->/?a=view_employee&empUID=' + res[i].empUID + '" title="' + res[i].empUID + ' - ' + res[i].userName + '" target="_blank"><div><span class="leaf-bold leaf-font0-9rem">'+ toTitleCase(res[i].Lname) +', '+ toTitleCase(res[i].Fname) +'</span></a> - <a tabindex="0" aria-label="Unset '+ toTitleCase(res[i].Fname)  + ' ' + toTitleCase(res[i].Lname) +'" href="#" class="text-secondary-darker leaf-font0-8rem" id="unsetPrimaryAdmin">UNSET</a></div>');
                                        $('#unsetPrimaryAdmin').on('click', function() {
                                                unsetPrimaryAdmin();
                                                dialog.hide();
                                        });
                                    }
                                }
                                if(!foundPrimary)
                                {
                                   $('#primaryAdminSummary').append("Primary Admin has not been set.");
                                }

                            },
                            cache: false
                        });
                        setTimeout(function () {
                            dialog.show();
                        }, 0);
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
                url: '<!--{$orgchartPath}-->/api/?a=group/'+ groupID + '/tag',
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
                url: '../api/?a=system/importGroup/' + groupID,
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
    dialog.setTitle('Import Group');
    dialog.setContent('<p role="heading" tabindex="-1">Import a group from another LEAF site:</p><div class="leaf-marginTop-1rem"><label>Group Title</label><div id="groupSel_container"></div></div>');
    dialog.showButtons();
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
            if(groupSel.jsonResponse[i].tags.service != undefined) {
                $('#' + groupSel.prefixID + 'grp' + groupSel.jsonResponse[i].groupID).css('display', 'none');
            }
        }
    });
    groupSel.initialize();

    dialog.setSaveHandler(function() {
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
    dialog.show();
}

function createGroup() {
    dialog.setTitle('Create a new group');
    dialog.setContent('<div><label role="heading">Group Title</label><div class="leaf-marginTop-halfRem"><input aria-label="Enter group name" id="groupNameInput" class="usa-input" size="36"></input></div></div>');
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
            url: '<!--{$orgchartPath}-->/api/?a=group',
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
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    getGroupList();
});

/* ]]> */
</script>
