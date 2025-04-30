export default {
    name: 'workflow-menu',
    inject: [
        'libsPath',

        'currentWorkflowID',
        'currentStep',
        'workflows',
        'steps',

        'newWorkflow',
        'createStep',
        'renameWorkflow',
        'duplicateWorkflow',
        'openHistoryDialog',
        'listActions',
        'listEvents',
        'deleteWorkflow'
    ],
    mounted() {
        let inputEl = document.getElementById('workflows');
        if (inputEl !== null && inputEl.value !== this.currentWorkflowID) {
            inputEl.value = this.currentWorkflowID;
            $("#workflows").trigger('chosen:updated');
        }
    },
    computed: {
        selectedWorkflowDescription() {
            return this.workflows[this.currentWorkflowID]?.description ?? "";
        },
        selectedWorkflowAria() {
            return this.selectedWorkflowDescription + 'is selected.';
        },
        selectedStepAria() {
            return this.currentStep?.stepTitle !== undefined ?
                this.currentStep.stepTitle + 'is selected.' : "";
        },
        stepList() {
            let arrSteps = [];
            for (let key in this.steps) {
                arrSteps.push({ ...this.steps[key] });
            }
            const sortedSteps = arrSteps.sort((a, b) => {
                const stepA = a.stepTitle.toLowerCase();
                const stepB = b.stepTitle.toLowerCase();
                return stepA < stepB ? -1 : stepA > stepB ? 1 : 0
            });
            return sortedSteps;
        },
    },
    template: `<div id="sideBar">
        <div>
            <label id="workflows_label" for="workflows">Workflows:</label>
            <div id="workflowList">
                <span id="workflow_select_status" role="status" aria-live="polite" :aria-label="selectedWorkflowAria"></span>
                <select id="workflows" title="Select a Workflow">
                    <option v-for="w in workflows" :key="'workflows_' + w.workflowID" :value="w.workflowID">
                        {{ w.description }} (ID:# {{ w.workflowID }})
                    </option>
                </select>
            </div>
        </div>
        <button type="button" id="btn_newWorkflow" class="buttonNorm" @click="newWorkflow();">
            <img :src="libsPath + 'dynicons/svg/list-add.svg'" alt="">New Workflow
        </button>
        
        <div>
            <label id="steps_label" for="workflow_steps">Workflow Steps:</label>
            <div id="stepList">
                <span id="step_select_status" role="status" aria-live="polite" :aria-label="selectedStepAria"></span>
                <select id="workflow_steps" title="Select a Workflow Step to edit it">
                    <option value="0">Choose a step to edit</option>
                    <option value="-1">Requestor</option>
                    <option v-for="s in stepList" :key="'workflow_steps_' + s.stepID" :value="s.stepID">
                        {{ s.stepTitle }} (#{{ s.stepID }})
                    </option>
                </select>
            </div>
        </div>
        <button type="button" id="btn_createStep" class="buttonNorm" @click="createStep">
            <img :src="libsPath + 'dynicons/svg/list-add.svg'" alt="">New Step
        </button>
        <br>
        <button type="button" id="btn_renameWorkflow" class="buttonNorm" @click="renameWorkflow()">
            <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="" />Rename Workflow
        </button>
        <button type="button" id="btn_duplicateWorkflow" class="buttonNorm" @click="duplicateWorkflow()">
            <img :src="libsPath + 'dynicons/svg/edit-copy.svg'" alt="" />Copy Workflow
        </button>
        <br>
        <button type="button" id="btn_viewHistory" class="buttonNorm" @click="openHistoryDialog(currentWorkflowID,'workflow');">
            <img :src="libsPath + 'dynicons/svg/appointment.svg'" alt="" />View History
        </button>
        <br>
        <button type="button" id="btn_listActionType" class="buttonNorm" @click="listActions">
            <img :src="libsPath + 'dynicons/svg/applications-other.svg'" alt="" /> Edit Actions
        </button>
        <button type="button" id="btn_listEvents" class="buttonNorm" @click="listEvents">
            <img :src="libsPath + 'dynicons/svg/gnome-system-run.svg'" alt="" />Edit Events
        </button>
        <br>
        <button type="button" id="btn_deleteWorkflow" class="buttonNorm" @click="deleteWorkflow">
            <img :src="libsPath + 'dynicons/svg/list-remove.svg'" alt="" />Delete Workflow
        </button>
    </div>`
}