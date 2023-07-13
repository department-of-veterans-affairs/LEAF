import { computed } from 'vue';

import LeafFormDialog from "../common/components/LeafFormDialog.js";

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
import ResponseMessage from "./components/ResponseMessage";

import './LEAF_FormEditor.scss';

export default {
    data() {
        return {
            APIroot: APIroot,
            libsPath: libsPath,
            orgchartPath: orgchartPath,
            CSRFToken: CSRFToken,
            ajaxResponseMessage: '',

            siteSettings: {},
            secureStatusText: 'LEAF-Secure Certified',
            secureBtnText: 'View Details',
            secureBtnLink: '',
            fileManagerTextFiles: [],

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
            orgchartFormats: ['orgchart_group','orgchart_position','orgchart_employee'],

            appIsLoadingCategoryList: true,
            appIsLoadingForm: false,
            currIndicatorID: null,         //null or number
            newIndicatorParentID: null,    //null or number
            categories: {},                //obj with keys for each catID, values an object with 'categories' and 'workflow' tables fields
            focusedFormID: '',
            focusedFormTree: [],
            selectedNodeIndicatorID: null,
            allStapledFormCatIDs: [],         //cat IDs of forms stapled to anything
            workflowRecords: [],            //array of all 'workflows' table records
            indicatorRecord: {},          //'indicators' table record for a specific indicatorID
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
            currIndicatorID: computed(() => this.currIndicatorID),
            newIndicatorParentID: computed(() => this.newIndicatorParentID),
            indicatorRecord: computed(() => this.indicatorRecord),
            isEditingModal: computed(() => this.isEditingModal),
            workflowRecords: computed(() => this.workflowRecords),
            categories: computed(() => this.categories),
            currentFormCollection: computed(() => this.currentFormCollection),
            allStapledFormCatIDs: computed(() => this.allStapledFormCatIDs),
            focusedFormIsSensitive: computed(() => this.focusedFormIsSensitive),
            focusedFormRecord: computed(() => this.focusedFormRecord),
            focusedFormTree: computed(() => this.focusedFormTree),
            selectedNodeIndicatorID: computed(() => this.selectedNodeIndicatorID),
            selectedFormNode: computed(() => this.selectedFormNode),
            appIsLoadingCategoryList: computed(() => this.appIsLoadingCategoryList),
            appIsLoadingForm: computed(() => this.appIsLoadingForm),
            activeForms: computed(() => this.activeForms),
            inactiveForms: computed(() => this.inactiveForms),
            supplementalForms: computed(() => this.supplementalForms),
            showCertificationStatus: computed(() => this.showCertificationStatus),
            secureStatusText: computed(() => this.secureStatusText),
            secureBtnText: computed(() => this.secureBtnText),
            secureBtnLink: computed(() => this.secureBtnLink),
            fileManagerTextFiles: computed(() => this.fileManagerTextFiles),

            showFormDialog: computed(() => this.showFormDialog),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            formSaveFunction: computed(() => this.formSaveFunction),
            internalFormRecords: computed(() => this.internalFormRecords),
            //static values
            APIroot: this.APIroot,
            libsPath: this.libsPath,
            setDefaultAjaxResponseMessage: this.setDefaultAjaxResponseMessage,
            newQuestion: this.newQuestion,
            editQuestion: this.editQuestion,
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            selectNewCategory: this.selectNewCategory,
            selectNewFormNode: this.selectNewFormNode,
            getFormByCategoryID: this.getFormByCategoryID,
            updateCategoriesProperty: this.updateCategoriesProperty,
            updateStapledFormsInfo: this.updateStapledFormsInfo,
            addNewCategory: this.addNewCategory,
            removeCategory: this.removeCategory,
            closeFormDialog: this.closeFormDialog,
            openAdvancedOptionsDialog: this.openAdvancedOptionsDialog,
            openNewFormDialog: this.openNewFormDialog,
            openImportFormDialog: this.openImportFormDialog,
            openFormHistoryDialog: this.openFormHistoryDialog,
            openConfirmDeleteFormDialog: this.openConfirmDeleteFormDialog,
            openStapleFormsDialog: this.openStapleFormsDialog,
            openEditCollaboratorsDialog: this.openEditCollaboratorsDialog,
            openIfThenDialog: this.openIfThenDialog,
            orgchartFormats: this.orgchartFormats,
            initializeOrgSelector: this.initializeOrgSelector,
            truncateText: this.truncateText,
            decodeAndStripHTML: this.decodeAndStripHTML,
            showLastUpdate: this.showLastUpdate,
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
        ResponseMessage
    },
    mounted() {
        this.getCategoryListAll().then(() => {
            if(this.$route.name === 'category' && this.$route.query.formID) {
                this.getFormFromQueryParam();
            }
        }).catch(err => console.log('error getting category list', err));

        this.getSiteSettings().then(res => {
            this.siteSettings = res;
            if(res.siteType === 'national_subordinate') {
                document.getElementById('subordinate_site_warning').style.display = 'block';
            }
            if (res.leafSecure >= 1) {
                this.getSecureFormsInfo();
            }
        }).catch(err => console.log('error getting site settings', err));
        this.getWorkflowRecords();
        this.getFileManagerTextFiles();
    },
    watch: {
        "$route.query.formID"(newVal = '', oldVal = '') {
            if(this.$route.name === 'category' && !this.appIsLoadingCategoryList) {
                this.getFormFromQueryParam();
            }
        }
    },
    computed: {
        /**
         * @returns {Object} current query from categories object
         */
        currentCategoryQuery() {
            const queryID = this.$route.query.formID;
            return this.categories[queryID] || {};
        },
        /**
         * @returns {Object} focused form record from categories object
         */
        focusedFormRecord() {
            return this.categories[this.focusedFormID] || {};
        },
        /**
         * @returns {Object} form tree node
         */
        selectedFormNode() {
            let selectedNode = null;
            if (this.selectedNodeIndicatorID !== null) {
                this.focusedFormTree.forEach(section => {
                    if (selectedNode === null) {
                        selectedNode = this.getNodeSelection(section, this.selectedNodeIndicatorID) || null;
                    }
                });
            }
            return selectedNode;
        },
        /**
         * @returns {boolean} true once sensitive indicator found
         */
        focusedFormIsSensitive() {
            let isSensitive = false;
            this.focusedFormTree.forEach(section => {
                if(!isSensitive) {
                    isSensitive = this.checkSensitive(section);
                }
            });
            return isSensitive;
        },
        /**
         * @returns {array} of non-internal forms that have workflows and are available
         */
        activeForms() {
            let active = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID === '' &&
                    parseInt(this.categories[c].workflowID) !== 0 &&
                    parseInt(this.categories[c].visible) === 1) {
                        active.push({...this.categories[c]});
                }
            }
            active = active.sort((eleA, eleB) => eleA.sort - eleB.sort);
            return active;
        },
        /**
         * @returns {array} of non-internal forms that have workflows and are hidden
         */
        inactiveForms() {
            let inactive = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID === '' &&
                    parseInt(this.categories[c].workflowID) !== 0 &&
                    parseInt(this.categories[c].visible) === 0) {
                    inactive.push({...this.categories[c]});
                }
            }
            inactive = inactive.sort((eleA, eleB) => eleA.sort - eleB.sort);
            return inactive;
        },
        /**
         * @returns {array} of non-internal forms that have no workflows
         */
        supplementalForms() {
            let supplementalForms = [];
            for(let c in this.categories) {
                if (this.categories[c].parentID === '' && parseInt(this.categories[c].workflowID) === 0 ) {
                    supplementalForms.push({...this.categories[c]});
                }
            }
            supplementalForms = supplementalForms.sort((eleA, eleB) => eleA.sort - eleB.sort);
            return supplementalForms;
        },
        /**
         * 
         * @returns {array} categories records that are internal forms of the focused form
         */
        internalFormRecords() {
            let internalFormRecords = [];
            for(let c in this.categories) {
                if (this.categories[c].parentID === this.focusedFormID) {
                    internalFormRecords.push({...this.categories[c]});
                }
            }
            return internalFormRecords;
        },
        /**
         * 
         * @returns {array} of categories records for queried form and any staples
         */
        currentFormCollection() {
            let allRecords = [];
            let currStapleIDs = this.currentCategoryQuery?.stapledFormIDs || [];
            currStapleIDs.forEach(id => {
                allRecords.push({...this.categories[id], formContextType: 'staple'});
            });
 
            let focusedFormType = this.currentCategoryQuery.parentID !== '' ?
                        'internal' : 
                        this.allStapledFormCatIDs.includes(this.currentCategoryQuery?.categoryID || '') ?
                        'staple' : 'main form';
            allRecords.push({...this.currentCategoryQuery, formContextType: focusedFormType,});
            return allRecords.sort((eleA, eleB) => eleA.sort - eleB.sort);
        },
    },
    methods: {
        truncateText(str='', maxlength = 40, overflow = '...') {
            return str.length <= maxlength ? str : str.slice(0, maxlength) + overflow;
        },
        /**
         * 
         * @param {string} content 
         * @returns removes encoded chars by passing through div and then strips all tags
         */
        decodeAndStripHTML(content = '') {
            const elDiv = document.createElement('div');
            elDiv.innerHTML = content;
            return XSSHelpers.stripAllTags(elDiv.innerText);
        },
        showLastUpdate(elementID = '', text = '') {
            const el = document.getElementById(elementID);
            if(el !== null) {
                el.innerText = text;
                el.style.opacity = 1;
                el.style.border = '2px solid #20a0f0';
                setTimeout(() => {
                    el.style.border = '2px solid transparent';
                }, 750);
            }
        },
        /**
         * Sends background call to get more immediate feedback during navigation about login or token status,
         * since the response from the index.php case is only returned on initial load.
         */
        setDefaultAjaxResponseMessage() {
            $.ajax({
                type: 'POST',
                url: `ajaxIndex.php?a=checkstatus`,
                data: {
                    CSRFToken,
                },
                success: (res) => {
                    this.ajaxResponseMessage = res || "";
                },
                error: (err) => reject(err)
            });
        },
        initializeOrgSelector(
            selType = 'employee',
            indID = 0,
            idPrefix = '',
            initialValue = '',
            selectorCallback = null
        ) {
            selType = selType.toLowerCase();
            const inputPrefix = selType === 'group' ? 'group#' : '#';
            let orgSelector = {};
            if (selType === 'group') {
              orgSelector = new groupSelector(`${idPrefix}orgSel_${indID}`);
            } else if (selType === 'position') {
              orgSelector = new positionSelector(`${idPrefix}orgSel_${indID}`);
            } else {
              orgSelector = new employeeSelector(`${idPrefix}orgSel_${indID}`);
            }
            orgSelector.apiPath = `${this.orgchartPath}/api/`;
            orgSelector.rootPath = `${this.orgchartPath}/`;
            orgSelector.basePath = `${this.orgchartPath}/`;
            orgSelector.setSelectHandler(() => {
                const elOrgSelInput = document.querySelector(`#${orgSelector.containerID} input.${selType}SelectorInput`);
                if(elOrgSelInput !== null) {
                    elOrgSelInput.value = `${inputPrefix}` + orgSelector.selection;
                }
            });
            if(typeof selectorCallback === 'function') {
                orgSelector.setResultHandler(() => selectorCallback(orgSelector));
            }
            orgSelector.initialize();
            //input initial value if there is one
            const elOrgSelInput = document.querySelector(`#${orgSelector.containerID} input.${selType}SelectorInput`);
            if (initialValue !== '' && elOrgSelInput !== null) {
                elOrgSelInput.value = `${inputPrefix}` + initialValue;
            }
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
                    success: (res) => {
                        for(let i in res) {
                            this.categories[res[i].categoryID] = res[i];
                            res[i].stapledFormIDs.forEach(id => {
                                if (!this.allStapledFormCatIDs.includes(id)) {
                                    this.allStapledFormCatIDs.push(id);
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
            if (formID === null || this.categories[formID] === undefined) {
                this.selectNewCategory();
                //console.log('no form selected or form does not exist');
            } else {
                this.selectNewCategory(formID, this.selectedNodeIndicatorID, true);
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
                query.onSuccess((data) => resolve(data));
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
            this.secureBtnLink = '../index.php?a=printview&recordID=' + mostRecentID;
            const mostRecentTimestamp = new Date(parseInt(mostRecentDate)*1000); // converts epoch secs to ms
            for(let i in indicatorList) {
                if(new Date(indicatorList[i].timeAdded).getTime() > mostRecentTimestamp.getTime()) {
                    newIndicator = true;
                    break;
                }
            }
            if (newIndicator === true) {
                this.showCertificationStatus = true;
                this.fetchLEAFSRequests(false).then(unresolvedLeafSRequests => {
                    if (Object.keys(unresolvedLeafSRequests).length === 0) { // if no new request, create one
                        this.secureStatusText = 'Forms have been modified.';
                        this.secureBtnText = 'Please Recertify Your Site';
                        this.secureBtnLink = '../report.php?a=LEAF_start_leaf_secure_certification';
                    } else {
                        const recordID = unresolvedLeafSRequests[Object.keys(unresolvedLeafSRequests)[0]].recordID;
                        this.secureStatusText = 'Re-certification in progress.';
                        this.secureBtnText = 'Check Certification Progress';
                        this.secureBtnLink = '../index.php?a=printview&recordID=' + recordID;
                    }
                    
                }).catch(err => console.log('an error has occurred', err));
            }
        },
        /**
         * @param {string} catID 
         * @param {number|null} subnodeIndID indicatorID of the focused form node
         * @returns {array} of objects with information about the form (indicators and structure relations)
         */
        getFormByCategoryID(catID = '', subnodeIndID = null) {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}?childkeys=nonnumeric`,
                    success: (res)=> {
                        this.focusedFormID = catID;
                        this.focusedFormTree = res;
                        this.selectedNodeIndicatorID = subnodeIndID;
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
        getIndicatorByID(indID = 0) {
            return new Promise((resolve, reject)=> {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}formEditor/indicator/${indID}`,
                    success: (res)=> {
                        resolve(res)
                    },
                    error: (err) => reject(err)
                });
            });
        },
        getFileManagerTextFiles() {
            $.ajax({
              type: 'GET',
              url: `${this.APIroot}system/files`,
              success: (res) => {
                const files = res || [];
                this.fileManagerTextFiles = files.filter(
                    filename => filename.indexOf('.txt') > -1 || filename.indexOf('.csv') > -1);
              },
              error: (err) => {
                console.log(err);
              },
              cache: false
            });
        },
        /**
         * updates app categories object property value
         * @param {string} catID
         * @param {string} keyName
         * @param {string} keyValue
         */
        updateCategoriesProperty(catID = '', keyName = '', keyValue = '') {
            if(this.categories[catID][keyName] !== undefined) {
                this.categories[catID][keyName] = keyValue;
            }
        },
        /**
         * updates app array allStapledFormCatIDs and stapledFormIds of categories object
         * @param {string} stapledCatID id of the form being merged/unmerged
         * @param {boolean} removeStaple indicates whether staple is being added or removed
         */
        updateStapledFormsInfo(stapledCatID = '', removeStaple = false) {
            const formID = this.currentCategoryQuery.categoryID;
            if(removeStaple === true) {
                this.allStapledFormCatIDs = this.allStapledFormCatIDs.filter(id => id !== stapledCatID);
                this.categories[formID].stapledFormIDs = this.categories[formID].stapledFormIDs.filter(id => id !== stapledCatID);
            } else {
                this.allStapledFormCatIDs = Array.from(new Set([...this.allStapledFormCatIDs, stapledCatID]));
                this.categories[formID].stapledFormIDs  = [...this.currentCategoryQuery.stapledFormIDs, stapledCatID];
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
         * removed an entry from the app's categories object when a form is deleted
         * @param {string} catID 
         */
        removeCategory(catID = '') {
            delete this.categories[catID];
        },
        /**
         * @param {string} catID of the form to select
         * @param {number|null} subnodeIndID indicatorID of currently selected form section
         */
        selectNewCategory(catID = '', subnodeIndID = null, setFormLoading = false) {
            this.setDefaultAjaxResponseMessage();
            if (catID !== '') {
                if (setFormLoading === true) this.appIsLoadingForm = true
                this.getFormByCategoryID(catID, subnodeIndID);

            } else {  //card browser.
                this.selectedNodeIndicatorID = null;
                this.focusedFormID = '';
                this.focusedFormTree = [];
                this.categories = {};
                this.workflowRecords = [];
                this.getCategoryListAll();
                this.getSecureFormsInfo();
                this.getWorkflowRecords();
                this.getFileManagerTextFiles();
            }
        },
        /**
         * 
         * @param {Object} event
         * @param {Object|null} node of the form section selected in the Form Index
         */
        selectNewFormNode(event = {}, node = null) {
            if (event.target.classList.contains('icon_move') || event.target.classList.contains('sub-menu-chevron')) {
                return //prevents enter/space activation from move and menu toggle buttons
            }
            this.selectedNodeIndicatorID = node?.indicatorID || null;
            if (node?.indicatorID !== null) {
                const elsMenu = Array.from(document.querySelectorAll(`li#index_listing_${node?.indicatorID} .sub-menu-chevron.closed`));
                elsMenu.forEach(el => el.click());
            }
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
            const name = this.truncateText(this.decodeAndStripHTML(indicatorName));
            this.currIndicatorID = indicatorID;
            this.setCustomDialogTitle(`<h2>Conditions For <span style="color: #a00;">${name} (${indicatorID})</span></h2>`);
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
        openNewFormDialog(event = {}, mainFormID = '') {
            const titleHTML = mainFormID === '' ? '<h2>New Form</h2>' : '<h2>New Internal Use Form</h2>';
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
        checkSensitive(node = {}) {
            if (parseInt(node.is_sensitive) === 1) {
                return true;

            } else {
                let sensitive = false;
                if (node.child) {
                    for (let c in node.child) {
                        sensitive = this.checkSensitive(node.child[c]) || false;
                        if (sensitive === true) break;
                    }
                }
                return sensitive;
            }
        },
        getNodeSelection(node = {}, indicatorID = 0) {
            if(parseInt(node.indicatorID) === parseInt(indicatorID)) {
                return node;

            } else {
                let nodeSelection = null;
                if (node.child && Object.keys(node.child).length > 0) {
                    for (let c in node.child) {
                        nodeSelection = this.getNodeSelection(node.child[c], indicatorID) || null;
                        if (nodeSelection !== null) break;
                    }
                }
                return nodeSelection;
            }
        },
    }
}