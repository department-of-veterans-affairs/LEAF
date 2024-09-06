<a href="../" class="usa-button site-button-outline-secondary">Main Page</a>
<span id="headerMenu_container" class="leaf-position-relative">
    <a id="button_showLinks" tabindex="0" class="usa-button site-button-outline-secondary" alt="Links Dropdown" title="Links">Links</a>
    <div id="headerMenu_links" tabindex="0" class="leaf-hdr-menu">
        {include file="menu_links.tpl"}
    </div>
</span>
<span id="headerMenuHelp_container" class="leaf-position-relative">
    <a id="button_showHelp" tabindex="0" class="usa-button site-button-outline-secondary" alt="" title="Help">Help</a>
    <div id="headerMenu_help" tabindex="0" class="leaf-hdr-menu">
        {include file="menu_help.tpl"}
    </div>
</span>
<a href="./" class="usa-button site-button-outline-secondary">Admin Panel</a>


<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>

<div id="links" style="position: absolute; padding: 24px; z-index: 1000; display: none; background-color: white; border: 1px solid black; width: 310px; box-shadow: 0 2px 6px #8e8e8e;">
    <a href="{$orgchartPath}">
        <span class="menuButtonSmall" style="background-color: #ffecb7">
            <img class="menuIconSmall" src="../dynicons/?img=system-users.svg&amp;w=76" style="position: relative" alt="" title="Org Chart" />
            <span class="menuTextSmall">Organizational Chart</span><br />
            <span class="menuDescSmall">Update/Review Org. Charts and Employee Information</span>
        </span>
    </a>

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

</div>
