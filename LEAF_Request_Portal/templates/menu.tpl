{if $action != ''}
    <button onclick="location.href='./';" class="buttonNorm" alt="Main Page" title="Main Page" style="padding-bottom: 2px;"><img src="../libs/dynicons/?img=go-home.svg&amp;w=16"/>Main Page</button>
{/if}
<div id="headerMenu_container" style="display: inline-block">
    <button id="button_showLinks" tabindex="0" class="buttonNorm" alt="Links Dropdown" title="Links" aria-haspopup="true" aria-expanded="false">Links</button>
    <div id="headerMenu_links">
    {include file="menu_links.tpl"}
    </div>
</div>
{if $is_admin == true}
     <button onclick="location.href='./admin/';" class="buttonNorm" alt="Admin Panel" title="Admin Panel" style="padding-bottom: 2px;"><img src="../libs/dynicons/?img=applications-system.svg&amp;w=16" />Admin Panel</button>
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
