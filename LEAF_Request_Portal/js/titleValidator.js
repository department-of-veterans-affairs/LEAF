var prevTitle = "";
var maxTitleLength = 256;
$(document).ready(function(){
    prevTitle = $('input[name="title"][type="text"]').val();
});
$(document).on('DOMNodeInserted', 'input[name="title"][type="text"]', function(e) {
    prevTitle = $('input[name="title"][type="text"]').val();
});
$(document).on('input','input[name="title"][type="text"]', function(e) {
    if ($(this).val().length>maxTitleLength) 
    {
        $(this).val(prevTitle);
        if ( !$('span#titleSizeWarning').length ) {
            $('input[name="title"][type="text"]').after('<span id="titleSizeWarning" style="color:#c00;"><br/>'+maxTitleLength+' character maximum</span>');
        }
    }
    else
    {
        prevTitle = $(this).val();
        $('span#titleSizeWarning').remove();   
    }
});