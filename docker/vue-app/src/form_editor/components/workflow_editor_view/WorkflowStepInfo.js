export default {
    name: 'workflow-step-info',
    data() {
        return {
            stepTitle: this.currentStep?.stepTitle ?? "",

            viewStepActions: false,
        }
    },
    mounted() {
        const btnEl = document.getElementById('btn_close_stepInfo');
        if(btnEl !== null) {
            btnEl.focus();
        }
    },
    inject: [
        'workflowStepInfoType',
        'currentStep',
        'currentJSPlumbParams',
        'steps',
        'routes',
        'closeWorkflowStepInfo',
    ],
    computed: {
        stepID() {
            return this.currentStep?.stepID ?? null;
        },
        actionType() {
            return this.currentJSPlumbParams?.action ?? null;
        },
        fromStepID() {
            return this.currentJSPlumbParams?.stepID ?? null;
        },
        fromStepTitle() {
            let title = 'Requestor';
            if (this.fromStepID !== -1) {
                title = this.steps?.[this.fromStepID]?.stepTitle || ''
            }
            return title;
        },
        //for action editing via stepInfo dropdown.
        outboundRoutes() {
            let hasSubmit = false;

            let routesArr = [];
            this.routes.map(r => {
                if(r.stepID === this.stepID) {
                    const { actionText, actionIcon, actionType } = r;
                    routesArr.push( { actionText, actionIcon, actionType });
                }
                if(r.actionType === "submit") {
                    hasSubmit = true;
                }
            });

            if(this.stepID === -1 && hasSubmit === false) {
                routesArr.push( { actionText: 'Submit', actionType: 'submit', actionIcon: '' } );
            }
            routesArr = routesArr.sort((a, b) => a.actionText < b.actionText);
            return routesArr;
        },
        stepInfoStyles() {
            let returnValue = {};
            if(this.workflowStepInfoType === 'step' && this.stepID !== null) {
                const stepEl = document.getElementById('step_' + this.stepID);
                if (stepEl !== null) {
                    const position = { left: stepEl.offsetLeft, top: stepEl.offsetTop };
                    const height = stepEl.offsetHeight;
                    returnValue = {
                        top: position.top + height + 16 + 'px',
                        left: position.left + 'px',
                    }
                }
            }
            if(this.workflowStepInfoType === 'action' && this.currentJSPlumbParams !== null) {
                returnValue = {
                    top: this.currentJSPlumbParams.pageY + 'px',
                    left: this.currentJSPlumbParams.pageX + 'px',
                }
            }
            return returnValue;
        },
        modalHeaderText() {
            let text = '';
            switch(this.stepID) {
                case null:
                    text = `Action: ${this.fromStepTitle} clicks ${this.actionType}`;
                    break;
                case -1:
                    text = 'Request initiator (stepID #: -1)';
                    break;
                case 0:
                    text = 'The End (stepID #: 0)';
                    break;
                default:
                text = `StepID: #${this.stepID}`;
                break;
            }
            return text;
        }
    },
    methods: {
        tabControls(event, closeBtn = false) {
            if (closeBtn === true && this.$refs.lastEl != undefined) { //close btn is explicitly tab.shift
                this.$refs.lastEl.focus();
                event.preventDefault();
            }
            if (closeBtn === false && event.shiftKey === false && this.$refs.closeBtn != undefined) {
                this.$refs.closeBtn.focus();
                event.preventDefault();
            }
        }
    },
    watch: {
        currentStep(newVal, oldVal) {
            console.log("step watch", newVal, oldVal)
        },
        currentJSPlumbParams(newVal, oldVal) {
            console.log("action watch", newVal, oldVal)
        }
    },
    template: `<div :id="'stepInfo_' + (stepID ?? actionType)"
        class="workflowStepInfo" :style="stepInfoStyles" @keydown.escape="closeWorkflowStepInfo($event, true)">
        <div id="stepInfo_header">
            <h3>{{ modalHeaderText }}</h3>
            <button type="button" id="btn_close_stepInfo" aria-label="close modal"
                @keydown.tab.shift="tabControls($event, true)" ref="closeBtn"
                @click="closeWorkflowStepInfo($event, true)">
                    &#10005;
            </button>
        </div>
        <div v-if="workflowStepInfoType === 'step' && stepID !== null" id="stepInfo_content">
            <div v-if="stepID > 0">
                <label for="step_title"> Step Title:</label>
                <input id="step_title" type="text" v-model="stepTitle">
            </div>
            <div v-if="stepID !== 0">
                <label for="toggleManageActions">
                    <input id="toggleManageActions" type="checkbox" style="margin:0;" v-model="viewStepActions">
                    &nbsp;View Step Actions
                </label>
                <ul v-show="viewStepActions" class="workflow_actions">
                    <li v-for="r in outboundRoutes" :key="'route_info_' + r.actionType">{{ r.actionText }}</li>
                </ul>
            </div>

            <button type="button" class="buttonNorm"
                @keydown.tab="tabControls($event, false)" ref="lastEl">test last</button>
         </div>
         <div v-if="workflowStepInfoType === 'action' && currentJSPlumbParams !== null" id="stepInfo_content">
         </div>
    </div>`
}