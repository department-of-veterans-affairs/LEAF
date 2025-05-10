export default {
    name: 'workflow-step-info',
    data() {
        return {
            loadingDependencies: true,
            checkingModules: true,
            submenuElement: null,
            stepElement: null,

            stepTitleInput: this.currentStep?.stepTitle ?? '',
            selectedNextID: '',

            viewStepActions: false,
            stepDependencies: [],
            indicatorListAll: [],

            leafWorkflowIndicator: "",
        }
    },
    created() {
        if(this.workflowStepInfoType === 'step' && this.stepID !== 0) {
            this.getStepDependencies();
            this.getIndicatorList();
            this.checkForStepModules();
        }
    },
    mounted() {
        console.log("mounted step info")
        this.submenuElement = document.getElementById(this.menuID);
        this.stepElement = document.getElementById('step_' + this.stepID);
        this.setSubmenuPositions();
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'isJSON',
        'decodeAndStripHTML',
        'currentWorkflowID',
        'workflowStepInfoType',
        'currentStep',
        'currentJSPlumbParams',
        'steps',
        'routes',
        'workflowCategories',
        'createConnection',
        'updateWorkflowSteps',
        'closeWorkflowStepInfo',
        'openBasicConfirmDialog',
        'showFormDialog',
    ],
    computed: {
        openConfirm() {
            return this.showFormDialog === false;
        },
        isEditable() {
            return this.currentWorkflowID > 0;
        },
        isNotEnd() {
            return this.stepID !== 0;
        },
        isNotRequestor() {
            return this.stepID !== -1;
        },
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
                    const { actionText, actionIcon, actionType, stepID } = r;
                    routesArr.push( { actionText, actionIcon, actionType, stepID });
                }
                if(r.actionType === "submit") { //copied logic from mod_form - not sure it's ever here
                    hasSubmit = true;
                }
            });

            if(this.stepID === -1 && hasSubmit === false) {
                routesArr.push( { actionText: 'Submit', actionType: 'submit', actionIcon: '', stepID: -1 } );
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
        formfieldIndicatorList() {
            return this.indicatorListAll.filter(
                ind => ind.parentIndicatorID === null || ind.parentStaples !== null
            );
        },
        formfieldOptions() {
            let options = [];
            this.workflowCategories.forEach(entry => {
                this.formfieldIndicatorList.forEach(ind => {
                    if(
                        entry.categoryID === ind.categoryID ||
                        entry.categoryID === ind.parentCategoryID ||
                        (Array.isArray(ind.parentStaples) && ind.parentStaples.some(s => s === entry.categoryID))
                    ) {
                        options.push({ ...ind });
                    }
                });
            });
            return options;
        },
        dynamicApproverOptions() {
            return this.indicatorListAll.filter(
                ind => ind?.format === 'orgchart_employee' || ind?.format === 'raw_data'
            )
        },
        dynamicGroupApproverOptions() {
            return this.indicatorListAll.filter(
                ind => ind?.format === 'orgchart_group' || ind?.format === 'raw_data'
            )
        },
        emailNotificationHTML() {
            const stepData = this.currentStep?.stepData ?? '';
            let html = "";
            if (this.isJSON(stepData)) {
                const stepParse = JSON.parse(stepData);
                if (stepParse.AutomatedEmailReminders?.AutomateEmailGroup?.toLowerCase() === 'true') {
                    const dateSelected = stepParse.AutomatedEmailReminders?.DateSelected || '';
                    const dayCount = stepParse.AutomatedEmailReminders?.DaysSelected || '';
                    const additionalDays = stepParse.AutomatedEmailReminders?.AdditionalDaysSelected || '';
                    const dayText = ((+dayCount > 1) ? 'Days' : 'Day');
                    const followText = ((+additionalDays > 1) ? 'Days' : 'Day');
                    if (dayCount !== '') {
                        html = `<div>Email reminders will be sent after ${dayCount} ${dayText} of inactivity.</div>`
                    } else {
                        html = `<div>Email reminders will be sent starting on ${dateSelected}.</div>`
                    }
                    if (additionalDays !== '') {
                        html += `<div>Follow-up reminders will be sent after ${additionalDays} ${followText} of inactivity.</div>`;
                    }
                }
            }
            return html;
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
            if(this.submenuElement !== null) {
                if(this.workflowStepInfoType === 'step' && this.stepElement !== null) {
                    this.submenuElement.style.top = this.stepElement.offsetTop + this.stepElement.offsetHeight + 8 + 'px';
                    this.submenuElement.style.left = this.stepElement.offsetLeft + 'px';
                }
                if(this.workflowStepInfoType === 'action' && this.currentJSPlumbParams !== null) {
                    this.submenuElement.style.top = this.currentJSPlumbParams.pageY + 'px';
                    this.submenuElement.style.left = this.currentJSPlumbParams.pageX + 'px';
                }
                //adjust left location if off right of screen
                const rect = this.submenuElement.getBoundingClientRect();
                if(rect.right > window.innerWidth) {
                    const adjustedLeft = 16 + rect.right - window.innerWidth;
                    const currentLeft = parseInt(this.submenuElement.style.left);
                    this.submenuElement.style.left = currentLeft - adjustedLeft + 'px';
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
            .then(deps => {
                this.stepDependencies = deps;
                this.loadingDependencies = false;
            }).catch(err => console.log(err));
        },
        checkForStepModules() {
            if (Array.isArray(this.currentStep?.stepModules)) {
                this.currentStep.stepModules.forEach(m => {
                    if (m.moduleName == 'LEAF_workflow_indicator' && this.isJSON(m.moduleConfig)) {
                        const config = JSON.parse(m.moduleConfig);
                        this.leafWorkflowIndicator = config.indicatorID;
                    }
                });
            }
            this.checkingModules = false;
        },
        addConnection() {
            if(this.selectedNextID !== '') {
                this.createConnection(this.currentWorkflowID, this.stepID, +this.selectedNextID);
            }
        },
        getIndicatorList() {
            let categories = [];
            this.workflowCategories.forEach(c => categories.push(c.categoryID));
            const formList = categories.join(',');
            const xfilter = 'categoryID,categoryName,parentCategoryID,indicatorID,name,format,parentIndicatorID,parentStaples';

            fetch(`${this.APIroot}form/indicator/list?includeHeadings=1&forms=${formList}&x-filterData=${xfilter}`)
            .then(res => res.json())
            .then(data => {
                data.map(ind => {
                    ind.name = this.decodeAndStripHTML(ind.name);
                    if(ind.name?.length > 45) {
                        ind.name = ind.name.slice(0, 42) + '...';
                    }
                });
                this.indicatorListAll = data;
            }).catch(err => console.log(err));
        },
        postStepModule(stepID = '') {
            let formData = new FormData();
            formData.append('CSRFToken', this.CSRFToken);
            formData.append('indicatorID', this.leafWorkflowIndicator);

            fetch(`${this.APIroot}workflow/step/${stepID}/inlineIndicator`, {
                method: 'POST',
                body: formData
            }).then(res => res.json()).then(data => {
                if(+data !== 1) {
                    console.log("issue saving form field", data);
                } else {
                    this.updateWorkflowSteps();
                }
            }).catch(err => console.log(err));
        },
        updateStepTitle() {
            console.log("update title")
        },
        editRequirement() {
            console.log("edit requirement")
        },
        unlinkDependency(dependencyID = 0, dependencyDescription) {
            if (this.openConfirm) {
                this.openBasicConfirmDialog(
                    `<b>Remove Requirement:<br>${dependencyDescription}</b> from <b>Step ${this.stepID}</b>?`,
                    () => this.unlinkDependency(dependencyID)
                );
            } else {
                const p = `?CSRFToken=${this.CSRFToken}&workflowID=${this.currentWorkflowID}&dependencyID=${dependencyID}`
                fetch(`${this.APIroot}workflow/step/${this.stepID}/dependencies${p}`, {
                    method: 'DELETE'
                }).then(res => res.json()).then(data => {
                    if (+data === 1) {
                        this.stepDependencies = this.stepDependencies.filter(d => d.dependencyID !== dependencyID);
                    } else {
                        console.log(data);
                    }
                }).catch(err => console.log(err));
            }
        },

        setDynamicApprover(stepID) {
            console.log("set dynamic employee")
        },
        setDynamicGroupApprover(stepID) {
            console.log("set dynamic group")
        },
        dependencyGrantAccess(dependencyID, stepID) {

        },
        //TODO::
        openLinkDependencyDialog() {
            console.log("temp dialog method")
        },
        openEmailReminderDialog() {
            console.log("temp dialog method")
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
            <template v-if="isNotEnd">
                <template v-if="isNotRequestor">
                    <label for="step_title"> Step Title:
                        <input id="step_title" type="text" v-model="stepTitleInput" @change="updateStepTitle" :disabled="!isEditable">
                    </label>
                    <div v-if="!loadingDependencies">
                        <b>Requirements</b>
                        <ul id="step_requirements">
                            <li v-if="!uniqueStepDependencies?.length > 0" class="error_message">A requirement must be added.</li>
                            <li v-else v-for="d in uniqueStepDependencies" :key="'step_' + stepID + 'dep_' + d.dependencyID">
                                <!-- SMART REQUIREMENTS -->
                                <template v-if="smartRequirementIDs.includes(d.dependencyID)">
                                    <b style="color:green;vertical-align:middle;">{{ d.description }}</b>
                                    <template v-if="isEditable">
                                        <!-- service chief and quadrad -->
                                        <button v-if="d.dependencyID === 1 || d.dependencyID === 8" type="button" class="buttonNorm icon"
                                            @click="editRequirement(d.dependencyID, d.description, stepID)"
                                            title="Edit Requirement Name" aria-label="Edit Requirement Name">
                                            <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="">
                                        </button>
                                        <button type="button" class="buttonNorm icon"
                                            @click="unlinkDependency(d.dependencyID, d.description)"
                                            title="Remove Requirement" aria-label="Remove Requirement">
                                            <img :src="libsPath + 'dynicons/svg/dialog-error.svg'" alt="">
                                        </button>
                                    </template>
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
                                        <button v-if="isEditable" type="button" class="buttonNorm" @click="setDynamicApprover(stepID)">Set Data Field</button>
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
                                        <button v-if="isEditable" type="button" class="buttonNorm" @click="setDynamicGroupApprover(stepID)">Set Data Field</button>
                                    </template>
                                </template>
                                <!-- CUSTOM REQUIREMENTS -->
                                <template v-else>
                                    <b>{{ d.description }}</b>
                                    <template v-if="isEditable">
                                        <button type="button" class="buttonNorm icon"
                                            @click="editRequirement(d.dependencyID, d.description, stepID)"
                                            title="Edit Requirement Name" aria-label="Edit Requirement Name">
                                            <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="">
                                        </button>
                                        <button type="button" class="buttonNorm icon"
                                            @click="unlinkDependency(d.dependencyID, d.description)"
                                            title="Remove Requirement" aria-label="Remove Requirement">
                                            <img :src="libsPath + 'dynicons/svg/dialog-error.svg'" alt="">
                                        </button>
                                    </template>
                                    <ul :id="'step_' + stepID + '_dep' + d.dependencyID">
                                        <li v-if="!customRequirementGroupMap[d.dependencyID]?.length > 0" class="error_message">A group must be added.</li>
                                        <li v-else v-for="g in customRequirementGroupMap[d.dependencyID]"
                                            :key="'groups_' + d.dependencyID + '_' + g.groupID">
                                            {{ g.name }}
                                        </li>
                                        <button v-if="isEditable" type="button" class="buttonNorm" @click="dependencyGrantAccess(d.dependencyID, stepID)">
                                            <img :src="libsPath + 'dynicons/svg/list-add.svg'" alt=""> Add Group
                                        </button>
                                    </ul>
                                </template>
                            </li>
                        </ul>
                    </div>
                    <div v-else><b>Loading ... </b></div>
                </template>
                <!-- Formfield, Access outbound routes -->
                <fieldset>
                    <legend>Options</legend>
                    <label v-if="stepID > 0" :for="'workflowIndicator_' + stepID" style="margin:0 0 1.25rem 0;"> Form Field:
                        <select :id="'workflowIndicator_' + stepID" v-model="leafWorkflowIndicator" @change="postStepModule(stepID)" :disabled="!isEditable">
                            <option value="">None</option>
                            <option v-for="f in formfieldOptions"
                                :key="f.categoryID + '_' + f.indicatorID" :value="f.indicatorID">
                                {{ f.categoryName }}: {{ f.name }} (id: {{ f.indicatorID }})
                            </option>
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
                                <button v-if="isEditable" type="button" class="icon"
                                    :aria-label="'Manage events for action: ' + r.actionText + ', step ' + r.stepID"
                                    title="Manage Action Events"
                                    aria-label="Manage Action Events">
                                    <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" alt="">
                                </button>
                                <button v-if="isEditable && r.stepID !== -1" type="button" class="icon"
                                    :aria-label="'Remove action: ' + r.actionText + ', step ' + r.stepID"
                                    title="Remove this action"
                                    aria-label="Remove Action">
                                    <img :src="libsPath + 'dynicons/svg/dialog-error.svg'" alt="">
                                </button>
                            </li>
                        </ul>
                        <template v-if="isEditable">
                            <label for="create_route">Add Action:</label>
                            <select id="create_route" title="Choose a step to connect to" v-model="selectedNextID" @change="addConnection">
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
                <template v-if="isNotRequestor && isEditable">
                    <div v-if="emailNotificationHTML !== ''" v-html="emailNotificationHTML" id="email_reminder_html"></div>
                    <div id="addRequirement_addReminder">
                        <button type="button" class="buttonNorm" @click="openLinkDependencyDialog">Add Requirement</button>
                        <button type="button" id="step_email_reminder" class="buttonNorm"
                            @click="openEmailReminderDialog" @keydown.tab="tabControls($event, false)" ref="lastEl">
                            Email Reminder
                        </button>
                    </div>
                </template>
            </template>
         </div>

         <!-- ACTION submenu -->
         <div v-if="workflowStepInfoType === 'action' && currentJSPlumbParams !== null" id="stepInfo_content">
         </div>
    </div>`
}