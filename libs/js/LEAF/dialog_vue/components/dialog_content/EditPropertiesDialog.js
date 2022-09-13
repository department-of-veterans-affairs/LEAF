export default {
    data() {
        return {
            initialFocusElID: 'name',
            categoryName: this.currentCategorySelection.categoryName,
            categoryDescription: this.currentCategorySelection.categoryDescription,
            workflowID: parseInt(this.currentCategorySelection.workflowID),
            description: this.currentCategorySelection.description || '',
            needToKnow: parseInt(this.currentCategorySelection.needToKnow),
            sort: parseInt(this.currentCategorySelection.sort),
            visible: parseInt(this.currentCategorySelection.visible),
            type: this.currentCategorySelection.type,
            formID: this.currSubformID || this.currCategoryID
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'currCategoryID',
        'currSubformID',
        'truncateText',
        'ajaxWorkflowRecords',
        'currentCategorySelection',
        'currentCategoryIsSensitive',
        'updateCategoriesProperty',
        'closeFormDialog'
	],
    computed: {
        isSubform() {
            return this.currentCategorySelection.parentID !== '';
        }
    },
    mounted() {
        document.getElementById(this.initialFocusElID).focus();
    },
    methods: {
        updateWorkflowDescription() {
            const currWorkflow = this.ajaxWorkflowRecords.find(rec => parseInt(rec.workflowID) === this.workflowID);
            this.description = currWorkflow?.description || '';
        },
        onSave(){
            console.log('clicked edit properties save');
            let  editPropertyUpdates = [];
            const nameChanged = this.categoryName !== this.currentCategorySelection.categoryName;
            const descriptionChanged  = this.categoryDescription !== this.currentCategorySelection.categoryDescription;
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
                                this.updateCategoriesProperty(this.formID, 'description', this.description);
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
                    console.log('promise all:', editPropertyUpdates);
                    this.closeFormDialog();
                });
        }
    },
    template: `<table id="edit-properties-modal">
        <tr> <!--'b', 'i', 'u', 'ol', 'ul', 'li', 'br', 'p', 'table', 'td', 'tr', 'thead', 'tbody', 'span', 'strong', 'em', 'colgroup', 'col'-->
            <td>Name</td>
            <td>
                <input id="name" type="text" maxlength="50" v-model="categoryName" />
            </td>
        </tr>
        <tr>
            <td>Description</td>
            <td>
                <textarea id="description" maxlength="255" v-model="categoryDescription">
                </textarea>
            </td>
        </tr>
        <template v-if="!isSubform">
            <tr>
                <td>Workflow</td>
                <td id="container_workflowID">
                    <select v-if="ajaxWorkflowRecords.length > 0" 
                        id="workflowID" name="select-workflow" 
                        title="select workflow"
                        v-model.number="workflowID"
                        @change="updateWorkflowDescription">
                        <option value="0" :selected="workflowID===0">No Workflow</option>
                        <template v-for="r in ajaxWorkflowRecords">
                            <option v-if="parseInt(r.workflowID) > 0"
                                :value="r.workflowID"
                                :selected="workflowID===parseInt(r.workflowID)">
                                ID#{{r.workflowID}}: {{truncateText(r.description)}}
                            </option>
                        </template>
                    </select>
                    <span v-else style="color: red">A workflow must be set up first</span>
                </td>
            </tr>
            <tr>
                <td>
                    <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" 
                    title="When turned on, the people associated with the workflow are the only ones who have access to view the form.  Forced on if form contains sensitive information." />
                    Need to Know mode  
                </td>
                <td>
                    <select id="needToKnow" title="Need To Know" v-model.number="needToKnow" :style="{width: currentCategoryIsSensitive ? '100%' : 'auto'}">
                        <option v-if="!currentCategoryIsSensitive" value="0" :selected="needToKnow===0">Off</option>
                        <option value="1" :selected="currentCategoryIsSensitive===true || needToKnow===1">
                        {{currentCategoryIsSensitive ? 'Forced on because sensitive fields are present' : 'On'}}
                        </option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" 
                    title="When hidden, users will not be able to select this form as an option." />
                    Availability 
                </td>
                <td>
                    <select id="availability" title="Select Availability" v-model.number="visible">
                        <option value="1" :selected="visible===1">Available</option>
                        <option value="0" :selected="visible===0">Hidden</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Sort Priority</td>
                <td><input id="sort" type="number" v-model.number="sort" style="width: 50px;"/></td>
            </tr>
            <tr>
                <td>
                    <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" 
                    title="Change type of form" />
                    Type  
                </td>
                <td>
                    <select id="formType" title="Change type of form" v-model="type" >
                        <option value="" :selected="type===''">Standard</option>
                        <option value="parallel_processing" :selected="type==='parallel_processing'">Parallel Processing</option>
                    </select>
                </td>
            </tr>
        </template>
    </table>`
}