<div id="sideBar" style="float: right; width: 150px">
    <div class="buttonNorm" onclick="createGroup();" style="font-size: 120%"><img src="../../libs/dynicons/?img=list-add.svg&w=32" alt="Create Service" /> Create Service</div><br />
</div>
<br style="clear: both" />
<div>
    <span style="font-size: 18px; font-weight: bold"></span>
    <br /><br />

    <div id="groupList"></div>
</div>


<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function createGroup() {
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
    		for(var i in res) {
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

    dialog.show();
}

function getMembers(groupID) {
    $.ajax({
        type: 'GET',
        url: '../api/?a=system/updateService/' + groupID,
        success: function() {
            $.ajax({
                url: "../api/service/" + groupID + "/members",
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

function populateMembers(groupID, members) {
    $('#members' + groupID).html('');
    for(var i in members) {
    	if(members[i].active == 1) {
            $('#members' + groupID).append(members[i].Lname + ', ' + members[i].Fname + '<br />');
    	}
    }
}

function addUser(groupID, userID) {
    $.ajax({
        type: 'POST',
        url: "../api/service/" + groupID + "/members",
        data: {'userID': userID,
               'CSRFToken': '<!--{$CSRFToken}-->'},
        success: function(response) {
            getMembers(groupID);
        }
    });
}

function removeUser(groupID, userID) {
    $.ajax({
        type: 'DELETE',
        url: "../api/service/" + groupID + "/members/_" + userID + '&CSRFToken=<!--{$CSRFToken}-->',
        success: function(response) {
            getMembers(groupID);
        }
    });
}


function getGroupList() {
    $('#groupList').html('<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Loading... <img src="../images/largespinner.gif" alt="loading..." /></div>');

    $.ajax({
    	type: 'GET',
        url: "../api/service",
        dataType: "json",
        success: function(res) {
    	    $('#groupList').html('');
    	    for(var i in res) {
    	    	$('#groupList').append('<div id="'+ res[i].serviceID +'" title="serviceID: '+ res[i].serviceID +'" class="groupBlock">\
    	    			                <h2 id="groupTitle'+ res[i].serviceID +'">'+ res[i].service +'</h2>\
    	    			                <div id="members'+ res[i].serviceID +'"></div>\
    	    		                    </div>');
    	    	$('#' + res[i].serviceID).on('click', function(serviceID) {
    	    		return function() {
                        $.ajax({
                            type: 'GET',
                            url: '../api/service/' + serviceID + '/members',
                            success: function(res) {
                            	dialog.clear();
                            	var button_deleteGroup = '<br /><br /><div id="deleteGroup_'+serviceID+'" class="buttonNorm" style="background-color: red">Delete this group</div>';
                            	if(serviceID > 0) {
                            		button_deleteGroup = '';
                            	}
                                dialog.setContent('<div id="employees"></div><br /><h3>Add Employee:</h3><div id="employeeSelector"></div><br /><br />' + button_deleteGroup);
                                $('#employees').html('<table id="employee_table" class="table"></table>');
                                var counter = 0;
                                for(var i in res) {
                                	var removeButton = '<span class="buttonNorm" id="removeMember_'+ counter +'">Remove</span>';
                                	var managedBy = '';
                                	if(res[i].locallyManaged != 1) {
                                		managedBy += '<br /> * Managed in Org. Chart';
                                	}
                                    if(res[i].active != 1) {
                                        managedBy += '<br /> * Managed in Org. Chart';
                                        managedBy += '<br /> * Override set, and they do not have access';
                                        removeButton = '<span class="buttonNorm" id="removeMember_'+ counter +'">Remove Override</span>';
                                    }
                                	$('#employee_table').append('<tr><td>'+ res[i].Lname + ', ' + res[i].Fname + managedBy +'</td><td>'+ removeButton +'</td></tr>');
                                    $('#removeMember_' + counter).on('click', function(userID) {
                                        return function() {
                                            removeUser(serviceID, userID);
                                            dialog.hide();
                                        };
                                    }(res[i].userName));
                                    counter++;
                                }

                                $('#deleteGroup_' + serviceID).on('click', function() {
                                	dialog_confirm.setContent('Are you sure you want to delete this service?');
                                	dialog_confirm.setSaveHandler(function() {
                                	    $.ajax({
                                	        type: 'DELETE',
                                	        url: "../api/service/" + serviceID + '&CSRFToken=<!--{$CSRFToken}-->',
                                	        success: function(response) {
                                	            location.reload();
                                	        }
                                	    });
                                	});
                                	dialog_confirm.show();
                                });
                                
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
                                                	addUser(serviceID, selectedUserName);
                                                }
                                                else {
                                                    alert(res);
                                                }
                                            }
                                        });
                                    }
                                    getMembers(serviceID);
                                    dialog.hide();
                                });

                                dialog.show();
                            },
                            cache: false
                        });
    	    		};
    	    	}(res[i].serviceID));
    	    	populateMembers(res[i].serviceID, res[i].members);
    	    }
        },
        cache: false
    });
}

$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    $('#simpleloadIndicator').css({width: $(window).width() * .78, height: $(window).height() * .78});
    $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});

    getGroupList();
});

/* ]]> */
</script>