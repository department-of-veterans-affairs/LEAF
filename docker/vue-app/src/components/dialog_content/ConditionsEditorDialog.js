export default {
    name: 'conditions-editor-dialog',
    data() {
        return {
            formID: this.focusedFormRecord.categoryID,
            formIndicatorID: parseInt(this.currIndicatorID),

            //indicatorOrg: {},  NOTE: keep
            indicators: [],
            appIsLoadingIndicators: true,
            selectedParentIndicator: {},
            selectedDisabledParentID: null,
            selectedParentOperators: [],
            selectedOperator: '',
            selectedParentValue: '',
            selectedParentValueOptions: [],   //for radio, dropdown
            selectableParents: [],
            selectedChildOutcome: '',
            selectedChildValueOptions: [],
            selectedChildValue: '',
            showRemoveModal: false,
            showConditionEditor: false,
            selectedConditionJSON: '',
            enabledParentFormats: ['dropdown', 'multiselect', 'radio', 'checkboxes'],
            multiOptionFormats: ['multiselect', 'checkboxes'],
            crosswalkFile: '',
            crosswalkHasHeader: false,
            crosswalkLevelTwo: [],
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
            //get all enabled indicators + headings
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}form/indicator/list/unabridged`,
                success: (res)=> {
                    const list = res;
                    const filteredList = list.filter(ele => parseInt(ele.indicatorID) > 0 && parseInt(ele.isDisabled) === 0);
                    this.indicators = filteredList;
                    this.indicators.forEach(i => { 
                        if (i.parentIndicatorID !== null) {
                            this.addHeaderIDs(parseInt(i.parentIndicatorID), i);
                        } else {
                            i.headerIndicatorID = parseInt(i.indicatorID);
                        }
                    });
                    this.appIsLoadingIndicators = false;
                    this.updateSelectedChildIndicator();
                },
                error: (err)=> {
                    console.log(err)
                }
            });
        },
        /**
         * 
         * @param {number | string} indicatorID 
         * @returns 
         */
        updateSelectedParentIndicator(indicatorID = 0) {
            //get rid of possible multiselect choices instance and parent comparison value
            const elSelectParent = document.getElementById('parent_compValue_entry');
            if(elSelectParent?.choicesjs) elSelectParent.choicesjs.destroy();
            this.selectedParentValue = ''; 
            
            const indicator = this.indicators.find(i => indicatorID !== null && parseInt(i.indicatorID) === parseInt(indicatorID));
            //if it's archived/deleted just return, otherwise update values
            if(indicator === undefined) {
                return;

            } else {
                this.selectedParentIndicator = {...indicator};

                let formatNameAndOptions = indicator.format.split("\n");  //format field has the format name followed by options, separator is \n
                let valueOptions = formatNameAndOptions.length > 1 ? formatNameAndOptions.slice(1) : [];
                valueOptions = valueOptions.map(o => o.trim());  //there are sometimes carriage returns in the array
                this.selectedParentValueOptions = valueOptions.filter(vo => vo !== '');

                switch(this.parentFormat) {
                    case 'multiselect':
                    case 'checkboxes':
                        this.selectedParentOperators = [
                            {val:"==", text: "includes"},
                            {val:"!=", text: "does not include"}
                        ];
                        break;
                    case 'dropdown':
                    case 'radio':
                        this.selectedParentOperators = [
                            {val:"==", text: "is"},
                            {val:"!=", text: "is not"}
                        ];
                        break;
                    default:
                        this.selectedParentOperators = [];
                        break;
                }
            }
        },
        /**
         * 
         * @param {string} outcome (condition outcome options: Hide, Show, Pre-Fill)
         */
        updateSelectedOutcome(outcome = '') {
            //get rid of possible multiselect choices instances for child prefill values
            const elSelectChild = document.getElementById('child_prefill_entry');
            if(elSelectChild?.choicesjs) elSelectChild.choicesjs.destroy();
            this.selectedChildOutcome = outcome.toLowerCase();
            //reset possible prefill and crosswalk data
            this.selectedChildValue = "";
            this.crosswalkFile = "";
            this.crosswalkHasHeader = false;
            this.level2IndID = null;
        },
        /**
         * @param {Object} target (DOM element)
         */
        updateSelectedParentValue(target = {}) {
            const parFormat = this.selectedParentIndicator.format.split('\n')[0].trim().toLowerCase();
            let value = '';
            if (this.multiOptionFormats.includes(parFormat)) {
                const arrSelections = Array.from(target.selectedOptions);
                arrSelections.forEach(sel => {
                    value += sel.label.replaceAll('\r', '').trim() + '\n';
                });
                value = value.trim();
            } else {
                value = target.value;
            }
            this.selectedParentValue = value;
        },
        /**
         * @param {Object} target (DOM element)
         */
        updateSelectedChildValue(target = {}) {
            const childFormat = this.childIndicator.format.split('\n')[0].trim().toLowerCase();
            let value = '';
            if (this.multiOptionFormats.includes(childFormat)) {
                const arrSelections = Array.from(target.selectedOptions);
                arrSelections.forEach(sel => {
                    value += sel.label.replaceAll('\r', '').trim() + '\n';
                });
                value = value.trim();
            } else {
                value = target.value;
            }
            value = XSSHelpers.stripAllTags(value);
            this.selectedChildValue = value;
        }, 
        updateSelectedChildIndicator() {
            const indicator = this.childIndicator;
            const childValueOptions = indicator.format.indexOf("\n") === -1 ?
                [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");

            this.selectedChildValueOptions = childValueOptions.filter(cvo => cvo !== '');

            const headerIndicatorID = parseInt(indicator.headerIndicatorID);
            this.selectableParents = this.indicators.filter(i => {
                const parFormat = i.format?.split('\n')[0].trim().toLowerCase();
                return parseInt(i.headerIndicatorID) === headerIndicatorID &&
                    parseInt(i.indicatorID) !== parseInt(this.childIndicator.indicatorID) &&
                    this.enabledParentFormats.includes(parFormat);
            });
            this.crosswalkLevelTwo = this.indicators.filter((i) => {
                const format = i.format?.split("\n")[0].trim().toLowerCase();
                return (
                    parseInt(i.headerIndicatorID) === headerIndicatorID &&
                    parseInt(i.indicatorID) !== parseInt(this.childIndicator.indicatorID) &&
                    ['dropdown', 'multiselect'].includes(format)
                );
            });
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
            this.selectedParentIndicator = {};
            this.selectedParentOperators = [];
            this.selectedOperator = '';
            this.selectedParentValue = '';
            this.selectedParentValueOptions = [];
            this.selectedChildOutcome = '';
            this.selectedChildValue = '';
            //rm possible child choicesjs instances associated with prior item
            const elSelectChild = document.getElementById('child_prefill_entry');
            if(elSelectChild?.choicesjs) elSelectChild.choicesjs.destroy();
            const elSelectParent = document.getElementById('parent_compValue_entry');
            if(elSelectParent?.choicesjs) elSelectParent.choicesjs.destroy();

            if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
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
                    error:(err)=> {
                        console.log(err);
                    }
                });
            }
        },
        /**
         *
         * @param {Object} data ({confirmDelete:boolean, condition:Object})
         */
        removeCondition(data = {}) {
            if(data.confirmDelete === true) { //delete btn confirm modal
                this.postConditions(false);
             
            } else { //X button select and open the confirm delete modal
                this.selectConditionFromList(data.condition);
                this.showRemoveModal = true;
            }
        },
        /**
         * @param {Object} conditionObj 
         */
        selectConditionFromList(conditionObj = {}) {
            this.selectedConditionJSON = JSON.stringify(conditionObj);

            this.updateSelectedParentIndicator(parseInt(conditionObj?.parentIndID || 0));
            this.selectedOperator = conditionObj?.selectedOp || '';
            this.selectedChildOutcome = conditionObj?.selectedOutcome || '';
            this.selectedParentValue = conditionObj?.selectedParentValue || '';
            this.selectedChildValue = conditionObj?.selectedChildValue || '';
            this.crosswalkFile = conditionObj?.crosswalkFile || '';
            this.crosswalkHasHeader = conditionObj?.crosswalkHasHeader || false;
            this.level2IndID = conditionObj?.level2IndID || null;
            //rm possible child choicesjs instance associated with prior list item
            const elSelectChild = document.getElementById('child_prefill_entry');
            if(elSelectChild?.choicesjs) elSelectChild.choicesjs.destroy();
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
                    break;z
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
            const elSelectParent = document.getElementById('parent_compValue_entry');
            const elSelectChild = document.getElementById('child_prefill_entry');
            
            const childFormat = this.conditions.childFormat;
            const parentFormat = this.conditions.parentFormat;
            const outcome = this.conditions.selectedOutcome;
           
            if(this.multiOptionFormats.includes(parentFormat) && elSelectParent !== null && !elSelectParent.choicesjs) {
                let arrValues = this.conditions.selectedParentValue.split('\n') || [];
                arrValues = arrValues.map(v => this.textValueDisplay(v).trim());

                let options = this.selectedParentValueOptions || [];
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

            if(outcome === 'pre-fill' && this.multiOptionFormats.includes(childFormat) && elSelectChild !== null && elExistingChoicesChild === null) {
                let arrValues = this.conditions.selectedChildValue.split('\n') || [];
                arrValues = arrValues.map(v => this.textValueDisplay(v).trim());
                
                let options = this.selectedChildValueOptions || [];
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
         * @returns {string} lower case base format of the parent question if there is one
         */
        parentFormat() {
            if(this.selectedParentIndicator?.format) {
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
                                            <div v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</div>
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
                        <!-- NOTE: PRE-FILL ENTRY AREA -->
                        <select v-if="conditions.selectedOutcome === 'pre-fill' && (childFormat==='dropdown' || childFormat==='radio')"
                            id="child_prefill_entry"
                            @change="updateSelectedChildValue($event.target)">
                            <option v-if="conditions.selectedChildValue === ''" value="" selected>Select a value</option>
                            <option v-for="val in selectedChildValueOptions" 
                                :value="val"
                                :key="'child_prefill_' + val"
                                :selected="textValueDisplay(conditions.selectedChildValue) === val">
                                {{ val }} 
                            </option>
                        </select>
                        <select v-else-if="conditions.selectedOutcome === 'pre-fill' && (conditions.childFormat === 'multiselect' || childFormat === 'checkboxes')"
                            placeholder="select some options"
                            multiple="true"
                            id="child_prefill_entry"
                            style="display: none;"
                            @change="updateSelectedChildValue($event.target)">
                        </select>
                        <input v-else-if="conditions.selectedOutcome === 'pre-fill' && (childFormat==='text' || childFormat==='textarea')" 
                            id="child_prefill_entry"
                            @change="updateSelectedChildValue($event.target)"
                            :value="textValueDisplay(conditions.selectedChildValue)" />
                    </template>
                </div>
                <div v-if="showSetup" class="if-then-setup">
                    <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                        <h3 style="margin: 0;">IF</h3>
                        <div>
                            <!-- NOTE: PARENT CONTROLLER SELECTION -->
                            <select title="select an indicator" 
                                    @change="updateSelectedParentIndicator($event.target.value)">
                                <option v-if="!conditions.parentIndID" value="" selected>Select an Indicator</option>
                                <option v-for="i in selectableParents" 
                                :title="i.name" 
                                :value="i.indicatorID"
                                :selected="parseInt(conditions.parentIndID) === parseInt(i.indicatorID)"
                                :key="'parent_' + i.indicatorID">
                                {{getIndicatorName(parseInt(i.indicatorID)) }} (indicator {{i.indicatorID}})
                                </option>
                            </select>
                        </div>
                        <div>
                            <!-- NOTE: OPERATOR SELECTION -->
                            <select
                                v-model="selectedOperator">
                                <option v-if="conditions.selectedOp === ''" value="" selected>Select a condition</option>
                                <option v-for="o in selectedParentOperators" 
                                :value="o.val"
                                :key="o.val"
                                :selected="conditions.selectedOp === o.val">
                                {{ o.text }}
                                </option>
                            </select>
                        </div>
                        <div>
                            <!-- NOTE: COMPARED VALUE SELECTION (active parent formats: dropdown, multiselect, radio, checkboxes) -->
                            <select v-if="parentFormat === 'dropdown' || parentFormat==='radio'"
                                id="parent_compValue_entry"
                                @change="updateSelectedParentValue($event.target)">
                                <option v-if="conditions.selectedParentValue === ''" value="" selected>Select a value</option>
                                <option v-for="val in selectedParentValueOptions"
                                    :key="'parent_val_' + val"
                                    :selected="textValueDisplay(conditions.selectedParentValue) === val"> {{ val }}
                                </option>
                            </select>
                            <select v-else-if="parentFormat === 'multiselect' || parentFormat==='checkboxes'"
                                id="parent_compValue_entry"
                                placeholder="select some options" multiple="true"
                                style="display: none;"
                                @change="updateSelectedParentValue($event.target)">
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
                            </select></label>
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