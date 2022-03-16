const ConditionsEditor = Vue.createApp({
    data() {
        return {
            forms: [],
            selectedFormCatID: '',
            selectedIndicator: {},
            selectedFormIndicators: [],
            selectedFormConditions: [],
            selectedParentOperators: [],
            selectedFormat: '',
            selectedValueOptions: [], //for radio, dropdown
            childIndicator: {},
            childIndicatorOptions: [],  //selectedform inds - selected ind
            formStructure: {} //TEST, TODO:
        }
    },
    methods: {
        updateSelectedIndicator(indicator){
            this.selectedIndicator = indicator;
            this.selectedParentOperators = [];
            this.selectedValueOptions = [];
            this.childIndicator = {};
            this.childIndicatorOptions = this.selectedFormIndicators.filter(i => i.indicatorID !== indicator.indicatorID);

            this.format = indicator.format.indexOf("\n") === -1 ?
                         indicator.format : indicator.format.substr(0, indicator.format.indexOf("\n")).trim();
            this.selectedValueOptions = indicator.format.indexOf("\n") === -1 ?
                         [] : indicator.format.slice(indicator.format.indexOf("\n")+1).split("\n");
            console.log(indicator.format, 'val options', this.selectedValueOptions);             
            switch(this.format) {
                case 'number':
                case 'currency':
                    this.selectedParentOperators = [
                        {val:"==", text: "is equal to"}, 
                        {val:"!=", text: "is not equal to"},
                        {val:">", text: "is greater than"},
                        {val:">=", text: "is greater than or equal to"},
                        {val:"<", text: "is less than"},
                        {val:"<=",text: "is less than or equal to"}
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
                case 'orgchart_employee': //NOTE: orgchart formats are currently excluded from indicator selection
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
            //update catID and clear potential prev indicator selection
            this.selectedFormCatID = catID;
            this.selectedIndicator = {};
            this.selectedParentOperators = [];
            this.selectedValueOptions = [];  //values for radio, multiselect, dropdown formats
            this.childIndicatorOptions = []; //which child indicators can be selected
 
            let formStructure = { //TEST, TODO: better list menu 
                categoryID: catID,
                indicators: [],
                internalForms: {},
            };
            //get indicators for selected form
            const xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = () => {
                if (xhttp.readyState == 4 && xhttp.status == 200) {
                    const indicatorList = JSON.parse(xhttp.responseText);
                    //all indicators associated with this form, for dropdown selection to add conditions
                    const formIndicators = indicatorList.filter(indi => !indi.format.includes('orgchart') && (indi.categoryID === catID || indi.parentCategoryID === catID));
                    //indicators that already have conditions, for list display / edit
                    const formConditions = formIndicators.filter(indi => indi.condition !== null && indi.condition !== '');
                    this.selectedFormIndicators = formIndicators;
                    this.selectedFormConditions = formConditions;
                    
                    //object that better represents form structure TEST, TODO: NOTE: not currently used
                    formIndicators.forEach(indicator => {
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
                    this.formStructure = formStructure;
                }
            };
            xhttp.open("GET", `../api/form/indicator/list`, true);
            xhttp.send(); //*/
        }
    },
    beforeMount(){
        //get forms for dropdown
        //* NOTE: xml
        const xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = () => {
            if (xhttp.readyState == 4 && xhttp.status == 200) {
                const list = JSON.parse(xhttp.responseText);
                const filteredList = list.filter(ele => ele.categoryID.includes('form_'));
                this.forms = filteredList.sort((a,b) => a.categoryName - b.categoryName).slice();
            }
        };
        xhttp.open("GET", "../api/form/categories", true);
        xhttp.send(); //*/
        /* //NOTE: fetch API, not sure which might be better here
        fetch("../api/form/categories").then(response => { 
                const contentType = response.headers.get('content-type');
                if (!contentType || !contentType.includes("application/json")) {
                    throw new TypeError("returned content-type not JSON");
                }
                if (response.status !== 200) {
                    console.log('status:', response.status, response.statusText);
                } else return response.json();
            }).then(data => {
                const filteredData = data.filter(ele => ele.categoryID.includes('form_'));
                this.forms = filteredData.sort((a,b) => a.categoryName - b.categoryName).slice();
            }).catch(err => console.log(err));*/
    },
    template: `<div>
        <div id="condition_editor_content">
            <editor-list 
                :forms="forms" 
                :selectedConditions="selectedFormConditions"
                @update-selected-form="getCategoryIndicators">
            </editor-list>
            <editor-main
                :selectedValueOptions="selectedValueOptions" 
                :selectedIndicators="selectedFormIndicators"
                :selectedIndicatorProp="selectedIndicator"
                :selectedParentOperators="selectedParentOperators"
                :childIndicatorOptions="childIndicatorOptions"
                @update-selected-indicator="updateSelectedIndicator">
            </editor-main>
            <editor-actions></editor-actions>
        </div>

        <div class="TEST">
            <p><b>selected catID:</b> {{ selectedFormCatID }}</p>
            <p><b>selected indID:</b> {{ selectedIndicator }}</p>
            <p><b>indicator info for selected form:</b> {{ selectedFormIndicators }}</p>
            <p><b>indicators that have conditions:</b> {{ selectedFormConditions }}</p>
        </div>
    </div>`
});


//LIST COMPONENT 
//Allows form selection and shows indicators with conditions for selected form
//TODO: tab indicators with conditions to view details and/or edit
ConditionsEditor.component('editor-list', {
    data() {
        return {
            selectedCategoryID: ''
        }
    },
    props: {
        forms: Array,
        selectedConditions: Array
    },
    methods: {
        selectForm(){
            this.$emit('update-selected-form', this.selectedCategoryID);
        }
    },
    template: `<div id="condition_editor_list">
        <h3>Conditions List</h3>
        <select title="select a form" name="form-selector" v-model="selectedCategoryID" @change="selectForm"> 
            <option v-for="f in forms" :title="f.categoryName" :value="f.categoryID">{{f.categoryName}}</option>
        </select>
        <ul>
            <li v-for="c in selectedConditions">{{ c.name }} (indicator {{ c.indicatorID }})</li>
        </ul>
    </div>`
});



//MAIN EDITOR WIDGET
ConditionsEditor.component('editor-main', {
    data() {
        return {
            selectedIndicator: {},
            selectedChildIndicator: {}
        }
    },
    props: {
        selectedIndicators: Array,      //all available inds for currently selected form
        selectedIndicatorProp: Object,  //info for the currently selected indicator
        selectedParentOperators: Array,       //available operators for the format of above ind
        selectedValueOptions: Array,    //values for dropdown formats
        childIndicator: Object,
        childIndicatorOptions: Array, //which indicators can be chosen for children
    },
    methods: {
        selectIndicator() {
            this.$emit('update-selected-indicator', this.selectedIndicator);
        },
        selectChildIndicator() {
            this.$emit('update-selected-child', this.selectedChildIndicator);
        },
        validateCurrency(event){
            const currencyRegex = /^(\d*)(\.\d{0,2})?$/;
            const val = event.target.value;
            if (!currencyRegex.test(val)) { //TODO: userfeedback
                document.getElementById('currency-format-input').value = '';
            }
        },
    },
    template: `<div id="condition_editor_main">
        <h3>Conditions Editor</h3>
        <div v-if="selectedIndicators.length > 0">
            <h4>IF</h4>
            <span>Parent Question Indicator</span>
            <select title="select an indicator" 
                    name="indicator-selector" 
                    v-model="selectedIndicator" 
                    @change="selectIndicator">    
                <option v-for="i in selectedIndicators" :title="i.name" :value="i">{{i.name }} (indicator {{i.indicatorID}})</option>
            </select>
            <select v-if="selectedParentOperators.length > 0">
                <option v-for="o in selectedParentOperators" :value="o.val">{{ o.text }}</option>
            </select>
            <input v-if="selectedIndicatorProp.format==='date'" type="date"/>
            <input v-if="selectedIndicatorProp.format==='number'" type="number"/>
            <input v-if="selectedIndicatorProp.format==='currency'"
                id="currency-format-input" 
                type="number" step="0.01" @change="validateCurrency"/>
            <select v-if="typeof selectedIndicatorProp.format === 'string' 
                && selectedIndicatorProp.format.includes('dropdown')">
                <option v-for="val in selectedValueOptions"> {{ val }} </option>
            </select>
            <select v-if="typeof selectedIndicatorProp.format === 'string' 
            && selectedIndicatorProp.format.includes('radio')">
                <option v-for="val in selectedValueOptions"> {{ val }} </option>
            </select>     
            <h4>THEN</h4>
            <span>Child Question Indicator</span>
            <select title="select an indicator" 
                    name="child-indicator-selector" 
                    v-model="selectedChildIndicator" 
                    @change="selectChildIndicator">    
                <option v-for="c in childIndicatorOptions" :title="c.name" :value="c">{{c.name }} (indicator {{c.indicatorID}})</option>
            </select>
        </div>
    </div>`
});



ConditionsEditor.component('editor-actions', {
    template: `<div id="condition_editor_actions">
            <h3>Actions</h3>
            <ul>
                <li><button id="btn_add_condition" @click="addCondition">+ Add Condition</button></li>
                <li><button id="btn_form_editor" @click="toFormEditor">Back to Form Editor</button></li>
            </ul>
        </div>`,
    props: {
        selectedIndicators: Array
    },
    methods: {
        addCondition(){
            console.log('clicked');
            this.$emit('add-condition')
        },
        toFormEditor(){
            window.location.assign('./?a=form#');
        }
    }
});

ConditionsEditor.mount('#LEAF_conditions_editor')