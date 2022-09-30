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
        'editPropertiesClicked',
        'editPermissionsClicked'
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
            this.gridInstances[indicatorID] = new gridInput(options, indicatorID, series, ''); //NOTE: global LEAF class for grid format
        }
    },
    template: `<div id="form_content_view">
        <!-- NOTE: TOP INFO PANEL -->
        <div id="edit-properties-panel">
            <div>
                <h3 :aria-label="currCategoryID" :title="'CategoryID: ' + currCategoryID">{{formName}}</h3>
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
            <div class="form-id-label">ID: {{currCategoryID}}
            <span v-if="currSubformID!==null">(subform {{currSubformID}})</span>
            </div>
        </div>

        <form-view-controller></form-view-controller>
    </div>` 
        
}