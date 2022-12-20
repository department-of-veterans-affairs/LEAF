export default {
    data() {
        return {
            categoryName: this.stripAndDecodeHTML(this.currentCategorySelection?.categoryName) || 'Untitled',
            categoryDescription: this.stripAndDecodeHTML(this.currentCategorySelection?.categoryDescription) || '',
            workflowID: parseInt(this.currentCategorySelection?.workflowID) || 0,
            needToKnow: parseInt(this.currentCategorySelection?.needToKnow) || 0,
            sort: parseInt(this.currentCategorySelection?.sort) || 0,
            visible: parseInt(this.currentCategorySelection?.visible) || 0,
            type: this.currentCategorySelection?.type || '',
            formID: this.currSubformID || this.currCategoryID
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'currCategoryID',
        'currSubformID',
        'ajaxWorkflowRecords',
        'currentCategorySelection',
        'currentCategoryIsSensitive',
        'updateCategoriesProperty',
        'openEditCollaboratorsDialog',
        'closeFormDialog',
        'truncateText',
        'stripAndDecodeHTML',
	],
    computed: {
        workflowDescription() {
            let returnValue = '';
            if (this.workflowID !== 0) {
                const currWorkflow = this.ajaxWorkflowRecords.find(rec => parseInt(rec.workflowID) === this.workflowID);
                returnValue = currWorkflow?.description || '';
            }
            return returnValue;
        },
        isSubForm(){
            return this.currentCategorySelection.parentID !== '';
        },
        isNeedToKnow(){
            return parseInt(this.needToKnow) === 1;
        },
        changesPending() {
            const nameChanged = this.stripAndDecodeHTML(this.categoryName) !== this.stripAndDecodeHTML(this.currentCategorySelection.categoryName);
            const descriptionChanged  = this.stripAndDecodeHTML(this.categoryDescription) !== this.stripAndDecodeHTML(this.currentCategorySelection.categoryDescription);
            const workflowChanged  = this.workflowID !== parseInt(this.currentCategorySelection.workflowID);
            const needToKnowChanged = this.needToKnow !== parseInt(this.currentCategorySelection.needToKnow);
            const sortChanged = this.sort !== parseInt(this.currentCategorySelection.sort);
            const visibleChanged = this.visible !== parseInt(this.currentCategorySelection.visible);
            const typeChanged = this.type !== this.currentCategorySelection.type;
            const changes = [
                nameChanged, descriptionChanged, workflowChanged, needToKnowChanged, sortChanged, visibleChanged, typeChanged
            ];
            console.log('form panel changes', changes)
            return changes.some(c => c === true);
        },
        formNameCharsRemaining() {
            return 50 - this.categoryName.length;
        },
        formDescrCharsRemaining() {
            return 255 - this.categoryDescription.length;
        }
    },
    methods: {
        onSave(){
            let  editPropertyUpdates = [];
            const nameChanged = this.stripAndDecodeHTML(this.categoryName) !== this.stripAndDecodeHTML(this.currentCategorySelection.categoryName);
            const descriptionChanged  = this.stripAndDecodeHTML(this.categoryDescription) !== this.stripAndDecodeHTML(this.currentCategorySelection.categoryDescription);
            const workflowChanged  = this.workflowID !== parseInt(this.currentCategorySelection.workflowID);
            const needToKnowChanged = this.needToKnow !== parseInt(this.currentCategorySelection.needToKnow);
            const sortChanged = this.sort !== parseInt(this.currentCategorySelection.sort);
            const visibleChanged = this.visible !== parseInt(this.currentCategorySelection.visible);
            const typeChanged = this.type !== this.currentCategorySelection.type;

            if(nameChanged) {
                editPropertyUpdates.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formName`,
                        data: {
                            name: this.categoryName,
                            categoryID: this.formID,
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {  //NOTE:  except for WF, these give back an empty array
                            this.updateCategoriesProperty(this.formID, 'categoryName', this.categoryName);
                        },
                        error: err =>  console.log('name post err', err)
                    })
                );
            }
            if(descriptionChanged) {
                editPropertyUpdates.push(
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
                        },
                        error: err => console.log('form description post err', err)
                    })
                );
            }
            if(workflowChanged) {
                editPropertyUpdates.push(
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
                                this.updateCategoriesProperty(this.formID, 'description', this.workflowDescription);
                            }
                        },
                        error: err => console.log('workflow post err', err)
                    })
                );
            }
            if(needToKnowChanged){
                editPropertyUpdates.push(
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
                        },
                        error: err => console.log('ntk post err', err)
                    })
                );
            }
            if(sortChanged){
                editPropertyUpdates.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formSort`,
                        data: {
                            sort: this.sort,
                            categoryID: this.formID,
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {
                            this.updateCategoriesProperty(this.formID, 'sort', this.sort);
                        },
                        error: err => console.log('sort post err', err)
                    })
                );
            }
            if(visibleChanged){
                editPropertyUpdates.push(
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
                        },
                        error: err => console.log('visibility post err', err)
                    })
                );
            }
            if(typeChanged){
                editPropertyUpdates.push(
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
                        },
                        error: err => console.log('type post err', err)
                    })
                );
            }
            Promise.all(editPropertyUpdates)
                .then(()=> {
                    //console.log('promise all:', editPropertyUpdates);
                    this.closeFormDialog();
                });
        }
    },
    template: `<div id="edit-properties-panel">
        <span class="form-id">ID: {{currCategoryID}}
            <span v-if="currSubformID!==null">(subform {{currSubformID}})</span>
        </span>
        <div id="edit-properties-description">
            <label for="categoryName">Form name
                <span style="margin-left:auto; font-size:80%; align-self:flex-end;">({{formNameCharsRemaining}})</span>
            </label>
            <input id="categoryName" type="text" maxlength="50" v-model="categoryName" style="margin-bottom: 1rem;"/>
            
            <label for="categoryDescription">Form description
                <span style="margin-left:auto; font-size:80%; align-self:flex-end;">({{formDescrCharsRemaining}})</span>
            </label>
            <textarea id="categoryDescription" maxlength="255" v-model="categoryDescription" rows="3"></textarea>
        </div>
        <div id="edit-properties-other-properties">
            <div style="display:flex; justify-content: space-between;">
                <button id="editFormPermissions" class="btn-general"
                    style="width: fit-content;"
                    @click="openEditCollaboratorsDialog">
                    Edit Special Write Access
                </button>
                <button v-if="changesPending" class="btn-general" title="Apply form property updates" @click="onSave">Apply updates</button>
            </div>
            <template v-if="!isSubForm">
                <div class="panel-properties">
                    <template v-if="ajaxWorkflowRecords.length > 0">
                        <label for="workflowID" style="margin-bottom: 0.5rem;">Workflow
                        <select id="workflowID" name="select-workflow" 
                            title="select workflow"
                            v-model.number="workflowID"
                            style="width:300px;"
                            :style="{color: workflowID===0 ? '#cb0000' : 'black'}">
                            <option value="0" :selected="workflowID===0">No Workflow.  Users cannot submit requests</option>
                            <template v-for="r in ajaxWorkflowRecords" :key="'workflow_' + r.workflowID">
                                <option v-if="parseInt(r.workflowID) > 0"
                                    :value="r.workflowID"
                                    :selected="workflowID===parseInt(r.workflowID)">
                                    ID#{{r.workflowID}}: {{truncateText(r.description,35)}}
                                </option>
                            </template>
                        </select></label>
                    </template>
                    <div v-else style="color: #cb0000; width: 100%; margin-bottom: 0.5rem;">A workflow must be set up first</div>

                    <div v-if="currentCategoryIsSensitive" style="color: #cb0000; margin-bottom: 0.5rem;">
                        <b>Need to know: {{isNeedToKnow ? 'on' : 'off'}}</b> &nbsp;(forced on because sensitive fields are present)
                    </div>
                    <label v-else for="needToKnow" style="margin-bottom: 0.5rem;"
                        title="When turned on, the people associated with the workflow are the only ones who have access to view the form. \nForced on if the form contains sensitive information.">Need to know
                        <select id="needToKnow" v-model.number="needToKnow" :style="{color: isNeedToKnow ? '#cb0000' : 'black'}">
                            <option value="0" :selected="!isNeedToKnow">Off</option>
                            <option value="1" style="color: #cb0000;" :selected="isNeedToKnow">On</option>
                        </select>
                    </label>

                    <div style="display: flex; flex-wrap: wrap; row-gap: 0.5rem;">
                        <label for="availability" title="When hidden, users will not be able to select this form as an option">Availability
                            <select id="availability" title="Select Availability" v-model.number="visible">
                                <option value="1" :selected="visible===1">Available</option>
                                <option value="0" :selected="visible===0">Hidden</option>
                            </select>
                        </label>

                        <label for="categorySort" title="-128 to 127">Sort
                            <input id="categorySort" type="number" v-model.number="sort" min="-128" max="127" style="width:60px;"/>
                        </label>

                        <label for="formType">Form Type
                        <select id="formType" title="Change type of form" v-model="type" >
                            <option value="" :selected="type===''">Standard</option>
                            <option value="parallel_processing" :selected="type==='parallel_processing'">Parallel Processing</option>
                        </select></label>
                    </div>
                </div>
            </template>
            <div v-else style="margin-top: auto;">This is an Internal Form</div>
        </div>
    </div>`
}