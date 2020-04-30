<link rel="stylesheet" href="../libs/css/leaf.css">

<!--{include file="../site_elements/generic_xhrDialog.tpl"}-->

<script>
	var sitemapOBJ;
    $(function() {
        sitemapOBJ = parseSitemapJSON();
        $.each(sitemapOBJ.cards, function(index, value){
			addCardToUI(value);
        });
        
        $("#sortable").sortable({
            revert: true
        });

    });

    function parseSitemapJSON(){
		sitemapJSON = $('span#sitemap-json').text();
    	result = jQuery.parseJSON(sitemapJSON);
        return result;
    }
    
    function buildSitemapJSON(){
    	return JSON.stringify(sitemapOBJ);
    }
        
    function addCardToUI(card){
    	    $('ul.usa-sidenav').append('<li class="usa-sidenav__item" id="li_cardID_'+card.id+'"><a onClick="editCardDialog(\''+card.id+'\');">'+card.title+'</a></li>');
            $('div#sortable').append('<div class="leaf-sitemap-card" draggable="true" id="div_cardID_'+card.id+'"><h3>'+card.title+'</h3><p>'+card.description+'</p></div>');
    }
    
    function updateCardUI(cardID){
        $.each(sitemapOBJ.cards, function(index, value){
            if(value.id == cardID){
    	$('#li_cardID_'+cardID+' a').text(value.title);
        $('#div_cardID_'+cardID+' h3').text(value.title);
        $('#div_cardID_'+cardID+' p').text(value.description);
            }
        });
    }
    
    function generateNewCardID(){
        do {
           var result           = '';
           var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
           for ( var i = 0; i < 5; i++ ) {
              result += characters.charAt(Math.floor(Math.random() * 62));
           }
        }
        while (cardIDExists(result));
        return result;
    }
    
    function cardIDExists(newID) {
        $.each(sitemapOBJ.cards,  function(index, value){
        	if(value.id == newID){
            	return true;
            }
        });
        return false;
    }
    
    function createGroup() {
        var dialog = createNewCardDialog();
        dialog.setTitle('Add New Card');
        dialog.setContent('<div><div role="heading">Card Title: </div><input aria-label="" id="card-title"></input><div role="heading" style="margin-top: 1rem;">Card Description: </div><input aria-label="Enter group name" id="card-description"></input><div role="heading" style="margin-top: 1rem;">Target Site Address: </div><input aria-label="" id="card-target"></input></div>');

        dialog.show();
        $('input:visible:first, select:visible:first').focus();
    }

    function createNewCardDialog() {
            var dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
       	 	dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            var id = generateNewCardID();
            var title = $("#xhr input#card-title").val();
            var description = $("#xhr input#card-description").val();
            var target = $("#xhr input#card-target").val();
            var order = sitemapOBJ.cards.length;
            var newCard = {id: id, title: title, description: description, target: target, order: order};
            sitemapOBJ.cards.push(newCard);
            addCardToUI(newCard);
            dialog.hide();
        });
	    $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
        return dialog;
    }
    
    function editCardDialog(cardID) {
            var dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
            var title = '';
            var description = '';
            var target = '';
        	//get old values
            $.each(sitemapOBJ.cards, function(index, value){
                if(value.id == cardID){
                    title = value.title;
                    description = value.description;
                    target = value.target;
                }
            });
        
            dialog.setTitle('Edit Card');
            dialog.setContent('<div><div role="heading">Card Title: </div><input aria-label="" id="card-title" value="'+title+'"></input><div role="heading" style="margin-top: 1rem;">Card Description: </div><input aria-label="Enter group name" id="card-description" value="'+description+'"></input><div role="heading" style="margin-top: 1rem;">Target Site Address: </div><input aria-label="" id="card-target" value="'+target+'"></input></div>');

        	//save handler
       	 	dialog.setSaveHandler(function() {
            	dialog.indicateBusy();
                var id = generateNewCardID();
                var title = $("#xhr input#card-title").val();
                var description = $("#xhr input#card-description").val();
                var target = $("#xhr input#card-target").val();
                var order = sitemapOBJ.cards.length;
                $.each(sitemapOBJ.cards, function(index, value){
                    if(value.id == cardID){
						sitemapOBJ.cards[index].title = title;
                        sitemapOBJ.cards[index].description = description;
                        sitemapOBJ.cards[index].target = target;
                    }
                });
                updateCardUI(cardID);
                dialog.hide();
            });
            $('#simplexhr').css({width: $(window).width() * .8, height: $(window).height() * .8});
            dialog.show();
            $('input:visible:first, select:visible:first').focus();
    }
    
    function save() { 
        $.ajax({
            type: 'GET',
            url: './api/system/reportTemplates/_sitemaps_template',
            success: function(res) {
                var newjson =buildSitemapJSON();
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
                    <h4>Phoenix VA Sitemap</h4>
                    <ul class="usa-sidenav">
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
                </div>
                <div class="leaf-sitemap-addCard" onclick="createGroup();">
                    <h3>Tap To Add New Card</h3>
                </div>
                <div class="leaf-marginAll1rem leaf-clearBoth">
                    <button class="usa-button leaf-float-left" id="saveButton" onclick=" save()">Save Sitemap</button>
                    <button class="usa-button usa-button--outline leaf-float-right">Delete Sitemap</button>
                </div>

            </div>
            
        </div>

    </div>
</main>
<span style="display: none;" id="sitemap-json">{"cards":[{"id":"abc","title":"Card One","description":"This is a description","target":"www.a.com","order":0},{"id":"def","title":"Card Twoss","description":"This is a descriptionss","target":"www.b.comss","order":1},{"id":"ghi","title":"Card Three","description":"This is a description","target":"www.c.com","order":2},{"id":"CNrvW","title":"new card","description":"asdf","target":"rrrrr","order":3}]}</span>