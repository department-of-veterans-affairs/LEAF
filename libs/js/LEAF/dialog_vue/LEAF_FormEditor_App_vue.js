import LeafFormDialog from "./components/LeafFormDialog.js";
import IndicatorEditing from "./components/dialog_content/IndicatorEditing.js";
import EditPropertiesDialog from "./components/dialog_content/EditPropertiesDialog.js";
import NewFormDialog from "./components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "./components/dialog_content/ImportFormDialog.js";
import FormHistoryDialog from "./components/dialog_content/FormHistoryDialog.js";
import StapleFormDialog from "./components/dialog_content/StapleFormDialog.js";

import ModFormMenu from "./components/ModFormMenu.js";
import CategoryCard from "./components/CategoryCard.js";
import FormContent from "./components/FormContent.js";

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
            currentCategoryIsSensitive: false,
            ajaxSelectedCategoryStapled: [],
            ajaxWorkflowRecords: [],       //array of all 'workflows' table records
            ajaxIndicatorByID: {},         //'indicators' table record for a specific indicatorID
            restoringFields: false,        //TODO:?? there are a few pages that could be view here, page_views: [restoringFields: false, leafLibrary: false etc]
            gridInput: gridInput,          //global LEAF class for grid format questions.
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
            currentCategoryIsSensitive: Vue.computed(() => this.currentCategoryIsSensitive),
            ajaxFormByCategoryID: Vue.computed(() => this.ajaxFormByCategoryID),
            appIsLoadingCategoryInfo: Vue.computed(() => this.appIsLoadingCategoryInfo),
            ajaxSelectedCategoryStapled: Vue.computed(() => this.ajaxSelectedCategoryStapled),
            ajaxWorkflowRecords: Vue.computed(() => this.ajaxWorkflowRecords),
            showFormDialog: Vue.computed(() => this.showFormDialog),
            dialogTitle: Vue.computed(() => this.dialogTitle),
            dialogFormContent: Vue.computed(() => this.dialogFormContent),
            formSaveFunction: Vue.computed(() => this.formSaveFunction),
            restoringFields: Vue.computed(() => this.restoringFields),
            //static values
            APIroot: this.APIroot,
            hasDevConsoleAccess: this.hasDevConsoleAccess,
            editPropertiesClicked: this.editPropertiesClicked,
            editPermissionsClicked: this.editPermissionsClicked,
            newQuestion: this.newQuestion,
            getForm: this.getForm,
            getStapledFormsByCurrentCategory: this.getStapledFormsByCurrentCategory,
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            selectNewCategory: this.selectNewCategory,
            updateCategoriesProperty: this.updateCategoriesProperty,
            addNewCategory: this.addNewCategory,
            closeFormDialog: this.closeFormDialog,
            openNewFormDialog: this.openNewFormDialog,
            openImportFormDialog: this.openImportFormDialog,
            openFormHistoryDialog: this.openFormHistoryDialog,
            openStapleFormsDialog: this.openStapleFormsDialog,
            truncateText: this.truncateText,
            showRestoreFields: this.showRestoreFields,
            gridInput: this.gridInput,   //global leaf class for grid formats
        }
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
        //general use methods
        truncateText(str, maxlength = 40, overflow = '...') {
            return str.length <= maxlength ? str : str.slice(0, maxlength) + overflow;
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
        getStapledFormsByCurrentCategory() {
            const formID = this.currSubformID || this.currCategoryID;
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}formEditor/_${formID}/stapled`,
                success: (res) => {
                    console.log('setting stapled forms', res);
                    this.ajaxSelectedCategoryStapled = res;
                },
                error: (err) => console.log(err)
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
        updateCategoriesProperty(catID, keyName, keyValue) {
            this.categories[catID][keyName] = keyValue;
            this.currentCategorySelection = this.categories[catID];
            console.log('updated curr cat selection', keyName, this.currentCategorySelection);
        },
        addNewCategory(catID, record = {}) {
            this.categories[catID] = record;
        },
        selectNewCategory(catID, isSubform = false) {
            console.log('selecting new form');
            this.restoringFields = false;  //on nav from Restore Fields

            if(!isSubform) { //also true on nav to View All, where catID will be null and the main form will reset
                console.log('setting new currCatID', catID);
                this.currCategoryID = catID;
                this.currSubformID = null;  //clear the subform ID whenever the main ID changes
            } else {
                console.log('setting new subCatID', catID);
                this.currSubformID = catID; //if it's an internal form, update the subformID, but keep the main form ID
            }
            this.currentCategorySelection = {};
            this.ajaxFormByCategoryID = [];
            this.ajaxSelectedCategoryStapled = [];

            vueData.formID = catID || ''; //NOTE: update of other vue app TODO: mv?
            document.getElementById('btn-vue-update-trigger').dispatchEvent(new Event("click"));

            //if user clicks a form card or internal, switch to specified record and get info about the form
            if (catID !== null) {
                this.currentCategorySelection = { ...this.categories[catID]};

                this.getFormByCategoryID(catID).then(res => {
                    this.ajaxFormByCategoryID = res;
                    document.getElementById(catID).focus();
                }).catch(err => console.log('error getting form info: ', err));

                this.getStapledFormsByCurrentCategory();

            } else {  //on nav to view all forms.
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
        editPermissionsClicked() {
            console.log('clicked edit Permissions');
        },
        editPropertiesClicked() {
            this.getFormByCategoryID(this.currSubformID || this.currCategoryID).then(res => {
                this.ajaxFormByCategoryID = res;
                this.currentCategoryIsSensitive = false;
                res.forEach(formSection => {
                    if (this.currentCategoryIsSensitive === false) {
                        this.currentCategoryIsSensitive = this.checkSensitive(formSection);
                    }
                });
                this.openEditProperties();
            }).catch(err => console.log('error updating category information', err));
        },
        editIndicatorPrivileges() {
            console.log('clicked edit privileges');
        },
        setCustomDialogTitle(htmlContent){
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
        },
        closeFormDialog() {
            this.showFormDialog = false;
            this.clearCustomDialog();
        },
        openStapleFormsDialog() {
            this.setCustomDialogTitle('<h2>Staple Other Form</h2>');
            this.setFormDialogComponent('staple-form-dialog');
            this.showFormDialog = true;
        },
        openIndicatorEditing(indicatorID) { //currentID for editing, parentID for new questions
            let title = ''
            if (this.currIndicatorID === null && indicatorID === null) {
                title = `<h2>Adding new question</h2>`;
            } else {
                title = this.currIndicatorID === parseInt(indicatorID) ? 
                `<h2>Editing indicator ${indicatorID}</h2>` : `<h2>Adding question to ${indicatorID}</h2>`;
            }
            this.setCustomDialogTitle(title);
            this.setFormDialogComponent('indicator-editing');
            this.showFormDialog = true;
        },
        openEditProperties() {
            this.setCustomDialogTitle('<h2>Edit Properties</h2>');
            this.setFormDialogComponent('edit-properties-dialog');
            this.showFormDialog = true;  
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
        getForm(indicatorID, series) {  //TODO: rename? this gets info for a specific existing question
            this.currIndicatorID = parseInt(indicatorID);
            this.newIndicatorParentID = null;
            this.getIndicatorByID(indicatorID).then(res => {
                this.isEditingModal = true;
                this.ajaxIndicatorByID = res;
                this.openIndicatorEditing(indicatorID);
                console.log('app called getForm with:', indicatorID, series);
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
        showRestoreFields() {
            this.restoringFields = true;
        }
    },
    components: {
        LeafFormDialog,
        IndicatorEditing,
        NewFormDialog,
        ImportFormDialog,
        FormHistoryDialog,
        StapleFormDialog,
        ModFormMenu,
        CategoryCard,
        FormContent,
        EditPropertiesDialog,
        RestoreFields
    }
}