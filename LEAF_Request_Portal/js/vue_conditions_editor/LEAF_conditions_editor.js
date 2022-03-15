const ConditionsEditor = Vue.createApp({
    data() {
        return {
            forms: [],
            selectedFormCatID: '',
            selectedFormIndicators: []
        }
    },
    methods: {
        getCategoryIndicators(catID) {
            this.selectedFormCatID = catID;
            //update selectedFormCatID and get indicators for list
            //*
            const xhttp = new XMLHttpRequest();
            let formStructure = {
                categoryID: catID,
                indicators: [],
                internalForms: {},
            };
            xhttp.onreadystatechange = () => {
                if (xhttp.readyState == 4 && xhttp.status == 200) {
                    const indicatorList = JSON.parse(xhttp.responseText);
                    //
                    const filteredList = indicatorList.filter(form => form.categoryID === catID || form.parentCategoryID === catID);
                    this.selectedFormIndicators = filteredList;
                    console.log(filteredList);
                    //object that better represents form structure
                    filteredList.forEach(indicator => {
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
                    console.log(formStructure);
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
        /* //NOTE: fetch API
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
            <editor-list :forms="forms" 
                :selectedIndicators="selectedFormIndicators"
                @update-selected-form="getCategoryIndicators">
            </editor-list>
            <editor-main></editor-main>
            <editor-actions></editor-actions>
        </div>
    </div>`
});


ConditionsEditor.component('editor-list', {
    data() {
        return {
            selectedCategoryID: ''
        }
    },
    props: {
        forms: Array,
        selectedIndicators: Array
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
        <i class="TEST"><p>selected catID: {{ selectedCategoryID }}</p>
        <p>indicator info (placeholder)</p></i>
        <ul>
            <li v-for="i in selectedIndicators">{{ i.name }} (indicator {{ i.indicatorID }})</li>
        </ul>
    </div>`
});



ConditionsEditor.component('editor-main', {
    template: `<div id="condition_editor_main">
        <h3>Conditions Editor</h3>
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
    methods: {
        addCondition(){
            console.log('called addCondition')
        },
        toFormEditor(){
            window.location.assign('./?a=form#');
        }
    }
});

ConditionsEditor.mount('#LEAF_conditions_editor')