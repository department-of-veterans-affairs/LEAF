export default {
    name: 'workflow-step-info',
    data() {
        return {
            submenu: null,
            stepElement: null,

            stepTitleInput: this.currentStep?.stepTitle ?? '',
            selectedNextID: '',

            viewStepActions: false,
            stepDependencies: [],
        }
    },
    created() {
        if(this.workflowStepInfoType === 'step') {
            this.getStepDependencies();
        }
    },
    mounted() {
        this.submenu = document.getElementById(this.menuID);
        this.stepElement = document.getElementById('step_' + this.stepID);
        this.setSubmenuPositions();
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'decodeAndStripHTML',
        'currentWorkflowID',
        'workflowStepInfoType',
        'currentStep',
        'currentJSPlumbParams',
        'steps',
        'routes',
        'createConnection',
        'closeWorkflowStepInfo',
    ],
    computed: {
        stepID() {
            return this.currentStep?.stepID ?? null;
        },
        actionType() {
            return this.currentJSPlumbParams?.action ?? null;
        },
        menuID() {
            return 'stepInfo_' + (this.stepID ?? this.actionType);
        },
        fromStepID() {
            return this.currentJSPlumbParams?.stepID ?? null;
        },
        fromStepTitle() {
            let title = 'Requestor';
            if (this.fromStepID !== -1) {
                title = this.decodeAndStripHTML(this.steps?.[this.fromStepID]?.stepTitle || '');
            }
            return title;
        },
        //for list of outbound actions step info submenu.
        outboundRoutes() {
            let hasSubmit = false;

            let routesArr = [];
            this.routes.map(r => {
                if(r.stepID === this.stepID) {
                    const { actionText, actionIcon, actionType } = r;
                    routesArr.push( { actionText, actionIcon, actionType });
                }
                if(r.actionType === "submit") { //copied logic from mod_form - not sure it's ever here
                    hasSubmit = true;
                }
            });

            if(this.stepID === -1 && hasSubmit === false) {
                routesArr.push( { actionText: 'Submit', actionType: 'submit', actionIcon: '' } );
            }
            routesArr = routesArr.sort((a, b) => a.actionText < b.actionText);
            return routesArr;
        },
        modalHeaderHTML() {
            let html = '';
            switch(this.stepID) {
                case null:
                    if(this.workflowStepInfoType === 'action') {
                        html = `Action: <div style="font-size:86%;">${this.fromStepTitle} clicks ${this.actionType}</div>`;
                    }
                    break;
                case -1:
                    html = 'Request initiator (stepID #: -1)';
                    break;
                case 0:
                    html = 'The End (stepID #: 0)';
                    break;
                default:
                html = `StepID: #${this.stepID}`;
                break;
            }
            return html;
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
        },
        setSubmenuPositions() {
            if(this.submenu !== null) {
                if(this.workflowStepInfoType === 'step' && this.stepElement !== null) {
                    this.submenu.style.top = this.stepElement.offsetTop + this.stepElement.offsetHeight + 16 + 'px';
                    this.submenu.style.left = this.stepElement.offsetLeft + 'px';
                }
                if(this.workflowStepInfoType === 'action' && this.currentJSPlumbParams !== null) {
                    this.submenu.style.top = this.currentJSPlumbParams.pageY + 'px';
                    this.submenu.style.left = this.currentJSPlumbParams.pageX + 'px';
                }
                //adjust left location if off right of screen
                const rect = this.submenu.getBoundingClientRect();
                if(rect.right > window.innerWidth) {
                    const adjustedLeft = 16 + rect.right - window.innerWidth;
                    const currentLeft = parseInt(this.submenu.style.left);
                    this.submenu.style.left = currentLeft - adjustedLeft + 'px';
                }
                const btnEl = document.getElementById('closeModal');
                if(btnEl !== null) {
                    btnEl.focus();
                }
            }
        },
        getStepDependencies() {
            fetch(`${this.APIroot}workflow/step/${this.stepID}/dependencies`)
            .then(res => res.json())
            .then(deps => this.stepDependencies = deps)
            .catch(err => console.log(err));
        },
        addConnection() {
            if(this.selectedNextID !== '') {
                console.log(this.currentWorkflowID, this.stepID, )
                this.createConnection(this.currentWorkflowID, this.stepID, +this.selectedNextID);
            }
        },
        updateStepTitle() {
            console.log("update title")
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
    template: `<div :id="menuID" class="workflowStepInfo" :class="workflowStepInfoType"
        @keydown.escape="closeWorkflowStepInfo($event, true)">
        <div id="stepInfo_header">
            <h3 v-html="modalHeaderHTML"></h3>
            <button type="button" id="closeModal" aria-label="close modal"
                @keydown.tab.shift="tabControls($event, true)" ref="closeBtn"
                @click="closeWorkflowStepInfo($event, true)">
                    &#10005;
            </button>
        </div>
        <!-- STEP submenu -->
        <div v-if="workflowStepInfoType === 'step' && stepID !== null" id="stepInfo_content">

            <!-- EDIT title, view ADD/RM requirements -->
            <template v-if="stepID > 0">
                <label for="step_title"> Step Title:
                    <input id="step_title" type="text" v-model="stepTitleInput" @change="updateStepTitle">
                </label>

                <div>
                    <b>Step Requirements</b>
                    <ul id="step_requirements">
                        <li>temp 1</li>
                        <li>temp 2</li>
                        <li>temp 3</li>
                    </ul>
                    <button type="button" class="buttonNorm">Add maybe here</button>
                </div>
            </template>
            <!-- ADD Fieldset, Access outbound routes -->
            <template v-if="stepID !== 0">
                <fieldset>
                    <legend>Step Options</legend>
                    <label v-if="stepID > 0" :for="'workflowIndicator_' + stepID" style="margin:0 0 1rem 0;"> Form Field:
                        <select :id="'workflowIndicator_' + stepID">
                        </select>
                    </label>
                    <label for="toggleManageActions">
                        <input id="toggleManageActions" type="checkbox" style="margin:0;" v-model="viewStepActions">
                        &nbsp;View Step Actions
                    </label>
                    <div v-show="viewStepActions" id="manage_actions_options">
                        <ul id="outbound_actions_list">
                            <li v-for="r in outboundRoutes" :key="'route_info_' + r.actionType">
                                <div class="action_text">{{ r.actionText }}</div>
                                <div class="action_options">
                                    <button type="button"
                                        :aria-label="'Manage events for action: ' + r.actionText + ', step ' + r.stepID"
                                        title="Manage Action Events"
                                        aria-label="Manage Action Events">📃
                                    </button>
                                    <button v-if="currentWorkflowID > 0 && r.stepID !== -1" type="button"
                                        :aria-label="'Remove action: ' + r.actionText + ', step ' + r.stepID"
                                        title="Remove this action"
                                        aria-label="Remove Action">❌
                                    </button>
                                </div>
                            </li>
                        </ul>
                        <label for="create_route">Add Action:</label>
                        <select id="create_route" title="Choose a step to connect to" v-model="selectedNextID"
                            @change="addConnection">
                            <option value="">Choose Step to Connect to</option>
                            <option value="0">End</option>
                        </select>
                    </div>
                </fieldset>
                <div>TODO Email reminder info
                    <button type="button" class="buttonNorm" @keydown.tab="tabControls($event, false)" ref="lastEl">
                        Email Reminder
                    </button>
                </div>
            </template>
         </div>
         <!-- ACTION submenu -->
         <div v-if="workflowStepInfoType === 'action' && currentJSPlumbParams !== null" id="stepInfo_content">
         </div>
    </div>`
}