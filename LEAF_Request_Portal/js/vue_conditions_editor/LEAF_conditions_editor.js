const ConditionsEditor = Vue.createApp({
    data() {
        return {
            test: 'test main app data property'
        }
    },
    beforeMount(){
        //ajax test. TODO: get conditions for form 
        let xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
            if (this.readyState == 4 && this.status == 200) {
                document.getElementById("test_ajax").innerHTML = this.responseText;
            }
        };
        xhttp.open("GET", "../api/form/indicator/list/disabled", true);
        xhttp.send();
        
    },
    template: `<div>
        <div id="condition_editor_content">
            <editor-nav></editor-nav>
            <editor-main></editor-main>
            <editor-actions></editor-actions>
        </div>
        <div style="margin: 1.2em; font-size: 12px"><!-- TEST: -->
            <p>test ajax call to ../api/form/indicator/list/disabled</p>
            <div id="test_ajax"></div>
        </div>
    </div>`
});

ConditionsEditor.component('editor-nav', {
    template: `<div id="condition_editor_nav">
        <h3>Conditions List</h3>
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
    data() {
        return {
            compTest: 'comp data',
        }
    },
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