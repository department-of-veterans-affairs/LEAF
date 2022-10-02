import LeafFormDialog from "./components/LeafFormDialog.js";
import IndicatorEditing from "./components/dialog_content/IndicatorEditing.js";
import AdvancedOptionsDialog from "./components/dialog_content/AdvancedOptionsDialog.js";
import NewFormDialog from "./components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "./components/dialog_content/ImportFormDialog.js";
import FormHistoryDialog from "./components/dialog_content/FormHistoryDialog.js";
import StapleFormDialog from "./components/dialog_content/StapleFormDialog.js";
import ConfirmDeleteDialog from "./components/dialog_content/ConfirmDeleteDialog.js";

import ModFormMenu from "./components/ModFormMenu.js";
import CategoryCard from "./components/CategoryCard.js";
import FormViewController from "./components/form_view/FormViewController.js";

import RestoreFields from "./components/RestoreFields.js";
import './LEAF_FormEditor.scss';

export default {
    data() {
        return {
            APIroot: '../api/',
            CSRFToken: CSRFToken,
            dialogTitle: '',
            dialogFormContent: '',
            dialogContentIsComponent: false,
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            showFormDialog: false,
            //this sets the method associated with the save btn to the onSave method of the modal's current component
            formSaveFunction: ()=> {
                if(this.$refs[this.dialogFormContent]) {
                    this.$refs[this.dialogFormContent].onSave();
                } else { console.log('got something unexpected')}
            },
            isEditingModal: false,

            appIsLoadingCategoryList: true,
            appIsLoadingCategoryInfo: false,
            currCategoryID: null,          //null or string
            currSubformID: null,           //null or string
            currIndicatorID: null,         //null or number
            newIndicatorParentID: null,    //null or number
            categories: {},                //obj with keys for each catID, values an object with 'categories' and 'workflow' tables fields
            currentCategorySelection: {},  //current record from categories object
            ajaxFormByCategoryID: [],      //form tree with information about indicators for each node
            selectedFormNode: null,
            indicatorCountSwitch: true,    //TEST toggle to trigger form view controller remount if the total count changes
            selectedNodeIndicatorID: null,
            currentCategoryIsSensitive: false,
            currentCategoryIndicatorTotal: 0,
            ajaxSelectedCategoryStapled: [],
            ajaxWorkflowRecords: [],       //array of all 'workflows' table records
            ajaxIndicatorByID: {},         //'indicators' table record for a specific indicatorID
            orgSelectorClassesAdded: { group: false, position: false, employee: false },
            restoringFields: false        //TODO:?? there are a few pages that could be view here, page_views: [restoringFields: false, leafLibrary: false etc]
        }
    },
    provide() {
        return {
            CSRFToken: Vue.computed(() => this.CSRFToken),
            currCategoryID: Vue.computed(() => this.currCategoryID),
            currSubformID: Vue.computed(() => this.currSubformID),
            currIndicatorID: Vue.computed(() => this.currIndicatorID),
            newIndicatorParentID: Vue.computed(() => this.newIndicatorParentID),
            isEditingModal: Vue.computed(() => this.isEditingModal),
            ajaxIndicatorByID: Vue.computed(() => this.ajaxIndicatorByID),
            categories: Vue.computed(() => this.categories),
            currentCategorySelection: Vue.computed(() => this.currentCategorySelection),
            selectedNodeIndicatorID: Vue.computed(() => this.selectedNodeIndicatorID),
            selectedFormNode: Vue.computed(() => this.selectedFormNode),
            currentCategoryIsSensitive: Vue.computed(() => this.currentCategoryIsSensitive),
            currentCategoryIndicatorTotal: Vue.computed(() => this.currentCategoryIndicatorTotal),
            ajaxFormByCategoryID: Vue.computed(() => this.ajaxFormByCategoryID),
            appIsLoadingCategoryInfo: Vue.computed(() => this.appIsLoadingCategoryInfo),
            ajaxSelectedCategoryStapled: Vue.computed(() => this.ajaxSelectedCategoryStapled),
            ajaxWorkflowRecords: Vue.computed(() => this.ajaxWorkflowRecords),
            showFormDialog: Vue.computed(() => this.showFormDialog),
            dialogTitle: Vue.computed(() => this.dialogTitle),
            dialogFormContent: Vue.computed(() => this.dialogFormContent),
            dialogButtonText: Vue.computed(() => this.dialogButtonText),
            formSaveFunction: Vue.computed(() => this.formSaveFunction),
            restoringFields: Vue.computed(() => this.restoringFields),
            orgSelectorClassesAdded: Vue.computed(() => this.orgSelectorClassesAdded),
            //static values
            APIroot: this.APIroot,
            editPermissionsClicked: this.editPermissionsClicked,
            newQuestion: this.newQuestion,
            editQuestion: this.editQuestion,
            getStapledFormsByCurrentCategory: this.getStapledFormsByCurrentCategory,
            setCurrCategoryStaples: this.setCurrCategoryStaples,
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            selectNewCategory: this.selectNewCategory,
            selectNewFormNode: this.selectNewFormNode,
            updateCategoriesProperty: this.updateCategoriesProperty,
            addNewCategory: this.addNewCategory,
            closeFormDialog: this.closeFormDialog,
            openAdvancedOptionsDialog: this.openAdvancedOptionsDialog,
            openNewFormDialog: this.openNewFormDialog,
            openImportFormDialog: this.openImportFormDialog,
            openFormHistoryDialog: this.openFormHistoryDialog,
            openConfirmDeleteFormDialog: this.openConfirmDeleteFormDialog,
            openStapleFormsDialog: this.openStapleFormsDialog,
            addOrgSelector: this.addOrgSelector,
            truncateText: this.truncateText,
            showRestoreFields: this.showRestoreFields,
            toggleIndicatorCountSwitch: this.toggleIndicatorCountSwitch
        }
    },
    components: {
        LeafFormDialog,
        IndicatorEditing,
        AdvancedOptionsDialog,
        NewFormDialog,
        ImportFormDialog,
        FormHistoryDialog,
        StapleFormDialog,
        ConfirmDeleteDialog,
        ModFormMenu,
        CategoryCard,
        FormViewController,
        RestoreFields
    },
    beforeMount(){
        this.getCategoryListAll().then(res => {
            this.setCategories(res);
            this.appIsLoadingCategoryList = false;
        }).catch(err => console.log('error getting category list', err));

        this.getWorkflowRecords().then(res => {
            this.ajaxWorkflowRecords = res;
        }).catch(err => console.log('error getting workflow records', err));
    },
    computed: {
        activeCategories() {
            let active = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID==='' && parseInt(this.categories[c].workflowID)!==0) {
                    active.push({...this.categories[c]});
                }
            }
            return active;
        },
        inactiveCategories() {
            let inactive = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID==='' && parseInt(this.categories[c].workflowID)===0) {
                    inactive.push({...this.categories[c]});
                }
            }
            return inactive;
        }
    },
    methods: {
        truncateText(str, maxlength = 40, overflow = '...') {
            return str.length <= maxlength ? str : str.slice(0, maxlength) + overflow;
        },
        addOrgSelector(selectorType) {
            this.orgSelectorClassesAdded[selectorType] = true;
        },
        toggleIndicatorCountSwitch() {
            this.indicatorCountSwitch = !this.indicatorCountSwitch;
        },
        //DB GET
        getCategoryListAll() {
            this.appIsLoadingCategoryList = true;
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formStack/categoryList/all`,
                    success: (res)=> resolve(res),
                    error: (err)=> reject(err)
                });
            });
        },
        getWorkflowRecords() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}workflow`,
                    success: (res) => resolve(res),
                    error: (err) => reject(err)
                });
            });
        },
        getFormByCategoryID(catID = this.currCategoryID) {
            this.appIsLoadingCategoryInfo = true;
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}`,
                    success: (res)=> {
                        this.appIsLoadingCategoryInfo = false;
                        resolve(res)
                    },
                    error: (err)=> reject(err)
                });
            });
        },
        getStapledFormsByCurrentCategory(formID) {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formEditor/_${formID}/stapled`,
                    success: (res) => {
                        resolve(res);
                    },
                    error: (err) => reject(err)
                });
            });
        },
        getIndicatorByID(indID) { //get specific indicator info
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formEditor/indicator/${indID}`,
                    success: (res)=> resolve(res),
                    error: (err) => reject(err)
                });
            });
        },
        //local data
        setCategories(obj) {  //build categories object from getCatListAll res on success
            for(let i in obj) {
                this.categories[obj[i].categoryID] = obj[i];
            }
        },
        setCurrCategoryStaples(stapledForms) {
            this.ajaxSelectedCategoryStapled = stapledForms;
        },
        updateCategoriesProperty(catID, keyName, keyValue) {
            this.categories[catID][keyName] = keyValue;
            this.currentCategorySelection = this.categories[catID];
            console.log('updated curr cat selection', keyName, this.currentCategorySelection);
        },
        addNewCategory(catID, record = {}) {
            this.categories[catID] = record;
        },
        //categoryID of the form to select, whether it is a subform, indicatorID associated with the current selection in the form index 
        selectNewCategory(catID, isSubform = false, subnodeIndID = null) {
            console.log('selecting new form');
            this.restoringFields = false;  //nav from Restore Fields subview

            if(!isSubform) {
                console.log('setting new currCatID', catID);
                this.currCategoryID = catID; //set main form catID
                this.currSubformID = null;   //clear the subform ID
            } else {
                console.log('setting new subCatID', catID);
                this.currSubformID = catID;  //update the subformID, but keep the main form ID
            }
            console.log('RESET: currentCategorySelection, ajaxFormByCategoryID, staples, selectednode, nodeIndID, indicatorTotal');
            this.currentCategorySelection = {};
            this.ajaxFormByCategoryID = [];
            this.ajaxSelectedCategoryStapled = [];
            this.selectedFormNode = null;
            this.selectedNodeIndicatorID = null;
            this.currentCategoryIndicatorTotal = 0;

            vueData.formID = catID || ''; //NOTE: update of other vue app TODO: mv?
            document.getElementById('btn-vue-update-trigger').dispatchEvent(new Event("click"));

            //switch to specified record, get info for the newly selected form, update variable values
            if (catID !== null) {
                this.currentCategorySelection = { ...this.categories[catID]};
                this.selectedNodeIndicatorID = subnodeIndID;
                this.currentCategoryIsSensitive = false;

                this.getFormByCategoryID(catID).then(res => {
                    this.ajaxFormByCategoryID = res;
                    this.ajaxFormByCategoryID.forEach(section => {
                        this.currentCategoryIndicatorTotal = this.getIndicatorCountAndNodeSelection(section, this.currentCategoryIndicatorTotal);
                        if (this.currentCategoryIsSensitive === false) {
                            this.currentCategoryIsSensitive = this.checkSensitive(section);
                        }
                    });
                }).catch(err => console.log('error getting form info: ', err));

                const formID = this.currSubformID || this.currCategoryID;
                console.log('formID nodeID', formID, this.selectedNodeIndicatorID, this.currIndicatorID)
                this.getStapledFormsByCurrentCategory(formID).then(res => this.ajaxSelectedCategoryStapled = res);

            } else {  //nav to form card browser.
                this.appIsLoadingCategoryList = true;
                this.categories = {};

                this.getCategoryListAll().then(res => {
                    this.setCategories(res);
                    this.appIsLoadingCategoryList = false;
                }).catch(err => console.log('error getting category list', err));

                this.getWorkflowRecords().then(res => {
                    this.ajaxWorkflowRecords = res;
                }).catch(err => console.log('error getting workflow records', err));
            }
        },
        selectNewFormNode(event, node) {
            if (event.target.classList.contains('icon_move') || event.target.classList.contains('sub-menu-chevron')) {
                return //prevents enter/space activation from list item move and menu toggle buttons
            }
            this.selectedFormNode = node;
            this.selectedNodeIndicatorID = node?.indicatorID || null;
            console.log('setting form node and indID from list selection', this.selectedNodeIndicatorID)
        },
        editPermissionsClicked() {
            console.log('clicked edit Permissions');
        },
        editIndicatorPrivileges() {
            console.log('clicked edit privileges');
        },
        setCustomDialogTitle(htmlContent) {
            this.dialogTitle = htmlContent;
        },
        //takes comp name as string, eg 'edit-properties-dialog'
        //components must be registered to this app
        setFormDialogComponent(component) {
            this.dialogContentIsComponent = true;
            this.dialogFormContent = component;
        },
        setFormDialogHTML(htmlContent) {
            this.dialogContentIsComponent = false;
            this.dialogFormContent = htmlContent;
        },
        clearCustomDialog() {
            this.setCustomDialogTitle('');
            this.setFormDialogComponent('');
            this.setFormDialogHTML('');
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        closeFormDialog() {
            this.showFormDialog = false;
            this.clearCustomDialog();
        },
        openConfirmDeleteFormDialog() {
            this.setCustomDialogTitle('<h2>Delete this form</h2>');
            this.setFormDialogComponent('confirm-delete-dialog');
            this.dialogButtonText = {confirm: 'Yes', cancel: 'No'};
            this.showFormDialog = true;
        },
        openStapleFormsDialog() {
            this.setCustomDialogTitle('<h2>Staple Other Form</h2>');
            this.setFormDialogComponent('staple-form-dialog');
            this.showFormDialog = true;
        },
        openIndicatorEditing(indicatorID) { //gets passed the currentID on edit buttons, a parentID for subquestion buttons, and null for new form sections
            let title = ''
            if (this.currIndicatorID === null && indicatorID === null) { //not an existing indicator, nor a child of an existing indicator
                title = `<h2>Adding new question</h2>`;
            } else {
                title = this.currIndicatorID === parseInt(indicatorID) ? 
                `<h2>Editing indicator ${indicatorID}</h2>` : `<h2>Adding question to ${indicatorID}</h2>`;
            }
            this.setCustomDialogTitle(title);
            this.setFormDialogComponent('indicator-editing');
            this.showFormDialog = true;
        },
        openAdvancedOptionsDialog(indicatorID) {
            console.log('app called open Advanced with:', indicatorID);
            this.currIndicatorID = parseInt(indicatorID);
            this.getIndicatorByID(indicatorID).then(res => {
                this.ajaxIndicatorByID = res;
                this.setCustomDialogTitle(`<h2>Advanced Options for indicator ${indicatorID}</h2>`);
                this.setFormDialogComponent('advanced-options-dialog');
                this.showFormDialog = true;   
            }).catch(err => console.log('error getting indicator information', err));
        },
        openNewFormDialog() {
            const titleHTML = this.currCategoryID === null ? '<h2>New Form</h2>' : '<h2>New Internal Use Form</h2>';
            this.setCustomDialogTitle(titleHTML);
            this.setFormDialogComponent('new-form-dialog');
            this.showFormDialog = true; 
        },
        openImportFormDialog() {
            this.setCustomDialogTitle('<h2>Import Form</h2>');
            this.setFormDialogComponent('import-form-dialog');
            this.showFormDialog = true;  
        },
        openFormHistoryDialog() {
            this.setCustomDialogTitle(`<h2>Form History</h2>`);
            this.setFormDialogComponent('form-history-dialog');
            this.showFormDialog = true;
        },
        newQuestion(parentIndID) {
            this.currIndicatorID = null;
            this.newIndicatorParentID = parentIndID !== null ? parseInt(parentIndID) : null;
            this.isEditingModal = false;
            console.log('Adding new indicator.', 'currID should be null:', this.currIndicatorID, 
                'parentID (null for new sections):', this.newIndicatorParentID, 'FORM:', this.currCategoryID);
            this.openIndicatorEditing(parentIndID);
        },
        editQuestion(indicatorID, series) {
            this.currIndicatorID = parseInt(indicatorID);
            this.newIndicatorParentID = null;
            this.getIndicatorByID(indicatorID).then(res => {
                this.isEditingModal = true;
                this.ajaxIndicatorByID = res;
                this.openIndicatorEditing(indicatorID);
                console.log('app called editQuestion with:', indicatorID, series);
            }).catch(err => console.log('error getting indicator information', err));
        },
        checkSensitive(node, isSensitive = false) {
            if (parseInt(node.is_sensitive) === 1) {
                isSensitive = true;
            }
            if (isSensitive === false && node.child) {
                for (let c in node.child) {
                    isSensitive = this.checkSensitive(node.child[c], isSensitive);
                    if (isSensitive===true) break;
                }
            }
            return isSensitive;
        },
        getIndicatorCountAndNodeSelection(node = {}, count = 0) {
            count++;
            if (node.indicatorID===this.selectedNodeIndicatorID) {
                this.selectedFormNode = node;
                console.log('found updated node from stored node ID', this.selectedNodeIndicatorID, this.selectedFormNode)
            }
            if (node.child) {
                for (let c in node.child) {
                    count = this.getIndicatorCountAndNodeSelection(node.child[c], count);
                }
            }
            return count;
        },
        showRestoreFields() {
            this.restoringFields = true;
        }
    }
}