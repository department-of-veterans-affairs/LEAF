export default {
    name: 'workflow-action-dialog',
    data() {
        return {
            actionText: this.dialogData.actionText || '',
            actionTextPasttense: this.dialogData.actionTextPasttense || '',
            actionIcon: (this.dialogData.actionIcon || '').trim(),
            sort: this.dialogData.sort || 0,
            fillDependency: this.dialogData.fillDependency || 1,
            isNewAction: this.dialogData.isNewAction || false,
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
    },
    mounted() {
        document.getElementById('actionText').focus();
    },
    methods: {
        onSave() {
            this.closeFormDialog();
        }
    },
    template: `<div id="action_input_modal">
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
        </div>`
}