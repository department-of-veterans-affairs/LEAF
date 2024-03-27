/************************
    LEAF's Session Timeout Handler
    Maintain session timeout consistency across multiple instances of the same session
*/
if(document.readyState != 'loading') {
    LeafSessionTimeout();
}
else {
    document.addEventListener('DOMContentLoaded', LeafSessionTimeout);
}

var LeafSession_maxTime = 15 * 60; // seconds
var LeafSession_warningTime = 13 * 60; // warn user after X seconds
var LeafSession_lastActiveTime = Math.round(Date.now() / 1000);
function LeafSessionTimeout() {
    document.querySelector('body').insertAdjacentHTML('beforeend', '<div id="LeafSession_dialog" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6)">'
        + '<div style="background-color: #fffdcf; margin: 20% auto; padding: 16px; width: 70%; border: 1px solid black; font-size: 20px; text-align: center">Your session will expire soon if you remain inactive.'
        + '<br />Press any key or move the mouse to extend your session.<br /><br /><button id="LeafSession_dialog_moreTime" class="buttonNorm" style="font-size: 24px">I need more time</button></div>'
        + '</div>');

    function handleErrors(res) {
        if (!res.ok) {
            throw Error("Network error.");
        }
        return res;
    }

    function warn(expiry) {
        let currSession = {
            sessExpireTime: expiry,
            lastAction: LeafSession_lastActiveTime
        };
        localStorage.setItem('LeafSession', JSON.stringify(currSession));
    }

    function handleActivity() {
        let now = new Date();
        let nowUnix = Math.round(now.getTime() / 1000);
        if(LeafSession_lastActiveTime < nowUnix) {
            LeafSession_lastActiveTime = nowUnix;
        }
        document.getElementById('LeafSession_dialog').style.display = 'none';
    }
    
    document.getElementById('LeafSession_dialog_moreTime').addEventListener('click', handleActivity);
    document.addEventListener('mousemove', handleActivity);
    document.addEventListener('keypress', handleActivity);

    var LeafSession_interval = setInterval(async function() {
        let now = new Date();
        let nowUnix = Math.round(now.getTime() / 1000);

        let remote = localStorage.getItem('LeafSession');
        if(remote == null) {
            let newSession = {
                sessExpireTime: null,
                lastAction: LeafSession_lastActiveTime
            };
            localStorage.setItem('LeafSession', JSON.stringify(newSession));
            remote = newSession;
        }
        else {
            remote = JSON.parse(remote);
            if(LeafSession_lastActiveTime > remote.lastAction) {
                remote.sessExpireTime = null;
                remote.lastAction = LeafSession_lastActiveTime;
                localStorage.setItem('LeafSession', JSON.stringify(remote));
            }
        }

        // use the most recent timestamp on the most active window
        if(remote.lastAction > LeafSession_lastActiveTime) {
            LeafSession_lastActiveTime = remote.lastAction;
        }

        // broadcast warning when the threshold has been reached
        if(LeafSession_lastActiveTime + LeafSession_warningTime <= nowUnix) {
            document.getElementById('LeafSession_dialog').style.display = 'block';
            warn(LeafSession_lastActiveTime + LeafSession_maxTime);
        }
        else {
            document.getElementById('LeafSession_dialog').style.display = 'none';
        }

        // logout when maxTime has been reached
        if (LeafSession_lastActiveTime + LeafSession_maxTime <= nowUnix) {
            let relUrl = '.';
            if(window.location.href.indexOf('/admin/') != -1) {
                relUrl = '..';
            }
            window.location = `${relUrl}/index.php?a=logout`;
        }
    }, 60000);
}
