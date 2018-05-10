var Signer = function() {

    sign = function(dataToSign, resultsHandler, errorHandler) {
        showLoader();
        var wsEndpoint = 'ws://127.0.0.1:8765/websockets/sign';
        // var wsEndpoint = 'ws://10.0.2.2:8765/websockets/sign';
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