<ul>

    <!-- Menu tooggle on smaller screens  -->
    <li id="toggleMenu" role="button" aria-haspopup="true">
        <a href="javascript:void(0);"><span aria-hidden="true" class="leaf-menu"><button>MENU</button></span><i aria-hidden="true" class="fas fa-times"></i><span id="toggleMenu-text">Toggle Navigation</span></a>
    </li>

    <li class="leaf-width-5rem leaf-mob-menu"><a href="../">Home</a></li>

    <li class="leaf-width-8rem leaf-mob-menu"><a href="../?a=reports&v=3">Report Builder</a></li>

    <li class="leaf-width-8rem leaf-mob-menu lev2">
        <a href="javascript:void(0);">Site Links</a>
        <ul>
            <li><a href="../{$orgchartPath}" target="_blank">Nexus: Org Charts</a></li>
        </ul>
    </li>

    <li class="leaf-width-8rem leaf-mob-menu lev2">
        <a href="javascript:void(0);">Admin</a>
        <ul>

            <li><a href="./">Admin Home<i class="leaf-nav-icon-space"></i></a></li>

            <li class="lev3">
                <a href="javascript:void(0);">User Access</a>
                <ul>
                    <li><a href="?a=mod_groups">User Access Groups</a></li>
                    <li><a href="?a=mod_svcChief">Service Chiefs</a></li>
                </ul>
            </li>

            <!--{if $siteType != 'national_subordinate'}-->
                <li><a href="?a=workflow">Workflow Editor<i class="leaf-nav-icon-space"></i></a></li>
            <!--{/if}-->

            <!--{if $siteType != 'national_subordinate'}-->
                <li><a href="?a=form">Form Editor<i class="leaf-nav-icon-space"></i></a></li>
            <!--{/if}-->

            <!--{if $siteType != 'national_subordinate'}-->
                <li><a href="?a=formLibrary">LEAF Library<i class="leaf-nav-icon-space"></i></a></li>
            <!--{/if}-->

            <li><a href="?a=mod_system">Site Settings<i class="leaf-nav-icon-space"></i></a></li>

            <li><a href="../report.php?a=LEAF_Timeline_Explorer">Timeline Explorer<i class="leaf-nav-icon-space"></i></a></li>

            <!--{if $siteType == 'national_primary'}-->
                <li><a href="javascript:void(0)">Site Distribution<i class="leaf-nav-icon-space"></i></a></li>
            <!--{/if}-->

            <li class="lev3">
                <a href="javascript:void(0);">Toolbox</a>
                <ul>
                <li><a href="../report.php?a=LEAF_import_data">Import Spreadsheet</a></li>
                <li><a href="../report.php?a=LEAF_mass_action">Mass Action</a></li>
                <li><a href="../report.php?a=LEAF_request_initiator_new_account">Initiator New Account</a></li>
                </ul>
            </li>

            <li class="lev3">
                <a href="javascript:void(0);">LEAF Developer Console</a>
                <ul>
                    <li><a href="?a=mod_templates">Template Editor</a></li>
                    <li><a href="?a=mod_templates_reports">LEAF Programmer</a></li>
                    <li><a href="?a=mod_templates_email">Email Template Editor</a></li>
                    <li><a href="?a=mod_file_manager">File Manager</a></li>
                    <li><a href="../?a=search">Search Database</a></li>
                    <li><a href="?a=admin_sync_services">Sync Services</a></li>
                    <li><a href="?a=admin_update_database">Update Database</a></li>
                </ul>
            </li>

        </ul>

    </li>

    <li class="leaf-width-4rem leaf-mob-menu lev2">
        <a href="javascript:void(0);"><i class='fas fa-user-circle leaf-usericon' alt='User Account Menu'></i></a>
        <ul class="leaf-usernavmenu">
            <li><a href="javascript:void(0);">User:<br/><span class="leaf-user-menu-name">{$name}</span></a></li>
            <li><a href="javascript:void(0);">Primary Admin:<br/><span id="primary-admin" class="leaf-user-menu-name"></span></a></li>
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
        $('#nav > ul > li:not(#toggleMenu)').removeClass('js-showElement');
        $(this).removeClass('js-open');
        $(this).attr('aria-expanded', false);

    } else {
        $('#nav > ul > li:not(#toggleMenu)').addClass('js-showElement');
        $(this).addClass('js-open');
        $(this).attr('aria-expanded', true);
    }

    return false;
})

// Add plus mark to li that have a sub menu
$('li.lev2:has("ul") > a').append('<i class="fas fa-angle-down leaf-nav-icon"></i>');
$('li.lev3:has("ul") > a').append('<i class="fas fa-angle-left leaf-nav-icon"></i>');


// sub menu
// ------------------------

// When interacting with a li that has a sub menu
$('li:has("ul")').on('mouseover keyup click mouseleave', function(e) {

    //console.log("test")

    // If either -
        // tabbing into the li that has a sub menu
        // hovering over the li that has a sub menu
    if ( e.keyCode === 9 | e.type === 'mouseover' ) {

        // Show sub menu
        $(this).children('ul').removeClass('js-hideElement');
        $(this).children('ul').addClass('js-showElement');
    }

    // If mouse leaves li that has sub menu
    if ( e.type === 'mouseleave' ) {

        // hide sub menu
        $(this).children('ul').removeClass('js-showElement');
        $(this).children('ul').addClass('js-hideElement');
    }


    // If clicking on li that has a sub menu
    if ( e.type === 'click' ) {

        // If sub menu is already open
        if ( $(this).children('a').hasClass('js-openSubMenu') ) {

            // remove Open class
            $(this).children('a').removeClass('js-openSubMenu');

            // Hide sub menu
            $(this).children('ul').removeClass('js-showElement');
            $(this).children('ul').addClass('js-hideElement');


        // If sub menu is closed
        } else {

            // add Open class
            $(this).children('a').addClass('js-openSubMenu');

            // Show sub menu
            $(this).children('ul').removeClass('js-hideElement');
            $(this).children('ul').addClass('js-showElement');

        }

    } // end click event

});


// Tabbing through Levels of sub menu
// ------------------------

// If key is pressed while on the last link in a sub menu
$('li > ul > li:last-child > a').on('keydown', function(e) {


    // If tabbing out of the last link in a sub menu AND not tabbing into another sub menu
    if ( (e.keyCode == 9) && $(this).parent('li').children('ul').length == 0 ) {

            // Close this sub menu
            $(this).parent('li').parent('ul').removeClass('js-showElement');
            $(this).parent('li').parent('ul').addClass('js-hideElement');


        // If tabbing out of a third level sub menu and there are no other links in the parent (level 2) sub menu
        if ( $(this).parent('li').parent('ul').parent('li').parent('ul').parent('li').children('ul').length > 0
             && $(this).parent('li').parent('ul').parent('li').is(':last-child') ) {

                // Close the parent sub menu (level 2) as well
                $(this).parent('li').parent('ul').parent('li').parent('ul').removeClass('js-showElement');
                $(this).parent('li').parent('ul').parent('li').parent('ul').addClass('js-hideElement');
        }

    }

})

})
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
