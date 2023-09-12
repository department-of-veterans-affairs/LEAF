export default {
    data() {
        return {
            categoryName: this.decodeAndStripHTML(this.focusedFormRecord?.categoryName || 'Untitled'),
            categoryDescription: this.decodeAndStripHTML(this.focusedFormRecord?.categoryDescription || ''),
            workflowID: parseInt(this.focusedFormRecord?.workflowID) || 0,
            needToKnow: parseInt(this.focusedFormRecord?.needToKnow) || 0,
            visible: parseInt(this.focusedFormRecord?.visible) || 0,
            type: this.focusedFormRecord?.type || '',
            formID: this.focusedFormRecord?.categoryID || '',
            formParentID: this.focusedFormRecord?.parentID || '',
            destructionAgeYears: this.focusedFormRecord?.destructionAge > 0 ?  this.focusedFormRecord?.destructionAge / 365 : null,
            lastUpdated: ''
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'workflowRecords',
        'allStapledFormCatIDs',
        'focusedFormRecord',
        'focusedFormIsSensitive',
        'updateCategoriesProperty',
        'openEditCollaboratorsDialog',
        'openFormHistoryDialog',
        'showLastUpdate',
        'truncateText',
        'decodeAndStripHTML',
	],
    computed: {
        workflowDescription() {
            let returnValue = '';
            if (this.workflowID !== 0) {
                const currWorkflow = this.workflowRecords.find(rec => parseInt(rec.workflowID) === this.workflowID);
                returnValue = currWorkflow?.description || '';
            }
            return returnValue;
        },
        isSubForm() {
            return this.focusedFormRecord.parentID !== '';
        },
        isStaple() {
            return this.allStapledFormCatIDs.includes(this.formID);
        },
        isNeedToKnow(){
            return parseInt(this.focusedFormRecord.needToKnow) === 1;
        },
        formNameCharsRemaining() {
            return 50 - this.categoryName.length;
        },
        formDescrCharsRemaining() {
            return 255 - this.categoryDescription.length;
        },
    },
    methods: {
        updateName() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formName`,
                data: {
                    name: this.categoryName,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {  //except for WF and desctuctionAge, these give back an empty array
                    this.updateCategoriesProperty(this.formID, 'categoryName', this.categoryName);
                    this.lastUpdated = new Date().toLocaleString();
                    this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                },
                error: err =>  console.log('name post err', err)
            })
        },
        updateDescription() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formDescription`,
                data: {
                    description: this.categoryDescription,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {
                    this.updateCategoriesProperty(this.formID, 'categoryDescription', this.categoryDescription);
                    this.lastUpdated = new Date().toLocaleString();
                    this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                },
                error: err => console.log('form description post err', err)
            })
        },
        updateWorkflow() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formWorkflow`,
                data: {
                    workflowID: this.workflowID,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: (res) => {
                    if (res === false) { //1 on success
                        alert('The workflow could not be set because this form is stapled to another form');
                    } else {
                        this.updateCategoriesProperty(this.formID, 'workflowID', this.workflowID);
                        this.updateCategoriesProperty(this.formID, 'workflowDescription', this.workflowDescription);
                        this.lastUpdated = new Date().toLocaleString();
                        this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                    }
                },
                error: err => console.log('workflow post err', err)
            })
        },
        updateAvailability() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formVisible`,
                data: {
                    visible: this.visible,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {
                    this.updateCategoriesProperty(this.formID, 'visible', this.visible);
                    this.lastUpdated = new Date().toLocaleString();
                    this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                },
                error: err => console.log('visibility post err', err)
            })
        },
        updateNeedToKnow() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formNeedToKnow`,
                data: {
                    needToKnow: this.needToKnow,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {
                    this.updateCategoriesProperty(this.formID, 'needToKnow', this.needToKnow);
                    this.lastUpdated = new Date().toLocaleString();
                    this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                },
                error: err => console.log('ntk post err', err)
            })
        },
        updateType() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formType`,
                data: {
                    type: this.type,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {
                    this.updateCategoriesProperty(this.formID, 'type', this.type);
                    this.lastUpdated = new Date().toLocaleString();
                    this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                },
                error: err => console.log('type post err', err)
            })
        },
        updateDestructionAge() {
            if(this.destructionAgeYears === null || (this.destructionAgeYears >= 1 && this.destructionAgeYears <= 30)) {
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formEditor/destructionAge`,
                    data: {
                        destructionAge: this.destructionAgeYears,
                        categoryID: this.formID,
                        CSRFToken: this.CSRFToken
                    },
                    success: (res) => {
                        if (+res === +this.destructionAgeYears * 365) {
                            this.updateCategoriesProperty(this.formID, 'destructionAge', +res);
                            this.lastUpdated = new Date().toLocaleString();
                            this.showLastUpdate('form_properties_last_update', `last modified: ${this.lastUpdated}`);
                        }
                    },
                    error: err => console.log('destruction age post err', err)
                })
            }
        },
    },
    template: `<div id="edit-properties-panel">
        <span class="form-id">{{formID}}
            <span v-if="formParentID">(internal for {{formParentID}})</span>
        </span>
        <div id="edit-properties-description">
            <label for="categoryName">Form name
                <span style="margin-left:auto; font-size:80%; align-self:flex-end;">({{formNameCharsRemaining}})</span>
            </label>
            <input id="categoryName" type="text" maxlength="50" v-model="categoryName" style="margin-bottom: 1rem;" @change="updateName"/>
            
            <label for="categoryDescription">Form description
                <span style="margin-left:auto; font-size:80%; align-self:flex-end;">({{formDescrCharsRemaining}})</span>
            </label>
            <textarea id="categoryDescription" maxlength="255" v-model="categoryDescription" rows="3" @change="updateDescription"></textarea>
        </div>
        <div id="edit-properties-other-properties">
            <div style="display:flex; justify-content: space-between;">
                <button type="button" id="editFormPermissions" class="btn-general"
                    style="width: fit-content;"
                    @click="openEditCollaboratorsDialog">
                    Edit Special Write Access
                </button>
                <button type="button" id="form_properties_last_update" @click.prevent="openFormHistoryDialog"
                    :style="{display: lastUpdated==='' ? 'none' : 'flex'}">
                </button>
            </div>
            <template v-if="!isSubForm">
                <div class="panel-properties">
                    <template v-if="!isStaple && workflowRecords.length > 0">
                        <label for="workflowID">Workflow
                        <select id="workflowID" name="select-workflow" @change="updateWorkflow"
                            title="select workflow"
                            v-model.number="workflowID"
                            style="width:280px;"
                            :style="{color: workflowID === 0 ? '#a00' : 'black'}"
                            :disabled="isStaple">
                            <option value="0" :selected="workflowID === 0">
                                No Workflow.  Users cannot submit requests
                            </option>
                            <template v-for="r in workflowRecords" :key="'workflow_' + r.workflowID">
                                <option v-if="parseInt(r.workflowID) > 0"
                                    :value="r.workflowID"
                                    :selected="workflowID === parseInt(r.workflowID)">
                                    ID#{{r.workflowID}}: {{truncateText(r.description,32)}}
                                </option>
                            </template>
                        </select></label>
                    </template>
                    <div v-if="workflowRecords.length === 0" style="color: #a00; width: 100%; margin-bottom: 0.5rem;">A workflow must be set up first</div>

                    <label for="availability" title="When hidden, users will not be able to select this form">Availability
                        <select id="availability" title="Select Availability" v-model.number="visible" @change="updateAvailability">
                            <option value="1" :selected="visible === 1">Available</option>
                            <option value="0" :selected="visible === 0">Hidden</option>
                        </select>
                    </label>
                    <label for="formType">Form Type
                        <select id="formType" title="Change type of form" v-model="type" @change="updateType">
                            <option value="" :selected="type === ''">Standard</option>
                            <option value="parallel_processing" :selected="type === 'parallel_processing'">Parallel Processing</option>
                        </select>
                    </label>
                    <div style="display:flex; align-items: center; column-gap: 1rem;">
                        <label for="destructionAgeYears" title="Resolved requests that have reached this expiration date will be destroyed" >Record Destruction Age (Years)
                            <select id="destructionAgeYears" v-model="destructionAgeYears"
                                title="resolved request destruction age in years" 
                                @change="updateDestructionAge">
                                <option :value="null" :selected="destructionAgeYears===null">never</option>
                                <option v-for="i in 30" :value="i">{{i}}</option>
                            </select>
                        </label>
                    </div>
                    <div v-if="focusedFormIsSensitive" style="display:flex; color: #a00;">
                        <div style="display:flex; align-items: center;"><b>Need to know: {{isNeedToKnow ? 'on' : 'off'}}</b></div> &nbsp;
                        <div style="display:flex; align-items: center; font-size:90%;">(forced on because sensitive fields are present)</div>
                    </div>
                    <label v-else for="needToKnow"
                        title="When turned on, the people associated with the workflow are the only ones who have access to view the form. \nForced on if the form contains sensitive information.">Need to know
                        <select id="needToKnow" v-model.number="needToKnow" :style="{color: isNeedToKnow ? '#a00' : 'black'}" @change="updateNeedToKnow">
                            <option value="0" :selected="!isNeedToKnow">Off</option>
                            <option value="1" style="color: #a00;" :selected="isNeedToKnow">On</option>
                        </select>
                    </label>
                </div>
            </template>
            <div v-else style="margin-top: auto;">This is an Internal Form</div>
        </div>
    </div>`
}