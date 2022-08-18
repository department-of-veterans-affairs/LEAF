/************************
    Form editor
*/
var form;
var formValidator = {};
var formRequired = {};
var formConditions = {};
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
			    	<div id="form-xhr-cancel-save-menu" style="border-bottom: 2px solid black; height: 30px">\
			        	<button id="'+prefixID+'button_cancelchange" class="buttonNorm" ><img src="../libs/dynicons/?img=process-stop.svg&amp;w=16" alt="cancel" /> Cancel</button>\
			        	<button id="'+prefixID+'button_save" class="buttonNorm"><img src="../libs/dynicons/?img=media-floppy.svg&amp;w=16" alt="save" /> Save Change</button>\
			        </div>\
			        <div id="'+prefixID+'loadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 300px; width: 460px">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>\
			        <div id="'+prefixID+'xhr" style="min-width: 540px; min-height: 420px; padding: 8px; overflow: auto"></div>\
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

	function sanitize(input){
		input = input.replace(/&/g, '&amp;');
        input = input.replace(/</g, '&lt;');
        input = input.replace(/>/g, '&gt;');
        input = input.replace(/"/g, '&quot;');
        input = input.replace(/'/g, '&#039;');
		return input;
	}

	
	function handleConditionalIndicators(formConditions) {
		const allowedChildFormats = ['dropdown', 'text'];
		const formConditionsByChild = formConditions;
		let currentChildInfo = {};
		
		const checkConditions = (event, selected, parID=0)=> {
			const parentElID = event !== null ? event.target.id : parID;

			const linkedParentConditions = getConditionsLinkedToParent(parentElID);
			let uniqueChildIDs = linkedParentConditions.map(c => c.childIndID);
			uniqueChildIDs = Array.from(new Set(uniqueChildIDs));

			let linkedChildConditions = [];
			uniqueChildIDs.forEach(id => {
				linkedChildConditions.push(...getConditionsLinkedToChild(id, parentElID));
			});

			const allConditions = [...linkedParentConditions, ...linkedChildConditions];

			const conditionsByChild = {}
			allConditions.map(c => {
				conditionsByChild[c.childIndID] ? conditionsByChild[c.childIndID].push(c) : conditionsByChild[c.childIndID] = [c];
			})

			for (let childID in conditionsByChild) {
				makeComparisons(childID, conditionsByChild[childID]);
			}
		}

		const getConditionsLinkedToParent = (parentID)=> {
			let conditionsLinkedToParent = [];
			for (let entry in formConditionsByChild) {
				const formConditions = formConditionsByChild[entry].conditions || [];
				formConditions.forEach(c => {
					const formatIsEnabled = allowedChildFormats.some(f => f === c.childFormat);
					//do not include conditions if the recorded condition format (condition.childFormat) does not
					//match the current format, as this would have unpredictable results
					if (formConditionsByChild[entry].format === c.childFormat && 
						formatIsEnabled &&
						c.parentIndID === parentID) {
						conditionsLinkedToParent.push({...c});
					}
				})
			}
			return conditionsLinkedToParent;
		}
		const getConditionsLinkedToChild = (childID, currParentID)=> {
			let conditionsLinkedToChild = [];
			for (let entry in formConditionsByChild) {
				if (entry.slice(2) === childID) {
					const formConditions = formConditionsByChild[entry].conditions || [];
					formConditions.map(c => {
						const formatIsEnabled = allowedChildFormats.some(f => f === c.childFormat);
						if (formConditionsByChild[entry].format === c.childFormat && 
							formatIsEnabled &&
							currParentID !== c.parentIndID) {
							conditionsLinkedToChild.push({...c});
						}
					});
				}
			}
			return conditionsLinkedToChild;
		}
		//use as ref for comparisons so that the validators can be reset
		const hideShowValidator = function(){return false};


		const handleChildValidators = (childID)=> {
			if (!currentChildInfo[childID]) { //if it is new define key and store validator
				currentChildInfo[childID] = {
					validator: form.dialog().requirements[childID]
				}
			} 
			//reset the validator if there is one from the stored value
			if (currentChildInfo[childID].validator !== undefined) {
				form.dialog().requirements[childID] = currentChildInfo[childID].validator;
			}
		}

		//conditions to assess per child
		const makeComparisons = (childID, arrConditions)=> {
			let prefillValue = '';
			const elJQChildID = $('#' + childID);
			
			handleChildValidators(childID);

			arrConditions.forEach(cond => {
				const chosenShouldUpdate = cond.childFormat === 'dropdown';
				let comparisonResult = false;

				let arrCompVals = [];
				arrConditions.map(c => {
					if (cond.selectedOutcome === c.selectedOutcome &&
						((cond.selectedOutcome === "Pre-fill" && cond.selectedChildValue === c.selectedChildValue) ||
						cond.selectedOutcome !== "Pre-fill"
						)
					) arrCompVals.push({[c.parentIndID]:c.selectedParentValue});
				});

				switch (cond.selectedOp) {
					case '==':
						arrCompVals.forEach(entry => {
							let id = Object.keys(entry)[0];
							let val = document.getElementById(id).value;
							if (sanitize(val) === entry[id]) {
								comparisonResult = true;
								if (cond.selectedOutcome === "Pre-fill") {
									prefillValue = cond.selectedChildValue;
								}
							}
						});
						break;
					case '!=':  //TODO: SOME or EVERY?
						arrCompVals.forEach(entry => {
							let id = Object.keys(entry)[0];
							let val = document.getElementById(id).value;
							if (sanitize(val) !== entry[id]) {
								comparisonResult = true;
							}
						});
						break;
					case '>':  
						//comparisonResult = arrCompVals.some(v => v > sanitize(val));
						break;
					case '<':
						//comparisonResult = arrCompVals.some(v => v < sanitize(val));
						break;
					default:
						console.log(cond.selectedOp);
						break;
				}

				//update child states and/or values
				switch (cond.selectedOutcome) {
					case 'Hide':
						if (comparisonResult === true) {
							elJQChildID.val('');
							if (chosenShouldUpdate) {
								elJQChildID.chosen().val('');
								elJQChildID.trigger('chosen:updated');
							}
							//if this is a required question, re-point validator
							$('.blockIndicator_' + childID).hide();
							if (currentChildInfo[childID].validator !== undefined) {
								form.dialog().requirements[childID] = hideShowValidator;
							}
						} else {
							$('.blockIndicator_' + childID).show();
						}
						break;
					case 'Show':
						if (comparisonResult === true) {
							$('.blockIndicator_' + childID).show();
						} else {
							elJQChildID.val('');
							if (chosenShouldUpdate) {
								elJQChildID.chosen().val('');
								elJQChildID.trigger('chosen:updated');
							}
							$('.blockIndicator_' + childID).hide();
							if (currentChildInfo[childID].validator !== undefined) {
								form.dialog().requirements[childID] = hideShowValidator;
							}
						}
						break;
					case 'Pre-fill':
						if (prefillValue !== '') {
							const text = $('<div/>').html(prefillValue).text();
							elJQChildID.val(text);
							elJQChildID.attr('disabled', 'disabled');
							if (chosenShouldUpdate) {
								elJQChildID.chosen().val(text);
								elJQChildID.trigger('chosen:updated');
							}
						} else {
							elJQChildID.removeAttr('disabled');
							elJQChildID.val('');
							if (chosenShouldUpdate) {
								elJQChildID.chosen().val('');
								elJQChildID.trigger('chosen:updated');
							}
						}
						break; 
					default:
						console.log(cond.selectedOutcome);
						break;
				} 
			});
		}

		//get the IDs of the questions that need listeners
		let parentQuestionIDs = [];
		for (let entry in formConditionsByChild) {
			const formConditions = formConditionsByChild[entry].conditions || [];
			formConditions.forEach(c => {
				parentQuestionIDs.push(c.parentIndID);
			});
		}
		parentQuestionIDs = Array.from(new Set(parentQuestionIDs));
		parentQuestionIDs.forEach(id => {
			checkConditions(null, null, id);
			$('#'+id).on('change', checkConditions); //does not call with addEventListener (Chosen plugin?)
		});
		
	}

	function doModify() {
		if(recordID == 0) {
			console.log('recordID not set');
			return 0;
		}

		var hasTable = $('#' + htmlFormID).find('.tableinput').length !== 0;
		var temp = $('#' + dialog.btnSaveID).html();
		$('#' + dialog.btnSaveID).empty().html('<img src="images/indicator.gif" alt="saving" /> Saving...');

		$('#' + htmlFormID).find(':input:disabled').removeAttr('disabled');

		var data = {recordID: recordID};
		$('#' + htmlFormID).serializeArray().map(function(x){data[x.name] = x.value;});

		if(hasTable){
            var tables = [];

			$('#' + htmlFormID).find('.tableinput > table').each(function(index) {
				var gridObject = {};
                gridObject.cells = [];
                gridObject.names = [];

                // determines the order of the column values
                gridObject.columns = [];

                $('thead', this).find('td').slice(0, -1).each(function() {
                    gridObject.names.push($(this).text());
                    gridObject.columns.push($('div', this).attr('id'));
				});

				$('tbody', this).find('tr').each(function(){
                    var cellArr = [];
					$(this).children('td').each(function() {
                        if($('textarea', this).length) {
                            cellArr.push($(this).find('textarea').val());
                        } else if($('select', this).length){
                            cellArr.push($("option:selected", this).val());
						} else if($('input', this).length) {
                            cellArr.push($("input", this).val());
                        }
                    });
                    gridObject.cells.push(cellArr);
				});
				tables[index] = {
					id: $(this).attr('id').split('_')[1],
					data: gridObject,
				};
            });

            $('#' + htmlFormID).serializeArray().map(function(){
            	for(var i = 0; i < tables.length; i++){
                    data[tables[i].id] = tables[i].data;
                }
            });
		}

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

	function getForm(indicatorID, series) {
		if(recordID == 0) {
			console.log('recordID not set');
			return 0;
		}
	    dialog.indicateBusy();

	    dialog.setSaveHandler(function() {
	    	doModify();
	    });

	    formValidator = new Object();
	    formRequired = new Object();
	    formConditions = new Object();
	    $.ajax({
	        type: 'GET',
	        url: "ajaxIndex.php?a=getindicator&recordID=" + recordID + "&indicatorID=" + indicatorID + "&series=" + series,
	        dataType: 'text',
	        success: function(response) {
	        	dialog.setTitle('Editing #' + recordID);
	            dialog.setContent(response);

	            for(let i in formValidator) {
	            	let tID = i.slice(2);
	            	dialog.setValidator(tID, formValidator[i].setValidator);
	            	dialog.setSubmitValid(tID, formValidator[i].setSubmitValid);
	                dialog.setValidatorError(tID, formValidator[i].setValidatorError);
	                dialog.setValidatorOk(tID, formValidator[i].setValidatorOk);
	            }

	            for(let i in formRequired) {
	            	let tID = i.slice(2);
	            	dialog.setRequired(tID, formRequired[i].setRequired);
					dialog.setSubmitError(tID, formRequired[i].setSubmitError);
	            	dialog.setRequiredError(tID, formRequired[i].setRequiredError);
	            	dialog.setRequiredOk(tID, formRequired[i].setRequiredOk);
	            }

	            dialog.enableLiveValidation();

				//for (let c in formConditions) {
					handleConditionalIndicators(formConditions); //[c]
				//}
				
	        },
	        error: function(response) {
	        	dialog.setContent("Error: " + response);
	        },
	        cache: false
	    });
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