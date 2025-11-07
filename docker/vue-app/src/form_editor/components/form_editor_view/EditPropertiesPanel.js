export default {
    name: 'edit-properties-panel',
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

            workflowsLoading: true,
            workflowRecords: []
        }
    },
    created() {
        this.getWorkflowRecords();
    },
    mounted() {
        if(this.focusedFormIsSensitive && +this.needToKnow === 0) {
            this.updateNeedToKnow(true);
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'appIsLoadingForm',
        'allStapledFormCatIDs',
        'focusedFormRecord',
        'focusedFormIsSensitive',
        'updateCategoriesProperty',
        'openEditCollaboratorsDialog',
        'openFormHistoryDialog',
        'showLastUpdate',
        'truncateText',
        'decodeAndStripHTML',
        'getWorkflowIndicators',
        'openBasicConfirmDialog',
	],
    computed: {
        loading() {
            return this.appIsLoadingForm || this.workflowsLoading;
        },
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
            return this.allStapledFormCatIDs?.[this.formID] > 0;
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
        showNeedToKnowWarning() {
            return this.needToKnow === 0;
        },
    },
    methods: {
        /**
         * @returns {array} of objects with all fields from the workflows table
         */
        getWorkflowRecords() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}workflow`,
                success: (res) => {
                    this.workflowRecords = res || [];
                    this.workflowsLoading = false;
                },
                error: (err) => console.log(err)
            });
        },
        updateName() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formName`,
                data: {
                    name: XSSHelpers.stripAllTags(this.categoryName),
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {  //except for WF and desctuctionAge, these give back an empty array
                    this.updateCategoriesProperty(this.formID, 'categoryName', this.categoryName);
                    this.showLastUpdate('form_properties_last_update');
                },
                error: err =>  console.log('name post err', err)
            })
        },
        updateDescription() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formDescription`,
                data: {
                    description:  XSSHelpers.stripAllTags(this.categoryDescription),
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {
                    this.updateCategoriesProperty(this.formID, 'categoryDescription', this.categoryDescription);
                    this.showLastUpdate('form_properties_last_update');
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
                    if (+res === 0) { //1 on success
                        alert('The workflow could not be set because this form is stapled to another form');
                    } else {
                        this.updateCategoriesProperty(this.formID, 'workflowID', this.workflowID);
                        this.updateCategoriesProperty(this.formID, 'workflowDescription', this.workflowDescription);
                        this.showLastUpdate('form_properties_last_update');
                        this.getWorkflowIndicators();
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
                    this.showLastUpdate('form_properties_last_update');
                },
                error: err => console.log('visibility post err', err)
            })
        },
        updateNeedToKnow(forceOn = false) {
            // if newValue is off then popup basic

            const newValue = forceOn === true ? 1 : this.needToKnow;
            if(newValue === 0) {
                this.needToKnow = 1;
                this.openBasicConfirmDialog('<div class="entry_warning bg-yellow-5"><span role="img">⚠️</span><span>All submitted data on this form will be visible to everyone.<br><br>Do you want to proceed?</span></div>', '<h2>You are about to turn off "Need to Know"</h2>', 'Yes', 'No', () => {
                    this.postNeedToKnow(newValue);
                });
            } else {
                this.postNeedToKnow(newValue);
            }
        },
        postNeedToKnow(value) {
            fetch(`${this.APIroot}formEditor/formNeedToKnow`, {
                method: 'POST',
                body: new URLSearchParams({
                    needToKnow: value,
                    categoryID: this.formID,
                    CSRFToken: this.CSRFToken
                })
            })
            .then(response => {
                return response.json(); // or response.text() if not expecting JSON
            })
            .then(() => {
                this.updateCategoriesProperty(this.formID, 'needToKnow', value);
                this.needToKnow = value;
                this.showLastUpdate('form_properties_last_update');
            })
            .catch(err => console.log('ntk post err', err));
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
                    this.showLastUpdate('form_properties_last_update');
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
                        if (+res?.status?.code === 2 && +res.data === +this.destructionAgeYears * 365) { //+null will become 0
                            const newVal = res?.data > 0 ? +res.data : null;
                            this.updateCategoriesProperty(this.formID, 'destructionAge', newVal);
                            this.showLastUpdate('form_properties_last_update');

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
                <span :aria-label="'max length 50 characters, ' + formNameCharsRemaining + ' remaining'">({{formNameCharsRemaining}})</span>
            </label>
            <input id="categoryName" type="text" maxlength="50" v-model="categoryName" @change="updateName"/>

            <label for="categoryDescription">Form description
                <span :aria-label="'max length 255 characters, ' + formDescrCharsRemaining + ' remaining'">({{formDescrCharsRemaining}})</span>
            </label>
            <textarea id="categoryDescription" maxlength="255" v-model="categoryDescription" rows="3" @change="updateDescription"></textarea>
        </div>
        <div v-if="!loading" id="edit-properties-other-properties">
            <div style="display:flex; justify-content: space-between;">
                <button type="button" id="form_properties_last_update" @click.prevent="openFormHistoryDialog(focusedFormRecord.categoryID)"
                    style="display: none;">
                </button>
            </div>
            <template v-if="!isSubForm">
                <div class="panel-properties">
                    <div id="workflow_info" v-if="!isStaple && workflowRecords.length > 0">
                        <label for="workflowID">Workflow:
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
                                        ID#{{r.workflowID}}: {{truncateText(decodeAndStripHTML(r.description),32)}}
                                    </option>
                                </template>
                            </select>
                        </label>
                        <a v-if="+focusedFormRecord.workflowID > 0" id="view_workflow" class="btn-general" :href="'./?a=workflow&workflowID='+ focusedFormRecord.workflowID" target="_blank">
                            View Workflow
                        </a>
                    </div>
                    <div v-if="!workflowsLoading && workflowRecords.length === 0" style="color: #a00; width: 100%; margin-bottom: 0.5rem;">A workflow must be set up first</div>

                    <label for="availability" title="When hidden, users will not be able to select this form">Status:
                        <select id="availability" title="Select Availability" v-model.number="visible" @change="updateAvailability">
                            <option value="1" :selected="visible === 1">Available</option>
                            <option value="0" :selected="visible === 0">Hidden</option>
                            <option value="-1" :selected="visible === -1">Unpublished</option>
                        </select>
                    </label>
                    <div v-if="focusedFormIsSensitive && isNeedToKnow" style="display:flex; color: #a00;">
                        <div style="display:flex; align-items: center;"><b>Need to know: </b></div> &nbsp;
                        <div style="display:flex; align-items: center;">Forced On because sensitive fields are present</div>
                    </div>
                    <label v-else for="needToKnow"
                        title="When turned on, the people associated with the workflow are the only ones who have access to view the form. \nForced on if the form contains sensitive information.">Need to know:
                        <select id="needToKnow" v-model.number="needToKnow" :style="{color: isNeedToKnow ? '#a00' : 'black'}" @change="updateNeedToKnow">
                            <option value="0" :selected="!isNeedToKnow">Off</option>
                            <option value="1" style="color: #a00;" :selected="isNeedToKnow">On</option>
                        </select>
                    </label>
                    <label for="formType">Form Type:
                        <select id="formType" title="Change type of form" v-model="type" @change="updateType">
                            <option value="" :selected="type === ''">Standard</option>
                            <option value="parallel_processing" :selected="type === 'parallel_processing'">Parallel Processing</option>
                        </select>
                    </label>
                    <div v-if="showNeedToKnowWarning" class="entry_info bg-blue-5v" style="margin-top: 0.5rem; margin-bottom: 0.5rem;">
                        <span role="img" aria-hidden="true" alt="">ℹ️</span>
                        <span>'Need to Know' is off. Users can see all submitted data on this form.</span>
                    </div>
                    <div v-if="false" style="display:flex; align-items: center; column-gap: 1rem;">
                        <label for="destructionAgeYears" title="Resolved requests that have reached this expiration date will be destroyed" >Record Destruction Age
                            <select id="destructionAgeYears" v-model="destructionAgeYears"
                                title="resolved request destruction age in years"
                                @change="updateDestructionAge">
                                <option :value="null" :selected="destructionAgeYears===null">never</option>
                                <option v-for="i in 30" :value="i">{{i}} year{{ i === 1 ? "" : "s"}}</option>
                            </select>
                        </label>
                    </div>
                </div>
            </template>
            <div v-else style="margin-top: auto;">This is an Internal Form</div>
        </div>
    </div>`
}