<div class="leaf-center-content">

    <a href="?a=mod_groups" role="button" class="leaf-admin-button bg-mint-10">
        <i class="leaf-admin-btnicon fas fa-users text-mint-50" alt="Modify users and groups" title="Modify users and groups"></i>
        <span class="leaf-admin-btntitle">User Access Groups</span>
        <span class="leaf-admin-btndesc">Modify users and groups</span>
    </a>

    <a href="?a=mod_svcChief" role="button" class="leaf-admin-button bg-red-10">
        <i class="leaf-admin-btnicon fas fa-user-friends text-red-50" alt="Modify service chief listing" title="Modify service chief listing"></i>
        <span class="leaf-admin-btntitle">Service Chiefs</span>
        <span class="leaf-admin-btndesc">Review service chiefs and set backups</span>
    </a>

    <!--{if $siteType != 'national_subordinate'}-->
    <a href="?a=workflow" role="button" class="leaf-admin-button bg-yellow-10">
        <i class="leaf-admin-btnicon fas fa-cogs text-yellow-50" alt="Workflow Visualizer" title="Workflow Visualizer"></i>
        <span class="leaf-admin-btntitle">Workflow Editor</span>
        <span class="leaf-admin-btndesc">Edit flowcharts for workflows</span>
    </a>
    <!--{/if}-->

    <a href="?a=mod_system" role="button" class="leaf-admin-button bg-cyan-10">
        <i class="leaf-admin-btnicon fas fa-keyboard text-cyan-50" alt="Bookmarks" title="Bookmarks"></i>
        <span class="leaf-admin-btntitle">Site Settings</span>
        <span class="leaf-admin-btndesc">Edit site name, time zone, and other labels</span>
    </a>

    <!--{if $siteType != 'national_subordinate'}-->
    <a href="?a=form" role="button" class="leaf-admin-button bg-green-10">
        <i class="leaf-admin-btnicon fas fa-file-alt text-green-50" alt="Form Editor" title="Form Editor"></i>
        <span class="leaf-admin-btntitle">Form Editor</span>
        <span class="leaf-admin-btndesc">Create and Modify Forms</span>
    </a>
    <!--{/if}-->

    <a href="../?a=reports" role="button" class="leaf-admin-button bg-gold-10">
        <i class="leaf-admin-btnicon fas fa-file-invoice text-gold-50" alt="Report Builder" title="Report Builder"></i>
        <span class="leaf-admin-btntitle">Report Builder</span>
        <span class="leaf-admin-btndesc">Create custom reports</span>
    </a>

    <!--{if $siteType != 'national_subordinate'}-->
    <a href="?a=formLibrary" role="button" class="leaf-admin-button bg-orange-10">
        <i class="leaf-admin-btnicon fas fa-book text-orange-50" alt="LEAF Library" title="LEAF Library"></i>
        <span class="leaf-admin-btntitle">LEAF Library</span>
        <span class="leaf-admin-btndesc">Use a form made by the LEAF community</span>
    </a>
    <!--{/if}-->

    <a href="../report.php?a=LEAF_Timeline_Explorer" role="button" class="leaf-admin-button bg-red-10">
        <i class="leaf-admin-btnicon fas fa-book text-red-50" alt="Timeline Explorer" title="Timeline Explorer"></i>
        <span class="leaf-admin-btntitle">Timeline Explorer</span>
        <span class="leaf-admin-btndesc">Analyze timeline data</span>
    </a>

    <a href="../report.php?a=LEAF_Toolbox" role="button" class="leaf-admin-button">
        <span class="menuButton bg-green-warm-5v">
            <img class="menuIcon" src="../../libs/dynicons/?img=applications-accessories.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
            <span class="menuText">Toolbox</span><br />
            <span class="menuDesc">Utilities for managing requests</span>
        </span>
    </a>

    <!--{if $siteType == 'national_primary'}-->
    <a href="../report.php?a=LEAF_National_Distribution" role="button" class="leaf-admin-button">
        <span class="menuButton">
            <img class="menuIcon" src="../../libs/dynicons/?img=network-wireless.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
            <span class="menuText">Site Distribution</span><br />
            <span class="menuDesc">Deploy changes to subordinate sites</span>
        </span>
    </a>
    <!--{/if}-->

</div>

<div class="leaf-center-content leaf-clear-both">
<br>
    <h3 role="heading" aria-level="1" tabindex="0">Advanced Options</h3>

    <a href="?a=mod_templates" role="button" class="leaf-admin-button">
        <span class="menuButton bg-orange-10v">
            <img class="menuIcon" src="../../libs/dynicons/?img=text-x-script.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
            <span class="menuText">Template Editor</span><br />
            <span class="menuDesc">Edit HTML Templates</span>
        </span>
    </a>

    <a href="?a=admin_sync_services" role="button" class="leaf-admin-button">
        <span class="menuButton bg-green-cool-10">
            <img class="menuIcon" src="../../libs/dynicons/?img=applications-other.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
            <span class="menuText">Sync Services</span><br />
            <span class="menuDesc">Update Service listing from Org Chart</span>
        </span>
    </a>

    <a href="?a=mod_templates_reports" role="button" class="leaf-admin-button">
        <span class="menuButton bg-blue-10">
            <img class="menuIcon" src="../../libs/dynicons/?img=utilities-terminal.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
            <span class="menuText">LEAF Programmer</span><br />
            <span class="menuDesc">Advanced Reports and Custom Pages</span>
        </span>
    </a>

</div>

<div class="leaf-center-content leaf-clear-both">
<br>
    <p id="btn_programmerMode" tabindex="0" role="button" aria-haspopup="true" aria-expanded="false">Show Other Programmer Options</p>

    <div id="programmerMode" style="display: none">
        
        <h3 role="heading" aria-level="1" tabindex="0">Programmer Options</h3>

        <a href="../?a=search" role="button" class="leaf-admin-button">
            <span class="menuButton bg-indigo-10">
                <img class="menuIcon" src="../../libs/dynicons/?img=system-search.svg&amp;w=96" style="position: relative" alt="Org Chart" title="Org Chart" />
                <span class="menuText">Search Database</span><br />
                <span class="menuDesc">Perform custom queries</span>
            </span>
        </a>

        <a href="?a=mod_file_manager" role="button" class="leaf-admin-button">
            <span class="menuButton bg-orange-10v">
                <img class="menuIcon" src="../../libs/dynicons/?img=system-file-manager.svg&amp;w=76" style="position: relative" alt="Bookmarks" title="Bookmarks" />
                <span class="menuText">File Manager</span><br />
                <span class="menuDesc">Upload custom image assets and documents</span>
            </span>
        </a>

        <a href="?a=admin_update_database" role="button" class="leaf-admin-button">
            <span class="menuButton bg-yellow-10">
                <img class="menuIcon" src="../../libs/dynicons/?img=application-x-executable.svg&amp;w=96" style="position: relative" alt="Database Update" title="Database Update" />
                <span class="menuText">Update Database</span><br />
                <span class="menuDesc">Updates the system database, if available</span>
            </span>
        </a>

</div>

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
