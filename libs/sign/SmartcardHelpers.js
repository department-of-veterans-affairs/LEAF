var Signer = function() {

    var stompClient = null;

    function connect(_callback) {
        var url = "https://localhost:8443/websocket";
        var socket = new SockJS(url);
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function (frame) {
            console.log('Connected: ' + frame);
            stompClient.subscribe('/wsbroker/controller', function (response) {
                showMessage(JSON.parse(response.body).content);
            });
            _callback();
        });
    }

    function disconnect() {
        stompClient.send("/app/close", {}, "");
    }

    function sendName(dataToSign) {
        stompClient.send("/app/sign", {}, JSON.stringify({'content': dataToSign}));
    }

    function showMessage(message) {
        alert(message);
    }

    var sign = function (dataToSign) {
        connect(function() {
            sendName(dataToSign);
            return dataToSign;
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