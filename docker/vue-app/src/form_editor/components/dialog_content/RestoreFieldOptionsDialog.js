export default {
    name: 'restore-field-options-dialog',
    data() {
        return {
            initialFocusElID: 'radio_restore_all',
            userOptionSelection: "all",
            userMessage: ''
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',

        'restoreIndicatorID',
        'disabledAncestors',

        'setDialogSaveFunction',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        const allRadio = document.getElementById(this.initialFocusElID);
        if(allRadio !== null) {
            allRadio.focus();
        }
        
    },
    computed: {
        disabledAncestorsText() {
            return "indicatorIDs: " + this.disabledAncestors.join(", ");
        }
    },
    methods: {
        onSave() {
            console.log("save clicked");
            console.log(this.restoreIndicatorID);
            console.log(this.disabledAncestors);
            console.log(this.userOptionSelection);
            /* TODO:
            get the user choice
            if all, interval restore all disabled ancestors
            if one, restore only restoreIndicatorID and also unset its parentID
            */
            this.closeFormDialog();
        },
        unsetParentID() {
            let formData = new FormData();
            formData.append('CSRFToken', this.CSRFToken);
            formData.append('parentID', null);

            fetch(`${this.APIroot}formEditor/${this.restoreIndicatorID}/parentID`, {
                method: 'POST',
                body: formData
            }).then(res => res.json()).then(() => {
            }).catch(err => console.log("error setting parentID", err));
        }
    },
    template: `
            <div id="restore_fields_parent_options" style="margin: 1em 0; min-height: 50px;">
                <p><b>This question has disabled parent questions:</b></p>
                <p>{{ disabledAncestorsText }}</p>
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
                        <span class="leaf_check"></span> Restore only this field (This will break its associations)
                    </label>
                </fieldset>
                <div v-if="userMessage" style="padding: 0.5rem 0"><b>{{ userMessage }}</b></div>
            </div>`
}