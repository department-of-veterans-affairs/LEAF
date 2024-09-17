<nav id="headerMenuNav" role="navigation" aria-label="LEAF site main menu">
    <ul>
        {if $action != ''}
        <li>
            <a href="./" class="buttonNorm" title="nav to homepage"><img src="dynicons/?img=go-home.svg&amp;w=16" alt="" />Home</a>
        </li>
        {/if}
        <li id="headerMenu_container" style="display: inline-block">
            <button type="button" id="button_showLinks" class="buttonNorm" title="links"
                onclick="toggleMenuPopup(event)" aria-expanded="false" aria-controls="headerMenu_links">
                Links<span aria-hidden="true">▼</span>
            </button>
            <div id="headerMenu_links" class="controlled-element">
            {include file={$menu_links}}
            </div>
        </li>
        <li id="headerMenuHelp_container" style="display: inline-block">
            <button type="button" id="button_showHelp" class="buttonNorm" title="primary admin contact information"
                onclick="toggleMenuPopup(event)" aria-expanded="false" aria-controls="headerMenu_help">
                <img style="vertical-align: sub;" src="dynicons/?img=help-browser.svg&amp;w=16" alt="" />
                Help<span aria-hidden="true">▼</span>
            </button>
            <div id="headerMenu_help" class="controlled-element">
            {include file={$menu_help}}
            </div>
        </li>
        {if $is_admin == true}
        <li><a href="./admin/" class="buttonNorm"><img src="dynicons/?img=applications-system.svg&amp;w=16" alt=""/>Admin Panel</a></li>
        {/if}
    </ul>
</nav>

<script>
    function hideElement(element = null) {
        if(element !== null && element.style !== undefined) {
            element.style.zIndex = 1;
            element.classList.remove('is-shown');
            let controllerBtn = document.querySelector('button[aria-controls="' + element.id + '"]');
            if(controllerBtn !== null) {
                controllerBtn.setAttribute('aria-expanded', "false");
            }
        }
    }
    function focusout(e) {
        e.stopPropagation();
        const controlledEl = e.currentTarget || null;
        const newTarget = e.relatedTarget || null;
        if (newTarget === null && controlledEl !== null) {
            hideElement(controlledEl);
        } else {
            const eventTarID = e.currentTarget.id || null;
            let controlledEls = Array.from(document.querySelectorAll(".controlled-element"));
            controlledEls.forEach(controlledEl => {
                const newTargetControlledEl = newTarget.closest('#' + controlledEl.id) || null;
                if (newTargetControlledEl === null) {
                    hideElement(controlledEl);
                }
            });
        }
    }
    function toggleMenuPopup(e){
        e.stopPropagation();
        e.preventDefault();
        const controlledID = e.currentTarget.getAttribute('aria-controls') || "";
        let popupEl = document.getElementById(controlledID);
        if (popupEl !== null) {
            let controlledEls = Array.from(document.querySelectorAll(".controlled-element"));
            controlledEls.forEach(el => el.style.zIndex = 1);

            const priorValue = e.currentTarget.getAttribute('aria-expanded') || "false";
            if(priorValue === "true") {
                hideElement(popupEl);
            } else {
                popupEl.classList.add('is-shown');
                popupEl.style.zIndex = 10;
                e.currentTarget.setAttribute('aria-expanded', "true");
            }
        }
    }

    $('#headerMenu_links').on('focusout', focusout);
    $('#headerMenu_help').on('focusout', focusout);
</script>

<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
