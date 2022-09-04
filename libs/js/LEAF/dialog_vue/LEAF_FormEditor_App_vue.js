import GenericDialog from "./components/GenericDialog.js";
import LeafFormDialog from "./components/LeafFormDialog.js";
import IndicatorEditing from "./components/IndicatorEditing.js";
import EditPropertiesDialog from "./components/EditPropertiesDialog.js"

import ModFormMenu from "./components/ModFormMenu.js";
import CategoryCard from "./components/CategoryCard.js";
import FormContent from "./components/FormContent.js";

import RestoreFields from "./components/RestoreFields.js";

export default {
    data() {
        return {
            APIroot: '../api/',
            CSRFToken: CSRFToken,
            dialogTitle: '',
            dialogFormContent: '',
            dialogContentIsComponent: false,
            showGeneralDialog: false,
            showFormDialog: false,
            //this sets the method associated with the save btn to the onSave method of the modal's current component
            formSaveFunction: ()=> {
                if(this.$refs[this.dialogFormContent]) {
                    this.$refs[this.dialogFormContent].onSave();
                } else { console.log('got something unexpected')}
            },
            isEditingModal: false,

            appIsLoadingCategoryList: true,
            currCategoryID: null,          //null or string
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
            currIndicatorID: Vue.computed(() => this.currIndicatorID),
            newIndicatorParentID: Vue.computed(() => this.newIndicatorParentID),
            isEditingModal: Vue.computed(() => this.isEditingModal),
            ajaxIndicatorByID: Vue.computed(() => this.ajaxIndicatorByID),
            categories: Vue.computed(() => this.categories),
            currentCategorySelection: Vue.computed(() => this.currentCategorySelection),
            currentCategoryIsSensitive: Vue.computed(() => this.currentCategoryIsSensitive),
            ajaxFormByCategoryID: Vue.computed(() => this.ajaxFormByCategoryID),
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
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            selectNewCategory: this.selectNewCategory,
            updateCategoriesProperty: this.updateCategoriesProperty,
            setCustomDialogTitle: this.setCustomDialogTitle,
            setFormDialogComponent: this.setFormDialogComponent,
            closeFormDialog: this.closeFormDialog,
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
    methods: {
        ifthenUpdateVueDataFormID(catID) {
            vueData.formID = catID;
            document.getElementById('btn-vue-update-trigger').dispatchEvent(new Event("click"));
        },
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
        getFormByCategory() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${this.currCategoryID}`,
                    success: (res)=> resolve(res),
                    error: (err)=> reject(err)
                });
            });
        },
        getStapledFormsByCategory() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formEditor/_${this.currCategoryID}/stapled`,
                    success: (res)=> resolve(res),
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
        updateCategoriesProperty(catID, keyName, keyValue) {
            this.categories[catID][keyName] = keyValue;
            this.currentCategorySelection = this.categories[catID];
            console.log('updated curr cat selection', keyName, this.currentCategorySelection);
        },
        selectNewCategory(catID) {
            console.log('selecting: ', catID !== null ? catID : 'nav to view all');
            this.restoringFields = false;
            this.currCategoryID = catID;
            console.log('clearing currentCategorySelection, ajaxFormByCategoryID, ajaxSelectedCategoryStapled');
            this.currentCategorySelection = {};
            this.ajaxFormByCategoryID = [];
            this.ajaxSelectedCategoryStapled = [];

            this.ifthenUpdateVueDataFormID(catID || '');

            //if user clicks a form card, switch to specified record and get info about the form
            if (catID !== null) { 
                this.currentCategorySelection = { ...this.categories[catID]};
                console.log('new category selected: ', this.currentCategorySelection);

                this.getFormByCategory().then(res => {
                    this.ajaxFormByCategoryID = res;
                    document.getElementById(this.currCategoryID).focus();
                    console.log('updated ajaxFormByCategoryID', res);
                }).catch(err => console.log('error getting form info: ', err));
                this.getStapledFormsByCategory().then(res=>{
                    this.ajaxSelectedCategoryStapled = res;
                    console.log('updated ajaxSelectedCategoryStapled', res);
                }).catch(err => console.log('error getting stapled forms: ', err));

            } else {  //nav to view all forms.  on live this recalls get categories
                this.appIsLoadingCategoryList = true;
                this.getCategoryListAll().then(res => {
                    this.setCategories(res);
                    console.log('updated categories');
                    this.appIsLoadingCategoryList = false;
                }).catch(err => console.log('error getting category list', err));
                this.getWorkflowRecords().then(res => {
                    console.log('udated workflow records info')
                    this.ajaxWorkflowRecords = res;
                }).catch(err => console.log('error getting workflow records', err));
            }
        },
        editPermissionsClicked() {
            console.log('clicked edit Permissions');
        },
        editPropertiesClicked() {
            this.closeFormDialog();
            console.log('clicked edit Properties, checking for updates');
            this.getFormByCategory(currCategoryID).then(res => {
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
        editIndicatorPrivileges(indicatorID) {
            console.log(indicatorID)
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
        clearCustomDialog(){
            this.setCustomDialogTitle('');
            this.setFormDialogComponent('');
            this.setFormDialogHTML('');
        },
        closeFormDialog() {
            this.showFormDialog = false;
            this.showGeneralDialog = false;
            this.clearCustomDialog();
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
        newQuestion(parentIndID) {
            this.currIndicatorID = null;
            this.newIndicatorParentID = parseInt(parentIndID);
            this.isEditingModal = false;
            this.openIndicatorEditing(parentIndID);
        },
        getForm(indicatorID, series) {
            this.currIndicatorID = parseInt(indicatorID);
            this.newIndicatorParentID = null;
            this.getIndicatorByID(indicatorID).then(res => {
                this.isEditingModal = true;
                this.ajaxIndicatorByID = res;
                this.openIndicatorEditing(indicatorID);
                console.log('app called getForm with:', indicatorID, series);
                console.log('app got indicator:', res);
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
        GenericDialog,
        LeafFormDialog,
        IndicatorEditing,
        ModFormMenu,
        CategoryCard,
        FormContent,
        EditPropertiesDialog,
        RestoreFields
    }
}