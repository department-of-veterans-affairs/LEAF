export default {
    data() {
        return {
            left: '{{',
            right: '}}',
            formats: {
                text: "Single line text",
                textarea: "Multi-line text",
                grid: "Grid (Table with rows and columns)",
                number: "Numeric",
                currency: "Currency",
                date: "Date",
                radio: "Radio (single select, multiple options)",
                checkbox: "Checkbox (A single checkbox)",
                checkboxes: "Checkboxes (Multiple Checkboxes)",
                multiselect: "Multi-Select Dropdown",
                dropdown: "Dropdown Menu (single select, multiple options)",
                fileupload: "File Attachment",
                image: "Image Attachment",
                orgchart_group: "Orgchart Group",
                orgchart_position: "Orgchart Position",
                orgchart_employee: "Orgchart Employee",
                raw_data: "Raw Data (for programmers)",
            },
            listForParentIDs: [],
            isLoadingParentIDs: true,
            multianswerFormats: ['checkboxes','radio','multiselect','dropdown'],

            name: this.ajaxIndicatorByID[this.currIndicatorID]?.name || '',
            options: this.ajaxIndicatorByID[this.currIndicatorID]?.options || [],//options property is arr of options (if present)
            format: this.ajaxIndicatorByID[this.currIndicatorID]?.format || '',  //format property here is just the format name
            description: this.ajaxIndicatorByID[this.currIndicatorID]?.description || '',
            defaultValue: this.ajaxIndicatorByID[this.currIndicatorID]?.default || '',
            required: parseInt(this.ajaxIndicatorByID[this.currIndicatorID]?.required)===1 || false,
            is_sensitive: parseInt(this.ajaxIndicatorByID[this.currIndicatorID]?.is_sensitive)===1 || false,
            parentID: this.ajaxIndicatorByID[this.currIndicatorID]?.parentID ? 
                    parseInt(this.ajaxIndicatorByID[this.currIndicatorID].parentID) : this.newIndicatorParentID,
            sort: parseInt(this.ajaxIndicatorByID[this.currIndicatorID]?.sort) || 0,
            //checkboxes input
            singleOptionValue: this.ajaxIndicatorByID[this.currIndicatorID]?.format === 'checkbox' ? 
                this.ajaxIndicatorByID[this.currIndicatorID].options : '',
            //multi answer format inputs
            multiOptionValue: ['checkboxes','radio','multiselect','dropdown'].includes(this.ajaxIndicatorByID[this.currIndicatorID]?.format) ? 
                this.ajaxIndicatorByID[this.currIndicatorID].options?.join('\n') : '',
            //used for grid formats
            gridJSON: this.ajaxIndicatorByID[this.currIndicatorID]?.format === 'grid' ? 
                JSON.parse(this.ajaxIndicatorByID[this.currIndicatorID]?.options[0]) : '',

            archived: false,
            deleted: false,
            codeEditorHtml: {},
            codeEditorHtmlPrint: {},
            html: !this.isEditingModal || this.ajaxIndicatorByID[this.currIndicatorID].html === null ? '' : this.ajaxIndicatorByID[this.currIndicatorID].html,
            htmlPrint: !this.isEditingModal || this.ajaxIndicatorByID[this.currIndicatorID].htmlPrint === null ? '' : this.ajaxIndicatorByID[this.currIndicatorID].htmlPrint,
        }
    },
    props: {
        contentProps: Object
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'isEditingModal',
        'closeFormDialog',
        'currCategoryID',
        'currIndicatorID',
        'ajaxIndicatorByID',
        'selectNewCategory',
        'updateCategoriesProperty',
        'newIndicatorParentID',
        'hasDevConsoleAccess'
    ],
    mounted(){
        console.log('indicator-editing mounted');
        if (this.isEditingModal === true) {
            console.log('editing indicator', this.currIndicatorID);
            this.getFormParentIDs().then(res => {
                console.log('indicator-editing got info for parentID selection');
                this.listForParentIDs = res;
                this.isLoadingParentIDs = false;
            });
            this.setupAdvancedOptions();
        } else {
            console.log('new indicator, parentID:', this.parentID);
        }
    },
    computed:{
        isMultiOptionQuestion() {
            return this.multianswerFormats.includes(this.format);
        },
        fullFormatForPost() {
            let fullFormat = this.format;
            switch(this.format){
                case 'grid':
                    this.updateGridJSON();
                    fullFormat = fullFormat + "\n" + JSON.stringify(this.gridJSON);
                    break;
                case 'radio':
                case 'checkboxes':
                case 'multiselect':
                case 'dropdown':
                    fullFormat = fullFormat  + "\n" +  this.formatIndicatorMultiAnswer();
                    break;
                case 'checkbox':
                    fullFormat = fullFormat + "\n" +  this.singleOptionValue;
                    break;
                default:
                    break;
            }
            return fullFormat;
        },
    },
    methods: {
        getFormParentIDs() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}/form/_${this.currCategoryID}/flat`,
                    success: (res)=> resolve(res),
                    error: (err)=> reject(err)
                });
            });
        },
        preventWhenFormatNone(event) {
            if (event.target.id.toLowerCase() === "indicatortype") {
                if (this.format === '' && (this.required === true || this.is_sensitive === true)) {
                    this.required = false;
                    this.is_sensitive = false;
                    alert(`You can't mark a field as sensitive or required if the Input Format is "None".`);
                }
            } else {
                if (this.format === '' && event.target.checked === true) {
                    event.target.checked = false;
                    const id = event.target.id;
                    const text = id === 'sensitive' ? 'sensitive' : 'required';
                    alert(`You can't mark a field as ${text} if the Input Format is "None".`);
                }
            }
        },
        setupAdvancedOptions() {
            this.codeEditorHtml = CodeMirror.fromTextArea(document.getElementById("html"), {
                mode: "htmlmixed",
                lineNumbers: true,
                extraKeys: {
                    "F11": function(cm) {
                        cm.setOption("fullScreen", !cm.getOption("fullScreen"));
                    },
                    "Esc": function(cm) {
                        if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                    },
                    "Ctrl-S": function(cm) {
                        saveCodeHTML();
                    }
                }
            });
            this.codeEditorHtmlPrint = CodeMirror.fromTextArea(document.getElementById("htmlPrint"), {
                mode: "htmlmixed",
                lineNumbers: true,
                extraKeys: {
                    "F11": function(cm) {
                        cm.setOption("fullScreen", !cm.getOption("fullScreen"));
                    },
                    "Esc": function(cm) {
                        if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                    },
                    "Ctrl-S": function(cm) {
                        saveCodeHTMLPrint();
                    }
                }
            });
            //TODO: troubleshooting
        },
        onSave(){
            console.log('clicked indicator-editing save');
            let indicatorEditingUpdates = [];

            if (this.isEditingModal) { /*  CALLS FOR EDITTING AN EXISTING QUESTION */
                console.log('updating an existing indicator: ID#', this.currIndicatorID);
                
                const nameChanged = this.name !== this.ajaxIndicatorByID[this.currIndicatorID].name;
                const descriptionChanged = this.description !== this.ajaxIndicatorByID[this.currIndicatorID].description;

                const options = this.ajaxIndicatorByID[this.currIndicatorID]?.options ? 
                                '\n' + this.ajaxIndicatorByID[this.currIndicatorID]?.options?.join('\n') : '';
                const fullFormatChanged = this.fullFormatForPost !== this.ajaxIndicatorByID[this.currIndicatorID].format + options;

                const defaultChanged = this.defaultValue !== this.ajaxIndicatorByID[this.currIndicatorID].default;
                const requiredChanged = +this.required !== parseInt(this.ajaxIndicatorByID[this.currIndicatorID].required);
                const sensitiveChanged = +this.is_sensitive !== parseInt(this.ajaxIndicatorByID[this.currIndicatorID].is_sensitive);
                const sortChanged = this.sort !== parseInt(this.ajaxIndicatorByID[this.currIndicatorID].sort);
                const parentIDChanged = this.parentID !== this.ajaxIndicatorByID[this.currIndicatorID].parentID;
                //check html and htmlPrint in case code was not saved with the other buttons.
                const htmlChanged = this.html !== this.codeEditorHtml.getValue();
                const htmlPrintChanged = this.htmlPrint !== this.codeEditorHtmlPrint.getValue();
                const shouldArchive = this.archived === true;
                const shouldDelete = this.deleted === true;
            
                console.log(nameChanged,descriptionChanged,fullFormatChanged,defaultChanged,requiredChanged,sensitiveChanged,sortChanged,parentIDChanged,shouldArchive,shouldDelete, htmlChanged, htmlPrintChanged);

                if(nameChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/name`,
                            data: {
                                name: this.name,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) =>  resolve(res),
                            error: err => {
                                console.log('ind name post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(descriptionChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/description`,
                            data: {
                                description: this.description,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind desciption post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(fullFormatChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/format`,
                            data: {
                                format: this.fullFormatForPost,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind format post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(defaultChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/default`,
                            data: {
                                default: this.defaultValue,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind default value post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(requiredChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/required`,
                            data: {
                                required: this.required ? 1 : 0,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind required post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(sensitiveChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/sensitive`,
                            data: {
                                is_sensitive: this.is_sensitive ? 1 : 0,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind is_sensitive post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if (sensitiveChanged && +this.is_sensitive === 1) {
                    indicatorEditingUpdates.push(
                    new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/formNeedToKnow`,
                            data: {
                                needToKnow: 1,
                                categoryID: this.currCategoryID,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => {
                                this.updateCategoriesProperty(this.currCategoryID, 'needToKnow', 1);
                                resolve(res);
                            },
                            error: err => {
                                console.log('set form need to know post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(shouldArchive) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/disabled`,
                            data: {
                                disabled: 1,  //can't undelete from there so this should be fine
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind disabled (archive) post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(shouldDelete) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/disabled`,
                            data: {
                                disabled: 2,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind disabled (deletion) post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(parentIDChanged && this.parentID !== this.currIndicatorID) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/parentID`,
                            data: {
                                parentID: this.parentID,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind parentID post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(sortChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/sort`,
                            data: {
                                sort: this.sort,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind sort post err', err);
                                reject(err);
                            }
                        })
                    }));
                }
                if(htmlChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/html`,
                            data: {
                                html: this.codeEditorHtml.getValue(),
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind html post err', err);
                                reject(err);
                            }
                        });
                    }));                    
                }
                if(htmlPrintChanged) {
                    indicatorEditingUpdates.push(
                        new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/htmlPrint`,
                            data: {
                                htmlPrint: this.codeEditorHtmlPrint.getValue(),
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => resolve(res),
                            error: err => {
                                console.log('ind htmlPrint post err', err);
                                reject(err);
                            }
                        });
                    }));                    
                }

            } else {  /* CALLS FOR CREATING A NEW QUESTION */
                console.log('creating a new indicator on form ', this.currCategoryID);

                if (+this.is_sensitive === 1) {
                    indicatorEditingUpdates.push(
                    new Promise((resolve, reject) => {
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/formNeedToKnow`,
                            data: {
                                needToKnow: 1,
                                categoryID: this.currCategoryID,
                                CSRFToken: this.CSRFToken
                            },
                            success: (res) => {
                                this.updateCategoriesProperty(this.currCategoryID, 'needToKnow', 1);
                                resolve(res);
                            },
                            error: err => {
                                console.log('set form need to know post err', err);
                                reject(err);
                            }
                        })
                    }));
                }

                indicatorEditingUpdates.push(
                new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/newIndicator`,
                        data: {
                            name: this.name,
                            format: this.fullFormatForPost,
                            description: this.description,
                            default: this.defaultValue,
                            parentID: this.parentID,
                            categoryID: this.currCategoryID,
                            required: this.required ? 1 : 0,
                            is_sensitive: this.is_sensitive ? 1 : 0,
                            sort: this.sort,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => resolve(res),
                        error: err => {
                            console.log('error posting new question', err);
                            reject(err);
                        }
                    })
                }));
            }

            Promise.all([indicatorEditingUpdates])
            .then(()=> {
                console.log('promise all:', indicatorEditingUpdates);
                this.closeFormDialog();
                if (indicatorEditingUpdates.length > 0) {
                    vueData.updateIndicatorList = true;          //NOTE: flag IFTHEN app for indicator updates
                    this.selectNewCategory(this.currCategoryID); //selectNew will update vueData formID and trigger click
                }
            });

        },
        radioBehavior(event) {
            const targetId = event.target.id;
            if (targetId.toLowerCase() === 'archived' && this.deleted) {
                document.getElementById('deleted').checked = false
                this.deleted = false;
            }
            if (targetId.toLowerCase() === 'deleted' && this.archived) {
                document.getElementById('archived').checked = false
                this.archived = false;
            }
        },
        addCells(){
            console.log('grid stuff');  //TODO: maybe make grid component for these
        },
        updateGridJSON() {  //TODO: temp from mod_form
            let gridJSON = [];
            //gather column names and column types. if type is dropdown, adds property.options
            $(gridBodyElement).find('div.cell').each(function() {
                let properties = new Object();
                if($(this).children('input:eq(0)').val() === 'undefined'){
                    properties.name = 'No title';
                } else {
                    properties.name = $(this).children('input:eq(0)').val();
                }
                properties.id = $(this).attr('id');
                properties.type = $(this).find('select').val();
                if(properties.type !== undefined){
                    if(properties.type.toLowerCase() === 'dropdown'){
                        properties.options = gridDropdown($(this).find('textarea').val().replace(/,/g, ""));
                    }
                } else {
                    properties.type = 'textarea';
                }
                gridJSON.push(properties);
            });
            this.gridJSON = gridJSON;
        },
        formatIndicatorMultiAnswer() {
            let optionsToArray = this.multiOptionValue.split('\n');
            optionsToArray = optionsToArray.map(option => option.trim());
            optionsToArray = optionsToArray.map(option => option === 'no' ? 'No' : option); //this checks specifically for lower case values
            const uniqueArray = Array.from(new Set(optionsToArray));
            return uniqueArray.join('\n');
        },
        //jQuery plugins and Codemirror for Advanced Options area. from mod_form as is
        advNameEditorClick() {
            $('#advNameEditor').css('display', 'none');
            $('#rawNameEditor').css('display', 'inline');
            $('#name').trumbowyg({
                resetCss: true,
                btns: ['formatting', 'bold', 'italic', 'underline', '|',
                    'unorderedList', 'orderedList', '|',
                    'link', '|',
                    'foreColor', '|',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('.trumbowyg-box').css({
                'min-height': '130px'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '100px',
                'height': '100px'
            });
        },
        rawNameEditorClick() {
            $('#advNameEditor').css('display', 'inline');
            $('#rawNameEditor').css('display', 'none');
            $('#name').trumbowyg('destroy');
        },
        advancedOptionsClick() {
            if(parseInt(this.hasDevConsoleAccess) === 1) {
                $('#button_advanced').css('display', 'none');
                $('#advanced').css('height', 'auto');
                $('#advanced').css('visibility', 'visible');
                $('.table').css('border-collapse', 'collapse');
                $('.CodeMirror').css('border', '1px solid black');
                //this.setupAdvancedOptions();
            } else {
                alert('Notice: Please go to Admin Panel -> LEAF Programmer to ensure continued access to this area.');
                $('#button_advanced').css('display', 'none');
                $('#advanced').css('visibility', 'hidden');
            }
        },
        saveCodeHTML() {
            const htmlValue = this.codeEditorHtml.getValue();
            console.log('htmlValue', htmlValue);
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${this.currIndicatorID}/html`,
                data: {
                    html: htmlValue,
                    CSRFToken: this.CSRFToken
                },
                success: (res)=> {
                    this.html = htmlValue;
                    this.ajaxIndicatorByID[this.currIndicatorID].html = htmlValue;
                    const time = new Date().toLocaleTimeString();
                    document.getElementById('codeSaveStatus_html').innerHTML = '<br /> Last saved: ' + time;
                },
                error: (err) => console.log(err)
            });
        },
        saveCodeHTMLPrint() {
            const htmlPrintValue = this.codeEditorHtmlPrint.getValue();
            console.log('htmlPrintValue', htmlPrintValue, this.currIndicatorID);
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${this.currIndicatorID}/htmlPrint`,
                data: {
                    htmlPrint: htmlPrintValue,
                    CSRFToken: this.CSRFToken
                },
                success: (res)=> {
                    this.htmlPrint = htmlPrintValue;
                    this.ajaxIndicatorByID[this.currIndicatorID].htmlPrint = htmlPrintValue;
                    const time = new Date().toLocaleTimeString();
                    document.getElementById('codeSaveStatus_htmlPrint').innerHTML ='<br /> Last saved: ' + time;
                },
                error: (err) => console.log(err)
            });
        }
    },
    template: `<div style="min-width: 400px;">
        <fieldset>
            <legend>Field Name</legend>
            <textarea id="name" v-model="name" style="width: 99%">{{name}}</textarea><br/>
            <button class="buttonNorm" id="rawNameEditor" @click="rawNameEditorClick" style="display: none">Show formatted code</button>
            <button class="buttonNorm" id="advNameEditor" @click="advNameEditorClick">Advanced Formatting</button>
        </fieldset>
        <fieldset>
            <legend>Short Label (Describe this field in 1-2 words)</legend>
            <input type="text" id="description" v-model="description" maxlength="50" />
        </fieldset>
        <fieldset>
            <legend>Input Format</legend>
            <select id="indicatorType" title="Select a Format" v-model="format" @change="preventWhenFormatNone">
                <option value="">None</option>
                <option v-for="kv in Object.entries(formats)" 
                :value="kv[0]" :selected="kv[0]===format" :key="kv[0]">{{ kv[1] }}</option>
            </select><br/>
            <div v-if="format==='checkbox'" id="container_indicatorSingleAnswer">
                Text for checkbox:<br /> 
                <input type="text" id="indicatorSingleAnswer" v-model="singleOptionValue"/>
            </div>
            <div v-if="isMultiOptionQuestion" id="container_indicatorMultiAnswer">
                One option per line:<br />
                <textarea id="indicatorMultiAnswer" v-model="multiOptionValue" style="width: 80%; height: 150px">
                </textarea>
            </div>
            <div v-if="format==='grid'" id="container_indicatorGrid">
                <span style="position: absolute; color: transparent" aria-atomic="true" aria-live="polite" id="tableStatus" role="status"></span>
                <br/>
                <button class="buttonNorm" id="addColumnBtn" title="Add column" alt="Add column" aria-label="grid input add column" onclick="addCells">
                    <img src="../../libs/dynicons/?img=list-add.svg&w=16" style="height: 25px;"/>
                    Add column
                </button>
                <br/><br/>
                Columns:
                <div border="1" style="overflow-x: scroll; max-width: 100%;">
                </div>
            </div>               
            <fieldset>
                <legend>Default Answer</legend>
                <textarea id="defaultValue" v-model="defaultValue" style="width: 50%;"></textarea>
            </fieldset>
        </fieldset>
        <fieldset><legend>Attributes</legend>
            <table>
                <tr>
                    <td>Required</td>
                    <td>
                        <input id="required" v-model="required" name="required" type="checkbox" 
                        @click="preventWhenFormatNone" @keypress.enter="preventWhenFormatNone"/>
                    </td>
                </tr>
                <tr>
                    <td>Sensitive Data (PHI/PII)</td>
                    <td>
                        <input id="sensitive" v-model="is_sensitive" name="sensitive" type="checkbox" 
                        @click="preventWhenFormatNone" @keypress.enter="preventWhenFormatNone"/>
                    </td>
                </tr>
                <tr>
                    <td>Sort Priority</td>
                    <td><input id="sort" v-model.number="sort" name="sort" type="number" style="width: 40px" /></td>
                </tr>
                <template v-if="isEditingModal">
                <tr>
                    <td>Parent Question ID</td>
                    <td colspan="2">
                        <div id="container_parentID">
                            <select v-model.number="parentID">
                                <template v-if="isLoadingParentIDs===false" v-for="kv in Object.entries(listForParentIDs)">
                                    <option v-if="currIndicatorID !== parseInt(kv[0])" :value="kv[0]" :key="'parent'+kv[0]">{{kv[0]}}: {{kv[1]['1'].name}}</option>
                                </template>
                            </select>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Archive</td>
                    <td colspan="1">
                        <input id="archived" v-model="archived" name="disable_or_delete" type="checkbox" @change="radioBehavior"/>
                    </td>
                    <td style="width: 275px;">
                        <span v-show="archived" id="archived-warning" style="color: red; font-size: 80%;">
                        This field will be archived.  It can be<br/>re-enabled by using Restore Fields.</span>
                    </td>
                </tr>
                <tr>
                    <td>Delete</td>
                    <td colspan="1">
                        <input id="deleted" v-model="deleted" name="disable_or_delete" type="checkbox" @change="radioBehavior" />
                    </td>
                    <td style="width: 275px;">
                        <span v-show="deleted" id="deletion-warning" style="color: red; font-size: 80%;">Deleted items can only be re-enabled<br/>within 30 days by using Restore Fields.</span>
                    </td>
                </tr>
                </template>
            </table>
        </fieldset>
        <template v-if="isEditingModal">
            <span id="button_advanced" class="buttonNorm" tabindex="0" @click="advancedOptionsClick">Advanced Options</span>
            <div v-if="parseInt(hasDevConsoleAccess)===1">
                <fieldset id="advanced" style="visibility: collapse; height: 0;"><legend>Advanced Options</legend>
                    Template Variables:<br />
                    <table class="table" style="border-collapse: inherit">
                        <tr>
                            <td><b>{{ left }} iID {{ right }}</b></td>
                            <td>The indicatorID # of the current data field.</td>
                        </tr>
                        <tr>
                            <td><b>{{ left }} recordID {{ right }}</b></td>
                            <td>The record ID # of the current request.</td>
                        </tr>
                        <tr>
                            <td><b>{{ left }} data {{ right }}</b></td>
                            <td>The contents of the current data field as stored in the database.</td>
                        </tr>
                    </table><br />
                    <div style="display:flex; justify-content: space-between;">
                        html (for pages where the user can edit data): 
                        <button id="btn_codeSave_html" @click="saveCodeHTML" class="buttonNorm" title="Save Code">
                            <img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" />
                            Save Code<span id="codeSaveStatus_html"></span>
                        </button>
                    </div>
                    <textarea id="html">{{html}}</textarea><br />  <!-- NOTE: can't seem to v-model these areas html and htmlPrint properties updated after save -->
                    <div style="display:flex; justify-content: space-between;">
                        htmlPrint (for pages where the user can only read data): 
                        <button id="btn_codeSave_htmlPrint" @click="saveCodeHTMLPrint" class="buttonNorm" title="Save Code">
                            <img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" />
                            Save Code<span id="codeSaveStatus_htmlPrint"></span>
                        </button>
                    </div>
                    <textarea id="htmlPrint">{{htmlPrint}}</textarea>
                </fieldset>
            </div>
        </template>
    </div>`
};