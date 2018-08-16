{if $action != ''}
    <a href="./" class="buttonNorm"><img src="../libs/dynicons/?img=go-home.svg&amp;w=16" role="button" />Main Page</a>
{/if}
<div id="headerMenu_container" style="display: inline-block">
    <a id="button_showLinks" tabindex="0" class="buttonNorm" alt="Links Dropdown" title="Links" aria-haspopup="true" aria-expanded="false" role="button">Links</a>
    <div id="headerMenu_links">
    {include file="menu_links.tpl"}
    </div>
</div>
{if $is_admin == true}
     <a href="./admin/" class="buttonNorm" role="button"><img src="../libs/dynicons/?img=applications-system.svg&amp;w=16"/>Admin Panel</a>
{/if}
{if $hide_main_control == 1}
{/if}

<script>
    $('#button_showLinks').keypress(function(e) {
        if (e.keyCode === 13) {
            $('#headerMenu_links').css("display", "block");
            $('#button_showLinks').attr('aria-expanded', 'true');
        }
    });
</script>

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
