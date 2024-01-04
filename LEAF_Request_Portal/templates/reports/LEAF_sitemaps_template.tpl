<link rel="stylesheet" href="<!--{$app_css_path}-->/leaf.css">

<!--{include file="../site_elements/generic_xhrDialog.tpl"}-->

<style>
    .icon {
        width: 32px;
        height: 32px;
        vertical-align: middle;
        float: left;
    }

    .icon-button:hover {
        background-color: grey;
    }

    .icon-selected {
        background-color: #1a4480;
    }

    .icon-picked {
        width: 32px;
        height: 32px;
        vertical-align: middle;
    }
</style>

<script>
    var sitemapOBJ;
    var dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    $(function() {
        //load existing sitemap on page load
        parseSitemapJSON();
        // hide alert
        $("#sitemap-alert").hide();
        $("#sortable").sortable({
            revert: true,
            stop: function() {
                var idsInOrder = $("#sortable").sortable("toArray");
                idsInOrder = $.map(idsInOrder, function(val) {
                    return val.replace("div_buttonID_", "");
                });
                $.each(sitemapOBJ.buttons, function(index, value) {
                    //set order = arraykeyat(id)
                    sitemapOBJ.buttons[index].order = idsInOrder.indexOf(value.id)
                });
                refreshButtons();
            }
        });
    });

    // parses sitemap json into sitemapOBJ
    function parseSitemapJSON() {
        $.ajax({
            type: 'GET',
            url: './api/system/settings',
            cache: false,
            success: function(res) {
                $("#spinner").hide();
                sitemapOBJ = jQuery.parseJSON(res['sitemap_json']);
                refreshButtons();
            },
            error: function(err) {
                console.log(err);
            }
        });
    }

    // builds sitemap JSON from sitemapOBJ
    function buildSitemapJSON() {
        return JSON.stringify(sitemapOBJ);
    }

    //refresh buttons after edit
    function refreshButtons() {
        $('ul.usa-sidenav').html('');
        $('div#sortable').html('');
        var buttons = sitemapOBJ.buttons;
        buttons.sort(function(a, b) {
            return a.order - b.order;
        });
        $.each(buttons, function(index, value) {
            addButtonToUI(value);
        });
        save();
    }

    // insert button into sortable list and sidenav
    function addButtonToUI(button) {
        $('ul.usa-sidenav').append('<li class="usa-sidenav__item" id="li_buttonID_' + button.id +
            ' "><a href="#" onClick="editButtonDialog(\'' + button.id + '\');" title="Edit Site">' + button.title +
            '</a></li>');
        const icon = button.icon ? '<img alt="" style="float: left; margin-right: 1rem; height: 48px; width: 48px;" src="' +
            button.icon + '">' : '';
        $('div#sortable').append(
            '<div tabindex="0" class="edit-card leaf-sitemap-card draggable="true" style="cursor: pointer; background-color: ' +
            button.color + '; color: ' + button.fontColor + ';" id="div_buttonID_' + button.id +
            '");" title="Drag to move, click to edit."><h3 class="edit-card" id="div_headingID_' + button.id +
            '"><a tabindex="-1" href="javascript:void(0);" onClick="editButtonDialog(\'' + button.id +
            '\');" title="Click title to edit." style="color: ' + button.fontColor + '">' + button.title + '</a>' +
            icon + '</h3><p class="edit-card" id="div_paragraphID_' + button.id + '">' + button.description +
            '</p></div>');
        $('#div_buttonID_' + button.id).on('keydown', function(event) {
            if (event.keyCode === 13) {
                event.preventDefault();
                $('#div_buttonID_' + button.id + ' a').click();
            }
        });
    }

    // get difference between click and drag for editing cards

    var body = document.getElementById("body");
    body.addEventListener("mousedown", function() {
        window.addEventListener("mousemove", drag);
        window.addEventListener("mouseup", lift);
        var didDrag = false;

        function drag() {
            didDrag = true;
        }

        function lift() {
            if (!didDrag) {
                var eventTarget = event.target.id;
                var eventClass = event.target.className.split(' ')[0];
                var editTarget = eventTarget.slice(-5);
                (eventClass == 'edit-card') && (editButtonDialog(editTarget));
            } else {
                window.removeEventListener("mousemove", drag);
                window.removeEventListener("mouseup", this);
            }
        }
    });

    //remove button from sortable list and sidenav
    function deleteButtonFromUI(buttonID) {
        $.each(sitemapOBJ.buttons, function(index, value) {
            if (value.id == buttonID) {
                sitemapOBJ.buttons.splice(index, 1);
                return false;
            }
        });
        dialog.hide();
        refreshButtons();
        save();
    }

    // generate unique id for sitemap button
    function generateNewButtonID() {
        do {
            var result = '';
            var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
            for (var i = 0; i < 5; i++) {
                result += characters.charAt(Math.floor(Math.random() * 62));
            }
        }
        while (buttonIDExists(result));
        return result;
    }

    // check if unique id already exists
    function buttonIDExists(newID) {
        $.each(sitemapOBJ.buttons, function(index, value) {
            if (value.id == newID) {
                return true;
            }
        });
        return false;
    }

    // brings up dialog to add a button
    function createGroup() {
        var dialog = createNewButtonDialog();
        dialog.setTitle('Add Site');
        dialog.setContent('<div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Site Title</div><input id="button-title" size="48" maxlength="27"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Site Description</div><input aria-label="Enter group name" id="button-description" size="48" maxlength="48"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input id="button-target" size="48"></input></div>' +
            '<div class="leaf-marginAll-1rem" style="width: 30%; float: left;">' +
            '<label for="btnColor" class="leaf-bold" style="display: block;">Site Color</label>' +
            '<input type="color" name="btnColor" style="display: block;" value="#ffffff" />' +
            '</div>' +
            '<div class="leaf-marginAll-1rem" style="width: 30%; float: left;">' +
            '<label for="btnFntColor" class="leaf-bold" style="display: block;">Font Color</label>' +
            '<input type="color" name="btnFntColor" style="display: block;" value="#000000" />' +
            '</div>' +
            '<div class="leaf-marginAll-1rem" style="width: 90%; float: left;">' +
            '<label for="iconpicker" class="leaf-bold" style="display: inline-block;">Icon (Optional)</label>' +
            '<div id="picked-icon" class="icon-picked" style="display: inline-block;"></div>' +
            '</div>' +
            '<div id="iconpicker" style="border: 1px solid grey; width: 100%; height: 10rem; overflow: auto; float: left; margin-bottom: 1rem;"></div>' +
            '</div></div>');
        $('#iconpicker').on('keydown', function(event) {
            if (event.keyCode === 13) {
                event.preventDefault();
                event.target.parentElement.click();
            }
        });
        dialog.show();
        getIcons();
        $('input:visible:first, select:visible:first').focus();
    }

    // instantiates new button dialog
    function createNewButtonDialog() {
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            let id = generateNewButtonID();
            let title = $("#xhr input#button-title").val();
            let description = $("#xhr input#button-description").val();
            let target = $("#xhr input#button-target").val();
            let color = $("#xhr input[name='btnColor']").val();
            let fontColor = $("#xhr input[name='btnFntColor']").val();
            let icon = $("#xhr #picked-icon>img").attr('src') ?? '';
            let order = sitemapOBJ.buttons.length;
            let newButton = {id: id, title: title, description: description, target: target, color: color, fontColor: fontColor, icon: icon, order: order};
            sitemapOBJ.buttons.push(newButton);
            addButtonToUI(newButton);
            dialog.hide();
            save();
        });
        $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
        return dialog;
    }

    // instantiates and pops up edit button dialog
    function editButtonDialog(buttonID) {
        let title = '';
        let description = '';
        let target = '';
        let color = '';
        let fontColor = '';
        let icon = '';
        // get old values
        $.each(sitemapOBJ.buttons, function(index, value) {
            if (value.id == buttonID) {
                title = value.title;
                description = value.description;
                target = value.target;
                color = value.color;
                fontColor = value.fontColor;
                icon = value.icon;
            }
        });
        dialog.setTitle('Edit Site');
        dialog.setContent('<div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Site Title</div><input id="button-title" value="' +
            title + '"size="48" maxlength="27"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Site Description</div><input aria-label="Enter group name" id="button-description" value="' +
            description + '" size="48" maxlength="48"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input aria-label="" id="button-target" value="' +
            target + '"size="48"></input></div>' +
            '<div class="leaf-marginAll-1rem" style="width: 30%; float: left;">' +
            '<label for="btnColor" class="leaf-bold" style="display: block;">Site Color</label>' +
            '<input type="color" name="btnColor" style="display: block;" value="#ffffff" />' +
            '</div>' +
            '<div class="leaf-marginAll-1rem" style="width: 30%; float: left;">' +
            '<label for="btnFntColor" class="leaf-bold" style="display: block;">Font Color</label>' +
            '<input type="color" name="btnFntColor" style="display: block;" value="#000000" />' +
            '</div>' +
            '<div class="leaf-marginAll-1rem" style="width: 90%; float: left;">' +
            '<label for="iconpicker" class="leaf-bold" style="display: inline-block;">Icon (Optional)</label>' +
            '<div id="picked-icon" class="icon-picked" style="display: inline-block;">' + (icon ?
                '<img alt="" class="icon leaf-marginLeft-1rem" style="vertical-align: middle;" src=' + icon + '>' : '') +
            '</div>' +
            '</div>' +
            '<div id="iconpicker" tabindex="0" style="border: 1px solid grey; width: 100%; height: 10rem; overflow: auto; float: left; margin-bottom: 1rem;"></div>' +
            '<div class="leaf-buttonBar leaf-clearBoth">' +
            '<button class="usa-button usa-button--secondary leaf-float-right" onClick="deleteButtonFromUI(\'' +
            buttonID + '\');" id="delete-button">Delete Site</button>' +
            '</div>' +
            '</div></div>');
        document.querySelector("#xhr input[name='btnColor']").value = color ?? '#ffffff';
        document.querySelector("#xhr input[name='btnFntColor']").value = fontColor ?? '#000000';
        $('#iconpicker').on('keydown', function(event) {
            if (event.keyCode === 13) {
                event.preventDefault();
                event.target.parentElement.click();
            }
        });

        // save handler
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            let id = generateNewButtonID();
            let title = $("#xhr input#button-title").val();
            let description = $("#xhr input#button-description").val();
            let target = $("#xhr input#button-target").val();
            let color = $("#xhr input[name='btnColor']").val();
            let fontColor = $("#xhr input[name='btnFntColor']").val();
            let icon = $("#xhr #picked-icon>img").attr('src') ?? '';
            let order = sitemapOBJ.buttons.length;
            $.each(sitemapOBJ.buttons, function(index, value) {
                if (value.id == buttonID) {
                    sitemapOBJ.buttons[index].title = title;
                    sitemapOBJ.buttons[index].description = description;
                    sitemapOBJ.buttons[index].target = target;
                    sitemapOBJ.buttons[index].color = color;
                    sitemapOBJ.buttons[index].fontColor = fontColor;
                    sitemapOBJ.buttons[index].icon = icon;
                }
            });
            refreshButtons();
            dialog.hide();
            save();
        });
        $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
        dialog.show();
        $('input:visible:first, select:visible:first').focus();
        getIcons(icon);
    }

    function getIcons(currIcon) {
        $.ajax({
            type: 'GET',
            url: './api/iconPicker/list',
            success: function(results) {
                for (result in results) {
                    icon = results[result];
                    icon.id = icon.alt.replace('.svg', '');
                    $('#iconpicker').append(`
<div id="${icon.id}_parent" value=${icon.src} onClick="selectIcon('${icon.src}');" style="cursor: pointer;">
<div id="${icon.id}_child" style="padding: 1rem; float: left;" tabindex="0">
<img class="icon" style="vertical-align: middle;" src="${icon.src}" alt="${icon.alt}" title="${icon.name}" />
                            </div>
                        </div>
                    `);
                }
            },
            fail: function(err) {
                console.log(err);
            }
        });
    }

    function selectIcon(src) {
        // set icon of site card to param
        const currIcons = document.getElementsByClassName('icon-selected');
        if (currIcons.length) { currIcons[0].classList.remove('icon-selected'); }

        const selectedIcon = document.querySelector(`.icon[src="${src}"]`);
        selectedIcon.classList.add('icon-selected');

        document.getElementById('picked-icon').innerHTML = `<img class="icon leaf-marginLeft-1rem" style="vertical-align: middle;" src="${src}" alt="" />`;
    }

    // saves sitemap json into the custom report
    function save() {
        var newJson = buildSitemapJSON();
        $.ajax({
                type: 'POST',
                url: './api/site/settings/sitemap_json',
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                sitemap_json: newJson
            },
            success: function(res) {
                // show/hide alert
                $("#sitemap-alert").fadeIn();
                $("#sitemap-alert").delay(1800).fadeOut();
            },
            cache: false
        });
    }
</script>

<div class="leaf-center-content">

    <aside class="sidenav">
        <h3 class="navhead">
            <!--{$city}--> Sitemap
        </h3>
        <ul class="usa-sidenav leaf-border-bottom">
        </ul>
        <div>
            <button class="usa-button leaf-btn-green leaf-marginTopBot-halfRem leaf-width100pct"
                onclick="createGroup();"><i class="fas fa-plus leaf-font0-7rem" title="Delete Site"></i> Add
                Site</button>
        </div>
        <div>
            <a href="./?a=sitemap" target="_blank"
                class="usa-button usa-button--outline leaf-marginTopBot-halfRem leaf-width100pct">View Sitemap</a>
        </div>
        <div>
            <a href="./report.php?a=LEAF_Inbox" target="_blank"
                class="usa-button usa-button--outline leaf-marginTopBot-halfRem leaf-width100pct">View Combined
                Inbox</a>
        </div>

        <!--<div class="leaf-sidenav-bottomBtns">
            <button class="usa-button usa-button--outline">Move Up</button>
            <button class="usa-button usa-button--outline leaf-float-right">Move Down</button>
        </div>-->
    </aside>

    <div class="main-content-noRight">

        <h1>
            <a href="./admin" class="leaf-crumb-link">Admin</a><i class="fas fa-caret-right leaf-crumb-caret"></i>
            Sitemap Editor
            <span id="sitemap-alert" class="leaf-sitemap-alert"><i class="fas fa-check"></i> Sitemap updated</span>
        </h1>
        <div id="sortable" class="leaf-displayFlexRow">
        </div>
        <div style="border: 2px solid black; text-align: center; font-size: 16px; font-weight: bold; background: white; padding: 16px; width: 95%"
            id="spinner">
            Loading... <img src="./images/largespinner.gif" alt="" />
        </div>

    </div>

</div>