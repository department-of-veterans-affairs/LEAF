import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import HistoryDialog from "@/common/components/HistoryDialog.js";
import WorkflowActionDialog from "../components/dialog_content/WorkflowActionDialog";

import WorkflowMenu from "../components/workflow_editor_view/WorkflowMenu";
import WorkflowStepInfo from "../components/workflow_editor_view/WorkflowStepInfo";

import { nextTick, computed } from 'vue';

import '../LEAF_WorkflowEditor.scss';

export default {
    name: 'workflow-editor-view',
    components: {
        WorkflowMenu,
        WorkflowStepInfo,

        LeafFormDialog,
        HistoryDialog,
        WorkflowActionDialog,
    },
    data() {
        return {
            loading: true,

            firstWorkflowDescription: '',
            firstWorkflowID: 0,

            workflows: {},
            currentWorkflowID: null,

            steps: {},
            currentStepID: null,

            routes: [],

            jsPlumbInstance: null,
            endPoints: [],
            endpointOptions: {
                isSource: true,
                isTarget: true,
                endpoint: ["Rectangle", {cssClass: "workflowEndpoint"}],
                paintStyle: {width: 48, height: 48},
                maxConnections: -1
            },

            mock_action: {
                actionText: "mock action test",
                actionTextPasttense: "mock action tested",
                actionIcon: 'applications-graphics.svg',
                sort: 0,
                fillDependency: 1,
            },
            mock_isNew: false,
        }
    },
    inject: [
        'APIroot',
        'libsPath',
        'CSRFToken',
        'getSiteSettings',
        'isJSON',
        'siteSettings',

        'setDefaultAjaxResponseMessage',
        'updateChosenAttributes',

        'showFormDialog',
        'dialogFormContent',

        'openWorkflowActionDialog',
    ],
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getSiteSettings();
            vm.setDefaultAjaxResponseMessage();
        });
    },
    created() {
        this.loadWorkflowList();
    },
    mounted() {
        this.setupJSPlumb();
        this.updateChosen(
            "workflows",
            "workflows_label",
            "Select a Workflow",
            event => { this.currentWorkflowID = event.target.value }
        );
        document.addEventListener('mousedown', this.closeStep);
    },
    beforeUnmount() {
        document.removeEventListener('mousedown', this.closeStep);
    },
    provide() {
        return {
            workflows: computed(() => this.workflows),
            steps: computed(() => this.steps),
            currentWorkflowID: computed(() => this.currentWorkflowID),
            currentStep: computed(() => this.currentStep),

            newWorkflow: this.newWorkflow,
            createStep: this.createStep,
            renameWorkflow: this.renameWorkflow,
            duplicateWorkflow: this.duplicateWorkflow,
            listActions: this.listActions,
            listEvents: this.listEvents,
            deleteWorkflow:this.deleteWorkflow,
        }
    },
    computed: {
        hasWorkflows() {
            return Object.keys(this.workflows)?.length > 0;
        },
        workflowMaxY() {
            let max = 80;
            let stepY = null;
            for (let stepID in this.steps) {
                stepY = parseInt(this.steps[stepID].posY);
                if (stepY > max) {
                    max = stepY;
                }
            }
            return max;
        },
        workflowHeight() {
            return { height: 300 + this.workflowMaxY + 'px' };
        },
        requestorStepStyle() {
            return {
                left: 180 + 40 + 'px',
                top: 80 + 40 + 'px',
                backgroundColor: '#e0e0e0',
                fontWeight: 'normal',
            }
        },
        lastStepStyle() {
            return {
                left: 580 + 'px',
                top: 160 + this.workflowMaxY + 'px',
                backgroundColor: '#ff8181',
                fontWeight: 'normal',
            }
        },
        currentStep() {
            let returnValue = null;
            if (this.currentStepID > 0) {
                returnValue = this.steps?.[this.currentStepID] ?? null;
            } else {
                if (this.currentStepID !== null) {
                    returnValue = {
                        stepID: this.currentStepID
                    }
                }
            }
            return returnValue
        },

    },
    methods: {
        setupJSPlumb() {
            jsPlumb.ready(() => {
                this.jsPlumbInstance = jsPlumb.getInstance();
                this.jsPlumbInstance.Defaults.Container = "workflow";
                this.jsPlumbInstance.Defaults.ConnectionOverlays = [
                    [ "PlainArrow", { location:0.9, width:16, length:14 }],
                ];
                this.jsPlumbInstance.Defaults.PaintStyle = { stroke: 'lime', lineWidth: 1 };
                this.jsPlumbInstance.Defaults.Connector = ["StateMachine", {curviness: 10}];
                this.jsPlumbInstance.Defaults.Anchor = "Continuous";
                this.jsPlumbInstance.Defaults.Endpoint = "Blank";

            });
        },
        stepStyle(stepID = 0) {
            const minY = 80;
            const minX = 0;

            const step = this.steps[stepID];
            return {
                left: Math.max(parseInt(step.posX), minX) + 'px',
                top: Math.max(parseInt(step.posY), minY) + 'px',
                backgroundColor: step.stepBgColor,
                fontWeight: 'normal',
            }
        },
        updateChosen(selectID = '', selectLabelID = '', title = 'Select an Option', callback) {
            if(selectID !== '') {
                nextTick(() => {
                    $('#' + selectID).chosen('destroy');
                    $('#' + selectID).chosen({
                        disable_search_threshold: 5,
                        allow_single_deselect: true,
                    }).change(event => callback(event));

                    this.updateChosenAttributes(selectID, selectLabelID, title);
                });
            }
        },
        closeStep(event) {
            const stepInfoEl = document.querySelector('.workflowStepInfo');
            const closestInfo = event.target.closest('.workflowStepInfo');
            if(closestInfo !== stepInfoEl) {
                this.currentStepID = null;
            }
        },
        newWorkflow() {
            console.log("newWorkflow")
        },
        createStep() {
            console.log("createStep")
        },

        renameWorkflow() {

        },
        duplicateWorkflow() {

        },
        listActions() {

        },
        listEvents() {

        },
        deleteWorkflow() {

        },

        loadWorkflowList() {
            fetch(
                `${this.APIroot}workflow`
            ).then(res => res.json()).then(workflowArray => {
                // Don't show built-in workflows unless 'dev' exists as a GET parameter
                const isDevMode = this.$route.query?.dev !== undefined;

                let map = {};
                workflowArray.forEach(ele => {
                    if (ele.workflowID > 0 || isDevMode) {
                        map[ele.workflowID] = ele;
                    }
                });
                this.workflows = map;

                this.firstWorkflowDescription = workflowArray?.[0]?.description || "";
                this.firstWorkflowID = workflowArray?.[0]?.workflowID || 0;

                this.loading = false;

                const paramID = this.$route.query?.workflowID;
                if (paramID !== undefined && this.workflows[paramID] !== undefined) {
                    this.currentWorkflowID = paramID;
                } else {
                    this.currentWorkflowID = this.firstWorkflowID;
                }
            }).catch(err => console.log(err))
        },
        loadWorkflow() {
            this.endPoints = [];
            this.jsPlumbInstance.reset();
            this.jsPlumbInstance.setSuspendDrawing(true);

            Promise.all([
                fetch(`${this.APIroot}workflow/${this.currentWorkflowID}`),
                fetch(`${this.APIroot}workflow/${this.currentWorkflowID}/route`),
            ]).then(responses => {
                Promise.all([
                    responses[0].json(),
                    responses[1].json(),
                ]).then(results => {
                    this.steps = results[0];
                    this.routes = results[1];
                    console.log(this.steps, this.routes)
                    this.jsPlumbConfig();
                    this.drawRoutes();
                });
            }).catch(err => console.log(err));
        },
        jsPlumbConfig() {
            nextTick(() => {
                for (let stepID in this.steps) {
                    if (this.endPoints[stepID] == undefined) {
                        this.endPoints[stepID] = this.jsPlumbInstance.addEndpoint('step_' + stepID, {anchor: 'Continuous'}, this.endpointOptions);

                        this.jsPlumbInstance.draggable('step_' + stepID, {
                            allowNegative: false,
                            stop: () => {
                                const stepEl = document.getElementById(`step_${stepID}`);
                                if (stepEl !== null) {
                                    const left = stepEl.offsetLeft;
                                    const top = stepEl.offsetTop;
                                    this.updatePosition(stepID, left, top);
                                }
                            }
                        });
                    }
                }

                if (this.endPoints[-1] == undefined) {
                    this.endPoints[-1] = this.jsPlumbInstance.addEndpoint('step_-1', {anchor: 'Continuous'}, this.endpointOptions);
                    this.jsPlumbInstance.draggable('step_-1', { allowNegative: false });
                }
                if (this.endPoints[0] == undefined) {
                    this.endPoints[0] = this.jsPlumbInstance.addEndpoint('step_0', {anchor: 'Continuous'}, this.endpointOptions);
                    this.jsPlumbInstance.draggable('step_0', { allowNegative: false });
                }
            });
        },
        drawRoutes() {
            nextTick(() => {
                const locIncrement = 0.15;
                let loc = 0.5;
                let actionCounts = {};
                this.routes.forEach(r => {
                    loc = 0.5;
                    switch (r.actionType.toLowerCase()) {
                        case 'sendback':
                            loc = 0.30;
                            break;
                        case 'approve':
                        case 'concur':
                            loc = 0.5;
                            break;
                        case 'defer':
                            loc = 0.25;
                            break;
                        case 'disapprove':
                            loc = 0.75;
                            break;
                        default:
                            const from = String(r.stepID);
                            const to = String(r.nextStepID);
                            if(from !== to) {
                                const fromStepToStep = from + "_" + to;
                                if(actionCounts?.[fromStepToStep] >= 0) {
                                    actionCounts[fromStepToStep] += 1;
                                    loc = Math.min(
                                        +((0.05 + locIncrement * actionCounts[fromStepToStep]).toFixed(2)),
                                        0.65
                                    );
                                    if(loc >= 0.5) { //reserve 0.5 for 0 - keeps centered if only one route
                                        loc += locIncrement;
                                    }
                                } else {
                                    actionCounts[fromStepToStep] = 0;
                                }
                            }
                        break;
                    }

                    if (r.nextStepID === 0 && r.actionType == 'sendback') {
                        this.jsPlumbInstance.connect({
                            source: 'step_' + r.stepID,
                            target: 'step_-1',
                            paintStyle: {stroke: 'red'},
                            overlays: [
                                [
                                    "Label",
                                    {
                                        id: `stepLabel_${r.stepID}_0_${r.actionType}`,
                                        cssClass: `workflowAction action-${r.stepID}-sendback--1`,
                                        label: r.actionText,
                                        location: loc,
                                        parameters: {
                                            'stepID': r.stepID,
                                            'nextStepID': 0,
                                            'action': r.actionType,
                                        },
                                        events: {
                                            click: (overlay, evt) => {
                                                const params = overlay.getParameters();
                                                this.showActionInfo(params, evt);
                                            }
                                        }
                                    }
                                ],
                            ]
                        });

                    } else {
                        let lineOptions = {
                            source: 'step_' + r.stepID,
                            target: 'step_' + r.nextStepID,
                            connector: ["StateMachine", {curviness: 10}],
                            anchor: "Continuous",
                            overlays: [
                                [
                                    "Label",
                                    {
                                        id: 'stepLabel_' + r.stepID + '_' + r.nextStepID + '_' + r.actionType,
                                        cssClass: `workflowAction action-${r.stepID}-${r.actionType}-${r.nextStepID}`,
                                        label: r.actionText,
                                        location: loc,
                                        parameters: {
                                            'stepID': r.stepID,
                                            'nextStepID': r.nextStepID,
                                            'action': r.actionType,
                                        },
                                        events: {
                                            click: (overlay, evt) => {
                                                const params = overlay.getParameters();
                                                this.showActionInfo(params, evt);
                                            }
                                        }
                                    }
                                ]
                            ]
                        };
                        if (r.actionType == 'sendback') {
                            lineOptions.paintStyle = {stroke: 'red'};
                        }
                        this.jsPlumbInstance.connect(lineOptions);
                    }
                });

                // connect the initial step if it exists
                if (
                    typeof this.workflows[this.currentWorkflowID]?.initialStepID !== 'undefined' &&
                    this.workflows[this.currentWorkflowID]?.initialStepID !== 0
                ) {
                    const initialStepID = this.workflows[this.currentWorkflowID].initialStepID;
                    this.jsPlumbInstance.connect({
                        source: this.endPoints[-1],
                        target: this.endPoints[initialStepID],
                        connector: ["StateMachine", {curviness: 10}],
                        anchor: "Continuous",
                        overlays: [
                            [
                                "Label",
                                {
                                    id: 'stepLabel_0_' + initialStepID + '_submit',
                                    cssClass: `workflowAction action--1-submit-${initialStepID}`,
                                    label: 'Submit',
                                    location: loc,
                                    parameters: {
                                        'stepID': -1,
                                        'nextStepID': initialStepID,
                                        'action': 'submit',
                                    },
                                    events: {
                                        click: (overlay, evt) => {
                                            const params = overlay.getParameters();
                                            this.showActionInfo(params, evt);
                                        }
                                    }
                                }
                            ]
                        ]
                    });
                }

                // bind connection events
                this.jsPlumbInstance.bind(
                    "connection",
                    (jsPlumbParams) => createAction(jsPlumbParams)
                );
                this.jsPlumbInstance.setSuspendDrawing(false, true);

                let endpointEls = Array.from(document.querySelectorAll('.workflowEndpoint'));
                endpointEls.forEach(el => el.style.backgroundImage = `url(${this.libsPath}dynicons/svg/network-wired.svg)`);
            });
        },
        updatePosition(stepID, left, top) {
            let formData = new FormData();
            formData.append('CSRFToken', this.CSRFToken);
            formData.append('stepID', stepID);
            formData.append('x', left);
            formData.append('y', top);

            fetch(`${this.APIroot}workflow/${this.currentWorkflowID}/editorPosition`, {
                method: 'POST',
                body: formData
            }).catch(err => console.log(err));
        },
        showStepInfo(stepID = -1) {
            if (this.currentStepID === stepID) {
                this.currentStepID = null;
            } else {
                this.currentStepID = stepID;
                if (stepID !== 0) { //not a dropdown option
                    let inputEl = document.getElementById('workflow_steps');
                    if (inputEl !== null) {
                        inputEl.value = stepID;
                        inputEl.dispatchEvent(new Event('change'));
                        $("#workflow_steps").trigger('chosen:updated');
                    }
                } else {
                    console.log("end")
                }
            }
        },
        showActionInfo(jsPlumbParams, event) {
            console.log("show action info", jsPlumbParams, event)
        },
        createAction(jsPlumbParams) {
            console.log(jsPlumbParams);
        },
        emailNotificationIcon(stepID = 0) {
            let html = '';
            const step = this.steps?.[stepID];
            if (typeof step?.stepData === 'string' && this.isJSON(step.stepData)) {
                const stepParse = JSON.parse(step.stepData);
                if (stepParse.AutomatedEmailReminders?.AutomateEmailGroup?.toLowerCase() === 'true') {
                    const dayCount = stepParse.AutomatedEmailReminders.DaysSelected;
                    const dayText = ((dayCount > 1) ? 'Days' : 'Day');
                    html = `<img src="${this.libsPath}dynicons/svg/appointment.svg"
                        style="height:18px;width:18px;margin-bottom:-3px;"
                        alt="Email reminders will be sent after ${dayCount} ${dayText} of inactivity"
                        title="Email reminders will be sent after ${dayCount} ${dayText} of inactivity">`;
                }
            }
            return html
        },
    },
    watch: {
        currentWorkflowID(newVal, oldVal) {
            if(this.workflows[newVal] !== undefined) {
                this.loadWorkflow(newVal);
            }
        },
        workflows() {
            this.updateChosen(
                "workflows",
                "workflows_label",
                "Select a Workflow",
                event => { this.currentWorkflowID = +event.target.value }
            );
        },
        steps() {
            this.updateChosen(
                "workflow_steps",
                "steps_label",
                "Select a Step",
                event => { this.currentStepID = +event.target.value }
            );
        }
    },
    template: `<div v-if="loading" class="page_loading">
            Loading...
            <img src="../images/largespinner.gif" alt="" />
        </div>
        <div v-else>
            <!-- TODO: this should be assoc with nav -->
            <div v-if="siteSettings?.siteType==='national_subordinate'" id="subordinate_site_warning" style="padding: 0.5rem; margin: 0.5rem 0;" >
                <h3 style="margin: 0 0 0.5rem 0; color: #a00;">This is a Nationally Standardized Subordinate Site</h3>
                <span><b>Do not make modifications!</b> &nbsp;Synchronization problems will occur. &nbsp;Please contact your process POC if modifications need to be made.</span>
            </div>
            <section id="workflow_editor" v-if="hasWorkflows">
                <WorkflowMenu />

                <div id="workflow" :style="workflowHeight">
                    <WorkflowStepInfo />
                    <button type="button" class="workflowStep" id="step_-1" :style="requestorStepStyle"
                        aria-label="workflow step: Requestor"
                        aria-controls="stepInfo_-1"
                        :aria-expanded="currentStepID === -1"
                        @click="showStepInfo(-1)">
                        Requestor
                    </button>

                    <template v-for="s in steps" :key="'wf_step_' + s.stepID">
                        <button type="button" class="workflowStep" :id="'step_' + s.stepID" :style="stepStyle(s.stepID)"
                            :aria-label="'workflow step: ' + s.stepTitle"
                            :aria-controls="'stepInfo_' + s.stepID"
                            :aria-expanded="currentStepID === s.stepID"
                            @click="showStepInfo(s.stepID)">
                                {{ s.stepTitle }}&nbsp;<span v-if="typeof s?.stepData === 'string'" v-html="emailNotificationIcon(s.stepID)"></span>
                        </button>
                    </template>

                    <button type="button" class="workflowStep" id="step_0" :style="lastStepStyle"
                        aria-label="Workflow End"
                        aria-controls="stepInfo_0"
                        :aria-expanded="currentStepID === 0"
                        @click="showStepInfo(0)">
                            End
                    </button>
                </div>
            </section>

            <button type="button" @click="openWorkflowActionDialog(mock_action, mock_isNew)">MOCK Action</button>
            <label for="mocktest"><input id="mocktest" type="checkbox" v-model="mock_isNew"> is new action</label>
        </div>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>`
}