import GridCell from "../GridCell";

export default {
    data() {
        return {
            initialFocusElID: 'name',
            showShortLabel: false,
            shortLabelTrigger: 50,
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
        'truncateText'
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
        if (this.isEditingModal === true) {
            this.getFormParentIDs().then(res => {
                this.listForParentIDs = res;
                this.isLoadingParentIDs = false;
            });
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
        descrCharsRemaining(){
            return Math.max(50 - this.description.length, 0)
        }
    },
    methods: {
        toggleShortlabel() {
            console.log(this.showShortLabel)
            this.showShortLabel = !this.showShortLabel;
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
        preventSelectionIfFormatNone(event) {
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
        onSave(){
            console.log('clicked indicator-editing save');
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
                            success: () => console.log('name success'),
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
                            success: () => console.log('description success'),
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
                            success: () => {},
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
                            success: () => {},
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
                            success: () => {},
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
                            success: () => {},
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
                            success: () => {},
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
                            success: () => {},
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
                            success: () => {},
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
                            success: () => {},
                            error: err => console.log('ind sort post err', err)
                        })
                    );
                }

            } else {  /* CALLS FOR CREATING A NEW QUESTION */
                console.log('creating a new indicator on form ', this.formID);
                const nonSectionSelector = `#drop_area_parent_${this.parentID} > li`;
                //set default sort to last question in current depth
                const sortVal = (this.parentID===null) ?
                    this.ajaxFormByCategoryID.length :                                 //new sections/pages
                    Array.from(document.querySelectorAll(nonSectionSelector)).length   //new questions in existing sections
                
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
                            sort: sortVal,
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {},
                        error: err => console.log('error posting new question', err)
                    })
                );
            }

            Promise.all(indicatorEditingUpdates).then((res)=> {
                console.log('promise all:', indicatorEditingUpdates, res);
                this.closeFormDialog();
                if (res.length > 0) {
                    vueData.updateIndicatorList = true;  //NOTE: flags IFTHEN app for updates
                    const subnodeIndID = (this.archived===true || this.deleted===true) && 
                            this.currIndicatorID === this.selectedNodeIndicatorID ? null : this.selectedNodeIndicatorID
                    this.selectNewCategory(this.formID, this.currSubformID !== null, subnodeIndID);
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
        appAddCell(){
            console.log('app added cell');
            this.gridJSON.push({});
        },
        gridDropdown(dropDownOptions){ //TODO: edit
            if(dropDownOptions == null || dropDownOptions.length === 0){
                return dropDownOptions;
            }
            let uniqueNames = dropDownOptions.split("\n");
            let returnArray = [];
            uniqueNames = uniqueNames.filter(function(elem, index, self) {
                return index == self.indexOf(elem);
            });
        
            $.each(uniqueNames, function(i, el){
                if(el === "no") {
                    uniqueNames[i] = "No";
                }
                returnArray.push(uniqueNames[i]);
            });
        
            return returnArray;
        },
        updateGridJSON() {  //FIX: TODO: rework
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
                if(properties.type !== undefined && properties.type !==null){
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
            optionsToArray = optionsToArray.map(option => option === 'no' ? 'No' : option); //this checks specifically for lower case values
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
                    @click="rawNameEditorClick" style="display: none;">
                    Show formatted code
                </button>
                <button class="btn-general" id="advNameEditor"
                    title="use advanced text editor"
                    @click="advNameEditorClick">
                    Advanced Formatting
                </button>
                <button v-if="name.length <= shortLabelTrigger" 
                    class="btn-general" 
                    style="margin-left: auto;"
                    title="access short label field"
                    @click="toggleShortlabel">
                    {{showShortLabel ? 'Hide' : 'Show'}} Short Label
                </button>
            </div>
        </div>
        <div id="non-name-wrapper">
            <div v-if="name.length > shortLabelTrigger || showShortLabel===true">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <label for="description">What would you call this field in a spreadsheet?</label>
                    <div>{{descrCharsRemaining}}</div>
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
                            title="select for assistance with format selection">
                            Help me Choose
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
                    <span style="position: absolute; color: transparent" aria-atomic="true" aria-live="polite" id="tableStatus" role="status"></span>
                    <br/>
                    <button class="buttonNorm" id="addColumnBtn" title="Add column" alt="Add column" aria-label="grid input add column" @click="appAddCell">
                        <img src="../../libs/dynicons/?img=list-add.svg&w=16" style="height: 25px;"/>
                        Add column
                    </button>
                    <br/><br/>
                    Columns:
                    <div style="overflow-x: scroll;">
                        <grid-cell v-if="gridJSON.length===0" :column="1" :cell="new Object()" key="initial_cell"></grid-cell>
                        <grid-cell v-for="(c,i) in gridJSON" :column="i+1" :cell="c" :key="c.id"></grid-cell>
                    </div>
                </div>
                <div style="margin-top:0.5rem;">
                    <label for="defaultValue">Default Answer</label><br/>
                    <textarea id="defaultValue" v-model="defaultValue"></textarea> 
                </div>
            </div>
            <fieldset id="indicator-editing-attributes">
                <legend style="font-family:'PublicSans-Bold';">Attributes</legend>
                <div class="attribute-row">
                    <div style="display: flex; align-items: center; margin-right: 1.25rem;">
                        <label class="checkable leaf_check" for="required">
                            <input type="checkbox" id="required" v-model="required" name="required" class="icheck leaf_check"  
                                @change="preventSelectionIfFormatNone" />
                            <span class="leaf_check"></span>Required
                        </label>
                    </div>
                    <div style="display: flex; align-items: center; margin-right: 1.25rem;">
                        <label class="checkable leaf_check" for="sensitive">
                            <input type="checkbox" id="sensitive" v-model="is_sensitive" name="sensitive" class="icheck leaf_check"  
                                @change="preventSelectionIfFormatNone" />
                            <span class="leaf_check"></span>Sensitive Data (PHI/PII)
                        </label>
                    </div>
                    <div v-if="!isEditingModal" style="display: flex; align-items: center;">
                        <input id="sort" v-model.number="sort" name="sort" type="number" style="width: 50px; padding: 0; margin-right:3px" />
                        <label for="sort">Sort Priority</label> 
                    </div>
                    <div v-if="isEditingModal" style="margin-right: 1.25rem;">
                        <label class="checkable leaf_check" for="archived">
                            <input type="checkbox" id="archived" name="disable_or_delete" class="icheck leaf_check"  
                                v-model="archived" @change="radioBehavior" />
                            <span class="leaf_check"></span>Archive
                        </label>
                    </div>
                    <div v-if="isEditingModal">
                        <label class="checkable leaf_check" for="deleted">
                            <input type="checkbox" id="deleted" name="disable_or_delete" class="icheck leaf_check"  
                                v-model="deleted" @change="radioBehavior" />
                            <span class="leaf_check"></span>Delete
                        </label>
                    </div>
                </div>
                <template v-if="isEditingModal">
                    <div class="attribute-row" style="margin-bottom: 0.5rem;">
                        <div v-if="isLoadingParentIDs===false" style="display: flex; align-items: center; margin-right: 1.25rem;">
                            <select v-model.number="parentID" id="container_parentID" style="width:230px; margin-right: 3px">
                                <option :value="null" :selected="parentID===null">None</option> 
                            <template v-for="kv in Object.entries(listForParentIDs)">
                                <option v-if="currIndicatorID !== parseInt(kv[0])" 
                                    :value="kv[0]" 
                                    :key="'parent'+kv[0]">
                                    {{kv[0]}}: {{truncateText(kv[1]['1'].name)}}
                                </option>
                            </template>
                            </select>
                            <label for="container_parentID">Parent Question ID</label>
                        </div>
                        <div style="display: flex; align-items: center;">
                            <input id="sort" v-model.number="sort" name="sort" type="number" style="width: 50px; padding: 0; margin-right:3px" />
                            <label for="sort">Sort Priority</label> 
                        </div>
                    </div>
                </template>
            </fieldset>
            <span v-show="archived" id="archived-warning">
                This field will be archived.  It can be re-enabled by using Restore Fields.
            </span>
            <span v-show="deleted" id="deletion-warning">
                Deleted items can only be re-enabled within 30 days by using Restore Fields.
            </span>
        </div>
    </div>`
};