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
        'restoreIndicatorID',
        'disabledAncestors',

        'setDialogSaveFunction',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        this.userMessage = `<p><b>This question has disabled parent questions:</b><br>${this.disabledAncestorsText}</p>`;
        const allRadio = document.getElementById(this.initialFocusElID);
        if(allRadio !== null) {
            allRadio.focus();
        }
    },
    computed: {
        disabledAncestorsText() {
            return "IDs: " + this.disabledAncestors.join(", ");
        }
    },
    methods: {
        onSave() {
            this.userMessage = "<b>Processing...</b>";
            if(this.userOptionSelection === "one") {
                Promise.all([
                    this.unsetParentID(this.restoreIndicatorID),
                    this.restoreField(this.restoreIndicatorID)
                ]).then(() => {
                    this.userMessage = "";
                    this.closeFormDialog();
                }).catch(err => console.log(err));

            } else {
                //start with parents in case this is interrupted
                let arrRestore = [ ...this.disabledAncestors, this.restoreIndicatorID ].reverse();

                const total = arrRestore.length;
                let count = 0;
                const restore = () => {
                    if(arrRestore.length > 0) {
                        const id = arrRestore.pop();
                        this.restoreField(id)
                        .then(() => {
                        }).catch(err => {
                            console.log(err);
                        }).finally(() => {
                            count++;
                            if(count === total) {
                                clearInterval(intervalID);
                                this.userMessage = "";
                                this.closeFormDialog();
                            }
                        });
                    }
                }
                const intervalID = setInterval(restore, 150);
            }
        },
        unsetParentID() {
            return new Promise((resolve, reject) => {
                let formData = new FormData();
                formData.append('CSRFToken', this.CSRFToken);
                formData.append('parentID', null);

                fetch(`${this.APIroot}formEditor/${this.restoreIndicatorID}/parentID`, {
                    method: 'POST',
                    body: formData
                }).then(res => res.json()).then(() => {
                    resolve();
                }).catch(err => {
                    console.log("error setting parentID", err)
                    reject(err);
                });
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