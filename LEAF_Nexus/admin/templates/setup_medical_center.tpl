<div id="menu" style="float: left; width: 200px; margin: 4px">
    <div onclick="setupAdmins();"><input id="menu_admins" class="buttonNorm step" style="width: 200px;"  type="button" value="1. System Administrators" /></div>
    <div onclick="setupPreferences();"><input id="menu_preferences" class="buttonNorm step" style="width: 200px;" type="button" value="2. Site Preferences" /></div>
    <div onclick="setupDirector();"><input id="menu_director" class="buttonNorm step" style="width: 200px;" type="button" value="3. Site Director" /></div>
    <div  onclick="setupLeadership();"><input id="menu_leadership" class="buttonNorm step" style="width: 200px;" type="button" value="4. Executive Leadership Team" /></div>
    <div  onclick="setupServices();"><input id="menu_services" class="buttonNorm step" style="width: 200px;" type="button" value="5. Services" /></div>
</div>
<div id="setupContainer" style="float: left; margin: 8px; width: 800px; height: 600px">

</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_plainDialogLarge.tpl"}-->

<script>
var CSRFToken = '<!--{$CSRFToken}-->';

function setupAdmins() {
    $('.step').removeClass('buttonNormSelected');
    $('#menu_admins').addClass('buttonNormSelected');

    $('#setupContainer').html('<iframe style="border: 0px; width: 100%; height: 100%" src="../?a=view_group&groupID=1&iframe=1"></iframe>');
}

function setupPreferences() {
	$('.step').removeClass('buttonNormSelected');
	$('#menu_preferences').addClass('buttonNormSelected');

	$('#setupContainer').html('<iframe style="border: 0px; width: 100%; height: 100%" src="./?a=mod_system&iframe=1"></iframe>');
}

function setupDirector() {
	$('.step').removeClass('buttonNormSelected');
    $('#menu_director').addClass('buttonNormSelected');

    $('#setupContainer').html('<fieldset><legend style="color: black; font-size: 14px">Position</legend><div tabindex="0" id="director" class="groupBlock">\
            <h2 id="groupTitle">Medical Center Director</h2>\
            <div id="members"></div>\
            </div>\
            <div style="float: left">Ensure your facility\'s director is listed here.<br />\
              <ol>\
                <li>Click "Add Director" (A pop-up window will open)</li>\
                <li>Click "Add Employee", and select your facility\'s director</li>\
                <li>Close the pop-up window that opened in step 1</li>\
              </ol></div>\
            </fieldset>\
            <fieldset><legend style="color: black; font-size: 14px">Service</legend><div id="service"></div></fieldset>');

    $('#director').on('click keydown', function() {
        if(event.type === "click" || [13,32].includes(event?.keyCode)) {
            dialog_large.setTitle('Site Director');
            dialog_large.setContent('<iframe tabindex="0" id="directorIframe" style="border: 0px; width: 100%; height: 100%" src="../?a=view_position&positionID=1&iframe=1"></iframe>');

            dialog_large.setCancelHandler(function() {
                setupDirector();
            });

            dialog_large.show();
        }
    });

    $.ajax({
        type: 'GET',
        url: '../api/position/1/employees',
        success: function(res) {
            if(res.length > 0) {
                let buffer = '';
                for(let i in res) {
                    buffer += res[i].lastName + ', ' + res[i].firstName + '<br />';
                }
                $('#members').html(buffer);
            }
            else {
                $('#members').html('<div class="buttonNorm">Add Director</div>');
            }
        },
        error: function(err) {
            console.log(err)
        },
        cache: false
    });

    $.ajax({
        type: 'GET',
        url: '../api/position/1/service',
        success: function(res) {
            if(res[0] != null) {
                $('#service').html('<span style="font-size: 140%">' + res[0].groupTitle + '</span>');
            }
            else {
                $('#service').html('The "Office of the Director" service does not exist.<br /><br /><button class="buttonNorm" onclick="createDirectorGroup();">Click here to Create the Service</button>');
            }
        },
        error: function(err) {
            console.log(err)
        },
        cache: false
    });
}

function createDirectorGroup() {
    dialog.setTitle('Create Group for Leadership Team');
    dialog.setContent('<table>\
                <tr>\
                    <td><label for="serviceName">Name of Service: </label></td>\
                    <td><input id="serviceName" type="text" value="Office of the Director" /></td>\
                </tr>\
            </table>');

    function tagNomenclature(groupID) {
        $.ajax({
            type: 'GET',
            url: '../api/tag/_service/parent',
            success: function(leadershipName) {
                $.ajax({
                    type: 'POST',
                    url: '../api/group/' + groupID + '/tag',
                    data: {CSRFToken: CSRFToken,
                        tag: leadershipName}
                });
                $.ajax({
                    type: 'POST',
                    url: '../api/group/' + groupID + '/tag',
                    data: {CSRFToken: CSRFToken,
                        tag: 'service'}
                });
            },
            cache: false
        });
    }

    dialog.setSaveHandler(function() {
        if($('#serviceName').val() == '') {
            alert('All fields must be filled out.');
        }
        else {
            // create group
            $.ajax({
                type: 'POST',
                url: '../api/group',
                data: {CSRFToken: CSRFToken,
                    title: $('#serviceName').val()},
                success: function(groupID) {
                    if(isNaN(groupID)) {
                        alert(groupID);
                    }
                    else {
                        tagNomenclature(groupID); // tag group

                        $.ajax({ // add position to the group
                            type: 'POST',
                            url: '../api/group/' + groupID + '/position',
                            data: {CSRFToken: CSRFToken,
                                positionID: 1},
                            success: function() {
                            	dialog.hide();
                            	setupDirector();
                            }
                        })
                    }
                }
            });
        }
    });

    dialog.show();
}

function createGroup() {
	dialog.setTitle('Create Group for Leadership Team');
	dialog.setContent('<table>\
		        <tr>\
			        <td><label for="serviceName">Name of Service: </label></td>\
			        <td><input id="serviceName" type="text" /> eg: "Office of the Chief of Staff"</td>\
			    </tr>\
			    <tr>\
                    <td><label for="positionTitle">Position Title: </label></td>\
                    <td><input id="positionTitle" type="text" /> eg: "Chief of Staff"</td>\
                </tr>\
                <tr>\
                    <td><label for="employee">Employee: </label></td>\
                    <td><div id="employee"></div>\
                        <br /><input id="isActing" type="checkbox" /><label for="isActing">Acting for vacant position</label>\
                    </td>\
                </tr>\
			</table>');

	function tagNomenclature(groupID) {
	    $.ajax({
	        type: 'GET',
	        url: '../api/tag/_service/parent',
	        success: function(leadershipName) {
	        	$.ajax({
	                type: 'POST',
	                url: '../api/group/' + groupID + '/tag',
	                data: {CSRFToken: CSRFToken,
	                	tag: leadershipName}
	            });
	        	$.ajax({
                    type: 'POST',
                    url: '../api/group/' + groupID + '/tag',
                    data: {CSRFToken: CSRFToken,
                        tag: 'service'}
                });
	        },
	        cache: false
	    });
	}

	dialog.setSaveHandler(function() {
		if($('#serviceName').val() == ''
			|| $('#positionTitle').val() == ''
			|| empSel.selection == '') {
			alert('All fields must be filled out.');
		}
		else {
			// create group
			$.ajax({
				type: 'POST',
				url: '../api/group',
				data: {CSRFToken: CSRFToken,
					title: $('#serviceName').val()},
				success: function(groupID) {
					if(isNaN(groupID)) {
						alert(groupID);
					}
					else {
						tagNomenclature(groupID); // tag group

						// create position
			            $.ajax({
			                type: 'POST',
			                url: '../api/position',
			                data: {CSRFToken: CSRFToken,
			                    title: $('#positionTitle').val(),
			                    parentID: 1}, // director (id# 1) is the supervisor
			                success: function(positionID) {
			                    if(isNaN(positionID)) {
			                        alert(positionID);
			                    }
			                    else {
			                    	$.when(
			                    			$.ajax({ // add position to the group
		                                        type: 'POST',
		                                        url: '../api/group/' + groupID + '/position',
		                                        data: {CSRFToken: CSRFToken,
		                                            positionID: positionID}
		                                    }),
		                                    $.ajax({ // import employee if necessary
		                                        type: 'POST',
		                                        url: '../api/employee/import/_' + empSel.selectionData[empSel.selection].userName,
		                                        dataType: 'json',
		                                        data: {CSRFToken: '<!--{$CSRFToken}-->'},
		                                        success: function(empUID) {
		                                            if(!isNaN(empUID)) {
		                                                $.ajax({ // add employee to the position
		                                                    type: 'POST',
		                                                    url: '../api/position/' + positionID + '/employee',
		                                                    data: {CSRFToken: CSRFToken,
		                                                        isActing: $('#isActing').prop('checked') ? 1 : 0,
		                                                        empUID: empUID}
		                                                })
		                                            }
		                                            else {
		                                                alert(response);
		                                                dialog.hide();
		                                            }
		                                        },
		                                        cache: false
		                                    })
		                                    ).then(function() {
		                                    	dialog.hide();
		                                    	setupLeadership();
		                                    });
			                    }
			                }
			            });
					}
				}
			});
		}
	});

	var empSel = new nationalEmployeeSelector('employee');
	empSel.apiPath = '../api/';
	empSel.rootPath = '../';
	empSel.initialize();

	dialog.show();
}

function setupLeadership() {
	$('.step').removeClass('buttonNormSelected');
    $('#menu_leadership').addClass('buttonNormSelected');

	$('#setupContainer').html('<div id="leaderHeader"><button class="buttonNorm" onclick="createGroup();" style="float: right; font-size: 120%"><img src="../dynicons/?img=list-add.svg&w=32" alt="" />Create <span id="leadershipNomenclature" style="font-size: 14px">Group</span></button><br style="clear: both" /></div>\
			<div id="leaders"></div>');

	var leadershipNomenclature = '';

    function loadEmployeeNames(positionID, groupID) {
        $.ajax({
            type: 'GET',
            url: '../api/position/' + positionID + '/employees',
            success: function(resEmployees) {
                for(var i in resEmployees) {
                	if(resEmployees[i].lastName != null) {
                		$('#members' + groupID).append(resEmployees[i].lastName + ', ' + resEmployees[i].firstName + '<br />');
                	}
                }
            },
            cache: false
        });
    }

    function loadPositions(groupID) {
        $.ajax({
            type: 'GET',
            url: '../api/group/' + groupID + '/positions',
            success: function(resPositions) {
                for(var j in resPositions) {
                    loadEmployeeNames(resPositions[j].positionID, groupID);
                }
            },
            cache: false
        });
    }

    $.ajax({
        type: 'GET',
        url: '../api/tag/_service/parent',
        success: function(leadershipName) {
            leadershipNomenclature = leadershipName;
            $('#leadershipNomenclature').html(leadershipName);
            $.ajax({
                type: 'GET',
                url: '../api/group/tag/_' + leadershipName,
                success: function(res) {
                    let buffer = '';
                    for(let i in res) {
                        buffer += '<div tabindex="0" id="group_'+ res[i].groupID +'" title="groupID: '+ res[i].groupID +'" class="groupBlock">\
                                <h2 id="groupTitle'+ res[i].groupID +'">'+ res[i].groupTitle +'</h2>\
                                <div id="members'+ res[i].groupID +'"></div>\
                                </div>';
                    }
                    $('#leaders').html(buffer);

                    for(let i in res) {
                        $('#group_' + res[i].groupID).on('click keydown', function(groupID) {
                            return function(event) {
                                if(event.type === "click" || [13,32].includes(event?.keyCode)) {
                                    dialog_large.setTitle('Leadership Team');
                                    dialog_large.setContent('<iframe tabindex="0" id="directorIframe" style="border: 0px; width: 100%; height: 100%" src="../?a=view_group&groupID=' + groupID + '&iframe=1"></iframe>');

                                    dialog_large.setCancelHandler(function() {
                                        setupLeadership();
                                    });

                                    dialog_large.show();
                                }
                            };
                        }(res[i].groupID));
                        loadPositions(res[i].groupID);
                    }
                },
                error: function(err) {
                    console.log(err)
                },
                cache: false
            });
        },
        cache: false
    });
    }

function createService(parentGroupID) {
    dialog.setTitle('Create Service');
    dialog.setContent('<table>\
                <tr>\
                    <td><label for="serviceName">Name of Service: </label></td>\
                    <td><input id="serviceName" type="text" /> eg: "Fiscal Service"</td>\
                </tr>\
                <tr>\
                    <td><label for="positionTitle">Position Title: </label></td>\
                    <td><input id="positionTitle" type="text" /> eg: "Chief, Fiscal Service"</td>\
                </tr>\
                <tr>\
                    <td><label for="employee">Employee: </label></td>\
                    <td><div id="employee"></div>\
                        <br /><input id="isActing" type="checkbox"/><label for="isActing">Acting for vacant position</label></div>\
                    </td>\
                </tr>\
            </table>');

    function tagNomenclature(groupID) {
        $.ajax({
            type: 'POST',
            url: '../api/group/' + groupID + '/tag',
            data: {CSRFToken: CSRFToken,
                tag: 'service'}
        });
    }

    dialog.setSaveHandler(function() {
        if($('#serviceName').val() == ''
            || $('#positionTitle').val() == ''
            || empSel.selection == '') {
            alert('All fields must be filled out.');
        }
        else {
            // create group
            $.ajax({
                type: 'POST',
                url: '../api/group',
                data: {CSRFToken: CSRFToken,
                    title: $('#serviceName').val()},
                success: function(groupID) {
                    if(isNaN(groupID)) {
                        alert(groupID);
                    }
                    else {
                        tagNomenclature(groupID); // tag group

                        // get the executive leader first
                        $.ajax({
                            type: 'GET',
                            url: '../api/group/' + parentGroupID + '/leader',
                            success: function(leaderID) {
                                $.ajax({
                                    type: 'POST',
                                    url: '../api/position',
                                    data: {CSRFToken: CSRFToken,
                                        title: $('#positionTitle').val(),
                                        parentID: leaderID},
                                    success: function(positionID) {
                                        if(isNaN(positionID)) {
                                            alert(positionID);
                                        }
                                        else {
                                            $.when(
                                                    $.ajax({ // add position to the group
                                                        type: 'POST',
                                                        url: '../api/group/' + groupID + '/position',
                                                        data: {CSRFToken: CSRFToken,
                                                            positionID: positionID}
                                                    }),
                                                    $.ajax({ // import employee if necessary
                                                        type: 'POST',
                                                        url: '../api/employee/import/_' + empSel.selectionData[empSel.selection].userName,
                                                        dataType: 'json',
                                                        data: {CSRFToken: '<!--{$CSRFToken}-->'},
                                                        success: function(empUID) {
                                                            if(!isNaN(empUID)) {
                                                                $.ajax({ // add employee to the position
                                                                    type: 'POST',
                                                                    url: '../api/position/' + positionID + '/employee',
                                                                    data: {CSRFToken: CSRFToken,
                                                                        isActing: $('#isActing').prop('checked') ? 1 : 0,
                                                                        empUID: empUID}
                                                                })
                                                            }
                                                            else {
                                                                alert(response);
                                                                dialog.hide();
                                                            }
                                                        },
                                                        cache: false
                                                    })
                                                    ).then(function() {
                                                        dialog.hide();
                                                        // write service on the page instead of reloading the whole page
                                                        $.ajax({
                                                        	type: 'GET',
                                                        	url: '../api/group/' + groupID,
                                                        	success: function(resGroup) {
                                                        		$('#group_' + parentGroupID).append('<li><a href="../?a=view_group&groupID='+ groupID +'">'+ resGroup.title +'</a></li>');
                                                        	}
                                                        });
                                                    });
                                        }
                                    }
                                });
                            }
                        });
                    }
                }
            });
        }
    });

    var empSel = new nationalEmployeeSelector('employee');
    empSel.apiPath = '../api/';
    empSel.rootPath = '../';
    empSel.initialize();

    dialog.show();
}

function setupServices() {
    $('.step').removeClass('buttonNormSelected');
    $('#menu_services').addClass('buttonNormSelected');

    $('#setupContainer').html('<div id="leaders"></div>');

    var leadershipNomenclature = '';
    function mapServiceToGroup(serviceData) {
        $.ajax({
            type: 'GET',
            url: '../api/group/' + serviceData.groupID + '/leader',
            success: function(leaderID) {
                $.ajax({
                    type: 'GET',
                    url: '../api/position/' + leaderID + '/search/parentTag/_' + leadershipNomenclature,
                    success: function(res2) {
                        $('#group_' + res2[0].groupID).append('<li><a href="../?a=view_group&groupID='+ serviceData.groupID +'">'+ serviceData.groupTitle +'</a></li>');
                    },
                    cache: false
                });
            },
            cache: false
        });
    }

    $.ajax({
        type: 'GET',
        url: '../api/tag/_service/parent',
        success: function(leadershipName) {
            $.ajax({
                type: 'GET',
                url: '../api/group/tag/_' + leadershipName,
                success: function(res) {
                	leadershipNomenclature = leadershipName;
                    var buffer = '<ul style="font-size: 140%">';
                    for(var i in res) {
                        buffer += '<li>'+ res[i].groupTitle +'<ul id="group_'+ res[i].groupID +'" style="margin-bottom: 1rem;">\
                            <li style="padding: 8px"><button class="buttonNorm" onclick="createService('+ res[i].groupID +');">Add Service</button></li>\
                        </ul></li>';
                    }
                    buffer += '</ul>';
                    $('#leaders').html(buffer);

                    $.ajax({
                        type: 'GET',
                        url: '../api/group/tag/_service',
                        success: function(services) {
                            var buffer = '';
                            for(var i in services) {
                            	mapServiceToGroup(services[i]);
                            }
                        },
                        cache: false
                    });
                },
                cache: false
            });
        },
        cache: false
    });
}

var dialog, dialog_confirm, dialog_large;
$(function() {
    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
    dialog_large = new dialogController('plainDialogLarge', 'plainLarge', 'loadIndicatorplainLarge', 'button_saveplainLarge', 'button_cancelchangeplainLarge');

	var hash = window.location.hash.substr(1);
	switch(hash.toLowerCase()) {
   	    case 'director':
            setupDirector();
            break;
	    case 'leadership':
		    setupLeadership();
		    break;
	    case 'services':
            setupServices();
            break;
	    default:
		    setupAdmins();
		    break;
	}

	$('#setupContainer').css('width', $(document).width() - 200 - 40);
    $('#plainDialogLarge').dialog({minWidth: ($(window).width() * .8) + 30});
});

</script>