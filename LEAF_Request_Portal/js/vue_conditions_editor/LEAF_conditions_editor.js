const ConditionsEditor = Vue.createApp({
    data() {
        return {
            forms: [],
            selectedFormCatID: ''
        }
    },
    methods: {
    },
    beforeMount(){
        //get forms for dropdown
        let xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = () => {
            if (xhttp.readyState == 4 && xhttp.status == 200) {
                const list = JSON.parse(xhttp.responseText);
                const filteredList = list.filter(ele => ele.categoryID.includes('form_'));
                this.forms = filteredList.sort((a,b) => a.categoryName - b.categoryName).slice();
            }
        };
        xhttp.open("GET", "../api/form/categories", true);
        xhttp.send();
    },
    template: `<div>
        <div id="condition_editor_content">
            <editor-nav :forms="forms"></editor-nav>
            <editor-main></editor-main>
            <editor-actions></editor-actions>
        </div>
    </div>`
});


ConditionsEditor.component('editor-nav', {
    data() {
        return {
            selectedCategoryID: ''
        }
    },
    props: {
        forms: Array
    },
    methods: {
        selectForm(){
            //TODO:
        }
    },
    template: `<div id="condition_editor_nav">
        <h3>Conditions List</h3>
        <!-- TODO: emit to parent for other components -->
        <select title="select a form" name="form-selector" v-model="selectedCategoryID"> 
            <option v-for="f in forms" :title="f.categoryName" :value="f.categoryID">{{f.categoryName}}</option>
        </select>
        <p>selected catID: {{ selectedCategoryID }}</p>
        <ul>
            <li>temp</li>
            <li>list</li>
            <li>items</li>
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