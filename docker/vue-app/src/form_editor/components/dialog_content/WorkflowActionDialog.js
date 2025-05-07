export default {
    name: 'workflow-action-dialog',
    data() {
        return {
            isNewAction: this.dialogData?.isNewAction,
            showInputs: false,
            actions: [],
            reservedActionTypes: {
                approve: 1,
                changeinitiator: 1,
                concur: 1,
                defer: 1,
                deleted: 1,
                disapprove: 1,
                move: 1,
                sendback: 1,
                sign: 1,
                submit: 1,
            },

            selectedExistingActionType: '',
            stepID: this.dialogData?.stepID,
            nextStepID: this.dialogData?.nextStepID,

            actionText: this.dialogData.actionText || '',
            actionTextPasttense: this.dialogData.actionTextPasttense || '',
            actionIcon: (this.dialogData.actionIcon || '').trim(),
            sort: this.dialogData?.sort ?? 0,
            fillDependency: this.dialogData?.fillDependency ?? 1,
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'dialogData',
        'currentWorkflowID',
        'steps',
        'postActionConnection',
        'postNewAction',
        'postEditAction',
        'loadWorkflow',
        'setDialogSaveFunction',
        'closeFormDialog'
	],
    created() {
        this.setDialogSaveFunction(this.onSave);
        if(this.isNewAction === true) {
            fetch(`${this.APIroot}workflow/actions`)
            .then(res => res.json())
            .then(actions => {
                this.actions = actions;
            }).catch(err => console.log(err));
        }
    },
    mounted() {
        const inputEl = document.getElementById('actionText');
        if(inputEl !== null) {
            inputEl.focus();
        }
        if(this.isNewAction) {
            let elSave = document.getElementById('button_save');
            if(elSave !== null) {
                elSave.setAttribute('disabled', true);
                this.validate();
            }
        }
    },
    computed: {
        isWorkflowConnection() {
            return this.dialogData?.isWorkflowConnection;
        },
        existingActionTypeMap() {
            let map = {};
            let name = '';
            this.actions.forEach(a => {
                name = (a?.actionType ?? '').toLowerCase().trim();
                map[name] = 1;
            });
            return map;
        },
        actionType() {
            const actionTypeRegex = new RegExp(/[^a-zA-Z0-9_]/, "gi");
            return this.actionText.replaceAll(actionTypeRegex, "");
        },
        sortValue() {
            return +this.sort < -128 ?
                -128 : +this.sort > 127 ?
                127 : +this.sort;
        },
        sourceTitle() {
            return this.stepID === -1 ? 'Requestor' : this.steps[this.stepID]?.stepTitle || '';
        },
        targetTitle() {
            return this.stepID === 0 ? 'End' : this.steps[this.nextStepID]?.stepTitle || '';
        },
        isReservedError() {
            const lowerType = this.actionType.toLowerCase();
            return this.isNewAction &&
                (this.existingActionTypeMap[lowerType] === 1 || this.reservedActionTypes[lowerType] === 1);
        }
    },
    methods: {
        validate() {
            const isExistingSelection = this.isWorkflowConnection && !this.showInputs;
            const hasRequiredInput = this.actionText !== '' && this.actionTextPasttense !== '';
            const isValid = isExistingSelection || (hasRequiredInput && !this.isReservedError);
            let elSave = document.getElementById('button_save');
            if(elSave !== null) {
                isValid ? elSave.removeAttribute('disabled') : elSave.setAttribute('disabled', true);
            }
        },
        onSave() {
            const callback = () => {
                this.closeFormDialog();
                this.loadWorkflow();
            }
            if (this.isWorkflowConnection && !this.showInputs) {
                const sourceID = this.stepID < 0 ? 0 : this.stepID;
                const targetID = this.nextStepID < 0 ? 0 : this.nextStepID;

                this.postActionConnection(
                    sourceID,
                    targetID,
                    this.selectedExistingActionType,
                    this.currentWorkflowID,
                    callback
                );

            } else {
                let formData = new FormData();
                formData.append('CSRFToken', this.CSRFToken);
                formData.append('actionText', this.actionText);
                formData.append('actionTextPasttense', this.actionTextPasttense);
                formData.append('actionIcon', this.actionIcon);
                formData.append('sort', this.sortValue);
                formData.append('fillDependency', +this.fillDependency);

                if(this.isNewAction === true) {
                    this.postNewAction(formData, callback);
                } else {
                    this.postEditAction(formData, this.actionType, callback);
                }
            }
        }
    },
    watch: {
        showInputs() {
            this.validate();
        }
    },
    template: `<div id="action_input_modal">
            <!-- WORKFLOW CONNECT -->
            <template v-if="isWorkflowConnection && showInputs === false">
                <div>Select action for <b>{{ sourceTitle }}</b> to <b>{{ targetTitle }}</b>:</div>
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
                <div :class="{'entry_error':isReservedError}">
                    <label for="actionText" id="action_label">Action <span style="color: #c00">&nbsp;*Required</span></label>
                    <div class="helper_text">eg: Approve</div>
                    <div v-show="isReservedError" id="actionText_error_message" class="error_message">
                        "This action name is not available.  Try another name."
                    </div>
                    <input id="actionText" type="text" maxlength="50" @change="validate" v-model.trim="actionText">
                </div>
                <div>
                    <label for="actionTextPasttense" id="action_past_tense_label"> Action Past Tense <span style="color: #c00">&nbsp;*Required</span></label>
                    <div class="helper_text">eg: Approved</div>
                    <input id="actionTextPasttense" type="text" maxlength="50" @change="validate" v-model.trim="actionTextPasttense">
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
                    <input id="actionSortNumber" type="number" min="-128" max="127" style="width:80px;" v-model.trim="sort">
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