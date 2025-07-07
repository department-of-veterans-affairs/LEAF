/************************
    Dialog Controller
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 25, 2012

*/

function dialogController(containerID, contentID, indicatorID, btnSaveID, btnCancelID) {
	this.containerID = containerID;
	this.contentID = contentID;
	this.indicatorID = indicatorID;
	this.btnSaveID = btnSaveID;
	this.btnCancelID = btnCancelID;
	this.dialogControllerXhrEvent = null;
	this.prefixID = 'dialog' + Math.floor(Math.random()*1000) + '_';
	this.validators = new Object();
	this.validatorErrors = new Object();
	this.validatorOks = new Object();
	this.invalid = 0;

	//calculate min width of dialog based on min width of content div
	var minWidth = parseInt($('#' + this.contentID).css('min-width'));
	minWidth = (minWidth == 0) ? 0 : (minWidth + 30);

	$('#' + this.containerID).dialog({autoOpen: false,
										modal: true,
										height: 'auto',
										width: 'auto',
										minWidth: minWidth});
	this.clearDialog();
    var t = this;

    // xhrDialog controls
    $('#' + this.btnCancelID).on('click', function() {
    	t.hide();
    });
    $('button.ui-dialog-titlebar-close').on('click', function() {
        t.hide();
    });
	
    const preventCloseOnEnter = (e) => {
        if(e?.keyCode === 13 && (e?.target?.nodeName || '').toLowerCase() === "input" && e?.target?.type !== 'color') {
            e.preventDefault();
        }
    }
    $(`#${t.contentID}`).on('keydown', preventCloseOnEnter);
}

dialogController.prototype.clearDialog = function() {
	$('#' + this.contentID).empty();
	$('#' + this.containerID).dialog('option', 'title', 'Org. Chart Editor');
	$('#' + this.btnSaveID).off();
};

dialogController.prototype.setTitle = function(title) {
	$('#' + this.containerID).dialog('option', 'title', title);
};

dialogController.prototype.hide = function() {
	$('#' + this.containerID).dialog('close');
    this.clearDialog();
};

dialogController.prototype.show = function() {
    //Stack clear for some events.  This helps ensure modal content is mounted before trying to set styles.
    setTimeout(() => {
        if($('#' + this.contentID).html() == '') {
            $('#' + this.loadIndicatorID).css('visibility', 'visible');
        }
        $('#' + this.containerID).dialog('open');
        $('#' + this.containerID).css('visibility', 'visible');
    });
};

dialogController.prototype.setContent = function(content) {
    this.clearValidators();
	$('#' + this.contentID).empty().html(content);
	$('#' + this.indicatorID).css('visibility', 'hidden');
};

dialogController.prototype.indicateBusy = function() {
	$('#' + this.indicatorID).css('visibility', 'visible');
};

dialogController.prototype.indicateIdle = function(content) {
	$('#' + this.indicatorID).css('visibility', 'hidden');
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

dialogController.prototype.setSaveHandler = function(funct) {
	$('#' + this.btnSaveID).off();
	var t = this;
    this.dialogControllerXhrEvent = $('#' + this.btnSaveID).on('click', function() {
        if(t.isValid() == 1) {        	
        	funct();
        }
    });
};

dialogController.prototype.setCancelHandler = function(funct) {
	$('#' + this.containerID).off();

	$('#' + this.containerID).on('dialogclose', function() {
        funct();
    });
};

dialogController.prototype.setJqueryButtons = function(buttons) {
	$('#' + this.containerID).dialog('option', 'buttons', buttons);
};

dialogController.prototype.clickSave = function() {
	$('#' + this.btnSaveID).click();
};

dialogController.prototype.setValidator = function(id, func) {
	this.validators[id] = func;
};

dialogController.prototype.clearValidators = function() {
	this.validators = new Object();
	this.validatorErrors = new Object();
};

dialogController.prototype.setValidatorError = function(id, func) {
	this.validatorErrors[id] = func;
};

dialogController.prototype.setValidatorOk = function(id, func) {
	this.validatorOks[id] = func;
};