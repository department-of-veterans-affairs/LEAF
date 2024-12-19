<nav id="headerMenuNav" role="navigation" aria-label="LEAF Nexus main menu">
    <ul>
        <li>
            <a href="../" class="buttonNorm"><img src="../dynicons/?img=go-home.svg&amp;w=16" alt="" title="Main Page" />Main Page</a>
        </li>
        <li id="headerMenuHelp_container" style="display: inline-block">
            <button type="button" id="button_showHelp" class="buttonNorm" title="primary admin contact information"
                onclick="toggleMenuPopup(event)" aria-expanded="false" aria-controls="headerMenu_help">
                <img style="vertical-align: sub;" src="../dynicons/?img=help-browser.svg&amp;w=16" alt="" />
                Help<span aria-hidden="true">▼</span>
            </button>
            <div id="headerMenu_help" class="controlled-element">
                For Help contact your primary admin
                <div id="help-primary-admin" style="font-weight:bold;">Searching...</div>
                <script type="text/javascript">
                    let observPrimaryAdmin = new IntersectionObserver(function(entities) {
                        if(entities[0].isIntersecting) {
                            observPrimaryAdmin.disconnect();
                            $.ajax({
                                url: "../api/system/primaryadmin",
                                dataType: "json",
                                success: function(response) {
                                    const fullName = ((response['firstName'] || '') + ' ' + (response['lastName'] || '')).trim();
                                    const userName = response["userName"] || '';
                                    const nameDisplay = fullName || userName;
                                    const email = response['email'] || '';

                                    const adminInfo = email !== '' ?
                                        '<div>Primary Admin:</div>' + nameDisplay + ' - <br/><a href="mailto:' + email+ '">' + email + '</a>' :
                                        'Primary Admin has not been set.';

                                    $('#help-primary-admin').html('<div id="help_admin_info">' + adminInfo + '</div>');
                                }
                            });
                        }
                    }, {
                        threshold: 1.0
                    });
                    observPrimaryAdmin.observe(document.querySelector('#help-primary-admin'));
                </script>

            </div>
        </li>
        {if isset($isAdmin)}
        <li><a href="./" class="buttonNorm"><img src="../dynicons/?img=applications-system.svg&amp;w=16" alt=""/>OC Admin Panel</a></li>
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

    $('#headerMenu_help').on('focusout', focusout);
</script>