<link rel="stylesheet" href="../libs/css/leaf.css" />

<!--{include file="../site_elements/generic_xhrDialog.tpl"}-->

<script>

    $(function() {

		//load existing sitemap on page load
        sitemapOBJ = parseSitemapJSON();
        $.each(sitemapOBJ.buttons, function(index, value){
			addButtonToUI(value);
        });
        
        $("#sortable").sortable({
            revert: true
        });

    });

	// parses sitemap json into sitemapOBJ
    function parseSitemapJSON(){
		sitemapJSON = $('span#sitemap-json').text();
    	result = jQuery.parseJSON(sitemapJSON);
        return result;
    }
    
	// builds sitemap JSON from sitemapOBJ
    function buildSitemapJSON(){
    	return JSON.stringify(sitemapOBJ);
    }
        
	// insert button into sortable list and sidenav
    function addButtonToUI(button){
        $('ul.usa-sidenav').append('<li class="usa-sidenav__item" id="li_buttonID_'+button.id+'"><a onClick="editButtonDialog(\''+button.id+'\');" title="Edit Button">'+button.title+'</a></li>');
        $('div#sortable').append('<div class="leaf-sitemap-button '+button.color+'" draggable="true" id="div_buttonID_'+button.id+'"><i class="fas fa-trash-alt leaf-delete-button" title="Delete Button"></i><h3>'+button.title+'</h3><p>'+button.description+'</p></div>');
    }
    
	// insert existing button in sortable list and sidenav
    function updateButtonUI(buttonID){
        $.each(sitemapOBJ.buttons, function(index, value){
            if(value.id == buttonID){
                $('#li_buttonID_'+buttonID+' a').text(value.title);
                $('#div_buttonID_'+buttonID+' h3').text(value.title);
                $('#div_buttonID_'+buttonID+' p').text(value.description);
            }
        });
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
        dialog.setTitle('Add New Button');
        dialog.setContent('<div>' +
            '<div class="leaf-marginAll1rem"><div role="heading">Button Title</div><input id="button-title" size="48"></input></div>' +
            '<div class="leaf-marginAll1rem"><div role="heading" class="leaf-bold">Button Description</div><input aria-label="Enter group name" id="button-description" size="48"></input></div>' +
            '<div class="leaf-marginAll1rem"><div role="heading" class="leaf-bold">Target Site Address</div><input id="button-target" size="48"></input></div>' +
            '<div class="leaf-marginAll1rem"><div role="heading" id="button-color" class="leaf-bold">Button Color</div>' +
                '<div class="leaf-float-left" style="margin-right: 3rem;">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-blue"></span><input type="radio" id="blue" name="btnColor" value="leaf-button-blue" checked><label for="blue">Blue</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-green"></span><input type="radio" id="green" name="btnColor" value="leaf-button-green"><label for="green">Green</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-yellow"></span><input type="radio" id="yellow" name="btnColor" value="leaf-button-yellow"><label for="yellow">Yellow</label></div>' +
                '</div><div class="leaf-float-left">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-orange"></span><input type="radio" id="orange" name="btnColor" value="leaf-button-orange"><label for="orange">Orange</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-red"></span><input type="radio" id="red" name="btnColor" value="leaf-button-red"><label for="red">Red</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-gold"></span><input type="radio" id="gold" name="btnColor" value="leaf-button-gold"><label for="gold">Gold</label></div>' +
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
    
        dialog.setTitle('Edit Button');
        dialog.setContent('<div>' +
        '<div class="leaf-marginAll1rem"><div role="heading">Button Title</div><input id="button-title" value="'+title+'"size="48"></input></div>' +
        '<div class="leaf-marginAll1rem"><div role="heading">Button Description</div><input aria-label="Enter group name" id="button-description" value="'+description+'" size="48"></input></div>' +
        '<div class="leaf-marginAll1rem"><div role="heading">Target Site Address</div><input aria-label="" id="button-target" value="'+target+'"size="48" ></input></div>' +
        '<div class="leaf-marginAll1rem"><div role="heading" id="button-color" class="leaf-bold">Button Color</div>' +
                '<div class="leaf-float-left" style="margin-right: 3rem;">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-blue"></span><input type="radio" id="blue" name="btnColor" value="value="leaf-button-blue"><label for="blue">Blue</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-green"></span><input type="radio" id="green" name="btnColor" value="value="leaf-button-green"><label for="green">Green</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-yellow"></span><input type="radio" id="yellow" name="btnColor" value="value="leaf-button-yellow"><label for="yellow">Yellow</label></div>' +
                '</div><div class="leaf-float-left">' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-orange"></span><input type="radio" id="orange" name="btnColor" value="value="leaf-button-orange"><label for="orange">Orange</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-red"></span><input type="radio" id="red" name="btnColor" value="value="leaf-button-red"><label for="red">Red</label></div>' +
                '<div class="leaf-color-choice"><span class="leaf-color-demo leaf-button-gold"></span><input type="radio" id="gold" name="btnColor" value="value="leaf-button-gold"><label for="gold">Gold</label></div>' +
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
            updateButtonUI(buttonID);
            dialog.hide();
        });
        $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
        dialog.show();
        $('input:visible:first, select:visible:first').focus();
    }
    
	// saves sitemap json into the custom report
    function save() { 
        $.ajax({
            type: 'GET',
            url: './api/system/reportTemplates/_sitemaps_template',
            success: function(res) {
                var newjson = buildSitemapJSON();
                html = $.parseHTML( res.file );
               // var newFile = $(res.file).find('span#sitemap-json').replaceWith('other_element').end().get(0).outerHTML;
                var newFile = $(res.file);
                newFile.siblings('span#sitemap-json')[0].innerHTML = newjson;
                resultString = '';
                $.each(newFile, function( index, value ) {
                  if($.type(value.outerHTML) == 'string'){
                    	resultString += value.outerHTML;
                  } else if(value.nodeName == "#text"){
                  		resultString += value.data;
                  } else if(value.nodeName == "#comment"){
                        resultString += "<!--" + value.data + "-->";
                  }
                });
                $.ajax({
                    type: 'POST',
                    data: {CSRFToken: '<!--{$CSRFToken}-->',
                           file: resultString},
                    url: './api/system/reportTemplates/_sitemaps_template',
                    success: function(res) {
                        if(res != null) {
                            alert(res);
                        }
                    }
                });
            },
            cache: false
        });
    }

</script>

<main id="main-content">

    <div class="grid-container">

        <div class="grid-row grid-gap">
            
            <div class="grid-col-3">
                <nav aria-label="Secondary navigation">
                    <ul class="usa-sidenav">
                    </ul>
                    <div class="leaf-sidenav-bottomBtns">
                        <button class="usa-button usa-button--outline leaf-btn-small">Move Up</button>
                        <button class="usa-button usa-button--outline leaf-btn-small leaf-float-right">Move Down</button>
                    </div>
                </nav>
            </div>

            <div class="grid-col-9">

                <h1>Phoenix VA Sitemap&nbsp; <button class="usa-button leaf-btn-small" onclick="createGroup();"><i class="fas fa-plus" title="Delete Button"></i> Add Button</button></h1>
                <div id="sortable">
                </div>
                <!-- div class="leaf-marginAll1rem leaf-clearBoth">
                    <button class="usa-button leaf-float-left" id="saveButton" onclick=" save()">Save Sitemap</button>
                    <button class="usa-button usa-button--outline leaf-float-right">Delete Sitemap</button>
                </div -->

            </div>
            
        </div>

    </div>
</main>
<span style="display: none;" id="sitemap-json">{"buttons":[{"id":"abc","title":"Communication Department","description":"Publicity, AV, Graphic Design","target":"www.a.com","color":"leaf-button-green","order":0},{"id":"def","title":"Education/CME","description":"Request Education Services","target":"www.b.com", "color":"leaf-button-gold","order":1},{"id":"ghi","title":"Fiscal Service","description":"Budget Request, Employee Travel","target":"www.c.com","color":"leaf-button-blue","order":2}]}</span>
