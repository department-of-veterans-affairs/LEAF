export default {
    name: 'confirm-delete-dialog',
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'decodeAndStripHTML',
        'focusedFormRecord',
        'getFormByCategoryID',
        'removeCategory',
        'closeFormDialog',
        'indicatorsInWorkflow',
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    computed: {
        /**
         * uses LEAF XSSHelpers.js
         * @returns {string} category name / description with potential tags stripped
         */
        formName() {
            return XSSHelpers.stripAllTags(this.decodeAndStripHTML(this.focusedFormRecord.categoryName));
        },
        formDescription() {
            return XSSHelpers.stripAllTags(this.decodeAndStripHTML(this.focusedFormRecord.categoryDescription));
        },
        currentStapleIDs() {
            return this.focusedFormRecord?.stapledFormIDs || [];
        },
        hasIndicatorsInWorkflow() {
            const workflowData = this.indicatorsInWorkflow || {};
            return Object.values(workflowData).some(indicator =>
                indicator.inWorkflow === true || indicator.stepInWorkflow === true
            );
        },
        canDelete() {
            return !this.hasIndicatorsInWorkflow && this.currentStapleIDs.length === 0;
        }
    },
    mounted() {
        // Hide the save button if there are workflow dependencies
        if (this.hasIndicatorsInWorkflow) {
            const saveButton = document.getElementById('button_save');
            if (saveButton) {
                saveButton.style.display = 'none';
            }

            // Change cancel button text to "Close"
            const cancelButton = document.getElementById('button_cancelchange');
            if (cancelButton) {
                cancelButton.textContent = 'Close';
            }
        }
    },
    methods:{
        onSave() {
            if (this.hasIndicatorsInWorkflow) {
                return; // Prevent deletion if indicators are in workflow
            }

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
                                this.getFormByCategoryID(parID, true);
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
        <span v-if="hasIndicatorsInWorkflow" class="entry_info bg-blue-5v" style="margin-top:1.5rem;">
            <span role="img" aria-hidden="true" alt="">ℹ️</span>
            Indicators are used in the workflow, remove those dependencies before deleting this form
        </span>
    </div>`
}