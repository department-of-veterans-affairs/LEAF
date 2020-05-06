<link rel="stylesheet" href="../libs/css/leaf.css" />

<!--{include file="../site_elements/generic_xhrDialog.tpl"}-->

<script>

    $(function() {

        $("#sortable").sortable({
            revert: true
        });

    });

    function createGroup() {
        dialog.setTitle('Add New Card');
        dialog.setContent('<div><div role="heading">Card Title: </div><input aria-label="" id=""></input><div role="heading" style="margin-top: 1rem;">Card Description: </div><input aria-label="Enter group name" id=""></input><div role="heading" style="margin-top: 1rem;">Target Site Address: </div><input aria-label="" id=""></input></div>');

        dialog.show();
        $('input:visible:first, select:visible:first').focus();
    }

    var dialog;
    $(function() {
	    dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');

	    $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
        $('#simplexhrDialog').dialog({minWidth: ($(window).width() * .8) + 30});

    });

</script>

<main id="main-content">

    <div class="grid-container">

        <div class="grid-row grid-gap">
            
            <div class="grid-col-3">
                <nav aria-label="Secondary navigation">
                    <h4>Phoenix VA Sitemap</h4>
                    <ul class="usa-sidenav">
                        <li class="usa-sidenav__item"><a href="" class="usa-current">Card One</a></li>
                        <li class="usa-sidenav__item"><a href="">Card Two</a></li>
                        <li class="usa-sidenav__item"><a href="">Card Three</a></li>
                        <li class="usa-sidenav__item"><a href="">Card Four</a></li>
                    </ul>
                    <div class="leaf-sidenav-bottomBtns">
                        <button class="usa-button leaf-btn-small">Move Up</button>
                        <button class="usa-button leaf-btn-small leaf-float-right">Move Down</button>
                    </div>
                </nav>
            </div>

            <div class="grid-col-9">

                <h1>Phoenix VA Sitemap</h1>
                <div id="sortable">
                    <div class="leaf-sitemap-card active" draggable="true">
                        <h3>Card One</h3>
                        <p>Description of site button, lorem ipsum etc.</p>
                    </div>
                    <div class="leaf-sitemap-card" draggable="true">
                        <h3>Card Two</h3>
                        <p>Link button text edited by user, more text for sample view.</p>
                    </div>
                    <div class="leaf-sitemap-card" draggable="true">
                        <h3>Card Three</h3>
                        <p>Lorem ipsum dolor est sanctus samplus textus.</p>
                    </div>
                    <div class="leaf-sitemap-card" draggable="true">
                        <h3>Card Four</h3>
                        <p>Text description example, longer text is provided that describes the link button.</p>
                    </div>
                </div>
                <div class="leaf-sitemap-addCard" onClick="createGroup();">
                    <h3>Tap To Add New Card</h3>
                </div>
                <div class="leaf-marginAll1rem leaf-clearBoth">
                    <button class="usa-button leaf-float-left">Save Sitemap</button>
                    <button class="usa-button usa-button--outline leaf-float-right">Delete Sitemap</button>
                </div>

            </div>
            
        </div>

    </div>

</main>