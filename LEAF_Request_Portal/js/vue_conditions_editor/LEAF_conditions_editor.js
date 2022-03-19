const ConditionsEditor = Vue.createApp({
    data() {
        return {
            forms: [],
            indicators: [],
            selectedFormCatID: '',
            selectedIndicator: {},
            selectedFormIndicators: [],
            selectedFormConditions: [],
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
            formStructure: {}, //TODO: use for menu conditions list
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
            this.selectedValueOptions = [];
            this.selectedParentValue = '';
            this.childIndicatorOptions = []; 
            this.childIndicator = {};  //TODO:  more than one.  easy to make array, but other logic will need more work
            this.selectedChildOutcome = '';
            this.selectedChildValueOptions = [];
            this.selectedChildValue = '';
        },
        updateSelectedIndicator(indicatorID){
            this.clearSelections();
            let indicator = this.selectedFormIndicators.find(i => i.indicatorID === indicatorID);
            this.selectedIndicator = {...indicator};
            this.childIndicatorOptions = this.selectedFormIndicators.filter(i => i.indicatorID !== indicator.indicatorID);
            this.selectedValueOptions = indicator.format.indexOf("\n") === -1 ?
                                        [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
    
            const format = indicator.format.indexOf("\n") === -1 ?
                        indicator.format : indicator.format.substr(0, indicator.format.indexOf("\n")).trim();

            switch(format) {
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
                this.selectedFormIndicators = this.indicators.filter(i => !i.format.includes('orgchart') && (i.categoryID === catID || i.parentCategoryID === catID));
                this.selectedFormConditions = this.selectedFormIndicators.filter(i => i.conditions !== null && i.conditions !== '');
            }
            /*let formStructure = { //TEST, TODO: better list menu 
                categoryID: catID,
                indicators: [],
                internalForms: {},
            };
            this.selectedFormIndicators.forEach(indicator => {
                //internal forms
                if (indicator.parentCategoryID === catID) {
                    const internalCatID = indicator.categoryID;
                    if (typeof formStructure.internalForms[internalCatID] !== "undefined") {
                        formStructure.internalForms[internalCatID].push({...indicator});
                    } else {
                        formStructure.internalForms = {...formStructure.internalForms, [internalCatID]: [{...indicator}]};
                    }
                } else {
                    formStructure.indicators.push({...indicator});
                }
            });
            this.formStructure = formStructure; */
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
            let indicator = this.selectedFormIndicators.find(i => i.indicatorID === indicatorID);
            this.childIndicator = indicator;
            this.selectedChildOutcome = '';
            this.selectedChildValue = '';
            this.selectedChildValueOptions = indicator.format.indexOf("\n") === -1 ?
                            [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
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
        }
    },
    computed: {
        formName(){
            if (this.selectedFormCatID !== '') {
                return this.forms.find(f => f.categoryID === this.selectedFormCatID).categoryName;
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
            const {childIndID, parentIndID, selectedOp, selectedParentValue, selectedChildValue, selectedOutcome} = this.conditionInputObject;
            //return true; //NOTE: uncomment to check styling
            return (childIndID && parentIndID && selectedOp //&& selectedParentValue NOTE: blank vals ??
                && (selectedOutcome && selectedOutcome !== "Pre-fill Question" || 
                   (selectedOutcome==="Pre-fill Question" && selectedChildValue !== '')));
        }
    },
    template: `<div>
        <div id="condition_editor_content">
            <editor-list 
                :forms="forms"
                :selectedConditions="selectedFormConditions"
                :selectedFormCatID="selectedFormCatID"
                @update-selected-form="getCategoryIndicators">
            </editor-list>
            <div id="condition_editor_main_panel">
                <editor-main
                    :formName="formName"
                    :selectedValueOptions="selectedValueOptions"
                    :selectedParentValue="selectedParentValue"
                    :selectedIndicators="selectedFormIndicators"
                    :selectedIndicatorProp="selectedIndicator"
                    :selectedParentOperators="selectedParentOperators"
                    :selectedOperator="selectedOperator"
                    :childIndicatorOptions="childIndicatorOptions"
                    :childIndicatorProp="childIndicator"
                    :selectedChildOutcome="selectedChildOutcome"
                    :selectedChildValueOptions="selectedChildValueOptions"
                    :selectedChildValue="selectedChildValue"
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
            <p>{{ conditionComplete ? 'true' : 'false' }}</p>
            <p><b>selected catID:</b> {{ selectedFormCatID }}</p>
            <p><b>selected parent indID:</b> {{ selectedIndicator }}</p>
            <p><b>indicators that have conditions:</b> {{ selectedFormConditions }}</p>
            <p><b>selected condition/operator:</b> {{ selectedOperator }}</p>
            <p><b>selected parent value:</b> {{ selectedParentValue }}</p>
            <p><b>selected outcome:</b> {{ selectedChildOutcome }}</p>
            <p><b>conditions input object:</b> {{ conditionInputObject }}</p>
            <p><b>indicator info for selected form (orgchart values excluded):</b> {{ selectedFormIndicators }}</p>
        </div>
    </div>` 
});


//LIST COMPONENT 
//Allows form selection and shows indicators with conditions for selected form
//TODO: tab indicators with conditions to view details and/or edit
ConditionsEditor.component('editor-list', {
    props: {
        forms: Array,
        selectedConditions: Array,
        selectedFormCatID: String
    },
    methods: {
        toFormEditor(){
            window.location.assign('./?a=form#');
        }
    },
    template: `<div id="condition_editor_list">
        <button id="btn_form_editor" @click="toFormEditor">Back to Form Editor</button>
        <hr/>
        <p>Select a form to begin adding a condition</p>
        <select title="select a form" name="form-selector" @change="$emit('update-selected-form', $event.target.value)">
            <option v-if="selectedFormCatID===''" value="" selected>Select a Form</option>
            <option v-for="f in forms" :title="f.categoryName" :value="f.categoryID">{{f.categoryName}}</option>
        </select>
        <hr/>
        <h3>Conditions List</h3>
        
        <p v-if="selectedConditions.length===0">No conditions have been added to this form</p>
        <div v-else>
            <p>Conditions have been added to the child indicators listed below</p>
            <ul>
                <li v-for="c in selectedConditions">{{ c.name }} (indicator {{ c.indicatorID }})</li>
            </ul>
        </div>
    </div>`
});


//CENTER EDITOR WIDGET
ConditionsEditor.component('editor-main', {
    props: {
        selectedIndicatorProp: Object,  //info for the currently selected indicator
        childIndicatorProp: Object,
        selectedIndicators: Array,      //all available inds for currently selected form
        childIndicatorOptions: Array,   //which indicators can be chosen for children
        selectedParentOperators: Array, //available operators, based on format of above ind
        selectedOperator: String,       //selectedOp, value and outcome used to update selectors if empty
        selectedValueOptions: Array,    //values for dropdown formats
        selectedParentValue: String,
        selectedChildOutcome: String,
        selectedChildValueOptions: Array,
        selectedChildValue: String,
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
        <h3>Conditions Editor</h3>
        <div v-if="formName">
            <p>Adding condition to form: <span class="edit-form-name"> {{formName}}</span></p>
            <hr/>
        </div>
        <p v-else>Please select a form to begin</p>
        
        <div v-if="selectedIndicators.length > 1">
            <h4>IF</h4>
            <span>Parent Question Indicator</span>
            <select title="select an indicator" 
                    name="indicator-selector" 
                    @change="$emit('update-selected-indicator', $event.target.value)">
                <option v-if="!selectedIndicatorProp?.indicatorID" value="" selected>Select an Indicator</option>        
                <option v-for="i in selectedIndicators" :title="i.name" :value="i.indicatorID">{{i.name }} (indicator {{i.indicatorID}})</option>
            </select>
            
            <select v-if="selectedParentOperators.length > 0"
                @change="$emit('update-selected-operator', $event.target.value)">
                <option v-if="selectedOperator===''" value="" selected>Select a condition</option>
                <option v-for="o in selectedParentOperators" :value="o.val">{{ o.text }}</option>
            </select>

            <input v-if="selectedIndicatorProp.format==='date'" type="date"
                @change="$emit('update-selected-parent-value', $event.target.value)"/>
            <input v-else-if="selectedIndicatorProp.format==='number'" type="number"
                @change="$emit('update-selected-parent-value', $event.target.value)"/>
            <input v-else-if="selectedIndicatorProp.format==='currency'"
                id="currency-format-input" 
                type="number" step="0.01" @change="validateCurrency"/>
            <select v-else-if="typeof selectedIndicatorProp.format === 'string' 
                && selectedIndicatorProp.format.includes('dropdown')"
                @change="$emit('update-selected-parent-value', $event.target.value)">
                <option v-if="selectedParentValue===''" value="" selected>Select a value</option>    
                <option v-for="val in selectedValueOptions"> {{ val }} </option>
            </select>
            <select v-else-if="typeof selectedIndicatorProp.format === 'string' 
                && selectedIndicatorProp.format.includes('radio')"
                @change="$emit('update-selected-parent-value', $event.target.value)">
                <option v-if="selectedParentValue===''" value="" selected>Select a value</option> 
                <option v-for="val in selectedValueOptions"> {{ val }} </option>
            </select>
            <p v-else class="TEST">value selection still in progress for some formats</p>
            <hr/>
            <h4>THEN</h4>
            <span>Child Question Indicator</span>
            <select title="select an indicator" 
                    name="child-indicator-selector" 
                    @change="$emit('update-selected-child', $event.target.value)">
                <option v-if="!childIndicatorProp?.indicatorID" value="" selected>Select an Indicator</option>        
                <option v-for="c in childIndicatorOptions" :title="c.name" :value="c.indicatorID">{{c.name }} (indicator {{c.indicatorID}})</option>
            </select>
            
            <select v-if="childIndicatorProp?.indicatorID" title="select outcome"
                    name="child-outcome-selector"
                    @change="$emit('update-selected-outcome', $event.target.value)">
                    <option v-if="selectedChildOutcome===''" value="" selected>Select an outcome</option> 
                    <option value="Show Question">Show Question</option>
                    <option value="Hide Question">Hide Question</option>
                    <option value="Pre-fill Question">Pre-fill Question</option>
            </select>
            <span v-if="selectedChildOutcome==='Pre-fill Question'">Enter a pre-fill value</span>
            <!-- TODO: other formats - only testing dropdown for now -->
            <select v-if="selectedChildOutcome==='Pre-fill Question'"
                @change="$emit('update-selected-child-value', $event.target.value)">
                <option v-if="selectedChildValue===''" value="" selected>Select a value</option>    
                <option v-for="val in selectedChildValueOptions" :value="val"> {{ val }} </option>
            </select>
        </div>
        <div v-if="selectedIndicators.length === 1">This form only has one indicator</div>
        <div v-if="formName && !selectedIndicators.length">No options available for the indicators on this form</div>
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
                    return 'equal to';
                case '!=':
                    return 'not equal to';
                case '>':
                    return 'greater or later than';
                case '<':
                    return 'less or earlier than';    
                default: return op;
            }
        }
    },
    template: `<div v-if="conditionInputComplete" id="condition_editor_actions">
    <p>Click save to store the condition, or cancel to start over</p>
    <div class="condition-card">
        <p><b>IF</b> parent question {{parentIndicator.name}} is 
            {{operatorText}} {{conditions.selectedParentValue}}, <b>THEN</b> child question {{childIndicator.name}} 
            <span v-if="conditions.selectedOutcome==='Pre-fill Question'">will have the value {{conditions.selectedChildValue}}</span>
            <span v-else>will be {{conditions.selectedOutcome==="Show Question" ? 'shown' : 'hidden'}}</span>
        </p>
    </div>
    <ul style="display: flex; justify-content: space-between">
        <li style="width: 30%;"><button id="btn_add_condition" @click="$emit('save-condition')">Save Condition</button></li>
        <li style="width: 30%;"><button id="btn_cancel" @click="$emit('cancel-entry','')">Cancel</button></li>
    </ul>
    </div>`
});