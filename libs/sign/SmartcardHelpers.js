var Signer = function() {

    var stompClient = null;
    var isConnected = false;
    var pendingSignatures = {}; // callbacks
    var initiatedJNLP = false;

    function connect(_callback) {
        var url = "https://localhost:8443/websocket";
        var socket = new SockJS(url);
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function (frame) {
            isConnected = true;
            console.log('Connected: ' + frame);
            stompClient.subscribe('/wsbroker/controller', function (response) {
                switch(response.command) {
                    case 'MESSAGE':
                        console.log(JSON.parse(response.body));
                        console.log(Object.keys(pendingSignatures));
                        break;
                    default:
                        console.log(response);
                        break;
                }
            });
            if(_callback != undefined) {
                _callback();
            }
        });
        socket.onclose = function() {
            console.log("Trying to reconnect");
            setTimeout(connect, 1000);
            if(initiatedJNLP == false) {
                if (!isConnected) {
                    initiatedJNLP = true;
                    window.open("../libs/sign/sign.jnlp");
                }
            }
        };

    }

    function disconnect() {
        isConnected = false;
        stompClient.send("/app/close", {}, "");
    }

    function sendData(dataToSign) {
        stompClient.send("/app/sign", {}, JSON.stringify({'content': dataToSign}));
    }

    var sign = function (key, dataToSign, onSuccess) {
        connect(function() {
            sendData(dataToSign);
            pendingSignatures[key] = onSuccess;
        });
    };

    var connection = function () {
        connect();
    };

    var disconnection = function () {
        disconnect();
    };

    return {
        sign: sign,
        connection: connection,
        disconnection: disconnection
    };

} ();