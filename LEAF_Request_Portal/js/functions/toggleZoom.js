var zoomStatus = new Array();
function toggleZoom(divID) {
    if(zoomStatus[divID] == 1) {
        zoomStatus[divID] = 0;
        $('#'+divID).animate({'font-size': '12px'}, 200);
    }
    else {
        zoomStatus[divID] = 1;
        $('#'+divID).animate({'font-size': '24px'}, 200);
    }
}