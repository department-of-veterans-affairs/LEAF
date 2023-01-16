<!-- <div id="sidebar">
placeholder<br />
</div> -->

<span id="editor_toolbar" class="noprint">
    <span id="editor_tools">
        <span onclick="zoomIn();"><img src="<!--{$libsPath}-->dynicons/?img=gnome-zoom-in.svg&amp;w=32" style="vertical-align: middle" alt="Zoom In" title="Zoom In" /> Zoom In</span>
        <span onclick="zoomOut();"><img src="<!--{$libsPath}-->dynicons/?img=gnome-zoom-out.svg&amp;w=32" style="vertical-align: middle" alt="Zoom Out" title="Zoom Out" /> Zoom Out</span>
        <!--{if $rootID != $topPositionID}-->
        <span onclick="viewSupervisor();"><img src="<!--{$libsPath}-->dynicons/?img=go-up.svg&amp;w=32" style="vertical-align: middle" alt="Zoom Out" title="Zoom Out" /> Go Up One Level</span>
        <!--{/if}-->
        <span onclick="window.location='mailto:?subject=FW:%20Org.%20Chart%20-%20&amp;body=Organizational%20Chart%20URL:%20<!--{if $smarty.server.HTTPS == on}-->https<!--{else}-->http<!--{/if}-->://<!--{$smarty.server.SERVER_NAME}--><!--{$smarty.server.REQUEST_URI|escape:'url'}-->%0A%0A'"><img src="<!--{$libsPath}-->dynicons/?img=mail-forward.svg&amp;w=32" style="vertical-align: middle" alt="Forward as Email" title="Forward as Email" /> Forward as Email</span>
    </span>
</span>

<div id="pageloadIndicator" style="visibility: visible">
    <div style="opacity: 0.8; z-index: 1000; position: absolute; background: #f3f3f3; height: 97%; width: 97%"></div>
    <div style="z-index: 1001; position: absolute; padding: 16px; width: 97%; text-align: center; font-size: 24px; font-weight: bold; background-color: white">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>
</div>

<div id="busyIndicator" style="visibility: hidden"><img src="<!--{$absOrgPath}-->/images/indicator.gif" alt="Busy..." /></div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

var positions = new Object();

function setZoomSmallest() {
    $('.positionSmall').css('width', '125px');
    $('.positionSmall').css('font-size', '63%');
    $('.positionSmall>div>div>div>img').css('width', '16px');
}

function setZoomSmall() {
    $('.positionSmall').css('width', '150px');
    $('.positionSmall').css('font-size', '75%');
    $('.positionSmall>div>div>div>img').css('width', '16px');
}

function setZoomMedium() {
    $('.positionSmall').css('width', '175px');
    $('.positionSmall').css('font-size', '87%');
    $('.positionSmall>div>div>div>img').css('width', '16px');
}

function setZoomLargest() {
    $('.positionSmall').css('width', '200px');
    $('.positionSmall').css('font-size', '100%');
    $('.positionSmall>div>div>div>img').css('width', '32px');
}

function zoomIn() {
	switch($('.positionSmall').css('width')) {
    case '200px':
    	alert('Maximum zoom level reached');
        break;
    case '175px':
    	setZoomLargest();
        saveZoomLevel(4);
        break;
    case '150px':
    	setZoomMedium();
        saveZoomLevel(3);
        break;
    case '125px':
    	setZoomSmall();
        saveZoomLevel(2);
    	break;
	}
	jsPlumb.repaintEverything();
}

function zoomOut() {
    switch($('.positionSmall').css('width')) {
    case '200px':
    	setZoomMedium();
        saveZoomLevel(3);
        break;
    case '175px':
        setZoomSmall();
        saveZoomLevel(2);
        break;
    case '150px':
    	setZoomSmallest();
        saveZoomLevel(1);
        break;
    case '125px':
    	alert('Minimum zoom level reached');
    	break;
 }
 jsPlumb.repaintEverything();
}

function applyZoomLevel() {
	switch(currentZoomLevel) {
        case 3:
            setZoomMedium();
            break;
        case 2:
            setZoomSmall();
            break;
        case 1:
            setZoomSmallest();
            break;
        default:
            setZoomLargest();
            break;
    }
}

function viewSupervisor() {
    $.ajax({
        url: './api/position/<!--{$rootID}-->/supervisor',
        dataType: 'json',
        success: function(response) {
            window.location = '?a=editor&rootID=' + response[0].positionID;
        },
        cache: false
    });
}

function saveLayout(positionID) {
	$('#busyIndicator').css('visibility', 'visible');
	var position = $('#' + positions[positionID].getDomID()).offset();
	var newPosition = new Object();
	newPosition.x = position.left;
	newPosition.y = position.top;
    $.ajax({
    	type: 'POST',
        url: './api/position/' + positionID,
        data: {15: JSON.stringify({<!--{$rootID}-->: newPosition}),
        	CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(res) {
            $('#busyIndicator').css('visibility', 'hidden');
        },
        cache: false
    });
}

function changeSupervisor(currPositionID) {
    dialog.setContent('Supervisor\'s Name or Title: <div id="positionSelector"></div>');
    dialog.show(); // need to show early because of ie6

    posSel = new positionSelector('positionSelector');
    posSel.libsPath = '<!--{$libsPath}-->';
    posSel.initialize();
    posSel.enableEmployeeSearch();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
        	type: 'POST',
            url: './api/position/' + currPositionID + '/supervisor',
            data: {positionID: posSel.selection,
                      CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                window.location.reload();
            },
            cache: false
        });
    });
}

function addSupervisor(positionID) {
    positions[positionID].unsetFocus();
    dialog.setContent('Full Position Title: <input id="inputtitle" style="width: 300px" class="dialogInput"></input>');
    dialog.setTitle('Add Supervisor');
    dialog.show(); // need to show early because of ie6
    $('#inputtitle').focus();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
            type: 'POST',
            url: './api/position',
            dataType: 'json',
            data: {title: $('#inputtitle').val(),
                      parentID: 0,
                      groupID: '<!--{$resolvedService[0]['groupID']}-->',
                      CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                if(isNaN(parseFloat(response))) {
                    alert('Error: Please check position title. ' + response);
                    dialog.indicateIdle();
                    return 0;
                }
                $.ajax({
                    type: 'POST',
                    url: './api/position/' + positionID + '/supervisor',
                    data: {positionID: response,
                              CSRFToken: '<!--{$CSRFToken}-->'},
                    success: function(response) {

                    },
                    cache: false
                });
                loadTimer = 0;
                // create position box
                positions[response] = new position(response);
                positions[response].initialize('bodyarea');
                positions[response].setRootID(0);
                positions[response].setTitle($('#inputtitle').val());
                positions[response].setContent('-');
                parentDomPosition = $('#' + positions[positionID].getDomID()).offset();
                parentDomPosition.left += 0;
                parentDomPosition.top -= 60;
                positions[response].setDomPosition(parentDomPosition.left, parentDomPosition.top);
                // make position box draggable
                draggableOptions.stop = function() {
                    saveLayout(response);
                };
                jsPlumb.draggable(positions[response].getDomID(), draggableOptions);

                // create and connect endpoints
                endPoints[response] = jsPlumb.addEndpoint(positions[response].getDomID(), {anchor: 'Center'}, endpointOptions);
                jsPlumb.connect({ source: endPoints[positionID],
                    target: endPoints[response],
                    connector: connectorOptions,
                    paintStyle: {stroke: "black", lineWidth: 2}
                });
                dialog.hide();
                applyZoomLevel();
            },
            cache: false
        });
    });
}


function addSubordinate(parentID) {
	positions[parentID].unsetFocus();
    dialog.setContent('Full Position Title: <input id="inputtitle" style="width: 300px" class="dialogInput"></input>');
    dialog.setTitle('Add Subordinate');
    dialog.show(); // need to show early because of ie6
    $('#inputtitle').focus();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
        	type: 'POST',
            url: './api/position',
            dataType: 'json',
            data: {title: $('#inputtitle').val(),
                      parentID: parentID,
                      groupID: '<!--{$resolvedService[0]['groupID']}-->',
                      CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
            	if(isNaN(parseFloat(response))) {
            		alert('Error: ' + response);
            		dialog.indicateIdle();
            		return 0;
            	}
            	loadTimer = 0;
            	// create position box
                positions[response] = new position(response);
                positions[response].initialize('bodyarea');
                positions[response].setRootID(parentID);
                positions[response].setTitle($('#inputtitle').val());
                positions[response].setContent('-');
                parentDomPosition = $('#' + positions[parentID].getDomID()).offset();
                parentDomPosition.left += 0;
                parentDomPosition.top += 80;
                positions[response].setDomPosition(parentDomPosition.left, parentDomPosition.top);
                positions[response].addControl('<div class="button" onclick="removePosition('+response+');"><img src="<!--{$libsPath}-->dynicons/?img=process-stop.svg&amp;w=32" alt="Remove Position" title="Remove Position" /> Remove Position</div>');
                positions[response].addControl('<div class="button" onclick="changeSupervisor('+response+');"><img src="<!--{$libsPath}-->dynicons/?img=system-users.svg&amp;w=32" alt="Change Supervisor" title="Change Supervisor" /> Change Supervisor</div>');
                // make position box draggable
                draggableOptions.stop = function() {
                	saveLayout(response);
                };
                jsPlumb.draggable(positions[response].getDomID(), draggableOptions);

                // create and connect endpoints
                endPoints[response] = jsPlumb.addEndpoint(positions[response].getDomID(), {anchor: 'Center'}, endpointOptions);
                jsPlumb.connect({ source: endPoints[parentID],
                    target: endPoints[response],
                    connector: connectorOptions,
                    paintStyle: {stroke: "black", lineWidth: 2}
                });
                dialog.hide();
                applyZoomLevel();
            },
            cache: false
        });
    });
}

function addSubgroup() {

}

var levelLimit = 5;
var undefinedPositionOffset = 80;
function getSubordinates(positionID, level) {
	loadTimer = 0;
    if(level >= levelLimit) {
        return false;
    }
    level++;
    for(var key in positions[positionID].data.subordinates) {
    	var subordinate = positions[positionID].data.subordinates;

        positions[subordinate[key].positionID] = new position(subordinate[key].positionID);
        positions[subordinate[key].positionID].initialize('bodyarea');
        positions[subordinate[key].positionID].setRootID(<!--{$rootID}-->);
        positions[subordinate[key].positionID].setParentID(positionID);

        positions[subordinate[key].positionID].onLoad = function() {
        	var loadSubordinates = 1;
        	var positionControls = '<div class="button" onclick="hideSubordinates('+subordinate[key].positionID+');"><img src="<!--{$libsPath}-->dynicons/?img=gnome-system-users.svg&amp;w=32" alt="Hide" title="Hide" /> Hide Subordinates</div>';
        	if(subordinate[key][15].data != '') {
                var subData = $.parseJSON(subordinate[key][15].data);
                if(subData[<!--{$rootID}-->] != undefined
                	&& subData[<!--{$rootID}-->].hideSubordinates != undefined
               		&& subData[<!--{$rootID}-->].hideSubordinates == 1) {

                	positionControls = '<div class="button" onclick="showSubordinates('+subordinate[key].positionID+');"><img src="<!--{$libsPath}-->dynicons/?img=system-users.svg&amp;w=32" alt="Show" title="Show" /> Show Subordinates</div>';
                	loadSubordinates = 0;
                }
        	}
        	else {
        		$('#' + positions[subordinate[key].positionID].getDomID()).css('box-shadow', ' 0 0 6px yellow');
        		positions[subordinate[key].positionID].setDomPosition(20, undefinedPositionOffset);
        		undefinedPositionOffset += 80;
        	}

        	if(subordinate[key].hasSubordinates == 1
       			&& loadSubordinates == 1) {
                $.ajax({
                    url: './api/position/' + subordinate[key].positionID,
                    dataType: 'json',
                    data: {q: this.q},
                    success: function(response) {
                    	positions[subordinate[key].positionID].data = response;
                    	getSubordinates(subordinate[key].positionID, level);
                    },
                    cache: false
                });
        	}

        	if(subordinate[key].hasSubordinates == 1) {
        		   positions[subordinate[key].positionID].addControl(positionControls);
        	}
        	else {
        		positions[subordinate[key].positionID].addControl('<div class="button" onclick="removePosition('+subordinate[key].positionID+');"><img src="<!--{$libsPath}-->dynicons/?img=process-stop.svg&amp;w=32" alt="Remove Position" title="Remove Position" /> Remove Position</div>');
        	}

        	var tPID = subordinate[key].positionID;
            draggableOptions.stop = function(params) {
                saveLayout(tPID);
            };
            jsPlumb.draggable(positions[subordinate[key].positionID].getDomID(), draggableOptions);

            endPoints[subordinate[key].positionID] = jsPlumb.addEndpoint(positions[subordinate[key].positionID].getDomID(), {anchor: 'Center'}, endpointOptions);

            jsPlumb.connect({ source: endPoints[subordinate[key].parentID],
                target: endPoints[subordinate[key].positionID],
                connector: connectorOptions,
                paintStyle: {stroke: "black", lineWidth: 2},
                cssClass: "editMode"
            });
            // dim other connectors while current selection is being modified
            $('#' + positions[subordinate[key].positionID].containerHeader).on('mousedown', function() {
            	$('svg.editMode path').css({'stroke': '#d0d0d0'});
            });

        	positions[subordinate[key].positionID].addControl('<div class="button" onclick="changeSupervisor('+subordinate[key].positionID+');"><img src="<!--{$libsPath}-->dynicons/?img=system-users.svg&amp;w=32" alt="Change Supervisor" title="Change Supervisor" /> Change Supervisor</div>');
        	positions[subordinate[key].positionID].addControl('<div class="button" onclick="window.location=\'?a=editor&amp;rootID='+subordinate[key].positionID+'\'"><img src="<!--{$libsPath}-->dynicons/?img=system-search.svg&amp;w=32" alt="Focus" title="Focus" /> Focus on This</div>');

            applyZoomLevel();
        };

        positions[subordinate[key].positionID].draw(subordinate[key]);
    }
}

function showSubordinates(positionID) {
    var data = new Object();
    data.hideSubordinates = 0;
    $.ajax({
    	type: 'POST',
        url: './api/position/' + positionID,
        data: {15: JSON.stringify({<!--{$rootID}-->: data}),
        	CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(res, args) {
        	window.location.reload();
        },
        cache: false
    });
}

function hideSubordinates(positionID) {
    var data = new Object();
    data.hideSubordinates = 1;
    $.ajax({
    	type: 'POST',
        url: './api/position/' + positionID,
        data: {15: JSON.stringify({<!--{$rootID}-->: data}),
        	CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(res, args) {
            window.location.reload();
        },
        cache: false
    });
}

function removePosition(positionID) {
    confirm_dialog.setContent('<img src="<!--{$libsPath}-->dynicons/?img=help-browser.svg&amp;w=48" alt="question icon" style="float: left; padding-right: 16px" /> <span style="font-size: 150%">Are you sure you want to delete this position?</span>');
    confirm_dialog.setTitle('Confirmation');
    confirm_dialog.setSaveHandler(function() {
        $.ajax({
        	type: 'DELETE',
            url: './api/position/' + positionID + '?' +
                $.param({CSRFToken: '<!--{$CSRFToken}-->'}),
            success: function(response) {
                if(response == 1) {
                    alert('Position has been deleted.');
                    window.location.reload();
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

function saveZoomLevel(zoomLevel) {
    var data = new Object();
    data.zoom = zoomLevel;
    $.ajax({
    	type: 'POST',
        url: './api/position/' + <!--{$rootID}-->,
        data: {15: JSON.stringify({<!--{$rootID}-->: data}),
        	CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(res, args) {
            //window.location.reload();
        },
        cache: false
    });
}

var loadTimer = 0;
var loadInterval;
function loader() {
	if(loadTimer > 299) {
		$('#pageloadIndicator').css('visibility', 'hidden');
		$('#pageloadIndicator').css('display', 'none');
		clearInterval(loadInterval);
	    $('#footer').css('position', 'absolute');
	    $('#footer').css('top', document.documentElement.scrollHeight + 'px');
	    $('#footer').css('right', '4px');
	    jsPlumb.setSuspendDrawing(false, true);
	}
	loadTimer += 100;
}

//jsPlumb
var connectorOptions = ["Flowchart", {stub: 2, cornerRadius: 10, midpoint: 0.7}];
var endPoints = new Object();
var endpointOptions = {
    isSource: true,
    isTarget: true,
    endpoint: ["Rectangle", {width: 2, height: 2, stub: 50}],
    maxConnections: -1
};

var draggableOptions = {
    handle: '.positionSmall_title',
    snap: true,
    snapMode: 'outer',
    snapTolerance: 10,
    zIndex: 3000,
    start: function() {

    },
    drag: function() {

    },
    stop: function(params) {
//        jsPlumb.repaintEverything();
    }
};

var dialog;
var currentZoomLevel = 0;
$(function() {
    jsPlumb.Defaults.Container = "bodyarea";
    jsPlumb.DefaultDragOptions = { cursor: "pointer", zIndex:2000 };

    loadInterval = setInterval('loader()', 100);

    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    jsPlumb.setSuspendDrawing(true);
    positions[<!--{$rootID}-->] = new position(<!--{$rootID}-->);
    positions[<!--{$rootID}-->].initialize('bodyarea');
    positions[<!--{$rootID}-->].setRootID(<!--{$rootID}-->);
    positions[<!--{$rootID}-->].addControl('<div class="button" onclick="addSupervisor(\'<!--{$rootID}-->\');"><img src="<!--{$libsPath}-->dynicons/?img=system-users.svg&amp;w=32" alt="Change Supervisor" title="Change Supervisor" /> Add Supervisor</div>');

    draggableOptions.stop = function() {
        saveLayout(<!--{$rootID}-->);
    };
    jsPlumb.draggable(positions[<!--{$rootID}-->].getDomID(), draggableOptions);

    positions[<!--{$rootID}-->].onLoad = function() {
    	endPoints[<!--{$rootID}-->] = jsPlumb.addEndpoint(positions[<!--{$rootID}-->].getDomID(), {anchor: 'Center'}, endpointOptions);
    	if(positions[<!--{$rootID}-->].data[15].data != '') {
            var positionData = $.parseJSON(positions[<!--{$rootID}-->].data[15].data);
            if(positionData[<!--{$rootID}-->] != undefined
                && positionData[<!--{$rootID}-->].zoom != undefined) {
                currentZoomLevel = positionData[<!--{$rootID}-->].zoom;
            }
        }

    	getSubordinates(<!--{$rootID}-->, 0);
    }

    positions[<!--{$rootID}-->].draw();

    $('#header').css('background-image', "url('images/gradient_admin.png')");
    $('#editor_toolbar').appendTo('#headerTab');
    $('#xhrDialog').on('keydown', function(e) {
        if(e.keyCode == 13) { // enter key
            e.preventDefault();
            $('#xhrDialog button#button_save').click();
        }
    });
});

/* ]]> */
</script>