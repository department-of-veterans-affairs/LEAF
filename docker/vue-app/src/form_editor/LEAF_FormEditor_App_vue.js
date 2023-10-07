import { computed } from 'vue';

import ResponseMessage from "./components/ResponseMessage";

import './LEAF_FormEditor.scss';

export default {
    data() {
        return {
            APIroot: APIroot,
            libsPath: libsPath,
            orgchartPath: orgchartPath,
            CSRFToken: CSRFToken,
            hasDevConsoleAccess: +hasDevConsoleAccess,
            ajaxResponseMessage: '',

            siteSettings: {},
            secureStatusText: 'LEAF-Secure Certified',
            secureBtnText: 'View Details',
            secureBtnLink: '',
            showCertificationStatus: false,
            isEditingModal: false,
            orgchartFormats: ['orgchart_group','orgchart_position','orgchart_employee'],
            appIsLoadingCategories: true,
            currIndicatorID: null,         //null or number
            newIndicatorParentID: null,    //null or number
            categories: {},
            allStapledFormCatIDs: [],         //cat IDs of forms stapled to anything
            indicatorRecord: {},          //'indicators' table record for a specific indicatorID
            advancedMode: false,

            /* modal properties */
            dialogTitle: '',
            dialogFormContent: '',
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            formSaveFunction: null,
            showFormDialog: false,
            dialogData: null
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
            siteSettings: computed(() => this.siteSettings),
            currIndicatorID: computed(() => this.currIndicatorID),
            newIndicatorParentID: computed(() => this.newIndicatorParentID),
            indicatorRecord: computed(() => this.indicatorRecord),
            isEditingModal: computed(() => this.isEditingModal),
            categories: computed(() => this.categories),
            allStapledFormCatIDs: computed(() => this.allStapledFormCatIDs),
            appIsLoadingCategories: computed(() => this.appIsLoadingCategories),
            showCertificationStatus: computed(() => this.showCertificationStatus),
            secureStatusText: computed(() => this.secureStatusText),
            secureBtnText: computed(() => this.secureBtnText),
            secureBtnLink: computed(() => this.secureBtnLink),
            advancedMode: computed(() => this.advancedMode),

            //static values
            APIroot: this.APIroot,
            libsPath: this.libsPath,
            getEnabledCategories: this.getEnabledCategories,
            hasDevConsoleAccess: this.hasDevConsoleAccess,
            getSiteSettings: this.getSiteSettings,
            setDefaultAjaxResponseMessage: this.setDefaultAjaxResponseMessage,
            newQuestion: this.newQuestion,
            editQuestion: this.editQuestion,
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            updateCategoriesProperty: this.updateCategoriesProperty,
            updateStapledFormsInfo: this.updateStapledFormsInfo,
            addNewCategory: this.addNewCategory,
            removeCategory: this.removeCategory,

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

            /** dialog */
            closeFormDialog: this.closeFormDialog,
            setDialogSaveFunction: this.setDialogSaveFunction,

            showFormDialog: computed(() => this.showFormDialog),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            dialogData: computed(() => this.dialogData),
            formSaveFunction: computed(() => this.formSaveFunction),
        }
    },
    components: {
        ResponseMessage
    },
    created() {
        console.log('APP created, app is getting categories');
        this.getEnabledCategories();
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
        showLastUpdate(elementID = '') {
            const lastUpdated = new Date().toLocaleString();
            const el = document.getElementById(elementID);
            if(el !== null) {
                el.style.display = 'flex';
                el.innerText = `last modified: ${lastUpdated}`;
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
         * @returns {object} main keys are categoryIDs. Values are obj w fields from non-built-in, enabled categories and workflows tables
         */
        getEnabledCategories() {
            this.appIsLoadingCategories = true;
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}formStack/categoryList/allWithStaples`,
                success: (res) => {
                    console.log('setting up categories');
                    this.categories = {};
                    for(let i in res) {
                        this.categories[res[i].categoryID] = res[i];
                        res[i].stapledFormIDs.forEach(id => {
                            if (!this.allStapledFormCatIDs.includes(id)) {
                                this.allStapledFormCatIDs.push(id);
                            }
                        });
                    }
                    this.appIsLoadingCategories = false;
                },
                error: (err)=> console.log(err)
            });
        },
        /**
         * @returns {Object} of all records from the portal's settings table.  Followup Leaf Secure check if leafSecure date exists
         */
        getSiteSettings() {
            try {
                fetch(`${this.APIroot}system/settings`).then(res => {
                    res.json().then(data => {
                        this.siteSettings = data;
                        if (+data?.leafSecure >= 1) {
                            this.getSecureFormsInfo();
                        }
                    });
                });
            } catch(error) {
                console.log('error getting site settings', error);
            }
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

            Promise.all(secureCalls).then((res)=> {
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

            } else {
                this.showCertificationStatus = false;
            }
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
         * @param {string} catID id of the form having a staple added or removed
         * @param {string} stapledCatID id of the form being merged/unmerged
         * @param {boolean} removeStaple indicates whether staple is being added or removed
         */
        updateStapledFormsInfo(catID = '', stapledCatID = '', removeStaple = false) {
            const formID = catID;
            if(removeStaple === true) {
                this.allStapledFormCatIDs = this.allStapledFormCatIDs.filter(id => id !== stapledCatID);
                this.categories[formID].stapledFormIDs = this.categories[formID].stapledFormIDs.filter(id => id !== stapledCatID);
            } else {
                this.allStapledFormCatIDs = Array.from(new Set([...this.allStapledFormCatIDs, stapledCatID]));
                this.categories[formID].stapledFormIDs = Array.from(new Set([...this.categories[formID].stapledFormIDs, stapledCatID]));
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

        /** DIALOG MODAL RELATED */
        /**
         * close dialog and reset values
         */
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.dialogFormContent = '';
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
            this.formSaveFunction = null;
            this.dialogData = null;
        },
        setCustomDialogTitle(htmlContent = '') {
            this.dialogTitle = htmlContent;
        },
        /**
         * sets the component for the dialog modal's main content. Components must be registered to the view using them
         * @param {string} component name as string, eg 'confirm-delete-dialog'
         */
        setFormDialogComponent(component = '') {
            this.dialogFormContent = component;
        },
        setDialogSaveFunction(func = '') {
            if (typeof func === 'function') {
                this.formSaveFunction = func;
            }
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
            this.dialogData = {
                parentID: mainFormID,
            };
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
        openFormHistoryDialog(catID = '') {
            this.dialogData = {
                historyType: 'form',
                historyID: catID,
            };
            this.setCustomDialogTitle(`<h2>Form History</h2>`);
            this.setFormDialogComponent('history-dialog');
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
        }
    }
}