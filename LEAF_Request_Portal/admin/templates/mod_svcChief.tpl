<div class="leaf-center-content">

    <aside class="sidenav-right"></aside>
    
    <!--{assign var=left_nav_content value="
        <div id='sideBar'>
            <button id='btn_uploadFile' class='usa-button leaf-width-12rem' onclick='syncServices();'>
                Import from Nexus
            </button>
        </div>
    "}-->
    <!--{include file="partial_layouts/left_side_nav.tpl" contentLeft="$left_nav_content"}-->
    
    <main class="main-content">
        <h2>Service Chiefs</h2>

        <div>
            <div id="groupList"></div>
        </div>

        <div class="leaf-row-space"></div>
    </div>
    
</div>


<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function syncServices() {
    dialog_simple.setTitle('Importing from Nexus...');
    dialog_simple.show();
    $.ajax({
        type: 'GET',
        url: "../scripts/updateServicesFromOrgChart.php",
        success: function(response) {
            dialog_simple.setContent(response);
        },
        cache: false
    });
}

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

    dialog.show();*/

    dialog_simple.setTitle('Create new service');
    dialog_simple.setContent('Changes to services must be made through Links->Nexus at the moment.');
    
    dialog_simple.show();
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
    var memberCt = (members.length - 1);
    var countTxt = (memberCt > 0) ? (' + ' + memberCt + ' others') : '';
    for(var i in members) {
    	if(members[i].active == 1) {
            if (i == 0) {
                $('#members' + groupID).append('<span>' + toTitleCase(members[i].Fname) + ' ' + toTitleCase(members[i].Lname) + countTxt + '</span>');
            }
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
        },
        cache: false
    });
}

function removeUser(groupID, userID) {
    $.ajax({
        type: 'DELETE',
        url: "../api/service/" + groupID + "/members/_" + userID + '&CSRFToken=<!--{$CSRFToken}-->',
        success: function(response) {
            getMembers(groupID);
        },
        cache: false
    });
}

function initiateWidget(serviceID) {
    $('#' + serviceID).on('click', function(serviceID) {
        return function() {
            $.ajax({
                type: 'GET',
                url: '../api/service/' + serviceID + '/members',
                success: function(res) {
                    dialog.clear();
                    var button_deleteGroup = '<button id="deleteGroup_'+serviceID+'" class="usa-button usa-button--secondary leaf-btn-small">Delete this group</button>';
                    if(serviceID > 0) {
                        button_deleteGroup = '';
                    }
                    dialog.setContent(
                        '<button class="usa-button usa-button--secondary leaf-btn-small leaf-float-right" onclick="viewHistory(' + serviceID + ')">View History</button>'+
                        '<div id="employees"></div><h3 class="leaf-marginTop-1rem">Add Employee</h3><div id="employeeSelector"></div>' + button_deleteGroup);
                    $('#employees').html('<div id="employee_table" class="leaf-marginTopBot-1rem"></div>');
                    var counter = 0;
                    for(var i in res) {
                        var removeButton = '<a href="#" class="text-secondary-darker leaf-font0-8rem" id="removeMember_'+ counter +'">REMOVE</a>';
                        var managedBy = '';
                        if(res[i].locallyManaged != 1) {
                            managedBy += '<div class="leaf-marginLeft-qtrRem leaf-font0-8rem">&bull; Managed in Org. Chart</div>';
                        }
                        if(res[i].active != 1) {
                            managedBy += '<div class="leaf-marginLeft-qtrRem leaf-font0-8rem">&bull; Managed in Org. Chart</div>';
                            managedBy += '<div class="leaf-marginLeft-qtrRem leaf-font0-8rem">&bull; Override set, and they do not have access</div>';
                            removeButton = '<a href="#" class="text-secondary-darker leaf-font0-8rem" id="removeMember_'+ counter +'">REMOVE OVERRIDE</a>';
                        }
                        $('#employee_table').append('<div class="leaf-font0-9rem leaf-marginTop-halfRem"><span class="leaf-bold">'+ toTitleCase(res[i].Fname) + ' ' + toTitleCase(res[i].Lname) + '</span> - ' + removeButton + ' '+ managedBy +'</div>');
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
                                },
                                cache: false
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
    }(serviceID));
}

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
		var quadrads = res1[0];
		var services = res2[0];
	    for(var i in quadrads) {
	    	$('#groupList').append('<h2>'+ toTitleCase(quadrads[i].name) +'</h2><div class="leaf-displayFlexRow" id="group_'+ quadrads[i].groupID +'"></div>');
	    }
	    for(var i in services) {
	    	$('#group_' + services[i].groupID).append('<div id="'+ services[i].serviceID +'" title="serviceID: '+ services[i].serviceID +'" class="groupBlockWhite">'
                    + '<h2 id="groupTitle'+ services[i].serviceID +'">'+ services[i].service +'</h2>'
                    + '<div id="members'+ services[i].serviceID +'"></div>'
                    + '</div>');
	    	initiateWidget(services[i].serviceID);
	    	populateMembers(services[i].serviceID, services[i].members);
	    }
	});
}

function viewHistory(groupID){
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
        cache: false
    });
}

// convert to title case
function toTitleCase(str) {
    return (str == "" || str == null) ? "" : str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator', 'simplebutton_save', 'simplebutton_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    getGroupList();
});

/* ]]> */
</script>