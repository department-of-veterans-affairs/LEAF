var Signer = function() {

    var stompClient = null;

    function connect() {
        var url = "https://localhost:8443/websocket";
        var socket = new SockJS(url);
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function (frame) {
            console.log('Connected: ' + frame);
            stompClient.subscribe('/topic/greetings', function (response) {
                showMessage(JSON.parse(response.body).content);
            });
        });
    }

    function disconnect() {
        if (stompClient !== null) {
            stompClient.disconnect();
        }
        console.log("Disconnected");
    }

    function sendName(dataToSign) {
        stompClient.send("/app/sign", {}, JSON.stringify({'content': dataToSign}));
    }

    function showMessage(message) {
        alert(message);
    }

    var sign = function (dataToSign) {
        sendName(dataToSign);
        return dataToSign;
    };

    var connection = function () {
        connect();
    };

    return {
        sign: sign,
        connection: connection
    };

} ();