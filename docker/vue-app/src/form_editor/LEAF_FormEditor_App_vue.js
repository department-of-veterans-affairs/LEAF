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
            orgchartFormats: ['orgchart_group','orgchart_position','orgchart_employee'],
            appIsLoadingCategories: true,

            categories: {},
            allStapledFormCatIDs: [],         //cat IDs of forms stapled to anything
            advancedMode: false,
            formMenuState: {},

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
            categories: computed(() => this.categories),
            allStapledFormCatIDs: computed(() => this.allStapledFormCatIDs),
            appIsLoadingCategories: computed(() => this.appIsLoadingCategories),
            showCertificationStatus: computed(() => this.showCertificationStatus),
            secureStatusText: computed(() => this.secureStatusText),
            secureBtnText: computed(() => this.secureBtnText),
            secureBtnLink: computed(() => this.secureBtnLink),
            advancedMode: computed(() => this.advancedMode),
            formMenuState: computed(() => this.formMenuState),

            //static values
            APIroot: this.APIroot,
            libsPath: this.libsPath,
            getEnabledCategories: this.getEnabledCategories,
            hasDevConsoleAccess: this.hasDevConsoleAccess,
            getSiteSettings: this.getSiteSettings,
            setDefaultAjaxResponseMessage: this.setDefaultAjaxResponseMessage,
            editIndicatorPrivileges: this.editIndicatorPrivileges,
            selectIndicator: this.selectIndicator,
            updateFormMenuState: this.updateFormMenuState,
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
            openIndicatorEditingDialog: this.openIndicatorEditingDialog,
            openIfThenDialog: this.openIfThenDialog,
            orgchartFormats: this.orgchartFormats,
            initializeOrgSelector: this.initializeOrgSelector,
            truncateText: this.truncateText,
            decodeAndStripHTML: this.decodeAndStripHTML,
            showLastUpdate: this.showLastUpdate,

            /** dialog related */
            closeFormDialog: this.closeFormDialog,
            setDialogSaveFunction: this.setDialogSaveFunction,
            checkRequiredData: this.checkRequiredData,

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
        this.getEnabledCategories();
    },
    methods: {
        truncateText(str = '', maxlength = 40, overflow = '...') {
            return str.length <= maxlength ? str : str.slice(0, maxlength) + overflow;
        },
        /**
         * @param {string} content 
         * @returns removes encoded chars by passing through div and then strips all tags
         */
        decodeAndStripHTML(content = '') {
            const elDiv = document.createElement('div');
            elDiv.innerHTML = content;
            return XSSHelpers.stripAllTags(elDiv.innerText);
        },
        /**
         * @param {string} elementID of targetted DOM element.  Briefly display last updated message
         */
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
         * Sends background call to get feedback during navigation about login or token status.
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
        /**
         * Initializes and mounts an orgchart selector widget of the specified type and calls optional callback methods
         * @param {string} selType type of orgchart selector (employee, group or position)
         * @param {number|string} indID unique id identifier (used in FE for indicator preview)
         * @param {string} idPrefix optional additional DOM id identifier
         * @param {string} initialValue optional initial value for selector
         * @param {function} selectorCallback optional method to call once orgchart selection is filled
         */
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
         * Update the menu state of the form editor preview
         * @param {number} indID indicatorID to set state for
         * @param {boolean} menuOpen open or close the menu
         * @param {boolean} cascade open or close all submenus
         */
        updateFormMenuState(indID = 0, menuOpen = true, cascade = false) {
            this.formMenuState[indID] = menuOpen;
            if(cascade === true) {
                const allChildren = Array.from(document.querySelectorAll(`#index_listing_${indID} li`));
                allChildren.forEach(c => {
                    const id = c.id.replace('index_listing_', '');
                    this.formMenuState[id] = menuOpen;
                });
            }
        },
        /**
         * updates app array allStapledFormCatIDs (when possible) and stapledFormIds for specified categories object
         * @param {string} catID id of the form having a staple added or removed
         * @param {string} stapledCatID id of the form being merged/unmerged
         * @param {boolean} removeStaple indicates whether staple is being added or removed
         */
        updateStapledFormsInfo(catID = '', stapledCatID = '', removeStaple = false) {
            const formID = catID;
            if(removeStaple === true) {
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
         * removes an entry from the app's categories object when a form is deleted
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
         * sets the component for the dialog modal's main content. Components must be registered to the view using them.
         * @param {string} component name as string, eg 'confirm-delete-dialog'
         */
        setFormDialogComponent(component = '') {
            this.dialogFormContent = component;
        },
        /** used by dialog content component on creation to set the modal save method */
        setDialogSaveFunction(func = '') {
            if (typeof func === 'function') {
                this.formSaveFunction = func;
            }
        },
        /**
         * dialogs using dialogData can call this on create to check that expected keys are present
         * @param {Array} requiredDataProperties of properties to check for.
         */
        checkRequiredData(requiredDataProperties = []) {
            let notFound = [];
            const dataKeys = Object.keys(this?.dialogData || {});
            requiredDataProperties.forEach(keyName => {
                if (!dataKeys.includes(keyName)) {
                    notFound.push(keyName);
                }
            });
            if(notFound.length > 0) {
                console.warn('expected dialogData key was not found', notFound);
            }
        },
        openConfirmDeleteFormDialog() {
            this.setCustomDialogTitle('<h2>Delete this form</h2>');
            this.setFormDialogComponent('confirm-delete-dialog');
            this.dialogButtonText = {confirm: 'Yes', cancel: 'No'};
            this.showFormDialog = true;
        },
        openStapleFormsDialog(categoryID = '') {
            this.dialogData = {
                mainFormID: categoryID
            }
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
            const name = this.truncateText(this.decodeAndStripHTML(indicatorName), 35);
            this.dialogData = {
                indicatorID,
            }
            this.setCustomDialogTitle(`<h2>Conditions For <span style="color: #a00;">${name} (${indicatorID})</span></h2>`);
            this.setFormDialogComponent('conditions-editor-dialog');
            this.showFormDialog = true;
        },
        /**
         * Opens the dialog for editing a question, or creating a new form section or subquestion
         * @param {number|null} indicatorID null for new questions.  Number for edited questions.
         * @param {number|null} parentID null for new sections. Number for edited questions or new subquestions.
         * @param {object} indicator details for edited question.  empty for new questions.
         */
        openIndicatorEditingDialog(indicatorID = null, parentID = null, indicator = {}) {
            let title = ''
            if (indicatorID === null && parentID === null) {
                title = `<h2>Adding new Section</h2>`;
            } else {
                title = indicatorID === null ?
                `<h2>Adding question to ${parentID}</h2>` : `<h2>Editing indicator ${indicatorID}</h2>`;
            }
            this.dialogData = {
                indicatorID,
                parentID,
                indicator,
            }
            this.setCustomDialogTitle(title);
            this.setFormDialogComponent('indicator-editing-dialog');
            this.showFormDialog = true;
        },
        /**
         * @param {object} indicator
         */
        openAdvancedOptionsDialog(indicator = {}) {
            this.dialogData = {
                indicatorID: indicator.indicatorID,
                html: indicator?.html || '',
                htmlPrint: indicator?.htmlPrint || '',
            }
            this.setCustomDialogTitle(`<h2>Advanced Options for indicator ${indicator.indicatorID}</h2>`);
            this.setFormDialogComponent('advanced-options-dialog');
            this.showFormDialog = true;   
        },
        openNewFormDialog(mainFormID = '') {
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
        }
    }
}