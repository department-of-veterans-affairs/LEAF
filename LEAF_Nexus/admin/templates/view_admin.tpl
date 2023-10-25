<div id="maincontent">

<a href="../?a=browse_group" tabindex="-1">
    <span class="menuButton" style="background-color: #cb9ed7" tabindex="0">
        <img class="menuIcon" src="../dynicons/?img=preferences-desktop-theme.svg&amp;w=96" style="position: relative" alt="Group Search" title="Group Search" />
        <span class="menuText">Groups</span><br />
        <span class="menuDesc">View groups such as services, sub-sections, etc.</span>
    </span>
</a>

<a href="?a=admin_refresh_directory" tabindex="-1">
    <span class="menuButton" style="background-color: #ffefa5" tabindex="0">
        <img class="menuIcon" src="../dynicons/?img=system-software-update.svg&amp;w=96" style="position: relative" alt="Directory Update" title="Directory Update" />
        <span class="menuText">Refresh Directory</span><br />
        <span class="menuDesc">Update account list from Active Directory</span>
    </span>
</a>

<a href="?a=setup_medical_center" tabindex="-1">
    <span class="menuButton" style="background-color: #c6ffbe" tabindex="0">
        <img class="menuIcon" src="../dynicons/?img=preferences-system.svg&amp;w=96" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText">Setup Wizard</span><br />
        <span class="menuDesc">Initial setup for VA Medical Centers</span>
    </span>
</a>

<a href="?a=mod_templates_reports" tabindex="-1">
    <span class="menuButton" style="background-color: black" tabindex="0">
        <img class="menuIcon" src="../dynicons/?img=utilities-terminal.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText" style="color: white">Report Programmer</span><br />
        <span class="menuDesc" style="color: white">Advanced Reports and Custom Pages</span>
    </span>
</a>

</div>

<!-- Other tools -->
<br style="clear: both" />
<br />

<div id="btn_programmerMode" class="buttonNorm" tabindex="0">Other Tools</div>

<div id="programmerMode" style="display: none">
<hr />
Programmer Options:<br />

<a href="../?a=browse_search" tabindex="-1">
    <span class="menuButtonSmall" style="background-color: #414141" tabindex="0">
        <img class="menuIconSmall" src="../dynicons/?img=system-search.svg&amp;w=72" style="position: relative" alt="Search" title="Search" />
        <span class="menuTextSmall" style="color: white">Search</span><br />
        <span class="menuDescSmall" style="color: white">All-in-one search</span>
    </span>
</a>

<a href="#" onclick="newEmployee()" tabindex="-1">
    <span class="menuButtonSmall" style="background-color: #414141" tabindex="0">
        <img class="menuIconSmall" src="../dynicons/?img=list-add.svg&amp;w=72" style="position: relative" alt="Search" title="Search" />
        <span class="menuTextSmall" style="color: white">Import Employee</span><br />
        <span class="menuDescSmall" style="color: white">Old tool to import employees into the database</span>
    </span>
</a>

<a href="?a=import_employees_from_spreadsheet" tabindex="-1">
    <span class="menuButtonSmall" style="background-color: black" tabindex="0">
        <img class="menuIconSmall" src="../dynicons/?img=list-add.svg&amp;w=72" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuTextSmall" style="color: white">Spreadsheet Import</span><br />
        <span class="menuDescSmall" style="color: white">Batch add employees from spreadsheet</span>
    </span>
</a>

<a href="?a=mod_system" tabindex="-1">
    <span class="menuButtonSmall" style="background-color: black" tabindex="0">
        <img class="menuIconSmall" src="../dynicons/?img=preferences-desktop.svg&amp;w=72" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuTextSmall" style="color: white">Change Site Name</span><br />
        <span class="menuDescSmall" style="color: white">Edit site name and other parameters</span>
    </span>
</a>



<a href="?a=admin_update_database" tabindex="-1">
    <span class="menuButton" style="background-color: #ffefa5" tabindex="0">
        <img class="menuIcon" src="../dynicons/?img=application-x-executable.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
        <span class="menuText">Update Database</span><br />
        <span class="menuDesc">Updates the system database, if available</span>
    </span>
</a>


</div>


<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
/* <![CDATA[ */

function newEmployee() {
    dialog.setContent('<fieldset><legend>Employee:</legend><div id="empSelector_container"></div><br />Hint: If there are too many results, use their E-mail address as a search term.</fieldset>');
    dialog.show(); // need to show early because of ie6

    var empSel = new nationalEmployeeSelector('empSelector_container');
    empSel.rootPath = '../';
    empSel.apiPath = '<!--{$leaf_domain}-->api/';
    empSel.initialize();
//    empSel.setDomain('<!--{$userDomain}-->');

    dialog.setSaveHandler(function() {
        dialog.indicateBusy();
        if(empSel.selection == '') {
        	dialog.indicateIdle();
        	alert('You need to select an employee to add.');
        	return false;
        }
        $.ajax({
        	type: 'POST',
            url: '../api/employee/import/_' + empSel.selectionData[empSel.selection].userName,
            dataType: 'json',
            data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response) {
            	if(parseFloat(response) > 0) {
            	    window.location = '../?a=view_employee&empUID=' + response;
            	}
            	else {
            		alert(response);
            		dialog.hide();
            	}
            },
            cache: false
        });
    });
}

<!--{include file="../../templates/site_elements/genericJS_toolbarAlignment.tpl"}-->

var dialog;
$(function() {

    $('#btn_programmerMode').on('click', function() {
        $('#btn_programmerMode').css('display', 'none');
        $('#programmerMode').css('display', 'block');
    });

    $('#btn_programmerMode').keypress(function(e) {
        if (e.keyCode === 13) {
            $('#btn_programmerMode').css('display', 'none');
            $('#programmerMode').css('display', 'block');
        }
    });

    $.ajax({
        url: '../scripts/syncSVNrevision.php',
        dataType: 'text',
        success: function(response) {
        },
        cache: false
    });

    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    confirm_dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
});

/* ]]> */
</script>