import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import { nextTick } from 'vue';

import '../LEAF_WorkflowEditor.scss';

export default {
    name: 'workflow-editor-view',
    components: {
        LeafFormDialog,
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

            routes: {},
            endPoints: [],
            endpointOptions: {
                isSource: true,
                isTarget: true,
                endpoint: ["Rectangle", {cssClass: "workflowEndpoint"}],
                paintStyle: {width: 48, height: 48},
                maxConnections: -1
            },
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
    },
    updated() {
        console.log("updated")
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
        selectedWorkflowDescription() {
            return this.workflows[this.currentWorkflowID]?.description ?? "";
        },
        selectedWorkflowAria() {
            return this.selectedWorkflowDescription + 'is selected.';
        },
        selectedStepAria() {
            return 'TODO:' + 'is selected.';
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
    },
    methods: {
        setupJSPlumb() {
            jsPlumb.Defaults.Container = "workflow";
            jsPlumb.Defaults.ConnectionOverlays = [["PlainArrow", {location:0.9, width:20, length:12}]];
            jsPlumb.Defaults.PaintStyle = {stroke: 'lime', lineWidth: 1};
            jsPlumb.Defaults.Connector = ["StateMachine", {curviness: 10}];
            jsPlumb.Defaults.Anchor = "Continuous";
            jsPlumb.Defaults.Endpoint = "Blank";
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
        newWorkflow() {
            console.log("newWorkflow")
        },
        createStep() {
            console.log("createStep")
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
            jsPlumb.reset();
            jsPlumb.setSuspendDrawing(true);

            fetch(
                `${this.APIroot}workflow/${this.currentWorkflowID}`
            ).then(res => res.json()).then(workflowSteps => {
                this.steps = workflowSteps;
                this.jsPlumbConfig();

            }).catch(err => console.log(err));
        },
        jsPlumbConfig() {
            nextTick(() => {
                for (let stepID in this.steps) {
                    if (this.endPoints[stepID] == undefined) {
                        this.endPoints[stepID] = jsPlumb.addEndpoint('step_' + stepID, {anchor: 'Continuous'}, this.endpointOptions);

                        jsPlumb.draggable('step_' + stepID, {
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
                    this.endPoints[-1] = jsPlumb.addEndpoint('step_-1', {anchor: 'Continuous'}, this.endpointOptions);
                    jsPlumb.draggable('step_-1', { allowNegative: false });
                }
                if (this.endPoints[0] == undefined) {
                    this.endPoints[0] = jsPlumb.addEndpoint('step_0', {anchor: 'Continuous'}, this.endpointOptions);
                    jsPlumb.draggable('step_0', { allowNegative: false });
                }
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
            console.log("show step info", stepID)
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
        }
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
                event => { this.currentWorkflowID = event.target.value }
            );
        },
        steps() {
            this.updateChosen(
                "workflow_steps",
                "steps_label",
                "Select a Step",
                event => { this.currentStepID = event.target.value }
            );
        }
    },
    template: `<div v-if="loading" class="page_loading">
            Loading...
            <img src="../images/largespinner.gif" alt="" />
        </div>
        <div v-show="!loading">
            <!-- TODO: this should be assoc with nav -->
            <div v-if="siteSettings?.siteType==='national_subordinate'" id="subordinate_site_warning" style="padding: 0.5rem; margin: 0.5rem 0;" >
                <h3 style="margin: 0 0 0.5rem 0; color: #a00;">This is a Nationally Standardized Subordinate Site</h3>
                <span><b>Do not make modifications!</b> &nbsp;Synchronization problems will occur. &nbsp;Please contact your process POC if modifications need to be made.</span>
            </div>
            <section id="workflow_editor" v-show="hasWorkflows">
                <div id="sideBar">
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
                        <button type="button" id="btn_newWorkflow" class="buttonNorm" @click="newWorkflow();">
                            <img :src="libsPath + 'dynicons/svg/list-add.svg'" alt=""> New Workflow
                        </button>
                    </div>
                    <div>
                        <label id="steps_label" for="workflow_steps">Workflow Steps:</label>
                        <div id="stepList">
                            <span id="step_select_status" role="status" aria-live="polite" :aria-label="selectedStepAria"></span>
                            <select id="workflow_steps" title="Select a Workflow Step to edit it">
                                <option>Choose a step to edit</option>
                                <option value="-1">Requestor</option>
                                <option v-for="s in steps" :key="'workflow_steps_' + s.stepID" :value="s.stepID">
                                    {{ s.stepTitle }} (#{{ s.stepID }})
                                </option>
                            </select>
                        </div>
                        <button type="button" id="btn_createStep" class="buttonNorm" @click="createStep();">
                            <img :src="libsPath + 'dynicons/svg/list-add.svg'" alt=""> New Step
                        </button>
                    </div>
                    <hr>
                </div> <!-- END SIDEBAR -->

                <div id="workflow" :style="workflowHeight">
                    <button type="button" class="workflowStep" id="step_-1" :style="requestorStepStyle"
                        aria-label="workflow step: Requestor"
                        aria-controls="stepInfo_-1"
                        aria-expanded="false"
                        @click="showStepInfo(-1)">
                        Requestor
                    </button>
                    <div class="workflowStepInfo" id="stepInfo_-1"></div>

                    <template v-for="s in steps" :key="'wf_step_' + s.stepID">
                        <button type="button" class="workflowStep" :id="'step_' + s.stepID" :style="stepStyle(s.stepID)"
                            :aria-label="'workflow step: ' + s.stepTitle"
                            :aria-controls="'stepInfo_' + s.stepID"
                            aria-expanded="false"
                            @click="showStepInfo(s.stepID)">
                                {{ s.stepTitle }}&nbsp;<span v-if="typeof s?.stepData === 'string'" v-html="emailNotificationIcon(s.stepID)"></span>
                        </button>
                        <div class="workflowStepInfo" :id="'stepInfo_' + s.stepID"></div>
                    </template>

                    <button type="button" class="workflowStep" id="step_0" :style="lastStepStyle"
                        aria-label="Workflow End"
                        aria-controls="stepInfo_0"
                        aria-expanded="false"
                        @click="showStepInfo(0)">
                            End
                    </button>
                    <div class="workflowStepInfo" id="stepInfo_0"></div>
                </div>
            </section>
            <p>{{ currentWorkflowID }}</p>
            <p>{{ selectedWorkflowDescription }}</p>
            <p>{{ steps }}</p>
            <p>{{ currentStepID }}</p>
            <p>{{ workflowMaxY }} {{ workflowHeight }} </p>
        </div>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>`
}