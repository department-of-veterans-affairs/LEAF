var Signer = function() {

    var isConnected = false;
    var pendingSignatures = {}; // callbacks
    var initiatedJNLP = false;
    var socket = null;

    function connect(_callback) {
        socket = new SockJS('https://localhost:8443');

        socket.onopen = function() {
            isConnected = true;
            if(typeof _callback == 'function') {
                _callback();
            }
        };

        socket.onclose = function() {
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
        };

        socket.onmessage = function(e) {
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
        };
    }

    function sendData(key, dataToSign) {
        socket.send(JSON.stringify({'key': key,
                                    'dataToSign': dataToSign}));
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