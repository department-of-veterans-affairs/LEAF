import GridCell from "../GridCell";

export default {
    data() {
        return {
            initialFocusElID: 'name',
            showShortLabel: false,
            shortLabelTrigger: 50,
            showAdditionalOptions: false,
            showDetailedFormatInfo: false,
            formID: this.currSubformID || this.currCategoryID,
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
            options: this.ajaxIndicatorByID[this.currIndicatorID]?.options || [],//options property, if present, is arr of options
            format: this.ajaxIndicatorByID[this.currIndicatorID]?.format || '',  //format property here is just the format name
            description: this.ajaxIndicatorByID[this.currIndicatorID]?.description || '',
            defaultValue: this.ajaxIndicatorByID[this.currIndicatorID]?.default || '',
            required: parseInt(this.ajaxIndicatorByID[this.currIndicatorID]?.required)===1 || false,
            is_sensitive: parseInt(this.ajaxIndicatorByID[this.currIndicatorID]?.is_sensitive)===1 || false,
            parentID: this.ajaxIndicatorByID[this.currIndicatorID]?.parentID ? 
                    parseInt(this.ajaxIndicatorByID[this.currIndicatorID].parentID) : this.newIndicatorParentID,
            //sort can be 0, need to compare specifically against undefined
            sort: this.ajaxIndicatorByID[this.currIndicatorID]?.sort !== undefined ? parseInt(this.ajaxIndicatorByID[this.currIndicatorID].sort) : null,
            //checkboxes input
            singleOptionValue: this.ajaxIndicatorByID[this.currIndicatorID]?.format === 'checkbox' ? 
                this.ajaxIndicatorByID[this.currIndicatorID].options : '',
            //multi answer format inputs
            multiOptionValue: ['checkboxes','radio','multiselect','dropdown'].includes(this.ajaxIndicatorByID[this.currIndicatorID]?.format) ? 
                this.ajaxIndicatorByID[this.currIndicatorID].options?.join('\n') : '',
            //used for grid formats
            gridBodyElement: 'div#container_indicatorGrid > div',
            gridJSON: this.ajaxIndicatorByID[this.currIndicatorID]?.format === 'grid' ? 
               JSON.parse(this.ajaxIndicatorByID[this.currIndicatorID]?.options[0]) : [],

            archived: false,
            deleted: false
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'isEditingModal',
        'closeFormDialog',
        'currCategoryID',
        'currSubformID',
        'currIndicatorID',
        'ajaxIndicatorByID',
        'ajaxFormByCategoryID',
        'selectedNodeIndicatorID',
        'selectNewCategory',
        'updateCategoriesProperty',
        'newIndicatorParentID',
        'truncateText',
        'toggleIndicatorCountSwitch'
    ],
    provide() {
        return {
            gridJSON: Vue.computed(() => this.gridJSON),
            updateGridJSON: this.updateGridJSON
        }
    },
    components: {
        GridCell
    },
    mounted() {
        console.log('Indicator Editing mounted for', this.currIndicatorID, 'on form', this.formID);
        if (this.isEditingModal === true) {
            this.getFormParentIDs().then(res => {
                this.listForParentIDs = res;
                this.isLoadingParentIDs = false;
            });
        }
        if(this.sort===null){
            this.sort = this.newQuestionSortValue;
        }
        if(XSSHelpers.containsTags(this.name, ['<b>','<i>','<u>','<ol>','<li>','<br>','<p>','<td>'])) {
            $('#advNameEditor').click();
            document.querySelector('.trumbowyg-editor').focus();
        } else {
            document.getElementById(this.initialFocusElID).focus();
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
        shortlabelCharsRemaining(){
            return 50 - this.description.length;
        },
        /**
         * used to set the default sort value of a new question to last index in current depth
         * @returns {number} 
         */
        newQuestionSortValue(){
            const nonSectionSelector = `#drop_area_parent_${this.parentID} > li`;
            const sortVal = (this.parentID===null) ?
                this.ajaxFormByCategoryID.length :                                 //new form sections/pages
                Array.from(document.querySelectorAll(nonSectionSelector)).length   //new questions in existing sections
            return sortVal;
        }
    },
    methods: {
        toggleSelection(event, dataPropertyName = 'showShortLabel') {
            if(typeof this[dataPropertyName] === 'boolean') {
                this[dataPropertyName] = !this[dataPropertyName];
            }
        },
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
                const shouldArchive = this.archived === true;
                const shouldDelete = this.deleted === true;
                console.log('CHANGES?: name,descr,fullFormat,default,required,sensitive,sort,parentID,archive,delete');
                console.log(nameChanged,descriptionChanged,fullFormatChanged,defaultChanged,requiredChanged,sensitiveChanged,sortChanged,parentIDChanged,shouldArchive,shouldDelete);

                if(nameChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/name`,
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
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/description`,
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
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/format`,
                            data: {
                                format: this.fullFormatForPost,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind format post err', err)
                        })
                    );
                }
                if(defaultChanged) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/default`,
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
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/required`,
                            data: {
                                required: this.required ? 1 : 0,
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
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/sensitive`,
                            data: {
                                is_sensitive: this.is_sensitive ? 1 : 0,
                                CSRFToken: this.CSRFToken
                            },
                            error: err =>  console.log('ind is_sensitive post err', err)
                        })
                    );
                }
                if (sensitiveChanged && +this.is_sensitive === 1) {
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
                                this.updateCategoriesProperty(this.formID, 'needToKnow', 1);
                            },
                            error: err => console.log('set form need to know post err', err)
                        })
                    );
                }
                if(shouldArchive) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/disabled`,
                            data: {
                                disabled: 1,  //can't undelete from there so this should be fine
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind disabled (archive) post err', err)
                        })
                    );
                }
                if(shouldDelete) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/disabled`,
                            data: {
                                disabled: 2,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind disabled (deletion) post err', err)
                        })
                    );
                }
                if(parentIDChanged && this.parentID !== this.currIndicatorID) {
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/parentID`,
                            data: {
                                parentID: this.parentID,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind parentID post err', err)
                        })
                    );
                }
                if(sortChanged) { //NOTE: sort is also handled with drag drop in index, might rm here
                    indicatorEditingUpdates.push(
                        $.ajax({
                            type: 'POST',
                            url: `${this.APIroot}formEditor/${this.currIndicatorID}/sort`,
                            data: {
                                sort: this.sort,
                                CSRFToken: this.CSRFToken
                            },
                            error: err => console.log('ind sort post err', err)
                        })
                    );
                }

            } else {  /* CALLS FOR CREATING A NEW QUESTION */
                console.log('creating a new indicator on form ', this.formID);
                
                if (+this.is_sensitive === 1) {
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
                                this.updateCategoriesProperty(this.formID, 'needToKnow', 1);
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
                        success: () => {},
                        error: err => console.log('error posting new question', err)
                    })
                );
            }

            Promise.all(indicatorEditingUpdates).then((res)=> {
                
                if (res.length > 0) {
                    vueData.updateIndicatorList = true;  //NOTE: flags IFTHEN app for updates
                    const subnodeIndID = (this.archived===true || this.deleted===true) && 
                            this.currIndicatorID === this.selectedNodeIndicatorID ? null: this.selectedNodeIndicatorID
                        
                    if (this.archived === true || this.deleted === true) {
                        this.toggleIndicatorCountSwitch();
                    }
                    this.selectNewCategory(this.formID, this.currSubformID !== null, subnodeIndID);
                }
                this.closeFormDialog();
            });

        },
        radioBehavior(event = {}) {
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
        appAddCell(){
            this.gridJSON.push({});
        },
        /**
         * 
         * @param {string} dropDownOptions from grid dropdown question textarea
         * @returns {array} of unique options with possible 'no' values updated to 'No'
         */
        gridDropdown(dropDownOptions = '') {
            let returnValue = []
            if (dropDownOptions !== null && dropDownOptions.length !== 0) {
                let uniqueOptions = dropDownOptions.split("\n");
                uniqueOptions = uniqueOptions.map(option => option.trim());
                uniqueOptions = uniqueOptions.map(option => option === 'no' ? 'No' : option);
                returnValue = Array.from(new Set(uniqueOptions));
            }
            return returnValue;
        },
        updateGridJSON() {  // TODO: try to rework wo jQuery
            let gridJSON = [];
            let t = this;
            //gather column names and column types. if type is dropdown, adds property.options
            $(this.gridBodyElement).find('div.cell').each(function() {
                let properties = new Object();
                if($(this).children('input:eq(0)').val() === 'undefined'){
                    properties.name = 'No title';
                } else {
                    properties.name = $(this).children('input:eq(0)').val();
                }
                properties.id = $(this).attr('id');
                properties.type = $(this).find('select').val();
                if(properties.type !== undefined && properties.type !== null){
                    if(properties.type.toLowerCase() === 'dropdown') {
                        properties.options = t.gridDropdown($(this).find('textarea').val().replace(/,/g, ""));
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
    template: `<div id="indicator-editing-dialog-content">
        <div>
            <label for="name">Field Name</label>
            <textarea id="name" v-model="name" rows="4">{{name}}</textarea>
            <div style="display:flex; justify-content: space-between; font-size: 80%;">
                <button class="btn-general" id="rawNameEditor"
                    title="use basic text editor"
                    @click="rawNameEditorClick" style="display: none; width:135px">
                    Show formatted code
                </button>
                <button class="btn-general" id="advNameEditor"
                    title="use advanced text editor" style="width:135px"
                    @click="advNameEditorClick">
                    Advanced Formatting
                </button>
                <button v-if="name.length <= shortLabelTrigger && description===''" 
                    class="btn-general" 
                    style="margin-left: auto; width:135px"
                    title="access short label field"
                    @click="toggleSelection($event, 'showShortLabel')">
                    {{showShortLabel ? 'Hide' : 'Use'}} Short Label
                </button>
            </div>
        </div>
        <div v-if="description!=='' || name.length > shortLabelTrigger || showShortLabel===true">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <label for="description">What would you call this field in a spreadsheet?</label>
                <div>{{shortlabelCharsRemaining}}</div>
            </div>
            <input type="text" id="description" v-model="description" maxlength="50" />
        </div>
        <div>
            <div>
                <label for="indicatorType">Input Format</label><br/>
                <div style="display:flex;">
                    <select id="indicatorType" title="Select a Format" v-model="format" @change="preventSelectionIfFormatNone">
                        <option value="">None</option>
                        <option v-for="kv in Object.entries(formats)" 
                        :value="kv[0]" :selected="kv[0]===format" :key="kv[0]">{{ kv[1] }}</option>
                    </select>
                    <button id="editing-format-assist" class="btn-general"
                        title="select for assistance with format choices">
                        ℹ
                    </button>
                </div>
            </div>
            <div v-if="format==='checkbox'" id="container_indicatorSingleAnswer" style="margin-top:0.5rem;">
                <label for="indicatorSingleAnswer">Text for checkbox:</label><br/> 
                <input type="text" id="indicatorSingleAnswer" v-model="singleOptionValue"/>
            </div>
            <div v-if="isMultiOptionQuestion" id="container_indicatorMultiAnswer" style="margin-top:0.5rem;">
                <label for="indicatorMultiAnswer">One option per line:</label><br/>
                <textarea id="indicatorMultiAnswer" v-model="multiOptionValue" style="height: 130px;">
                </textarea>
            </div>
            <div v-if="format==='grid'" id="container_indicatorGrid">
                <span id="tableStatus" style="position: absolute; color: transparent" 
                    aria-atomic="true" aria-live="polite"  role="status"></span>
                <br/>
                <button class="buttonNorm" id="addColumnBtn" title="Add column" alt="Add column" aria-label="grid input add column" 
                    @click="appAddCell">
                    ➕ Add column
                </button>
                <br/><br/>
                Columns ({{gridJSON.length}}):
                <div style="overflow-x: scroll;" id="gridcell_col_parent">
                    <grid-cell v-if="gridJSON.length===0" :column="1" :cell="new Object()" key="initial_cell"></grid-cell>
                    <grid-cell v-for="(c,i) in gridJSON" :column="i+1" :cell="c" :key="c.id"></grid-cell>
                </div>
            </div>
            <div v-show="format!=='' && format!=='raw_data'" style="margin-top:0.75rem;">
                <label for="defaultValue">Default Answer</label><br/>
                <textarea id="defaultValue" v-model="defaultValue"></textarea> 
            </div>
        </div>
        <fieldset id="indicator-editing-attributes">
            <legend style="font-family:'PublicSans-Bold';">Attributes</legend>
            <div class="attribute-row">
                <label class="checkable leaf_check" for="required" style="margin-right: 1.25rem;">
                    <input type="checkbox" id="required" v-model="required" name="required" class="icheck leaf_check"  
                        @change="preventSelectionIfFormatNone" />
                    <span class="leaf_check"></span>Required
                </label>
                <label class="checkable leaf_check" for="sensitive" style="margin-right: 2rem;">
                    <input type="checkbox" id="sensitive" v-model="is_sensitive" name="sensitive" class="icheck leaf_check"  
                        @change="preventSelectionIfFormatNone" />
                    <span class="leaf_check"></span>Sensitive Data (PHI/PII)
                </label>
                <template v-if="!isEditingModal">
                    <label for="sort">
                        <input id="sort" v-model.number="sort" name="sort" type="number" style="width: 50px; padding: 0 2px; margin-right:3px" />Sort Priority
                    </label>
                </template>
                <template v-if="isEditingModal">
                    <label class="checkable leaf_check" for="archived" style="margin-right: 1.25rem; margin-left: 1.5rem;">
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
            <button v-if="isEditingModal" 
                class="btn-general" 
                style="width:155px; font-size: 80%;"
                title="edit additional options"
                @click="toggleSelection($event, 'showAdditionalOptions')">
                {{showAdditionalOptions ? 'Hide' : 'Show'}} Additional Options
            </button>
            <template v-if="isEditingModal && showAdditionalOptions">
                <div class="attribute-row" style="margin-top: 1rem;">
                    <template v-if="isLoadingParentIDs===false">
                        <label for="container_parentID" style="margin-right: 1.25rem;">
                            <select v-model.number="parentID" id="container_parentID" style="width:200px; margin-right: 3px">
                                <option :value="null" :selected="parentID===null">None</option> 
                                <template v-for="kv in Object.entries(listForParentIDs)">
                                    <option v-if="currIndicatorID !== parseInt(kv[0])" 
                                        :value="kv[0]" 
                                        :key="'parent'+kv[0]">
                                        {{kv[0]}}: {{truncateText(kv[1]['1'].name)}}
                                    </option>
                                </template>
                            </select>Parent Question ID
                        </label>
                    </template>
                    <label for="sort">
                        <input id="sort" v-model.number="sort" name="sort" type="number" style="width: 50px; padding: 0 2px; margin-right:3px" />Sort Priority
                    </label>
                </div>
                <div>EDIT PRIVS</div>
            </template>
            <span v-show="archived" id="archived-warning">
                This field will be archived.  It can be re-enabled by using Restore Fields.
            </span>
            <span v-show="deleted" id="deletion-warning">
                Deleted items can only be re-enabled within 30 days by using Restore Fields.
            </span>
        </fieldset>
    </div>`
};