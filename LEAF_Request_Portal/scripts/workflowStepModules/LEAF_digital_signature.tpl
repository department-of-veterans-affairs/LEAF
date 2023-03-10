workflowStepModule[{{$stepID}}] = workflowStepModule[{{$stepID}}] || {};
workflowStepModule[{{$stepID}}]['LEAF_digital_signature'] = (function() {
	var prefixID = 'workflowStepModule' + Math.floor(Math.random()*1000) + '_';
	var step;

	function setupButtonAction() {
		workflow.setActionPreconditionFunc(function(data, completeAction) {
			var currRecordID = data.step.recordID;
			if (step.requiresDigitalSignature == 1
				&& data.step.dependencyActions[data.idx].fillDependency > 0) { // dont require signature for regressive actions
				if (LEAFRequestPortalAPI !== undefined) {
					var key = currRecordID + '_' + Math.floor(Math.random()*1000);
					$('#form_dep'+ step.dependencyID).slideUp();    // UI hint for loading
					$(document.createElement('div'))
					.css({'margin': 'auto',
						'width': '95%',
						'padding-bottom': '16px',
						'font-size': '14px',
						'text-align': 'center'})
					.html("<img src='images/largespinner.gif' alt='Loading Digital Signature (Beta) Routines' title='Loading Digital Signature (Beta) Routines'' style='vertical-align: middle'> Loading Digital Signature (Beta) Routines...")
					.attr('id', 'digitalSignatureStatus_' + key)
					.appendTo('#workflowbox_dep' + step.dependencyID);

					var portalAPI = LEAFRequestPortalAPI();
					portalAPI.setCSRFToken(CSRFToken);

					portalAPI.Forms.getJSONForSigning(
						currRecordID,
						function (json) {
							var jsonStr = JSON.stringify(json);
							Signer.sign(key, jsonStr, function (signedData, signerPublicKey) {
								portalAPI.Signature.create(
									signedData,
									currRecordID,
									step.stepID,
									step.dependencyID,
                                    jsonStr,
                                    signerPublicKey,
									function (id) {
										completeAction();
									},
									function (err) {
										console.log(err);
									}
								);

							}, function (err) {
								// TODO: display error message to user
								console.log(err);
							});

						},
						function (err) {
							console.log(err);
						}
					);

				}
			} else {
				completeAction();
			}
		});
	}

	function init(currStep) {
		step = currStep;
		$(document.createElement('div'))
		.css({'margin': 'auto',
			  'width': '95%',
			  'text-align': 'center'})
		.html("<br style='clear: both' /><img src='dynicons/?img=application-certificate.svg&w=24' alt='Digital Signature (Beta) Enabled' title='Digital Signature (Beta) Enabled' style='vertical-align: middle'> Digital Signature (Beta) Enabled")
		.appendTo('#form_dep' + step.dependencyID);

		if(typeof Signer == 'undefined') {
			alert("Digital Signature is not available.");
		}

		setupButtonAction();
	}

	// placeholder
	function trigger(callback) {

	}

	return {
		init: init,
//		trigger: trigger
	};
})();
