export default {
    name: 'workflow-action-dialog',
    data() {
        return {
            actionText: this.dialogData.actionText || '',
            actionTextPasttense: this.dialogData.actionTextPasttense || '',
            actionIcon: (this.dialogData.actionIcon || '').trim(),
            sort: this.dialogData.sort || 0,
            fillDependency: this.dialogData.fillDependency || 1,
            isNewAction: this.dialogData?.isNewAction,
            showInputs: false,
            selectedExistingActionType: '',
            actions: [],
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'dialogData',
        'setDialogSaveFunction',
        'closeFormDialog'
	],
    created() {
        this.setDialogSaveFunction(this.onSave);
        if(this.isNewAction === true) {
            fetch(`${this.APIroot}workflow/actions`)
            .then(res => res.json())
            .then(actions => this.actions = actions)
            .catch(err => console.log(err));
        }
    },
    mounted() {
        const inputEl = document.getElementById('actionText');
        if(inputEl !== null) {
            inputEl.focus();
        }
    },
    computed: {
        isWorkflowConnection() {
            return this.dialogData?.isWorkflowConnection;
        },
    },
    methods: {
        onSave() {
            this.closeFormDialog();
        }
    },
    template: `<div id="action_input_modal">
            <!-- WORKFLOW CONNECT -->
            <template v-if="isWorkflowConnection && showInputs === false">
                <div>Select action for XXX to YYY:</div>
                <div>
                    <label for="actionType" id="actionType_label">Select an existing action type:</label>
                    <select id="actionType" v-model="selectedExistingActionType">
                        <option v-for="a in actions" :key="'select_' + a.actionType" :value="a.actionType">
                            {{ a.actionText }}
                        </option>
                    </select>
                </div>
            </template>
            <template v-if="isWorkflowConnection">
                <fieldset>
                    <legend>Action Options</legend>
                    <label>
                        <input type="radio" v-model="showInputs" v-bind:value="false">
                        Use an existing Action Type
                    </label>
                    <label>
                        <input type="radio" v-model="showInputs" v-bind:value="true">
                        Create a new Action Type
                    </label>
                </fieldset>
            </template>
            <!-- NEW, EDIT -->
            <template v-if="showInputs || !isWorkflowConnection">
                <div>
                    <label for="actionText" id="action_label">Action <span style="color: #c00">&nbsp;*Required</span></label>
                    <div class="helper_text">eg: Approve</div>
                    <div id="actionText_error_message" class="error_message"></div>
                    <input id="actionText" type="text" maxlength="50" v-model="actionText">
                </div>
                <div>
                    <label for="actionTextPasttense" id="action_past_tense_label"> Action Past Tense <span style="color: #c00">&nbsp;*Required</span></label>
                    <div class="helper_text">eg: Approved</div>
                    <input id="actionTextPasttense" type="text" maxlength="50" v-model="actionTextPasttense">
                </div>
                <div>
                    <label for="actionIcon" id="choose_icon_label">Icon</label>
                    <div class="helper_text">eg: go-next.svg &nbsp;<a :href="libsPath + 'dynicons/gallery.php'" style="color:#005EA2;" target="_blank">List of available icons</a></div>
                    <div class="action_icon">
                        <input id="actionIcon" type="text" maxlength="50" v-model="actionIcon">
                        <img v-if="actionIcon !== ''" :src="libsPath + 'dynicons/svg/' + actionIcon" class="icon_preview">
                    </div>
                </div>
                <div>
                    <label for="actionSortNumber" id="action_sort_label">Button Order</label>
                    <div class="helper_text">Lower numbers appear first</div>
                    <input id="actionSortNumber" type="number" min="-128" max="127" style="width:80px;" v-model="sort">
                </div>
                <div>
                    <label for="fillDependency">
                        Does this action represent moving forwards or backwards in the process?
                    </label>
                    <div v-if="+fillDependency < 1" id="backwards_action_note" class="helper_text">
                        Note: Backwards actions do not save form field data.
                    </div>
                    <select id="fillDependency" v-model="fillDependency">
                        <option value="1">Forwards</option>
                        <option value="-1">Backwards</option>
                    </select>
                </div>
            </template>
        </div>`
}