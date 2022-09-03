export default {
    data() {
        return {
            categoryName: this.currentCategorySelection.categoryName,
            categoryDescription: this.currentCategorySelection.categoryDescription,
            categoryDescriptionHTML: this.fromEncodeToHTML(this.currentCategorySelection.categoryDescription),
            workflowID: parseInt(this.currentCategorySelection.workflowID),
            description: this.currentCategorySelection.description || '',
            needToKnow: parseInt(this.currentCategorySelection.needToKnow),
            sort: parseInt(this.currentCategorySelection.sort),
            visible: parseInt(this.currentCategorySelection.visible),
            type: this.currentCategorySelection.type
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'fromEncodeToHTML',
        'currCategoryID',
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
    methods: {  //TODO: category descr needs html filter for name display
        updateWorkflowDescription() {
            const currWorkflow = this.ajaxWorkflowRecords.find(rec => parseInt(rec.workflowID) === this.workflowID);
            this.description = currWorkflow?.description || '';
        },
        //called by ref on the component passed to setCustomDialogComponent in the main app
        onSave(){
            console.log('clicked edit properties save');
            console.log(this.categoryDescription, 'selected', this.currentCategorySelection.categoryDescription)
            let  editPropertyUpdates = [];
            const nameChanged = this.categoryName !== this.currentCategorySelection.categoryName;
            const descriptionChanged  = this.categoryDescription !== this.currentCategorySelection.categoryDescription;
            const workflowChanged  = this.workflowID !== this.currentCategorySelection.workflowID;
            const needToKnowChanged = this.needToKnow !== this.currentCategorySelection.needToKnow;
            const sortChanged = this.sort !== this.currentCategorySelection.sort;
            const visibleChanged = this.visible !== this.currentCategorySelection.visible;
            const typeChanged = this.type !== this.currentCategorySelection.type;

            if(nameChanged){
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formName`,
                        data: {
                            name: this.categoryName,
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {  //NOTE:  except for WF, these give back an empty array
                            this.updateCategoriesProperty(this.currCategoryID, 'categoryName', this.categoryName);
                            resolve(res);
                        },
                        error: err => {
                            console.log('name post err', err);
                            reject(err);
                        }
                    })
                }));
            }
            if(descriptionChanged){
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formDescription`,
                        data: {
                            description: this.categoryDescription,    // html is posted, categories needs to be updated with the encoded version
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {
                            //TODO: this is getting the html rather than encoded version.  probably just need to track both.
                            this.updateCategoriesProperty(this.currCategoryID, 'categoryDescription', this.categoryDescription);
                            resolve(res);
                        },
                        error: err => {
                            console.log('form description post err', err);
                            reject(err);
                        }
                    });
                }));
            }
            if(workflowChanged) {
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formWorkflow`,
                        data: {
                            workflowID: this.workflowID,
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {
                            if (res === false) { //1 on success
                                alert('The workflow could not be set because this form is stapled to another form');
                            } else {
                                this.updateCategoriesProperty(this.currCategoryID, 'workflowID', this.workflowID);
                                this.updateCategoriesProperty(this.currCategoryID, 'description', this.description);
                            }
                            resolve(res);
                        },
                        error: err => {
                            console.log('workflow post err', err);
                            reject(err);
                        }
                    });
                }));
            }
            if(needToKnowChanged){
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formNeedToKnow`,
                        data: {
                            needToKnow: this.needToKnow,
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {
                            this.updateCategoriesProperty(this.currCategoryID, 'needToKnow', this.needToKnow);
                            resolve(res);
                        },
                        error: err => {
                            console.log('ntk post err', err);
                            reject(err);
                        }
                    });
                }));
            }
            if(sortChanged){
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formSort`,
                        data: {
                            sort: this.sort,
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {
                            this.updateCategoriesProperty(this.currCategoryID, 'sort', this.sort);
                            resolve(res);
                        },
                        error: err => {
                            console.log('sort post err', err);
                            reject(err);
                        }
                    });
                }));
            }
            if(visibleChanged){
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formVisible`,
                        data: {
                            visible: this.visible,
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {
                            this.updateCategoriesProperty(this.currCategoryID, 'visible', this.visible);
                            resolve(res);
                        },
                        error: err => {
                            console.log('visibility post err', err);
                            reject(err);
                        }
                    });
                }));
            }
            if(typeChanged){
                editPropertyUpdates.push(
                    new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/formType`,
                        data: {
                            type: this.type,
                            categoryID: this.currCategoryID,
                            CSRFToken: this.CSRFToken
                        },
                        success: (res) => {
                            this.updateCategoriesProperty(this.currCategoryID, 'type', this.type);
                            resolve(res);
                        },
                        error: err => {
                            console.log('type post err', err);
                            reject(err);
                        }
                    });
                }));
            }
            Promise.all([editPropertyUpdates])
                .then(()=> {
                    console.log('promise all:', editPropertyUpdates);
                    this.closeFormDialog();
                });
        }
    },
    template: `<table>
        <tr>
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
                            {{r.description}} (ID: #{{r.workflowID}})
                            </option>
                        </template>
                    </select>
                    <span v-else style="color: red">A workflow must be set up first</span>
                </td>
            </tr>
            <tr>
                <td>Need to Know mode 
                    <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" 
                    title="When turned on, the people associated with the workflow are the only ones who have access to view the form.  Forced on if form contains sensitive information." />
                </td>
                <td>
                    <select id="needToKnow" title="Need To Know" v-model.number="needToKnow">
                        <option v-if="!currentCategoryIsSensitive" value="0" :selected="needToKnow===0">Off</option>
                        <option value="1" :selected="currentCategoryIsSensitive===true || needToKnow===1">
                        {{currentCategoryIsSensitive ? 'Forced on because sensitive fields are present' : 'On'}}
                        </option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Availability 
                    <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" 
                    title="When hidden, users will not be able to select this form as an option." />
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
                <td><input id="sort" type="number" v-model.number="sort" /></td>
            </tr>
            <tr>
                <td>Type 
                    <img src="../../libs/dynicons/?img=emblem-notice.svg&w=16" 
                    title="Change type of form" />
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