<div class="menu">

<a href="?a=mod_groups" role="button">
    <span class="menuButton" style="background-color: #bfe6ff">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-users.svg&amp;w=96" style="position: relative" alt="Modify users and groups" title="Modify users and groups" />
        <span class="menuText">User Access Groups</span><br />
        <span class="menuDesc">Modify users and groups</span>
    </span>
</a>

<a href="?a=mod_svcChief" role="button">
    <span class="menuButton" style="background-color: #aeedb5">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-users.svg&amp;w=96" style="position: relative" alt="Modify service chief listing" title="Modify service chief listing" />
        <span class="menuText">Service Chiefs</span><br />
        <span class="menuDesc">Review service chiefs and set backups</span>
    </span>
</a>

<a href="?a=workflow" role="button">
    <span class="menuButton" style="background-color: #a3acff">
        <img class="menuIcon" src="../../libs/dynicons/?img=gnome-system-run.svg&amp;w=96" style="position: relative" alt="Workflow Visualizer" title="Workflow Visualizer" />
        <span class="menuText">Workflow Editor</span><br />
        <span class="menuDesc">Edit flowcharts for workflows</span>
    </span>
</a>

<a href="?a=mod_system" role="button">
    <span class="menuButton" style="background-color: #fffde6">
        <img class="menuIcon" src="../../libs/dynicons/?img=preferences-desktop-wallpaper.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText">Site Settings</span><br />
        <span class="menuDesc">Edit site name, time zone, and other labels</span>
    </span>
</a>

<a href="?a=form" role="button">
    <span class="menuButton" style="background-color: #d0ffce">
        <img class="menuIcon" src="../../libs/dynicons/?img=document-properties.svg&amp;w=96" style="position: relative" alt="Workflow Visualizer" title="Workflow Visualizer" />
        <span class="menuText">Form Editor</span><br />
        <span class="menuDesc">Create and Modify Forms</span>
    </span>
</a>

<a href="../?a=reports" role="button">
    <span class="menuButton" style="background-color: black">
        <img class="menuIcon" src="../../libs/dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText" style="color: white">Report Builder</span><br />
        <span class="menuDesc" style="color: white">Create custom reports</span>
    </span>
</a>

<a href="?a=formLibrary" role="button">
    <span class="menuButton" style="background-color: #2e8540">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-file-manager.svg&amp;w=96" style="position: relative" alt="Workflow Visualizer" title="Workflow Visualizer" />
        <span class="menuText" style="color: white">LEAF Library</span><br />
        <span class="menuDesc" style="color: white">Use a form made by the LEAF community</span>
    </span>
</a>

<!--{if $siteType == 'national_primary'}-->
<a href="../report.php?a=LEAF_National_Distribution" role="button">
    <span class="menuButton" style="background-color: #574d68" >
        <img class="menuIcon" src="../../libs/dynicons/?img=network-wireless.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
        <span class="menuText" style="color: white">Site Distribution</span><br />
        <span class="menuDesc" style="color: white">Roll-out changes to subordinate sites</span>
    </span>
</a>
<!--{/if}-->

</div>
<hr style="clear: both; visibility: hidden; margin-bottom: 100px"/>
<div class="menu">
<hr />
<h3 role="heading" aria-level="1" tabindex="0">Advanced Options:</h3><br />
    <a href="?a=mod_templates" role="button">
        <span class="menuButton" style="background-color: #ffdddd" >
            <img class="menuIcon" src="../../libs/dynicons/?img=text-x-script.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
            <span class="menuText">Template Editor</span><br />
            <span class="menuDesc">Edit HTML Templates</span>
        </span>
    </a>

    <a href="?a=admin_sync_services" role="button">
        <span class="menuButton" style="background-color: #574d68" >
            <img class="menuIcon" src="../../libs/dynicons/?img=applications-other.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
            <span class="menuText" style="color: white">Sync Services</span><br />
            <span class="menuDesc" style="color: white">Update Service listing from Org Chart</span>
        </span>
    </a>

    <a href="?a=mod_templates_reports" role="button">
        <span class="menuButton" style="background-color: black" >
            <img class="menuIcon" src="../../libs/dynicons/?img=utilities-terminal.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
            <span class="menuText" style="color: white">LEAF Programmer</span><br />
            <span class="menuDesc" style="color: white">Advanced Reports and Custom Pages</span>
        </span>
    </a>
</div>

<br style="clear: both" />
<br />
<div id="btn_programmerMode" class="buttonNorm" tabindex="0" role="button" aria-haspopup="true" aria-expanded="false">Show Other Programmer Options</div>

<div id="programmerMode" class="menu" style="display: none">
<hr />
<h3 role="heading" aria-level="1" tabindex="0">Programmer Options:</h3><br />

<a href="../?a=search" role="button">
    <span class="menuButton" style="background-color: black">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-search.svg&amp;w=96" style="position: relative" alt="Org Chart" title="Org Chart" />
        <span class="menuText" style="color: white">Search Database</span><br />
        <span class="menuDesc" style="color: white">Perform custom queries</span>
    </span>
</a>

<a href="?a=mod_file_manager" role="button">
    <span class="menuButton" style="background-color: black">
        <img class="menuIcon" src="../../libs/dynicons/?img=system-file-manager.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
        <span class="menuText" style="color: white">File Manager</span><br />
        <span class="menuDesc" style="color: white">Upload custom image assets and documents</span>
    </span>
</a>

<a href="?a=admin_update_database" role="button">
    <span class="menuButton" style="background-color: #ffefa5">
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
  var menuButton = $('#btn_programmerMode');
  var subMenu = $('#programmerMode');
  var subMenuButton = $('#programmerMode').find('a');

	$('#btn_programmerMode').on('click', function(e) {
    $(menuButton).attr('aria-expanded', 'true');
		$('#programmerMode').toggle();
	});

    $.ajax({
        type: 'GET',
        url: '../scripts/syncSVNrevision.php',
        success: function() {},
        cache: false
    });

    $(menuButton).keypress(function(e) {
        if (e.keyCode === 13) {
            $(subMenu).css("display", "block");
            $(menuButton).attr('aria-expanded', 'true');
            $('h3').focus();
        }
    });
    $(subMenuButton[2]).focusout(function() {
            alert('is out');
            $(subMenu).css("display", "none");
            $(menuButton).attr('aria-expanded', 'false');
            $(menuButton).focus();
    });
});
/* ]]> */
</script>
