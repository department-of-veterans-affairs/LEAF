{if $action != ''}
    <a href="./" class="buttonNorm" title="nav to homepage"><img src="dynicons/?img=go-home.svg&amp;w=16" alt="" />Main Page</a>
{/if}
<div id="headerMenu_container" style="display: inline-block">
    <a id="button_showLinks" tabIndex="0" class="buttonNorm" title="site links" aria-haspopup="true" aria-expanded="false" role="button">
        Links<span role="img" aria="" alt="">▼</span>
    </a>
    <div id="headerMenu_links">
    {include file={$menu_links}}
    </div>
</div>
<div id="headerMenuHelp_container" style="display: inline-block">
    <a id="button_showHelp" tabIndex="0" class="buttonNorm" title="primary admin contact information" aria-haspopup="true" aria-expanded="false" role="button">
        <img style="vertical-align: sub;" src="dynicons/?img=help-browser.svg&amp;w=16" alt="" />
        Help<span role="img" aria="" alt="">▼</span>
    </a>
    <div id="headerMenu_help" tabindex="0">
    {include file={$menu_help}}
    </div>
</div>
{if $is_admin == true}
     <a href="./admin/" class="buttonNorm" role="button"><img src="dynicons/?img=applications-system.svg&amp;w=16" alt=""/>Admin Panel</a>
{/if}
{if $hide_main_control == 1}
{/if}

<script>
    function focusout(e) {
        e.stopPropagation();
        let parEl = e.currentTarget.parentNode;
        let anchor = parEl?.querySelector('a');
        if (anchor) {
            e.currentTarget.style.display = 'none';
            anchor.setAttribute('aria-expanded', 'false');
        }
    }
    function toggleMenuPopup(e){
        e.stopPropagation();
        if(e.keyCode && (parseInt(e.keyCode)=== 32 || parseInt(e.keyCode)=== 13)) {
            e.preventDefault();
            let popupEl = document.querySelector('#' + e.currentTarget.id + ' + div');
            if (popupEl) {
                if(popupEl.style.display === '') {
                    popupEl.style.display = 'block';
                    e.currentTarget.setAttribute('aria-expanded', 'true');
                } else {
                    curDisplay = popupEl.style.display;
                    popupEl.style.display = curDisplay === 'block' ? 'none' : 'block';
                    e.currentTarget.setAttribute('aria-expanded', curDisplay === 'block' ? 'false' : 'true');
                }
            }
        }
    }
    $('#button_showLinks').on('keypress', toggleMenuPopup);
    $('#button_showHelp').on('keypress', toggleMenuPopup);
    $('#headerMenu_links').on('focusout', focusout);
    $('#headerMenu_help').on('focusout', focusout);
</script>

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
