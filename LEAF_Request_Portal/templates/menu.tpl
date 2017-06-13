{if $action != ''}
    <a href="./" class="buttonNorm"><img src="../libs/dynicons/?img=go-home.svg&amp;w=16" alt="Main Page" title="Main Page" />Main Page</a>
{/if}
<div id="headerMenu_container" style="display: inline-block">
    <a id="button_showLinks" href="#" class="buttonNorm">Links &#9660;</a>
    <div id="headerMenu_links">
    {include file="menu_links.tpl"}
    </div>
</div>
{if $is_admin == true}
     <a href="./admin/" class="buttonNorm"><img src="../libs/dynicons/?img=applications-system.svg&amp;w=16" alt="Admin Panel" title="Admin Panel" />Admin Panel</a>
{/if}
{if $hide_main_control == 1}
{/if}

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
