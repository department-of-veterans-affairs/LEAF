const ConditionsEditor = Vue.createApp({
    data() {
        return {
            vueData: vueData,  //init {formID: 0, indicatorID: 0, updateIndicatorList: false}  indID is always set to a number
            windowTop: 0,
            //indicatorOrg: {},  NOTE: keep
            indicators: [],  //.indicatorID is now type number. isDisabled is type number
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
            editingCondition: ''
        }
    },
    beforeMount(){
        this.getAllIndicators();
    },
    mounted(){
        document.addEventListener('scroll', this.onScroll);
    },
    beforeUnmount(){
        document.removeEventListener('scroll', this.onScroll);
    },
    methods: {
        onScroll(){
            if (this.vueData.indicatorID !== 0) return;
            this.windowTop = window.top.scrollY;
        },
        getAllIndicators(){
            //get all enabled indicators + headings
            $.ajax({
                type: 'GET',
                url: '../api/form/indicator/list/unabridged',
                success: (res)=> {
                    const list = res;
                    const filteredList = list.filter(ele => parseInt(ele.indicatorID) > 0 && parseInt(ele.isDisabled)===0);
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
                    this.vueData.updateIndicatorList = false;
                },
                error: (err)=> {
                    console.log(err)
                }
            });
        },
        clearSelections(resetAll = false){
            //cleared when either the form or child indicator changes
            if(resetAll){
                this.vueData.indicatorID = 0;
                this.showConditionEditor = false;
            }
            this.selectedParentIndicator = {};
            this.parentFound = true;
            this.selectedParentOperators = [];
            this.selectedOperator = '';
            this.selectedParentValueOptions = [];  //parent values if radio, dropdown, etc
            this.selectedParentValue = '';
            this.childIndicator = {};
            this.selectableParents = [],
            this.selectedChildOutcome = '';
            this.selectedChildValueOptions = [];
            this.selectedChildValue = '';
            this.editingCondition = '';
        },
        updateSelectedParentIndicator(indicatorID){
            const indicator = this.indicators.find(i => indicatorID !== null && parseInt(i.indicatorID) === parseInt(indicatorID));
            //handle scenario if a parent is archived/deleted
            if(indicator===undefined) {
                this.parentFound = false;
                this.selectedDisabledParentID = indicatorID===0 ? this.selectedDisabledParentID : indicatorID;
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
                case 'orgchart_employee': //NOTE: currently excluded from indicator selection
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
        updateSelectedOutcome(outcome){
            this.selectedChildOutcome = outcome;
            this.selectedChildValue = '';  //reset possible prefill
        },
        updateSelectedOperator(operator){
            this.selectedOperator = operator;
        },
        updateSelectedParentValue(value){
            this.selectedParentValue = value;
        },
        updateSelectedChildValue(value){
            this.selectedChildValue = value;
        }, 
        updateSelectedChildIndicator(){
            this.clearSelections();
            this.selectedChildOutcome = '';
            this.selectedChildValue = '';

            if(this.vueData.indicatorID !== 0) {
                this.dragElement(document.getElementById("condition_editor_center_panel"));
                const indicator = this.indicators.find(i => parseInt(i.indicatorID) === this.vueData.indicatorID);
                const childValueOptions = indicator.format.indexOf("\n") === -1 ? [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
                
                this.childIndicator = {...indicator};
                this.selectedChildValueOptions = childValueOptions.filter(cvo => cvo !== '');

                const headerIndicatorID = parseInt(indicator.headerIndicatorID);
                this.selectableParents = this.indicators.filter(i => {
                    return parseInt(i.headerIndicatorID) === headerIndicatorID && 
                            parseInt(i.indicatorID) !== parseInt(this.childIndicator.indicatorID) &&
                            i.format.indexOf('dropdown') === 0;  //parents are currently dropdowns only
                });
            }
            $.ajax({
                type: 'GET',
                url: `../api/form/_${this.vueData.formID}`,
                success: (res)=> {
                    const form = res;
                    form.forEach((formheader, index) => {
                        this.indicators.forEach(ind => {
                            if (parseInt(ind.headerIndicatorID)===parseInt(formheader.indicatorID)){
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
        crawlParents(indicator, initialIndicator) { //ind to get parentID from, 
            const parentIndicatorID = parseInt(indicator.parentIndicatorID);
            const parent = this.indicators.find(i => parseInt(i.indicatorID) === parentIndicatorID);

            if (!parent || !parent.parentIndicatorID) {
                //debug this.indicatorOrg[parentIndicatorID].indicators[initialIndicator.indicatorID] = {...initialIndicator, headerIndicatorID: parentIndicatorID};
                //add information about the headerIndicatorID to the indicators
                let indToUpdate = this.indicators.find(i => parseInt(i.indicatorID)===parseInt(initialIndicator.indicatorID));
                indToUpdate.headerIndicatorID = parentIndicatorID;
            } else {
                this.crawlParents(parent, initialIndicator);
            }
        },
        newCondition(){
            this.editingCondition = '';
            this.showConditionEditor = true;
            this.selectedParentIndicator = {};
            this.selectedParentOperators = [];
            this.selectedOperator = '';
            this.selectedParentValue = '';
            this.selectedParentValueOptions = [];
            this.selectedChildOutcome = '';
            this.selectedChildValue = '';
            if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
        },
        postCondition(){
            const { childIndID }  = this.conditionInputObject;
            if (this.conditionComplete) {
                const conditionsJSON = JSON.stringify(this.conditionInputObject);
                let indToUpdate = this.indicators.find(i => parseInt(i.indicatorID) === parseInt(childIndID));
                let currConditions = (indToUpdate.conditions === '' || indToUpdate.conditions === null)
                    ? [] : JSON.parse(indToUpdate.conditions);
                let newConditions = currConditions.filter(c => JSON.stringify(c) !== this.editingCondition);

                const isUnique = newConditions.every(c => JSON.stringify(c) !== conditionsJSON);
                if (isUnique){
                    newConditions.push(this.conditionInputObject);
                    
                    $.ajax({
                        type: 'POST',
                        url: `../api/formEditor/${childIndID}/conditions`,
                        data: {
                            conditions: JSON.stringify(newConditions),
                            CSRFToken: CSRFToken
                        },
                        success: (res)=> {
                            if (res !== 'Invalid Token.') {
                                indToUpdate.conditions = JSON.stringify(newConditions), //update the indicator in the indicators list
                                this.clearSelections(true);
                            }                            
                        },
                        error:(err)=> {
                            console.log(err);
                        }
                    });

                } else {
                    this.clearSelections(true);
                }
            }
        },
        removeCondition(data) {  //data is  {confirmDelete: <bool>, condition: object}
            //updates conditionInputObject
            this.selectConditionFromList(data.condition);

            if(data.confirmDelete === true) { //if user pressed delete btn on the confirm modal
                const { childIndID, parentIndID, selectedOutcome, selectedChildValue } = data.condition;
                
                if (childIndID !== undefined) {
                    const hasActiveParentIndicator = this.indicators.some(ele => parseInt(ele.indicatorID)===parseInt(parentIndID));
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
                        newConditions = currConditions.filter(c => !(c.parentIndID===this.selectedDisabledParentID && c.selectedOutcome===selectedOutcome && c.selectedChildValue===selectedChildValue))
                    }
                    
                    if (newConditions.length === 0) newConditions = null;
                    
                    $.ajax({
                        type: 'POST',
                        url: `../api/formEditor/${childIndID}/conditions`,
                        data: {
                            conditions: (newConditions !== null) ? JSON.stringify(newConditions) : '',
                            CSRFToken: CSRFToken
                        },
                        success: (res)=> {
                            if (res !== 'Invalid Token.') {
                                let indToUpdate = this.indicators.find(i => parseInt(i.indicatorID) === parseInt(childIndID));
                                //update conditions on the indicator by reference to the indicators list
                                indToUpdate.conditions = (newConditions !== null) ? JSON.stringify(newConditions) : '';
                            }
                        },
                        error: (err)=> {
                            console.log(err);
                        }
                    });
                }
                this.showRemoveConditionModal = false;
                this.clearSelections(true);
             
            } else { //user pressed an X button in a conditions list that opens the confirm delete modal  
                this.showRemoveConditionModal = true;
            }
        },
        selectConditionFromList(conditionObj){
            //update par and chi ind, other values
            this.editingCondition = JSON.stringify(conditionObj);
            this.showConditionEditor = true;
            this.updateSelectedParentIndicator(conditionObj?.parentIndID);
            if(this.parentFound && this.parentFormat === 'dropdown') {
                this.selectedOperator = conditionObj?.selectedOp;
                this.selectedParentValue = conditionObj?.selectedParentValue;
            }
            this.selectedChildOutcome = conditionObj?.selectedOutcome;
            this.selectedChildValue = conditionObj?.selectedChildValue;
        },
        dragElement(el) {
            let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

            if (document.getElementById(el.id + "_header")) {
                document.getElementById(el.id + "_header").onmousedown = dragMouseDown;
            }

            function dragMouseDown(e) {
                e = e || window.event;
                e.preventDefault();
                pos3 = e.clientX;
                pos4 = e.clientY;
                document.onmouseup = closeDragElement;
                document.onmousemove = elementDrag;
            }

            function elementDrag(e) {
                e = e || window.event;
                e.preventDefault();
                pos1 = pos3 - e.clientX;
                pos2 = pos4 - e.clientY;
                pos3 = e.clientX;
                pos4 = e.clientY;
                el.style.top = (el.offsetTop - pos2) + "px";
                el.style.left = (el.offsetLeft - pos1) + "px";
            }

            function closeDragElement() {
                if ((el.offsetTop - window.top.scrollY) < 0) {
                    el.style.top = (window.top.scrollY + 15) + "px";
                }
                if (el.offsetLeft < 320) {
                    el.style.left = '320px';
                }
                document.onmouseup = null;
                document.onmousemove = null;
            }
        }
    },
    computed: {
        parentFormat(){
            if(this.selectedParentIndicator?.format){
                const f = this.selectedParentIndicator.format
                return f.indexOf("\n") === -1 ? f : f.substr(0, f.indexOf("\n")).trim();
            } else return '';

        },
        childFormat(){
            if(this.childIndicator?.format){
                const f = this.childIndicator.format;
                return f.indexOf("\n") === -1 ? f : f.substr(0, f.indexOf("\n")).trim();
            } else return '';
        },
        conditionInputObject(){
            const childIndID  = this.childIndicator?.indicatorID || 0;
            const parentIndID = this.selectedParentIndicator?.indicatorID || 0;            
            const selectedOp = this.selectedOperator;
            const selectedParentValue = this.selectedParentValue;
            const selectedOutcome = this.selectedChildOutcome;
            const selectedChildValue = this.selectedChildValue;
            const childFormat = this.childFormat;
            const parentFormat = this.parentFormat;
            return {
                childIndID, parentIndID, selectedOp, selectedParentValue, selectedChildValue, selectedOutcome,
                childFormat, parentFormat
            }    
        },
        conditionComplete(){
            const {childIndID, parentIndID, selectedOp, selectedParentValue, 
                selectedChildValue, selectedOutcome} = this.conditionInputObject;

            return (
                    childIndID !== 0 && parentIndID !== 0 && 
                    selectedOp !== '' && selectedParentValue !== '' &&
                    (selectedOutcome && selectedOutcome !== "Pre-fill" ||
                    (selectedOutcome==="Pre-fill" && selectedChildValue !== ''))
                );
        }
    },
    template: `<div id="condition_editor_content" :style="{display: vueData.indicatorID===0 ? 'none' : 'block'}">
        <div id="condition_editor_center_panel" :style="{top: windowTop > 0 ? 15+windowTop+'px' : '15px'}">
            <editor-main
                :vueData="vueData"
                :indicators="indicators"
                :selectedChild="childIndicator"
                :selectableParents="selectableParents"
                :selectedParentValueOptions="selectedParentValueOptions"
                :selectedParentOperators="selectedParentOperators"
                :parentFormat="parentFormat"
                :childFormat="childFormat"
                :selectedChildValueOptions="selectedChildValueOptions"
                :conditions="conditionInputObject"
                :showConditionEditor="showConditionEditor"
                :showRemoveConditionModal="showRemoveConditionModal"
                :editingCondition="editingCondition"
                :conditionInputComplete="conditionComplete"
                @new-condition="newCondition"
                @update-indicator-list="getAllIndicators"
                @update-selected-parent="updateSelectedParentIndicator"
                @update-selected-child="updateSelectedChildIndicator"
                @update-selected-operator="updateSelectedOperator"
                @update-selected-parent-value="updateSelectedParentValue"
                @update-selected-outcome="updateSelectedOutcome"
                @set-condition="selectConditionFromList"
                @remove-condition="removeCondition"
                @cancel-delete="showRemoveConditionModal=false"
                @update-selected-child-value="updateSelectedChildValue">
            </editor-main>
            <editor-actions
                :conditionInputComplete="conditionComplete"
                :parentIndicator="selectedParentIndicator"
                :childIndicator="childIndicator"
                :conditions="conditionInputObject"
                :showRemoveConditionModal="showRemoveConditionModal"
                @save-condition="postCondition"
                @cancel-entry="clearSelections(true)">
            </editor-actions>
        </div>
    </div>` 
});



//CENTER EDITOR WIDGET
ConditionsEditor.component('editor-main', {
    props: {
        vueData: Object,
        selectedChild: Object,
        selectableParents: Array,
        indicators: Array,
        selectedParentOperators: Array,       //available operators, based on format of above ind
        selectedParentValueOptions: Array,    //values for dropdown formats
        selectedChildValueOptions: Array,
        parentFormat: String,
        childFormat: String,
        conditions: Object,
        showConditionEditor: Boolean,
        showRemoveConditionModal: Boolean,
        editingCondition: String,
        conditionInputComplete: Boolean,
    },
    methods: {
        validateCurrency(event) {
            const currencyRegex = /^(\d*)(\.\d{0,2})?$/;
            const val = event.target.value;
            if (!currencyRegex.test(val)) { //TODO: userfeedback
                document.getElementById('currency-format-input').value = '';
            } else {
                this.$emit('update-selected-parent-value', event.target.value);
            }
        },
        forceUpdate(){
            this.$forceUpdate();
            if(this.vueData.updateIndicatorList === true){ //set to T in mod_form if new ind or ind edited, then to F after new fetch
                this.$emit('update-indicator-list');
            } else {
                this.$emit('update-selected-child');
            }
        },
        applyMaxTextLength(text) {
            let maxTextLength = 40;
            return text?.length > maxTextLength ? text.slice(0,maxTextLength) + '... ' : text || '';
        },
        getIndicatorName(id) {
            if (id !== 0) {
                let indicatorName = this.indicators.find(indicator => parseInt(indicator.indicatorID) === parseInt(id))?.name || '';
                return this.applyMaxTextLength(indicatorName);
            }
        },
        textValueDisplay(str) {
            return $('<div/>').html(str).text();
        },
        getOperatorText(op){
            switch(op){
                case '==':
                    return 'is';
                case '!=':
                    return 'is not';
                case '>':
                    return 'is greater than';
                case '<':
                    return 'is less than';    
                default: return op;
            }
        },
        isOrphan(childIndID) {
            return !this.selectableParents.some(p => parseInt(p.indicatorID) === parseInt(childIndID));
        },
        childFormatChangedSinceSave(condition){
            const childConditionFormat = condition.childFormat;
            const childID = parseInt(condition.childIndID);
            const childIndicator = this.indicators.find(ind => parseInt(ind.indicatorID) === childID);
            const currentIndicatorFormat = childIndicator?.format?.split('\n')[0];
            return childConditionFormat?.trim() !== currentIndicatorFormat?.trim();
        }
    },
    computed: {
        savedConditions(){
            return this.selectedChild.conditions ? JSON.parse(this.selectedChild.conditions)
                    : [];
        },
        conditionTypes(){
            const show = this.savedConditions.filter(i => i.selectedOutcome === 'Show');
            const hide = this.savedConditions.filter(i => i.selectedOutcome === 'Hide');
            const prefill = this.savedConditions.filter(i => i.selectedOutcome === 'Pre-fill');

            return {show,hide,prefill};
        }
    },
    template: `<div id="condition_editor_inputs">
        <button id="btn-vue-update-trigger" @click="forceUpdate" style="display:none;"></button>
        <div v-if="vueData.formID!==0" id="condition_editor_center_panel_header" class="editor-card-header">
            <h3 style="color:black;">Conditions For <span style="color: #c00;">
            {{getIndicatorName(vueData.indicatorID)}} ({{vueData.indicatorID}})
            </span></h3>
        </div>
        <div>
            <ul v-if="savedConditions && savedConditions.length > 0 && !showRemoveConditionModal" 
                id="savedConditionsList">
                <div v-if="conditionTypes.show.length > 0">
                    <p><b>This field will be hidden except:</b></p>
                    <li v-for="c in conditionTypes.show" key="c" class="savedConditionsCard">
                        <button @click="$emit('set-condition', c)" class="btnSavedConditions" 
                            :class="{selectedConditionEdit: JSON.stringify(c)===editingCondition, isOrphan: isOrphan(c.parentIndID)}">
                            <span v-if="!isOrphan(c.parentIndID)">
                                If '{{getIndicatorName(c.parentIndID)}}' 
                                {{getOperatorText(c.selectedOp)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                then show this question.
                                <span v-if="childFormatChangedSinceSave(c)" class="changesDetected"><br/>
                                The format of this question has changed.  
                                Please review and save it to update</span>
                                </span>
                            </span>
                            <span v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</span>
                        </button>
                        <button style="width: 1.75em;"
                        class="btn_remove_condition"
                        @click="$emit('remove-condition', {confirmDelete: false, condition: c})">X
                        </button>
                    </li>
                </div>
                <div v-if="conditionTypes.hide.length > 0">
                    <p style="margin-top: 1em"><b>This field will be shown except:</b></p>
                    <li v-for="c in conditionTypes.hide" key="c" class="savedConditionsCard">
                        <button @click="$emit('set-condition', c)" class="btnSavedConditions" 
                            :class="{selectedConditionEdit: JSON.stringify(c)===editingCondition, isOrphan: isOrphan(c.parentIndID)}">
                            <span v-if="!isOrphan(c.parentIndID)">
                                If '{{getIndicatorName(c.parentIndID)}}' 
                                {{getOperatorText(c.selectedOp)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                then hide this question.
                                <span v-if="childFormatChangedSinceSave(c)" class="changesDetected"><br/>
                                The format of this question has changed.  
                                Please review and save it to update</span>
                                </span>
                            </span>
                            <span v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</span>
                        </button>
                        <button style="width: 1.75em;"
                        class="btn_remove_condition"
                        @click="$emit('remove-condition', {confirmDelete: false, condition: c})">X
                        </button>
                    </li>
                </div>
                <div v-if="conditionTypes.prefill.length > 0">
                    <p style="margin-top: 1em"><b>This field will be pre-filled:</b></p>
                    <li v-for="c in conditionTypes.prefill" key="c" class="savedConditionsCard">
                        <button @click="$emit('set-condition', c)" class="btnSavedConditions" 
                            :class="{selectedConditionEdit: JSON.stringify(c)===editingCondition, isOrphan: isOrphan(c.parentIndID)}">
                            <span v-if="!isOrphan(c.parentIndID)">
                                If '{{getIndicatorName(c.parentIndID)}}' 
                                {{getOperatorText(c.selectedOp)}} <strong>{{ textValueDisplay(c.selectedParentValue) }}</strong> 
                                then this question will be <strong>{{ textValueDisplay(c.selectedChildValue) }}</strong>
                                <span v-if="childFormatChangedSinceSave(c)" class="changesDetected"><br/>
                                The format of this question has changed.  
                                Please review and save it to update</span>
                            </span>
                            <span v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived or deleted.</span>
                        </button>
                        <button style="width: 1.75em;"
                        class="btn_remove_condition"
                        @click="$emit('remove-condition', {confirmDelete: false, condition: c})">X
                        </button>
                    </li>
                </div>
            </ul>
            <button v-if="!showRemoveConditionModal" @click="$emit('new-condition')" 
                class="btnNewCondition">+ New Condition</button>
            <div v-if="showRemoveConditionModal">
                <div>Choose <b>Delete</b> to confirm removal, or <b>cancel</b> to return</div>
                <ul style="display: flex; justify-content: space-between; margin-top: 1em">
                    <li style="width: 30%;">
                        <button class="btn_remove_condition" @click="$emit('remove-condition', {confirmDelete: true, condition: conditions } )">Delete</button>
                    </li>
                    <li style="width: 30%;">
                        <button id="btn_cancel" @click="$emit('cancel-delete')">Cancel</button>
                    </li>
                </ul>
            </div>
        </div>
        <div v-if="!showRemoveConditionModal && showConditionEditor" id="outcome-editor">
            <!-- childIndID, parentIndID, selectedOp, selectedParentValue, selectedChildValue, selectedOutcome-->
            <span v-if="conditions.childIndID" class="input-info">Select an outcome</span>
            <select v-if="conditions.childIndID" title="select outcome"
                    name="child-outcome-selector"
                    @change="$emit('update-selected-outcome', $event.target.value)">
                    <option v-if="conditions.selectedOutcome===''" value="" selected>Select an outcome</option> 
                    <option value="Show" :selected="conditions.selectedOutcome==='Show'">Hide this question except ...</option>
                    <option value="Hide" :selected="conditions.selectedOutcome==='Hide'">Show this question except ...</option>
                    <option value="Pre-fill" :selected="conditions.selectedOutcome==='Pre-fill'">Pre-fill this Question</option>
            </select>
            <span v-if="conditions.selectedOutcome==='Pre-fill'" class="input-info">Enter a pre-fill value</span>
            <!-- TODO: other formats - only testing dropdown for now -->
            <select v-if="conditions.selectedOutcome==='Pre-fill' && childFormat==='dropdown'"
                @change="$emit('update-selected-child-value', $event.target.value)">
                <option v-if="conditions.selectedChildValue===''" value="" selected>Select a value</option>    
                <option v-for="val in selectedChildValueOptions" 
                :value="val"
                :selected="textValueDisplay(conditions.selectedChildValue)===val">
                {{ val }} 
                </option>
            </select>
            <input v-else-if="conditions.selectedOutcome==='Pre-fill' && childFormat==='text'" 
                @change="$emit('update-selected-child-value', $event.target.value)"
                :value="textValueDisplay(conditions.selectedChildValue)" />
        </div>
        <div v-if="!showRemoveConditionModal && showConditionEditor && selectableParents.length > 0"
            class="if-then-setup">
            <h4 style="margin: 0;">IF</h4>
            <div>
                <select title="select an indicator" 
                        name="indicator-selector" 
                        @change="$emit('update-selected-parent', $event.target.value)">
                    <option v-if="!conditions.parentIndID" value="" selected>Select an Indicator</option>        
                    <option v-for="i in selectableParents" 
                    :title="i.name" 
                    :value="i.indicatorID"
                    :selected="parseInt(conditions.parentIndID)===parseInt(i.indicatorID)"
                    key="i.indicatorID">
                    {{getIndicatorName(i.indicatorID) }} (indicator {{i.indicatorID}})
                    </option>
                </select>
            </div>
            <div>
                <!-- OPERATOR SELECTION -->
                <select
                    @change="$emit('update-selected-operator', $event.target.value)">
                    <option v-if="conditions.selectedOp===''" value="" selected>Select a condition</option>
                    <option v-for="o in selectedParentOperators" 
                    :value="o.val"
                    :selected="conditions.selectedOp===o.val">
                    {{ o.text }}
                    </option>
                </select>
            </div>
            <div>    
                <!-- COMPARED VALUE SELECTION -->
                <input v-if="parentFormat==='date'" type="date"
                    :value="conditions.selectedParentValue"
                    @change="$emit('update-selected-parent-value', $event.target.value)"/>
                <input v-else-if="parentFormat==='number'" type="number"
                    :value="conditions.selectedParentValue"
                    @change="$emit('update-selected-parent-value', $event.target.value)"/>
                <input v-else-if="parentFormat.format==='currency'"
                    id="currency-format-input" 
                    type="number" step="0.01"
                    :value="conditions.selectedParentValue" 
                    @change="validateCurrency"/>
                <select v-else-if="parentFormat==='dropdown'"
                    @change="$emit('update-selected-parent-value', $event.target.value)">
                    <option v-if="conditions.selectedParentValue===''" value="" selected>Select a value</option>    
                    <option v-for="val in selectedParentValueOptions"
                        :selected="textValueDisplay(conditions.selectedParentValue)===val"> {{ val }}
                    </option>
                </select>
                <select v-else-if="parentFormat==='radio'"
                    @change="$emit('update-selected-parent-value', $event.target.value)">
                    <option v-if="conditions.selectedParentValue===''" value="" selected>Select a value</option> 
                    <option v-for="val in selectedParentValueOptions"> {{ val }} </option>
                </select>
                <p v-else class="TEST">value selection still in progress for some formats</p>
            </div>
        </div>
        <div v-if="conditionInputComplete"><h4 style="margin: 0; display:inline-block">THEN</h4> '{{getIndicatorName(vueData.indicatorID)}}'
            <span v-if="conditions.selectedOutcome==='Pre-fill'">will 
            <span style="color: #00A91C; font-weight: bold;"> have the value '{{textValueDisplay(conditions.selectedChildValue)}}'</span>
            </span>
            <span v-else>will 
                <span style="color: #00A91C; font-weight: bold;">
                be {{conditions.selectedOutcome==="Show" ? 'shown' : 'hidden'}}
                </span>
            </span>
        </div>
        <div v-if="selectableParents.length < 1">No options are currently available for the indicators on this form</div>
    </div>`
});


ConditionsEditor.component('editor-actions', {
    props: {
        conditionInputComplete: Boolean,
        parentIndicator: Object,
        childIndicator: Object,
        conditions: Object,
        showRemoveConditionModal: Boolean
    },
    methods: {
        toFormEditor(){
            window.location.assign('./?a=form#');
        }
    },
    computed: {
        operatorText(){
            const op = this.conditions.selectedOp;
            switch(op){
                case '==':
                    return 'is';
                case '!=':
                    return 'is not';
                case '>':
                    return 'is greater than';
                case '<':
                    return 'is less than';    
                default: return op;
            }
        }
    },
    template: `<div v-if="!showRemoveConditionModal" id="condition_editor_actions">
            <div>
                <ul style="display: flex; justify-content: space-between;">
                    <li style="width: 30%;">
                        <button v-if="conditionInputComplete" id="btn_add_condition" @click="$emit('save-condition')">Save</button>
                    </li>
                    <li style="width: 30%;">
                        <button id="btn_cancel" @click="$emit('cancel-entry','')">Cancel</button>
                    </li>
                </ul>
            </div>
        </div>`
});
ConditionsEditor.mount('#LEAF_conditions_editor');