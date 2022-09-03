import PrintFormAjax from "./PrintFormAjax.js";

export default {
    data() {
        return {
            gridInstances: {},
        }
    },
    provide() {
        return {
            gridInstances: Vue.computed(() => this.gridInstances),
            updateGridInstances: this.updateGridInstances
        }
    },
    components: {
        PrintFormAjax
    },
    inject: [
        'currCategoryID',
        'currentCategorySelection', 
        'editPropertiesClicked',
        'editPermissionsClicked',
        'ajaxFormByCategoryID',
        'gridInput'
    ],
    computed: {
        formTitle() {
            return this.currentCategorySelection.categoryName;
        },
        formCatID() {
            return this.currentCategorySelection.categoryID;
        },
        categoryDescription() {
            return this.currentCategorySelection.categoryDescription;
        },
        workflow() {
            return this.currentCategorySelection.workflowID === '0' ?
            `<span style="color: red">No workflow. Users will not be able to select this form.</span>` :
            `${this.currentCategorySelection.description} (ID #${this.currentCategorySelection.workflowID})`;
        },
        isSubForm(){
            return !this.currentCategorySelection.parentID == '';
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
        <div style="display: flex; justify-content: space-between; margin-bottom: 1em;
            background-color: white; padding: 8px; border: 1px solid black;">
            <div>
                <p><b :aria-label="formTitle" :title="'CategoryID: ' + currCategoryID">{{ formTitle }}</b> (ID# {{ formCatID }})</p>
                <p>{{ categoryDescription }}</p>
                <span v-if="!isSubForm">Workflow: <b v-html="workflow"></b></span><br />
                <span v-if="!isSubForm">Need to Know mode: <b>{{ currentCategorySelection.needToKnow == 1 ? 'On' : 'Off' }}</b></span>
            </div>

            <div style="flex: 0 0 140px;">
                <div tabindex="0" id="editFormData" class="buttonNorm"  
                    @click="editPropertiesClicked" @keyup.enter="editPropertiesClicked"
                    style="margin-bottom:0.5em;">Edit Properties</div>

                <div tabindex="0" id="editFormPermissions" class="buttonNorm" 
                    @click="editPermissionsClicked" @keyup.enter="editPermissionsClicked">Edit Collaborators</div>
            </div>
        </div>
        <!-- NOTE: FORM AREA -->
        <div id="formEditor_form" style="background-color: white;">
            <div v-if="ajaxFormByCategoryID.length === 0" style="border: 2px solid black; text-align: center; 
                font-size: 24px; font-weight: bold; padding: 16px;">
                Loading... 
                <img src="../images/largespinner.gif" alt="loading..." />
            </div>
            <template v-else>
            <print-form-ajax></print-form-ajax>
            </template>
        </div>`
}