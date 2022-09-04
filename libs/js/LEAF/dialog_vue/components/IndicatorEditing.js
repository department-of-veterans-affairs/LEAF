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
            multianswerFormats: ['checkboxes','radio','multiselect','dropdown'],
            name: this.ajaxIndicatorByID[this.currIndicatorID]?.name || '',
            options: this.ajaxIndicatorByID[this.currIndicatorID]?.options || '',
            //format property of the indicator from ajax is just the format name
            format: this.ajaxIndicatorByID[this.currIndicatorID]?.format || '',
            description: this.ajaxIndicatorByID[this.currIndicatorID]?.description || '',
            defaultValue: this.ajaxIndicatorByID[this.currIndicatorID]?.default || '',
            required: this.ajaxIndicatorByID[this.currIndicatorID]?.required==='1' || false,
            is_sensitive: this.ajaxIndicatorByID[this.currIndicatorID]?.is_sensitive==='1' || false,
            parentID: this.ajaxIndicatorByID[this.currIndicatorID]?.parentID || this.newIndicatorParentID,
            sort: this.ajaxIndicatorByID[this.currIndicatorID]?.sort || '',
            //checkboxes input
            singleOptionValue: this.ajaxIndicatorByID[this.currIndicatorID]?.format === 'checkbox' ? 
                this.ajaxIndicatorByID[this.currIndicatorID].options : '',
            //multi answer format inputs
            multiOptionValue: ['checkboxes','radio','multiselect','dropdown'].includes(this.ajaxIndicatorByID[this.currIndicatorID]?.format) ? 
                this.ajaxIndicatorByID[this.currIndicatorID].options?.join('\n') : '',
            //used for grid formats
            gridJSON: this.ajaxIndicatorByID[this.currIndicatorID]?.format === 'grid' ? 
                JSON.parse(this.ajaxIndicatorByID[this.currIndicatorID]?.options[0]) : '',
            //the value that gets posted to the format field of the indicators table (formatname + options)
            fullFormatForPost: '',
            archived: false,
            deleted: false,
            codeEditorHtml: '',
            codeEditorHtmlPrint: ''
        }
    },
    inject: [
        'isEditingModal',
        'currIndicatorID',
        'ajaxIndicatorByID',
        'newIndicatorParentID',
        'hasDevConsoleAccess'
    ],
    mounted(){
        console.log('indicator-editing mounted');
        this.codeEditorHtml = this.isEditingModal ? 
            CodeMirror.fromTextArea(document.getElementById("html"), {
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
            }) : '',
        this.codeEditorHtmlPrint = this.isEditingModal ?
            CodeMirror.fromTextArea(document.getElementById("htmlPrint"), {
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
            }) : ''
    },
    computed:{
        isMultiOptionQuestion() {
            return this.multianswerFormats.includes(this.format);
        }
    },
    methods: {
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
        updateAdvancedOptions() {
            this. codeEditorHtml = CodeMirror.fromTextArea(document.getElementById("html"), {
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
        },
        onSave(){
            console.log('clicked indicator-editing save');
            this.getFullFormatForPost();

            if (this.isEditingModal) {
                this.updateAdvancedOptions();
                console.log('updating indicator')
                //TODO: post need to know

                let indicatorEditingUpdates = []
                const nameChanged = this.name !== this.ajaxIndicatorByID[this.currIndicatorID].name;
                const fullFormatChanged = this.fullFormatForPost !== this.ajaxIndicatorByID[this.currIndicatorID].format +
                            "\n" + this.ajaxIndicatorByID[this.currIndicatorID].options;
                const descriptionChanged = this.description !== this.ajaxIndicatorByID[this.currIndicatorID].description;
                const defaultChanged = this.default !== this.ajaxIndicatorByID[this.currIndicatorID].default;
                const requiredChanged = this.required !== this.ajaxIndicatorByID[this.currIndicatorID].required;
                const sensitiveChanged = this.is_sensitive !== this.ajaxIndicatorByID[this.currIndicatorID].is_sensitive;
                const parentIDChanged = this.parentID !== this.ajaxIndicatorByID[this.currIndicatorID].parentID;
                const sortChanged = this.sort !== this.ajaxIndicatorByID[this.currIndicatorID].sort;    
                //const htmlChanged = codeEditorHtml.getValue() !== this.ajaxIndicatorByID[this.currIndicatorID].html;
                //htmlPrintChanged = codeEditorHtmlPrint.getValue() !== this.ajaxIndicatorByID[this.currIndicatorID].htmlPrint; 
                const shouldDelete = this.deleted;
                const shouldArchive = this.archived;
                //push to array for each confirmed change
            } else {
                console.log('new indicator')
                //post need to know
                //post info for new question
                //'../api/formEditor/newIndicator'
            }
            console.log(this.$data);
        },
        radioBehavior(event) {
            console.log(event.target);
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
                    if(properties.type === 'dropdown'){
                        properties.options = gridDropdown($(this).find('textarea').val().replace(/,/g, ""));
                    }
                } else {
                    properties.type = 'textarea';
                }
                gridJSON.push(properties);
            });
            this.gridJSON = gridJSON;
        },
        getFullFormatForPost() {
            switch(this.format){
                case 'grid':
                    this.updateGridJSON();
                    this.fullFormatForPost = this.format + "\n" + JSON.stringify(this.gridJSON);
                    break;
                case 'radio':
                case 'checkboxes':
                case 'multiselect':
                case 'dropdown':
                    this.fullFormatForPost = this.format + "\n" +  this.formatIndicatorMultiAnswer();
                    break;
                case 'checkbox':
                    this.fullFormatForPost = this.format + "\n" +  this.singleOptionValue;
                    break;
                default:
                    this.fullFormatForPost = this.format;
            }
        },
        formatIndicatorMultiAnswer() {
            let optionsToArray = this.multiOptionValue.split('\n');
            optionsToArray = optionsToArray.map(option => option.trim());
            optionsToArray = optionsToArray.map(option => option === 'no' ? 'No' : option);

            let uniqueArray = Array.from(new Set(optionsToArray));
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
            if(this.hasDevConsoleAccess === 1) {
                $('#button_advanced').css('display', 'none');
                $('#advanced').css('height', 'auto');
                $('#advanced').css('visibility', 'visible');
                $('.table').css('border-collapse', 'collapse');
                $('.CodeMirror').css('border', '1px solid black');
            } else {
                alert('Notice: Please go to Admin Panel -> LEAF Programmer to ensure continued access to this area.');
                $('#button_advanced').css('display', 'none');
                $('#advanced').css('visibility', 'hidden');
            }
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
                    <td><input id="sort" v-model="sort" name="sort" type="number" style="width: 40px" /></td>
                </tr>
                <template v-if="isEditingModal">
                <tr>
                    <td>Parent Question ID</td>
                    <td colspan="2"><div id="container_parentID">TEMP</div></td>
                </tr>
                <tr>
                    <td>Archive</td>
                    <td colspan="1">
                        <input id="archived" v-model="archived" name="disable_or_delete" type="checkbox" @change="radioBehavior"/>
                    </td>
                    <td style="width: 275px;">
                        <span id="archived-warning" style="color: red; visibility: hidden;">
                        This field will be archived.  It can be<br/>re-enabled by using <a href="?a=disabled_fields" target="_blank">Restore Fields</a>.</span>
                    </td>
                </tr>
                <tr>
                    <td>Delete</td>
                    <td colspan="1">
                        <input id="deleted" v-model="deleted" name="disable_or_delete" type="checkbox" @change="radioBehavior" />
                    </td>
                    <td style="width: 275px;">
                        <span id="deletion-warning" style="color: red; visibility: hidden;">Deleted items can only be re-enabled<br/>within 30 days by using <a href="?a=disabled_fields" target="_blank">Restore Fields</a>.</span>
                    </td>
                </tr>
                </template>
            </table>
        </fieldset>
        <template v-if="isEditingModal">
            <span id="button_advanced" class="buttonNorm" tabindex="0" @click="advancedOptionsClick">Advanced Options</span>
            <div>
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
                        <button id="btn_codeSave_html" class="buttonNorm" title="Save Code">
                            <img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" />
                            Save Code<span id="codeSaveStatus_html"></span>
                        </button>
                    </div>
                    <textarea id="html"></textarea><br />
                    <div style="display:flex; justify-content: space-between;">
                        htmlPrint (for pages where the user can only read data): 
                        <button id="btn_codeSave_htmlPrint" class="buttonNorm" title="Save Code">
                            <img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" />
                            Save Code<span id="codeSaveStatus_htmlPrint"></span>
                        </button>
                    </div>
                    <textarea id="htmlPrint"></textarea>
                </fieldset>
            </div>
        </template>
    </div>`
};