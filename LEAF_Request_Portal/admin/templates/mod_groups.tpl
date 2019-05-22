<div id="sideBar" style="float: right">
    <button class="buttonNorm" onclick="importGroup();" style="font-size: 120%"><img src="../../libs/dynicons/?img=edit-copy.svg&w=32" alt="Import Group" /> Import Existing Group</button>
    <button class="buttonNorm" onclick="createGroup();" style="font-size: 120%"><img src="../../libs/dynicons/?img=list-add.svg&w=32" alt="Create Group" /> Create New Group</button>
</div>
<br style="clear: both" />
<div>
    <h2 role="heading" tabindex="-1">Site Administrators</h2>
    <div id="adminList"></div>
    <br style="clear: both" />
    <h2 role="heading" tabindex="-1">User Groups</h2>
    <div id="groupList"></div>
</div>

<br style="clear: both" />

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function getMembers(groupID) {
    $.ajax({
        url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=" + groupID,
        dataType: "json",
        success: function(response) {
            $('#members' + groupID).fadeOut();
            populateMembers(groupID, response);
            $('#members' + groupID).fadeIn();
        }
    });
}

function populateMembers(groupID, members) {
    $('#members' + groupID).html('');
    for(var i in members) {
        $('#members' + groupID).append(members[i].Lname + ', ' + members[i].Fname + '<br />');
    }
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
        }
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
        }
    });
}

function focusGroupsAndMembers(groupID) {
    $('#' + groupID).on('focusin', function() {
        $('#' + groupID).css('background-color', '#fffdc2');
    });
    $('#' + groupID).on('focusout', function() {
        $('#' + groupID).css('background-color', 'white');
    });
}
function getGroupList() {
    $('#groupList').html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="loading..." /></div>');

    $.ajax({
        type: 'GET',
        url: "../api/group/members",
        dataType: "json",
        success: function(res) {
            $('#groupList').html('');
            for(var i in res) {

            	// only show explicit groups, not ELTs
            	if(res[i].parentGroupID == null
            		&& res[i].groupID != 1) {
                    $('#groupList').append('<div tabindex="0" id="'+ res[i].groupID +'" title="groupID: '+ res[i].groupID +'" class="groupBlock">\
                            <h2 id="groupTitle'+ res[i].groupID +'">'+ res[i].name +'</h2>\
                            <div id="members'+ res[i].groupID +'"></div>\
                            </div>');
            	}
            	else if(res[i].groupID == 1) {
                    $('#adminList').append('<div tabindex="0" id="'+ res[i].groupID +'" title="groupID: '+ res[i].groupID +'" class="groupBlock">\
                            <h2 id="groupTitle'+ res[i].groupID +'">'+ res[i].name +'</h2>\
                            <div id="members'+ res[i].groupID +'"></div>\
                            </div>');
            	}

                focusGroupsAndMembers(res[i].groupID);
                if(res[i].groupID != 1) { // if not admin
                    function openGroup(groupID, parentGroupID) {
                        dialog_simple.setContent('<iframe src="<!--{$orgchartPath}-->/?a=view_group&groupID=' + groupID + '&iframe=1" tabindex="0" style="width: 99%; height: 99%; border: 0px; background:url(../images/largespinner.gif) center top no-repeat;"></iframe>');
                        dialog_simple.setCancelHandler(function() {
                            $.ajax({
                                type: 'GET',
                                url: '../api/?a=system/updateGroup/' + groupID,
                                success: function() {
                                    getMembers(groupID);
                                },
                                cache: false
                            });
                        });
                        //508 fix
                        setTimeout(function () {
                            $("#simplebutton_cancelchange").remove();
                            $("#simplebutton_save").remove();
                            dialog_simple.show();
                        }, 0);
                    }

                    //508 fix
                    $('#' + res[i].groupID).on('click', function(groupID, parentGroupID) {
                        return function() {
                            openGroup(groupID, parentGroupID);
                        };
                    }(res[i].groupID, res[i].parentGroupID));
                    $('#' + res[i].groupID).on('keydown', function(groupID, parentGroupID) {
                        return function(event) {
                            if(event.keyCode === 13 || event.keyCode === 32) {
                                openGroup(groupID, parentGroupID);
                            }
                        };
                    }(res[i].groupID, res[i].parentGroupID));
                }
                else { // if is admin
                    function openAdminGroup(){
                        dialog.setContent('<h2 role="heading" tabindex="-1">System Administrators</h2><div id="adminSummary"></div><br /><h3 role="heading" tabindex="-1" >Add Administrator:</h3><div id="employeeSelector"></div>');

                        empSel = new nationalEmployeeSelector('employeeSelector');
                        empSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
                        empSel.rootPath = '<!--{$orgchartPath}-->/';
                        empSel.outputStyle = 'micro';
                        empSel.initialize();

                        dialog.setSaveHandler(function() {
                            if(empSel.selection != '') {
                                var selectedUserName = empSel.selectionData[empSel.selection].userName;
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
                                    }
                                });
                            }
                            dialog.hide();
                        });
                        $.ajax({
                            url: "ajaxJSON.php?a=mod_groups_getMembers&groupID=1",
                            dataType: "json",
                            success: function(res) {
                                $('#adminSummary').html('');
                                var counter = 0;
                                for(var i in res) {
                                    $('#adminSummary').append('<div>&bull; '+ res[i].Lname  + ', ' + res[i].Fname +' [ <a tabindex="0" aria-label="Remove '+ res[i].Lname  + ', ' + res[i].Fname +'" href="#" id="removeAdmin_'+ counter +'">Remove</a> ]</div>');
                                    $('#removeAdmin_' + counter).on('click', function(userID) {
                                        return function() {
                                            removeAdmin(userID);
                                            dialog.hide();
                                        };
                                    }(res[i].userName));
                                    counter++;
                                }
                            }
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
            }
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
                }
            }),
            $.ajax({
                type: 'GET',
                url: '../api/?a=system/updateGroup/' + groupID,
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
    dialog.setTitle('Import Group');
    dialog.setContent('<h2 role="heading" tabindex="-1">Import a group from another LEAF site.</h2><br /><div role="heading" tabindex="-1">Group Title: </div><div id="groupSel_container"></div>');

    var groupSel = new groupSelector('groupSel_container');
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
        for(var i in groupSel.jsonResponse) {
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
        }
    });
    dialog.show();
}

function createGroup() {
    dialog.setTitle('Create a new group');
    dialog.setContent('<div><br /><div role="heading" style="display:inline">Group Title: </div><input aria-label="Enter group name" id="groupName"></input></div>');

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
            url: '<!--{$orgchartPath}-->/api/?a=group',
            data: {title: $('#groupName').val(),
                   CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(res) {
                if(possibleErrors.includes(res)) {
                    alert(res);
                    dialog.hide();
                }
                else {
                    tagAndUpdate(res, function() {
                        dialog.indicateIdle();
                    });
                }
            }
        });
    });
    dialog.show();
    $('input:visible:first, select:visible:first').focus();
}

var dialog;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');

	$('#simpleloadIndicator').css({width: $(window).width() * .78, height: $(window).height() * .78});
	$('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});

    getGroupList();
});

/* ]]> */
</script>
