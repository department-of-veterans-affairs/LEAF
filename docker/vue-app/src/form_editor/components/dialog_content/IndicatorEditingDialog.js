import { computed } from 'vue';

import GridCell from "../GridCell";
import IndicatorPrivileges from "../IndicatorPrivileges";

export default {
    name: 'indicator-editing-dialog',
    data() {
        return {
            requiredDataProperties: ['indicator','indicatorID','parentID'],
            initialFocusElID: 'name',
            showAdditionalOptions: false,
            showDetailedFormatInfo: false,
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
            formatInfo: {
                text: `A single input for short text entries.`,
                textarea: `A large area for multiple lines of text and limited text formatting options.`,
                grid: `A table format with rows and columns.  Additional rows can be added, removed, or moved during data entry.`,
                number: `A single input used to store numeric data.  Useful for information that will be used for calculations.`,
                currency: `A single input used to store currency values in dollars to two decimal places.`,
                date: `Embeds a datepicker.`,
                radio: `Radio buttons allow a single selection from multiple options.  All of the question\'s options will display.`,
                checkbox: `A single checkbox is typically used for confirmation. The checkbox label text can be further customized.`,
                checkboxes: `Checkboxes will allow the selection of multiple options.  All of the question\'s options will display.`,
                multiselect: `Multi-Select format will allow the selection of several options from a selection box with a dropdown.  Only selected items will display.`,
                dropdown: `A dropdown menu will allow one selection from multiple options.  Only the selected option will display.`,
                fileupload: `File Attachment`,
                image: `Similar to file upload, but only image format files will be shown during selection`,
                orgchart_group: `Orgchart Group format is used to select a specific LEAF User Access Group`,
                orgchart_position: `Orgchart Position format is used to select a specific LEAF user by their position in the orgchart`,
                orgchart_employee: `Orgchart Employee format is used to select a specific LEAF user from the orgchart`,
                raw_data: `Raw Data is associated with Advanced Options, which can be used by programmers to run custom code during form data entry or review`,
            },
            listForParentIDs: [],
            isLoadingParentIDs: true,
            multianswerFormats: ['checkboxes','radio','multiselect','dropdown'],

            name: this.decodeHTMLEntities(this.dialogData?.indicator?.name || ''),
            options: this.dialogData?.indicator?.options || [],//array of choices for radio, dropdown, etc.  1 ele w JSON for grids
            format: this.dialogData?.indicator?.format || '',  //base format (eg 'radio')
            description: this.dialogData?.indicator?.description || '',
            defaultValue: this.decodeAndStripHTML(this.dialogData?.indicator?.default || ''),
            required: parseInt(this.dialogData?.indicator?.required) === 1 || false,
            is_sensitive: parseInt(this.dialogData?.indicator?.is_sensitive) === 1 || false,
            parentID: this.dialogData?.parentID || null,
            //used here for new questions.  compared against undefined since it can be 0
            sort: this.dialogData?.indicator?.sort !== undefined ? parseInt(this.dialogData?.indicator.sort) : null,

            //checkboxes input
            singleOptionValue: this.dialogData?.indicator?.format === 'checkbox' ? 
                this.dialogData?.indicator.options : '',
            //list of options
            multiOptionValue: ['checkboxes','radio','multiselect','dropdown'].includes(this.dialogData?.indicator?.format) ?
                (this.dialogData?.indicator.options || []).join('\n') : '',

            //used for grid formats
            gridJSON: this.dialogData?.indicator?.format === 'grid' ? JSON.parse(this.dialogData?.indicator?.options[0]) : [],

            archived: false,
            deleted: false
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'dialogData',
        'checkRequiredData',
        'setDialogSaveFunction',
        'advancedMode',
        'initializeOrgSelector',
        'closeFormDialog',
        'showLastUpdate',
        'focusedFormRecord',
        'focusedFormTree',
        'getFormByCategoryID',
        'truncateText',
        'decodeAndStripHTML',
        'orgchartFormats'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
        this.checkRequiredData(this.requiredDataProperties);
    },
    provide() {
        return {
            gridJSON: computed(() => this.gridJSON),
            updateGridJSON: this.updateGridJSON
        }
    },
    components: {
        GridCell,
        IndicatorPrivileges
    },
    mounted() {
        if (this.isEditingModal === true) {
            this.getFormParentIDs().then(res => {
                this.listForParentIDs = res;
                this.isLoadingParentIDs = false;
            }).catch(err => console.log('an error has occurred', err));
        }
        if(this.sort === null){
            this.sort = this.newQuestionSortValue;
        }
        if(this.containsRichText(this.name)) {
            document.getElementById('advNameEditor').click();
            document.querySelector('.trumbowyg-editor').focus();
        } else {
            document.getElementById(this.initialFocusElID).focus();
        }
        if (this.orgchartFormats.includes(this.format)) {
            const selType = this.format.slice(this.format.indexOf('_') + 1);
            this.initializeOrgSelector(
                selType, this.indicatorID, 'modal_', this.defaultValue, this.setOrgSelDefaultValue
            );
            const elInput = document.querySelector(`#modal_orgSel_${this.indicatorID} input`);
            if(elInput !== null) { //needed to remove orgselector default value
                elInput.addEventListener('change', (event) => {
                    if (event.target.value.trim() === '') {
                        this.defaultValue = '';
                    }
                });
            }
        }
    },
    computed: {
        isEditingModal() {
            return +this.indicatorID > 0;
        },
        indicatorID() {
            return this.dialogData?.indicatorID || null;
        },
        formID() {
            return this.focusedFormRecord?.categoryID || '';
        },
        nameLabelText() {
            return this.parentID === null ? 'Section Heading' : 'Field Name';
        },
        showFormatSelect() {
            //not a header, or in advanced mode, or the format of the header is already a format other than none
            return this.parentID !== null || this.advancedMode === true || this.format !== ''
        },
        shortLabelTriggered() {
            return this.name.trim().split(' ').length > 2 || this.containsRichText(this.name);
        },
        formatBtnText() {
            return this.showDetailedFormatInfo ? "Hide Details" : "What's this?";
        },
        isMultiOptionQuestion() {
            return this.multianswerFormats.includes(this.format);
        },
        fullFormatForPost() {
            let fullFormat = this.format;
            switch(this.format.toLowerCase()){
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
        shortlabelCharsRemaining() {
            return 50 - this.description.length;
        },
        /**
         * used to set the default sort value of a new question to last index in current depth
         * @returns {number} 
         */
        newQuestionSortValue() {
            const offset = 128;
            const nonSectionSelector = `#drop_area_parent_${this.parentID} > li`;
            const sortVal = (this.parentID === null) ?
                this.focusedFormTree.length - offset:                                       //new form sections/pages
                Array.from(document.querySelectorAll(nonSectionSelector)).length - offset   //new questions in existing sections
            return sortVal;
        }
    },
    methods: {
        containsRichText(txt) {
            return XSSHelpers.containsTags(txt, ['<b>','<i>','<u>','<ol>','<li>','<br>','<p>','<td>','<h1>','<h2>','<h3>','<h4>','<a>','<blockquote>']);
        },
        decodeHTMLEntities(txt) {
            let tmp = document.createElement("textarea");
            tmp.innerHTML = txt;
            return tmp.value;
        },
        setOrgSelDefaultValue(orgSelector = {}) {
            if(orgSelector.selection !== undefined) {
                this.defaultValue = orgSelector.selection.toString();
            }
        },
        toggleSelection(event, dataPropertyName = 'showDetailedFormatInfo') {
            if(typeof this[dataPropertyName] === 'boolean') {
                this[dataPropertyName] = !this[dataPropertyName];
            }
        },
        getFormParentIDs() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}/form/_${this.formID}/flat`,
                    success: (res)=> {
                        for (let i in res) {
                            res[i]['1'].name = XSSHelpers.stripAllTags(res[i]['1'].name);
                        }
                        resolve(res);
                    },
                    error: (err)=> reject(err)
                });
            });
        },
        preventSelectionIfFormatNone() {
            if (this.format === '' && (this.required === true || this.is_sensitive === true)) {
                this.required = false;
                this.is_sensitive = false;
                alert(`You can't mark a field as sensitive or required if the Input Format is "None".`);
            }
        },
        onSave(){
            //check for advanced text formatting for name field
            const elTrumbow = document.querySelector('.trumbowyg-editor');
            if(elTrumbow !== undefined && elTrumbow !== null){
                this.name = elTrumbow.innerHTML;
            }
            
            let indicatorEditingUpdates = [];
            if (this.isEditingModal) { /* CALLS FOR EDITTING AN EXISTING QUESTION */
                const nameChanged = this.name !== this.dialogData?.indicator.name;
                const descriptionChanged = this.description !== this.dialogData?.indicator.description;

                const options = this.dialogData?.indicator?.options ? 
                                '\n' + this.dialogData?.indicator?.options?.join('\n') : '';
                const fullFormatChanged = this.fullFormatForPost !== this.dialogData?.indicator.format + options;

                const defaultChanged = this.decodeAndStripHTML(this.defaultValue) !== this.decodeAndStripHTML(this.dialogData?.indicator.default);
                const requiredChanged = +this.required !== parseInt(this.dialogData?.indicator.required);
                const sensitiveChanged = +this.is_sensitive !== parseInt(this.dialogData?.indicator.is_sensitive);
                const parentIDChanged = this.parentID !== this.dialogData?.indicator.parentID;
                const shouldArchive = this.archived === true;
                const shouldDelete = this.deleted === true;
                //keeping for now for potential debugging
                //console.log('CHANGES?: name,descr,fullFormat,default,required,sensitive,parentID,archive,delete');
                //console.log(nameChanged,descriptionChanged,fullFormatChanged,defaultChanged,requiredChanged,sensitiveChanged,parentIDChanged,shouldArchive,shouldDelete);

                if(nameChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/name`,
                            data: {
                                name: this.name,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind name post err', err)
                        })
                    );
                }
                if(descriptionChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/description`,
                            data: {
                                description: this.description,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind desciption post err', err)
                        })
                    );
                }
                if(fullFormatChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/format`,
                            data: {
                                format: this.fullFormatForPost,
                                CSRFToken: this.CSRFToken
                            },
                            success: function(res) {
                                if (res === 'size limit exceeded') {
                                    alert(`The input format was not saved because it was too long.\nIf you require extended length, please submit a YourIT ticket.`);
                                }
                            },
                            error: err => console.log('ind format post err', err)
                        })
                    );
                }
                if(defaultChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/default`,
                            data: {
                                default: this.defaultValue,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind default value post err', err)
                        })
                    );
                }
                if(requiredChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/required`,
                            data: {
                                required: this.required ? 1: 0,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind required post err', err)
                        })
                    );
                }
                if(sensitiveChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/sensitive`,
                            data: {
                                is_sensitive: this.is_sensitive ? 1 : 0,
                                CSRFToken: this.CSRFToken
                            },
                            error: err =>  console.log('ind is_sensitive post err', err)
                        })
                    );
                }
                if (sensitiveChanged && this.is_sensitive === true && +this.focusedFormRecord.needToKnow !== 1) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/formNeedToKnow`,
                            data: {
                                needToKnow: 1,
                                categoryID: this.formID,
                                CSRFToken: this.CSRFToken
                            },
                            success: () => {
                                let panelEl = document.querySelector('select#needToKnow');
                                if(panelEl !== null) {
                                    panelEl.value = 1;
                                    panelEl.dispatchEvent(new Event("change"));
                                }
                            },
                            error: err => console.log('set form need to know post err', err)
                        })
                    );
                }
                if(shouldArchive) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/disabled`,
                            data: {
                                disabled: 1,
                                CSRFToken: this.CSRFToken
                            },
                            success: () => {},
                            error: err => console.log('ind disabled (archive) post err', err)
                        })
                    );
                }
                if(shouldDelete) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/disabled`,
                            data: {
                                disabled: 2,
                                CSRFToken: this.CSRFToken
                            },
                            success: () => {},
                            error: err => console.log('ind disabled (deletion) post err', err)
                        })
                    );
                }
                if(parentIDChanged && this.parentID !== this.indicatorID) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.indicatorID}/parentID`,
                            data: {
                                parentID: this.parentID,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind parentID post err', err)
                        })
                    );
                }

            } else {  /* CALLS FOR CREATING A NEW QUESTION */
                if (this.is_sensitive && +this.focusedFormRecord.needToKnow !== 1) {
                    //if the form is not already marked need to know, update this too
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/formNeedToKnow`,
                            data: {
                                needToKnow: 1,
                                categoryID: this.formID,
                                CSRFToken: this.CSRFToken
                            },
                            success: () => {
                                let panelEl = document.querySelector('select#needToKnow');
                                if(panelEl !== null) {
                                    panelEl.value = 1;
                                    panelEl.dispatchEvent(new Event("change"));
                                }
                            },
                            error: err => console.log('set form need to know post err', err)
                        })
                    );
                }
                indicatorEditingUpdates.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/newIndicator`,
                        data: {
                            name: this.name,
                            format: this.fullFormatForPost,
                            description: this.description,
                            default: this.defaultValue,
                            parentID: this.parentID,
                            categoryID: this.formID,
                            required: this.required ? 1 : 0,
                            is_sensitive: this.is_sensitive ? 1 : 0,
                            sort: this.newQuestionSortValue,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {},
                        error: err => console.log('error posting new question', err)
                    })
                );
            }

            Promise.all(indicatorEditingUpdates).then((res)=> {
                if (res.length > 0) {
                    this.getFormByCategoryID(this.formID);
                    this.showLastUpdate('form_properties_last_update');
                }
                this.closeFormDialog();
            }).catch(err => console.log('an error has occurred', err));

        },
        radioBehavior(event = {}) {
            const targetId = event?.target.id;
            if (targetId.toLowerCase() === 'archived' && this.deleted) {
                document.getElementById('deleted').checked = false
                this.deleted = false;
            }
            if (targetId.toLowerCase() === 'deleted' && this.archived) {
                document.getElementById('archived').checked = false
                this.archived = false;
            }
        },
        appAddCell(){
            this.gridJSON.push({});
        },
        /**
         * @param {string} dropDownOptions from the value of grid cell dropdown type textarea
         * @returns {array} of unique options with commas rm and possible 'no' values updated to 'No'
         */
        formatGridDropdown(dropDownOptions = '') {
            let returnValue = []
            if (dropDownOptions !== null && dropDownOptions.length !== 0) {
                let uniqueOptions = dropDownOptions.replaceAll(/,/g, "").split("\n");
                uniqueOptions = uniqueOptions.map(option => option.trim());
                uniqueOptions = uniqueOptions.map(option => option === 'no' ? 'No' : option);
                returnValue = Array.from(new Set(uniqueOptions));
            }
            return returnValue;
        },
        updateGridJSON() {
            let gridJSON = [];
            const gridParent = document.getElementById('gridcell_col_parent');
            const gridCells = Array.from(gridParent.querySelectorAll('div.cell'));
            gridCells.forEach(cell => {
                const id = cell.id;
                const type = (document.getElementById('gridcell_type_' + id)?.value || '').toLowerCase();
                let properties = new Object();
                properties.id = id;
                properties.name = document.getElementById('gridcell_title_' + id)?.value || 'No Title';
                properties.type = type;
                if(type === 'dropdown') {
                    const elTextarea = document.getElementById('gridcell_options_' + id);
                    properties.options = this.formatGridDropdown(elTextarea.value || '');
                }
                if(type === 'dropdown_file') {
                    properties.file = document.getElementById('dropdown_file_select_' + id)?.value || '';
                    properties.hasHeader = Boolean(+document.getElementById('dropdown_file_header_select_' + id)?.value);
                }
                gridJSON.push(properties);
            });
            this.gridJSON = gridJSON;
        },
        formatIndicatorMultiAnswer() {
            let optionsToArray = this.multiOptionValue.split('\n');
            optionsToArray = optionsToArray.map(option => option.trim());
            optionsToArray = optionsToArray.map(option => option === 'no' ? 'No' : option); //this checks specifically for lower case no
            const uniqueArray = Array.from(new Set(optionsToArray));
            return uniqueArray.join('\n');
        },
        //jQuery plugins for WYSWYG. from mod_form as is
        advNameEditorClick() {
            $('#advNameEditor').css('display', 'none');
            $('#rawNameEditor').css('display', 'block');
            $('#name').trumbowyg({
                resetCss: true,
                btns: ['formatting', 'bold', 'italic', 'underline', '|',
                    'unorderedList', 'orderedList', '|',
                    'link', '|',
                    'foreColor', '|',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('.trumbowyg-box').css({
                'min-height': '130px',
                'max-width': '700px',
                'margin': '0.5rem 0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '100px',
                'height': '100px',
                'padding': '1rem'
            });
        },
        rawNameEditorClick() {
            $('#advNameEditor').css('display', 'block');
            $('#rawNameEditor').css('display', 'none');
            $('#name').trumbowyg('destroy');
        }
    },
    watch: {
        format(newVal, oldVal) {
            this.defaultValue = '';
            if (this.orgchartFormats.includes(newVal)) {
                const selType = newVal.slice(newVal.indexOf('_') + 1);
                this.initializeOrgSelector(selType, this.indicatorID, 'modal_', '', this.setOrgSelDefaultValue);
                const elInput = document.querySelector(`#modal_orgSel_${this.indicatorID} input`);
                if(elInput !== null) { //needed to remove default value
                    elInput.addEventListener('change', (event) => {
                        if (event.target.value.trim() === '') {
                            this.defaultValue = '';
                        }
                    });
                }
            }
        }
    },
    template: `<div id="indicator-editing-dialog-content">
        <div>
            <label for="name">{{ nameLabelText }}</label>
            <textarea id="name" v-model="name" rows="4">{{name}}</textarea>
            <div style="display:flex; justify-content: space-between;">
                <button type="button" class="btn-general" id="rawNameEditor"
                    title="use basic text editor"
                    @click="rawNameEditorClick" style="display: none; width:135px">
                    Show formatted code
                </button>
                <button type="button" class="btn-general" id="advNameEditor"
                    title="use advanced text editor" style="width:135px"
                    @click="advNameEditorClick">
                    Advanced Formatting
                </button>
            </div>
        </div>
        <div v-show="description !== '' || shortLabelTriggered">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <label for="description">Short label for spreadsheet headings</label>
                <div>{{shortlabelCharsRemaining}}</div>
            </div>
            <input type="text" id="description" v-model="description" maxlength="50" />
        </div>
        <div>
            <div v-if="showFormatSelect">
                <label for="indicatorType">Input Format</label>
                <div style="display:flex;">
                    <select id="indicatorType" title="Select a Format" v-model="format" @change="preventSelectionIfFormatNone">
                        <option value="">None</option>
                        <option v-for="kv in Object.entries(formats)" 
                        :value="kv[0]" :selected="kv[0] === format" :key="kv[0]">{{ kv[1] }}</option>
                    </select>
                    <button type="button" id="editing-format-assist" class="btn-general"
                        @click="toggleSelection($event, 'showDetailedFormatInfo')"
                        title="select for assistance with format choices" style=" align-self:stretch; margin-left: 3px;">
                        {{ formatBtnText }}
                    </button>
                </div>
                <div v-show="showDetailedFormatInfo" id="formatDetails" style="max-width:500px; font-size: 0.9rem; margin-bottom: 1rem;">
                    <p><b>Format Information</b></p>
                    {{ format !== '' ? formatInfo[format] : 'No format.  Indicators without a format are often used to provide additional information for the user.  They are often used for form section headers.' }}
                </div>
            </div>
            <div v-show="format === 'checkbox'" id="container_indicatorSingleAnswer" style="margin-top:0.5rem;">
                <label for="indicatorSingleAnswer">Text for checkbox</label>
                <input type="text" id="indicatorSingleAnswer" v-model="singleOptionValue"/>
            </div>
            <div v-show="isMultiOptionQuestion" id="container_indicatorMultiAnswer" style="margin-top:0.5rem;">
                <label for="indicatorMultiAnswer">Options (One option per line)</label>
                <textarea id="indicatorMultiAnswer" v-model="multiOptionValue" style="height: 130px;">
                </textarea>
            </div>
            <div v-if="format === 'grid'" id="container_indicatorGrid">
                <span id="tableStatus" style="position: absolute; color: transparent" 
                    aria-atomic="true" aria-live="polite"  role="status"></span>
                <br/>
                <div style="display:flex; align-items: center;">
                    <button type="button" class="btn-general" id="addColumnBtn" title="Add column" alt="Add column" aria-label="grid input add column" 
                        @click="appAddCell">
                        + Add column
                    </button>&nbsp;Columns ({{gridJSON.length}}):
                </div>
                <div style="overflow-x: scroll;" id="gridcell_col_parent">
                    <grid-cell v-if="gridJSON.length === 0" :column="1" :cell="new Object()" key="initial_cell"></grid-cell>
                    <grid-cell v-for="(c,i) in gridJSON" :column="i+1" :cell="c" :key="c.id"></grid-cell>
                </div>
            </div>
            <div v-show="format !== '' && format !== 'raw_data'" style="margin-top:0.75rem;">
                <label for="defaultValue">Default Answer</label>
                <div v-show="orgchartFormats.includes(format)"
                    :id="'modal_orgSel_' + indicatorID"
                    style="min-height:30px" aria-labelledby="defaultValue">
                </div>
                <textarea v-show="!orgchartFormats.includes(format)" id="defaultValue" v-model="defaultValue"></textarea>
            </div>
        </div>
        <div v-show="!(!isEditingModal && format === '')" id="indicator-editing-attributes">
            <b>Attributes</b>
            <div class="attribute-row">
                <template v-if="format !== ''">
                    <label class="checkable leaf_check" for="required" style="margin-right: 1.5rem;">
                        <input type="checkbox" id="required" v-model="required" name="required" class="icheck leaf_check"  
                            @change="preventSelectionIfFormatNone" />
                        <span class="leaf_check"></span>Required
                    </label>
                    <label class="checkable leaf_check" for="sensitive" style="margin-right: 4rem;">
                        <input type="checkbox" id="sensitive" v-model="is_sensitive" name="sensitive" class="icheck leaf_check"  
                            @change="preventSelectionIfFormatNone" />
                        <span class="leaf_check"></span>Sensitive Data (PHI/PII)
                    </label>
                </template>
                <template v-if="isEditingModal">
                    <label class="checkable leaf_check" for="archived" style="margin-right: 1.5rem;">
                        <input type="checkbox" id="archived" name="disable_or_delete" class="icheck leaf_check"  
                            v-model="archived" @change="radioBehavior" />
                        <span class="leaf_check"></span>Archive
                    </label>
                    <label class="checkable leaf_check" for="deleted">
                        <input type="checkbox" id="deleted" name="disable_or_delete" class="icheck leaf_check"  
                            v-model="deleted" @change="radioBehavior" />
                        <span class="leaf_check"></span>Delete
                    </label>
                </template>
            </div>
            <button v-if="isEditingModal" type="button"
                class="btn-general" 
                title="edit additional options"
                @click="toggleSelection($event, 'showAdditionalOptions')">
                {{showAdditionalOptions ? 'Hide' : 'Show'}} Advanced Attributes
            </button>
            <template v-if="showAdditionalOptions">
                <div class="attribute-row" style="margin-top: 1rem; justify-content: space-between;">
                    <template v-if="isLoadingParentIDs === false">
                        <label for="container_parentID" style="margin-right: 1rem;">Parent Question ID
                            <select v-model.number="parentID" id="container_parentID" style="width:250px; margin-left:3px;">
                                <option :value="null" :selected="parentID === null">None</option> 
                                <template v-for="kv in Object.entries(listForParentIDs)">
                                    <option v-if="indicatorID !== parseInt(kv[0])" 
                                        :value="kv[0]" 
                                        :key="'parent_'+kv[0]">
                                        {{kv[0]}}: {{truncateText(kv[1]['1'].name), 50}}
                                    </option>
                                </template>
                            </select>
                        </label>
                    </template>
                </div>
                <indicator-privileges :indicatorID="indicatorID"></indicator-privileges>
            </template>
            <span v-show="archived" id="archived-warning">
                This field will be archived. &nbsp;It can be<br/>re-enabled by using Restore Fields.
            </span>
            <span v-show="deleted" id="deletion-warning">
                Deleted items can only be re-enabled<br />within 30 days by using Restore Fields.
            </span>
        </div>
    </div>`
};