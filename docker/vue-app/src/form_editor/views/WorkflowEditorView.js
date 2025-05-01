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

            workflowMinHeight: 300,
            minEndStepPosY: 80,
            endStepDiffY: 160,
            endStepInitialX: 580,
            requestorStepInitialX: 220,
            requestorStepInitialY: 120,

            currentWorkflowID: null,
            currentStepID: null,

            workflowStepInfoType: '',

            firstWorkflowID: 1,
            workflowsList: [],
            workflows: {},

            steps: {},
            localSteps: {
                "-1": {
                    stepID: -1,
                    posX: null,
                    posY: null
                },
                "0": {
                    stepID: 0,
                    posX: null,
                    posY: null
                }
            },

            routes: [],

            jsPlumbInstance: null,
            currentJSPlumbParams: null,
            endPoints: {},
            endpointOptions: {
                isSource: true,
                isTarget: true,
                endpoint: [ "Rectangle", { cssClass: "workflowEndpoint" } ],
                paintStyle: { width: 48, height: 48 },
                maxConnections: -1
            },

            //NOTE: mock data
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
    mounted() {
        this.loadWorkflowList(); //here instead of in created hook for better chosen plugin handling
        this.setupJSPlumb();
        console.log("mounted", Date.now())
        document.addEventListener('mousedown', this.closeWorkflowStepInfo);
    },
    beforeUnmount() {
        document.removeEventListener('mousedown', this.closeWorkflowStepInfo);
    },
    provide() {
        return {
            currentWorkflowID: computed(() => this.currentWorkflowID),
            currentStep: computed(() => this.currentStep),

            workflows: computed(() => this.workflows),
            workflowsList: computed(() => this.workflowsList),
            steps: computed(() => this.steps),
            routes: computed(() => this.routes),

            workflowStepInfoType: computed(() => this.workflowStepInfoType),
            currentJSPlumbParams: computed(() => this.currentJSPlumbParams),

            newWorkflow: this.newWorkflow,
            createStep: this.createStep,
            renameWorkflow: this.renameWorkflow,
            duplicateWorkflow: this.duplicateWorkflow,
            listActions: this.listActions,
            listEvents: this.listEvents,
            deleteWorkflow:this.deleteWorkflow,

            closeWorkflowStepInfo: this.closeWorkflowStepInfo,
        }
    },
    computed: {
        /**
         * @returns current url workflowID value as int
         */
        routeQueryWorkflowID() {
            return +this.$route.query?.workflowID;
        },
        /**
         * @returns boolean, true if dev exists as a route param
         */
        hasRouteQueryDev() {
            return this.$route.query.dev !== undefined;
        },
        hasWorkflows() {
            return Object.keys(this.workflows)?.length > 0;
        },
        workflowMaxY() {
            let max = this.minEndStepPosY;
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
            return { height: this.workflowMinHeight + this.workflowMaxY + 'px' };
        },
        requestorStepStyle() {
            return {
                left: (this.localSteps[-1].posX || this.requestorStepInitialX) + 'px',
                top: (this.localSteps[-1].posY || this.requestorStepInitialY) + 'px',
                backgroundColor: '#e0e0e0',
                fontWeight: 'normal',
            }
        },
        lastStepStyle() {
            //set End posY locally once
            if(this.workflowMaxY > this.minEndStepPosY && this.localSteps[0].posY === null) {
                this.localSteps[0].posY = this.endStepDiffY + this.workflowMaxY;
            }
            return {
                left: (this.localSteps[0].posX || this.endStepInitialX) + 'px',
                top: this.localSteps[0].posY + 'px',
                backgroundColor: '#ff8181',
                fontWeight: 'normal',
            }
        },
        currentStep() {
            let returnValue = null;
            if (this.currentStepID > 0) {
                returnValue = this.steps?.[this.currentStepID] ?? null;
            } else {
                //0 and -1 are not in steps object
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
        getStepStyle(stepID = 0) {
            const minY = 80;
            const minX = 0;

            const step = this.localSteps[stepID] || this.steps[stepID];
            return step !== undefined ? {
                left: Math.max(parseInt(step.posX), minX) + 'px',
                top: Math.max(parseInt(step.posY), minY) + 'px',
                fontSize: step?.stepTitle?.length > 40 ? '90%' : '100%',
                backgroundColor: step.stepBgColor,
                fontWeight: 'normal',
            } : {};
        },

        //submenu methods tracked/provided here
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

        /**
         * fetch workflows once view is mounted, then update workflow editor
         * workflows, workflowList, firstWorkflowID, currentWorkflowID data.
         * Set loading to false once finished (initial mount only).
         */
        loadWorkflowList() {
            fetch(
                `${this.APIroot}workflow`
            ).then(res => res.json()).then(workflowArray => {
                // Don't show built-in workflows unless 'dev' exists as a GET parameter
                this.workflowsList = this.hasRouteQueryDev ?
                    workflowArray : workflowArray.filter(wf => wf.workflowID > 0);

                let map = {};
                workflowArray.forEach(ele => { map[ele.workflowID] = ele });
                this.workflows = map;

                this.firstWorkflowID = this.workflowsList?.[0]?.workflowID || 0;

                let wfID = this.routeQueryWorkflowID;
                if(
                    wfID === 0 ||
                    this.workflows[wfID] === undefined ||
                    (this.hasRouteQueryDev === false && wfID < 0)
                ) {
                    wfID = this.firstWorkflowID;
                }

                this.currentWorkflowID = wfID;
                this.loading = false;
            }).catch(err => console.log(err))
        },
        /**
         * update url query with current workflow being loaded
         * fetch workflow editor app steps and routes data, then update jsPlumb config and draw routes 
         */
        loadWorkflow() {
            if(this.routeQueryWorkflowID !== this.currentWorkflowID) {
                let query = { workflowID: this.currentWorkflowID };
                if(this.hasRouteQueryDev) {
                    query.dev = this.$route.query.dev;
                }
                this.$router.push({ path: 'workflows', query, });
            }
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

                    this.jsPlumbConfig();
                    this.drawRoutes();
                });
            }).catch(err => console.log(err));
        },
        jsPlumbConfig() {
            nextTick(() => {
                const makeStopHandler = (stepID) => () => {
                    const stepEl = document.getElementById(`step_${stepID}`);
                    if (stepEl !== null) {
                        const left = stepEl.offsetLeft;
                        const top = stepEl.offsetTop;
                        this.updateStepPosition(stepID, left, top);
                    }
                }
                this.endPoints = {};
                for (let stepID in this.steps) {
                    if (this.endPoints[stepID] == undefined) {
                        this.endPoints[stepID] = this.jsPlumbInstance.addEndpoint('step_' + stepID, {anchor: 'Continuous'}, this.endpointOptions);

                        this.jsPlumbInstance.draggable('step_' + stepID, {
                            allowNegative: false,
                            stop: makeStopHandler(+stepID)
                        });
                    }
                }

                if (this.endPoints[-1] == undefined) {
                    this.endPoints[-1] = this.jsPlumbInstance.addEndpoint('step_-1', {anchor: 'Continuous'}, this.endpointOptions);
                    this.jsPlumbInstance.draggable('step_-1', {
                        allowNegative: false,
                        stop: makeStopHandler(-1)
                    });
                }
                if (this.endPoints[0] == undefined) {
                    const endOptions = {
                        ...this.endpointOptions,
                        isSource: false,
                    };
                    this.endPoints[0] = this.jsPlumbInstance.addEndpoint('step_0', {anchor: 'Continuous'}, endOptions);
                    this.jsPlumbInstance.draggable('step_0', {
                        allowNegative: false,
                        stop: makeStopHandler(0)
                    });
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
                    (jsPlumbParams) => this.createAction(jsPlumbParams)
                );
                this.jsPlumbInstance.setSuspendDrawing(false, true);

                let endpointEls = Array.from(document.querySelectorAll('.workflowEndpoint'));
                endpointEls.forEach(el => el.style.backgroundImage = `url(${this.libsPath}dynicons/svg/network-wired.svg)`);
            });
        },
        /**
         * Update local position settings and save settings for non built-in steps
         * Update local position settings for built-in steps 
         * @param {number} stepID 
         * @param {number} left 
         * @param {number} top 
         */
        updateStepPosition(stepID, left, top) {
            if(stepID > 0) {
                let formData = new FormData();
                formData.append('CSRFToken', this.CSRFToken);
                formData.append('stepID', stepID);
                formData.append('x', left);
                formData.append('y', top);

                const intitialX = this.steps[stepID].posX;
                const intitialY = this.steps[stepID].posY;
                this.steps[stepID].posX = left;
                this.steps[stepID].posY = top;

                fetch(`${this.APIroot}workflow/${this.currentWorkflowID}/editorPosition`, {
                    method: 'POST',
                    body: formData
                }).catch(err => {
                    console.log("error saving step position", err)
                    this.steps[stepID].posX = intitialX;
                    this.steps[stepID].posY = intitialY;
                });

            //Requestor, End, and built-in step positions are not saved, but can be moved locally
            } else {
                if (Number.isInteger(stepID) && this.localSteps?.[stepID] === undefined) {
                    const { stepID:newLocalID, posX, posY, stepBgColor } = this.steps[stepID];
                    this.localSteps[newLocalID] = { stepID:newLocalID, posX, posY, stepBgColor };
                }
                if(this.localSteps[stepID] !== undefined) {
                    this.localSteps[stepID].posX = left;
                    this.localSteps[stepID].posY = top;
                }
            }
        },
        /**
         * Update workflow editor workflowStepInfoType, currentJSPlumbParams, currentStepID data when a step is clicked
         * @param {number} stepID
         */
        showStepInfo(stepID = -1) {
            this.workflowStepInfoType = 'step';
            this.currentJSPlumbParams = null;
            if (this.currentStepID === stepID) { //close on second click
                this.currentStepID = null;
            } else {
                this.currentStepID = +stepID;
                let inputEl = document.getElementById('workflow_steps');
                if (inputEl !== null && inputEl.value !== stepID) {
                    inputEl.value = stepID;
                    $("#workflow_steps").trigger('chosen:updated');
                }
            }
        },
        /**
         * Update workflow editor workflowStepInfoType, currentJSPlumbParams, currentStepID data when an action bubble is clicked.
         * @param {object} jsPlumbParams sent through jsPlumb click event
         * @param {object} event associated event
         */
        showActionInfo(jsPlumbParams, event) {
            this.workflowStepInfoType = 'action';
            this.currentStepID = null;
            this.currentJSPlumbParams = {
                ...jsPlumbParams,
                pageX: event?.pageX ?? 200,
                pageY: event?.pageY ?? 300,
                mediatingStep: event?.detail?.mediatingStep ?? null,
            };
        },
        /**
         * Closes submenu that displays step and action info.
         * Close is either explicit or determined by whether click occurred outside an open submenu.
         * @param {object} event document mousedown, modal keydown.escape, modal close button click
         * @param {boolean} closeMenu true if explicitly closed (close button, escape)
         */
        closeWorkflowStepInfo(event, closeMenu = false) {
            if (closeMenu === false) {
                const stepInfoEl = document.querySelector('.workflowStepInfo');
                const closestInfo = event.target.closest('.workflowStepInfo');
                closeMenu = closestInfo !== stepInfoEl;
            }
            if (closeMenu === true) {
                this.currentStepID = null;
                this.currentJSPlumbParams = null;
                this.workflowStepInfoType = '';
            }
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
        routeQueryWorkflowID(newVal, oldVal) {
            console.log("route wfID changed, updating select value", newVal, oldVal)
            let inputEl = document.getElementById('workflows');
            if (inputEl !== null && inputEl.value !== newVal) {
                inputEl.value = newVal;
                inputEl.dispatchEvent(new Event('change'));
                $("#workflows").trigger('chosen:updated');
            }
        },
        hasRouteQueryDev(newVal, oldVal) {
            console.log("dev param changed, refetching wfs")
            this.loadWorkflowList();
        },
        currentWorkflowID() {
            //reset local positions of requestor and end steps, close submenu
            this.localSteps[-1].posX = null;
            this.localSteps[-1].posY = null;
            this.localSteps[0].posX = null;
            this.localSteps[0].posY = null;
            this.closeWorkflowStepInfo({}, true);
            if(this.workflows[this.currentWorkflowID] !== undefined) {
                this.loadWorkflow();
            } else {
                this.currentWorkflowID = this.firstWorkflowID;
            }
        },
        workflows(newVal, oldVal) {
            console.log("wfs changed, update chosen options", newVal, oldVal, Date.now())
            this.updateChosen(
                "workflows",
                "workflows_label",
                "Select a Workflow",
                event => {
                    console.log('wf selection triggered wfID update')
                    this.currentWorkflowID = +event.target.value;
                }
            );
        },
        steps(newVal, oldVal) {
            console.log("steps changed, update chosen options", newVal, oldVal)
            this.updateChosen(
                "workflow_steps",
                "steps_label",
                "Select a Step",
                event => {
                    console.log('step election triggered stepID and info type update')
                    this.workflowStepInfoType = 'step';
                    this.currentStepID = +event.target.value
                }
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
                    <template v-if="currentStepID !== null || currentJSPlumbParams !== null">
                        <WorkflowStepInfo :key="'step_info_' + currentStepID" />
                    </template>
                    <button type="button" class="workflowStep" id="step_-1" :style="requestorStepStyle"
                        aria-label="workflow step: Requestor"
                        aria-controls="stepInfo_-1"
                        :aria-expanded="currentStepID === -1"
                        @click="showStepInfo(-1)">
                        Requestor
                    </button>

                    <template v-for="s in steps" :key="'wf_step_' + s.stepID">
                        <button type="button" class="workflowStep" :id="'step_' + s.stepID" :style="getStepStyle(s.stepID)"
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