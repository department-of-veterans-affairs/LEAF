<a href="../" class="buttonNorm"><img src="../../libs/dynicons/?img=go-home.svg&amp;w=16" alt="Main Page" title="Main Page" />Main Page</a>
<div id="headerMenu_container" style="display: inline-block">
    <a id="button_showLinks" tabindex="0" class="buttonNorm" alt="Links Dropdown" title="Links">Links</a>
    <div id="headerMenu_links">
    {include file="menu_links.tpl"}
    </div>
</div>
<div id="headerMenuHelp_container" style="display: inline-block">
    <a id="button_showHelp" tabindex="0" class="buttonNorm" alt="Help Popup" title="Help"><img style="vertical-align: sub;" src="../../libs/dynicons/?img=help-browser.svg&amp;w=16">Help</a>
    <div id="headerMenu_help" tabindex="0">
    {include file="menu_help.tpl"}
    </div>
</div>
<a href="./" class="buttonNorm"><img src="../../libs/dynicons/?img=applications-system.svg&amp;w=16" alt="Admin Panel" title="Admin Panel" />Admin Panel</a>

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>

<div id="links" style="position: absolute; padding: 24px; z-index: 1000; display: none; background-color: white; border: 1px solid black; width: 310px; box-shadow: 0 2px 6px #8e8e8e;">
<a href="../{$orgchartPath}">
    <span class="menuButtonSmall" style="background-color: #ffecb7">
        <img class="menuIconSmall" src="../../libs/dynicons/?img=system-users.svg&amp;w=76" style="position: relative" alt="Org Chart" title="Org Chart" />
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
