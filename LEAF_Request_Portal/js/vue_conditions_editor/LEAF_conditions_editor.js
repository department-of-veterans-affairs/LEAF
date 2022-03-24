const ConditionsEditor = Vue.createApp({
    data() {
        return {
            forms: [],
            indicators: [],
            selectedFormCatID: '',
            selectedIndicator: {},
            selectedFormIndicators: [],
            selectedFormConditions: [],   //TODO: rework (internal info?)
            selectedParentOperators: [],
            selectedOperator: '',
            selectedParentValue: '',
            selectedFormat: '',
            selectedValueOptions: [],   //for radio, dropdown
            childIndicator: {},
            childIndicatorOptions: [],  //selectedform inds - selected parent ind
            selectedChildOutcome: '',
            selectedChildValueOptions: [],
            selectedChildValue: '',
        }
    },
    beforeMount(){
        //get all enabled forms for List dropdown
        const xhttpForms = new XMLHttpRequest();
        xhttpForms.onreadystatechange = () => {
            if (xhttpForms.readyState == 4 && xhttpForms.status == 200) {
                const list = JSON.parse(xhttpForms.responseText);
                const filteredList = list.filter(ele => ele.categoryID.includes('form_'));
                this.forms = filteredList.sort((a,b) => a.categoryName - b.categoryName).slice();
            }
        };
        xhttpForms.open("GET", "../api/form/categories", true);
        xhttpForms.send();

        //get all enabled indicators
        const xhttpInds = new XMLHttpRequest();
        xhttpInds.onreadystatechange = () => {
            if (xhttpInds.readyState == 4 && xhttpInds.status == 200) {
                const list = JSON.parse(xhttpInds.responseText);
                const filteredList = list.filter(ele => parseInt(ele.indicatorID) > 0 && ele.isDisabled===0);
                this.indicators = filteredList;
            }
        };
        xhttpInds.open("GET", `../api/form/indicator/list`, true);
        xhttpInds.send();
    },
    methods: {
        clearSelections(){
            //cleared when either the form or parent indicator changes
            this.selectedIndicator = {};
            this.selectedParentOperators = [];
            this.selectedOperator = '';
            this.selectedParentFormat = '';
            this.selectedValueOptions = [];  //parent values if radio, dropdown, etc
            this.selectedParentValue = '';
            this.childIndicatorOptions = []; 
            this.childIndicator = {};
            this.selectedChildOutcome = '';
            this.selectedChildValueOptions = [];
            this.selectedChildValue = '';
        },
        updateSelectedIndicator(indicatorID){
            this.clearSelections();
            const indicator = this.selectedFormIndicators.find(i => i.indicatorID === indicatorID);
            const valueOptions = indicator.format.indexOf("\n") === -1 ? [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
           
            this.selectedIndicator = {...indicator};
            this.childIndicatorOptions = this.selectedFormIndicators.filter(i => i.indicatorID !== indicator.indicatorID);
            this.selectedValueOptions = valueOptions.filter(vo => vo !== '');

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
                        {val:"==", text: "selected value(s) is"}, 
                        {val:"!=", text: "selected value(s) is not"}
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
        getCategoryIndicators(catID) {
            this.clearSelections();
            this.selectedFormCatID = catID;
            //update indicators and conditions for the selected form
            if (catID === '') {
                this.selectedFormIndicators = [];
                this.selectedFormConditions = [];  
            } else {
                this.selectedFormIndicators = this.indicators.filter(i => !i.format.includes('orgchart') && i.categoryID === catID); // (|| i.parentCategoryID === catID) NOTE: same forms for now
                this.selectedFormConditions = this.selectedFormIndicators.filter(i => i.conditions !== null && i.conditions !== '');
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
        updateSelectedChildIndicator(indicatorID){
            const indicator = this.selectedFormIndicators.find(i => i.indicatorID === indicatorID);
            const childValueOptions = indicator.format.indexOf("\n") === -1 ? [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
            
            this.childIndicator = {...indicator};
            this.selectedChildOutcome = '';
            this.selectedChildValue = '';
            this.selectedChildValueOptions = childValueOptions.filter(cvo => cvo !== '');
        },
        postCondition(){
            const { childIndID }  = this.conditionInputObject;
            if (this.conditionComplete && childIndID !== undefined) {
                const pkg = JSON.stringify(this.conditionInputObject);
                let form = new FormData();
                form.append('CSRFToken', CSRFToken);
                form.append('conditions', pkg);

                //* NOTE: xml version  DONE:
                const xhttp = new XMLHttpRequest();
                xhttp.open("POST", `../api/formEditor/${childIndID}/conditions`, true);
                xhttp.send(form); 
                xhttp.onreadystatechange = () => {
                    if (xhttp.readyState == 4 && xhttp.status == 200) {
                        const res = JSON.parse(xhttp.responseText);
                        //TODO: return better indication of success, currently just empty array
                        if (res !== 'Invalid Token.') { 
                            let indToUpdate = this.indicators.find(i => i.indicatorID === this.conditionInputObject.childIndID);
                            indToUpdate.conditions = pkg;
                            this.getCategoryIndicators(this.selectedFormCatID);
                        }
                    }
                };//*/
                /* NOTE: fetch API version  //DONE: working now
                fetch(`../api/formEditor/${childIndID}/conditions`, {
                    method: 'POST', 
                    body: form
                })
                .then(res => res.json())
                .then(data => console.log(data))
                .catch(err => console.log(err));
                  //*/
            } else {
                console.log('condition object not complete');
            }
        },
        selectConditionFromList(listConditionJSON){
            //already have selectedFormCatID and selectedFormIndicators. update par and chi ind, other values
            const conditionObj = JSON.parse(listConditionJSON);
            this.updateSelectedIndicator(conditionObj.parentIndID);
            this.updateSelectedChildIndicator(conditionObj.childIndID);
            this.selectedOperator = conditionObj.selectedOp;
            this.selectedChildOutcome = conditionObj.selectedOutcome;
            this.selectedParentValue = conditionObj?.selectedParentValue;
            this.selectedChildValue = conditionObj?.selectedChildValue;
        }
    },
    computed: {
        formName(){
            if (this.selectedFormCatID !== '') {
                return this.forms.find(f => f.categoryID === this.selectedFormCatID).categoryName;
            } else return '';
        },
        parentFormat(){
            if(this.selectedIndicator?.format){
                const f = this.selectedIndicator.format
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
            const childIndID  = this.childIndicator.indicatorID;
            const parentIndID = this.selectedIndicator.indicatorID;            
            const selectedOp = this.selectedOperator;
            const selectedParentValue = this.selectedParentValue;
            const selectedOutcome = this.selectedChildOutcome;
            const selectedChildValue = this.selectedChildValue;
            return {
                childIndID, parentIndID, selectedOp, selectedParentValue, selectedChildValue, selectedOutcome
            }    
        },
        conditionComplete(){
            const {childIndID, parentIndID, selectedOp, selectedParentValue, 
                selectedChildValue, selectedOutcome} = this.conditionInputObject;

            return (
                    childIndID && parentIndID && selectedOp && selectedParentValue &&
                    (selectedOutcome && selectedOutcome !== "Pre-fill Question" || 
                    (selectedOutcome==="Pre-fill Question" && selectedChildValue !== ''))
                );
        }
    },
    template: `<div>
        <div id="condition_editor_content">
            <editor-list 
                :forms="forms"
                :selectedConditions="selectedFormConditions"
                :selectedFormCatID="selectedFormCatID"
                @select-from-list-conditions="selectConditionFromList"
                @update-selected-form="getCategoryIndicators">
            </editor-list>
            <div id="condition_editor_center_panel">
                <editor-main
                    :formName="formName"
                    :selectedValueOptions="selectedValueOptions"
                    :selectedIndicators="selectedFormIndicators"
                    :selectedParentOperators="selectedParentOperators"
                    :parentFormat="parentFormat"
                    :childFormat="childFormat"
                    :childIndicatorOptions="childIndicatorOptions"
                    :selectedChildValueOptions="selectedChildValueOptions"
                    :conditions="conditionInputObject"
                    @update-selected-indicator="updateSelectedIndicator"
                    @update-selected-child="updateSelectedChildIndicator"
                    @update-selected-operator="updateSelectedOperator"
                    @update-selected-parent-value="updateSelectedParentValue"
                    @update-selected-outcome="updateSelectedOutcome"
                    @update-selected-child-value="updateSelectedChildValue">
                </editor-main>
                <editor-actions
                    :conditionInputComplete="conditionComplete"
                    :parentIndicator="selectedIndicator"
                    :childIndicator="childIndicator"
                    :conditions="conditionInputObject"
                    @save-condition="postCondition"
                    @cancel-entry="getCategoryIndicators">
                </editor-actions>
            </div>
        </div>
        <div class="TEST">
            <p><b>condition complete:</b> {{ conditionComplete ? 'true' : 'false' }}</p>
            <p><b>selected catID:</b> {{ selectedFormCatID }}</p>
            <p><b>selected parent indID:</b> {{ selectedIndicator }}</p>
            <span><b>child indicatorID - child condition:</b></span><br/>
            <div v-for="c in selectedFormConditions">{{c.indicatorID + '- ' + c.conditions}}<br/></div>
            <p style="margin-top: 10px;"><b>selected parent format:</b> {{ parentFormat }}</p>
            <p><b>selected child format:</b> {{ childFormat }}</p>
            <p><b>selected condition/operator:</b> {{ selectedOperator }}</p>
            <p><b>selected parent value:</b> {{ selectedParentValue }}</p>
            <p><b>selected outcome:</b> {{ selectedChildOutcome }}</p>
            <p><b>conditions input object:</b> {{ conditionInputObject }}</p>
        </div>
    </div>` 
});


//LIST COMPONENT 
//Allows form selection and shows indicators with conditions for selected form
//TODO: tab indicators with conditions to view details and/or edit
ConditionsEditor.component('editor-list', {
    props: {
        forms: Array,
        selectedConditions: Array,  //indicators with .conditions value
        selectedFormCatID: String
    },
    methods: {
        toFormEditor(){
            window.location.assign('./?a=form#');
        },
        getParentController(conditionJSON){
            return JSON.parse(conditionJSON).parentIndID;
        },
        getParentControllerName(conditionJSON){
            const parentID = JSON.parse(conditionJSON).parentIndID;
            return this.selectedFormIndicators.find(i => i.indicatorID === parentID).name;
        }
    },
    template: `<div id="condition_editor_list">
        <div class="editor-card-header">
        <p>Select a form to start adding a new condition</p>
        <select title="select a form" name="form-selector" @change="$emit('update-selected-form', $event.target.value)">
            <option v-if="selectedFormCatID===''" value="" selected>Select a Form</option>
            <option v-for="f in forms" 
            :title="f.categoryName" 
            :value="f.categoryID">
            {{f.categoryName}}</option>
        </select>
        </div>
        <div class="editor-card-base">
            <h3 class="input-info">Conditions List</h3>
            <p v-if="selectedConditions.length===0">No conditions have been added to this form</p>
            <div v-else>
                <ul>
                    <li v-for="child in selectedConditions" key="child.conditions">
                        <button class="btn-condition-select"
                            @click="$emit('select-from-list-conditions', child.conditions)">
                            <b>{{ child.name }}</b> (indicator {{ child.indicatorID }})<br/>
                            <span class="ind-controller-info">
                            controlled by parent (indicator {{ getParentController(child.conditions) }})</span>
                        </button>
                    </li>
                </ul>
            </div>
            <hr/>
            <button id="btn_form_editor" @click="toFormEditor">Back to Form Editor</button>
        </div>
    </div>`
});


//CENTER EDITOR WIDGET
ConditionsEditor.component('editor-main', {
    props: {
        selectedIndicators: Array,      //all available inds for currently selected form
        childIndicatorOptions: Array,   //which indicators can be chosen for children
        selectedParentOperators: Array, //available operators, based on format of above ind
        selectedValueOptions: Array,    //values for dropdown formats
        selectedChildValueOptions: Array,
        parentFormat: String,
        childFormat: String,
        conditions: Object,
        formName: String
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
        }
    },
    template: `<div id="condition_editor_inputs">
        <div v-if="formName" class="editor-card-header">
            <h3 style="color:black;">Conditions Editor<span class="form-name">
                &nbsp;<i class="fas fa-caret-right"></i>&nbsp;
                {{ formName }}
            </span></h3>
        </div>
        <div v-else>Please select a form to begin</div>
        
        <div v-if="selectedIndicators.length > 1" class="editor-card-base">
            <h4>IF</h4>
            <span class="input-info">Parent question</span>
            <select title="select an indicator" 
                    name="indicator-selector" 
                    @change="$emit('update-selected-indicator', $event.target.value)">
                <option v-if="!conditions.parentIndID" value="" selected>Select an Indicator</option>        
                <option v-for="i in selectedIndicators" 
                :title="i.name" 
                :value="i.indicatorID"
                :selected="conditions.parentIndID===i.indicatorID"
                key="i.indicatorID">
                {{i.name }} (indicator {{i.indicatorID}})
                </option>
            </select>
            <div v-if="selectedParentOperators.length > 0">
                <span class="input-info">Choose a comparison</span>
                <select
                    @change="$emit('update-selected-operator', $event.target.value)">
                    <option v-if="conditions.selectedOp===''" value="" selected>Select a condition</option>
                    <option v-for="o in selectedParentOperators" 
                    :value="o.val"
                    :selected="conditions.selectedOp===o.val">
                    {{ o.text }}
                    </option>
                </select>
                <span class="input-info">Enter a value</span>
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
                    <option v-for="val in selectedValueOptions"
                        :selected="conditions.selectedParentValue===val"> {{ val }}
                    </option>
                </select>
                <select v-else-if="parentFormat==='radio'"
                    @change="$emit('update-selected-parent-value', $event.target.value)">
                    <option v-if="conditions.selectedParentValue===''" value="" selected>Select a value</option> 
                    <option v-for="val in selectedValueOptions"> {{ val }} </option>
                </select>
                <p v-else class="TEST">value selection still in progress for some formats</p>
            </div>
            <hr/>
            <h4>THEN</h4>
            <span class="input-info">Child question</span>
            <select title="select an indicator" 
                    name="child-indicator-selector" 
                    @change="$emit('update-selected-child', $event.target.value)">
                <option v-if="!conditions.childIndID" value="" selected>Select an Indicator</option>        
                <option v-for="c in childIndicatorOptions" 
                :title="c.name" 
                :value="c.indicatorID"
                :selected="conditions.childIndID===c.indicatorID"
                key="c.indicatorID">
                {{c.name }} (indicator {{c.indicatorID}})
                </option>
            </select>
            <!-- childIndID, parentIndID, selectedOp, selectedParentValue, selectedChildValue, selectedOutcome-->
            <span v-if="conditions.childIndID" class="input-info">Select an outcome</span>
            <select v-if="conditions.childIndID" title="select outcome"
                    name="child-outcome-selector"
                    @change="$emit('update-selected-outcome', $event.target.value)">
                    <option v-if="conditions.selectedOutcome===''" value="" selected>Select an outcome</option> 
                    <option value="Show Question" :selected="conditions.selectedOutcome==='Show Question'">Show Question</option>
                    <option value="Hide Question" :selected="conditions.selectedOutcome==='Hide Question'">Hide Question</option>
                    <option value="Pre-fill Question" :selected="conditions.selectedOutcome==='Pre-fill Question'">Pre-fill Question</option>
            </select>
            <span v-if="conditions.selectedOutcome==='Pre-fill Question'" class="input-info">Enter a pre-fill value</span>
            <!-- TODO: FIX: other formats - only testing dropdown for now -->
            <select v-if="conditions.selectedOutcome==='Pre-fill Question'"
                @change="$emit('update-selected-child-value', $event.target.value)">
                <option v-if="conditions.selectedChildValue===''" value="" selected>Select a value</option>    
                <option v-for="val in selectedChildValueOptions" 
                :value="val"
                :selected="conditions.selectedChildValue===val"> 
                {{ val }} 
                </option>
            </select>
        </div>
        <div v-if="formName && selectedIndicators.length <= 1">No options are currently available for the indicators on this form</div>
    </div>`
});


ConditionsEditor.component('editor-actions', {
    props: {
        conditionInputComplete: Boolean,
        parentIndicator: Object,
        childIndicator: Object,
        conditions: Object    
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
                    return '';
                case '!=':
                    return 'not';
                case '>':
                    return 'greater than';
                case '<':
                    return 'less than';    
                default: return op;
            }
        }
    },
    template: `<div v-if="conditionInputComplete" id="condition_editor_actions">
        <div class="editor-card-header">Click save to store this condition, or cancel to start over</div>
        <div>
            <div><b>IF</b> parent question '{{parentIndicator.name}}' is 
                <span style="color: #00A91C; font-weight: bold;">
                {{operatorText}} {{conditions.selectedParentValue}}
                </span>
            </div>
            <br/>
            <div> 
                <b>THEN</b> child question '{{childIndicator.name}}'  
                <span v-if="conditions.selectedOutcome==='Pre-fill Question'">will 
                    <span style="color: #00A91C; font-weight: bold;"> have the value '{{conditions.selectedChildValue}}'</span>
                </span>
                <span v-else>will 
                    <span style="color: #00A91C; font-weight: bold;">
                     be {{conditions.selectedOutcome==="Show Question" ? 'shown' : 'hidden'}}
                    </span>
                </span>
            </div>
            <hr/>
            <ul style="display: flex; justify-content: space-between">
            <li style="width: 30%;"><button id="btn_add_condition" @click="$emit('save-condition')">Save Condition</button></li>
            <li style="width: 30%;"><button id="btn_cancel" @click="$emit('cancel-entry','')">Cancel</button></li>
            </ul>
        </div>
    </div>`
});