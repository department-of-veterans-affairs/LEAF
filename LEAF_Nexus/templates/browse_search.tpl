<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools"><h1>Options</h1>
        <div onclick="window.location='?a=browse_group';"><img src="dynicons/?img=preferences-desktop-theme.svg&amp;w=32" style="vertical-align: middle" alt="" title="Search Groups" /> View Groups</div>
        <div onclick="window.location='?a=browse_position';"><img src="dynicons/?img=system-users.svg&amp;w=32" style="vertical-align: middle" alt="" title="Search Position" /> View Positions</div>
        <div onclick="window.location='?a=browse_employee';"><img src="dynicons/?img=contact-new.svg&amp;w=32" style="vertical-align: middle" alt="" title="Search Employees" /> View Employees</div>
    </div>
</div>

<div id="maincontent">
<div id="searchContainer">
    <div style="padding: 8px; color: white; font-weight: bold; font-size: 140%; background-color: #4A6995">
        <label for="search">Search: </label><input id="search" style="width: 80%; font-size: 140%; padding: 2px; border: 1px solid black" type="text" />
    </div>
    <br />
    <div style="margin-bottom: 8px" id="employee">
        <div id="employeeHeader">
            <span id="employeeName">Employees</span>
        </div>
        <div id="employeeBody">
                <div id="employeeSelector"></div>
        </div>
    </div>
    <div style="margin-bottom: 8px" id="position">
        <div id="positionHeader">
            <span id="positionTitle">Positions</span>
        </div>
        <div id="positionBody" style="width: 99%">
                <div id="positionSelector"></div>
        </div>
    </div>
    <div id="group">
        <div id="groupHeader">
            <span id="groupTitle">Groups</span>
        </div>
        <div id="groupBody" style="width: 99%">
                <div id="groupSelector"></div>
        </div>
    </div>
    <br /><br /><br />
</div>
</div>

<div id="orgchartForm"></div>

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
	if(posSel.numResults == 0) {
        $('#position').css('display', 'none');
    }
    else {
        $('#position').css('display', 'inline');
    }
	if(grpSel.numResults == 0) {
        $('#group').css('display', 'none');
    }
    else {
        $('#group').css('display', 'inline');
    }
}

<!--{include file="site_elements/genericJS_toolbarAlignment.tpl"}-->

var empSel, posSel, grpSel;
var ppInterval;
$(function() {
	empSel = new employeeSelector('employeeSelector');
	empSel.initialize();
	empSel.hideInput();
    empSel.setSelectHandler(function() {
        window.location = '?a=view_employee&empUID=' + empSel.selection;
    });

	posSel = new positionSelector('positionSelector');
	posSel.initialize();
	posSel.hideInput();
    posSel.setSelectHandler(function() {
         window.location = '?a=view_position&positionID=' + posSel.selection;
    });

	grpSel = new groupSelector('groupSelector');
	grpSel.initialize();
	grpSel.hideInput();
	grpSel.setSelectHandler(function() {
        window.location = '?a=view_group&groupID=' + grpSel.selection;
    });

    $('#search').focus();
    $('#search').on('keyup', function() {
        empSel.forceSearch($('#search').val());
        posSel.forceSearch($('#search').val());
        grpSel.forceSearch($('#search').val());
    });

    ppInterval = setInterval(function(){postProcess();}, 300);

    orgchartForm = new orgchartForm('orgchartForm');
    orgchartForm.initialize();
});

/* ]]> */
</script>
