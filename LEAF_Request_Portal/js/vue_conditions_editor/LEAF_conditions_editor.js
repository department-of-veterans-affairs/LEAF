const ConditionsEditor = Vue.createApp({
    data() {
        return {
            vueData: vueData,  //obj w formID: 0,formTitle: '',indicatorID: 0,icons: [], updateIndicatorList: false
            windowTop: 0,
            //indicatorOrg: {},  debug
            indicators: [],
            selectedParentIndicator: {},
            selectedParentOperators: [],
            selectedOperator: '',
            selectedParentValue: '',
            selectedParentValueOptions: [],   //for radio, dropdown
            childIndicator: {},
            selectableParents: [],
            selectedChildOutcome: '',
            selectedChildValueOptions: [],
            selectedChildValue: '',
            showRemoveConditionModal: false
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
            const xhttpInds = new XMLHttpRequest();
            xhttpInds.onreadystatechange = () => {
                if (xhttpInds.readyState == 4 && xhttpInds.status == 200) {
                    const list = JSON.parse(xhttpInds.responseText);
                    const filteredList = list.filter(ele => parseInt(ele.indicatorID) > 0 && ele.isDisabled===0);
                    this.indicators = filteredList;
                    
                    /* this.indicators.forEach(i => {  //debug, make object for organization according to header
                        if (i.parentIndicatorID === null){
                            this.indicatorOrg[i.indicatorID] = {header: i, indicators:{}};
                        }
                    });*/
                    this.indicators.forEach(i => { 
                        if (i.parentIndicatorID !== null) { //no need to check headers themselves
                            this.crawlParents(i,i);
                        }    
                    });
                    this.vueData.updateIndicatorList = false;
                    console.log('indicators have been updated: ', this.indicators);
                }
            };
            //get the headers too, need to figure out what they are for each child
            xhttpInds.open("GET", `../api/form/indicator/list/unabridged`, true);
            xhttpInds.send();
        },
        clearSelections(resetAll = false){
            //cleared when either the form or child indicator changes
            if(resetAll){
                this.vueData.indicatorID = 0;
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
        },
        updateSelectedParentIndicator(indicatorID){
            const indicator = this.indicators.find(i => indicatorID !== null && i.indicatorID === indicatorID);
            //handle scenario if a parent is archived/deleted
            if(indicator===undefined) {
                console.log(`parent ${indicatorID} not found`)
                this.parentFound = false;
                return;
            } else this.parentFound = true;

            const valueOptions = indicator.format.indexOf("\n") === -1 ? [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
           
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
        updateSelectedOutcome(outcome){
            let parentEl;
            parentEl = document.getElementById('parent-editor');
            parentEl.style.display = 'block';
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
                        i.indicatorID !== this.childIndicator.indicatorID &&
                        i.format.indexOf('dropdown') === 0;  //TEST  Dropdowns only, for testing
                });
                /*if(indicator.conditions !== null && indicator.conditions !== ''){
                    const conditionObj = JSON.parse(indicator.conditions);
                    if(conditionObj.length===1){
                        this.selectConditionFromList(conditionObj[0]);    
                    }
                }*/
            }
            const xhttpForm = new XMLHttpRequest();
            xhttpForm.onreadystatechange = () => {
                if (xhttpForm.readyState == 4 && xhttpForm.status == 200) {
                    const form = JSON.parse(xhttpForm.responseText);
                    form.forEach((formheader, index) => {
                        this.indicators.forEach(ind => {
                            if (ind.headerIndicatorID===formheader.indicatorID){
                                ind.formPage=index;
                            }
                        })
                    });
                }
            };
            xhttpForm.open("GET", `../api/form/_${this.vueData.formID}`, false);
            xhttpForm.send();
        },
        crawlParents(indicator, initialIndicator) {
            const parentIndicatorID = indicator.parentIndicatorID;
            const parent = this.indicators.find(i => i.indicatorID === parentIndicatorID);

            if (parent.parentIndicatorID === null) {
                //debug this.indicatorOrg[parentIndicatorID].indicators[initialIndicator.indicatorID] = {...initialIndicator, headerIndicatorID: parentIndicatorID};
                //add information about the headerIndicatorID to the indicators
                let indToUpdate = this.indicators.find(i => i.indicatorID===initialIndicator.indicatorID);
                indToUpdate.headerIndicatorID = parentIndicatorID;
            } else {
                this.crawlParents(parent, initialIndicator);
            }
        },
        postCondition(){
            const { childIndID }  = this.conditionInputObject;
            if (this.conditionComplete) {
                let indToUpdate = this.indicators.find(i => i.indicatorID === this.conditionInputObject.childIndID);
                let updatedConditions = (indToUpdate.conditions === '' || indToUpdate.conditions === null)
                    ? [] : JSON.parse(indToUpdate.conditions);
                if (!updatedConditions.some(condition => condition.selectedOutcome === this.conditionInputObject.selectedOutcome)) {
                    updatedConditions.push(this.conditionInputObject);
                } else {
                    let remainingConditions = updatedConditions.filter(condition => condition.selectedOutcome !== this.conditionInputObject.selectedOutcome);
                    remainingConditions.push(this.conditionInputObject);
                    updatedConditions = remainingConditions;
                }

                const pkg = JSON.stringify(updatedConditions);
                let form = new FormData();
                form.append('CSRFToken', CSRFToken);
                form.append('conditions', pkg);

                const xhttp = new XMLHttpRequest();
                xhttp.open("POST", `../api/formEditor/${childIndID}/conditions`, true);
                xhttp.send(form);
                xhttp.onreadystatechange = () => {
                    if (xhttp.readyState == 4 && xhttp.status == 200) {
                        const res = JSON.parse(xhttp.responseText);
                        //TODO: return better indication of success, currently just empty array
                        if (res !== 'Invalid Token.') {
                            indToUpdate.conditions = pkg; //update the indicator in the indicators list
                            this.clearSelections(true);
                        }
                    }
                };
            } else {
                console.log('condition object not complete');
            }
        },
        removeCondition(confirmDelete=false){
            if(confirmDelete){
                const { childIndID, selectedOutcome }  = this.conditionInputObject;
                if (childIndID !== undefined) {
                    const currConditions = JSON.parse(this.indicators.find(i => i.indicatorID === childIndID).conditions) || [];
                    let newConditions = currConditions.filter(c => c.selectedOutcome !== selectedOutcome);
                    
                    let form = new FormData();
                    form.append('CSRFToken', CSRFToken);
                    form.append('conditions', JSON.stringify(newConditions));

                    const xhttp = new XMLHttpRequest();
                    xhttp.open("POST", `../api/formEditor/${childIndID}/conditions`, true);
                    xhttp.send(form); 
                    xhttp.onreadystatechange = () => {
                        if (xhttp.readyState == 4 && xhttp.status == 200) {
                            const res = JSON.parse(xhttp.responseText);
                            //TODO: return better indication of success, currently just empty array
                            if (res !== 'Invalid Token.') { 
                                console.log('running del')
                                let indToUpdate = this.indicators.find(i => i.indicatorID === childIndID);
                                indToUpdate.conditions = JSON.stringify(newConditions); //update the indicator in the indicators list
                                //this.vueData.indicatorID = 0;
                            }
                        }
                    };
                }
                this.showRemoveConditionModal = false;
                this.clearSelections(true);
            } else {
                this.showRemoveConditionModal = true;
            }
        },
        selectConditionFromList(conditionObj){
            let parentEl;
            parentEl = document.getElementById('parent-editor');
            parentEl.style.display = 'block';
            //console.log('called', conditionObj, conditionObj?.parentIndID);
            //update par and chi ind, other values
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
                    (selectedOutcome && selectedOutcome !== "Pre-fill Question" || 
                    (selectedOutcome==="Pre-fill Question" && selectedChildValue !== ''))
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
                @update-indicator-list="getAllIndicators"
                @update-selected-parent="updateSelectedParentIndicator"
                @update-selected-child="updateSelectedChildIndicator"
                @update-selected-operator="updateSelectedOperator"
                @update-selected-parent-value="updateSelectedParentValue"
                @update-selected-outcome="updateSelectedOutcome"
                @set-condition="selectConditionFromList"
                @update-selected-child-value="updateSelectedChildValue">
            </editor-main>
            <editor-actions
                :showRemoveConditionModal="showRemoveConditionModal"
                :conditionInputComplete="conditionComplete"
                :parentIndicator="selectedParentIndicator"
                :childIndicator="childIndicator"
                :conditions="conditionInputObject"
                @save-condition="postCondition"
                @remove-condition="removeCondition"
                @cancel-delete="showRemoveConditionModal=false"
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
        conditions: Object
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
            if(this.vueData.updateIndicatorList===true){ //set to T in mod_form if new ind or ind edited, then to F after new fetch
                this.$emit('update-indicator-list');
            } else {
                this.$emit('update-selected-child');
            }
        },
        getIndicatorName(id){
            let indicatorName = '';
            indicatorName = this.indicators.find(indicator => indicator.indicatorID === id)?.name;
            indicatorName = indicatorName.slice(0,50);
            return indicatorName;
        }
    },
    computed: {
        savedConditions(){
            return this.selectedChild.conditions ? JSON.parse(this.selectedChild.conditions)
                    : [];
        }
    },
    template: `<div id="condition_editor_inputs">
        <button id="btn-vue-update-trigger" @click="forceUpdate" style="display:none;"></button>
        <div v-if="vueData.formID!==0" id="condition_editor_center_panel_header" class="editor-card-header">
            <h3 style="color:black;">Conditions Editor<span class="form-name">
                &nbsp;<i class="fas fa-caret-right"></i>&nbsp;
                {{ vueData.formTitle }}
            </span></h3>
        </div>
        <div>
            <span class="input-info">Controlled Question</span>
            <i><p style="color: #900; font-weight:bold">{{selectedChild.name }} (indicator {{selectedChild.indicatorID}})</p></i>     
            <div v-if="savedConditions && savedConditions.length > 0">
                <div v-for="c in savedConditions"
                key="c" 
                @click="$emit('set-condition', c)">
                <button class="savedConditionsCard"><u>{{c.selectedOutcome}}</u> <strong>IF</strong> 
                '{{getIndicatorName(c.parentIndID)}}...' 
                {{c.selectedOp}} <strong>{{c.selectedParentValue}}</strong></button>
                </div>
            </div>
        </div>
        <div id="outcome-editor">
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
            <select v-if="conditions.selectedOutcome==='Pre-fill Question' && childFormat==='dropdown'"
                @change="$emit('update-selected-child-value', $event.target.value)">
                <option v-if="conditions.selectedChildValue===''" value="" selected>Select a value</option>    
                <option v-for="val in selectedChildValueOptions" 
                :value="val"
                :selected="conditions.selectedChildValue===val"> 
                {{ val }} 
                </option>
            </select>
        </div>
        <div v-if="selectableParents.length > 0" id="parent-editor">
            <h4>WHEN</h4>
            <span class="input-info">Parent question</span>
            <select title="select an indicator" 
                    name="indicator-selector" 
                    @change="$emit('update-selected-parent', $event.target.value)">
                <option v-if="!conditions.parentIndID" value="" selected>Select an Indicator</option>        
                <option v-for="i in selectableParents" 
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
                    <option v-for="val in selectedParentValueOptions"
                        :selected="conditions.selectedParentValue===val"> {{ val }}
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
    template: `<div id="condition_editor_actions">
            <div v-if="conditionInputComplete===true" class="editor-card-header">Click save to store this condition, or cancel to start over
            </div>
            <div v-if="conditionInputComplete">
                <div><b>IF</b> parent question '{{parentIndicator.name}}' is 
                    <span style="color: #00A91C; font-weight: bold;">
                    {{operatorText}} {{conditions.selectedParentValue}}
                    </span>
                    <br/>
                </div>
                <div> 
                    <b>THEN</b> controlled question '{{childIndicator.name}}'  
                    <span v-if="conditions.selectedOutcome==='Pre-fill Question'">will 
                        <span style="color: #00A91C; font-weight: bold;"> have the value '{{conditions.selectedChildValue}}'</span>
                    </span>
                    <span v-else>will 
                        <span style="color: #00A91C; font-weight: bold;">
                        be {{conditions.selectedOutcome==="Show Question" ? 'shown' : 'hidden'}}
                        </span>
                    </span>
                </div>
            </div>
            <div v-if="!showRemoveConditionModal">
                <ul style="display: flex; justify-content: space-between;">
                    <li style="width: 30%;">
                        <button v-if="conditionInputComplete" id="btn_add_condition" @click="$emit('save-condition')">Save</button>
                    </li>
                    <li style="width: 30%;">
                        <button v-if="conditionInputComplete" id="btn_remove_condition" @click="$emit('remove-condition')">Remove</button>
                    </li>
                    <li style="width: 30%;">
                        <button id="btn_cancel" @click="$emit('cancel-entry','')">Cancel</button>
                    </li>
                </ul>
            </div>
            <div v-else>
                <div>Choose <b>Delete</b> to confirm removal, or <b>cancel</b> to return</div>
                <ul style="display: flex; justify-content: space-between; margin-top: 1em">
                    <li style="width: 30%;">
                        <button id="btn_remove_condition" @click="$emit('remove-condition', true)">Delete</button>
                    </li>
                    <li style="width: 30%;">
                        <button id="btn_cancel" @click="$emit('cancel-delete')">Cancel</button>
                    </li>
                </ul>
            </div>
        </div>`
});
ConditionsEditor.mount('#LEAF_conditions_editor');