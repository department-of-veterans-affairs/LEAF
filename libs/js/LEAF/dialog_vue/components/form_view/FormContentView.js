import FormViewController from "./FormViewController.js";

export default {
    data() {
        return {
            gridInstances: {},
        }
    },
    props: {
        orgchartPath: {
            type: String
        }
    },
    provide() {
        return {
            gridInstances: Vue.computed(() => this.gridInstances),
            updateGridInstances: this.updateGridInstances,
            orgchartPath: this.orgchartPath
        }
    },
    components: {
        FormViewController
    },
    inject: [
        'currCategoryID',
        'currSubformID',
        'currentCategorySelection',
        'appIsLoadingCategoryInfo',
        'editPropertiesClicked',
        'editPermissionsClicked',
        'gridInput'
    ],
    computed: {
        formName() {
            return XSSHelpers.stripAllTags(this.currentCategorySelection.categoryName) || 'Untitled';
        },
        formCatID() {
            return this.currentCategorySelection.categoryID;
        },
        categoryDescription() {
            return XSSHelpers.stripAllTags(this.currentCategorySelection.categoryDescription);
        },
        workflow() {
            return parseInt(this.currentCategorySelection.workflowID) === 0 ?
            `<span style="color: red">No workflow. Users will not be able to select this form.</span>` :
            `${this.currentCategorySelection.description} (ID #${this.currentCategorySelection.workflowID})`;
        },
        isSubForm(){
            return !this.currentCategorySelection.parentID === '';
        },
        isNeedToKnow(){
            return parseInt(this.currentCategorySelection.needToKnow) === 1;
        }
    },
    methods: {
        updateGridInstances(options, indicatorID, series) {
            const gridInput = new this.gridInput(options, indicatorID, series, '');
            this.gridInstances[indicatorID] = gridInput;
        }
    },
    template: `
        <!-- NOTE: TOP INFO PANEL -->
        <div id="edit-properties-panel">
            <div>
                <div :aria-label="currCategoryID" :title="'CategoryID: ' + currCategoryID"><b>{{formName}}</b></div>
                <div style="padding: 0.5em 0">{{categoryDescription}}</div>
                <span v-if="!isSubForm">Workflow: <b v-html="workflow"></b></span><br />
                <span v-if="!isSubForm">Need to Know mode: <b :style="{color: isNeedToKnow ? '#e00' : 'black'}">{{ isNeedToKnow ? 'On' : 'Off' }}</b></span>
            </div>

            <div style="flex: 0 0 140px;">
                <div tabindex="0" id="editFormData" class="buttonNorm"  
                    @click="editPropertiesClicked" @keyup.enter="editPropertiesClicked"
                    style="margin-bottom:0.5em;">Edit Properties</div>

                <div tabindex="0" id="editFormPermissions" class="buttonNorm"
                    @click="editPermissionsClicked" @keyup.enter="editPermissionsClicked">Edit Collaborators</div>
            </div>
            <div style="position: absolute; right: 4px; bottom: 4px" class="form-id-label">ID: {{currCategoryID}}
            <span v-if="currSubformID!==null">(subform {{currSubformID}})</span>
            </div>
        </div>

        <!-- NOTE: FORM AREA -->
        <div v-if="appIsLoadingCategoryInfo" style="border: 2px solid black; text-align: center; 
            font-size: 24px; font-weight: bold; padding: 16px;">
            Loading... 
            <img src="../images/largespinner.gif" alt="loading..." />
        </div>
        <template v-else>
        <form-view-controller></form-view-controller>
        </template>`
        
}