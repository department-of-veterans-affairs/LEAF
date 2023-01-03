export default {
    data() {
        return {
            vueData: { 
                formID: this.currSubformID || this.currCategoryID,
                indicatorID: this.currIndicatorID
            },
            //indicatorOrg: {},  NOTE: keep
            indicators: [],
            selectedParentIndicator: {},
            selectedDisabledParentID: null,
            selectedParentOperators: [],
            selectedOperator: '',
            selectedParentValue: '',
            selectedParentValueOptions: [],   //for radio, dropdown
            childIndicator: {},
            selectableParents: [],
            selectedChildOutcome: '',
            selectedChildValueOptions: [],
            selectedChildValue: '',
            showRemoveConditionModal: false,
            showConditionEditor: false,
            editingCondition: '',
            enabledParentFormats: ['dropdown', 'multiselect']
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'currIndicatorID',
        'currCategoryID',
        'currSubformID',
        'selectedNodeIndicatorID',
        'selectNewCategory',
        'closeFormDialog',
        'truncateText',
    ],
    beforeMount(){
        this.getAllIndicators();
    },
    mounted(){
        //console.log('IFTHEN (form editor) mounted', this.vueData);
    },
    updated() {
        const outcome = this.conditions.selectedOutcome.toLowerCase();
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

                    /* this.indicators.forEach(i => {
                        if (i.parentIndicatorID === null){
                            this.indicatorOrg[i.indicatorID] = {header: i, indicators:{}};
                        }
                    }); //NOTE: keep for later use to make object for organization according to header */
                    this.indicators.forEach(i => { 
                        if (i.parentIndicatorID !== null) { //no need to check headers themselves
                            this.crawlParents(i,i);
                        }    
                    });
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
            //get rid of possible multiselect choices instance and reset parent comparison value
            const elSelectParent = document.getElementById('parent_compValue_entry');
            if(elSelectParent?.choicesjs) elSelectParent.choicesjs.destroy();
            this.selectedParentValue = '';  
            
            const indicator = this.indicators.find(i => indicatorID !== null && parseInt(i.indicatorID) === parseInt(indicatorID));
            //handle scenario if a parent is archived/deleted
            if(indicator === undefined) {
                this.parentFound = false;
                this.selectedDisabledParentID = indicatorID === 0 ? this.selectedDisabledParentID : parseInt(indicatorID);
                return;
            } else {
                this.parentFound = true;
                this.selectedDisabledParentID = null;
            }

            let formatNameAndOptions = indicator.format.split("\n");  //format field has the format name followed by options, separator is \n
            let valueOptions = formatNameAndOptions.length > 1 ? formatNameAndOptions.slice(1) : [];
            valueOptions = valueOptions.map(o => o.trim());  //there are sometimes carriage returns in the array

            this.selectedParentIndicator = {...indicator};
            this.selectedParentValueOptions = valueOptions.filter(vo => vo !== '');

            switch(this.parentFormat) {
                case 'number':
                case 'currency':
                    this.selectedParentOperators = [
                        {val:"==", text: "is equal to"}, 
                        {val:"!=", text: "is not equal to"},
                        {val:">", text: "is greater than"},
                        {val:"<", text: "is less than"},
                    ];
                    break;
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
                case 'checkbox':
                    this.selectedParentOperators = [
                        {val:"==", text: "is checked"}, 
                        {val:"!=", text: "is not checked"}
                    ];
                    break;          
                case 'date':
                    this.selectedParentOperators = [
                        {val:"==", text: "on"}, 
                        {val:">=", text: "on and after"},
                        {val:"<=", text: "on and before"}
                    ];
                    break;
                case 'orgchart_employee':
                case 'orgchart_group':  
                case 'orgchart_position':
                    break;  
                default:
                    this.selectedParentOperators = [
                        {val:"LIKE", text: "contains"}, 
                        {val:"NOT LIKE", text:"does not contain"}
                    ]; 
                    break;
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
            this.selectedChildOutcome = outcome;
            this.selectedChildValue = '';  //reset possible prefill
        },
        /**
         * @param {Object} target (DOM element)
         */
        updateSelectedParentValue(target = {}) {
            const parFormat = this.selectedParentIndicator.format.split('\n')[0].trim();
            let value = '';
            if (parFormat.toLowerCase() === 'multiselect') {
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
            const childFormat = this.childIndicator.format.split('\n')[0].trim();
            let value = '';
            if (childFormat === 'multiselect') {
                const arrSelections = Array.from(target.selectedOptions);
                arrSelections.forEach(sel => {
                    value += sel.label.replaceAll('\r', '').trim() + '\n';
                });
                value = value.trim();
            } else {
                value = target.value;
            }
            this.selectedChildValue = value;
        }, 
        updateSelectedChildIndicator() {

            if(this.vueData.indicatorID !== 0) {
                const indicator = this.indicators.find(i => parseInt(i.indicatorID) === this.vueData.indicatorID);
                const childValueOptions = indicator.format.indexOf("\n") === -1 ? [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
                
                this.childIndicator = {...indicator};
                this.selectedChildValueOptions = childValueOptions.filter(cvo => cvo !== '');

                const headerIndicatorID = parseInt(indicator.headerIndicatorID);
                this.selectableParents = this.indicators.filter(i => {
                    return parseInt(i.headerIndicatorID) === headerIndicatorID && 
                            parseInt(i.indicatorID) !== parseInt(this.childIndicator.indicatorID) &&
                            (i.format.indexOf('dropdown') === 0 || i.format.indexOf('multiselect') === 0);  //dropdowns, multiselect parent only
                });
            }
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}form/_${this.vueData.formID}`,
                success: (res)=> {
                    const form = res;
                    form.forEach((formheader, index) => {
                        this.indicators.forEach(ind => {
                            if (parseInt(ind.headerIndicatorID) === parseInt(formheader.indicatorID)){
                                ind.formPage = index;
                            }
                        })
                    });
                },
                error: (err)=> {
                    console.log(err)
                }
            });
        },
        crawlParents(indicator = {}, initialIndicator = {}) { //ind to get parentID from, 
            const parentIndicatorID = parseInt(indicator.parentIndicatorID);
            const parent = this.indicators.find(i => parseInt(i.indicatorID) === parentIndicatorID);

            if (parent===undefined || parent.parentIndicatorID===null) {
                //add information about the headerIndicatorID to the indicators
                let indToUpdate = this.indicators.find(i => parseInt(i.indicatorID) === parseInt(initialIndicator.indicatorID));
                indToUpdate.headerIndicatorID = parentIndicatorID;
            } else {
                this.crawlParents(parent, initialIndicator);
            }
        },
        newCondition() {
            this.editingCondition = '';
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
        postCondition() {
            const { childIndID }  = this.conditions;
            if (this.conditionComplete) {
                const conditionsJSON = JSON.stringify(this.conditions);
                let indToUpdate = this.indicators.find(i => parseInt(i.indicatorID) === parseInt(childIndID));
                let currConditions = (indToUpdate.conditions === '' || indToUpdate.conditions === null || indToUpdate.conditions === 'null') ?
                    [] : JSON.parse(indToUpdate.conditions);
                let newConditions = currConditions.filter(c => JSON.stringify(c) !== this.editingCondition);

                const isUnique = newConditions.every(c => JSON.stringify(c) !== conditionsJSON);
                if (isUnique){
                    newConditions.push(this.conditions);

                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/${childIndID}/conditions`,
                        data: {
                            conditions: JSON.stringify(newConditions),
                            CSRFToken: this.CSRFToken
                        },
                        success: (res)=> {
                            if (res !== 'Invalid Token.') {
                                /* refetch works, but just updating the obj would be faster
                                //TODO: update conditions of this ind on the form view formnode to update the UI
                                const updatedConditions = (newConditions !== null) ? JSON.stringify(newConditions) : ''; */
                                this.selectNewCategory(this.vueData.formID, this.currSubformID !== null, this.selectedNodeIndicatorID);
                                this.closeFormDialog();
                            } else { console.log('error adding condition', res) }                          
                        },
                        error:(err)=> {
                            console.log(err);
                        }
                    });

                } else {
                    this.closeFormDialog();
                }
            }
        },
        /**
         * 
         * @param {Object} data ({confirmDelete:boolean, condition:Object})
         */
        removeCondition(data = {}) {  
            this.selectConditionFromList(data.condition);

            if(data.confirmDelete === true) { //if user pressed delete btn on the confirm modal
                const { childIndID, parentIndID, selectedOutcome, selectedChildValue } = data.condition;
                
                if (childIndID !== undefined) {
                    const hasActiveParentIndicator = this.indicators.some(ele => parseInt(ele.indicatorID) === parseInt(parentIndID));
                    const conditionsJSON = JSON.stringify(data.condition);

                    //get all conditions on this child
                    let currConditions = JSON.parse(this.indicators.find(i => parseInt(i.indicatorID) === parseInt(childIndID)).conditions) || [];
                    //fixes issues due to data type changes after php8.
                    currConditions.forEach(c => {
                        c.childIndID = parseInt(c.childIndID);
                        c.parentIndID = parseInt(c.parentIndID);
                    });
 
                    //filter out the condition to be rm'd from the indicator's currConditions
                    let newConditions = [];
                    if(hasActiveParentIndicator) {
                        newConditions = currConditions.filter(c => JSON.stringify(c) !== conditionsJSON);
                    } else {
                        newConditions = currConditions.filter(c => !(c.parentIndID === this.selectedDisabledParentID && c.selectedOutcome === selectedOutcome && c.selectedChildValue === selectedChildValue))
                    }
                    
                    if (newConditions.length === 0) newConditions = null;
                    
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/${childIndID}/conditions`,
                        data: {
                            conditions: (newConditions !== null) ? JSON.stringify(newConditions) : '',
                            CSRFToken: this.CSRFToken
                        },
                        success: (res)=> {
                            if (res !== 'Invalid Token.') {
                                this.closeFormDialog()
                                /*
                                //TODO: update conditions of this ind on the form view formnode to update the UI
                                const updatedConditions = (newConditions !== null) ? JSON.stringify(newConditions) : ''; */
                                this.selectNewCategory(this.vueData.formID, this.currSubformID !== null, this.selectedNodeIndicatorID);

                            } else { console.log('error removing condition', res) }
                        },
                        error: (err)=> {
                            console.log(err);
                        }
                    });
                }
             
            } else { //user pressed an X button in a conditions list that opens the confirm delete modal  
                this.showRemoveConditionModal = true;
            }
        },
        /**
         * @param {Object} conditionObj 
         */
        selectConditionFromList(conditionObj = {}){
            //update par and chi ind, other values
            this.editingCondition = JSON.stringify(conditionObj);
            this.showConditionEditor = true;
            this.updateSelectedParentIndicator(parseInt(conditionObj?.parentIndID));
            if(this.parentFound && this.enabledParentFormats.includes(this.parentFormat)) {
                this.selectedOperator = conditionObj?.selectedOp;
                this.selectedParentValue = conditionObj?.selectedParentValue;
            }
            //rm possible child choicesjs instance associated with prior list item
            const elSelectChild = document.getElementById('child_prefill_entry');
            if(elSelectChild?.choicesjs) elSelectChild.choicesjs.destroy();

            this.selectedChildOutcome = conditionObj?.selectedOutcome;
            this.selectedChildValue = conditionObj?.selectedChildValue;
        },
        /**
         * @param {number} id 
         * @returns {string}
         */
        getIndicatorName(id = 0) {
            if (id !== 0) {
                let indicatorName = this.indicators.find(indicator => parseInt(indicator.indicatorID) === id)?.name || '';
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
            const parFormat = condition.parentFormat;
            switch(op){
                case '==':
                    return parFormat === 'multiselect' ? 'includes' : 'is';
                case '!=':
                    return 'is not';
                case '>':
                    return 'is greater than';
                case '<':
                    return 'is less than';    
                default: return op;
            }
        },
        /**
         * returns true if the parentID of the condition is no longer in the list (due to archive or delete)
         * @param {number} childIndID 
         * @returns {boolean}
         */
        isOrphan(childIndID = 0) {
            return !this.selectableParents.some(p => parseInt(p.indicatorID) === childIndID);
        },
        /**
         * @param {Object} condition 
         * @returns {boolean}
         */
        childFormatChangedSinceSave(condition = {}) {
            const childConditionFormat = condition.childFormat;
            const currentIndicatorFormat = this.childIndicator?.format?.split('\n')[0];
            return childConditionFormat?.trim() !== currentIndicatorFormat?.trim();
        },
        /**
         * called when the app updates if the outcome is selected.  Creates choicejs combobox instances for multiselect format select boxes
         */
        updateChoicesJS() {
            const elExistingChoicesChild = document.querySelector('#outcome-editor > div.choices');
            const elSelectParent = document.getElementById('parent_compValue_entry');
            const elSelectChild = document.getElementById('child_prefill_entry');
            
            const childFormat = this.conditions.childFormat.toLowerCase();
            const parentFormat = this.conditions.parentFormat.toLowerCase();
            const outcome = this.conditions.selectedOutcome.toLowerCase();
           
            if(parentFormat === 'multiselect' && elSelectParent !== null && !elSelectParent.choicesjs) {
                let arrValues = this.conditions?.selectedParentValue.split('\n') || [];
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

            if(outcome === 'pre-fill' && childFormat === 'multiselect' && elSelectChild !== null && elExistingChoicesChild === null) {
                let arrValues = this.conditions?.selectedChildValue.split('\n') || [];
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
            this.postCondition();
        }
    },
    computed: {
        /**
         * 
         * @returns {string} base format of the parent question (dropdown, multiselect)
         */
        parentFormat() {
            if(this.selectedParentIndicator?.format) {
                const f = this.selectedParentIndicator.format.toLowerCase();
                return f.split('\n')[0].trim();
            } else return '';
        },
        /**
         * 
         * @returns {string} base format of the child question (dropdown, multiselect, text)
         */
        childFormat() {
            if(this.childIndicator?.format){
                const f = this.childIndicator.format.toLowerCase();
                return f.split('\n')[0].trim();
            } else return '';
        },
        /**
         * 
         * @returns {Object} current conditions object
         */
        conditions() {
            const childIndID  = this.childIndicator?.indicatorID || 0;
            const parentIndID = this.selectedParentIndicator?.indicatorID || 0;            
            const selectedOp = this.selectedOperator;
            const selectedParentValue = this.selectedParentValue;
            const selectedOutcome = this.selectedChildOutcome;
            const selectedChildValue = this.selectedChildValue;
            const childFormat = this.childFormat;
            const parentFormat = this.parentFormat;
            return {
                childIndID, parentIndID, selectedOp, 
                selectedParentValue, selectedChildValue, selectedOutcome,
                childFormat, parentFormat
            }    
        },
        /**
         * 
         * @returns {boolean} if all required fields are entered for the current condition type
         */
        conditionComplete() {
            const {childIndID, parentIndID, selectedOp, selectedParentValue, 
                selectedChildValue, selectedOutcome} = this.conditions;
            
            const isComplete = (
                    childIndID !== 0 && parentIndID !== 0 && 
                    selectedOp !== '' && selectedParentValue !== '' &&
                    (selectedOutcome && selectedOutcome.toLowerCase() !== "pre-fill" ||
                    (selectedOutcome.toLowerCase() === "pre-fill" && selectedChildValue !== ''))
                );
            const elSave = document.getElementById('button_save');
            if (elSave !== null) elSave.style.display = isComplete ? 'block' : 'none';

            return isComplete;
        },
        /**
         * 
         * @returns {Array} of condition objects
         */
        savedConditions() {
            return this.childIndicator.conditions ? JSON.parse(this.childIndicator.conditions)
                    : [];
        },
        /**
         * 
         * @returns {Object}
         */
        conditionTypes() {
            const show = this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === 'show');
            const hide = this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === 'hide');
            const prefill = this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === 'pre-fill');

            return {show,hide,prefill};
        }
    },
    watch: {
        showRemoveConditionModal(newVal) {
            const elSaveDiv = document.getElementById('leaf-vue-dialog-cancel-save');
            if (elSaveDiv !== null) elSaveDiv.style.display = newVal === true ? 'none' : 'flex';
        }
    },
    template: `<div id="condition_editor_center_panel">

            <!-- NOTE: MAIN EDITOR TEMPLATE -->
            <div id="condition_editor_inputs">
                <div>
                    <ul v-if="savedConditions && savedConditions.length > 0 && !showRemoveConditionModal" 
                        id="savedConditionsList">
                        <!-- NOTE: SHOW LIST -->
                        <div v-if="conditionTypes.show.length > 0">
                            <p style="margin-bottom: 0.5rem;"><b>This field will be hidden except:</b></p>
                            <li v-for="c in conditionTypes.show" :key="c" class="savedConditionsCard">
                                <button @click="selectConditionFromList(c)" class="btnSavedConditions" 
                                    :class="{selectedConditionEdit: JSON.stringify(c) === editingCondition, isOrphan: isOrphan(parseInt(c.parentIndID))}">
                                    <span v-if="!isOrphan(parseInt(c.parentIndID))">
                                        If '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                        {{getOperatorText(c)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                        then show this question.
                                        <span v-if="childFormatChangedSinceSave(c)" class="changesDetected"><br/>
                                        The format of this question has changed.  
                                        Please review and save it to update</span>
                                    </span>
                                    <span v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</span>
                                </button>
                                <button style="width: 1.75em;"
                                class="btn_remove_condition"
                                @click="removeCondition({confirmDelete: false, condition: c})">X
                                </button>
                            </li>
                        </div>
                        <!-- NOTE: HIDE LIST -->
                        <div v-if="conditionTypes.hide.length > 0">
                            <p style="margin-bottom: 0.5rem;"><b>This field will be shown except:</b></p>
                            <li v-for="c in conditionTypes.hide" :key="c" class="savedConditionsCard">
                                <button @click="selectConditionFromList(c)" class="btnSavedConditions" 
                                    :class="{selectedConditionEdit: JSON.stringify(c) === editingCondition, isOrphan: isOrphan(parseInt(c.parentIndID))}">
                                    <span v-if="!isOrphan(parseInt(c.parentIndID))">
                                        If '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                        {{getOperatorText(c)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                        then hide this question.
                                        <span v-if="childFormatChangedSinceSave(c)" class="changesDetected"><br/>
                                        The format of this question has changed.  
                                        Please review and save it to update</span>
                                    </span>
                                    <span v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</span>
                                </button>
                                <button style="width: 1.75em;"
                                class="btn_remove_condition"
                                @click="removeCondition({confirmDelete: false, condition: c})">X
                                </button>
                            </li>
                        </div>
                        <!-- NOTE: PREFILL LIST -->
                        <div v-if="conditionTypes.prefill.length > 0">
                            <p style="margin-bottom: 0.5rem;"><b>This field will be pre-filled:</b></p>
                            <li v-for="c in conditionTypes.prefill" :key="c" class="savedConditionsCard">
                                <button @click="selectConditionFromList(c)" class="btnSavedConditions" 
                                    :class="{selectedConditionEdit: JSON.stringify(c) === editingCondition, isOrphan: isOrphan(parseInt(c.parentIndID))}">
                                    <span v-if="!isOrphan(parseInt(c.parentIndID))">
                                        If '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                        {{getOperatorText(c)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                        then this question will be <strong>{{ textValueDisplay(c.selectedChildValue) }}</strong>
                                        <span v-if="childFormatChangedSinceSave(c)" class="changesDetected"><br/>
                                        The format of this question has changed.  
                                        Please review and save it to update</span>
                                    </span>
                                    <span v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</span>
                                </button>
                                <button style="width: 1.75em;"
                                    class="btn_remove_condition"
                                    @click="removeCondition({confirmDelete: false, condition: c})">X
                                </button>
                            </li>
                        </div>
                    </ul>
                    <button v-if="!showRemoveConditionModal" @click="newCondition" class="btnNewCondition">+ New Condition</button>
                    <div v-if="showRemoveConditionModal">
                        <div>Choose <b>Delete</b> to confirm removal, or <b>cancel</b> to return</div>
                        <ul style="display: flex; justify-content: space-between; margin-top: 1em">
                            <li style="width: 30%;">
                                <button class="btn_remove_condition" @click="removeCondition({confirmDelete: true, condition: conditions })">Delete</button>
                            </li>
                            <li style="width: 30%;">
                                <button id="btn_cancel" @click="showRemoveConditionModal=false">Cancel</button>
                            </li>
                        </ul>
                    </div>
                </div>
                <div v-if="!showRemoveConditionModal && showConditionEditor" id="outcome-editor">
                    <!-- OUTCOME SELECTION -->
                    <span v-if="conditions.childIndID" class="input-info">Select an outcome</span>
                    <select v-if="conditions.childIndID" title="select outcome"
                            name="child-outcome-selector"
                            @change="updateSelectedOutcome($event.target.value)">
                            <option v-if="conditions.selectedOutcome === ''" value="" selected>Select an outcome</option> 
                            <option value="Show" :selected="conditions.selectedOutcome.toLowerCase() === 'show'">Hide this question except ...</option>
                            <option value="Hide" :selected="conditions.selectedOutcome.toLowerCase() === 'hide'">Show this question except ...</option>
                            <option value="Pre-fill" :selected="conditions.selectedOutcome.toLowerCase() === 'pre-fill'">Pre-fill this Question</option>
                    </select>
                    <span v-if="conditions.selectedOutcome.toLowerCase() === 'pre-fill'" class="input-info">Enter a pre-fill value</span>
                    <!-- NOTE: PRE-FILL ENTRY AREA dropdown, multidropdown, text -->
                    <select v-if="conditions.selectedOutcome.toLowerCase() === 'pre-fill' && childFormat === 'dropdown'"
                        name="child-prefill-value-selector"
                        id="child_prefill_entry"
                        @change="updateSelectedChildValue($event.target)">
                        <option v-if="conditions.selectedChildValue === ''" value="" selected>Select a value</option>    
                        <option v-for="val in selectedChildValueOptions" 
                            :value="val"
                            :key="val"
                            :selected="textValueDisplay(conditions.selectedChildValue) === val">
                            {{ val }} 
                        </option>
                    </select>
                    <select v-else-if="conditions.selectedOutcome.toLowerCase() === 'pre-fill' && conditions.childFormat === 'multiselect'"
                        placeholder="select some options"
                        multiple="true"
                        id="child_prefill_entry"
                        style="display: none;"
                        name="child-prefill-value-selector"
                        @change="updateSelectedChildValue($event.target)">   
                    </select>
                    <input v-else-if="conditions.selectedOutcome.toLowerCase() === 'pre-fill' && childFormat === 'text'" 
                        id="child_prefill_entry"
                        @change="updateSelectedChildValue($event.target)"
                        :value="textValueDisplay(conditions.selectedChildValue)" />
                </div>
                <div v-if="!showRemoveConditionModal && showConditionEditor && selectableParents.length > 0"
                    class="if-then-setup">
                    <h4 style="margin: 0;">IF</h4>
                    <div>
                        <!-- NOTE: PARENT CONTROLLER SELECTION -->
                        <select title="select an indicator" 
                                name="indicator-selector" 
                                @change="updateSelectedParentIndicator($event.target.value)">
                            <option v-if="!conditions.parentIndID" value="" selected>Select an Indicator</option>        
                            <option v-for="i in selectableParents" 
                            :title="i.name" 
                            :value="i.indicatorID"
                            :selected="parseInt(conditions.parentIndID) === parseInt(i.indicatorID)"
                            :key="i.indicatorID">
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
                        <!-- NOTE: COMPARED VALUE SELECTION (active parent formats: dropdown, multiselect) -->
                        <select v-if="parentFormat === 'dropdown'"
                            id="parent_compValue_entry"
                            @change="updateSelectedParentValue($event.target)">
                            <option v-if="conditions.selectedParentValue === ''" value="" selected>Select a value</option>    
                            <option v-for="val in selectedParentValueOptions"
                                :key="val"
                                :selected="textValueDisplay(conditions.selectedParentValue) === val"> {{ val }}
                            </option>
                        </select>
                        <select v-else-if="parentFormat === 'multiselect'"
                            id="parent_compValue_entry"
                            placeholder="select some options" multiple="true"
                            style="display: none;"
                            @change="updateSelectedParentValue($event.target)">
                        </select>
                    </div>
                </div>
                <div v-if="conditionComplete"><h4 style="margin: 0; display:inline-block">THEN</h4> '{{getIndicatorName(vueData.indicatorID)}}'
                    <span v-if="conditions.selectedOutcome.toLowerCase() === 'pre-fill'">will 
                    <span style="color: #00A91C; font-weight: bold;"> have the value{{childFormat === 'multiselect' ? '(s)':''}} '{{textValueDisplay(conditions.selectedChildValue)}}'</span>
                    </span>
                    <span v-else>will 
                        <span style="color: #00A91C; font-weight: bold;">
                        be {{conditions.selectedOutcome === "Show" ? 'shown' : 'hidden'}}
                        </span>
                    </span>
                </div>
                <div v-if="selectableParents.length < 1">No options are currently available for the indicators on this form</div>
            </div>
        </div>` 
}