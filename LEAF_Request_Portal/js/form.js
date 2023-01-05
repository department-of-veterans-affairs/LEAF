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
        const allowedChildFormats = ['dropdown', 'text', 'multiselect', 'radio', 'checkboxes'];

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

        const checkConditions = (event=0, selected=0, parID=0)=> {
            const parentElID = event !== null ? parseInt(event.target.id) : parseInt(parID);

            const linkedParentConditions = getConditionsLinkedToParent(parentElID); //get all children directly controlled by this parent, and their ids
            let uniqueChildIDs = linkedParentConditions.map(c => parseInt(c.childIndID));
            uniqueChildIDs = Array.from(new Set(uniqueChildIDs));

            let linkedChildConditions = [];
            uniqueChildIDs.forEach(id => {
                linkedChildConditions.push(...getConditionsLinkedToChild(id, parentElID)); //get all other possible parents controlling the above children
            });

            let allConditions = [...linkedParentConditions, ...linkedChildConditions];
            let hideShowConditions = allConditions.filter(c => ['show', 'hide'].includes(c.selectedOutcome.toLowerCase()));
            let prefillConditions = allConditions.filter(c => !['show', 'hide'].includes(c.selectedOutcome.toLowerCase()));
            allConditions = [...hideShowConditions, ...prefillConditions]; //orders them so that prefills would be last

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
         * @returns array of conditions that have the given value for their parentIndID, or empty array
         */
        const getConditionsLinkedToParent = (parentID=0)=> {
            let conditionsLinkedToParent = [];
            if(parentID !== 0) {
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
            }
            return conditionsLinkedToParent;
        }
        /**
         *
         * @param {number} childID id of a child condition
         * @param {number} currParentID the id of the controller that was updated
         * @returns array of all other parents that control the given child, or empty array
         */
        const getConditionsLinkedToChild = (childID=0, currParentID=0)=> {
            let conditionsLinkedToChild = [];
            if(childID !== 0 && currParentID !== 0) {
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
            }
            return conditionsLinkedToChild;
        }

        /**
         * returns true if any of the selected values are in the comparisonValues
         * @param {array} multiChoiceElements array of option elements or checkboxes
         * @param {array} comparisonValues array of values to compare against
         * @returns
         */
        const valIncludesMultiselOption = (multiChoiceElements = [], comparisonValues = []) => {
            let result = false;
            //get the values associated with the selection elements
            let vals = multiChoiceElements.map(sel => {
                if(sel?.label) { //multiselect option
                    return sanitize(sel.label.replaceAll('\r', '').trim());
                } else { //checkboxes
                    return sanitize(sel.value.replaceAll('\r', '').trim());
                }
            });
            vals.forEach(v => {
                if (comparisonValues.includes(v)) {
                    result = true;
                }
            });
            return result;
        }

        const clearMultiSelectChild = (element=[], childID=0) => {
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
        /**
         * used to get the sanitized input value for radio and dropdown parents
         * @param {*} pFormat format of the parent according to conditions object
         * @param {*} pIndID id of the parent according to the conditions object
         * @returns string.  
         */
        const getParentValue = (pFormat='', pIndID=0) => {
            let val = '';
            if (pFormat === 'radio') {
                val = sanitize(document.querySelector(`input[id^="${pIndID}_radio"]:checked`)?.value.trim()) || '';
            } 
            if (pFormat === 'dropdown') {
                val = sanitize(document.getElementById(pIndID)?.value.trim()) || '';
            }
            return val;
        }

        const clearValues = (childFormat='', childIndID=0) => {
            $('#' + childIndID).val('');
            $(`input[id^="${childIndID}_"]`).prop("checked", false); //this will hit both radio and checkboxes formats
            $(`input[id^="${childIndID}_radio0"]`).prop("checked", true);
            if (childFormat === 'multiselect') {
                clearMultiSelectChild($('#' + childIndID), childIndID);
            }
            $('.blockIndicator_' + childIndID).hide();
            if (childRequiredValidators[childIndID].validator !== undefined && dialog !== null) {
                dialog.requirements[childIndID] = hideShowValidator;
            }
        }

        /**
         *
         * @param {string} childID indicator ID of the child question, used to select associated DOM elements
         * @param {array} arrChildConditions array of conditions objects associated with the child question
         */
        const makeComparisons = (childID='', arrChildConditions=[]) => {
            const multiOptionFormats = ['multiselect', 'checkboxes'];
            //childFormat should be the same for all list elements, since formats that don't match the current question format are already removed.
            const childFormat = arrChildConditions[0].childFormat.toLowerCase();
            const chosenShouldUpdate = childFormat === 'dropdown';

            //used in the outcome switch after condition checking.
            let conditionOutcomes = [];
            if (arrChildConditions.filter(c => c.selectedOutcome.toLowerCase() === 'hide').length > 0) conditionOutcomes.push('hide');
            if (arrChildConditions.filter(c => c.selectedOutcome.toLowerCase() === 'show').length > 0) conditionOutcomes.push('show');
            if (arrChildConditions.filter(c => c.selectedOutcome.toLowerCase() === 'pre-fill').length > 0) conditionOutcomes.push('pre-fill');
            if (conditionOutcomes.length > 2) console.log('there are both hide and show conditions on the same question. check conditions setup');


            //get child input elements and their start values
            const elChildInput = $('#' + childID); //gets the input elements for text, multiselect and dropdown formats

            const radioEmpty = $(`input[id^="${childID}_radio0"]`); //radio format
            if (childFormat === 'radio' && radioEmpty.length === 0) {
                $(`div.response.blockIndicator_${childID}`).prepend(`<input id="${childID}_radio0" name="${childID}" value="" style="display:none;" />`);
            }
            const elChildRadioBtns = $(`input[id^="${childID}_radio"]`);
            const radioValue = $(`input[id^="${childID}_radio"]:checked`).val();

            const elChildCheckboxes = $(`input[type="checkbox"][id^="${childID}"]`); //checkboxes format
            let checkboxStartValues = '';
            elChildCheckboxes.map((i, cb) => { if(cb.checked === true) checkboxStartValues += cb.value });

            //used later to check if the end value is different after checking conditions
            const childStartValue = elChildInput.val()?.join ? elChildInput.val().join() : elChildInput.val() || radioValue  || checkboxStartValues || '';


            handleChildValidators(childID);

            let hideShowConditionMet = false;
            let childPrefillValue = '';

            arrChildConditions.forEach(cond => {
                const parentFormat = cond.parentFormat.toLowerCase();
                const parent_id = cond.parentIndID;
                const parentComparisonValues =  cond.selectedParentValue.trim();
                const outcome = cond.selectedOutcome.toLowerCase();

                switch (cond.selectedOp) {
                    case '==':
                        //these are repetitive, but potentially more confusing in a method because of their alteration of variables and comparison differences between operators
                        if(multiOptionFormats.includes(parentFormat)) {
                            //values from the condition to compare against. For multioption formats this will be a string of values separated with \n
                            const arrCompareValues = parentComparisonValues.split('\n').map(option => option.replaceAll('\r', '').trim());
                            //actual selected elements for multiselect and checkboxes (option or input elements)
                            const selectionElements = parentFormat === 'multiselect' ?
                                Array.from(document.getElementById(parent_id)?.selectedOptions || []) :
                                Array.from(document.querySelectorAll(`input[type="checkbox"][id^="${parent_id}"]:checked`) || []);
                            //hide and show should be mutually exclusive and only matter once, so don't continue if it has already become true
                            if (['hide', 'show'].includes(outcome) && !hideShowConditionMet && valIncludesMultiselOption(selectionElements, arrCompareValues)) {
                                hideShowConditionMet = true;
                            }
                            //likewise if there are mult controllers for a prefill then they should have the same prefill value
                            if(outcome === 'pre-fill' && childPrefillValue === '' && valIncludesMultiselOption(selectionElements, arrCompareValues)) {
                                childPrefillValue = cond.selectedChildValue.trim();
                            }

                        } else {
                            const parent_val = getParentValue(parentFormat, parent_id);
                            if(['hide', 'show'].includes(outcome) && !hideShowConditionMet && parentComparisonValues === parent_val) {
                                hideShowConditionMet = true;
                            }
                            if(outcome === 'pre-fill' && childPrefillValue === '' && parentComparisonValues === parent_val) {
                                childPrefillValue = cond.selectedChildValue.trim();
                            }
                        }
                        break;
                    case '!=':
                        if(multiOptionFormats.includes(parentFormat)) {
                            const arrCompareValues = parentComparisonValues.split('\n').map(option => option.replaceAll('\r', '').trim());
                            const selectionElements = parentFormat === 'multiselect' ?
                                Array.from(document.getElementById(parent_id)?.selectedOptions || []) :
                                Array.from(document.querySelectorAll(`input[type="checkbox"][id^="${parent_id}"]:checked`) || []);

                            if (['hide', 'show'].includes(outcome) && !hideShowConditionMet && !valIncludesMultiselOption(selectionElements, arrCompareValues)) {
                                hideShowConditionMet = true;
                            }
                            if(outcome === 'pre-fill' && childPrefillValue === '' && !valIncludesMultiselOption(selectionElements, arrCompareValues)) {
                                childPrefillValue = cond.selectedChildValue.trim();
                            }

                        } else {
                            const parent_val = getParentValue(parentFormat, parent_id);
                            if(['hide', 'show'].includes(outcome) && !hideShowConditionMet && parentComparisonValues !== parent_val) {
                                hideShowConditionMet = true;
                            }
                            if(outcome === 'pre-fill' && childPrefillValue === '' && parentComparisonValues === parent_val) {
                                childPrefillValue = cond.selectedChildValue.trim();
                            }
                        }
                        break;
                    default:
                        console.log(cond.selectedOp);
                        break;
                }
            });

            //update child states and/or values.  there should be at most 2 types here, a hide OR show, and a prefill
            conditionOutcomes.forEach(co => {
                switch (co) {
                    case 'hide':
                        if (hideShowConditionMet === true) {
                            clearValues(childFormat, childID);
                        } else {
                            $('.blockIndicator_' + childID).show();
                        }
                        break;
                    case 'show':
                        if (hideShowConditionMet === true) {
                            $('.blockIndicator_' + childID).show();
                        } else {
                            clearValues(childFormat, childID);
                        }
                        break;
                    case 'pre-fill':
                        let indBlock = $(`div.response.blockIndicator_${childID}`);
                        if (childPrefillValue !== '') {
                            if(indBlock.css('display') !== 'none') { //don't continue if the question is in a hidden state because of other conditions
                                if(multiOptionFormats.includes(childFormat)) {
                                    const arrPrefills = childPrefillValue.split('\n');
                                    const arrChoices = arrPrefills.map(item =>  $('<div/>').html(item).text().trim());
                                    $(`input[id^="${childID}_"]`).prop("checked", false); //clear out possible selections
                                    arrChoices.forEach(textVal => $(`input[id^="${childID}_"][value="${textVal}"]`).prop("checked", true));
                                    elChildCheckboxes.prop("disabled", true);

                                    if(childFormat === 'multiselect') {
                                        let elSelectChoices = elChildInput[0].choicesjs;
                                        elSelectChoices?.removeActiveItems();
                                        elSelectChoices?.setChoiceByValue(arrChoices);
                                        elSelectChoices?.disable();
                                    }

                                } else {
                                    const text = $('<div/>').html(childPrefillValue).text().trim();
                                    elChildInput.val(text);  //text, dropd
                                    elChildInput.attr('disabled', 'disabled');
                                    $(`input[id^="${childID}_radio"][value="${text}"]`).prop("checked", true); //radio
                                    elChildRadioBtns.prop("disabled", true);
                                }
                            }

                        } else {
                            //just re-enable selection/editing.  Can't clear them since that would rm normal entries
                            elChildInput.removeAttr('disabled');
                            elChildInput[0]?.choicesjs?.enable();
                            elChildRadioBtns.prop("disabled", false);
                            elChildCheckboxes.prop("disabled", false);
                        }
                        break; 
                    default:
                        console.log(co);
                        break;
                }
            })

            //check end values and trigger update if values have changed
            let checkboxEndValues = '';
            elChildCheckboxes.map((i, cb) => { if(cb.checked === true) checkboxEndValues += cb.value });

            const childEndValue = elChildInput.val()?.join ? elChildInput.val().join() : elChildInput.val() || $(`input[id^="${childID}_radio"]:checked`).val() || checkboxEndValues || '';

            if(childStartValue !== childEndValue) {
                elChildInput.trigger('change');
                $(`input[id^="${childID}_"]`).trigger('change');  //radio and checkboxes
                if (chosenShouldUpdate) {
                    const val = elChildInput.val();
                    elChildInput.chosen().val(val);
                    elChildInput.chosen({ width: '100%' });
                    elChildInput.trigger('chosen:updated');
                }
            }
        }

        //confirm that the parent indicators exist on the form (in case of archive/deletion)
        let confirmedParElsByIndID = [];
        let notFoundParElsByIndID = [];
        for (let entry in formConditionsByChild) {
            const formConditions = formConditionsByChild[entry].conditions || [];
            formConditions.forEach(c => {
                let parentEl = null;
                switch(c.parentFormat.toLowerCase()) {
                    case 'radio': //radio buttons use indID_radio1, indID_radio2 etc
                        parentEl = document.querySelector(`input[id^="${c.parentIndID}_radio"]`);
                        break;
                    case 'checkboxes': //checkboxes use indID_0, indID_1 etc
                        parentEl = document.querySelector(`input[id^="${c.parentIndID}_"]`);
                        break;
                    default: //multisel, dropdown, text use input id=indID.
                        parentEl = document.getElementById(c.parentIndID);
                        break;
                }
                if (parentEl !== null) {
                    confirmedParElsByIndID.push(parseInt(c.parentIndID));
                } else {
                    notFoundParElsByIndID.push(parseInt(c.parentIndID));
                }
            });
        }
        confirmedParElsByIndID = Array.from(new Set(confirmedParElsByIndID));
        notFoundParElsByIndID = Array.from(new Set(notFoundParElsByIndID));

        if (notFoundParElsByIndID.length > 0) { //filter out any conditions that have parent IDs of elements not found in the DOM
            for (let entry in formConditionsByChild) {
               formConditionsByChild[entry].conditions = formConditionsByChild[entry].conditions.filter(c => !notFoundParElsByIndID.includes(parseInt(c.parentIndID)));
            }
        }
        confirmedParElsByIndID.forEach(id => {
            checkConditions(null, null, id);
            //initial condition check and listeners for confirmed parents.  input depends on format. jq will not err if element is not there
            $('#'+id).on('change', checkConditions);
            $(`input[id^="${id}_"]`).on('change', checkConditions); //this should cover both radio and checkboxes
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