export default {
    name: 'conditions-editor-dialog',
    data() {
        return {
            formID: this.focusedFormRecord.categoryID,
            formIndicatorID: parseInt(this.currIndicatorID),
            indicators: [],
            appIsLoadingIndicators: true,
            parentIndicatorID: 0,
            selectedOperator: '',
            selectedParentValue: '',
            selectedChildOutcome: '',
            selectedChildValue: '',
            showRemoveModal: false,
            showConditionEditor: false,
            selectedConditionJSON: '',
            enabledParentFormats: ['dropdown', 'multiselect', 'radio', 'checkboxes'],
            multiOptionFormats: ['multiselect', 'checkboxes'],
            crosswalkFile: '',
            crosswalkHasHeader: false,
            level2IndID: null,
            noPrefillFormats: ['', 'fileupload', 'image']
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'currIndicatorID',
        'focusedFormRecord',
        'selectedNodeIndicatorID',
        'selectNewCategory',
        'closeFormDialog',
        'truncateText',
        'fileManagerTextFiles'
    ],
    mounted() {
        const elSaveDiv = document.querySelector('#leaf-vue-dialog-cancel-save #button_save');
        if (elSaveDiv !== null) elSaveDiv.style.display = 'none';
        this.getAllIndicators();
    },
    updated() {
        const outcome = this.conditions.selectedOutcome;
        if(["pre-fill", "show", "hide"].includes(outcome)) {
            this.updateChoicesJS();
        }
    },
    methods: {
        getAllIndicators(){
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}form/indicator/list/unabridged`,
                success: (res)=> {
                    const filteredList = res.filter(ele => parseInt(ele.indicatorID) > 0 && parseInt(ele.isDisabled) === 0);
                    this.indicators = filteredList;
                    this.indicators.forEach(i => { 
                        if (i.parentIndicatorID !== null) {
                            this.addHeaderIDs(parseInt(i.parentIndicatorID), i);
                        } else {
                            i.headerIndicatorID = parseInt(i.indicatorID);
                        }
                    });
                    this.appIsLoadingIndicators = false;
                },
                error: (err) => console.log(err)
            });
        },
        /**
         * @param {string} outcome (condition outcome options: Hide, Show, Pre-Fill)
         */
        updateSelectedOutcome(outcome = '') {
            this.removeChoicesjsMultibox();
            this.selectedChildOutcome = outcome.toLowerCase();
            this.selectedChildValue = "";
            this.crosswalkFile = "";
            this.crosswalkHasHeader = false;
            this.level2IndID = null;
        },
        /**
         * @param {Object} target (DOM element)
         * @param {string} type parent or child
         */
        updateSelectedOptionValue(target = {}, type = 'parent') {
            type = type.toLowerCase();
            const format = type === 'parent' ? this.parentFormat : this.childFormat;

            let value = '';
            if (this.multiOptionFormats.includes(format)) {
                const arrSelections = Array.from(target.selectedOptions);
                arrSelections.forEach(sel => {
                    value += sel.label.trim() + '\n';
                });
                value = value.trim();
            } else {
                value = target.value;
            }
            if (type === 'parent') {
                this.selectedParentValue = XSSHelpers.stripAllTags(value);
            } else if (type === 'child') {
                this.selectedChildValue = XSSHelpers.stripAllTags(value);
            }
        },
        /**
         * Recursively searches indicators to add headerIndicatorID to the indicators list.
         * The headerIndicatorID is used to track which indicators are on the same page.
         * @param {Number} indID parent ID of indicator at the current depth
         * @param {Object} initialIndicator reference to the indicator to update
         */
        addHeaderIDs(indID = 0, initialIndicator = {}) {
            const parent = this.indicators.find(i => parseInt(i.indicatorID) === indID);
            if(parent === undefined) return;
            //if the parent has a null parentID, then this is the header, update the passed reference
            if (parent?.parentIndicatorID === null) {
                initialIndicator.headerIndicatorID = indID;
            } else {
                this.addHeaderIDs(parseInt(parent.parentIndicatorID), initialIndicator);
            }
        },
        newCondition() {
            this.selectedConditionJSON = '';
            this.showConditionEditor = true;
            this.selectedOperator = '';
            this.parentIndicatorID = 0;
            this.selectedParentValue = '';
            this.selectedChildOutcome = '';
            this.selectedChildValue = '';
            this.removeChoicesjsMultibox();
        },
        postConditions(addSelected = true) {
            if (this.conditionComplete || addSelected === false) {
                //copy of all conditions on child, and filter using stored JSON val
                let currConditions = [...this.savedConditions];
                let newConditions = currConditions.filter(c => JSON.stringify(c) !== this.selectedConditionJSON);
                //clean up some possible data type issues after php8 and br tags before saving.
                newConditions.forEach(c => {
                    c.childIndID = parseInt(c.childIndID);
                    c.parentIndID = parseInt(c.parentIndID);
                    c.selectedChildValue = XSSHelpers.stripAllTags(c.selectedChildValue);
                    c.selectedParentValue = XSSHelpers.stripAllTags(c.selectedParentValue);
                });

                //if adding, confirm new conditions is unique
                const newConditionJSON = JSON.stringify(this.conditions);
                const newConditionIsUnique = newConditions.every(c => JSON.stringify(c) !== newConditionJSON);
                if (addSelected === true && newConditionIsUnique) {
                    newConditions.push(this.conditions);
                }

                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formEditor/${this.formIndicatorID}/conditions`,
                    data: {
                        conditions: newConditions.length > 0 ? JSON.stringify(newConditions) : '',
                        CSRFToken: this.CSRFToken
                    },
                    success: (res)=> {
                        if (res !== 'Invalid Token.') {
                            this.selectNewCategory(this.formID, this.selectedNodeIndicatorID);
                            this.closeFormDialog();
                        } else { console.log('error adding condition', res) }
                    },
                    error:(err) => console.log(err)
                });
            }
        },
        /**
         * @param {Object} data ({confirmDelete:boolean, condition:Object})
         */
        removeCondition(data = {}) {
            if(data?.confirmDelete === true) { //delete btn confirm modal
                this.postConditions(false);
             
            } else { //X button select and open the confirm delete modal
                this.selectConditionFromList(data?.condition || {});
                this.showRemoveModal = true;
            }
        },
        /**
         * clear out potential choices multibox instances by calling its destroy method
         */
        removeChoicesjsMultibox() {
            const elSelectChild = document.getElementById('child_prefill_entry_multi');
            if(elSelectChild?.choicesjs && typeof elSelectChild.choicesjs?.destroy === 'function') elSelectChild.choicesjs.destroy();
            const elSelectParent = document.getElementById('parent_compValue_entry_multi');
            if(elSelectParent?.choicesjs && typeof elSelectParent.choicesjs?.destroy === 'function') elSelectParent.choicesjs.destroy();
        },
        /**
         * store the selected condition in a string and update associated app values
         * @param {Object} conditionObj 
         */
        selectConditionFromList(conditionObj = {}) {
            this.selectedConditionJSON = JSON.stringify(conditionObj);
            this.parentIndicatorID = conditionObj?.parentIndID || 0;
            this.selectedOperator = conditionObj?.selectedOp || '';
            this.selectedChildOutcome = conditionObj?.selectedOutcome || '';
            this.selectedParentValue = conditionObj?.selectedParentValue || '';
            this.selectedChildValue = conditionObj?.selectedChildValue || '';
            this.crosswalkFile = conditionObj?.crosswalkFile || '';
            this.crosswalkHasHeader = conditionObj?.crosswalkHasHeader || false;
            this.level2IndID = conditionObj?.level2IndID || null;
            this.removeChoicesjsMultibox();
            this.showConditionEditor = true;
        },
        /**
         * @param {number} id 
         * @returns {string}
         */
        getIndicatorName(id = 0) {
            if (id !== 0) {
                let indicatorName =
                    this.indicators.find(
                        indicator => parseInt(indicator.indicatorID) === id
                    )?.name || '';
                return this.truncateText(indicatorName, 40);
            }
        },
        textValueDisplay(str = '') {
            return $('<div/>').html(str).text();
        },
        /**
         * @param {Object} condition 
         * @returns {string}
         */
        getOperatorText(condition = {}) {
            const op = condition.selectedOp;
            const parFormat = condition.parentFormat.toLowerCase();
            let text = '';
            switch(op){
                case '==':
                    text = this.multiOptionFormats.includes(parFormat) ? 'includes' : 'is';
                    break;
                case '!=':
                    text = 'is not';
                    break;
                default:
                    text = op;
                    break;
            }
            return text;
        },
        /**
         * returns true if the outcome is not a crosswalk and its parentIndID
         * is no longer in the list of selectable parents (due to archive or delete)
         * @param {object} condition 
         * @returns {boolean}
         */
        isOrphan(condition = {}) {
            const indID = parseInt(condition?.parentIndID || 0);
            const outcome = condition.selectedOutcome.toLowerCase();
            return outcome !== 'crosswalk' && !this.selectableParents.some(p => parseInt(p.indicatorID) === indID);
        },
        /**
         * @param {String} conditionType
         * @returns {String}
         */
        listHeaderText(conditionType = '') {
            const type = conditionType.toLowerCase();
            let text = '';
            switch(type) {
                case 'show':
                    text = 'This field will be hidden except:'
                    break;
                case 'hide':
                    text = 'This field will be shown except:'
                    break;
                case 'prefill':
                    text = 'This field will be pre-filled:'
                    break;
                case 'crosswalk':
                    text = 'This field has loaded dropdown(s)'
                    break;
                default:
                    break;
            }
            return text;
        },
        /**
         * @param {Object} condition 
         * @returns {boolean}
         */
        childFormatChangedSinceSave(condition = {}) {
            const childConditionFormat = condition.childFormat.toLowerCase();
            const currentIndicatorFormat = this.childFormat;
            return childConditionFormat?.trim() !== currentIndicatorFormat?.trim();
        },
        /**
         * called if the app updates to create choicejs combobox instances for multi option formats if needed
         */
        updateChoicesJS() {
            const elExistingChoicesChild = document.querySelector('#outcome-editor > div.choices');
            const elSelectParent = document.getElementById('parent_compValue_entry_multi');
            const elSelectChild = document.getElementById('child_prefill_entry_multi');
            const outcome = this.conditions.selectedOutcome;

            if(this.multiOptionFormats.includes(this.parentFormat) &&
                elSelectParent !== null &&
                !(elSelectParent?.choicesjs?.initialised === true)
            ) {
                let arrValues = this.conditions.selectedParentValue.split('\n') || [];
                arrValues = arrValues.map(v => this.textValueDisplay(v).trim());

                let options = this.selectedParentValueOptions;
                options = options.map(o =>({
                    value: o.trim(),
                    label: o.trim(),
                    selected: arrValues.includes(o.trim())
                }));
                const choices = new Choices(elSelectParent, {
                    allowHTML: false,
                    removeItemButton: true,
                    editItems: true,
                    choices: options.filter(o => o.value !== "")
                });
                elSelectParent.choicesjs = choices;
            }

            if(outcome === 'pre-fill' && this.multiOptionFormats.includes(this.childFormat) &&
                elSelectChild !== null && elExistingChoicesChild === null
            ) {
                let arrValues = this.conditions.selectedChildValue.split('\n') || [];
                arrValues = arrValues.map(v => this.textValueDisplay(v).trim());
                
                let options = this.selectedChildValueOptions;
                options = options.map(o =>({
                    value: o.trim(),
                    label: o.trim(),
                    selected: arrValues.includes(o.trim())
                }));
                const choices = new Choices(elSelectChild, {
                    allowHTML: false,
                    removeItemButton: true,
                    editItems: true,
                    choices: options.filter(o => o.value !== "")
                });
                elSelectChild.choicesjs = choices;
            }
        },
        onSave() {
            this.postConditions(true);
        }
    },
    computed: {
        showSetup() {
            return  !this.showRemoveModal && this.showConditionEditor &&
                (this.selectedChildOutcome === 'crosswalk' || this.selectableParents.length > 0);
        },
        noOptions() {
            return !['', 'crosswalk'].includes(this.selectedChildOutcome) && this.selectableParents.length < 1;
        },
        childIndicator() {
            return this.indicators.find(i => parseInt(i.indicatorID) === this.formIndicatorID);
        },
        /**
         * @returns {object} current parent selection
         */
        selectedParentIndicator() {
            const indicator = this.selectableParents.find(
                i => parseInt(i.indicatorID) === parseInt(this.parentIndicatorID)
            );
            return indicator === undefined ? {} : {...indicator};
        },
        /**
         * @returns {string} lower case base format of the parent question if there is one
         */
        parentFormat() {
            if(this.selectedParentIndicator?.format !== undefined) {
                const f = this.selectedParentIndicator.format.toLowerCase();
                return f.split('\n')[0].trim();
            } else return '';
        },
        /**
         * @returns {string} lower case base format of the child question
         */
        childFormat() {
            const f = this.childIndicator.format.toLowerCase();
            return f.split('\n')[0].trim();
        },
        /**
         * @returns list of indicators that are on the same page, enabled as parents, and different than child 
         */
        selectableParents() {
            const headerIndicatorID = this.childIndicator.headerIndicatorID;
            return this.indicators.filter(i => {
                const parFormat = i.format?.split('\n')[0].trim().toLowerCase();
                return i.headerIndicatorID === headerIndicatorID &&
                    parseInt(i.indicatorID) !== parseInt(this.childIndicator.indicatorID) &&
                    this.enabledParentFormats.includes(parFormat);
            });
        },
        /**
         * @returns list of operators and human readable text base on parent format
         */
        selectedParentOperators() {
            let operators = [];
            switch(this.parentFormat) {
                case 'multiselect':
                case 'checkboxes':
                    operators = [
                        {val:"==", text: "includes"},
                        {val:"!=", text: "does not include"}
                    ];
                    break;
                case 'dropdown':
                case 'radio':
                    operators = [
                        {val:"==", text: "is"},
                        {val:"!=", text: "is not"}
                    ];
                    break;
                default:
                    break;
            }
            return operators;
        },
        crosswalkLevelTwo() {
            const headerIndicatorID = this.childIndicator.headerIndicatorID;
            return this.indicators.filter((i) => {
                const format = i.format?.split("\n")[0].trim().toLowerCase();
                return (
                    i.headerIndicatorID === headerIndicatorID &&
                    parseInt(i.indicatorID) !== parseInt(this.childIndicator.indicatorID) &&
                    ['dropdown', 'multiselect'].includes(format)
                );
            });
        },
        /**
         * @returns list of options for comparison based on parent indicator selection
         */
        selectedParentValueOptions() {
            const fullFormatToArray = (this.selectedParentIndicator?.format || '').split("\n");
            let options = fullFormatToArray.length > 1 ? fullFormatToArray.slice(1) : [];
            options = options.map(o => o.trim());
            return options.filter(o => o !== '')
        },
        /**
         * @returns list of options for prefill outcomes.  Does NOT combine with file loaded options.
         */
        selectedChildValueOptions() {
            const fullFormatToArray = this.childIndicator.format.split("\n");
            let options = fullFormatToArray.length > 1 ? fullFormatToArray.slice(1) : [];
            options = options.map(o => o.trim());
            return options.filter(o => o !== '')
        },
        canAddCrosswalk() {
            return (this.childFormat === 'dropdown' || this.childFormat === 'multiselect')
        },
        /**
         * @returns {Object} current conditions object, properties to lower and tags removed as needed
         */
        conditions() {
            return {
                childIndID: parseInt(this.childIndicator?.indicatorID || 0),
                parentIndID: parseInt(this.selectedParentIndicator?.indicatorID || 0),
                selectedOp: this.selectedOperator, 
                selectedParentValue: XSSHelpers.stripAllTags(this.selectedParentValue),
                selectedChildValue: XSSHelpers.stripAllTags(this.selectedChildValue),
                selectedOutcome: this.selectedChildOutcome.toLowerCase(),
                crosswalkFile: this.crosswalkFile,
                crosswalkHasHeader: this.crosswalkHasHeader,
                level2IndID: this.level2IndID,
                childFormat: this.childFormat,
                parentFormat: this.parentFormat
            }    
        },
        /**
         * 
         * @returns {boolean} if all required fields are entered for the current condition type
         */
        conditionComplete() {
            const {
                childIndID,
                parentIndID,
                selectedOp,
                selectedParentValue,
                selectedChildValue,
                selectedOutcome,
                crosswalkFile
            } = this.conditions;

            let returnValue = false;
            if (!this.showRemoveModal) { //don't bother w this logic if showing delete view
                switch(selectedOutcome) {
                    case 'pre-fill':
                        returnValue = childIndID !== 0
                                    && parentIndID !== 0
                                    && selectedOp !== ""
                                    && selectedParentValue !== ""
                                    && selectedChildValue !== "";
                        break;
                    case 'hide':
                    case 'show':
                        returnValue = childIndID !== 0
                                    && parentIndID !== 0
                                    && selectedOp !== ""
                                    && selectedParentValue !== "";
                        break;
                    case 'crosswalk':
                        returnValue = crosswalkFile !== "";
                        break;
                    default:
                        break;
                }
            }
            //btn is part of the LEAF modal
            const elSave = document.getElementById('button_save');
            if (elSave !== null) elSave.style.display = returnValue === true ? 'block' : 'none';

            return returnValue;
        },
        /**
         * @returns {Array} of conditions.  'null' accounts for a previous import issue
         */
        savedConditions() {
            return this.childIndicator.conditions && this.childIndicator.conditions !== 'null' ?
                JSON.parse(this.childIndicator.conditions) : [];
        },
        /**
         * @returns {Object} of conditions by type
         */
        conditionTypes() {
            return {
                show: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "show"),
                hide: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "hide"),
                prefill: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "pre-fill"),
                crosswalk: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "crosswalk"),
            };
        }
    },
    watch: {
        showRemoveModal(newVal) {
            const elSaveDiv = document.getElementById('leaf-vue-dialog-cancel-save');
            if (elSaveDiv !== null) {
                elSaveDiv.style.display = newVal === true ? 'none' : 'flex';
            }
        }
    },
    template: `<div id="condition_editor_center_panel">
            <!-- LOADING SPINNER -->
            <div v-if="appIsLoadingIndicators" style="border: 2px solid black; text-align: center; 
                font-size: 24px; font-weight: bold; padding: 16px;">
                Loading... 
                <img src="../images/largespinner.gif" alt="loading..." />
            </div>
            <!-- INPUT AREA -->
            <div v-else id="condition_editor_inputs">
                <div>
                    <!-- NOTE: LISTS BY CONDITION TYPE -->
                    <div v-if="savedConditions.length > 0 && !showRemoveModal" id="savedConditionsLists">
                        <template v-for="typeVal, typeKey in conditionTypes" :key="typeVal">
                            <template v-if="typeVal.length > 0">
                                <p><b>{{ listHeaderText(typeKey) }}</b></p>
                                <ul style="margin-bottom: 1rem;">
                                    <li v-for="c in typeVal" :key="c" class="savedConditionsCard">
                                        <button type="button" @click="selectConditionFromList(c)" class="btnSavedConditions" 
                                            :class="{selectedConditionEdit: JSON.stringify(c) === selectedConditionJSON, isOrphan: isOrphan(c)}">
                                            <template v-if="!isOrphan(c)">
                                                <div style="text-align: left">
                                                    <div v-if="c.selectedOutcome.toLowerCase() !== 'crosswalk'">
                                                        If '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                                        {{getOperatorText(c)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                                        then {{c.selectedOutcome}} this question.
                                                    </div>
                                                    <div v-else>Options for this question will be loaded from <b>{{ c.crosswalkFile }}</b></div>
                                                    <div v-if="childFormatChangedSinceSave(c)" class="changesDetected">
                                                        This question's format has changed.  Please review and save to update it
                                                    </div>
                                                </div>
                                            </template>
                                            <div v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived, deleted or is on another page.</div>
                                        </button>
                                        <button type="button" style="width: 1.75em;" class="btn_remove_condition"
                                            @click="removeCondition({confirmDelete: false, condition: c})">X
                                        </button>
                                    </li>
                                </ul>
                            </template>
                        </template>
                    </div>
                    <button v-if="!showRemoveModal" type="button" @click="newCondition" class="btnNewCondition">+ New Condition</button>
                    <!-- DELETION DIALOG -->
                    <div v-if="showRemoveModal">
                        <div>Choose <b>Delete</b> to confirm removal, or <b>cancel</b> to return</div>
                        <ul style="display: flex; justify-content: space-between; margin-top: 1em">
                            <li style="width: 30%;">
                                <button type="button" class="btn_remove_condition"
                                    @click="removeCondition({confirmDelete: true, condition: {}})">
                                    Delete
                                </button>
                            </li>
                            <li style="width: 30%;">
                                <button type="button" id="btn_cancel" @click="showRemoveModal=false">Cancel</button>
                            </li>
                        </ul>
                    </div>
                </div>
                <div v-if="!showRemoveModal && showConditionEditor" id="outcome-editor">
                    <!-- NOTE: OUTCOME SELECTION -->
                    <span v-if="conditions.childIndID" class="input-info">Select an outcome</span>
                    <select v-if="conditions.childIndID" title="select outcome"
                            @change="updateSelectedOutcome($event.target.value)">
                            <option v-if="conditions.selectedOutcome === ''" value="" selected>Select an outcome</option> 
                            <option value="show" :selected="conditions.selectedOutcome === 'show'">Hide this question except ...</option>
                            <option value="hide" :selected="conditions.selectedOutcome === 'hide'">Show this question except ...</option>
                            <option v-if="!noPrefillFormats.includes(childFormat)" 
                                value="pre-fill" :selected="conditions.selectedOutcome === 'pre-fill'">Pre-fill this Question
                            </option>
                            <option v-if="canAddCrosswalk"
                                value="crosswalk" :selected="conditions.selectedOutcome === 'crosswalk'">Load Dropdown or Crosswalk
                            </option>
                    </select>
                    <template v-if="!noOptions">
                        <span v-if="conditions.selectedOutcome === 'pre-fill'" class="input-info">Enter a pre-fill value</span>
                        <!-- NOTE: CHILD PRE-FILL ENTRY AREAS -->
                        <select v-if="conditions.selectedOutcome === 'pre-fill' && (childFormat==='dropdown' || childFormat==='radio')"
                            id="child_prefill_entry_single"
                            @change="updateSelectedOptionValue($event.target, 'child')">
                            <option v-if="conditions.selectedChildValue === ''" value="" selected>Select a value</option>
                            <option v-for="val in selectedChildValueOptions" 
                                :value="val"
                                :key="'child_prefill_' + val"
                                :selected="textValueDisplay(conditions.selectedChildValue) === val">
                                {{ val }} 
                            </option>
                        </select>
                        <select v-else-if="conditions.selectedOutcome === 'pre-fill' && (childFormat === 'multiselect' || childFormat === 'checkboxes')"
                            placeholder="select some options"
                            multiple="true"
                            id="child_prefill_entry_multi"
                            style="display: none;"
                            @change="updateSelectedOptionValue($event.target, 'child')">
                        </select>
                        <input v-else-if="conditions.selectedOutcome === 'pre-fill' && (childFormat==='text' || childFormat==='textarea')" 
                            id="child_prefill_entry_text"
                            @change="updateSelectedOptionValue($event.target, 'child')"
                            :value="textValueDisplay(conditions.selectedChildValue)" />
                    </template>
                </div>
                <div v-if="showSetup" class="if-then-setup">
                    <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                        <h3 style="margin: 0;">IF</h3>
                        <div>
                            <!-- NOTE: PARENT CONTROLLER SELECTION -->
                            <select title="select an indicator" v-model.number="parentIndicatorID">
                                <option v-if="!conditions.parentIndID" :value="0" selected>Select an Indicator</option>
                                <option v-for="i in selectableParents" :key="'parent_' + i.indicatorID"
                                :title="i.name"
                                :value="i.indicatorID">
                                {{getIndicatorName(parseInt(i.indicatorID)) }} (indicator {{i.indicatorID}})
                                </option>
                            </select>
                        </div>
                        <div>
                            <!-- NOTE: OPERATOR SELECTION -->
                            <select v-model="selectedOperator">
                                <option v-if="conditions.selectedOp === ''" value="" selected>Select a condition</option>
                                <option v-for="o in selectedParentOperators" :key="o.val" :value="o.val" >
                                {{ o.text }}
                                </option>
                            </select>
                        </div>
                        <div>
                            <!-- NOTE: COMPARED VALUE SELECTIONS -->
                            <select v-if="parentFormat === 'dropdown' || parentFormat==='radio'"
                                id="parent_compValue_entry_single"
                                @change="updateSelectedOptionValue($event.target, 'parent')">
                                <option v-if="conditions.selectedParentValue === ''" value="" selected>Select a value</option>
                                <option v-for="val in selectedParentValueOptions"
                                    :key="'parent_val_' + val"
                                    :selected="textValueDisplay(conditions.selectedParentValue) === val"> {{ val }}
                                </option>
                            </select>
                            <select v-else-if="parentFormat === 'multiselect' || parentFormat==='checkboxes'"
                                id="parent_compValue_entry_multi"
                                placeholder="select some options" multiple="true"
                                style="display: none;"
                                @change="updateSelectedOptionValue($event.target, 'parent')">
                            </select>
                        </div>
                    </template>
                    <!-- NOTE: LOADED DROPDOWNS AND CROSSWALKS -->
                    <div v-else class="crosswalks">
                        <div style="display:flex; gap: 2rem; margin-bottom: 1rem;">
                            <label for="select-crosswalk-file">File&nbsp;
                                <select v-model="crosswalkFile" style="width: 100%;" id="select-crosswalk-file">
                                    <option value="">Select a file</option>
                                    <option v-for="f in fileManagerTextFiles" :key="f" :value="f">{{f}}</option>
                                </select>
                            </label>
                            <label for="select-crosswalk-header">Does file contain headers?&nbsp;
                                <select v-model="crosswalkHasHeader" style="width:75px;" id="select-crosswalk-header">
                                    <option :value="false">No</option>
                                    <option :value="true">Yes</option>
                                </select>
                            </label>
                        </div>
                        <div style="display:flex;">
                            <label for="select-level-two">Controlled Dropdown&nbsp;
                                <select v-model.number="level2IndID" id="select-level-two">
                                    <option :value="null">none (single dropdown)</option>
                                    <option v-for="indicator in crosswalkLevelTwo"
                                        :key="'level2_' + indicator.indicatorID"
                                        :value="parseInt(indicator.indicatorID)">
                                        {{indicator.indicatorID}}: {{getIndicatorName(parseInt(indicator.indicatorID))}}
                                    </option>
                                </select>
                            </label>
                        </div>
                    </div>
                </div>
                <div v-if="conditionComplete">
                    <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                        <h3 style="margin: 0; display:inline-block">THEN</h3> '{{getIndicatorName(formIndicatorID)}}'
                        <span v-if="conditions.selectedOutcome === 'pre-fill'">will 
                        <span style="color: #008010; font-weight: bold;"> have the value{{childFormat === 'multiselect' ? '(s)':''}} '{{textValueDisplay(conditions.selectedChildValue)}}'</span>
                        </span>
                        <span v-else>will 
                            <span style="color: #008010; font-weight: bold;">
                            be {{conditions.selectedOutcome === "show" ? 'shown' : 'hidden'}}
                            </span>
                        </span>
                    </template>
                    <template v-else>
                        <p>Selection options will be loaded from <b>{{ conditions.crosswalkFile }}</b></p>
                    </template>
                </div>
                <div v-if="noOptions">No options are currently available for this selection</div>
            </div>
        </div>` 
}