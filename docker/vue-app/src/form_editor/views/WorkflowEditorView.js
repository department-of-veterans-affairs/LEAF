import LeafFormDialog from "@/common/components/LeafFormDialog.js";

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
    mounted() {
        this.setupJSPlumb();
        this.updateChosen(
            "workflows",
            "Select a Workflow",
            event => { this.currentWorkflowID = event.target.value }
        );
    },
    created() {
        this.loadWorkflowList();
    },
    computed: {
        hasWorkflows() {
            return Object.keys(this.workflows)?.length > 0;
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
                backgroundColor: '#e0e0e0'
            }
        }
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
        updateChosen(selectID = '', title = 'Select an Option', callback) {
            console.log("updating", selectID)
            if(selectID !== '') {
                setTimeout(() => { //finish running file for this plugin
                    $('#' + selectID).chosen('destroy');
                    $('#' + selectID).chosen({
                        disable_search_threshold: 5,
                        allow_single_deselect: true,
                    }).change(event => callback(event));

                    this.updateChosenAttributes(selectID, selectID + '_label', title);
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
            }).catch(err => console.log(err));
        },
        showStepInfo(stepID = -1) {
            console.log("show step info", stepID)
        }
    },
    watch: {
        currentWorkflowID(newVal, oldVal) {
            console.log("watching currentWorkflowID", newVal);
            if(this.workflows[newVal] !== undefined) {
                this.loadWorkflow(newVal);
            }
        },
        workflows(newVal, oldVal) {
            console.log("workflows changed")
            this.updateChosen(
                "workflows",
                "Select a Workflow",
                event => { this.currentWorkflowID = event.target.value }
            );
        },
        steps() {
            this.updateChosen(
                "workflow_steps",
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
                        <label id="workflow_steps_label" for="workflow_steps">Workflow Steps:</label>
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
                </div> <!-- END SIDEBAR -->

                <div id="workflow">
                    <button type="button" class="workflowStep" id="step_-1" :style="requestorStepStyle"
                        aria-label="workflow step: Requestor"
                        aria-controls="stepInfo_-1"
                        aria-expanded="false"
                        @click="showStepInfo(-1)">
                        Requestor
                    </button>
                </div>
            </section>
            <p>{{ currentWorkflowID }}</p>
            <p>{{ selectedWorkflowDescription }}</p>
            <p>{{ steps }}</p>
            <p>{{ currentStepID }}</p>
        </div>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>`
}