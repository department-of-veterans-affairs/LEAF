The following is a list of requests that are pending your action:
<!--{if count($inbox) == 0}-->
<br /><br />
<div style="width: 50%; margin: 0px auto; border: 1px solid black; padding: 16px; background-color: white">
<img src="../libs/dynicons/?img=folder-open.svg&amp;w=96" alt="empty" style="float: left; padding-right: 16px"/><div style="font-size: 200%"> Your inbox is empty.<br /><br />Have a good day!</div>
</div>
<!--{/if}-->

<div id="inbox">
<!--{foreach from=$inbox item=dep}-->
<br /><br />
<table id="depTitle_<!--{$dep.dependencyID}-->" class="agenda" style="width: 100%; margin: 0px auto">
    <tr style="background-color: <!--{$dep.dependencyBgColor}-->; cursor: pointer" onclick="toggleDepVisibility('<!--{$dep.dependencyID}-->')">
      <td colspan="3">
      <span style="float: left; font-size: 120%; font-weight: bold">
          <!--{if $dep.dependencyID != -1}-->
              <!--{$dep.dependencyDesc}-->
          <!--{else}-->
              Action required from: <!--{$dep.approverName}-->
          <!--{/if}-->
      </span>
      <span style="float: right; text-decoration: underline; font-weight: bold"><span id="depTitleAction_<!--{$dep.dependencyID}-->">View</span> <!--{$dep.count}--> requests</span>
      </td>
    </tr>
</table>
<div id="depContainer_<!--{$dep.dependencyID}-->" style="background-color: <!--{$dep.dependencyBgColor}-->">
    <div style="border: 1px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px">Loading...</div>
</div>
<!--{/foreach}-->
</div>

<!-- DIALOG BOXES -->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script type="text/javascript" src="js/functions/toggleZoom.js"></script>
<script type="text/javascript">
/* <![CDATA[ */

var depVisibility = [];
function toggleDepVisibility(depID, isDefault) {
    if(depVisibility[depID] == undefined
    	|| depVisibility[depID] == 1) {
    	depVisibility[depID] = 0;
    	$('#depContainer_' + depID).css({
    		'visibility': 'hidden',
    		'display': 'none'
    	});
    	$('#depTitle_' + depID).css({
            'width': '50%'
        });
    }
    else {
    	depVisibility[depID] = 1;
        loadInboxData(depID);
        $('#depTitle_' + depID).css({
            'width': '100%'
        });
        $('#depContainer_' + depID).css({
            'visibility': 'visible',
            'display': 'inline'
        });
    }
}

function stripHtml(input) {
    var temp = document.createElement('div');
    temp.innerHTML = input;
    return temp.innerText || temp.textContent;
}

var CSRFToken = '<!--{$CSRFToken}-->';
var inboxDataLoaded = new Object();
function loadInboxData(depID) {
	var formGrid = new LeafFormGrid('depContainer_' + depID);

    $.ajax({
        type: 'GET',
        url: 'api/?a=inbox/dependency/_' + depID,
        success: function(res) {
            inboxDataLoaded[depID] = 1;

            var recordIDs = '';
            for (var i in res[depID]['records']) {
                recordIDs += res[depID]['records'][i].recordID + ',';
            }

            formGrid.setDataBlob(res);
            formGrid.setHeaders([
                 {name: 'Type', indicatorID: 'type', editable: false, callback: function(data, blob) {
                	 var categoryNames = '';
                	 if(blob[depID]['records'][data.recordID].categoryNames != undefined) {
                		 categoryNames = blob[depID]['records'][data.recordID].categoryNames.replace(' | ', ', ');
                	 }
                	 else {
                		 categoryNames = '<span style="color: red">Warning: This request is based on an old or deleted form.</span>';
                	 }
                	 $('#'+data.cellContainerID).html(categoryNames);
                 }},
                 {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
                	 $('#'+data.cellContainerID).html(blob[depID]['records'][data.recordID].service);
                 }},
                 {name: 'Title', indicatorID: 'title', editable: false, callback: function(data, blob) {
                     $('#'+data.cellContainerID).html(blob[depID]['records'][data.recordID].title + ' <button id="'+ data.cellContainerID +'_preview" class="buttonNorm">View Request</button><div id="inboxForm_' + depID + '_' + data.recordID +'" style="background-color: white; display: none; height: 300px; overflow: scroll"></div>');
                     $('#'+data.cellContainerID + '_preview').on('click', function() {
                    	 $('#'+data.cellContainerID + '_preview').hide();
                    	 if($('#inboxForm_'+depID+'_'+data.recordID).html() == '') {
                    		 $('#inboxForm_'+depID+'_'+data.recordID).html('Loading...');
                    		 $('#inboxForm_'+depID+'_'+data.recordID).slideDown();
                             $.ajax({
                                 type: 'GET',
                                 url: 'ajaxIndex.php?a=printview&recordID=' + data.recordID,
                                 success: function(res) {
                                     $('#inboxForm_'+depID+'_'+data.recordID).html(res);
                                     $('#inboxForm_'+depID+'_'+data.recordID).slideDown();
                                 }
                             });
                    	 }
                     });
                 }},
                 {name: 'Action', indicatorID: 'action', editable: false, sortable: false, callback: function(data, blob) {
                	 var depDescription = 'Take Action';
                	 $('#'+data.cellContainerID).html('<div class="buttonNorm" style="text-align: center; font-weight: bold; white-space: normal" onclick="loadWorkflow('+ data.recordID +', \''+ depID +'\', \''+ formGrid.getPrefixID() +'\');">'+ depDescription +'</div>');
                 }}
             ]);
            formGrid.loadData(recordIDs);
            $('#' + formGrid.getPrefixID() + 'header_title').css('width', '60%');
        },
        cache: false
    });
}

// empty handles
function getForm(indicatorID, series) {}

function loadWorkflow(recordID, dependencyID, prefixID) {
	dialog_message.setTitle('Apply Action to #' + recordID);

    currRecordID = recordID;
    dialog_message.setContent('<div id="workflowcontent"></div><div id="currItem"></div>');
    workflow = new LeafWorkflow('workflowcontent', '<!--{$CSRFToken}-->');
    workflow.setActionSuccessCallback(function() {
        dialog_message.hide();
    	$('#' + prefixID + 'tbody_tr' + recordID).fadeOut(1500);
    });
    workflow.getWorkflow(recordID);
    dialog_message.show();
}

var currRecordID = null;

var intvalStatus = null;
var lastActTime = null;

var dialog_message;
$(function() {
	dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    <!--{foreach from=$inbox item=dep}-->
    toggleDepVisibility('<!--{$dep.dependencyID}-->', 1);
    <!--{/foreach}-->

});


/* ]]> */
</script>
