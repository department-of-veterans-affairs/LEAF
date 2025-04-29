export default {
    name: 'workflow-step-info',
    data() {
        return {
            viewStepActions: false,
        }
    },
    inject: [
        'currentStep'
    ],
    computed: {
        stepID() {
            return this.currentStep?.stepID ?? null;
        },
        stepInfoStyles() {
            let returnValue = {};
            if(this.stepID !== null) {
                const position = $('#step_' + this.stepID).offset();
                const height = $('#step_' + this.stepID).height();
                returnValue = {
                    top: position.top + height + 20 + 'px',
                    left: position.left + 'px',
                }
            }
            return returnValue;
        }
    },
    template: `<div v-if="currentStep !== null" :id="'stepInfo_' + stepID" class="workflowStepInfo" :style="stepInfoStyles">
        <div v-if="stepID === -1">
            Request initiator (stepID #: -1)
            <input type="checkbox" v-model="viewStepActions">
            <ul v-show="viewStepActions">Test req</ul>
        </div>
        <div v-else-if="stepID === 0">
            End
        </div>
        <div v-else>
            <h3>stepID: #{{ stepID }}</h3>
            <input type="checkbox" v-model="viewStepActions">
            <ul v-show="viewStepActions">Test other</ul>
        </div>
        {{ stepInfoStyles }}
    </div>`
}