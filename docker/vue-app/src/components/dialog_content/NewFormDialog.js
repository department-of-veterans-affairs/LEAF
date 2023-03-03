export default {
    name: 'new-form-dialog',
    data() {
        return {
            categoryName: '',
            categoryDescription: ''
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'focusedFormRecord',
        'addNewCategory',
        'selectNewCategory',
        'closeFormDialog'
	],
    mounted() {
        document.getElementById('name').focus();
    },
    computed: {
        nameCharsRemaining(){
            return Math.max(50 - this.categoryName.length, 0);
        },
        descrCharsRemaining(){
            return Math.max(255 - this.categoryDescription.length, 0);
        },
        newFormParentID() {
            //if the focused form does not have a parent, it's a main form - the new form should have that as its parent
            return this.focusedFormRecord?.parentID === '' ? this.focusedFormRecord.categoryID : '';
        }
    },
    methods: {
        onSave() {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/new`,
                data: {
                    name: this.categoryName,
                    description: this.categoryDescription,
                    parentID: this.newFormParentID,
                    CSRFToken: this.CSRFToken
                },
                success: (res)=> {
                    let newCatID = res;
                    let temp = {};
                    //specified values
                    temp.categoryID = newCatID;
                    temp.categoryName = this.categoryName;
                    temp.categoryDescription = this.categoryDescription;
                    temp.parentID = this.newFormParentID;
                    //default values
                    temp.workflowID = 0;
                    temp.needToKnow = 0;
                    temp.visible = 1;
                    temp.sort = 0;
                    temp.type = '';
                    temp.stapledFormIDs = [];
                    this.addNewCategory(newCatID, temp);
                    if(!this.focusedFormRecord?.categoryID) {
                        this.$router.push({name: 'category', query: { formID: newCatID }});
                    }
                    this.closeFormDialog();
                },
                error: err => {
                    console.log('error posting new form', err);
                    reject(err);
                }
            });
        }
    },
    template: `<div>
            <div style="display: flex; justify-content: space-between; padding: 0.25em 0">
                <div><b>Form Name</b><span style="font-size:80%"> (up to 50 characters)</span></div>
                <div>{{nameCharsRemaining}}</div>
            </div>
            <input id="name" type="text" maxlength="50" v-model="categoryName" style="width: 100%;" />
            <div style="display: flex; justify-content: space-between; padding: 0.25em 0; margin-top: 1em;">
                <div><b>Form Description</b><span style="font-size:80%"> (up to 255 characters)</span></div>
                <div>{{descrCharsRemaining}}</div>
            </div>
            <textarea id="description" maxlength="255" v-model="categoryDescription" 
                style="width: 100%; height: 90px;">
            </textarea>
        </div>`
};