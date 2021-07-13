{if $action != ''}
    <a href="./" class="buttonNorm"><img src="../libs/dynicons/?img=go-home.svg&amp;w=16" role="button" />Main Page</a>
{/if}
<div id="headerMenu_container" style="display: inline-block">
    <a id="button_showLinks" tabindex="0" class="buttonNorm" alt="Links Dropdown" title="Links" aria-haspopup="true" aria-expanded="false" role="button">Links</a>
    <div id="headerMenu_links">
    {include file="menu_links.tpl"}
    </div>
</div>
<div id="headerMenuHelp_container" style="display: inline-block">
    <a id="button_showHelp" tabindex="0" class="buttonNorm" alt="Help Popup" title="Help" aria-haspopup="true" aria-expanded="false" role="button"><img style="vertical-align: sub;" src="../libs/dynicons/?img=help-browser.svg&amp;w=16">&nbsp;Help</a>
    <div id="headerMenu_help" tabindex="0">
    {include file="menu_help.tpl"}
    </div>
</div>
{if $is_admin == true}
     <a href="./admin/" class="buttonNorm" role="button"><img src="../libs/dynicons/?img=applications-system.svg&amp;w=16"/>Admin Panel</a>
{/if}
{if $hide_main_control == 1}
{/if}

<script>

    menu508($('#button_showLinks'), $('#headerMenu_links'), $('#headerMenu_links').find('a'));
    menu508($('#button_showHelp'), $('#headerMenu_help'), $('#headerMenu_help'));

    function menu508(menuButton, subMenu, subMenuButton)
    {
        $(menuButton).keydown(function(e) {
            if (e.keyCode === 13) {
                $(subMenu).css("display", "block");
                $(menuButton).attr('aria-expanded', 'true');
                subMenuButton.focus();
            }
        });

        $(menuButton).focusout(function() {
            $(subMenu).css("display", "none");
            $(menuButton).attr('aria-expanded', 'false');
        });
    }
</script>

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
