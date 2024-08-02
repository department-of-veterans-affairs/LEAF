<!-- Menu toggle on smaller screens  -->
<div id="toggleMenu">
    <a href="javascript:void(0);" aria-label="open mobile navigation" aria-expanded="false" role="button"
        aria-controls="leaf_admin_menu">
        <span class="leaf-menu">MENU</span><i aria-hidden="true" class="fas fa-times"></i>
    </a>
</div>
<ul id="leaf_admin_menu">
    <li class="leaf-width-5rem leaf-mob-menu"><a href="../">Home</a></li>

    <li class="leaf-width-8rem leaf-mob-menu"><a href="../?a=reports&v=3">Report Builder</a></li>

    <li class="leaf-width-8rem leaf-mob-menu lev2">
        <a href="javascript:void(0);" aria-label="site links submenu" aria-expanded="false" role="button"
            aria-controls="site_links_submenu">Site Links</a>
        <ul id="site_links_submenu">
            <li><a href="{$orgchartPath}" target="_blank">Nexus: Org Charts</a></li>
        </ul>
    </li>

    <li class="leaf-width-8rem leaf-mob-menu lev2">
        <a href="javascript:void(0);" aria-label="admin submenu" aria-expanded="false" role="button"
            aria-controls="admin_submenu">Admin</a>
        <ul id="admin_submenu">
            <!--{if $action != ''}-->
            <li><a href="./">Admin Panel<i class="leaf-nav-icon-space"></i></a></li>
            <!--{/if}-->
            <li><a href="https://leaf.va.gov/platform/service_requests_launchpad/" target="_blank">LEAF Support<i class="leaf-nav-icon-space"></i></a></li>

            <li class="lev3">
                <a href="javascript:void(0);" aria-label="user access submenu" aria-expanded="false" role="button"
                    aria-controls="user_access_submenu">User Access</a>
                <ul id="user_access_submenu">
                    <li><a href="?a=mod_groups">User Access Groups</a></li>
                    <li><a href="?a=mod_svcChief">Service Chiefs</a></li>
                <!--{if $siteType == 'national_subordinate'}-->
                    <li><a href="?a=access_matrix">Access Matrix<i class="leaf-nav-icon-space"></i></a></li>
                <!--{/if}-->
                </ul>
            </li>

            <li class="lev3">
                <a href="javascript:void(0);" aria-label="site configuration submenu" aria-expanded="false" role="button"
                    aria-controls="site_configuration_submenu">Site Configuration</a>
                <ul id="site_configuration_submenu">
                <!--{if $siteType != 'national_subordinate'}-->
                    <li><a href="?a=workflow">Workflow Editor<i class="leaf-nav-icon-space"></i></a></li>
                    <li><a href="?a=form_vue">Form Editor<i class="leaf-nav-icon-space"></i></a></li>
                    <li><a href="?a=formLibrary">LEAF Library<i class="leaf-nav-icon-space"></i></a></li>
                <!--{/if}-->

                    <li><a href="?a=mod_system">Site Settings<i class="leaf-nav-icon-space"></i></a></li>
                <!--{if $siteType == 'national_primary'}-->
                    <li><a href="../report.php?a=LEAF_National_Distribution">Site Distribution<i class="leaf-nav-icon-space"></i></a></li>
                <!--{/if}-->
                </ul>
            </li>

            <li class="lev3">
                <a href="javascript:void(0);" aria-label="admin oversight tools submenu" aria-expanded="false" role="button"
                    aria-controls="oversight_tools_submenu">Admin Oversight Tools</a>
                <ul id="oversight_tools_submenu">
                    <li><a href="../?a=reports&v=3&query=N4IgLgpgTgtgziAXAbVASwCZJHSAHASQBEQAaEAez2gEMwKpsBCAXjJBjoGMALbKCHAoAbAG4Qs5AOZ0I2AIIA5EgF9S6LIhAYIwiJEmVqUOg2xtynMLyQAGabIXKQKgLrkAVhTQA7BChxoUTQuOXIuWSkGAE9FGhgwnDA6AFcEchouMDQKHwB9HjRcGPZcCDwAMRThADM0YWEEnzAAeR9haJB3HAYwJGA1EGE0GDQ%2BxABGW2nyYdHWmpq4fTsVIA%3D%3D%3D&indicators=NobwRAlgdgJhDGBDALgewE4EkAiYBcYyEyANgKZgA0YUiAthQVWAM4bL4AMAvpeNHCRosuAsgCeABwrVaDfGGZt0HPDz6RYCFBhwKWyFAFcWzOY0XVlq9fy1DdosInhFUUAPoALCAYzizegsldi5eO0EdEQUYRHEWDxZoeDIPEkQDDxc3KED5JitQtW4AXSA&sort=N4Ig1gpgniBcIBMCGUDOBlAlgOwMYQBklUAXAQVxMwHtsQAaEagJwQmbkQlVxAF8gA%3D%3D&title=VW5yZXNvbHZlZCByZXF1ZXN0cw%3D%3D">Unresolved Requests</a></li>
                    <li><a href="../report.php?a=LEAF_Timeline_Explorer">Timeline Explorer</a></li>
                    <li><a href="../?a=reports&v=3">Report Builder</a></li>
                    <li><a href="../report.php?a=LEAF_Data_Visualizer">Data Visualizer</a></li>
                </ul>
            </li>

            <li class="lev3">
                <a href="javascript:void(0);" aria-label="LEAF Developer console submenu" aria-expanded="false" role="button"
                    aria-controls="developer_console_submenu">LEAF Developer Console</a>
                <ul id="developer_console_submenu">
                    <li><a href="?a=mod_templates">Template Editor</a></li>
                    <li><a href="?a=mod_templates_email">Email Template Editor</a></li>
                    <li><a href="?a=mod_templates_reports">LEAF Programmer</a></li>
                    <li><a href="?a=mod_file_manager">File Manager</a></li>
                    <li><a href="../?a=search">Search Database</a></li>
                    <!--{if $hasCustomCode == 0}-->
                    <li><a href="?a=admin_sync_services">Sync Services</a></li>
                    <!--{/if}-->
                    <li><a href="?a=admin_update_database">Update Database</a></li>
                </ul>
            </li>

            <li class="lev3">
                <a href="javascript:void(0);" aria-label="toolbox submenu" aria-expanded="false" role="button"
                    aria-controls="toolbox_submenu">Toolbox</a>
                <ul id="toolbox_submenu">
                <li><a href="../report.php?a=LEAF_import_data">Import Spreadsheet</a></li>
                <li><a href="../report.php?a=LEAF_mass_action">Mass Action</a></li>
                <li><a href="./?a=mod_account_updater">New Account Updater</a></li>
                <li><a href="../report.php?a=LEAF_sitemaps_template">Sitemap Editor</a></li>
                <li><a href="../report.php?a=LEAF_Sitemap_Search">Sitemap Search</a></li>
                <li><a href="?a=mod_combined_inbox">Combined Inbox Editor</a></li>
                <li><a href="../report.php?a=LEAF_table_input_report">Grid Splitter</a></li>
                </ul>
            </li>
        </ul>

    </li>

    <li class="leaf-width-4rem leaf-mob-menu lev2">
        <a href="javascript:void(0);" aria-label="user account menu" aria-expanded="false" role="button"
            aria-controls="user_account_menu"><i class='fas fa-user-circle leaf-usericon'></i></a>
        <ul class="leaf-usernavmenu" id="user_account_menu">
            <li tabindex="0">User:<br/><span class="leaf-user-menu-name">{$name}</span></li>
            <li tabindex="0">Primary Admin:<br/><span id="primary-admin" class="leaf-user-menu-name"></span></li>
            <li><a href="../?a=logout">Sign Out</a></li>
        </ul>
    </li>

</ul>

<script>
$(document).ready(function() {

// Remove no-js class
$('html').removeClass('no-js');

$('#toggleMenu').on('click', function() {

    if ( $(this).hasClass('js-open') ) {
        $('#nav > ul > li').removeClass('js-showElement');
        $('#toggleMenu a').attr('aria-label', 'open mobile navigation');
        $(this).removeClass('js-open');
        $('#toggleMenu a').attr('aria-expanded', false);

    } else {
        $('#nav > ul > li').addClass('js-showElement');
        $('#toggleMenu a').attr('aria-label', 'close mobile navigation');
        $(this).addClass('js-open');
        $('#toggleMenu a').attr('aria-expanded', true);
    }

    return false;
})

// Add plus mark to li that have a sub menu
$('li.lev2:has(ul) > a').append('<i class="fas fa-angle-down leaf-nav-icon"></i>');
$('li.lev3:has(ul) > a').append('<i class="fas fa-angle-left leaf-nav-icon"></i>');
$('li.lev3:has(ul) > a').append('<i class="fas fa-angle-down leaf-nav-icon"></i>');


// sub menu
// ------------------------

// When interacting with a li that has a sub menu
$('li:has(ul)').on('mouseover click mouseleave focusout', function(e) {
    // hovering over the li that has a sub menu
    if (e.type === 'mouseover') {
        // Show sub menu
        $(this).children('a').attr('aria-expanded', true);
        $(this).children('a').addClass('js-openSubMenu');
        $(this).children('ul').removeClass('js-hideElement');
        $(this).children('ul').addClass('js-showElement');
    }

    // If mouse leaves li that has sub menu
    if (e.type === 'mouseleave') {
        // hide sub menu
        $(this).children('a').attr('aria-expanded', false);
        $(this).children('a').removeClass('js-openSubMenu');
        $(this).children('ul').removeClass('js-showElement');
        $(this).children('ul').addClass('js-hideElement');
    }

    // If clicking on li that has a sub menu
    if (e.type === 'click') {
        e.stopPropagation();

        // If sub menu is already open
        if ( $(this).children('a').hasClass('js-openSubMenu') ) {

            // remove Open class
            $(this).children('a').attr('aria-expanded', false);
            $(this).children('a').removeClass('js-openSubMenu');

            // Hide sub menu
            $(this).children('ul').removeClass('js-showElement');
            $(this).children('ul').addClass('js-hideElement');


        // If sub menu is closed
        } else {

            // add Open class
            $(this).children('a').attr('aria-expanded', true);
            $(this).children('a').addClass('js-openSubMenu');

            // Show sub menu
            $(this).children('ul').removeClass('js-hideElement');
            $(this).children('ul').addClass('js-showElement');

        }

    }
    if(e.type === 'focusout') {
        e.stopPropagation();
        const curTarget = e.currentTarget || null;
        const newTarget = e.relatedTarget || null;
        if(curTarget !== null && newTarget !== null) {
            const prevLev2Li = curTarget.closest('li.lev2');
            const newLev2Li = newTarget.closest('li.lev2');
            const prevLev3Li = curTarget.closest('li.lev3');
            const newLev3Li = newTarget.closest('li.lev3');
            if(prevLev2Li !== null && prevLev2Li !== newLev2Li) {
                $(prevLev2Li).children('a').attr('aria-expanded', false);
                $(prevLev2Li).children('a').removeClass('js-openSubMenu');
                $(prevLev2Li).children('ul').removeClass('js-showElement');
                $(prevLev2Li).children('ul').addClass('js-hideElement');
            }
            if(prevLev3Li !== null && prevLev3Li !== newLev3Li) {
                $(prevLev3Li).children('a').attr('aria-expanded', false);
                $(prevLev3Li).children('a').removeClass('js-openSubMenu');
                $(prevLev3Li).children('ul').removeClass('js-showElement');
                $(prevLev3Li).children('ul').addClass('js-hideElement');
            }
        }
    }
});


});
</script>

<script type="text/javascript">
    $.ajax({
        url: "../api/system/primaryadmin",
        dataType: "json",
        success: function(response) {
            var emailString = response['Email'] != '' ? " - " + response['Email'] : '';
            if(response["Fname"] !== undefined)
            {
                $('#primary-admin').html(response['Fname'] + " " + response['Lname'] + emailString);
            }
            else if(response["userName"] !== undefined)
            {
                $('#primary-admin').html(response['userName']);
            }
            else
            {
                $('#primary-admin').html('Not Set');
            }

        }
    });
</script>
