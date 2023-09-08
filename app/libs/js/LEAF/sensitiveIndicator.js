var toggleSensitiveIndicator = function(indicatorID, seriesID, reveal) {
    var maskedElement = $("div.sensitiveIndicator#xhrIndicator_"+indicatorID+"_"+seriesID+" > span.sensitiveIndicator-masked");
    var unmaskedElement = $("div.sensitiveIndicator#xhrIndicator_"+indicatorID+"_"+seriesID+" > .printResponse");
    var label = $("div.sensitiveIndicator#xhrIndicator_"+indicatorID+"_"+seriesID+" > div.sensitiveIndicatorMaskToggle > label");
    if (reveal)
    {
        label.attr('title', 'Hide Sensitive Data');
        label.attr('alt', 'Hide Sensitive Data');
        maskedElement.css( "display", "none" );
        unmaskedElement.css( "display", "block" );
    }
    else
    {
        label.attr('title', 'Show Sensitive Data');
        label.attr('alt', 'Show Sensitive Data');
        maskedElement.css( "display", "block" );
        unmaskedElement.css( "display", "none" );
    }

}