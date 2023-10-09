export default {
    name: 'conditions-editor-dialog',
    data() {
        return {
            requiredDataProperties: ['indicatorID'],
            indicators: [],
            appIsLoadingIndicators: true,
            parentIndID: 0,
            selectedOperator: '',
            selectedParentValue: '',
            selectedOutcome: '',
            selectedChildValue: '',
            showRemoveModal: false,
            showConditionEditor: false,
            selectedConditionJSON: '',
            enabledParentFormats: ['dropdown', 'multiselect', 'radio', 'checkboxes'],
            multiOptionFormats: ['multiselect', 'checkboxes'],
            orgchartFormats: ["orgchart_employee","orgchart_group","orgchart_position"],
            orgchartSelectData: {},
            crosswalkFile: '',
            crosswalkHasHeader: false,
            level2IndID: null,
            noPrefillFormats: ['', 'fileupload', 'image']
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'dialogData',
        'checkRequiredData',
        'focusedFormRecord',
        'getFormByCategoryID',
        'closeFormDialog',
        'truncateText',
        'decodeAndStripHTML',
        'fileManagerTextFiles',
        'initializeOrgSelector'
    ],
    created() {
        this.checkRequiredData(this.requiredDataProperties);
        this.setDialogSaveFunction(this.onSave);
        this.getFormIndicators();
    },
    mounted() {
        const elSaveDiv = document.querySelector('#leaf-vue-dialog-cancel-save #button_save');
        if (elSaveDiv !== null) elSaveDiv.style.display = 'none';
    },
    methods: {
        getFormIndicators(){
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}form/indicator/list/unabridged`,
                success: (res)=> {
                    const filteredList = res.filter(
                        ele => parseInt(ele.indicatorID) > 0 && parseInt(ele.isDisabled) === 0 && ele.categoryID === this.formID
                    );
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
        * @param {number} indicatorID
        */
        updateSelectedParentIndicator(indicatorID = 0) {
            this.parentIndID = indicatorID;
            if(!this.selectedParentValueOptions.includes(this.selectedParentValue)) {
                this.selectedParentValue = "";
            }
            this.updateChoicesJS();
        },
        /**
         * @param {string} outcome (condition outcome options: Hide, Show, Pre-Fill)
         */
        updateSelectedOutcome(outcome = '') {
            this.selectedOutcome = outcome.toLowerCase();
            this.selectedChildValue = "";
            this.crosswalkFile = "";
            this.crosswalkHasHeader = false;
            this.level2IndID = null;
            if(this.selectedOutcome === 'pre-fill') {
                this.updateChoicesJS();
                this.addOrgSelector();
            }
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
            this.parentIndID = 0;
            this.selectedParentValue = '';
            this.selectedOutcome = '';
            this.selectedChildValue = '';
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
                    url: `${this.APIroot}formEditor/${this.childIndID}/conditions`,
                    data: {
                        conditions: newConditions.length > 0 ? JSON.stringify(newConditions) : '',
                        CSRFToken: this.CSRFToken
                    },
                    success: (res)=> {
                        if (res !== 'Invalid Token.') {
                            this.getFormByCategoryID(this.formID);
                            this.closeFormDialog();
                        } else { console.log('error adding condition', res) }
                    },
                    error:(err) => console.log(err)
                });
            }
        },
        /**
         * @param {Object} (destructured object {confirmDelete:boolean, condition:Object})
         */
        removeCondition({confirmDelete = false, condition = {}} = {}) {
            if(confirmDelete === true) { //delete btn confirm modal
                this.postConditions(false);
            } else { //X button select from list and open the confirm delete modal
                this.selectConditionFromList(condition);
                this.showRemoveModal = true;
            }
        },
        /**
         * store the selected condition in a string and update associated app values
         * @param {Object} conditionObj 
         */
        selectConditionFromList(conditionObj = {}) {
            this.selectedConditionJSON = JSON.stringify(conditionObj);
            this.parentIndID = parseInt(conditionObj?.parentIndID || 0);
            this.selectedOperator = conditionObj?.selectedOp || '';
            this.selectedOutcome = (conditionObj?.selectedOutcome || '').toLowerCase();
            this.selectedParentValue = conditionObj?.selectedParentValue || '';
            this.selectedChildValue = conditionObj?.selectedChildValue || '';
            this.crosswalkFile = conditionObj?.crosswalkFile || '';
            this.crosswalkHasHeader = conditionObj?.crosswalkHasHeader || false;
            this.level2IndID = conditionObj?.level2IndID || null;
            this.showConditionEditor = true;
            this.updateChoicesJS();
            this.addOrgSelector();
        },
        /**
         * @param {number} id 
         * @returns {string}
         */
        getIndicatorName(id = 0) {
            let indicatorName = this.indicators.find(i => parseInt(i.indicatorID) === id)?.name || "";
            indicatorName = this.decodeAndStripHTML(indicatorName);
            return this.truncateText(indicatorName);
        },
        /**
         * @param {Object} condition 
         * @returns {string}
         */
        getOperatorText(condition = {}) {
            const parFormat = condition.parentFormat.toLowerCase();
            let text = condition.selectedOp;
            switch(text) {
                case '==':
                    text = this.multiOptionFormats.includes(parFormat) ? 'includes' : 'is';
                    break;
                case '!=':
                    text = this.multiOptionFormats.includes(parFormat) ? 'does not include' : 'is not';
                    break;
                default:
                    break;
            }
            return text;
        },
        /**
         * @param {object} condition
         * @returns {boolean} is parent for a non-crosswalk outcome not in the list of selectable parents
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
         * @returns {boolean} whether the child or parent format does not match that of the condition
         */
        childFormatChangedSinceSave(condition = {}) {
            const savedChildFormat = (condition?.childFormat || '').toLowerCase().trim();
            const savedParentFormat = (condition?.parentFormat || '').toLowerCase().trim();
            const savedParIndID = parseInt(condition?.parentIndID || 0);
            const parentInd = this.selectableParents.find(
                p => parseInt(p.indicatorID) === savedParIndID
            );
            const parentIndFormat = (parentInd?.format || '')
                .toLowerCase()
                .split('\n')[0].trim();

            return savedChildFormat !== this.childFormat || savedParentFormat !== parentIndFormat;
        },
        /**
         * called to create choicejs combobox instances for multi option formats
         */
        updateChoicesJS() {
            setTimeout(() => {
                const elExistingChoicesChild = document.querySelector('#child_choices_wrapper > div.choices');
                const elSelectParent = document.getElementById('parent_compValue_entry_multi');
                const elSelectChild = document.getElementById('child_prefill_entry_multi');
                const outcome = this.conditions.selectedOutcome;

                if(this.multiOptionFormats.includes(this.parentFormat) &&
                    elSelectParent !== null &&
                    !(elSelectParent?.choicesjs?.initialised === true)
                ) {
                    let arrValues = this.conditions.selectedParentValue.split('\n') || [];
                    arrValues = arrValues.map(v => this.decodeAndStripHTML(v).trim());

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
                    arrValues = arrValues.map(v => this.decodeAndStripHTML(v).trim());

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
            });
        },
        addOrgSelector() {
            if (this.selectedOutcome === 'pre-fill' && this.orgchartFormats.includes(this.childFormat)) {
                const selType = this.childFormat.slice(this.childFormat.indexOf('_') + 1);
                setTimeout(() => {
                    this.initializeOrgSelector(
                        selType, this.childIndID, 'ifthen_child_', this.selectedChildValue, this.setOrgSelChildValue
                    );
                });
            }
        },
        setOrgSelChildValue(orgSelector = {}) {
            if(orgSelector.selection !== undefined) {
                this.orgchartSelectData = orgSelector.selectionData[orgSelector.selection];
                this.selectedChildValue = orgSelector.selection.toString();
            }
        },
        onSave() {
            this.postConditions(true);
        }
    },
    computed: {
        formID() {
            return this.focusedFormRecord.categoryID;
        },
        showSetup() {
            return  this.showConditionEditor && this.selectedOutcome &&
                (this.selectedOutcome === 'crosswalk' || this.selectableParents.length > 0);
        },
        noOptions() {
            return !['', 'crosswalk'].includes(this.selectedOutcome) && this.selectableParents.length < 1;
        },
        childIndID() {
            return this.dialogData.indicatorID;
        },
        childIndicator() {
            return this.indicators.find(i => parseInt(i.indicatorID) === this.childIndID);
        },
        /**
         * @returns {object} current parent selection
         */
        selectedParentIndicator() {
            const indicator = this.selectableParents.find(
                i => parseInt(i.indicatorID) === parseInt(this.parentIndID)
            );
            return indicator === undefined ? {} : {...indicator};
        },
        /**
         * @returns {string} lower case base format of the parent question if there is one
         */
        parentFormat() {
            const f = (this.selectedParentIndicator?.format || '').toLowerCase();
            return f.split('\n')[0].trim();
        },
        /**
         * @returns {string} lower case base format of the child question
         */
        childFormat() {
            const f = (this.childIndicator?.format || '').toLowerCase();
            return f.split('\n')[0].trim();
        },
        /**
         * @returns list of indicators that are on the same page, enabled as parents, and different than child 
         */
        selectableParents() {
            const headerIndicatorID = this.childIndicator?.headerIndicatorID || 0;
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
                default:
                    operators = [
                        {val:"==", text: "is"},
                        {val:"!=", text: "is not"}
                    ];
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
        childPrefillDisplay() {
            let returnVal = '';
            switch(this.childFormat) {
                case 'orgchart_employee':
                    returnVal = ` '${this.orgchartSelectData?.firstName || ''} ${this.orgchartSelectData?.lastName || ''}'`;
                    break;
                case 'orgchart_group':
                    returnVal = ` '${this.orgchartSelectData?.groupTitle || ''}'`;
                    break;
                case 'orgchart_position':
                    returnVal = ` '${this.orgchartSelectData?.positionTitle || ''}'`;
                    break;
                case 'multiselect':
                case 'checkboxes':
                    const pluralTxt = this.selectedChildValue.split('\n').length > 1 ? 's' : '';
                    returnVal = `${pluralTxt} '${this.decodeAndStripHTML(this.selectedChildValue)}'`;
                    break;
                default:
                    returnVal = ` '${this.decodeAndStripHTML(this.selectedChildValue)}'`;
                    break;
            }
            return returnVal;
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
                selectedOutcome: this.selectedOutcome.toLowerCase(),
                crosswalkFile: this.crosswalkFile,
                crosswalkHasHeader: this.crosswalkHasHeader,
                level2IndID: this.level2IndID,
                childFormat: this.childFormat,
                parentFormat: this.parentFormat
            }    
        },
        /**
         * @returns {boolean} if all required fields are entered for the current condition type
         */
        conditionComplete() {
            const {
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
                        returnValue = parentIndID !== 0
                                    && selectedOp !== ""
                                    && selectedParentValue !== ""
                                    && selectedChildValue !== "";
                        break;
                    case 'hide':
                    case 'show':
                        returnValue = parentIndID !== 0
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
         * @returns {Array} of conditions where conditions is a string rep of array.  Accounts for prior import issue
         */
        savedConditions() {
            return typeof this.childIndicator.conditions === 'string' && this.childIndicator.conditions[0] === '[' ?
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
            <div v-if="appIsLoadingIndicators" id="loader_spinner">
                Loading... <img src="../images/largespinner.gif" alt="loading..." />
            </div>
            <div v-else id="condition_editor_inputs">
                <!-- NOTE: DELETION DIALOG -->
                <div v-if="showRemoveModal" style="margin-bottom: -0.75rem;">
                    <div>Choose <b>Delete</b> to confirm removal, or <b>cancel</b> to return</div>
                    <div style="display: flex; justify-content: space-between; margin-top: 2rem">
                        <button type="button" class="btn_remove_condition" style="width: 120px;"
                            @click="removeCondition({confirmDelete: true, condition: {}})">
                            Delete
                        </button>
                        <button type="button" class="btn-general" style="width: 120px;" @click="showRemoveModal=false">
                            Cancel
                        </button>
                    </div>
                </div>
                <template v-else>
                    <!-- NOTE: LISTS BY CONDITION TYPE -->
                    <div v-if="savedConditions.length > 0" id="savedConditionsLists">
                        <template v-for="typeVal, typeKey in conditionTypes" :key="typeVal">
                            <template v-if="typeVal.length > 0">
                                <p><b>{{ listHeaderText(typeKey) }}</b></p>
                                <ul style="margin-bottom: 1rem;">
                                    <li v-for="c in typeVal" :key="c" class="savedConditionsCard">
                                        <button type="button" @click="selectConditionFromList(c)" class="btnSavedConditions" 
                                            :class="{selectedConditionEdit: JSON.stringify(c) === selectedConditionJSON, isOrphan: isOrphan(c)}">
                                            <template v-if="!isOrphan(c)">
                                                <div v-if="c.selectedOutcome.toLowerCase() !== 'crosswalk'">
                                                    If '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                                    {{getOperatorText(c)}} <strong>{{ decodeAndStripHTML(c.selectedParentValue) }}</strong> 
                                                    then {{c.selectedOutcome}} this question.
                                                </div>
                                                <div v-else>Options for this question will be loaded from <b>{{ c.crosswalkFile }}</b></div>
                                                <div v-if="childFormatChangedSinceSave(c)" class="changesDetected">
                                                    Format changes detected.  Please review and save to update this condition.
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
                    <button type="button" @click="newCondition" class="btn-confirm new">+ New Condition</button>
                    <!-- NOTE: OUTCOME SELECTION and PREFILL AREAS -->
                    <div v-if="showConditionEditor" id="outcome-editor">
                        <span class="input-info">Select an outcome</span>
                        <select title="select outcome" @change="updateSelectedOutcome($event.target.value)">
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
                        <template v-if="!noOptions && conditions.selectedOutcome === 'pre-fill'">
                            <span class="input-info">Enter a pre-fill value</span>
                            <select v-if="childFormat==='dropdown' || childFormat==='radio'"
                                id="child_prefill_entry_single"
                                @change="updateSelectedOptionValue($event.target, 'child')">
                                <option v-if="conditions.selectedChildValue === ''" value="" selected>Select a value</option>
                                <option v-for="val in selectedChildValueOptions" 
                                    :value="val"
                                    :key="'child_prefill_' + val"
                                    :selected="decodeAndStripHTML(conditions.selectedChildValue) === val">
                                    {{ val }} 
                                </option>
                            </select>
                            <div v-else-if="multiOptionFormats.includes(childFormat)"
                                id="child_choices_wrapper" :key="'prefill_' + selectedConditionJSON">
                                <select v-if="childFormat === 'multiselect' || childFormat === 'checkboxes'"
                                    placeholder="select some options"
                                    multiple="true"
                                    id="child_prefill_entry_multi"
                                    style="display: none;"
                                    @change="updateSelectedOptionValue($event.target, 'child')">
                                </select>
                            </div>
                            <input v-if="childFormat==='text' || childFormat==='textarea'" 
                                id="child_prefill_entry_text"
                                @change="updateSelectedOptionValue($event.target, 'child')"
                                :value="decodeAndStripHTML(conditions.selectedChildValue)" />
                            <div v-if="orgchartFormats.includes(childFormat)" :id="'ifthen_child_orgSel_' + conditions.childIndID"
                                style="min-height:30px" aria-labelledby="prefill_value_entry">
                            </div>
                        </template>
                    </div>
                    <div v-if="showSetup" id="if-then-setup">
                        <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                            <h3 style="margin: 0;">IF</h3>
                            <!-- NOTE: PARENT CONTROLLER SELECTION -->
                            <select title="select an indicator" @change="updateSelectedParentIndicator(parseInt($event.target.value))">
                                <option v-if="!conditions.parentIndID" :value="0" selected>Select an Indicator</option>
                                <option v-for="i in selectableParents" :key="'parent_' + i.indicatorID"
                                :title="i.name"
                                :value="i.indicatorID">
                                {{getIndicatorName(parseInt(i.indicatorID)) }} (indicator {{i.indicatorID}})
                                </option>
                            </select>
                            <!-- NOTE: OPERATOR SELECTION -->
                            <select v-model="selectedOperator">
                                <option v-if="conditions.selectedOp === ''" value="" selected>Select a condition</option>
                                <option v-for="o in selectedParentOperators" :key="o.val" :value="o.val" >
                                {{ o.text }}
                                </option>
                            </select>
                            <!-- NOTE: COMPARED VALUE SELECTIONS -->
                            <select v-if="parentFormat === 'dropdown' || parentFormat==='radio'"
                                id="parent_compValue_entry_single"
                                @change="updateSelectedOptionValue($event.target, 'parent')">
                                <option v-if="conditions.selectedParentValue === ''" value="" selected>Select a value</option>
                                <option v-for="val in selectedParentValueOptions"
                                    :key="'parent_val_' + val"
                                    :selected="decodeAndStripHTML(conditions.selectedParentValue) === val"> {{ val }}
                                </option>
                            </select>
                            <div v-else-if="parentFormat==='multiselect' || parentFormat==='checkboxes'"
                                id="parent_choices_wrapper" class="comparison"
                                :key="'comp_' + selectedConditionJSON">
                                <select id="parent_compValue_entry_multi"
                                    placeholder="select some options" multiple="true"
                                    style="display: none;"
                                    @change="updateSelectedOptionValue($event.target, 'parent')">
                                </select>
                            </div>
                        </template>
                        <!-- NOTE: LOADED DROPDOWNS AND CROSSWALKS -->
                        <div v-else class="crosswalks">
                            <label for="select-crosswalk-file">File&nbsp;
                                <select v-model="crosswalkFile" id="select-crosswalk-file" style="width: 200px;">
                                    <option value="">Select a file</option>
                                    <option v-for="f in fileManagerTextFiles" :key="f" :value="f">{{f}}</option>
                                </select>
                            </label>
                            <label for="select-crosswalk-header">Does file contain headers?&nbsp;
                                <select v-model="crosswalkHasHeader" style="width:60px;" id="select-crosswalk-header">
                                    <option :value="false">No</option>
                                    <option :value="true">Yes</option>
                                </select>
                            </label>
                            <label for="select-level-two">Controlled Dropdown&nbsp;
                                <select v-model.number="level2IndID" id="select-level-two" style="width: 200px;">
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
                    <div v-if="conditionComplete">
                        <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                            <h3 style="margin: 0; display:inline-block">THEN</h3> '{{getIndicatorName(childIndID)}}'
                            <span v-if="conditions.selectedOutcome === 'pre-fill'">will 
                            <span style="color: #008010; font-weight: bold;"> have the value{{childPrefillDisplay}}</span>
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
                </template>
            </div>
        </div>` 
}