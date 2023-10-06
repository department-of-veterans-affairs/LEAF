export default {
    name: 'confirm-delete-dialog',
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'focusedFormRecord',
        'selectNewCategory',
        'removeCategory',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
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
                        //+res will cover 1, '1', and true
                        if(+res === 1) {
                            this.removeCategory(delID);
                            if(parID === '') { //if a main form is deleted go to browser
                                this.$router.push({ name: 'browser'});
                            } else { //otherwise focus parent
                                this.selectNewCategory(parID, true);
                            }
                            this.closeFormDialog();
                        } else {
                            alert(res);
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