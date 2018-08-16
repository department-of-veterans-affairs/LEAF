var toggleSensitiveIndicator = function(indicatorID, seriesID, reveal) {
    var maskedSpan = $("span.sensitiveIndicator-masked#maskedSensitiveIndicator_"+indicatorID+"_"+seriesID);
    var unmaskedSpan = $("span.sensitiveIndicator-unmasked#unmaskedSensitiveIndicator_"+indicatorID+"_"+seriesID);
    if (reveal)
    {
        maskedSpan.hide();
        unmaskedSpan.show();
    }
    else
    {
        maskedSpan.show();
        unmaskedSpan.hide();
    }

}