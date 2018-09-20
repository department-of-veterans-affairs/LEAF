var Signer = function() {

    var stompClient = null;
    var isConnected = false;

    function connect(_callback) {
        var url = "https://localhost:8443/websocket";
        var socket = new SockJS(url);
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function (frame) {
            isConnected = true;
            console.log('Connected: ' + frame);
            stompClient.subscribe('/wsbroker/controller', function (response) {
                showMessage(JSON.parse(response.body).content);
            });
            if(_callback != undefined) {
                _callback();
            }
        });
        socket.onclose = function() {
            console.log("Trying to reconnect");
            setTimeout(connect, 1000);
        };

    }

    function disconnect() {
        isConnected = false;
        stompClient.send("/app/close", {}, "");
    }

    function sendData(dataToSign) {
        stompClient.send("/app/sign", {}, JSON.stringify({'content': dataToSign}));
    }

    function showMessage(message) {
        alert(message);
    }

    var sign = function (dataToSign, onSuccess) {
        connect(function() {
            sendData(dataToSign);
            onSuccess('signature hash needs to go here');
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