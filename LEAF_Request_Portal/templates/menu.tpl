{if $action != ''}
    <a href="./" class="usa-button site-button-outline-secondary">Main Page</a>
{/if}
<span id="headerMenu_container" class="leaf-position-relative">
    <a id="button_showLinks" tabindex="0" class="usa-button site-button-outline-secondary" alt="Links Dropdown" title="Links" aria-haspopup="true" aria-expanded="false" role="button">Links</a>
    <div id="headerMenu_links" tabindex="0" class="leaf-hdr-menu">
        {include file="menu_links.tpl"}
    </div>
</span>
<span id="headerMenuHelp_container" class="leaf-position-relative">
    <a id="button_showHelp" tabindex="0" class="usa-button site-button-outline-secondary" alt="Help Popup" title="Help" aria-haspopup="true" aria-expanded="false" role="button">Help</a>
    <div id="headerMenu_help" tabindex="0" class="leaf-hdr-menu">
        {include file="menu_help.tpl"}
    </div>
</span>
{if $is_admin == true}
     <a href="./admin/" class="usa-button site-button-outline-secondary" role="button">Admin Panel</a>
{/if}
{if $hide_main_control == 1}
{/if}

<script>

    menu508($('#button_showLinks'), $('#headerMenu_links'), $('#headerMenu_links').find('a'));
    menu508($('#button_showHelp'), $('#headerMenu_help'), $('#headerMenu_help'));

    function menu508(menuButton, subMenu, subMenuButton)
    {
        $(menuButton).keypress(function(e) {
            if (e.keyCode === 13) {
                $(subMenu).css("display", "block");
                $(menuButton).attr('aria-expanded', 'true');
                subMenuButton.focus();
            }
        });

        $(subMenuButton).focusout(function() {
                $(subMenu).css("display", "none");
                $(menuButton).attr('aria-expanded', 'false');
                $(menuButton).focus();
        });
    }
</script>

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
