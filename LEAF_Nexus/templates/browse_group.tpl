<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools"><h1>Tools</h1>
        <button class="tools" onclick="newGroup()"><img src="dynicons/?img=folder-new.svg&amp;w=32" style="vertical-align: middle" alt="" title="New Group" /> Create New Group</button>
    </div>
</div>

<div id="maincontent">
    <div id="group">
        <div id="groupHeader">
            <span id="groupTitle">Group Search:</span>
        </div>
        <div id="groupBody" style="width: 99%">
                <div id="groupSelector"></div>
        </div>
    </div>
</div>

<div id="orgchartForm"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function newGroup()
{
    dialog.setContent('Group Name: <input id="groupName" style="width: 300px" class="dialogInput"></input>');
    dialog.setTitle('Create New Group');
    dialog.show(); // need to show early because of ie6

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
        	type: 'POST',
            url: './api/group',
            data: {title: $('#groupName').val(),
            	CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
            	if(!$.isNumeric(response)) {
            		alert(response);
            	}
            	window.location.href = './?a=view_group&groupID=' + response;
                dialog.hide();
            },
            cache: false
        });
    });
}

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->

var grpSel;
var intval;
var dialog;
$(function() {
	grpSel = new groupSelector('groupSelector');
	grpSel.initialize();
	grpSel.enableNoLimit();

	grpSel.setSelectHandler(function() {
    	window.location = '?a=view_group&groupID=' + grpSel.selection;
    });
	grpSel.setSelectLink('?a=view_group');

    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');

    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();
});

/* ]]> */
</script>
