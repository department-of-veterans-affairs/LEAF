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
        'listTracker',
        'indicatorsInWorkflow',
    ],
    created() {
        if (!this.hasIndicatorsInWorkflow) {
            this.setDialogSaveFunction(this.onSave);
        } else {
            // Set save function to null or empty function to hide the save button
            this.setDialogSaveFunction(null);
        }
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
        /**
         * Check if any indicators from listTracker are in indicatorsInWorkflow
         * @returns {boolean}
         */
        hasIndicatorsInWorkflow() {
            if (!this.listTracker || !this.indicatorsInWorkflow) {
                return false;
            }
            console.log('ConfirmDeleteDialog created', Object.keys(this.listTracker));

            const indicatorIDs = Object.keys(this.listTracker);
            console.log('ConfirmDeleteDialog created', indicatorIDs);

            return indicatorIDs.some(indicatorID =>
                this.indicatorsInWorkflow.hasOwnProperty(indicatorID)
            );
        },
        /**
         * Build message showing which indicators are in workflows
         * @returns {string}
         */
        workflowBlockingMessage() {
            if (!this.hasIndicatorsInWorkflow) {
                return '';
            }

            let messageParts = [];
            const indicatorIDs = Object.keys(this.listTracker);

            indicatorIDs.forEach(indicatorID => {
                if (this.indicatorsInWorkflow[indicatorID]) {
                    const workflowStatus = this.indicatorsInWorkflow[indicatorID];

                    // Split workflow and step names by '), ' to handle commas within names
                    const workflowNames = workflowStatus.workflowName.split('), ').map((name, idx, arr) => {
                        return idx < arr.length - 1 ? name + ')' : name;
                    });

                    const stepNames = workflowStatus.stepName.split('), ').map((name, idx, arr) => {
                        return idx < arr.length - 1 ? name + ')' : name;
                    });

                    // Build message for each workflow/step combination
                    for (let i = 0; i < workflowNames.length; i++) {
                        const workflow = workflowNames[i] || '';
                        const step = stepNames[i] || '';
                        if (workflow && step) {
                            messageParts.push(`Indicator ID ${indicatorID} - Workflow: ${workflow} - Step: ${step}`);
                        }
                    }
                }
            });

            if (messageParts.length === 0) {
                return '';
            }

            return `Sorry, you are not allowed to delete this form at this time. Indicator(s) on this form are currently being used in a workflow. Here is a list of Indicators, the workflow they are present in and the step.<br /><br />${messageParts.join('<br />')}`;
        },
    },
    mounted() {
        // Hide the save button if there are workflow dependencies
        if (this.hasIndicatorsInWorkflow) {
            const saveButton = document.getElementById('button_save');
            if (saveButton) {
                saveButton.style.display = 'none';
            }

            const cancelButton = document.getElementById('button_cancelchange');
            if (cancelButton) {
                cancelButton.textContent = 'Close';
            }
        }
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
        <div v-if="hasIndicatorsInWorkflow">
            <div class="entry_warning bg-yellow-5" style="margin-bottom: 1rem;">
                <span role="img" alt="warning">⚠️</span>
                <span v-html="workflowBlockingMessage"></span>
            </div>
        </div>
        <div v-else>
            <div>Are you sure you want to delete this form?</div>
            <div style="margin: 1em 0;"><b>{{formName}}</b></div>
            <div style="min-width:300px; max-width: 500px; min-height: 50px; margin-bottom: 1rem;">{{formDescription}}</div>
            <div v-if="currentStapleIDs.length > 0">⚠️ This form still has stapled forms attached</div>
        </div>
    </div>`
}