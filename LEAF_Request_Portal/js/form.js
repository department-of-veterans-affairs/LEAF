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

    function sanitize(input=''){
        input = input.replace(/&/g, '&amp;');
        input = input.replace(/</g, '&lt;');
        input = input.replace(/>/g, '&gt;');
        input = input.replace(/"/g, '&quot;');
        input = input.replace(/'/g, '&#039;');
        return input;
    }

    
    function handleConditionalIndicators(formConditionsByChild = {}, dialog = null) {
        const allowedChildFormats = ['dropdown', 'text', 'multiselect', 'radio'];

        let childRequiredValidators = {};
        const handleChildValidators = (childID)=> {
            if (!childRequiredValidators[childID]) {
                childRequiredValidators[childID] = {
                    validator: formRequired[`id${childID}`]?.setRequired
                }
            }
            //reset the validator, if there is one, from the stored value
            if (childRequiredValidators[childID].validator !== undefined && dialog !== null) {
                dialog.requirements[childID] = childRequiredValidators[childID].validator;
            }
        }
        //validator ref for required question in a hidden state
        const hideShowValidator = function(){return false};

        const checkConditions = (event, selected, parID=0)=> {
            const parentElID = event !== null ? parseInt(event.target.id) : parseInt(parID);

            const linkedParentConditions = getConditionsLinkedToParent(parentElID); //get all children directly controlled by this parent, and their ids
            let uniqueChildIDs = linkedParentConditions.map(c => parseInt(c.childIndID));
            uniqueChildIDs = Array.from(new Set(uniqueChildIDs));

            let linkedChildConditions = [];
            uniqueChildIDs.forEach(id => {
                linkedChildConditions.push(...getConditionsLinkedToChild(id, parentElID)); //get all other possible parents controlling the above children
            });

            const allConditions = [...linkedParentConditions, ...linkedChildConditions];

            const conditionsByChild = {}
            allConditions.map(c => {
                conditionsByChild[c.childIndID] ? conditionsByChild[c.childIndID].push(c) : conditionsByChild[c.childIndID] = [c];
            })

            setTimeout(() => {  //some multiselect updates don't work unless the stack is cleared
                for (let childID in conditionsByChild) {
                    makeComparisons(childID, conditionsByChild[childID]);
                }
            }, 0);
        }
        /**
         *
         * @param {number} parentID
         * @returns array of conditions that have the given value for their parentIndID
         */
        const getConditionsLinkedToParent = (parentID=0)=> {
            let conditionsLinkedToParent = [];
            for (let entry in formConditionsByChild) {
                const formConditions = formConditionsByChild[entry].conditions || [];
                formConditions.forEach(c => {
                    const formatIsEnabled = allowedChildFormats.some(f => f === c.childFormat);
                    //do not include conditions if the recorded condition format (condition.childFormat) does not
                    //match the current format, as this would have unpredictable results
                    if (formConditionsByChild[entry].format === c.childFormat && 
                        formatIsEnabled &&
                        parseInt(c.parentIndID) === parseInt(parentID)) {
                        conditionsLinkedToParent.push({...c});
                    }
                })
            }
            return conditionsLinkedToParent;
        }
        /**
         *
         * @param {number} childID id of a child condition
         * @param {number} currParentID the id of the controller that was updated
         * @returns array of all other parents that control the given child
         */
        const getConditionsLinkedToChild = (childID=0, currParentID=0)=> {
            let conditionsLinkedToChild = [];
            for (let entry in formConditionsByChild) {
                if (parseInt(entry.slice(2)) === parseInt(childID)) {
                    const formConditions = formConditionsByChild[entry].conditions || [];
                    formConditions.map(c => {
                        const formatIsEnabled = allowedChildFormats.some(f => f === c.childFormat);
                        if (formConditionsByChild[entry].format === c.childFormat && 
                            formatIsEnabled &&
                            parseInt(currParentID) !== parseInt(c.parentIndID)) {
                            conditionsLinkedToChild.push({...c});
                        }
                    });
                }
            }
            return conditionsLinkedToChild;
        }

        const valIncludesMultiselOption = (selectedOptions = [], arrOptions = []) => {
            let result = false;
            let vals = selectedOptions.map(sel => sanitize(sel.label.replaceAll('\r', '').trim()));
            
            vals.forEach(v => {
                if (arrOptions.includes(v)) {
                    result = true;
                }
            });
            return result;
        }

        const clearMultiSelectChild = (element, childID) => {
            element[0]?.choicesjs?.removeActiveItems();
            let elEmptyOption = document.getElementById(`${childID}_empty_value`);
            if (elEmptyOption === null) {
                let opt = document.createElement('option');
                opt.id = `${childID}_empty_value`;
                opt.value = '';
                element[0].appendChild(opt);
                elEmptyOption = document.getElementById(`${childID}_empty_value`);
            }
            elEmptyOption.selected = true;
        }

        const getCurrentEnteredValue = (pFormat='', pIndID=0) => {
            let val = '';
            if (pFormat==='radio') {
                val = sanitize(document.querySelector(`input[id^="${pIndID}_radio"]:checked`)?.value.trim()) || '';
            } else { //multisel, dropdown
                val = sanitize(document.getElementById(pIndID)?.value.trim()) || '';
            }
            return val;
        }

        const clearValues = (childFormat, childIndID) => { //cond.childFormat
            $('#' + childIndID).val('');
            $(`input[id^="${childIndID}_radio"]`).prop("checked", false);
            $(`input[id^="${childIndID}_radio0"]`).prop("checked", true);
            if (childFormat === 'multiselect') {
                clearMultiSelectChild($('#' + childIndID), childIndID);
            }
            $('.blockIndicator_' + childIndID).hide();
            if (childRequiredValidators[childIndID].validator !== undefined && dialog !== null) {
                dialog.requirements[childIndID] = hideShowValidator;
            }
        }

        //conditions to check for specific child
        const makeComparisons = (childID, arrConditions)=> {
            let prefillValue = '';
            const elChildInput = $('#' + childID); //input el for text, multisel and dropd

            //make an input to deselect radio buttons if display state toggles
            const radioEmpty = $(`input[id^="${childID}_radio0"]`);
            if (arrConditions[0].childFormat === 'radio' && radioEmpty.length===0) {
                $(`div.response.blockIndicator_${childID}`).prepend(`<input id="${childID}_radio0" name="${childID}" value="" style="display:none;" />`);
            }
            const elRadioBtns = $(`input[id^="${childID}_radio"]`);

            const startValue = elChildInput.val() || $(`input[id^="${childID}_radio"]:checked`).val() || '';

            handleChildValidators(childID);

            arrConditions.forEach(cond => {
                const chosenShouldUpdate = cond.childFormat === 'dropdown';
                let comparisonResult = false;

                let arrCompVals = [];
                arrConditions.map(c => {
                    if (cond.selectedOutcome === c.selectedOutcome &&
                        ((cond.selectedOutcome.toLowerCase() === "pre-fill" && cond.selectedChildValue.trim() === c.selectedChildValue.trim()) ||
                        cond.selectedOutcome.toLowerCase() !== "pre-fill"
                        )
                    ) arrCompVals.push({[c.parentIndID]:c.selectedParentValue.trim()});
                });

                const isMultiselectParent = cond.parentFormat.toLowerCase()==='multiselect';
                switch (cond.selectedOp) {
                    case '==':
                        arrCompVals.forEach(entry => {
                            let id = Object.keys(entry)[0];
                            let val = getCurrentEnteredValue(cond.parentFormat, id);

                            if(!isMultiselectParent) {
                                if (entry[id] === val) {
                                    comparisonResult = true;
                                    if (cond.selectedOutcome.toLowerCase() === "pre-fill") {
                                        prefillValue = cond.selectedChildValue.trim();
                                    }
                                }
                            } else {
                                entry[id] = entry[id].split('\n');
                                entry[id] = entry[id].map(option => option.replaceAll('\r', '').trim());
                                let selectedOptions = Array.from(document.getElementById(id)?.selectedOptions);

                                if (valIncludesMultiselOption(selectedOptions, entry[id])) {
                                    comparisonResult = true;
                                    if (cond.selectedOutcome.toLowerCase() === "pre-fill") {
                                        prefillValue = cond.selectedChildValue.trim();
                                    }
                                }
                            }
                        });
                        break;
                    case '!=':
                        arrCompVals.forEach(entry => {
                            let id = Object.keys(entry)[0];
                            let val = getCurrentEnteredValue(cond.parentFormat, id);

                            if(!isMultiselectParent) {
                                if (entry[id] !== val) {
                                    comparisonResult = true;
                                    if (cond.selectedOutcome.toLowerCase() === "pre-fill") {
                                        prefillValue = cond.selectedChildValue.trim();
                                    }
                                }
                            } else {
                                entry[id] = entry[id].split('\n');
                                entry[id] = entry[id].map(option => option.replaceAll('\r', '').trim());
                                let selectedOptions = Array.from(document.getElementById(id)?.selectedOptions);

                                if (!valIncludesMultiselOption(selectedOptions, entry[id])) {
                                    comparisonResult = true;
                                    if (cond.selectedOutcome.toLowerCase() === "pre-fill") {
                                        prefillValue = cond.selectedChildValue.trim();
                                    }
                                }
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
                switch (cond.selectedOutcome.toLowerCase()) {
                    case 'hide':
                        if (comparisonResult === true) {
                            clearValues(cond.childFormat, childID);
                        } else {
                            $('.blockIndicator_' + childID).show();
                        }
                        break;
                    case 'show':
                        if (comparisonResult === true) {
                            $('.blockIndicator_' + childID).show();
                        } else {
                            clearValues(cond.childFormat, childID);
                        }
                        break;
                    case 'pre-fill':
                        let indBlock = $(`div.response.blockIndicator_${childID}`);
                        if (prefillValue !== '') {
                            //don't fill if it's in a hidden state bc of other conditions
                            if(cond.childFormat === 'multiselect') {
                                const arrPrefills = prefillValue.split('\n');
                                const arrChoices = arrPrefills.map(item =>  $('<div/>').html(item).text().trim());
                                let elSelectChoices = elChildInput[0].choicesjs;
                                elSelectChoices?.removeActiveItems();
                                elSelectChoices?.setChoiceByValue(arrChoices);
                                elSelectChoices?.disable();
                            } else {
                                const text = $('<div/>').html(prefillValue).text().trim();
                                elChildInput.val(text);  //text, multisel, dropd
                                elChildInput.attr('disabled', 'disabled');
                                $(`input[id^="${childID}_radio"][value="${text}"]`).prop("checked", true); //radio
                                elRadioBtns.prop("disabled", true);
                            }
                            
                            setTimeout(()=> { //temp timing fix for data value
                                if(indBlock.css('display')==='none') {
                                    clearValues(cond.childFormat, childID);
                                }
                            });

                        } else {
                            //just re-enable selection/editing.  resetting causes issues here.
                            elChildInput.removeAttr('disabled');
                            elChildInput[0]?.choicesjs?.enable();
                            elRadioBtns.prop("disabled", false);

                            setTimeout(()=> { //temp timing fix for validation
                                if(indBlock.css('display')==='none') {
                                    if (childRequiredValidators[childID].validator !== undefined && dialog !== null) {
                                        dialog.requirements[childID] = hideShowValidator;
                                    }
                                }
                            });
                        }
                        break; 
                    default:
                        console.log(cond.selectedOutcome);
                        break;
                }
                //trigger update if values have changed
                const endValue = elChildInput.val() || $(`input[id^="${childID}_radio"]:checked`).val() || '';

                if(startValue !== endValue) {
                    elChildInput.trigger('change');
                    $(`input[id^="${childID}_radio"]`).trigger('change');
                    if (chosenShouldUpdate) {
                        const val = elChildInput.val();
                        elChildInput.chosen().val(val);
                        elChildInput.chosen({ width: '100%' });
                        elChildInput.trigger('chosen:updated');
                    }
                }
            });
        }

        //confirm that the parent indicators exist on the form (in case of archive/deletion)
        let confirmedParElsByIndID = [];
        for (let entry in formConditionsByChild) {
            const formConditions = formConditionsByChild[entry].conditions || [];
            formConditions.forEach(c => {
                let parentEl = null;
                switch(c.parentFormat) {
                    case 'radio': //radio buttons use indID_radio1, indID_radio2 etc
                        parentEl = document.querySelector(`input[id^="${c.parentIndID}_radio"]`);
                        break;
                    default: //multisel, dropdown, text use input id=indID.
                        parentEl = document.getElementById(c.parentIndID);
                        break;
                }
                if (parentEl !== null) {
                    confirmedParElsByIndID.push(c.parentIndID);
                }
            });
        }
        confirmedParElsByIndID = Array.from(new Set(confirmedParElsByIndID));
        confirmedParElsByIndID.forEach(id => {
            checkConditions(null, null, id);
            //input depends on format
            $('#'+id).on('change', checkConditions); //jq should not err if element is not there
            $(`input[id^="${id}_radio"]`).on('change', checkConditions);
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
        $('#' + htmlFormID).serializeArray().map(function(x) {
            if (x.name.includes('_multiselect')) {
                const i = x.name.indexOf('_multiselect');
                if (x.value === '') { //selected if no options are chosen
                    data[x.name.slice(0, i)] = x.value;
                } else {
                    data[x.name.slice(0, i)] ? data[x.name.slice(0, i)].push(x.value) : data[x.name.slice(0, i)] = [x.value];
                }
            } else data[x.name] = x.value;
        });

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

                handleConditionalIndicators(formConditions, dialog);
                
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