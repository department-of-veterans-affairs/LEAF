<link rel="stylesheet" href="../libs/css/leaf.css">

<!--{include file="../site_elements/generic_xhrDialog.tpl"}-->

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
            stop: function(){
                var idsInOrder = $("#sortable").sortable("toArray");
                idsInOrder = $.map( idsInOrder, function( val ) {
                    return val.replace("div_buttonID_","");
                });
                $.each(sitemapOBJ.buttons,  function(index, value){
                    //set order = arraykeyat(id)
                    sitemapOBJ.buttons[index].order = idsInOrder.indexOf(value.id)
                });
                refreshButtons();
            }
        });
    });

	// parses sitemap json into sitemapOBJ
    function parseSitemapJSON(){
        $.ajax({
            type: 'GET',
            url: './api/system/settings',
            cache: false,
            success: function(res) {
                $("#spinner").hide();
                sitemapOBJ = jQuery.parseJSON(res['sitemap_json']);
                refreshButtons();
            },
        });
    }
    
	// builds sitemap JSON from sitemapOBJ
    function buildSitemapJSON(){
    	return JSON.stringify(sitemapOBJ);
    }
        
    //refresh buttons after edit
    function refreshButtons(){
        $('ul.usa-sidenav').html('');
        $('div#sortable').html('');
        var buttons = sitemapOBJ.buttons;
        buttons.sort(function(a, b){
            return a.order-b.order;
        });
        $.each(buttons, function(index, value){
            addButtonToUI(value);
        });
        save();
    }
         
	// insert button into sortable list and sidenav
    function addButtonToUI(button){
        $('ul.usa-sidenav').append('<li class="usa-sidenav__item" id="li_buttonID_' + button.id +' "><a href="#" onClick="editButtonDialog(\'' + button.id + '\');" title="Edit Card">' + button.title + '</a></li>');
        $('div#sortable').append('<div class="edit-card leaf-sitemap-card draggable="true" style="background-color: ' + button.color + '; color: ' + button.fontColor + ';" id="div_buttonID_' + button.id + '");" title="Drag to move, click to edit."><h3 class="edit-card" id="div_headingID_' + button.id + '"><a href="javascript:void(0);" onClick="editButtonDialog(\'' + button.id + '\');" title="Click title to edit." style="color: ' + button.fontColor + '">' + button.title + '</a></h3><p class="edit-card" id="div_paragraphID_' + button.id + '">' + button.description + '</p></div>');
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
            }
            else {
                window.removeEventListener("mousemove", drag);
                window.removeEventListener("mouseup", this);
            }
        }
    });


    //remove button from sortable list and sidenav
    function deleteButtonFromUI(buttonID){
        $.each(sitemapOBJ.buttons,  function(index, value){
        	if(value.id == buttonID){
            	sitemapOBJ.buttons.splice(index, 1);
                return false;
            }
        });
        dialog.hide();
        refreshButtons();
        save();
    }
    
	// generate unique id for sitemap button
    function generateNewButtonID(){
        do {
           var result = '';
           var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
           for ( var i = 0; i < 5; i++ ) {
              result += characters.charAt(Math.floor(Math.random() * 62));
           }
        }
        while (buttonIDExists(result));
        return result;
    }
    
	// check if unique id already exists
    function buttonIDExists(newID) {
        $.each(sitemapOBJ.buttons,  function(index, value){
        	if(value.id == newID){
            	return true;
            }
        });
        return false;
    }
    
	// brings up dialog to add a button
    function createGroup() {
        var dialog = createNewButtonDialog();
        dialog.setTitle('Add Site Card');
        dialog.setContent('<div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Title</div><input id="button-title" size="48" maxlength="27"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Description</div><input aria-label="Enter group name" id="button-description" size="48" maxlength="48"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input id="button-target" size="48" maxlength="2048"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" id="button-color" class="leaf-bold">Card Color</div>' +
            '<span><input type="color" name="btnColor" /></span>' +     
            '<div class="leaf-marginTop-1rem"><div role="heading" id="font-color" class="leaf-bold">Font Color</div>' +
            '<span><input type="color" name="btnFntColor" /></span>' +     
        '</div></div>');

        dialog.show();
        $('input:visible:first, select:visible:first').focus();
    }

	// instantiates new button dialog
    function createNewButtonDialog() {
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            var id = generateNewButtonID();
            var title = $("#xhr input#button-title").val();
            var description = $("#xhr input#button-description").val();
            var target = $("#xhr input#button-target").val();
            var color = $("#xhr input[name='btnColor']").val();
            var fontColor = $("#xhr input[name='btnFntColor']").val();
            var order = sitemapOBJ.buttons.length;
            var newButton = {id: id, title: title, description: description, target: target, color: color, order: order};
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
        var title = '';
        var description = '';
        var target = '';
        var color = '';
        var fontColor = '';
        // get old values
        $.each(sitemapOBJ.buttons, function(index, value){
            if(value.id == buttonID){
                title = value.title;
                description = value.description;
                target = value.target;
                color = value.color;
                fontColor = value.fontColor;
            }
        });
        dialog.setTitle('Edit Site Card');
        dialog.setContent('<div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Title</div><input id="button-title" value="'+title+'"size="48" maxlength="27"></input></div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Description</div><input aria-label="Enter group name" id="button-description" value="'+description+'" size="48" maxlength="48"></input></div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input aria-label="" id="button-target" value="'+target+'"size="48" maxlength="40"></input></div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" id="button-color" class="leaf-bold">Card Color</div>' +
        '<span><input type="color" name="btnColor" /></span>' +
        '<div class="leaf-marginTop-1rem"><div role="heading" id="button-font-color" class="leaf-bold">Font Color</div>' +
        '<span><input type="color" name="btnFntColor" /></span>' +
        '<div class="leaf-buttonBar leaf-clearBoth leaf-float-right">' +
        '<button class="usa-button usa-button--secondary" onClick="deleteButtonFromUI(\'' + buttonID + '\');" id="delete-button">Delete card</button>' +
        '</div>' +
        '</div></div>');
        document.querySelector("#xhr input[name='btnColor']").value = color;
        document.querySelector("#xhr input[name='btnFntColor']").value = fontColor;

        // save handler
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            var id = generateNewButtonID();
            var title = $("#xhr input#button-title").val();
            var description = $("#xhr input#button-description").val();
            var target = $("#xhr input#button-target").val();
            var color = $("#xhr input[name='btnColor']").val();
            var fontColor = $("#xhr input[name='btnFntColor']").val();
            var order = sitemapOBJ.buttons.length;
            $.each(sitemapOBJ.buttons, function(index, value){
                if(value.id == buttonID){
                    sitemapOBJ.buttons[index].title = title;
                    sitemapOBJ.buttons[index].description = description;
                    sitemapOBJ.buttons[index].target = target;
                    sitemapOBJ.buttons[index].color = color;
                    sitemapOBJ.buttons[index].fontColor = fontColor;
                }
            });
            refreshButtons();
            dialog.hide();
            save();
        });
        $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
        dialog.show();
        $('input:visible:first, select:visible:first').focus();
    }
    
	// saves sitemap json into the custom report
    function save() { 
        var newJson = buildSitemapJSON();
        $.ajax({
            type: 'POST',
            url: './api/site/settings/sitemap_json',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
                    sitemap_json: newJson},
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
        <h3 class="navhead"><!--{$city}-->  Sitemap</h3>
        <ul class="usa-sidenav leaf-border-bottom">
        </ul>
        <div>
            <button class="usa-button leaf-btn-green leaf-marginTopBot-halfRem leaf-width100pct" onclick="createGroup();"><i class="fas fa-plus leaf-font0-7rem" title="Delete Card"></i> Add Site Card</button>
        </div>
        <div>
            <a href="./?a=sitemap" target="_blank" class="usa-button usa-button--outline leaf-marginTopBot-halfRem leaf-width100pct">View Sitemap</a>
        </div>
        
        <!--<div class="leaf-sidenav-bottomBtns">
            <button class="usa-button usa-button--outline">Move Up</button>
            <button class="usa-button usa-button--outline leaf-float-right">Move Down</button>
        </div>-->
    </aside>

    <div class="main-content-noRight">

        <h1>
            <a href="./admin" class="leaf-crumb-link">Admin</a><i class="fas fa-caret-right leaf-crumb-caret"></i> Sitemap Editor
            <span id="sitemap-alert" class="leaf-sitemap-alert"><i class="fas fa-check"></i> Sitemap updated</span>
        </h1>
        <div id="sortable" class="leaf-displayFlexRow">
        </div>
        <div style="border: 2px solid black; text-align: center; font-size: 16px; font-weight: bold; background: white; padding: 16px; width: 95%" id="spinner">
            Loading... <img src="./images/largespinner.gif" alt="loading..." />
        </div>

    </div>

</div>
