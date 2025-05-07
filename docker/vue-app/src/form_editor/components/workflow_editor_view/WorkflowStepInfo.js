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
        //list of existing outbound actions for the step info submenu.
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
            return routesArr;
        },
        stepRouteOptions() {
            let options = [];
            if (this.currentWorkflowID > 0) {
                const stepKeys = Object.keys(this.steps);
                stepKeys.forEach(k => {
                    if (+k !== this.stepID) {
                        options.push({ ...this.steps[k] });
                    }
                });
                options = options.sort((a, b) => {
                    const stepA = a.stepTitle.toLowerCase();
                    const stepB = b.stepTitle.toLowerCase();
                    return stepA < stepB ? -1 : stepA > stepB ? 1 : 0;
                });
            }
            return options;
        },
        uniqueStepDependencies() {
            let added = {};
            let uniqueDeps = [];
            this.stepDependencies.forEach(d => {
                if (added[d.dependencyID] === undefined) {
                    uniqueDeps.push(d);
                    added[d.dependencyID] = 1;
                }
            });
            return uniqueDeps;
        },
        customRequirementGroupMap() {
            let map = {};
            let depID = null;
            this.stepDependencies.forEach(d => {
                depID = d.dependencyID;
                if (d.groupID > 0) {
                    if (map[depID] === undefined) {
                        map[depID] = [];
                    }
                    map[depID].push({ groupID: d.groupID, name: d.name });
                }
            });
            return map;
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
        },
        smartRequirementIDs() {
            return [-3, -2, -1, 1, 8];
        },
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
        },
        editRequirement() {
            console.log("edit requirement")
        },
        unlinkDependency() {
            console.log("unlink dep")
        },
        setDynamicGroupApprover() {
            console.log("apr group")
        },
        dependencyGrantAccess() {

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
                    <b>Requirements</b>
                    <ul id="step_requirements">
                        <li v-for="d in uniqueStepDependencies" :key="'step_' + stepID + 'dep_' + d.dependencyID">
                            <template v-if="smartRequirementIDs.includes(d.dependencyID)">
                                <b style="color:green;vertical-align:middle;">{{ d.description }}</b>
                                <!-- service chief and quadrad -->
                                <button v-if="d.dependencyID === 1 || d.dependencyID === 8" type="button" class="buttonNorm icon"
                                    @click="editRequirement(d.dependencyID, d.description, stepID)"
                                    title="Edit Requirement Name" aria-label="Edit Requirement Name">
                                    <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="">
                                </button>
                                <button type="button" class="buttonNorm icon"
                                    @click="unlinkDependency(stepID, d.dependencyID)"
                                    title="Remove Requirement" aria-label="Remove Requirement">
                                    <img :src="libsPath + 'dynicons/svg/dialog-error.svg'" alt="">
                                </button>
                                (depID: {{ d.dependencyID }})
                                <template v-if="d.dependencyID === -1">
                                    <div v-if="d.indicatorID_for_assigned_empUID === null || d.indicatorID_for_assigned_empUID === 0"
                                        class="error_message">A data field (indicatorID) must be set.</div>
                                    <div>
                                        indicatorID:
                                        <span :class="{error_message: !d.indicatorID_for_assigned_empUID}">
                                            {{ d.indicatorID_for_assigned_empUID ?? 'not set' }}
                                        </span>
                                    </div>
                                    <button type="button" class="buttonNorm" @click="setDynamicApprover(stepID)">Set Data Field</button>
                                </template>
                                <template v-if="d.dependencyID === -3">
                                    <div v-if="d.indicatorID_for_assigned_groupID === null || d.indicatorID_for_assigned_groupID === 0"
                                        class="error_message">A data field (indicatorID) must be set.</div>
                                    <div>
                                        indicatorID:
                                        <span :class="{error_message: !d.indicatorID_for_assigned_groupID}">
                                            {{ d.indicatorID_for_assigned_groupID ?? 'not set' }}
                                        </span>
                                    </div>
                                    <button type="button" class="buttonNorm" @click="setDynamicGroupApprover(stepID)">Set Data Field</button>
                                </template>
                            </template>
                            <template v-else>
                                <b tabindex=0 role="button"
                                    :title="'Choose access groups for depID: ' + d.dependencyID"
                                    :aria-label="'Choose access groups for depID: ' + d.dependencyID"
                                    @click="dependencyGrantAccess(d.dependencyID, stepID)">
                                    {{ d.description }}
                                </b>
                                <button type="button" class="buttonNorm icon"
                                    @click="editRequirement(d.dependencyID, d.description, stepID)"
                                    title="Edit Requirement Name" aria-label="Edit Requirement Name">
                                    <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="">
                                </button>
                                <button type="button" class="buttonNorm icon"
                                    @click="unlinkDependency(stepID, d.dependencyID)"
                                    title="Remove Requirement" aria-label="Remove Requirement">
                                    <img :src="libsPath + 'dynicons/svg/dialog-error.svg'" alt="">
                                </button>
                                <ul v-if="customRequirementGroupMap[d.dependencyID]?.length > 0"
                                    :id="'step_' + stepID + '_dep' + d.dependencyID">
                                    <li v-for="g in customRequirementGroupMap[d.dependencyID]"
                                        :key="'groups_' + d.dependencyID + '_' + g.groupID">
                                        {{ g.name }}
                                    </li>
                                    <button type="button" class="buttonNorm" @click="dependencyGrantAccess(d.dependencyID, stepID)">
                                        <img :src="libsPath + 'dynicons/svg/list-add.svg'" alt=""> Add Group
                                    </button>
                                </ul>
                                <div v-else>no groups</div>
                            </template>
                        </li>
                    </ul>
                    <button type="button" class="buttonNorm">Add maybe here</button>
                </div>
            </template>
            <!-- ADD Fieldset, Access outbound routes -->
            <template v-if="stepID !== 0">
                <fieldset>
                    <legend>Step Options</legend>
                    <label v-if="stepID > 0" :for="'workflowIndicator_' + stepID" style="margin:0 0 1.25rem 0;"> Form Field:
                        <select :id="'workflowIndicator_' + stepID">
                        </select>
                    </label>
                    <label for="toggleManageActions" style="margin:0;">
                        <input id="toggleManageActions" type="checkbox" style="margin:0;" v-model="viewStepActions">
                        &nbsp; View Step Actions
                    </label>
                    <div v-show="viewStepActions" id="manage_actions_options">
                        <ul id="outbound_actions_list">
                            <li v-for="r in outboundRoutes" :key="'route_info_' + r.actionType">
                                {{ r.actionText }}
                                <button type="button" class="icon"
                                    :aria-label="'Manage events for action: ' + r.actionText + ', step ' + r.stepID"
                                    title="Manage Action Events"
                                    aria-label="Manage Action Events">
                                    <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="">
                                </button>
                                <button v-if="currentWorkflowID > 0 && r.stepID !== -1" type="button" class="icon"
                                    :aria-label="'Remove action: ' + r.actionText + ', step ' + r.stepID"
                                    title="Remove this action"
                                    aria-label="Remove Action">
                                    <img :src="libsPath + 'dynicons/svg/dialog-error.svg'" alt="">
                                </button>
                            </li>
                        </ul>
                        <template v-if="currentWorkflowID > 0">
                            <label for="create_route">Add Action:</label>
                            <select id="create_route" title="Choose a step to connect to" v-model="selectedNextID"
                                @change="addConnection">
                                <option value="">Choose Step to Connect to</option>
                                <option value="0">End</option>
                                <template v-if="stepID > 0">
                                    <option value="-1">Requestor</option>
                                    <option :value="stepID">Self</option>
                                </template>
                                <option v-for="o in stepRouteOptions" :key="'route_option_' + o.stepID" :value="o.stepID">
                                    {{ o.stepTitle }} (id#{{ o.stepID }})
                                </option>
                            </select>
                        </template>
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