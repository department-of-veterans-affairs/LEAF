<div class="menu2" style="width: 315px; float: left">

<a href="?a=navigator">
    <span class="menuButtonSmall" style="background-color: #ffefa5">
        <img class="menuIconSmall" src="dynicons/?img=applications-internet.svg&amp;w=76" style="position: relative" alt="" />
        <span class="menuTextSmall">Browser</span><br />
        <span class="menuDescSmall">View Organizational Charts</span>
    </span>
</a>

<!--{if $groupLeader != ''}-->
<a href="?a=navigator&amp;rootID=<!--{$groupLeader|strip_tags}-->">
    <span class="menuButtonSmall" style="background-color: #b3ceff">
        <img class="menuIconSmall" src="dynicons/?img=preferences-system-windows.svg&amp;w=76" style="position: relative" alt="" />
        <span class="menuTextSmall">Service Org. Chart</span><br />
        <span class="menuDescSmall">View your service's Org. Chart</span>
    </span>
</a>
<!--{/if}-->

<a href="./utils/exportPDL.php">
    <span class="menuButtonSmall" style="background-color: black">
        <img class="menuIconSmall" src="dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" alt=""  />
        <span class="menuTextSmall" style="color: white">Export PDL</span><br />
        <span class="menuDescSmall" style="color: white">Download the Position Description List</span>
    </span>
</a>

<a href="?a=summary">
    <span class="menuButtonSmall" style="background-color: black">
        <img class="menuIconSmall" src="dynicons/?img=x-office-presentation.svg&amp;w=76" style="position: relative" alt="" />
        <span class="menuTextSmall" style="color: white">Vacancy Summary</span><br />
        <span class="menuDescSmall" style="color: white">View vacancies by Service</span>
    </span>
</a>

</div>

<div id="main">
    <div id="searchContainer" style="float: left; border: 1px solid #e0e0e0; padding: 4px; background-color: white">
        <div style="padding: 8px; color: white; font-weight: bold; font-size: 140%; background-color: #4A6995">
            <div id="searchBorder" style="white-space: nowrap; background-color: #4A6995;">
                <img id="searchIcon" src="dynicons/?img=search.svg&w=16" style="position: absolute; margin-left: 66px; padding: 10px" alt="" />
                <img id="searchIconBusy" src="images/indicator.gif" style="display: none; position: absolute; margin-left: 66px; padding: 10px" alt="" />
                <label for="search">Search </label><input id="search" name="search" aria-label="Search" style="font-size: 140%; width: 75%; padding: 2px 2px 2px 26px; border: 1px solid black; background-repeat: no-repeat; background-position: right center" type="text" />
            </div>
        </div>
        <br />
        <div id="searchTips" style="max-width: 300px">
            <fieldset><legend style="font-size: 11px; color: #767676">Available Search Options</legend>
               <div>
                   <img title="Employees" alt="" style="float: left; padding: 8px" src="dynicons/?img=contact-new.svg&amp;w=32" />
                   <div><div style="margin:4px"><b>Employees</b></div>
                   Names</div>
               </div>
               <br />
               <div>
                   <img title="Positions" alt="" style="float: left; padding: 8px" src="dynicons/?img=system-users.svg&amp;w=32" />
                   <div><div style="margin:4px"><b>Positions</b></div>
                   Titles, PD Number</div>
               </div>
               <br />
               <div>
                   <img title="Groups" alt="" style="float: left; padding: 8px" src="dynicons/?img=preferences-desktop-theme.svg&amp;w=32" />
                   <div><div style="margin:4px"><b>Groups</b></div>
                   Services, Organizational</div>
               </div>
            </fieldset>
        </div>
        <div style="margin-bottom: 12px" id="employee">
            <div id="employeeHeader">
                <span id="employeeName">Employees</span>
            </div>
            <div id="employeeBody">
                    <div id="employeeSelector"></div>
                    <div id="employeeAllResults" style="padding: 4px; margin: 8px; display: none; text-align: center"><a href="?a=browse_employee">Show More Results</a></div>
            </div>
        </div>
        <div style="margin-bottom: 12px" id="position">
            <div id="positionHeader">
                <span id="positionTitle">Positions</span>
            </div>
            <div id="positionBody" style="width: 99%">
                    <div id="positionSelector"></div>
                    <div id="positionAllResults" style="padding: 4px; margin: 8px; display: none; text-align: center"><a href="?a=browse_position">Show More Results</a></div>
            </div>
        </div>
        <div style="margin-bottom: 12px" id="group">
            <div id="groupHeader">
                <span id="groupTitle">Services</span>
            </div>
            <div id="groupBody" style="width: 99%">
                    <div id="groupSelector"></div>
            </div>
        </div>
        <div id="group2" style="float: left; width: 99%; border: 1px solid black; background-color: #d0d0d0">
            <div id="group2Header" style="background-color: #353535; padding: 4px">
                <span id="group2Title" style="font-size: 140%; font-weight: bold; color: white">Distribution Groups</span>
            </div>
            <div id="group2Body" style="width: 99%; padding: 4px">
                    <div id="group2Selector"></div>
                    <div id="groupAllResults" style="padding: 4px; margin: 8px; display: none; text-align: center"><a href="?a=browse_group">Show More Results</a></div>
            </div>
        </div>
    </div>

    <div id="currentEmployee" style="float: right; width: 220px; background-color: #ffe3e3; border: 1px solid black;">
    <!--{if $employee[0].empUID > 0}-->
        <div id="currentEmployeeHeader" style="background-color: #f4bcbc; font-size: 110%; font-weight: bold; padding: 4px"><a href="?a=view_employee&empUID=<!--{$employee[0].empUID|strip_tags}-->"><!--{$employee[0].firstName|sanitize}--> <!--{$employee[0].lastName|sanitize}--></a></div>
        <div id="currentEmployeeBody" style="padding: 4px">Loading...</div>
    <!--{else}-->
        <div style="padding: 8px">Your account is not present in the Org. Chart database.</div>
    <!--{/if}-->
    </div>
</div>

<div id="orgchartForm"></div>
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function postProcess()
{
    if(empSel.numResults == 0) {
        $('#employee').css('display', 'none');
    }
    else {
        $('#employee').css('display', 'inline');
    }
    if(empSel.numResults >= 4) {
        $('#employeeAllResults').css('display', 'block');
    }
    else {
        $('#employeeAllResults').css('display', 'none');
    }

    if(posSel.numResults == 0) {
        $('#position').css('display', 'none');
    }
    else {
        $('#position').css('display', 'inline');
    }
    if(posSel.numResults >= 5) {
        $('#positionAllResults').css('display', 'block');
    }
    else {
        $('#positionAllResults').css('display', 'none');
    }

    if(grpSel.numResults == 0) {
        $('#group').css('display', 'none');
    }
    else {
        $('#group').css('display', 'inline');
    }
    if(grp2Sel.numResults == 0) {
        $('#group2').css('display', 'none');
    }
    else {
        $('#group2').css('display', 'inline');
    }
    if(grp2Sel.numResults >= 5) {
        $('#groupAllResults').css('display', 'block');
    }
    else {
        $('#groupAllResults').css('display', 'none');
    }

    if(timer > 400) {
    	$('#searchIcon').css('display', "inline");
        $('#searchIconBusy').css('display', "none");
    }
    timer += (this.timer > 5000) ? 0 : 300;
}

function setSearchWidth() {
	$('#searchContainer').css('width', $(window).width() - sideOffset + 'px');
}

var empSel, posSel, grpSel, grp2Sel;
var ppInterval;
var sideOffset = 580;
var timer = 0;
$(function() {
    empSel = new employeeSelector('employeeSelector');
    empSel.initialize();
    empSel.hideInput();
    empSel.setSelectHandler(function() {
        window.location = '?a=view_employee&empUID=' + empSel.selection;
    });
    empSel.setSelectLink('?a=view_employee');
    empSel.emailHref = true;

    posSel = new positionSelector('positionSelector');
    posSel.initialize();
    posSel.hideInput();
    posSel.setSelectHandler(function() {
         window.location = '?a=view_position&positionID=' + posSel.selection;
    });
    posSel.setSelectLink('?a=view_position');

    grpSel = new groupSelector('groupSelector');
    grpSel.configInputID('#search');
    grpSel.initialize();
    grpSel.searchTag('service');
    grpSel.hideInput();
    grpSel.setSelectHandler(function() {
        window.location = '?a=navigator_service&groupID=' + grpSel.selection;
    });
    grpSel.setSelectLink('?a=navigator_service');

    grp2Sel = new groupSelector('group2Selector');
    grp2Sel.configInputID('#search');
    grp2Sel.initialize();
    grp2Sel.hideInput();
    grp2Sel.setSelectHandler(function() {
        window.location = '?a=view_group&groupID=' + grp2Sel.selection;
    });
    grp2Sel.setSelectLink('?a=view_group');

    $('#search').on('keyup', function() {
    	$('#searchIcon').css('display', "none");
    	$('#searchIconBusy').css('display', "inline");
        timer = 0;
    	empSel.timer = 0;
        posSel.timer = 0;
        grpSel.timer = 0;
        grp2Sel.timer = 0;
        empSel.forceSearch($('#search').val());
        posSel.forceSearch($('#search').val());
        grpSel.forceSearch($('#search').val());
        grp2Sel.forceSearch($('#search').val());
        sideOffset = 350;
        setSearchWidth();
        if($('#search').val() != '') {
        	$('#searchTips').css('display', 'none');
        }
        else {
        	$('#searchTips').css('display', 'inline');
        }
        $('#currentEmployee').css('display', 'none');
    });

    setSearchWidth();
    window.onresize = function() {
    	setSearchWidth();
    };
    ppInterval = setInterval(function(){postProcess();}, 100);

    <!--{if $employee[0].empUID > 0 && is_numeric($employee[0].empUID)}-->
    $.ajax({
        url: "ajaxEmployee.php?a=getForm&empUID=<!--{$employee[0].empUID}-->",
        success: function(response) {
            if(response != '') {
                $('#currentEmployeeBody').html(response);
                $('#currentEmployeeBody img').css('max-width', '64px');
                $('#data_28_1_1').css('word-break', 'break-all');
                <!--{if $employeePositions[0].positionID > 0}-->
                $.ajax({
                    url: './api/position/<!--{$employeePositions[0].positionID}-->',
                    dataType: 'json',
                    success: function(positionData) {
                        title = '';
                        if(positionData.title != '') {
                            title = '<br /><span>' + positionData.title + '</span>';
                        }
                        $('#currentEmployeeHeader').append(title);
                    }
                });
                <!--{/if}-->
            }
            else {
                $('#currentEmployeeBody').html('');
            }
        },
        cache: false
    });
    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();
    <!--{include file="site_elements/orgchartForm_updateOutlook.js.tpl"}-->
    <!--{/if}-->
});

/* ]]> */
</script>
