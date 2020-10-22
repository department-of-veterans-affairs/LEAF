/************************
    Dialog Controller

*/

function dialogController(containerID, contentID, indicatorID, btnSaveID, btnCancelID) {
    this.containerID = containerID;
    this.contentID = contentID;
    this.indicatorID = indicatorID;
    this.btnSaveID = btnSaveID;
    this.btnCancelID = btnCancelID;
    this.dialogControllerXhrEvent = null;
    this.prefixID = 'dialog' + Math.floor(Math.random()*1000) + '_';
    this.validators = {};
    this.validatorErrors = {};
    this.validatorOks = {};
    this.requirements = {};
    this.requirementErrors = {};
    this.requirementOks = {};
    this.invalid = 0;
    this.incomplete = 0;

    //calculate min width of dialog based on min width of content div
    var minWidth = parseInt($('#' + this.contentID).css('min-width'));
    minWidth = (minWidth == 0) ? 0 : (minWidth + 30);

    var VueJSModal = window['vue-js-modal'].default;

    Vue.use(VueJSModal);

    this.app = new Vue({
        el: "#" + containerID,
        data: {
            title: 'Editor',
            content: '',
            minWidth: minWidth,
            height: 'auto',
            dialogControllerXhrEvent: null
        },
        methods: {
            show() {
                this.$modal.show(containerID);
            },
            hide () {
                this.title = 'Editor';
                this.$modal.hide(containerID);
            },
            clickSave () {
                this.dialogControllerXhrEvent();
            }
        },
        mount () {
            this.show();
        }
    });

    this.clearDialog();

    // xhrDialog controls
    $('#' + this.btnCancelID).on('click', function() {
        this.app.hide();
    });

}

dialogController.prototype.clear = function() {
    this.clearDialog();
};

dialogController.prototype.clearDialog = function() {
    this.app.content = '';
    this.app.title = 'Editor';
    $('#' + this.btnSaveID).off();
    this.clearValidators();
};

dialogController.prototype.setTitle = function(title) {
    this.app.title = title;
};

dialogController.prototype.hide = function() {
    this.app.hide();
    this.clearDialog();
};

dialogController.prototype.show = function() {
    if(this.app.content == '') {
        $('#' + this.indicatorID).css('visibility', 'visible');
    }
    this.app.show();
};

dialogController.prototype.setContent = function(content) {
    this.clearValidators();
    this.app.content = content;
    this.indicateIdle();
};

dialogController.prototype.indicateBusy = function() {
    $('#' + this.indicatorID).css('visibility', 'visible');
    $('#' + this.btnSaveID).css('visibility', 'hidden');
};

dialogController.prototype.indicateIdle = function() {
    $('#' + this.indicatorID).css('visibility', 'hidden');
    $('#' + this.btnSaveID).css('visibility', 'visible');
};

dialogController.prototype.hideButtons = function() {
    $('#' + this.btnCancelID).css('visibility', 'hidden');
    $('#' + this.btnSaveID).css('visibility', 'hidden');
};

dialogController.prototype.showButtons = function() {
    $('#' + this.btnCancelID).css('visibility', 'visible');
    $('#' + this.btnSaveID).css('visibility', 'visible');
};

dialogController.prototype.enableLiveValidation = function() {
    var t = this;
    $('input[type="text"]').on('keyup', function() {
        t.isValid();
    });
};

dialogController.prototype.isValid = function() {
    this.invalid = 0;
    for(var item in this.validators) {
        if(!this.validators[item]()) {
            console.log('Data entry error on indicator ID: ' + item); // helps identify validator triggers when custom styles hide the normal error UI
            this.invalid = 1;
            if(this.validatorErrors[item] != undefined) {
                this.validatorErrors[item]();
            }
            else {
                alert('Data entry error. Please check your input.');
            }
        }
        else {
            if(this.validatorOks[item] != undefined) {
                this.validatorOks[item]();
            }
        }
    }
    if(this.invalid == 1) {
        return 0;
    }
    return 1;
};

dialogController.prototype.isComplete = function() {
    this.incomplete = 0;
    for(var item in this.requirements) {
        if(this.requirements[item]()) {
            this.incomplete = 1;
            if(this.requirementErrors[item] != undefined) {
                this.requirementErrors[item]();
            }
            else {
                alert('Required field missing. Please check your input.');
            }
        }
        else {
            if(this.requirementOks[item] != undefined) {
                this.requirementOks[item]();
            }
        }
    }
    if(this.incomplete == 1) {
        return 0;
    }
    return 1;
};

dialogController.prototype.setSaveHandler = function(funct) {
    $('#' + this.btnSaveID).off();
    var t = this;
    this.app.dialogControllerXhrEvent = function () {    
        if(t.isValid() == 1 && t.isComplete() == 1) {           
            funct();
            $('#' + t.btnSaveID).off();
        }
        else {
            t.indicateIdle();
        }
    };
};

dialogController.prototype.setCancelHandler = function(funct) {
    $('#' + this.containerID).off('beforeClose');
    var t = this;
    $('#' + this.containerID).on('beforeClose', function() {
        if(t.isValid() == 1 && t.isComplete() == 1) {           
            funct();
            $('#' + this.containerID).off('beforeClose');
        }
        else {
            t.indicateIdle();
        }
    });
};

dialogController.prototype.clickSave = function() {
    this.app.clickSave();
};

dialogController.prototype.setValidator = function(id, func) {
    this.validators[id] = func;
};

dialogController.prototype.clearValidators = function() {
    this.validators = {};
    this.validatorErrors = {};
    this.requirements = {};
    this.requirementErrors = {};
    $('input[type="text"]').off();
};

dialogController.prototype.setValidatorError = function(id, func) {
    this.validatorErrors[id] = func;
};

dialogController.prototype.setValidatorOk = function(id, func) {
    this.validatorOks[id] = func;
};

dialogController.prototype.setRequired = function(id, func) {
    this.requirements[id] = func;
};

dialogController.prototype.setRequiredError = function(id, func) {
    this.requirementErrors[id] = func;
};

dialogController.prototype.setRequiredOk = function(id, func) {
    this.requirementOks[id] = func;
};
