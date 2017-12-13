<div class="menu">

<a href="?a=mod_groups">
    <span class="menuButton" style="background-color: #bfe6ff" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-users.svg&amp;w=96" style="position: relative" alt="Modify users and groups" title="Modify users and groups" />
        <span class="menuText">User Access Groups</span><br />
        <span class="menuDesc">Modify users and groups</span>
    </span>
</a>

<a href="?a=mod_svcChief">
    <span class="menuButton" style="background-color: #aeedb5"tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-users.svg&amp;w=96" style="position: relative" alt="Modify service chief listing" title="Modify service chief listing" />
        <span class="menuText">Service Chiefs</span><br />
        <span class="menuDesc">Review service chiefs</span>
    </span>
</a>

<a href="?a=workflow">
    <span class="menuButton" style="background-color: #a3acff" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=gnome-system-run.svg&amp;w=96" style="position: relative" alt="Workflow Visualizer" title="Workflow Visualizer" />
        <span class="menuText">Workflow Editor</span><br />
        <span class="menuDesc">Edit flowcharts for workflows</span>
    </span>
</a>

<a href="?a=mod_system">
    <span class="menuButton" style="background-color: #fffde6" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=preferences-desktop-wallpaper.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText">Site Settings</span><br />
        <span class="menuDesc">Edit site name and other labels</span>
    </span>
</a>

<a href="?a=form">
    <span class="menuButton" style="background-color: #d0ffce" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=document-properties.svg&amp;w=96" style="position: relative" alt="Workflow Visualizer" title="Workflow Visualizer" />
        <span class="menuText">Form Editor</span><br />
        <span class="menuDesc">Create and Modify Forms</span>
    </span>
</a>

<a href="../?a=reports">
    <span class="menuButton" style="background-color: black" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText" style="color: white">Report Builder</span><br />
        <span class="menuDesc" style="color: white">Create custom reports</span>
    </span>
</a>

<a href="?a=mod_templates">
    <span class="menuButton" style="background-color: #ffdddd" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=text-x-script.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText">Template Editor</span><br />
        <span class="menuDesc">Edit HTML Templates</span>
    </span>
</a>

<a href="?a=admin_sync_services">
    <span class="menuButton" style="background-color: #574d68" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=applications-other.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
        <span class="menuText" style="color: white">Sync Services</span><br />
        <span class="menuDesc" style="color: white">Update Service listing from Org Chart</span>
    </span>
</a>

<a href="?a=mod_templates_reports">
    <span class="menuButton" style="background-color: black" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=utilities-terminal.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText" style="color: white">LEAF Programmer</span><br />
        <span class="menuDesc" style="color: white">Advanced Reports and Custom Pages</span>
    </span>
</a>

</div>

<br style="clear: both" />
<br />
<div id="btn_programmerMode" class="buttonNorm" tabindex="0">Show Other Programmer Options</div>

<div id="programmerMode" style="display: none">
<hr />
Programmer Options:<br />

<a href="../?a=search">
    <span class="menuButton" style="background-color: black" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-search.svg&amp;w=96" style="position: relative" alt="Org Chart" title="Org Chart" />
        <span class="menuText" style="color: white">Search Database</span><br />
        <span class="menuDesc" style="color: white">Perform custom queries</span>
    </span>
</a>

<a href="?a=mod_file_manager">
    <span class="menuButton" style="background-color: black" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-file-manager.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText" style="color: white">File Manager</span><br />
        <span class="menuDesc" style="color: white">Upload custom image assets and documents</span>
    </span>
</a>

<a href="?a=admin_update_database">
    <span class="menuButton" style="background-color: #ffefa5" tabindex="0">
        <img class="menuIcon" src="../../libs/dynicons/?img=application-x-executable.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
        <span class="menuText">Update Database</span><br />
        <span class="menuDesc">Updates the system database, if available</span>
    </span>
</a>

</div>

<br /><br />

<script type="text/javascript">
/* <![CDATA[ */

$(function() {

	$('#btn_programmerMode').on('click', function() {
		$('#btn_programmerMode').css('display', 'none');
		$('#programmerMode').css('display', 'block');
	});

    $.ajax({
        type: 'GET',
        url: '../scripts/syncSVNrevision.php',
        success: function() {},
        cache: false
    });
});

/* ]]> */
</script>
