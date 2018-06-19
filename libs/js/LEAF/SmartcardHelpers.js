var Signer = function() {

    sign = function(dataToSign, resultsHandler, errorHandler) {
        // showLoader();
        window.open("../../websocket_digital_signature.jnlp");
        var wsEndpoint = 'ws://localhost:8765/websockets/sign';
        if (!(resultsHandler instanceof Function))
            throw 'The sign parameter must be a function';
        var signService = new WebSocket(wsEndpoint);
        signService.onmessage = function(event) {
            var dataJson = event.data.toString();
            if (dataJson.error != null && dataJson.match('^ERROR'))
                errorHandler(dataJson.error);
            else {
                resultsHandler(dataJson);
            }
            signService.close();
        }.bind(this);
        signService.onopen = function() {
            signService.send(dataToSign);
        }.bind(this);
        signService.onclose = function() {
            console.log('Connection closed');
        }.bind(this);
        signService.onerror = function() {
            var errorMessage = 'Connection error: the digital signing service can not be reached.';
            alert(errorMessage);
            throw errorMessage;
        }.bind(this);
        return this;
    };

    showLoader = function() {
        var overlay = document.createElement("div");
        var loaderDiv = document.createElement("div");
        var loader = document.createAttribute("class");
        loader.value = "loader";
        loaderDiv.setAttributeNode(loader);
        overlay.appendChild(loaderDiv);
        document.body.appendChild(overlay);
    };

    hideLoader = function() {
        document.getElementById("overlay").style.display = "none";
    };

    return {
        sign: sign
    };
} ();