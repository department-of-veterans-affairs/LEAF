import { computed } from 'vue';

import LeafFormDialog from "./components/LeafFormDialog.js";
import IndicatorEditingDialog from "./components/dialog_content/IndicatorEditingDialog.js";
import AdvancedOptionsDialog from "./components/dialog_content/AdvancedOptionsDialog.js";
import NewFormDialog from "./components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "./components/dialog_content/ImportFormDialog.js";
import FormHistoryDialog from "./components/dialog_content/FormHistoryDialog.js";
import StapleFormDialog from "./components/dialog_content/StapleFormDialog.js";
import EditCollaboratorsDialog from "./components/dialog_content/EditCollaboratorsDialog.js";
import ConfirmDeleteDialog from "./components/dialog_content/ConfirmDeleteDialog.js";
import ConditionsEditorDialog from "./components/dialog_content/ConditionsEditorDialog.js";

import ModFormMenu from "./components/ModFormMenu.js";


import './LEAF_FormEditor.scss';
import './LEAF_IfThen.scss';

export default {
    data() {
        return {
            APIroot: '../api/',
            CSRFToken: CSRFToken,
            siteSettings: {},
            showCertificationStatus: false,
            dialogTitle: '',
            dialogFormContent: '',
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            showFormDialog: false,
            //this sets the method associated with the save btn of the current dialog modal to the onSave method of its current component
            formSaveFunction: ()=> {
                if(this.$refs[this.dialogFormContent]) {
                    this.$refs[this.dialogFormContent].onSave();
                } else { console.log('possible error setting modal save method')}
            },
            isEditingModal: false,

            appIsLoadingCategoryList: true,
            appIsLoadingForm: false,
            currCategoryID: null,          //null or string
            currSubformID: null,           //null or string
            currIndicatorID: null,         //null or number
            newIndicatorParentID: null,    //null or number
            categories: {},                //obj with keys for each catID, values an object with 'categories' and 'workflow' tables fields
            selectedFormTree: [],          //form tree with information about indicators for each node
            selectedFormNode: null,
            indicatorCountSwitch: true,    //toggled to trigger form view controller remount if an indicator is archived or deleted
            selectedNodeIndicatorID: null,
            currentCategoryIsSensitive: false,
            stapledFormsCatIDs: [],         //cat IDs of forms stapled to anything
            workflowRecords: [],            //array of all 'workflows' table records
            indicatorRecord: {},          //'indicators' table record for a specific indicatorID
            orgSelectorClassesAdded: { group: false, position: false, employee: false },
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
            currCategoryID: computed(() => this.currCategoryID),
            currSubformID: computed(() => this.currSubformID),
            currIndicatorID: computed(() => this.currIndicatorID),
            newIndicatorParentID: computed(() => this.newIndicatorParentID),
            isEditingModal: computed(() => this.isEditingModal),
            indicatorRecord: computed(() => this.indicatorRecord),
            categories: computed(() => this.categories),
            currentCategorySelection: computed(() => this.currentCategorySelection),
            selectedNodeIndicatorID: computed(() => this.selectedNodeIndicatorID),
            selectedFormNode: computed(() => this.selectedFormNode),
            currentCategoryIsSensitive: computed(() => this.currentCategoryIsSensitive),
            selectedFormTree: computed(() => this.selectedFormTree),
            appIsLoadingForm: computed(() => this.appIsLoadingForm),
            appIsLoadingCategoryList: computed(() => this.appIsLoadingCategoryList),
            activeCategories: computed(() => this.activeCategories),
            inactiveCategories: computed(() => this.inactiveCategories),
            showCertificationStatus: computed(() => this.showCertificationStatus),
            selectedCategoryStapledForms: computed(() => this.selectedCategoryStapledForms),
            stapledFormsCatIDs: computed(() => this.stapledFormsCatIDs),
            workflowRecords: computed(() => this.workflowRecords),
            showFormDialog: computed(() => this.showFormDialog),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            formSaveFunction: computed(() => this.formSaveFunction),
            orgSelectorClassesAdded: computed(() => this.orgSelectorClassesAdded),
            internalForms: computed(() => this.internalForms),
            //static values
            APIroot: this.APIroot,
            newQuestion: this.newQuestion,
            editQuestion: this.editQuestion,
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            selectNewCategory: this.selectNewCategory,
            selectNewFormNode: this.selectNewFormNode,
            updateCategoriesProperty: this.updateCategoriesProperty,
            updateStapledFormsInfo: this.updateStapledFormsInfo,
            addNewCategory: this.addNewCategory,
            closeFormDialog: this.closeFormDialog,
            openAdvancedOptionsDialog: this.openAdvancedOptionsDialog,
            openNewFormDialog: this.openNewFormDialog,
            openImportFormDialog: this.openImportFormDialog,
            openFormHistoryDialog: this.openFormHistoryDialog,
            openConfirmDeleteFormDialog: this.openConfirmDeleteFormDialog,
            openStapleFormsDialog: this.openStapleFormsDialog,
            openEditCollaboratorsDialog: this.openEditCollaboratorsDialog,
            openIfThenDialog: this.openIfThenDialog,
            addOrgSelector: this.addOrgSelector,
            truncateText: this.truncateText,
            stripAndDecodeHTML: this.stripAndDecodeHTML,
            toggleIndicatorCountSwitch: this.toggleIndicatorCountSwitch
        }
    },
    components: {
        LeafFormDialog,
        IndicatorEditingDialog,
        AdvancedOptionsDialog,
        NewFormDialog,
        ImportFormDialog,
        FormHistoryDialog,
        StapleFormDialog,
        EditCollaboratorsDialog,
        ConfirmDeleteDialog,
        ConditionsEditorDialog,
        ModFormMenu,
    },
    beforeMount() {
        this.getCategoryListAll().then(() => {
            if(this.$route.name === 'category' && this.$route.query.formID) {
                console.log('category route and formID query found, getting from query')
                this.getFormFromQueryParam();
            }
        }).catch(err => console.log('error getting category list', err));

        this.getWorkflowRecords();
    },
    mounted() {
        console.log('mounted app')
        this.getSiteSettings().then(res => {
            this.siteSettings = res;
            if(res.siteType === 'national_subordinate') {
                document.getElementById('subordinate_site_warning').style.display = 'block';
            }
            if (res.leafSecure >= 1) {
                this.getSecureFormsInfo();
            }
        }).catch(err => console.log('error getting site settings', err));
    },
    watch: {
        "$route.query.formID"(newVal = '', oldVal = '') {
            if(this.$route.name === 'category' && this.$route.query.formID && oldVal !== '') {
                this.getFormFromQueryParam();
            }
        }
    },
    computed: {
        /**
         * @returns {Object} current record from categories object (main or internal forms)
         */
        currentCategorySelection() {
            const formID = this.currSubformID || this.currCategoryID;
            return formID !== null ? this.categories[formID] : {};
        },
        /**
         * 
         * @returns {array} of categories object records
         */
        activeCategories() {
            let active = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID === '' && parseInt(this.categories[c].workflowID) !== 0) {
                    active.push({...this.categories[c]});
                }
            }
            return active;
        },
        /**
         * 
         * @returns {array} of categories object records
         */
        inactiveCategories() {
            let inactive = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID === '' && parseInt(this.categories[c].workflowID) === 0) {
                    inactive.push({...this.categories[c]});
                }
            }
            return inactive;
        },
        /**
         * 
         * @returns {array} of internal forms associated with the main form
         */
        internalForms() {
            let internalForms = [];
            for(let c in this.categories) {
                if (this.categories[c].parentID === this.currCategoryID) {
                    const internal = {...this.categories[c]};
                    internalForms.push(internal);
                }
            }
            return internalForms;
        },
        selectedCategoryStapledForms() {
            let staples = [];
            if (Object.keys(this.currentCategorySelection).length > 0) {
                this.currentCategorySelection.stapledFormIDs.forEach(id => {
                    staples.push({...this.categories[id]});
                });
            }
            return staples;
        }
    },
    methods: {
        truncateText(str='', maxlength = 40, overflow = '...') {
            return str.length <= maxlength ? str : str.slice(0, maxlength) + overflow;
        },
        /**
         * 
         * @param {string} content 
         * @returns string with tags removed and remaining characers decoded
         */
        stripAndDecodeHTML(content='') {
            const elDiv = document.createElement('div');
            elDiv.innerHTML = content;
            const text = XSSHelpers.stripAllTags(elDiv.innerText);
            return text;
        },
        /**
         * used to track whether js code and styles for orgchart formats have been downloaded from the nexus
         * @param {string} selectorType group, employee, position
         */
        addOrgSelector(selectorType = '') {
            this.orgSelectorClassesAdded[selectorType] = true;
        },
        /**
         * used to force rerender of the form view controller component
         */
        toggleIndicatorCountSwitch() {
            this.indicatorCountSwitch = !this.indicatorCountSwitch;
        },
        /**
         * 
         * @returns {array} of objects with all fields from categories and workflow tables for enabled forms
         */
        getCategoryListAll() {
            this.appIsLoadingCategoryList = true;
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formStack/categoryList/allWithStaples`,
                    success: (res)=> {
                        console.log('updated categories');
                        for(let i in res) {
                            this.categories[res[i].categoryID] = res[i];
                            res[i].stapledFormIDs.forEach(id => {
                                if (!this.stapledFormsCatIDs.includes(id)) {
                                    this.stapledFormsCatIDs.push(id);
                                }
                            });
                        }
                        this.appIsLoadingCategoryList = false;
                        resolve(res);
                    },
                    error: (err)=> reject(err)
                });
            });
        },
        getFormFromQueryParam() {
            const formReg = /^form_[0-9a-f]{5}$/i;
            const formID = formReg.test(this.$route.query?.formID || '') ? this.$route.query.formID : null;
            console.log('got form id from query param', formID)
            if (formID === null || this.categories[formID] === undefined) {
                this.selectNewCategory(null);
                console.log('form does not exist');
                //TODO: form not found status message
            } else {
                const isSubform = this.categories[formID].parentID !== '';
                this.selectNewCategory(formID, isSubform, null);
            }
        },
        /**
         * 
         * @returns {array} of objects with all fields from the workflows table
         */
        getWorkflowRecords() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}workflow`,
                    success: (res) => {
                        this.workflowRecords = res;
                        resolve(res);
                    },
                    error: (err) => reject(err)
                });
            });
        },
        /**
         * 
         * @returns {Object} of all records from the portal's settings table
         */
        getSiteSettings() {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}system/settings`,
                    success: (res) => resolve(res),
                    error: (err) => reject(err),
                    cache: false
                })
            });
        },
        /**
         * 
         * @param {boolean} searchResolved 
         * @returns {Object} of LEAF Secure Certification requests
         */
        fetchLEAFSRequests(searchResolved = false) {
            return new Promise((resolve, reject)=> {
                let query = new LeafFormQuery();
                query.setRootURL('../');
                query.addTerm('categoryID', '=', 'leaf_secure');
            
                if (searchResolved === true) {
                    query.addTerm('stepID', '=', 'resolved');
                    query.join('recordResolutionData');
                } else {
                    query.addTerm('stepID', '!=', 'resolved');
                }
                query.onSuccess((data) => {
                    resolve(data);
                });
                query.execute();
            });
        },
        /**
         *  resolves both all non deleted indicators (includes headers and archived indicators) and LEAFSRequests
         *  and when done, uses the resolved information to check the portals LEAFSRequest status
         */
        getSecureFormsInfo() {
            let secureCalls = [
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/indicator/list`,
                    success: (res)=> {},
                    error: (err) => console.log(err),
                    cache: false,
                }),

                this.fetchLEAFSRequests(true)
            ];

            Promise.all(secureCalls)
            .then((res)=> {
                const indicatorList = res[0];
                const leafSecureRecords = res[1];
                this.checkLeafSRequestStatus(indicatorList, leafSecureRecords);
            }).catch(err => console.log('an error has occurred', err));

        },
        /**
         * checks status of LEAF Secure Certification requests and adds HTML contents based on status
         * @param {array} indicatorList 
         * @param {Object} leafSRequests
         */
        checkLeafSRequestStatus(indicatorList = [], leafSRequests = {}) {
            let mostRecentID = null;
            let newIndicator = false;
            let mostRecentDate = 0;

            for(let i in leafSRequests) {
                if(leafSRequests[i].recordResolutionData.lastStatus.toLowerCase() === 'approved'
                    && leafSRequests[i].recordResolutionData.fulfillmentTime > mostRecentDate) {
                    mostRecentDate = leafSRequests[i].recordResolutionData.fulfillmentTime;
                    mostRecentID = i;
                }
            }
            document.getElementById('secureBtn')?.setAttribute('href', '../index.php?a=printview&recordID=' + mostRecentID);
            const mostRecentTimestamp = new Date(parseInt(mostRecentDate)*1000); // converts epoch secs to ms
            for(let i in indicatorList) {
                if(new Date(indicatorList[i].timeAdded).getTime() > mostRecentTimestamp.getTime()) {
                    newIndicator = true;
                    break;
                }
            }
            if (newIndicator === true && this.currCategoryID === null) { //null if on form browser page
                this.showCertificationStatus = true;
                this.fetchLEAFSRequests(false).then(unresolvedLeafSRequests => {
                    if (this.currentCategoryID === null) {
                        if (Object.keys(unresolvedLeafSRequests).length === 0) { // if no new request, create one
                            document.getElementById('secureStatus').innerText = 'Forms have been modified.';
                            document.getElementById('secureBtn').innerText = 'Please Recertify Your Site';
                            document.getElementById('secureBtn')?.setAttribute('href', '../report.php?a=LEAF_start_leaf_secure_certification');
                        } else {
                            const recordID = unresolvedLeafSRequests[Object.keys(unresolvedLeafSRequests)[0]].recordID;
                            document.getElementById('secureStatus').innerText = 'Re-certification in progress.';
                            document.getElementById('secureBtn').innerText = 'Check Certification Progress';
                            document.getElementById('secureBtn')?.setAttribute('href', '../index.php?a=printview&recordID=' + recordID);
                        }
                    }
                }).catch(err => console.log('an error has occurred', err));
            }
        },
        /**
         * 
         * @param {string} catID 
         * @returns {array} of objects with information about the form (indicators and structure relations)
         */
        getFormByCategoryID(catID = '') {
            console.log('getting form', catID)
            this.appIsLoadingForm = true;
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}?childkeys=nonnumeric`,
                    success: (res)=> {
                        console.log('form received');
                        this.appIsLoadingForm = false;
                        resolve(res)
                    },
                    error: (err)=> reject(err)
                });
            });
        },
        /**
         * 
         * @param {number} indID 
         * @returns {Object} with property information about the specific indicator
         */
        getIndicatorByID(indID) {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formEditor/indicator/${indID}`,
                    success: (res)=> resolve(res),
                    error: (err) => reject(err)
                });
            });
        },
        /**
         * updates app categories object property value
         * @param {string} catID 
         * @param {string} keyName 
         * @param {string} keyValue 
         */
        updateCategoriesProperty(catID = '', keyName = '', keyValue = '') {
            this.categories[catID][keyName] = keyValue;
        },
        /**
         * updates app stapledFormsCatIDs to track which forms have staples, and stapledFormIds of categories object
         * @param {string} stapledCatID id of the form being merged/unmerged
         * @param {string} removeStaple indicates whether staple is being added or removed
         */
        updateStapledFormsInfo(stapledCatID = '', removeStaple = false) {
            const formID = this.currentCategorySelection.categoryID;
            console.log('updating stapled info for form', formID, 'removing?', removeStaple)
            if(removeStaple === true) {
                this.stapledFormsCatIDs = this.stapledFormsCatIDs.filter(id => id !== stapledCatID);
                this.categories[formID].stapledFormIDs = this.categories[formID].stapledFormIDs.filter(id => id !== stapledCatID);
            } else {
                this.stapledFormsCatIDs = Array.from(new Set([...this.stapledFormsCatIDs, stapledCatID]));
                this.categories[formID].stapledFormIDs  = [...this.currentCategorySelection.stapledFormIDs, stapledCatID];
            }
        },
        /**
         * adds an entry to the app's categories object when a new form is created
         * @param {string} catID 
         * @param {Object} record of properties for the new form
         */
        addNewCategory(catID = '', record = {}) {
            this.categories[catID] = record;
        },
        /**
         * 
         * @param {string|null} catID of the form to select TODO: see if this can be refact to empty str
         * @param {boolean} isSubform whether it is a main or a subform
         * @param {number|null} subnodeIndID the indicatorID associated with the currently selected form section from the Form Index
         */
        selectNewCategory(catID = '', isSubform = false, subnodeIndID = null) {
            if(!isSubform) {
                this.currCategoryID = catID;
                this.currSubformID = null;
            } else {
                this.currCategoryID = this.categories[catID].parentID;
                this.currSubformID = catID;
            }
            this.selectedFormTree = [];
            this.selectedFormNode = null;
            this.selectedNodeIndicatorID = null;

            //switch to specified record, get info for the newly selected form, update sensitive, total values, get staples
            if (catID !== null) {
                this.selectedNodeIndicatorID = subnodeIndID;
                this.currentCategoryIsSensitive = false;

                this.getFormByCategoryID(catID).then(res => {
                    this.selectedFormTree = res;
                    this.selectedFormTree.forEach(section => {
                        if (this.selectedFormNode === null) {
                            this.getNodeSelection(section);
                        }
                        this.currentCategoryIsSensitive = this.checkSensitive(section, this.currentCategoryIsSensitive);
                    });
                    this.$router.replace({ name: "category", query: { formID: catID } });
                    document.getElementById('header_' + catID)?.focus(); //focus the breadcrumb/button for the main form
                }).catch(err => console.log('error getting form info: ', err));

            } else {  //card browser.
                this.categories = {};
                this.getCategoryListAll();
                this.getSecureFormsInfo();
                this.getWorkflowRecords();
            }
        },
        /**
         * 
         * @param {Object} event
         * @param {Object} node of the form section selected in the Form Index
         */
        selectNewFormNode(event = {}, node = {}) {
            if (event.target.classList.contains('icon_move') || event.target.classList.contains('sub-menu-chevron')) {
                return //prevents enter/space activation from move and menu toggle buttons
            }
            this.selectedFormNode = node;
            this.selectedNodeIndicatorID = node?.indicatorID || null;
        },

        /** DIALOG MODAL RELATED */
        setCustomDialogTitle(htmlContent = '') {
            this.dialogTitle = htmlContent;
        },
        /**
         * set the component for the dialog modal's main content. Components must be registered to this app
         * @param {string} component name as string, eg 'confirm-delete-dialog'
         */
        setFormDialogComponent(component = '') {
            this.dialogFormContent = component;
        },
        /**
         * close dialog and reset title, content and button text values
         */
        closeFormDialog() {
            this.showFormDialog = false;
            this.setCustomDialogTitle('');
            this.setFormDialogComponent('');
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        openConfirmDeleteFormDialog() {
            this.setCustomDialogTitle('<h2>Delete this form</h2>');
            this.setFormDialogComponent('confirm-delete-dialog');
            this.dialogButtonText = {confirm: 'Yes', cancel: 'No'};
            this.showFormDialog = true;
        },
        openStapleFormsDialog() {
            this.setCustomDialogTitle('<h2>Editing Stapled Forms</h2>');
            this.setFormDialogComponent('staple-form-dialog');
            this.dialogButtonText = {confirm: 'Add', cancel: 'Close'};
            this.showFormDialog = true;
        },
        openEditCollaboratorsDialog() {
            this.setCustomDialogTitle('<h2>Editing Collaborators</h2>');
            this.setFormDialogComponent('edit-collaborators-dialog');
            this.dialogButtonText = {confirm: 'Add', cancel: 'Close'};
            this.showFormDialog = true;
        },
        openIfThenDialog(indicatorID = 0, indicatorName = 'Untitled') {
            const name = this.truncateText(XSSHelpers.stripAllTags(indicatorName));
            this.currIndicatorID = indicatorID;
            this.setCustomDialogTitle(`<h2>Conditions For <span style="color: #c00;">${name} (${indicatorID})</span></h2>`);
            this.setFormDialogComponent('conditions-editor-dialog');
            this.showFormDialog = true;
        },
        /**
         * Opens the dialog for editing a form question, creating a new form section, or creating a new subquestion
         * @param {number|null} indicatorID 
         */
        openIndicatorEditingDialog(indicatorID = null) {
            let title = ''
            if (indicatorID === null) { //new form section
                title = `<h2>Adding new Section</h2>`;
            } else {
                //If equal, this is editing an existing question.  Otherwise, creating a new subquestion (param is its parentID)
                title = this.currIndicatorID === parseInt(indicatorID) ? 
                `<h2>Editing indicator ${indicatorID}</h2>` : `<h2>Adding question to ${indicatorID}</h2>`;
            }
            this.setCustomDialogTitle(title);
            this.setFormDialogComponent('indicator-editing-dialog');
            this.showFormDialog = true;
        },
        /**
         * get indicator info for indicatorID, and then open advanced options for that indicator
         * @param {number} indicatorID 
         */
        openAdvancedOptionsDialog(indicatorID = 0) {
            this.indicatorRecord = {};
            this.currIndicatorID = indicatorID;
            this.getIndicatorByID(indicatorID).then(res => {
                this.indicatorRecord = res;
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
        /**
         * add a new section or new subquestion to a form
         * @param {number|null} parentIndID of the new subquestion.  null for new sections.
         */
        newQuestion(parentIndID = null) {
            this.currIndicatorID = null;
            this.newIndicatorParentID = parentIndID !== null ? parseInt(parentIndID) : null;
            this.isEditingModal = false;
            this.openIndicatorEditingDialog(parentIndID);
        },
        /**
         * get information about the indicator and open indicator editing
         * @param {number} indicatorID 
         */
        editQuestion(indicatorID = 0) {
            this.indicatorRecord = {};
            this.currIndicatorID = indicatorID;
            this.newIndicatorParentID = null;
            this.getIndicatorByID(indicatorID).then(res => {
                this.isEditingModal = true;
                this.indicatorRecord = res;
                this.openIndicatorEditingDialog(indicatorID);
            }).catch(err => console.log('error getting indicator information', err));
        },
        checkSensitive(node = {}, isSensitive = false) {
            if (isSensitive === false) {
                if (parseInt(node.is_sensitive) === 1) {
                    isSensitive = true;
                }
                if (isSensitive === false && node.child) {
                    for (let c in node.child) {
                        isSensitive = this.checkSensitive(node.child[c], isSensitive);
                        if (isSensitive === true) break;
                    }
                }
            }
            return isSensitive;
        },
        getNodeSelection(node = {}) {
            if (node.indicatorID === this.selectedNodeIndicatorID) {
                this.selectedFormNode = node;
            }
            if (this.selectedFormNode === null && node.child) {
                for (let c in node.child) {
                    this.getNodeSelection(node.child[c]);
                }
            }
        }
    }
}