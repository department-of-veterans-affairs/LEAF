export default {
    name: 'restore-field-options-dialog',
    data() {
        return {
            initialFocusElID: 'radio_restore_all',
            userOptionSelection: "all",
            userMessage: "",
            processing: false,
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',

        'restoreField',
        'updateAppData',
        'indicatorID_toRestore',
        'disabledAncestors',
        'firstOrphanID',
        'searchPending',

        'setDialogSaveFunction',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        //set the initial message for the user and set focus
        this.userMessage = `<p><b>This question has disabled parent questions:</b></p>`;
        const allRadio = document.getElementById(this.initialFocusElID);
        if(allRadio !== null) {
            allRadio.focus();
        }
    },
    computed: {
        disabledAncestorsList() {
            return [ ...this.disabledAncestors ].reverse();
        },
        listStyles() {
            return {
                listStyleType: "disc",
                marginLeft: "0.5rem",
                paddingTop: "0.75rem",
                lineHeight: "1.4",
                paddingInlineStart: "1rem",
            }
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
            const indID = this.indicatorID_toRestore;
            this.processing = true;
            if(this.userOptionSelection === "one") {
                Promise.all([
                    this.unsetParentID(indID),
                    this.restoreField(indID)
                ]).then(() => {
                    this.updateAppData(indID);
                    //<b style="color:#064;">Field ${indID} restored</b>
                    this.userMessage = ``;
                    this.closeFormDialog();
                }).catch(err => console.log(err));

            } else {
                this.userMessage = `<b style="color:#064;">Restoring Fields: `;
                //restore method below will pop one each time
                //in case of interruption, safe order is most distant parent to direct parent, then the ID to restore
                let arrRestore = [ { indicatorID: indID }, ...this.disabledAncestors ];

                const total = arrRestore.length;
                let count = 0;
                const restore = () => {
                    if(arrRestore.length > 0) {
                        const id = arrRestore.pop().indicatorID;
                        const remaining = arrRestore.length;
                        this.restoreField(id)
                        .then(() => {
                            this.updateAppData(id, 750);
                            this.userMessage += `${id}${remaining > 0 ? ", " : "</b>"}`;
                        }).catch(err => {
                            console.log(err);
                        }).finally(() => {
                            //for the most distant parent restored, reset the parentID if there is an orphan
                            if (count === 0 && this.firstOrphanID !== null) {
                                this.unsetParentID(id);
                            }
                            count++;
                            if(count === total) {
                                setTimeout(() => {
                                    this.closeFormDialog();
                                }, 750);
                            }
                        });

                    } else {
                        clearInterval(intervalID);
                    }
                }
                const intervalID = setInterval(restore, 100);
            }
        },
        /**
         * sets the parent ID of an indicator to null.
         * Used if a user decides to restore only a specific question when that question has disabled ancestors.
         * Used on the most distant parentID for multiple restores in an orphan is detected
         * @param {number} indicatorID
         * @returns promise
         */
        unsetParentID(indicatorID = 0) {
            let formData = new FormData();
            formData.append('CSRFToken', this.CSRFToken);
            formData.append('parentID', null);

            return fetch(`${this.APIroot}formEditor/${indicatorID}/parentID`, {
                method: 'POST',
                body: formData
            });
        }
    },
    template: `
            <div id="restore_fields_parent_options" style="margin: 1em 0; min-height: 50px;">
                <div v-if="searchPending === true" class="page_loading">
                    Loading...
                    <img src="../images/largespinner.gif" alt="" />
                </div>
                <template v-else>
                <p>{{ firstOrphanID }} </p>
                    <div v-if="userMessage !== ''" v-html="userMessage"></div>
                    <ul v-if="!processing" :style="listStyles">
                        <li v-for="element in disabledAncestorsList" style="display:list-item;">
                            <b>{{ element.indicatorID }}</b>: {{ element.name. length > 45 ? element.name.slice(0, 42) + "..." : element.name }}
                        </li>
                    </ul>
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
                </template>
            </div>`
}