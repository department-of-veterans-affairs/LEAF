<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools"><h1>Options</h1>
        <div onclick="addEmployee()"><img src="dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="" title="Add Employee" /> Add Employee</div>
        <div onclick="addPosition()"><img src="dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="" title="Add Position" /> Add Position</div>
        <div onclick="addGroup()"><img src="dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="" title="Add Group" /> Add Group/Service</div>
        <div onclick="addEveryone()"><img src="dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="" title="Add Everyone" /> Add Everyone</div>
        <div onclick="addOwner()"><img src="dynicons/?img=list-add.svg&amp;w=32" style="vertical-align: middle" alt="" title="Add Owner" /> Add Owner</div>
    </div>
</div>

<div id="maincontent">
    <div style="background-color: #fff297; border: 1px solid black; padding: 4px">
        <div style="font-size: 150%">
            Permissions for field ID# <!--{$indicator.indicatorID|strip_tags}-->
        </div>
        <div style="background-color: #fffad7; font-size: 120%; padding: 8px">
            <table class="table" style="width: 80%">
                <tr style="background-color: black; color: white; text-align: center">
                    <td>Field Name</td>
                    <td>Field Type</td>
                </tr>
                <tr style="background-color: white; text-align: center">
                    <td>"<!--{$indicator.name|sanitize}-->"</td>
                    <td><!--{$indicator.format|sanitize}--></td>
                </tr>
            </table>
        </div>
    </div>
    <br />
    <table class="table">
        <tr style="background-color: black; color: white; text-align: center">
            <td style="width: 400px">Subject</td>
            <td style="width: 100px">Read</td>
            <td style="width: 100px">Write</td>
            <td style="width: 100px" title="This allows permissions to be granted to others">Grant</td>
        </tr>
    <!--{foreach from=$permissions item=permission}-->
    
        <!--{if $is_admin == FALSE && ($permission.UID == 2 || $permission.UID == 1)}-->
        <tr style="background-color: <!--{cycle values='#e0e0e0,#c4c4c4'}-->; opacity: 50%;">
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->" style="font-size: 14px; font-weight: bold"><img src="images/largespinner.gif" alt="" /> Loading <!--{$permission.categoryID|strip_tags}-->...</td>
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->_read" style="font-size: 14px">
                <div class="buttonNorm">
                <!--{if $permission.read == 1}-->
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes
                <!--{else}-->
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No
                <!--{/if}-->
                </div>
            </td>
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->_write" style="font-size: 14px">
                <div class="buttonNorm">
                
                <!--{if $permission.write == 1}-->
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes
                <!--{else}-->
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No
                <!--{/if}-->
                </div>
            </td>
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->_grant" style="font-size: 14px">
                <div class="buttonNorm">
                <!--{if $permission.grant == 1}-->
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes
                <!--{else}-->
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No
                <!--{/if}-->
                </div>
            </td>
        </tr>
        <!--{else}-->
        <tr style="background-color: <!--{cycle values='#e0e0e0,#c4c4c4'}-->">
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->" style="font-size: 14px; font-weight: bold"><img src="images/largespinner.gif" alt="" /> Loading <!--{$permission.categoryID|strip_tags}-->...</td>
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->_read" style="font-size: 14px" onclick="togglePermission('<!--{$permission.categoryID|strip_tags}-->', <!--{$permission.UID|strip_tags}-->, 'read')">
                <div class="buttonNorm">
                    <!--{if $permission.read == 1}-->
                    <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes
                    <!--{else}-->
                    <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No
                    <!--{/if}-->
                </div>
            </td>
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->_write" style="font-size: 14px" onclick="togglePermission('<!--{$permission.categoryID|strip_tags}-->', <!--{$permission.UID|strip_tags}-->, 'write')">
                <div class="buttonNorm">
                    <!--{if $permission.write == 1}-->
                    <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes
                    <!--{else}-->
                    <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No
                    <!--{/if}-->
                </div>
            </td>
            <td id="<!--{$permission.categoryID|strip_tags}-->_<!--{$permission.UID|strip_tags}-->_grant" style="font-size: 14px" onclick="togglePermission('<!--{$permission.categoryID|strip_tags}-->', <!--{$permission.UID|strip_tags}-->, 'grant')">
                <div class="buttonNorm">
                    <!--{if $permission.grant == 1}-->
                    <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes
                    <!--{else}-->
                    <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No
                    <!--{/if}-->
                </div>
            </td>
        </tr>
        <!--{/if}-->
    <!--{/foreach}-->
    <!--{if count($permissions) == 0}-->
        <tr><td colspan="4" style="background-color: #c10303; color: white; font-weight: bold; font-size: 14px; padding: 4px"><img src="dynicons/?img=emblem-notice.svg&amp;w=32" alt="" style="vertical-align: middle" /> Permissions have not been set.<br />The following default settings are in effect:</td></tr>
        <tr>
            <td style="font-size: 14px">Everyone</td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" style="vertical-align: middle" /> Yes
                </div>
            </td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" style="vertical-align: middle" /> No
                </div>
            </td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" style="vertical-align: middle" /> No
                </div>
            </td>
        </tr>
        <tr>
            <td style="font-size: 14px">Owner</td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" style="vertical-align: middle" /> Yes
                </div>
            </td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" style="vertical-align: middle" /> Yes
                </div>
            </td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" style="vertical-align: middle" /> No
                </div>
            </td>
        </tr>
        <tr>
            <td style="font-size: 14px">System Administrators</td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" style="vertical-align: middle" /> No
                </div>
            </td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" style="vertical-align: middle" /> No
                </div>
            </td>
            <td style="font-size: 14px">
                <div>
                <img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" style="vertical-align: middle" /> Yes
                </div>
            </td>
        </tr>
    <!--{/if}-->
    </table>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function addEmployee() {
    dialog.setContent('Employee Search: <div id="employeeSelector"></div>');
    dialog.show(); // need to show early because of ie6

    empSel = new employeeSelector('employeeSelector');
    empSel.initialize();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
            type: 'POST',
            url: './api/indicator/<!--{$indicator.indicatorID}-->/permissions/addEmployee',
            data: {empUID: empSel.selection,
            	CSRFToken: '<!--{$CSRFToken}-->'},
           	success: function(response) {
                window.location.reload();
            },
            fail: function(err) {
                alert('Error: ' + err.statusText);
            },
            cache: false
        });
    });
}

function addPosition() {
    dialog.setContent('Position Search: <div id="positionSelector"></div>');
    dialog.show(); // need to show early because of ie6

    posSel = new positionSelector('positionSelector');
    posSel.initialize();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
            type: 'POST',
            url: './api/indicator/<!--{$indicator.indicatorID}-->/permissions/addPosition',
            data: {positionID: posSel.selection,
            	CSRFToken: '<!--{$CSRFToken}-->'},
           	success: function(response) {
                window.location.reload();
            },
            fail: function(err) {
                alert('Error: ' + err.statusText);
            },
            cache: false
        });
    });
}

function addGroup() {
    dialog.setContent('Group Search: <div id="groupSelector"></div>');
    dialog.show(); // need to show early because of ie6

    grpSel = new groupSelector('groupSelector');
    grpSel.initialize();

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        $.ajax({
        	type: 'POST',
            url: './api/indicator/<!--{$indicator.indicatorID}-->/permissions/addGroup',
            data: {groupID: grpSel.selection,
            	CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
                window.location.reload();
            },
            fail: function(err) {
                alert('Error: ' + err.statusText);
            },
            cache: false
        });
    });
}

function addEveryone() {
    $.ajax({
    	type: 'POST',
        url: './api/indicator/<!--{$indicator.indicatorID}-->/permissions/addGroup',
        data: {groupID: 2,
        	CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            window.location.reload();
        },
        fail: function(err) {
            alert('Error: ' + err.statusText);
        },
        cache: false
    });
}

function addOwner() {
    $.ajax({
    	type: 'POST',
        url: './api/indicator/<!--{$indicator.indicatorID}-->/permissions/addGroup',
        data: {groupID: 3,
        	CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            window.location.reload();
        },
        fail: function(err) {
            alert('Error: ' + err.statusText);
        },
        cache: false
    });
}

function togglePermission(categoryID, UID, type)
{
    $.ajax({
    	type: 'POST',
        url: "./api/indicator/<!--{$indicator.indicatorID}-->/permission/_" + categoryID + "/" + UID + "/_" + type + "/toggle",
        data: {CSRFToken: '<!--{$CSRFToken}-->'},
        dataType: 'json',
        success: function(response) {
            if(response != null) {
                if(response == '1') {
                	$('#'+categoryID+'_'+UID+'_'+type).html('<div class="buttonNorm"><img src="dynicons/?img=gnome-emblem-default.svg&amp;w=32" alt="" /> Yes</div>');
                }
                else if(response == '0') {
                    $('#'+categoryID+'_'+UID+'_'+type).html('<div class="buttonNorm"><img src="dynicons/?img=process-stop.svg&amp;w=32" alt="" /> No</div>');
                }
            }
        },
        fail: function(err) {
            alert('Error: ' + err.statusText);
        },
        cache: false
    });
}

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->

var dialog;
$(function() {
	<!--{foreach from=$permissions item=permission}-->
    $.ajax({
        url: "./api/<!--{$permission.categoryID}-->/<!--{$permission.UID}-->",
        dataType: 'json',
        success: function(response) {
            if(response != '') {
            	switch("<!--{$permission.categoryID}-->") {
            	   case "employee":
                       $("#<!--{$permission.categoryID}-->_<!--{$permission.UID}-->").html('<img src="dynicons/?img=gnome-stock-person.svg&w=32" alt="" style="vertical-align: middle" /> <a href="?a=view_employee&empUID=<!--{$permission.UID}-->">'
                    	   + response.employee.lastName + ', ' + response.employee.firstName + '</a>');
            		   break;
            	   case "position":
                       $("#<!--{$permission.categoryID}-->_<!--{$permission.UID}-->").html('<img src="dynicons/?img=contact-new.svg&w=32" alt="" style="vertical-align: middle" /> <a href="?a=view_position&positionID=<!--{$permission.UID}-->">'
                    	   + response.title + '</a>');
                       break;
                   case "group":
                       $("#<!--{$permission.categoryID}-->_<!--{$permission.UID}-->").html('<img src="dynicons/?img=system-users.svg&w=32" alt="" style="vertical-align: middle" /> <a href="?a=view_group&groupID=<!--{$permission.UID}-->">'
                           + response.title + '</a>');
                       break;
            	}
            }
        },
        fail: function(err) {
            alert('Error: ' + err.statusText);
        },
        cache: false
    });
    <!--{/foreach}-->

    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
});

/* ]]> */
</script>
