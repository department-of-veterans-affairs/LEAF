export default {
    name: 'restore-field-options-dialog',
    data() {
        return {
            initialFocusElID: 'radio_restore_all',
            userOptionSelection: "all",
            userMessage: "",
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',

        'restoreField',
        'updateDisabledFields',
        'indicatorID_toRestore',
        'disabledAncestors',

        'setDialogSaveFunction',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        //set the initial message for the user and set focus
        this.userMessage = `<p><b>This question has disabled parent questions:</b><br>${this.disabledAncestorsText}</p>`;
        const allRadio = document.getElementById(this.initialFocusElID);
        if(allRadio !== null) {
            allRadio.focus();
        }
    },
    computed: {
        disabledAncestorsText() {
            let idsOrderByParent = [ ...this.disabledAncestors ].reverse();
            return "IDs: " + idsOrderByParent.join(", ");
        }
    },
    methods: {
        /*
        * Performs restore actions according to user choice.
        * If restoring only a single question, the parent ID is also unset so that the question will appear on the form
        * If restoring all associated fields, the question and its disabled ancestors restored at intervals
        */
        onSave() {
            this.userMessage = "<b>Processing...</b>";
            if(this.userOptionSelection === "one") {
                Promise.all([
                    this.unsetParentID(this.indicatorID_toRestore),
                    this.restoreField(this.indicatorID_toRestore)
                ]).then(() => {
                    this.updateDisabledFields(this.indicatorID_toRestore);
                    this.userMessage = "";
                    this.closeFormDialog();
                }).catch(err => console.log(err));

            } else {
                //restore method below will pop one each time
                //in case of interruption, safe order is most distant parent to direct parent, then the ID to restore
                let arrRestore = [ this.indicatorID_toRestore, ...this.disabledAncestors ];

                const total = arrRestore.length;
                let count = 0;
                const restore = () => {
                    if(arrRestore.length > 0) {
                        const id = arrRestore.pop();
                        this.restoreField(id)
                        .then(() => {
                            this.updateDisabledFields(id);
                        }).catch(err => {
                            console.log(err);
                        }).finally(() => {
                            count++;
                            if(count === total) {
                                this.userMessage = "";
                                this.closeFormDialog();
                            }
                        });

                    } else {
                        clearInterval(intervalID);
                    }
                }
                const intervalID = setInterval(restore, 150);
            }
        },
        /**
         * sets the parent ID of the indicator being restored to null.
         * Used if a user decides to restore only a specific question when that question has disabled ancestors.
         * @returns promise
         */
        unsetParentID() {
            let formData = new FormData();
            formData.append('CSRFToken', this.CSRFToken);
            formData.append('parentID', null);

            return fetch(`${this.APIroot}formEditor/${this.indicatorID_toRestore}/parentID`, {
                method: 'POST',
                body: formData
            });
        }
    },
    template: `
            <div id="restore_fields_parent_options" style="margin: 1em 0; min-height: 50px;">
                <div v-if="userMessage !== ''" v-html="userMessage"></div>
                <fieldset>
                    <legend id="restore_fields_legend">Restore Options</legend>
                    <label class="checkable leaf_check" for="radio_restore_all">
                        <input type="radio" checked
                            v-model="userOptionSelection"
                            id="radio_restore_all"
                            class="icheck leaf_check"
                            value="all"
                            aria-describedby="restore_fields_parent_options">
                        <span class="leaf_check"></span> Restore associated fields
                    </label>
                    <label class="checkable leaf_check" for="radio_restore_one">
                        <input type="radio"
                            v-model="userOptionSelection"
                            id="radio_restore_one"
                            class="icheck leaf_check"
                            value="one"
                            aria-describedby="restore_fields_parent_options">
                        <span class="leaf_check"></span> Only restore this field (This will break its associations)
                    </label>
                </fieldset>
            </div>`
}