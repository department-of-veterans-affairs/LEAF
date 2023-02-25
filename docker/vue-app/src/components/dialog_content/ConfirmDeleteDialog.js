export default {
    data() {
        return {
            formID: this.currSubformID || this.currCategoryID,
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'currCategoryID',
        'currSubformID',
        'currentCategorySelection',
        'selectNewCategory',
        'closeFormDialog'
    ],
    computed: {
        /**
         * uses LEAF XSSHelpers.js
         * @returns {string} category name / description with all tages stripped
         */
        formName() {
            return XSSHelpers.stripAllTags(this.currentCategorySelection.categoryName);
        },
        formDescription() {
            return XSSHelpers.stripAllTags(this.currentCategorySelection.categoryDescription);
        },
        currentStapleIDs() {
            return this.currentCategorySelection?.stapledFormIDs || [];
        },
    },
    methods:{
        onSave() {
            if(this.currentStapleIDs.length === 0) {
                
                $.ajax({
                    type: 'DELETE',
                    url: `${this.APIroot}formStack/_${this.formID}?` + $.param({CSRFToken:this.CSRFToken}),
                    success: (res) => {
                        if(res !== true) {
                            alert(res);
                        } else {
                            this.closeFormDialog();
                            this.selectNewCategory(null);
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