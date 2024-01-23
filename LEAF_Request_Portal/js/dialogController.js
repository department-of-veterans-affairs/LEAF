/************************
    Dialog Controller

*/

function dialogController(containerID, contentID, loadIndicatorID, btnSaveID, btnCancelID) {
	this.containerID = containerID;
	this.contentID = contentID;
	this.loadIndicatorID = loadIndicatorID;
	this.btnSaveID = btnSaveID;
	this.btnCancelID = btnCancelID;
	this.dialogControllerXhrEvent = null;
	this.prefixID = 'dialog' + Math.floor(Math.random()*1000) + '_';
	this.validators = {};
	this.validatorSubmitErrors = {};
	this.validatorErrors = {};
	this.validatorOks = {};
	this.requirements = {};
	this.requirementSubmitErrors = {};
	this.requirementErrors = {};
	this.requirementOks = {};
	this.invalid = 0;
	this.incomplete = 0;

	//calculate min width of dialog based on min width of content div
	let minWidth = parseInt($('#' + this.contentID).css('min-width'));
	minWidth = (minWidth == 0) ? 0 : (minWidth + 30);

	$('#' + this.containerID).dialog({autoOpen: false,
										modal: true,
										height: 'auto',
										width: 'auto',
										resizable: false,
										minWidth: minWidth});
	this.clearDialog();
    let t = this;

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
    };
    $(`#${t.contentID}`).on('keydown', preventCloseOnEnter);
}

dialogController.prototype.clear = function() {
	this.clearDialog();
};

dialogController.prototype.clearDialog = function() {
	$('#' + this.contentID).empty();
	$('#' + this.containerID).dialog('option', 'title', 'Editor');
	$('#' + this.btnSaveID).off();
	this.clearValidators();
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
	this.indicateIdle();
};

dialogController.prototype.indicateBusy = function() {
    $('#' + this.loadIndicatorID).css('visibility', 'visible');
    $('#' + this.loadIndicatorID).css('height', 'auto');
    $('#' + this.btnSaveID).css('visibility', 'hidden');
};

dialogController.prototype.indicateIdle = function() {
    $('#' + this.loadIndicatorID).css('visibility', 'hidden');
    $('#' + this.loadIndicatorID).css('height', '1px');
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
	let t = this;
	$('.mainform').on('change', function() {
		t.isComplete();
		t.isValid();
	});
};

dialogController.prototype.isValid = function(isSubmit) {
	isSubmit = isSubmit || false;
	this.invalid = 0;
	for(let item in this.validators) {
    	if(!this.validators[item]()) {
    		this.invalid = 1;
    		if (isSubmit === false) {
				if (this.validatorErrors[item] != undefined) {
					this.validatorErrors[item]();
				} else {
					alert('Data entry error. Please check your input.');
				}
			} else {
				if (this.validatorSubmitErrors[item] != undefined) {
					this.validatorSubmitErrors[item]();
				} else {
					alert('Data entry error. Please check your input.');
				}
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

dialogController.prototype.isComplete = function(isSubmit) {
	isSubmit = isSubmit || false;
	this.incomplete = 0;
	for(let item in this.requirements) {
    	if(this.requirements[item]()) {
    		this.incomplete = 1;
    		if (isSubmit === false) {
				if (this.requirementErrors[item] != undefined) {
					this.requirementErrors[item]();
				} else {
					alert('Required field missing. Please check your input.');
				}
			} else {
				if (this.requirementSubmitErrors[item] != undefined) {
					this.requirementSubmitErrors[item]();
                    if (this.requirementErrors[item] != undefined) {
                        this.requirementErrors[item]();
                    }
				} else {
					alert('Required field missing. Please check your input.');
				}
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
	let t = this;
    this.dialogControllerXhrEvent = $('#' + this.btnSaveID).on('click', function() {
        if(t.isValid(true) == 1 && t.isComplete(true) == 1) {
        	funct();
        	$('#' + t.btnSaveID).off();
        }
        else {
        	t.indicateIdle();
        }
    });
};

dialogController.prototype.setCancelHandler = function(funct) {
	$('#' + this.containerID).off('dialogbeforeclose');
	let t = this;
    $('#' + this.containerID).on('dialogbeforeclose', function() {
        if(t.isValid() == 1 && t.isComplete() == 1) {        	
        	funct();
        	$('#' + this.containerID).off('dialogbeforeclose');
        }
        else {
        	t.indicateIdle();
        }
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
	this.validators = {};
	this.validatorErrors = {};
	this.requirements = {};
	this.requirementErrors = {};
	$('input[type="text"]').off();
};

dialogController.prototype.setSubmitValid = function(id, func) {
	this.validatorSubmitErrors[id] = func;
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

dialogController.prototype.setSubmitError = function(id, func) {
	this.requirementSubmitErrors[id] = func;
};

dialogController.prototype.setRequiredError = function(id, func) {
	this.requirementErrors[id] = func;
};

dialogController.prototype.setRequiredOk = function(id, func) {
	this.requirementOks[id] = func;
};
