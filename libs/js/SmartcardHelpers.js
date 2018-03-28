var signer = {
    _dataToSignList : [],
    _dllList : [],
    _statusLog : [],
    _logHandler : null,

    _log : function(msg){
        this._statusLog.push(msg);
        if(this._logHandler != null)
            this._logHandler(msg);
    },

    setLogHandler : function(handler){
        if(!(handler instanceof Function))
            throw 'The setLogHandler parameter must be a function';
        this._logHandler = handler;
        return this;
    },

    addData : function(id, contentB64){
        this._dataToSignList.push({
            id : id,
            contentB64 : contentB64,
            params : null
        });
        return this;
    },

    addData : function(id, contentB64, params){
        this._dataToSignList.push({
            id : id,
            contentB64 : contentB64,
            params : params
        });
        return this;
    },

    cleanData : function(){
        this._dataToSignList = [];
        return this;
    },

    sign : function(resultsHandler, errorHandler){
        var wsEndpoint = 'ws://127.0.0.1:8765/websockets/sign';
        // var wsEndpoint = 'ws://10.0.2.2:8765/websockets/sign';
        if(!(resultsHandler instanceof Function))
            throw 'The sign parameter must be a function';
        var signService = new WebSocket(wsEndpoint);
        signService.onmessage = function(event){
            this._log('Hex: ' + event.data);
            var dataJson = event.data.toString();
            // alert('dataJson: ' + dataJson);
            // var dataJson = JSON.parse(event.data);
            if(dataJson.error != null)
                errorHandler(dataJson.error);
            else {
                resultsHandler(dataJson);
                // resultsHandler(dataJson.dataSigned);
            }
            signService.close();
        }.bind(this);
        signService.onopen = function(){
            var data = {
                dllList : this._dllList,
                dataToSign : this._dataToSignList
            };
            // var dataS = JSON.stringify(data);
            // signService.send(dataS);
            signService.send(data);
        }.bind(this);
        signService.onclose = function(){
            this._log('Connection closed');
        }.bind(this);
        signService.onerror = function(){
            this._log('Connection error: the WebSocket service ' + wsEndpoint + ' can not be reached.');
            throw 'Connection error: the WebSocket service ' + wsEndpoint + ' can not be reached.';
        }.bind(this);
        return this;
    }
};