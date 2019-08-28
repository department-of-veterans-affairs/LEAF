/************************
    LEAF's Session Timeout Handler
*/
if(document.readyState != 'loading') {
    LeafSessionTimeout();
}
else {
    document.addEventListener('DOMContentLoaded', LeafSessionTimeout);
}

var LeafSession_idleTime = 0; // minutes
var LeafSession_maxTime = 15; // minutes
var LeafSession_warningTime = 13; // warn user after X minutes
var LeafSession_isDisplayingWarning = false;
function LeafSessionTimeout() {
    document.querySelector('body').insertAdjacentHTML('beforeend', '<div id="LeafSession_dialog" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6)">'
        + '<div style="background-color: #fffdcf; margin: 20% auto; padding: 16px; width: 70%; border: 1px solid black; font-size: 20px; text-align: center">Your session will expire soon if you remain inactive.'
        + '<br /><br /><button id="LeafSession_dialog_moreTime" class="buttonNorm" style="font-size: 24px">I need more time</button></div>'
        + '</div>');

    document.getElementById('LeafSession_dialog_moreTime').addEventListener('click', function() {
        LeafSession_idleTime = 0;
        document.getElementById('LeafSession_dialog').style.display = 'none';
    });
    document.addEventListener('mousemove', function() {
        LeafSession_idleTime = 0;
        document.getElementById('LeafSession_dialog').style.display = 'none';
    });
    document.addEventListener('keypress', function() {
        LeafSession_idleTime = 0;
        document.getElementById('LeafSession_dialog').style.display = 'none';
    });

    var LeafSession_interval = setInterval(function() {
        LeafSession_idleTime++;

        if (LeafSession_idleTime >= LeafSession_maxTime) {
            if(window.location.href.indexOf('/admin/') == -1) {
                window.location = './index.php?a=logout';
            }
            else {
                window.location = '../index.php?a=logout';
            }
        }
        // check activity on other windows after LeafSession_warningTime minutes
        else if(LeafSession_idleTime >= LeafSession_warningTime) {
            var now = new Date();
            var nowUnix = Math.round(now.getTime() / 1000);

            var req = new XMLHttpRequest();
            if(window.location.href.indexOf('/admin/') == -1) {
                req.open('GET', './api/userActivity?_'+ nowUnix);
            }
            else {
                req.open('GET', '../api/userActivity?_'+ nowUnix);
            }
            req.onload = function() {
                if(this.status >= 200 && this.status < 400) {
                    var lastActiveWindowTime = this.response;
                    var lastActiveCurrWindowTime = nowUnix - LeafSession_idleTime * 60;

                    // use the most recent timestamp on the most active window
                    if(lastActiveWindowTime > lastActiveCurrWindowTime) {
                        LeafSession_idleTime = Math.round((nowUnix - lastActiveWindowTime) / 60);
                    }
                    else {
                        document.getElementById('LeafSession_dialog').style.display = 'block';
                    }
                }
            };
            req.send();
        }
    }, 60000);
}
