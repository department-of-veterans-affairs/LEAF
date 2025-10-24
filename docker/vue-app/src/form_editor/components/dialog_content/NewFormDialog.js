export default {
    name: 'new-form-dialog',
    data() {
        return {
            requiredDataProperties: ['parentID'],
            categoryName: '',
            categoryDescription: '',
            newFormParentID: this.dialogData.parentID,
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'decodeAndStripHTML',
        'setDialogSaveFunction',
        'dialogData',
        'checkRequiredData',
        'addNewCategory',
        'closeFormDialog'
	],
    created() {
        this.checkRequiredData(this.requiredDataProperties);
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        document.getElementById('name').focus();
    },
    emits: ['get-form'],
    computed: {
        nameCharsRemaining(){
            return Math.max(50 - this.categoryName.length, 0);
        },
        descrCharsRemaining(){
            return Math.max(255 - this.categoryDescription.length, 0);
        }
    },
    methods: {
        onSave() {
            const name = XSSHelpers.stripAllTags(this.categoryName);
            const description = XSSHelpers.stripAllTags(this.categoryDescription);
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/new`,
                data: {
                    name,
                    description,
                    parentID: this.newFormParentID,
                    CSRFToken: this.CSRFToken
                },
                success: (res)=> {
                    const newCatID = res;
                    let temp = {};
                    //specified values
                    temp.categoryID = newCatID;
                    temp.categoryName = name;
                    temp.categoryDescription = description;
                    temp.parentID = this.newFormParentID;
                    //default values
                    temp.workflowID = 0;
                    temp.needToKnow = 1;
                    temp.visible = -1;
                    temp.sort = 0;
                    temp.type = '';
                    temp.stapledFormIDs = [];
                    temp.destructionAge = null;
                    this.addNewCategory(newCatID, temp);

                    if(this.newFormParentID === '') { //new main form
                        this.$router.push({name: 'category', query: { formID: newCatID }});
                    } else { //new internal
                        this.$emit('get-form', newCatID);
                    }
                    this.closeFormDialog();
                },
                error: err => {
                    console.log('error posting new form', err);
                }
            });
        }
    },
    template: `<div>
            <div style="display: flex; justify-content: space-between;">
                <label for="name">Form Name&nbsp;<span style="font-size:80%">(up to 50 characters)</span></label>
                <div>{{nameCharsRemaining}}</div>
            </div>
            <input id="name" type="text" maxlength="50" v-model="categoryName" style="width: 100%;" />
            <div style="display: flex; justify-content:space-between;margin-top: 1em;">
                <label for="description">Form Description&nbsp;<span style="font-size:80%">(up to 255 characters)</span></label>
                <div>{{descrCharsRemaining}}</div>
            </div>
            <textarea id="description" maxlength="255" rows="5" v-model="categoryDescription"
                style="width: 100%; resize:none;">
            </textarea>
        </div>`
};