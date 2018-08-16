var toggleSensitiveIndicator = function(indicatorID, seriesID, reveal) {
    var maskedElement = $("div.sensitiveIndicator#xhrIndicator_"+indicatorID+"_"+seriesID+" > span.sensitiveIndicator-masked");
    var unmaskedElement = $("div.sensitiveIndicator#xhrIndicator_"+indicatorID+"_"+seriesID+" > span.printResponse");
    if (reveal)
    {
        maskedElement.css( "display", "none" );
        unmaskedElement.css( "display", "block" );
    }
    else
    {
        maskedElement.css( "display", "block" );
        unmaskedElement.css( "display", "none" );
    }

}