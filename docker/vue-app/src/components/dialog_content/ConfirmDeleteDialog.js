export default {
    name: 'confirm-delete-dialog',
    inject: [
        'APIroot',
        'CSRFToken',
        'focusedFormRecord',
        'getFormByCategoryID',
        'selectNewCategory',
        'removeCategory',
        'closeFormDialog'
    ],
    computed: {
        /**
         * uses LEAF XSSHelpers.js
         * @returns {string} category name / description with all tages stripped
         */
        formName() {
            return XSSHelpers.stripAllTags(this.focusedFormRecord.categoryName);
        },
        formDescription() {
            return XSSHelpers.stripAllTags(this.focusedFormRecord.categoryDescription);
        },
        currentStapleIDs() {
            return this.focusedFormRecord?.stapledFormIDs || [];
        },
    },
    methods:{
        onSave() {
            if(this.currentStapleIDs.length === 0) {
                const delID = this.focusedFormRecord.categoryID;
                const parID = this.focusedFormRecord.parentID;

                $.ajax({
                    type: 'DELETE',
                    url: `${this.APIroot}formStack/_${delID}?` + $.param({CSRFToken:this.CSRFToken}),
                    success: (res) => {
                        if(res !== true) {
                            alert(res);
                        } else {
                            //if a subform is deleted, re-focus its parent, otherwise go to browser
                            if (parID !== '') {
                                this.getFormByCategoryID(parID, true);
                            } else {
                                this.selectNewCategory();
                            }
                            this.removeCategory(delID);
                            this.closeFormDialog();
                        }
                    },
                    error: err => console.log('an error has occurred', err)
                });

            } else {
                //prevents some issues, as deleting a form with staples attached makes the stapled forms ineligible for workflow assignment 
                alert('Please remove all stapled forms before deleting.')
            }
        }
    },
    template:`<div>
        <div>Are you sure you want to delete this form?</div>
        <div style="margin: 1em 0;"><b>{{formName}}</b></div>
        <div style="min-width:300px; max-width: 500px; min-height: 50px; margin-bottom: 1rem;">{{formDescription}}</div>
        <div v-if="currentStapleIDs.length > 0">⚠️ This form still has stapled forms attached</div>
    </div>`
}