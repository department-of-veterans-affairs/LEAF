/************************
    Form editor
*/
var form;
var formValidator = {};
var LeafForm = function(containerID) {
	var containerID = containerID;
	var prefixID = 'LeafForm' + Math.floor(Math.random()*1000) + '_';
	var htmlFormID = prefixID + 'record';
	var dialog;
	var recordID = 0;
	var postModifyCallback;

	$('#' + containerID).html('<div id="'+prefixID+'xhrDialog" style="display: none; background-color: white; border-style: none solid solid; border-width: 0 1px 1px; border-color: #e0e0e0; padding: 4px">\
			<form id="'+prefixID+'record" enctype="multipart/form-data" action="javascript:void(0);">\
			    <div>\
			        <button id="'+prefixID+'button_cancelchange" class="buttonNorm" style="position: absolute; left: 10px"><img src="../libs/dynicons/?img=process-stop.svg&amp;w=16" alt="cancel" /> Cancel</button>\
			        <button id="'+prefixID+'button_save" class="buttonNorm" style="position: absolute; right: 10px"><img src="../libs/dynicons/?img=media-floppy.svg&amp;w=16" alt="save" /> Save Change</button>\
			        <div style="border-bottom: 2px solid black; line-height: 30px"><br /></div>\
			        <div id="'+prefixID+'loadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 300px; width: 460px">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>\
			        <div id="'+prefixID+'xhr" style="width: 540px; height: 420px; padding: 8px; overflow: auto"></div>\
			    </div>\
			</form>\
			</div>');
	dialog = new dialogController(prefixID+'xhrDialog', prefixID+'xhr', prefixID+'loadIndicator', prefixID+'button_save', prefixID+'button_cancelchange');

	function setRecordID(id) {
		recordID = id;
	}
	
	function setPostModifyCallback(func) {
		postModifyCallback = func;
	}

	function doModify() {
		if(recordID == 0) {
			console.log('recordID not set');
			return 0;
		}
		var temp = $('#' + dialog.btnSaveID).html();
		$('#' + dialog.btnSaveID).empty().html('<img src="images/indicator.gif" alt="saving" /> Saving...');

		$('#' + htmlFormID).find(':input:disabled').removeAttr('disabled');

		var data = {recordID: recordID};
		$('#' + htmlFormID).serializeArray().map(function(x){data[x.name] = x.value;}); 

	    $.ajax({
	        type: 'POST',
	        url: 'ajaxIndex.php?a=domodify',
	        data: data,
	        dataType: 'text',
	        success: function(res) {
	        	if(postModifyCallback != undefined) {
	        		postModifyCallback();
	        	}
	            $('#' + dialog.btnSaveID).empty().html(temp);
	        },
	        cache: false
	    });
	}

	function checkSignature(indicatorID, series) {
		$.ajax({
			type: 'GET',
			url: "./api/?a=signature/" + recordID,
			success: function(res) {
				if(res.length > 0) {
					{
                        var dialog_confirm_sig = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
                        dialog.hide();
                        dialog_confirm_sig.setTitle('Warning');
                        dialog_confirm_sig.setContent('Editing this form will invalidate all signatures associated with it.  Are you sure you want to edit it?');
                        dialog_confirm_sig.setSaveHandler(function() {
                            dialog_confirm_sig.hide();
                            dialog.show();
                            dialog.indicateBusy();
                            getEditWindow(indicatorID, series)
                        });
                        dialog_confirm_sig.show();
                    }
				}
				else
				{
                    getEditWindow(indicatorID, series);
				}
			}
		})
	}

	function getEditWindow(indicatorID, series) {
        dialog.setSaveHandler(function() {
            doModify();
        });

        formValidator = new Object();
        formRequired = new Object();
        $.ajax({
            type: 'GET',
            url: "ajaxIndex.php?a=getindicator&recordID=" + recordID + "&indicatorID=" + indicatorID + "&series=" + series,
            dataType: 'text',
            success: function(response) {
                dialog.setTitle('Editing #' + recordID);
                dialog.setContent(response);

                for(var i in formValidator) {
                    var tID = i.slice(2);
                    dialog.setValidator(tID, formValidator[i].setValidator);
                    dialog.setValidatorError(tID, formValidator[i].setValidatorError);
                    dialog.setValidatorOk(tID, formValidator[i].setValidatorOk);
                }

                for(var i in formRequired) {
                    var tID = i.slice(2);
                    dialog.setRequired(tID, formRequired[i].setRequired);
                    dialog.setRequiredError(tID, formRequired[i].setRequiredError);
                    dialog.setRequiredOk(tID, formRequired[i].setRequiredOk);
                }

                dialog.enableLiveValidation();
            },
            error: function(response) {
                dialog.setContent("Error: " + response);
            },
            cache: false
        });
	}

	function getForm(indicatorID, series) {
		if(recordID == 0) {
			console.log('recordID not set');
			return 0;
		}
		checkSignature(indicatorID, series);
	}

	function initCustom(containerID, contentID, indicatorID, btnSaveID, btnCancelID) {
		dialog = new dialogController(containerID, contentID, indicatorID, btnSaveID, btnCancelID);
		prefixID = '';
		htmlFormID = 'record';
	}

	function setHtmlFormID(id) {
		htmlFormID = id;
	}

	return {
		dialog: function() { return dialog; },
		getHtmlFormID: function() { return htmlFormID; },
		serializeData: function() { return $('#' + htmlFormID).serialize(); },

		setRecordID: setRecordID,
		setPostModifyCallback: setPostModifyCallback,
		doModify: doModify,
		getForm: getForm,
		initCustom: initCustom,
		setHtmlFormID: setHtmlFormID
	}
};
