<div class="leaf-admin-content">

    <h3 role="heading" aria-level="1" tabindex="0">Get Help</h3>

    <a href="https://leaf.va.gov/platform/service_requests_launchpad/" target="_blank" role="button" class="leaf-admin-button bg-blue-cool-10 lf-trans-blue">
        <i class="leaf-admin-btnicon fas fa-info-circle text-blue-cool-50" title="LEAF Support"></i>
        <span class="leaf-admin-btntitle">LEAF Support</span>
        <span class="leaf-admin-btndesc">Access VA LEAF Support Services</span>
    </a>
    <br /><br />

    <h3 role="heading" aria-level="1" tabindex="0">User Access</h3>

    <a href="?a=mod_groups" role="button" class="leaf-admin-button bg-yellow-5 lf-trans-yellow">
        <i class="leaf-admin-btnicon fas fa-users text-yellow-40" title="Modify users and groups"></i>
        <span class="leaf-admin-btntitle">User Access Groups</span>
        <span class="leaf-admin-btndesc">Modify users and groups</span>
    </a>

    <a href="?a=mod_svcChief" role="button" class="leaf-admin-button bg-yellow-5 lf-trans-yellow">
        <i class="leaf-admin-btnicon fas fa-user-friends text-yellow-40" title="Modify service chief listing"></i>
        <span class="leaf-admin-btntitle">Service Chiefs</span>
        <span class="leaf-admin-btndesc">Review service chiefs and set backups</span>
    </a>

    <!--{if $siteType == 'national_subordinate'}-->
        <a href="?a=access_matrix" role="button" class="leaf-admin-button bg-yellow-5 lf-trans-yellow">
            <i class="leaf-admin-btnicon fas fa-th text-yellow-40" title="Access Matrix"></i>
            <span class="leaf-admin-btntitle">Access Matrix</span>
            <span class="leaf-admin-btndesc">Configure group access to tasks</span>
        </a>
    <!--{/if}-->
    <br /><br />

    <h3 role="heading" aria-level="1" tabindex="0">Site Configuration</h3>

    <!--{if $siteType != 'national_subordinate'}-->
        <a href="?a=workflow" role="button" class="leaf-admin-button bg-blue-cool-10 lf-trans-blue">
            <i class="leaf-admin-btnicon fas fa-cogs text-blue-cool-50" title="Workflow Editor"></i>
            <span class="leaf-admin-btntitle">Workflow Editor</span>
            <span class="leaf-admin-btndesc">Edit flowcharts for workflows</span>
        </a>
    <!--{/if}-->

    <!--{if $siteType != 'national_subordinate'}-->
        <a href="?a=form_vue" role="button" class="leaf-admin-button bg-blue-cool-10 lf-trans-blue">
            <i class="leaf-admin-btnicon fas fa-file-alt text-blue-cool-50 leaf-icn-narrow4" title="Form Editor"></i>
            <span class="leaf-admin-btntitle">Form Editor</span>
            <span class="leaf-admin-btndesc">Create and Modify Forms</span>
        </a>
    <!--{/if}-->

    <!--{if $siteType != 'national_subordinate'}-->
        <a href="?a=formLibrary" role="button" class="leaf-admin-button bg-blue-cool-10 lf-trans-blue">
            <i class="leaf-admin-btnicon fas fa-book text-blue-cool-50 leaf-icn-narrow2" title="LEAF Library"></i>
            <span class="leaf-admin-btntitle">LEAF Library</span>
            <span class="leaf-admin-btndesc">Use a form made by the LEAF community</span>
        </a>
    <!--{/if}-->

    <a href="?a=mod_system" role="button" class="leaf-admin-button bg-blue-cool-10 lf-trans-blue">
        <i class="leaf-admin-btnicon fas fa-keyboard text-blue-cool-50" title="Bookmarks"></i>
        <span class="leaf-admin-btntitle">Site Settings</span>
        <span class="leaf-admin-btndesc">Edit site name, time zone, and other labels</span>
    </a>

    <!--{if $siteType == 'national_primary'}-->
        <a href="../report.php?a=LEAF_National_Distribution" role="button"
            class="leaf-admin-button bg-blue-cool-10 lf-trans-blue">
            <i class="leaf-admin-btnicon fas fa-sitemap text-blue-cool-50" title="Site Distribution"></i>
            <span class="leaf-admin-btntitle">Site Distribution</span>
            <span class="leaf-admin-btndesc">Deploy changes to subordinate sites</span>
        </a>
    <!--{/if}-->
    <br /><br />

    <h3 role="heading" aria-level="1" tabindex="0">Admin Oversight Tools</h3>
    <a href="../?a=reports&v=3&query=N4IgLgpgTgtgziAXAbVASwCZJHSAHASQBEQAaEAez2gEMwKpsBCAXjJBjoGMALbKCHAoAbAG4Qs5AOZ0I2AIIA5EgF9S6LIhAYIwiJEmVqUOg2xtynMLyQAGabIXKQKgLrkAVhTQA7BChxoUTQuOXIuWSkGAE9FGhgwnDA6AFcEchouMDQKHwB9HjRcGPZcCDwAMRThADM0YWEEnzAAeR9haJB3HAYwJGA1EGE0GDQ%2BxABGW2nyYdHWmpq4fTsVIA%3D%3D%3D&indicators=NobwRAlgdgJhDGBDALgewE4EkAiYBcYyEyANgKZgA0YUiAthQVWAM4bL4AMAvpeNHCRosuAsgCeABwrVaDfGGZt0HPDz6RYCFBhwKWyFAFcWzOY0XVlq9fy1DdosInhFUUAPoALCAYzizegsldi5eO0EdEQUYRHEWDxZoeDIPEkQDDxc3KED5JitQtW4AXSA&sort=N4Ig1gpgniBcIBMCGUDOBlAlgOwMYQBklUAXAQVxMwHtsQAaEagJwQmbkQlVxAF8gA%3D%3D&title=VW5yZXNvbHZlZCByZXF1ZXN0cw%3D%3D"
        role="button" class="leaf-admin-button bg-violet-10 lf-trans-blue">
        <i class="leaf-admin-btnicon fas fa-search text-violet-50 leaf-icn-narrow2" title="Timeline Explorer"></i>
        <span class="leaf-admin-btntitle">Unresolved Requests</span>
        <span class="leaf-admin-btndesc">Examine potential delays</span>
    </a>

    <a href="../report.php?a=LEAF_Timeline_Explorer" role="button" class="leaf-admin-button bg-violet-10 lf-trans-blue">
        <i class="leaf-admin-btnicon fas fa-clock text-violet-50 leaf-icn-narrow2" title="Timeline Explorer"></i>
        <span class="leaf-admin-btntitle">Timeline Explorer</span>
        <span class="leaf-admin-btndesc">Analyze timeline data</span>
    </a>

    <a href="../?a=reports&v=3" role="button" class="leaf-admin-button bg-violet-10 lf-trans-blue">
        <i class="leaf-admin-btnicon fas fa-file-invoice text-violet-50 leaf-icn-narrow4" title="Report Builder"></i>
        <span class="leaf-admin-btntitle">Report Builder</span>
        <span class="leaf-admin-btndesc">Create custom reports</span>
    </a>

    <a href="../report.php?a=LEAF_Data_Visualizer" role="button" class="leaf-admin-button bg-violet-10 lf-trans-blue">
        <i class="leaf-admin-btnicon fas fa-chart-pie text-violet-50 leaf-icn-narrow2" title="Data Visualizer"></i>
        <span class="leaf-admin-btntitle">Data Visualizer</span>
        <span class="leaf-admin-btndesc">Analyze form responses</span>
    </a>
    <br /><br />

    <h3 role="heading" aria-level="1" tabindex="0">LEAF Developer Console</h3>

    <a href="?a=mod_templates" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-edit text-green-cool-50 leaf-icn-narrow2" title="Template Editor"></i>
        <span class="leaf-admin-btntitle">Template Editor</span>
        <span class="leaf-admin-btndesc">Edit HTML Templates</span>
    </a>

    <a href="?a=mod_templates_email" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-mail-bulk text-green-cool-50 leaf-icn-narrow2" title="Email Template Editor"></i>
        <span class="leaf-admin-btntitle">Email Template Editor</span>
        <span class="leaf-admin-btndesc">Add and Edit Email Templates</span>
    </a>

    <a href="?a=mod_templates_reports" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-terminal text-green-cool-50" title="LEAF Programmer"></i>
        <span class="leaf-admin-btntitle">LEAF Programmer</span>
        <span class="leaf-admin-btndesc">Advanced Reports and Custom Pages</span>
    </a>

    <a href="?a=mod_file_manager" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-tasks text-green-cool-50" title="File Manager"></i>
        <span class="leaf-admin-btntitle">File Manager</span>
        <span class="leaf-admin-btndesc">Upload custom images and documents</span>
    </a>

    <a href="../?a=search" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-search text-green-cool-50 leaf-icn-narrow2" title="Search Database"></i>
        <span class="leaf-admin-btntitle">Search Database</span>
        <span class="leaf-admin-btndesc">Perform custom queries</span>
    </a>

    <a href="?a=admin_sync_services" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-sync-alt text-green-cool-50" title="Sync Services"></i>
        <span class="leaf-admin-btntitle">Sync Services</span>
        <span class="leaf-admin-btndesc">Update Service listing from Org Chart</span>
    </a>

    <a href="?a=admin_update_database" role="button" class="leaf-admin-button bg-green-cool-10 lf-trans-green">
        <i class="leaf-admin-btnicon fas fa-database text-green-cool-50 leaf-icn-narrow2" title="Update Database"></i>
        <span class="leaf-admin-btntitle">Update Database</span>
        <span class="leaf-admin-btndesc">Updates the system database, if available</span>
    </a>
    <br /><br />

    <h3 role="heading" aria-level="1" tabindex="0" class="leaf-clear-both">Toolbox</h3>

    <a href="../report.php?a=LEAF_import_data" role="button" class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-file-import text-orange-50" title="Import Spreadsheet"></i>
        <span class="leaf-admin-btntitle">Import Spreadsheet</span>
        <span class="leaf-admin-btndesc">Rows to requests, columns as fields</span>
    </a>

    <a href="../report.php?a=LEAF_mass_action" role="button" class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-list text-orange-50" title="Mass Actions"></i>
        <span class="leaf-admin-btntitle">Mass Actions</span>
        <span class="leaf-admin-btndesc">Apply bulk actions to requests</span>
    </a>

    <a href="./?a=mod_account_updater" role="button" class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-play text-orange-50 leaf-icn-narrow2" title="Initiator New Account"></i>
        <span class="leaf-admin-btntitle">New Account Updater</span>
        <span class="leaf-admin-btndesc">Update records with new account</span>
    </a>


    <a href="../report.php?a=LEAF_sitemaps_template" role="button"
        class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-map-signs text-orange-50 leaf-icn-narrow2" title="Sitemap Editor"></i>
        <span class="leaf-admin-btntitle">Sitemap Editor</span>
        <span class="leaf-admin-btndesc">Edit portal Sitemap links</span>
    </a>

    <a href="../report.php?a=LEAF_Sitemap_Search" role="button"
        class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-search text-orange-50 leaf-icn-narrow2" title="Sitemap Search"></i>
        <span class="leaf-admin-btntitle">Sitemap Search</span>
        <span class="leaf-admin-btndesc">Search all sites within a sitemap</span>
    </a>

    <!--
    <a href="./?a=site_designer" role="button" class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-edit text-orange-50 leaf-icn-narrow2" alt="" title="Site Designer"></i>
        <span class="leaf-admin-btntitle">Site Designer</span>
        <span class="leaf-admin-btndesc">Change the way the site looks (Alpha)</span>
    </a>
    -->

    <a href="?a=mod_combined_inbox" role="button" class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-solid fa-inbox text-orange-50 leaf-icn-narrow2" title="Combined Inbox Editor"></i>
        <span class="leaf-admin-btntitle">Combined Inbox Editor</span>
        <span class="leaf-admin-btndesc">Edit combined inbox</span>
    </a>

    <a href="../report.php?a=LEAF_table_input_report" role="button"
        class="leaf-admin-button bg-orange-10 lf-trans-orange">
        <i class="leaf-admin-btnicon fas fa-file-export text-orange-50 leaf-icn-narrow2" title="Sitemap Editor"></i>
        <span class="leaf-admin-btntitle">Grid Splitter</span>
        <span class="leaf-admin-btndesc">Export grid form data to Excel spreadsheet</span>
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
            fail: function(err) {
                console.log(err);
            },
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