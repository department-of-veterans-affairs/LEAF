const ConditionsEditor = Vue.createApp({
    data() {
        return {
            forms: [],
            selectedFormCatID: '',
            selectedIndicator: {},
            selectedFormIndicators: [],
            selectedFormConditions: [],
            selectedOperators: [],
            selectedFormat: '',
            formStructure: {} //TEST
        }
    },
    methods: {
        updateSelectedIndicator(indicator){
            this.selectedIndicator = indicator;
            this.selectedOperators = [];
            this.format = indicator.format.indexOf("\n") === -1 ?
                         indicator.format : indicator.format.substr(0, indicator.format.indexOf("\n")).trim();

            switch(this.format) {
                case 'number':
                case 'currency':  //NOTE: currency and number do not have != option in formSearch.js - why? vals are otherwise the same, but text differs
                case 'multiselect':
                case 'dropdown':
                case 'radio':      
                    this.selectedOperators = [
                        {val:"=", text:"IS"}, 
                        {val:"!=", text:"IS NOT"},
                        {val:">", text:">" },
                        {val:">=", text: ">="},
                        {val:"<", text: "<"},
                        {val:"<=",text: "<="}
                    ];
                    break;
                case 'date': //TODO: does back handle type=date inputs?
                    this.selectedOperators = [
                        {val:"=", text: "ON"}, 
                        {val:">=", text:"ON AND AFTER"},
                        {val:"<=", text:"ON AND BEFORE" }
                    ];
                    break;
                case 'orgchart_employee':
                case 'orgchart_group':  
                case 'orgchart_position':
                    break;  
                default:
                    this.selectedOperators = [
                        {val:"LIKE", text: "CONTAINS"}, 
                        {val:"NOT LIKE", text:"DOES NOT CONTAIN"},
                        {val:"=", text:"=" },
                        {val:"!=", text:"!=" }
                    ]; 
                    break;
            }
        },
        getCategoryIndicators(catID) {
            //update catID and clear potential prev indicator selection
            this.selectedFormCatID = catID;
            this.selectedIndicator = {};
            this.selectedOperators = [];
 
            let formStructure = { //TODO: better list menu 
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
                    const formIndicators = indicatorList.filter(indi => indi.categoryID === catID || indi.parentCategoryID === catID);
                    //indicators that already have conditions, for list display / edit
                    const formConditions = formIndicators.filter(indi => indi.condition !== null);
                    this.selectedFormIndicators = formIndicators;
                    this.selectedFormConditions = formConditions;
                    
                    //object that better represents form structure NOTE: not currently used
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
                :selectedIndicators="selectedFormIndicators"
                :selectedIndicatorProp="selectedIndicator"
                :selectedOperators="selectedOperators"
                @update-selected-indicator="updateSelectedIndicator">
            </editor-main>
            <editor-actions></editor-actions>
        </div>

        <div class="TEST">
            <p>selected catID: {{ selectedFormCatID }}</p>
            <p>selected indID: {{ selectedIndicator }}</p>
            <p>indicator info for selected form: {{ selectedFormIndicators }}</p>
            <p>indicators that have conditions: {{ selectedFormConditions }}</p>
        </div>
    </div>`
});


//LIST COMPONENT Allows form selection and shows indicators with conditions for selected form
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
            selectedIndicator: {}
        }
    },
    props: {
        selectedIndicators: Array,
        selectedIndicatorProp: Object,
        selectedOperators: Array
    },
    methods: {
        selectIndicator() {
            this.$emit('update-selected-indicator', this.selectedIndicator);
        }
    },
    template: `<div id="condition_editor_main">
        <h3>Conditions Editor</h3>
        <div v-if="selectedIndicators.length > 0">
            <h4>IF</h4>
            <p>Parent Question Indicator</p>
            <select title="select an indicator" 
                    name="indicator-selector" 
                    v-model="selectedIndicator" 
                    @change="selectIndicator">    
                <option v-for="i in selectedIndicators" :title="i.name" :value="i">{{i.name }} (indicator {{i.indicatorID}})</option>
            </select>
            <div class="TEST">operators based on format: {{ selectedIndicatorProp.format }}</div>
            <select v-if="selectedOperators.length > 0">
                <option v-for="o in selectedOperators" :value="o.val">{{ o.text }}</option>
            </select>
            <input v-if="selectedIndicatorProp.format==='date'" type="date"/>
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