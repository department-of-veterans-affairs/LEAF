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
    <a id="button_showHelp" tabindex="0" class="buttonNorm" alt="Help Popup" title="Help">Help</a>
    <div id="headerMenu_help">
    {include file="menu_Help.tpl"}
    </div>
</div>
{if $is_admin == true}
     <a href="./admin/" class="buttonNorm" role="button"><img src="../libs/dynicons/?img=applications-system.svg&amp;w=16"/>Admin Panel</a>
{/if}
{if $hide_main_control == 1}
{/if}

<script>
    var menuButton = $('#button_showLinks');
    var subMenu = $('#headerMenu_links');
    var subMenuButton = $('#headerMenu_links').find('a');

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
</script>

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
