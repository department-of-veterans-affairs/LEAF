/************************
    LEAF's Session Timeout Handler
    Maintain session timeout consistency across multiple instances of the same session

    This variant is for non LEAF-S sites, which inherit OS session controls
*/
if(document.readyState != 'loading') {
    LeafSessionAnnounce();
}
else {
    document.addEventListener('DOMContentLoaded', LeafSessionAnnounce);
}

var LeafSession_warningTime = 120; // show warning X seconds before session expiration
var LeafSession_lastActiveTime = 0;
function LeafSessionAnnounce() {
    document.querySelector('body').insertAdjacentHTML('beforeend', '<div id="LeafSession_dialog" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6)">'
        + '<div style="background-color: #fffdcf; margin: 20% auto; padding: 16px; width: 70%; border: 1px solid black; font-size: 20px; text-align: center">Your session will expire soon if you remain inactive.'
        + '<br /><br /><button id="LeafSession_dialog_moreTime" class="buttonNorm" style="font-size: 24px">I need more time</button></div>'
        + '</div>');

    function handleErrors(res) {
        if (!res.ok) {
            throw Error("Network error.");
        }
        return res;
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

        let relUrl = '.';
        if(window.location.href.indexOf('/admin/') != -1) {
            relUrl = '..';
        }
        let url = `${relUrl}/api/userActivity/status/${LeafSession_lastActiveTime}`;

        // check activity on other windows
        let remote = await fetch(url)
            .then(handleErrors)
            .then(res => res.json())
            .catch(err => {
                console.error(err)
                return {
                    sessExpireTime: null,
                    lastAction: LeafSession_lastActiveTime
                };
            });

        // logout when the session has been terminated elsewhere
        if (remote.lastAction == null) {
            window.location = `${relUrl}/index.php?a=logout`;
        }

        // announce session expiration warnings
        if(remote.sessExpireTime != null && remote.sessExpireTime <= nowUnix + LeafSession_warningTime) {
            document.getElementById('LeafSession_dialog').style.display = 'block';
        }
        else {
            document.getElementById('LeafSession_dialog').style.display = 'none';
        }
    }, 60000);
}
