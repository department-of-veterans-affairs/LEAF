//attempt to force a consistent width for the sidebar if there is enough desktop resolution
var lastScreenSize = null;
function sideBar() {
    if(lastScreenSize != $(window).width()) {
        lastScreenSize = $(window).width();

        if(lastScreenSize < 700) {
            mainWidth = lastScreenSize * 0.97;
            $("#toolbar").removeClass("toolbar_right");
            $("#toolbar").addClass("toolbar_inline");
            $("#maincontent").css("width", "98%");
            $("#toolbar").css("width", "98%");
        }
        else {
            mainWidth = (lastScreenSize * 0.8) - 2;
            $("#toolbar").removeClass("toolbar_inline");
            $("#toolbar").addClass("toolbar_right");
            // effective width of toolbar becomes around 200px
            mywidth = Math.floor((1 - 250/lastScreenSize) * 100);
            $("#maincontent").css("width", mywidth + "%");
            $("#toolbar").css("width", 98-mywidth + "%");
        }
    }
}
$(function() {
    sideBar();
    window.onresize = function() {
        sideBar();
    };
});