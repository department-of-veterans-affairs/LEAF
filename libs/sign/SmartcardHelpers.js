var Signer = function() {
    var isConnected = false;
    var pendingSignatures = {}; // callbacks
    var initiatedJNLP = false;
    var socket = null;
    function connect(_callback) {
        console.log('begin connect, initiatedJNLP = ' + initiatedJNLP + ", socket = " + socket);
        if(socket != null
            && socket.readyState == 1) {
            if(typeof _callback == 'function') {
                _callback();
            }
            return 1;
        }
        //socket = new WebSocket('ws://localhost:8443');
        var chromeUrl = 'ws://localhost:8080/';
        var ieUrl = 'https://localhost:8443/myapp/';
        !!document.documentMode ? socket = new SockJS(ieUrl) : socket = new WebSocket(chromeUrl);
        socket.addEventListener('open', function() {
            isConnected = true;
            if(typeof _callback == 'function') {
                _callback();
            }
        });
        socket.addEventListener('close', function() {
            console.log('close.  initiatedJNLP = ' + initiatedJNLP);
            //if(socket.readyState == 3 || socket.readyState == 0) { // closed/can't open
            console.log("Connection Closed/Can't Open - Trying to reconnect. ReadyState: " + socket.readyState);
            setTimeout(function() {
                connect(_callback);
            }, 500);
            if(initiatedJNLP == false) {
                if (!isConnected) {
                    initiatedJNLP = true;
                    window.open("//" + window.location.hostname + "/LEAF/digital-signature/sign.jnlp");
                }
            }
            // }
        });
        socket.addEventListener('message', function(e) {
            var response = JSON.parse(e.data);
            switch(response.status) {
                case 'SUCCESS':
                    if(pendingSignatures[response.key] != undefined) {
                        pendingSignatures[response.key](response.message);
                    }
                    break;
                case 'ERROR':
                    document.getElementById('digitalSignatureStatus_' + response.key).innerHTML = '<img src="../libs/dynicons/?img=dialog-error.svg&w=32" style="vertical-align: middle" alt="Error icon" /> ' + response.message
                        + '<br />Please refresh the page and try again.';
                    break;
                default:
                    console.log('Full response: ');
                    console.log(response);
                    break;
            }
        });
    }
    function sendData(key, dataToSign) {
        console.log('sendData begin');
        socket.send(JSON.stringify({'key': key,
            'dataToSign': dataToSign}));
        console.log('sendData end');
    }
    var sign = function (key, dataToSign, onSuccess) {
        connect(function() {
            sendData(key, dataToSign);
            pendingSignatures[key] = onSuccess;
        });
    };
    return {
        sign: sign
    };
} ();