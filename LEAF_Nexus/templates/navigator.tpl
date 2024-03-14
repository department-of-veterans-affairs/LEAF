<!-- <div id="sidebar">
placeholder<br />
</div> -->

<span id="editor_toolbar" class="noprint">
    <span id="editor_tools">
        <button type="button" class="buttonNorm" onclick="window.location='?a=editor&amp;rootID=<!--{$rootID}-->';"><img src="dynicons/?img=accessories-text-editor.svg&amp;w=24" style="vertical-align: middle" alt="" title="Edit Orgchart" /> Edit Orgchart</button>
        <!--{if $rootID != $topPositionID}-->
        <button type="button" class="buttonNorm" onclick="viewSupervisor();"><img src="dynicons/?img=go-up.svg&amp;w=24" style="vertical-align: middle" alt="" title="Zoom Out" /> Go Up One Level</button>
        <!--{/if}-->
        <button type="button" class="buttonNorm"  onclick="window.location='mailto:?subject=FW:%20Org.%20Chart%20-%20&amp;body=Organizational%20Chart%20URL:%20<!--{if $smarty.server.HTTPS == on}-->https<!--{else}-->http<!--{/if}-->://<!--{$smarty.server.SERVER_NAME}--><!--{$smarty.server.REQUEST_URI|escape:'url'}-->%0A%0A'"><img src="dynicons/?img=mail-forward.svg&amp;w=24" style="vertical-align: middle" alt="" title="Forward as Email" /> Forward as Email</button>
    </span>
</span>

<div id="pageloadIndicator" style="visibility: visible">
    <div style="opacity: 0.8; z-index: 1000; position: absolute; background: #f3f3f3; height: 97%; width: 97%"></div>
    <div style="z-index: 1001; position: absolute; padding: 16px; width: 97%; text-align: center; font-size: 24px; font-weight: bold; background-color: white">Loading... <img src="images/largespinner.gif" alt="" /></div>
</div>

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
    }
}

function viewSupervisor() {
    $.ajax({
        url: './api/position/<!--{$rootID}-->/supervisor',
        dataType: 'json',
        success: function(response) {
            window.location = '?a=navigator&rootID=' + response[0].positionID;
        }
    });
}

function addSubgroup() {

}

function setPositionStyle(containerID, positionID) {
	//dojo.style(containerID + '_title', 'cursor', 'pointer');
	$('#' + containerID + '_title').css('cursor', 'pointer');
    $('#' + containerID + '_title').click(function() {
    	window.location = '?a=navigator&rootID=' + positionID;
    });
}

var levelLimit = 5;
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

            if(subordinate[key][15].data != '') {
                var subData = $.parseJSON(subordinate[key][15].data);
                if(subData[<!--{$rootID}-->] != undefined
                    && subData[<!--{$rootID}-->].hideSubordinates != undefined
                    && subData[<!--{$rootID}-->].hideSubordinates == 1) {

                    //positionControls = '<div class="button" onclick="showSubordinates('+subordinate[key].positionID+');"><img src="dynicons/?img=system-users.svg&amp;w=32" alt="" title="Show" /> Show Subordinates</div>';
                    loadSubordinates = 0;
                }
            }

            if(subordinate[key].hasSubordinates == 1
                && loadSubordinates == 1) {

                $.ajax({
                    url: './api/position/' + subordinate[key].positionID,
                    data: {q: this.q},
                    dataType: 'json',
                    success: function(data) {
                    	positions[subordinate[key].positionID].data = data;
                        getSubordinates(subordinate[key].positionID, level);
                    },
                    cache: false
                });
            }

            //jsPlumb.draggable(positions[subordinate[key].positionID].getDomID(), draggableOptions);
            $('#' + positions[subordinate[key].positionID].getDomID()).on('dragstop', null, subordinate[key].positionID, function(event) {
                saveLayout(event.data);
            });

            endPoints[subordinate[key].positionID] = jsPlumb.addEndpoint(positions[subordinate[key].positionID].getDomID(), {anchor: 'Center'}, endpointOptions);

            jsPlumb.connect({ source: endPoints[subordinate[key].parentID],
                target: endPoints[subordinate[key].positionID],
                connector: connectorOptions,
                paintStyle: {stroke: "black", lineWidth: 2}
            });

            positions[subordinate[key].positionID].emptyControls();

            positions[subordinate[key].positionID].addControl('<a class="button buttonNorm" href="?a=view_position&amp;positionID='+this.positionID+'"><img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="" /> View Details</a>');
            positions[subordinate[key].positionID].addControl('<a class="button buttonNorm" href="?a=navigator&amp;rootID='+this.positionID+'"><img src="dynicons/?img=system-search.svg&amp;w=32" alt="" /> Focus on This</a>');

            setPositionStyle(positions[subordinate[key].positionID].prefixID + positions[subordinate[key].positionID].positionID, positions[subordinate[key].positionID].positionID);

            applyZoomLevel();
        };

        positions[subordinate[key].positionID].draw(subordinate[key]);
    }
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
    endpoint: ["Rectangle", {width: 2, height: 2, stub: 0}],
    maxConnections: -1
};
var draggableOptions = {
    handle: '.positionSmall_title',
    snap: true,
    snapMode: 'outer',
    snapTolerance: 10,
    zIndex: 3000
};

var currentZoomLevel = 0;
$(function() {
    jsPlumb.Defaults.Container = "bodyarea";
    jsPlumb.DragOptions = { cursor: "pointer", zIndex:2000 };

    loadInterval = setInterval('loader()', 100);

    jsPlumb.setSuspendDrawing(true);
    positions[<!--{$rootID}-->] = new position(<!--{$rootID}-->);
    positions[<!--{$rootID}-->].initialize('bodyarea');
    positions[<!--{$rootID}-->].setRootID(<!--{$rootID}-->);
    //jsPlumb.draggable(positions[<!--{$rootID}-->].getDomID(), draggableOptions);
    $('#' + positions[<!--{$rootID}-->].getDomID()).on('dragstop', null, function() {
        saveLayout(<!--{$rootID}-->);
    });

    positions[<!--{$rootID}-->].onLoad = function() {
    	endPoints[<!--{$rootID}-->] = jsPlumb.addEndpoint(positions[<!--{$rootID}-->].getDomID(), {anchor: 'Center'}, endpointOptions);
    	getSubordinates(<!--{$rootID}-->, 0);

        if(positions[<!--{$rootID}-->].data[15].data != '') {
            var positionData = $.parseJSON(positions[<!--{$rootID}-->].data[15].data);
            if(positionData[<!--{$rootID}-->] != undefined
                && positionData[<!--{$rootID}-->].zoom != undefined) {
                currentZoomLevel = positionData[<!--{$rootID}-->].zoom;
                applyZoomLevel();
            }
        }
    }

    positions[<!--{$rootID}-->].onDrawComplete = function() {
        <!--{if $header == 'false'}-->
        $('#header').css('display', 'none');
        $('html').animate({scrollTop: 80}, 1000);
        <!--{/if}-->
    };

    positions[<!--{$rootID}-->].emptyControls();
    positions[<!--{$rootID}-->].addControl('<a class="button buttonNorm" href="?a=view_position&amp;positionID=<!--{$rootID}-->"><img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="" title="View Details" /> View Details</a>');
    positions[<!--{$rootID}-->].draw();
    setPositionStyle(positions[<!--{$rootID}-->].prefixID + <!--{$rootID}-->, <!--{$rootID}-->);

    $('#editor_toolbar').prependTo('#body');
});

/* ]]> */
</script>
