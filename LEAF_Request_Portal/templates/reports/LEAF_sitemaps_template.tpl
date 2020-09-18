<link rel="stylesheet" href="../libs/css/leaf.css">

<!--{include file="../site_elements/generic_xhrDialog.tpl"}-->

<script>
	var sitemapOBJ;
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
    }
                    
	// insert button into sortable list and sidenav
    function addButtonToUI(button){
        $('ul.usa-sidenav').append('<li class="usa-sidenav__item" id="li_buttonID_'+button.id+'"><a href="#" onClick="editButtonDialog(\''+button.id+'\');" title="Edit Card"><i class="fas fa-edit leaf-float-right text-blue-warm-50v" alt="Edit Sitemap Card"></i>'+button.title+'</a></li>');
        $('div#sortable').append('<div class="leaf-sitemap-card '+button.color+'" draggable="true" id="div_buttonID_'+button.id+'"><i class="fas fa-trash-alt leaf-delete-card" title="Delete Card" onClick="deleteButtonFromUI(\'' + button.id + '\')"></i><h3>'+button.title+'</h3><p>'+button.description+'</p></div>');
    }

    //remove button from sortable list and sidenav
    function deleteButtonFromUI(buttonID){
        $.each(sitemapOBJ.buttons,  function(index, value){
        	if(value.id == buttonID){
            	sitemapOBJ.buttons.splice(index, 1);
                return false;
            }
        });
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
        dialog.setTitle('Add New Card');
        dialog.setContent('<div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Title</div><input id="button-title" size="48" maxlength="36"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Description</div><input aria-label="Enter group name" id="button-description" size="48" maxlength="60"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input id="button-target" size="48" maxlength="40"></input></div>' +
            '<div class="leaf-marginAll-1rem"><div role="heading" id="button-color" class="leaf-bold">Card Color</div>' +
                '<div class="leaf-float-left" style="margin-right: 3rem;">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-white"></span><input type="radio" id="white" name="btnColor" value="leaf-card-white" checked><label for="white">White</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-blue"></span><input type="radio" id="blue" name="btnColor" value="leaf-card-blue"><label for="blue">Blue</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-green"></span><input type="radio" id="green" name="btnColor" value="leaf-card-green"><label for="green">Green</label></div>' +
                '</div><div class="leaf-float-left">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-orange"></span><input type="radio" id="orange" name="btnColor" value="leaf-card-orange"><label for="orange">Orange</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-yellow"></span><input type="radio" id="yellow" name="btnColor" value="leaf-card-yellow"><label for="yellow">Yellow</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-grey"></span><input type="radio" id="grey" name="btnColor" value="leaf-card-grey"><label for="grey">Grey</label></div>' +
                '</div>' +
        '</div></div>');

        dialog.show();
        $('input:visible:first, select:visible:first').focus();
    }

	// instantiates new button dialog
    function createNewButtonDialog() {
        var dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            var id = generateNewButtonID();
            var title = $("#xhr input#button-title").val();
            var description = $("#xhr input#button-description").val();
            var target = $("#xhr input#button-target").val();
            var color = $("#xhr input[name='btnColor']:checked").val();
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
        var dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
        var title = '';
        var description = '';
        var target = '';
        var color = '';
        // get old values
        $.each(sitemapOBJ.buttons, function(index, value){
            if(value.id == buttonID){
                title = value.title;
                description = value.description;
                target = value.target;
                color = value.color;
            }
        });
        var chkVarWhite, chkVarBlue, chkVarGreen, chkVarOrange, chkVarYellow, chkVarGrey = '';
        if (color == 'leaf-card-white') {chkVarWhite = 'checked'}
        if (color == 'leaf-card-blue') {chkVarBlue = 'checked'}
        if (color == 'leaf-card-green') {chkVarGreen = 'checked'}
        if (color == 'leaf-card-orange') {chkVarOrange = 'checked'}
        if (color == 'leaf-card-yellow') {chkVarYellow = 'checked'}
        if (color == 'leaf-card-grey') {chkVarGrey = 'checked'}
        dialog.setTitle('Edit Card');
        dialog.setContent('<div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Title</div><input id="button-title" value="'+title+'"size="48" maxlength="36"></input></div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Card Description</div><input aria-label="Enter group name" id="button-description" value="'+description+'" size="48" maxlength="60"></input></div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input aria-label="" id="button-target" value="'+target+'"size="48" maxlength="40"></input></div>' +
        '<div class="leaf-marginAll-1rem"><div role="heading" id="button-color" class="leaf-bold">Card Color</div>' +
                '<div class="leaf-float-left" style="margin-right: 3rem;">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-white"></span><input type="radio" id="white" name="btnColor" value="leaf-card-white"' + chkVarWhite + '><label for="white">White</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-blue"></span><input type="radio" id="blue" name="btnColor" value="leaf-card-blue"' + chkVarBlue + '><label for="blue">Blue</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-green"></span><input type="radio" id="green" name="btnColor" value="leaf-card-green"' + chkVarGreen +'><label for="green">Green</label></div>' +
                '</div><div class="leaf-float-left">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-orange"></span><input type="radio" id="orange" name="btnColor" value="leaf-card-orange"' + chkVarOrange + '><label for="orange">Orange</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-yellow"></span><input type="radio" id="yellow" name="btnColor" value="leaf-card-yellow"' + chkVarYellow + '><label for="yellow">Yellow</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-card-grey"></span><input type="radio" id="grey" name="btnColor" value="leaf-card-grey"' + chkVarGrey + '><label for="grey">Grey</label></div>' +
                '</div>' +
        '</div></div>');

        // save handler
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            var id = generateNewButtonID();
            var title = $("#xhr input#button-title").val();
            var description = $("#xhr input#button-description").val();
            var target = $("#xhr input#button-target").val();
            var color = $("#xhr input[name='btnColor']:checked").val();
            var order = sitemapOBJ.buttons.length;
            $.each(sitemapOBJ.buttons, function(index, value){
                if(value.id == buttonID){
                    sitemapOBJ.buttons[index].title = title;
                    sitemapOBJ.buttons[index].description = description;
                    sitemapOBJ.buttons[index].target = target;
                    sitemapOBJ.buttons[index].color = color;
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
                $("#sitemap-alert").delay(3000).fadeOut();
            },
            cache: false
        });
    }

</script>

<div class="leaf-center-content">
            
    <aside class="sidenav">
        <h3>Sitemap cards</h3>
        <ul class="usa-sidenav leaf-border-bottom">
        </ul>
        <div>
            <button class="usa-button leaf-width-13rem leaf-marginTopBot-halfRem" onclick="createGroup();"><i class="fas fa-plus" title="Delete Card"></i> Add Card</button>
        </div>
        <div>
            <button class="usa-button usa-button--outline leaf-width-13rem leaf-marginTopBot-halfRem"><a href="./?a=sitemap" target="_blank">View Sitemap</a></button>
        </div>
        
        <!--<div class="leaf-sidenav-bottomBtns">
            <button class="usa-button usa-button--outline">Move Up</button>
            <button class="usa-button usa-button--outline leaf-float-right">Move Down</button>
        </div>-->
    </aside>

    <div class="main-content-noRight">

        <h1>
            <a href="/LEAF_Request_Portal/admin" class="leaf-crumb-link">Admin</a><i class="fas fa-caret-right leaf-crumb-caret"></i><!--{$city}--> Sitemap
            <span id="sitemap-alert" class="leaf-sitemap-alert"><i class="fas fa-check"></i> Sitemap updated</span>
        </h1>
        <div id="sortable" class="leaf-displayFlexRow">
        </div>
        <div style="border: 2px solid black; text-align: center; font-size: 16px; font-weight: bold; background: white; padding: 16px; width: 95%" id="spinner">
            Loading... <img src="./images/largespinner.gif" alt="loading..." />
        </div>

    </div>

</div>
