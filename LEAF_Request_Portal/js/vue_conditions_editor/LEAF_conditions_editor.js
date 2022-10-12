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
            editingCondition: '',
            enabledParentFormats: ['dropdown', 'multiselect']
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
        updateSelectedParentIndicator(indicatorID) {
            //get rid of possible multiselect choices instance and reset parent comparison value
            const elSelectParent = document.getElementById('parent_compValue_entry');
            if(elSelectParent?.choicesjs) elSelectParent.choicesjs.destroy();
            this.selectedParentValue = '';  
            
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
        updateSelectedOutcome(outcome) {
            //get rid of possible multiselect choices instances for child prefill values
            const elSelectChild = document.getElementById('child_prefill_entry');
            if(elSelectChild?.choicesjs) elSelectChild.choicesjs.destroy();
            this.selectedChildOutcome = outcome;
            this.selectedChildValue = '';  //reset possible prefill
        },
        updateSelectedOperator(operator){
            this.selectedOperator = operator;
        },
        updateSelectedParentValue(target){
            const parFormat = this.selectedParentIndicator.format.split('\n')[0].trim();
            let value = '';
            if (parFormat==='multiselect') {
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
        updateSelectedChildValue(target){
            const childFormat = this.childIndicator.format.split('\n')[0].trim();
            let value = '';
            if (childFormat==='multiselect') {
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
                            (i.format.indexOf('dropdown') === 0 || i.format.indexOf('multiselect') === 0);  //dropdowns, multiselect parent only
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
            //rm possible child choicesjs instances associated with prior item
            const elSelectChild = document.getElementById('child_prefill_entry');
            if(elSelectChild?.choicesjs) elSelectChild.choicesjs.destroy();
            const elSelectParent = document.getElementById('parent_compValue_entry');
            if(elSelectParent?.choicesjs) elSelectParent.choicesjs.destroy();
            
            if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
        },
        postCondition(){
            const { childIndID }  = this.conditions;
            if (this.conditionComplete) {
                const conditionsJSON = JSON.stringify(this.conditions);
                let indToUpdate = this.indicators.find(i => parseInt(i.indicatorID) === parseInt(childIndID));
                let currConditions = (indToUpdate.conditions === '' || indToUpdate.conditions === null || indToUpdate.conditions === 'null')
                    ? [] : JSON.parse(indToUpdate.conditions);
                let newConditions = currConditions.filter(c => JSON.stringify(c) !== this.editingCondition);

                const isUnique = newConditions.every(c => JSON.stringify(c) !== conditionsJSON);
                if (isUnique){
                    newConditions.push(this.conditions);
                    
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
        //param data object  {confirmDelete: <bool>, condition: object}
        removeCondition(data) {  
            this.selectConditionFromList(data.condition); //updates conditions object

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
        parentFormat() {
            if(this.selectedParentIndicator?.format){
                const f = this.selectedParentIndicator.format
                return f.indexOf("\n") === -1 ? f : f.substr(0, f.indexOf("\n")).trim();
            } else return '';

        },
        childFormat() {
            if(this.childIndicator?.format){
                const f = this.childIndicator.format;
                return f.indexOf("\n") === -1 ? f : f.substr(0, f.indexOf("\n")).trim();
            } else return '';
        },
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
                childIndID, parentIndID, selectedOp, selectedParentValue, selectedChildValue, selectedOutcome,
                childFormat, parentFormat
            }    
        },
        conditionComplete(){
            const {childIndID, parentIndID, selectedOp, selectedParentValue, 
                selectedChildValue, selectedOutcome} = this.conditions;
            
            return (
                    childIndID !== 0 && parentIndID !== 0 && 
                    selectedOp !== '' && selectedParentValue !== '' &&
                    (selectedOutcome && selectedOutcome.toLowerCase() !== "pre-fill" ||
                    (selectedOutcome.toLowerCase()==="pre-fill" && selectedChildValue !== ''))
                );
        },
    },
    template: `<div id="condition_editor_content" :style="{display: vueData.indicatorID===0 ? 'none' : 'block'}">
        <div id="condition_editor_center_panel" :style="{top: windowTop > 0 ? 15+windowTop+'px' : '15px'}">
            <editor-main
                :vueData="vueData"
                :indicators="indicators"
                :childIndicator="childIndicator"
                :selectableParents="selectableParents"
                :selectedParentValueOptions="selectedParentValueOptions"
                :selectedParentOperators="selectedParentOperators"
                :parentFormat="parentFormat"
                :childFormat="childFormat"
                :selectedChildValueOptions="selectedChildValueOptions"
                :conditions="conditions"
                :showConditionEditor="showConditionEditor"
                :showRemoveConditionModal="showRemoveConditionModal"
                :editingCondition="editingCondition"
                :conditionComplete="conditionComplete"
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

            <!--NOTE: save cancel panel  -->
            <div v-if="!showRemoveConditionModal" id="condition_editor_actions">
                <div>
                    <ul style="display: flex; justify-content: space-between;">
                        <li style="width: 30%;">
                            <button v-if="conditionComplete" id="btn_add_condition" @click="postCondition">Save</button>
                        </li>
                        <li style="width: 30%;">
                            <button id="btn_cancel" @click="clearSelections(true)">Cancel</button>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>` 
});



//CENTER EDITOR WIDGET
ConditionsEditor.component('editor-main', {
    props: {
        vueData: Object,
        childIndicator: Object,
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
        conditionComplete: Boolean,
    },
    updated() {
        if(this.conditions.selectedOutcome !== '') {
            this.updateChoicesJS();
        }
    },
    methods: {
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
        getOperatorText(condition){
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
        isOrphan(childIndID) {
            return !this.selectableParents.some(p => parseInt(p.indicatorID) === parseInt(childIndID));
        },
        childFormatChangedSinceSave(condition) {
            const childConditionFormat = condition.childFormat;
            const currentIndicatorFormat = this.childIndicator?.format?.split('\n')[0];
            return childConditionFormat?.trim() !== currentIndicatorFormat?.trim();
        },
        updateChoicesJS() {
            const elExistingChoicesChild = document.querySelector('#outcome-editor > div.choices');
            const elSelectParent = document.getElementById('parent_compValue_entry');
            const elSelectChild = document.getElementById('child_prefill_entry');
            
            const childFormat = this.conditions.childFormat.toLowerCase();
            const parentFormat = this.conditions.parentFormat.toLowerCase();
            const outcome = this.conditions.selectedOutcome.toLowerCase();
           
            if(parentFormat === 'multiselect' && elSelectParent !== null && !elSelectParent.choicesjs) {
                let options = this.selectedParentValueOptions || [];
                options = options.map(o =>({
                    value: o.trim(),
                    label: o.trim(),
                    selected: this.arrParentMultiselectValues.includes(o.trim())
                }));
                const choices = new Choices(elSelectParent, {
                    allowHTML: false,
                    removeItemButton: true,
                    editItems: true,
                    choices: options.filter(o => o.value !== "")
                });
                elSelectParent.choicesjs = choices;
            }

            if(outcome==='pre-fill' && childFormat === 'multiselect' && elSelectChild !== null && elExistingChoicesChild===null) {
                let options = this.selectedChildValueOptions || [];
                options = options.map(o =>({
                    value: o.trim(),
                    label: o.trim(),
                    selected: this.arrChildMultiselectValues.includes(o.trim())
                }));
                const choices = new Choices(elSelectChild, {
                    allowHTML: false,
                    removeItemButton: true,
                    editItems: true,
                    choices: options.filter(o => o.value !== "")
                });
                elSelectChild.choicesjs = choices;
            }
        }
    },
    computed: {
        savedConditions(){
            return this.childIndicator.conditions ? JSON.parse(this.childIndicator.conditions)
                    : [];
        },
        conditionTypes(){
            const show = this.savedConditions.filter(i => i.selectedOutcome === 'Show');
            const hide = this.savedConditions.filter(i => i.selectedOutcome === 'Hide');
            const prefill = this.savedConditions.filter(i => i.selectedOutcome === 'Pre-fill');

            return {show,hide,prefill};
        },
        arrChildMultiselectValues() {
            let arrValues = this.conditions?.selectedChildValue.split('\n') || [];
            arrValues = arrValues.map(v => this.textValueDisplay(v).trim());
            return arrValues;
        },
        arrParentMultiselectValues() {
            let arrValues = this.conditions?.selectedParentValue.split('\n') || [];
            arrValues = arrValues.map(v => this.textValueDisplay(v).trim());
            return arrValues;
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
            <span v-if="conditions.childIndID" class="input-info">Select an outcome</span>
            <select v-if="conditions.childIndID" title="select outcome"
                    name="child-outcome-selector"
                    @change="$emit('update-selected-outcome', $event.target.value)">
                    <option v-if="conditions.selectedOutcome===''" value="" selected>Select an outcome</option> 
                    <option value="Show" :selected="conditions.selectedOutcome==='Show'">Hide this question except ...</option>
                    <option value="Hide" :selected="conditions.selectedOutcome==='Hide'">Show this question except ...</option>
                    <option value="Pre-fill" :selected="conditions.selectedOutcome==='Pre-fill'">Pre-fill this Question</option>
            </select>
            <span v-if="conditions.selectedOutcome.toLowerCase()==='pre-fill'" class="input-info">Enter a pre-fill value</span>
            <!-- NOTE: PRE-FILL ENTRY AREA dropdown, multidropdown, text -->
            <select v-if="conditions.selectedOutcome.toLowerCase()==='pre-fill' && childFormat==='dropdown'"
                name="child-prefill-value-selector"
                id="child_prefill_entry"
                @change="$emit('update-selected-child-value', $event.target)">
                <option v-if="conditions.selectedChildValue===''" value="" selected>Select a value</option>    
                <option v-for="val in selectedChildValueOptions" 
                :value="val"
                :selected="textValueDisplay(conditions.selectedChildValue)===val">
                {{ val }} 
                </option>
            </select>
            <select v-else-if="conditions.selectedOutcome.toLowerCase()==='pre-fill' && conditions.childFormat==='multiselect'"
                placeholder="select some options"
                multiple="true"
                id="child_prefill_entry"
                style="display: none;"
                :key="conditions.selectedOutcome + '_' + conditions.parentIndID"
                name="child-prefill-value-selector"
                @change="$emit('update-selected-child-value', $event.target)">   
            </select>
            <input v-else-if="conditions.selectedOutcome==='Pre-fill' && childFormat==='text'" 
                id="child_prefill_entry"
                @change="$emit('update-selected-child-value', $event.target)"
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
                <!-- NOTE: OPERATOR SELECTION -->
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
                <!-- NOTE: COMPARED VALUE SELECTION (active parent formats: dropdown, multiselect) -->
                <select v-if="parentFormat==='dropdown'"
                    id="parent_compValue_entry"
                    @change="$emit('update-selected-parent-value', $event.target)">
                    <option v-if="conditions.selectedParentValue===''" value="" selected>Select a value</option>    
                    <option v-for="val in selectedParentValueOptions"
                        :selected="textValueDisplay(conditions.selectedParentValue)===val"> {{ val }}
                    </option>
                </select>
                <select v-else-if="parentFormat==='multiselect'"
                    id="parent_compValue_entry"
                    placeholder="select some options" multiple="true"
                    style="display: none;"
                    @change="$emit('update-selected-parent-value', $event.target)">
                </select>
            </div>
        </div>
        <div v-if="conditionComplete"><h4 style="margin: 0; display:inline-block">THEN</h4> '{{getIndicatorName(vueData.indicatorID)}}'
            <span v-if="conditions.selectedOutcome==='Pre-fill'">will 
            <span style="color: #00A91C; font-weight: bold;"> have the value{{childFormat==='multiselect' ? '(s)':''}} '{{textValueDisplay(conditions.selectedChildValue)}}'</span>
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

ConditionsEditor.mount('#LEAF_conditions_editor');