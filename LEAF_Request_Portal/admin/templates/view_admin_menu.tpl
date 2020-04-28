<div class="leaf-admin-content">

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
        <i class="leaf-admin-btnicon fas fa-file-alt text-green-50 leaf-icn-narrow4" alt="Form Editor" title="Form Editor"></i>
        <span class="leaf-admin-btntitle">Form Editor</span>
        <span class="leaf-admin-btndesc">Create and Modify Forms</span>
    </a>
    <!--{/if}-->

    <a href="../?a=reports" role="button" class="leaf-admin-button bg-gold-10">
        <i class="leaf-admin-btnicon fas fa-file-invoice text-gold-50 leaf-icn-narrow4" alt="Report Builder" title="Report Builder"></i>
        <span class="leaf-admin-btntitle">Report Builder</span>
        <span class="leaf-admin-btndesc">Create custom reports</span>
    </a>

    <!--{if $siteType != 'national_subordinate'}-->
    <a href="?a=formLibrary" role="button" class="leaf-admin-button bg-orange-10">
        <i class="leaf-admin-btnicon fas fa-book text-orange-50 leaf-icn-narrow2" alt="LEAF Library" title="LEAF Library"></i>
        <span class="leaf-admin-btntitle">LEAF Library</span>
        <span class="leaf-admin-btndesc">Use a form made by the LEAF community</span>
    </a>
    <!--{/if}-->

    <a href="../report.php?a=LEAF_Timeline_Explorer" role="button" class="leaf-admin-button bg-red-10">
        <i class="leaf-admin-btnicon fas fa-clock text-red-50 leaf-icn-narrow2" alt="Timeline Explorer" title="Timeline Explorer"></i>
        <span class="leaf-admin-btntitle">Timeline Explorer</span>
        <span class="leaf-admin-btndesc">Analyze timeline data</span>
    </a>

    <a href="../report.php?a=LEAF_Toolbox" role="button" class="leaf-admin-button bg-violet-10">
        <i class="leaf-admin-btnicon fas fa-toolbox text-violet-50" alt="Toolbox" title="Toolbox"></i>
        <span class="leaf-admin-btntitle">Toolbox</span>
        <span class="leaf-admin-btndesc">Utilities for managing requests</span>
    </a>

    <!--{if $siteType == 'national_primary'}-->
    <a href="../report.php?a=LEAF_National_Distribution" role="button" class="leaf-admin-button bg-indigo-cool-10">
        <i class="leaf-admin-btnicon fas fa-sitemap text-indigo-cool-50" alt="Site Distribution" title="Site Distribution"></i>
        <span class="leaf-admin-btntitle">Site Distribution</span>
        <span class="leaf-admin-btndesc">Deploy changes to subordinate sites</span>
    </a>
    <!--{/if}-->

    <h3 role="heading" aria-level="1" tabindex="0">Advanced Options</h3>

    <a href="?a=mod_templates" role="button" class="leaf-admin-button bg-blue-10">
        <i class="leaf-admin-btnicon fas fa-edit text-blue-50" alt="Template Editor" title="Template Editor"></i>
        <span class="leaf-admin-btntitle">Template Editor</span>
        <span class="leaf-admin-btndesc">Edit HTML Templates</span>
    </a>

    <a href="?a=admin_sync_services" role="button" class="leaf-admin-button bg-mint-cool-10">
        <i class="leaf-admin-btnicon fas fa-sync-alt text-mint-cool-50" alt="Sync Services" title="Sync Services"></i>
        <span class="leaf-admin-btntitle">Sync Services</span>
        <span class="leaf-admin-btndesc">Update Service listing from Org Chart</span>
    </a>

    <a href="?a=mod_templates_reports" role="button" class="leaf-admin-button bg-yellow-5v">
        <i class="leaf-admin-btnicon fas fa-terminal text-yellow-50" alt="LEAF Programmer" title="LEAF Programmer"></i>
        <span class="leaf-admin-btntitle">LEAF Programmer</span>
        <span class="leaf-admin-btndesc">Advanced Reports and Custom Pages</span>
    </a>

    <p id="btn_programmerMode" tabindex="0" role="button" aria-haspopup="true" aria-expanded="false" class="leaf-show-opts">Show Other Programmer Options</p>

    <span id="programmerMode" style="display: none" class="leaf-valign-top">
        
        <h3 role="heading" aria-level="1" tabindex="0">Programmer Options</h3>

        <a href="../?a=search" role="button" class="leaf-admin-button bg-red-10 leaf-float-left">
            <i class="leaf-admin-btnicon fas fa-search text-red-50 leaf-icn-narrow2" alt="Search Database" title="Search Database"></i>
            <span class="leaf-admin-btntitle">Search Database</span>
            <span class="leaf-admin-btndesc">Perform custom queries</span>
        </a>

        <a href="?a=mod_file_manager" role="button" class="leaf-admin-button bg-gold-10 leaf-float-left">
            <i class="leaf-admin-btnicon fas fa-tasks text-gold-50" alt="File Manager" title="File Manager"></i>
            <span class="leaf-admin-btntitle">File Manager</span>
            <span class="leaf-admin-btndesc">Upload custom image assets and documents</span>
        </a>

        <a href="?a=admin_update_database" role="button" class="leaf-admin-button bg-violet-10 leaf-float-left">
            <i class="leaf-admin-btnicon fas fa-database text-violet-50 leaf-icn-narrow2" alt="Update Database" title="Update Database"></i>
            <span class="leaf-admin-btntitle">Update Database</span>
            <span class="leaf-admin-btndesc">Updates the system database, if available</span>
        </a>

    </span>

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
