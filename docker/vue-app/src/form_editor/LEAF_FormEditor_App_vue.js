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
            hasDevConsoleAccess: hasDevConsoleAccess,
            ajaxResponseMessage: '',

            siteSettings: {},
            secureStatusText: 'LEAF-Secure Certified',
            secureBtnText: 'View Details',
            secureBtnLink: '',
            showCertificationStatus: false,
            orgchartFormats: ['orgchart_group','orgchart_position','orgchart_employee'],
            appIsLoadingCategories: true,

            categories: {},
            allStapledFormCatIDs: {},    //table of cat IDs of forms stapled to anything, val is num times used
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
            selectIndicator: this.selectIndicator,
            updateCategoriesProperty: this.updateCategoriesProperty,
            updateStapledFormsInfo: this.updateStapledFormsInfo,
            addNewCategory: this.addNewCategory,
            removeCategory: this.removeCategory,
            updateChosenAttributes: this.updateChosenAttributes,

            openAdvancedOptionsDialog: this.openAdvancedOptionsDialog,
            openNewFormDialog: this.openNewFormDialog,
            openImportFormDialog: this.openImportFormDialog,
            openFormHistoryDialog: this.openFormHistoryDialog,
            openConfirmDeleteFormDialog: this.openConfirmDeleteFormDialog,
            openStapleFormsDialog: this.openStapleFormsDialog,
            openEditCollaboratorsDialog: this.openEditCollaboratorsDialog,
            openIndicatorEditingDialog: this.openIndicatorEditingDialog,
            openIfThenDialog: this.openIfThenDialog,
            openRestoreFieldOptionsDialog: this.openRestoreFieldOptionsDialog,
            openBasicConfirmDialog: this.openBasicConfirmDialog,
            orgchartFormats: this.orgchartFormats,
            initializeOrgSelector: this.initializeOrgSelector,
            truncateText: this.truncateText,
            decodeAndStripHTML: this.decodeAndStripHTML,
            showLastUpdate: this.showLastUpdate,

            /** dialog related */
            closeFormDialog: this.closeFormDialog,
            lastModalTab: this.lastModalTab,
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
        document.addEventListener('keydown', (event)=> {
            if((event?.key || "").toLowerCase() === "escape" && this.showFormDialog === true) {
                //escape is needed to tab out of codemirror editors - don't close the modal if the target is one of those textareas
                const closestCodeMirror = event.target.closest('.CodeMirror') || null;
                if(closestCodeMirror === null) {
                    this.closeFormDialog();
                }
            }
        });
        this.dragDropFirefoxFix();
    },
    methods: {
        openBasicConfirmDialog(messageHTML = '', title = '<h2>Confirmation Required</h2>', affirmative = 'Confirm', negative = 'Cancel', saveFunction = {}) {
            if(typeof saveFunction === 'function') {
                this.formSaveFunction = () => {
                    saveFunction();
                    this.closeFormDialog();
                }
                this.dialogData = messageHTML;
                this.setCustomDialogTitle(title);
                this.setFormDialogComponent('basic-confirm-dialog');
                this.dialogButtonText = {confirm: affirmative, cancel: negative};
                this.showFormDialog = true;
            }
        },
        dragDropFirefoxFix() {
            if(/Firefox\/\d+[\d\.]*/.test(navigator.userAgent) &&
                typeof window.DragEvent === 'function' &&
                typeof window.addEventListener === 'function') {

                (function() {
                // patch for Firefox bug https://bugzilla.mozilla.org/show_bug.cgi?id=505521
                var cx, cy, px, py, ox, oy, sx, sy, lx, ly;
                function update(e) {
                    cx = e.clientX; cy = e.clientY;
                    px = e.pageX;   py = e.pageY;
                    ox = e.offsetX; oy = e.offsetY;
                    sx = e.screenX; sy = e.screenY;
                    lx = e.layerX;  ly = e.layerY;
                }
                function assign(e) {
                    e._ffix_cx = cx; e._ffix_cy = cy;
                    e._ffix_px = px; e._ffix_py = py;
                    e._ffix_ox = ox; e._ffix_oy = oy;
                    e._ffix_sx = sx; e._ffix_sy = sy;
                    e._ffix_lx = lx; e._ffix_ly = ly;
                }
                window.addEventListener('mousemove', update, true);
                window.addEventListener('dragover', update, true);
                // bug #505521 identifies these three listeners as problematic:
                // (although tests show 'dragstart' seems to work now, keep to be compatible)
                window.addEventListener('dragstart', assign, true);
                window.addEventListener('drag', assign, true);
                window.addEventListener('dragend', assign, true);

                var me = Object.getOwnPropertyDescriptors(window.MouseEvent.prototype),
                    ue = Object.getOwnPropertyDescriptors(window.UIEvent.prototype);
                function getter(prop,repl) {
                    return function() {return me[prop] && me[prop].get.call(this) || Number(this[repl]) || 0};
                }
                function layerGetter(prop,repl) {
                    return function() {return this.type === 'dragover' && ue[prop] ? ue[prop].get.call(this) : (Number(this[repl]) || 0)};
                }
                Object.defineProperties(window.DragEvent.prototype,{
                    clientX: {get: getter('clientX', '_ffix_cx')},
                    clientY: {get: getter('clientY', '_ffix_cy')},
                    pageX:   {get: getter('pageX', '_ffix_px')},
                    pageY:   {get: getter('pageY', '_ffix_py')},
                    offsetX: {get: getter('offsetX', '_ffix_ox')},
                    offsetY: {get: getter('offsetY', '_ffix_oy')},
                    screenX: {get: getter('screenX', '_ffix_sx')},
                    screenY: {get: getter('screenY', '_ffix_sy')},
                    x:       {get: getter('x', '_ffix_cx')},
                    y:       {get: getter('y', '_ffix_cy')},
                    layerX:  {get: layerGetter('layerX', '_ffix_lx')},
                    layerY:  {get: layerGetter('layerY', '_ffix_ly')}
                });
                })();
            }
        },
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
         * @param {string} selectID id of the select element
         * @param {string} labelID id of the associated label element
         * @param {string} title descriptor for the list selection generated by chosen
         */
        updateChosenAttributes(selectID = "", labelID = "", title = "List Selection") {
            let chosenInput = document.querySelector(`#${selectID}_chosen input.chosen-search-input`);
            let chosenSearchResults = document.querySelector(`#${selectID}-chosen-search-results`);
            if(chosenInput !== null) {
                chosenInput.setAttribute('role', 'combobox');
                chosenInput.setAttribute('aria-labelledby', labelID);
            }
            if(chosenSearchResults !== null) {
                chosenSearchResults.setAttribute('title', title);
                chosenSearchResults.setAttribute('role', 'listbox');
            }
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
         * @param {string} catID new form ID used to route after importing a form from within the form editor
         * @returns {object} main keys are categoryIDs. Values are obj w fields from non-built-in, enabled categories and workflows tables
         */
        getEnabledCategories(catID = '') {
            this.appIsLoadingCategories = true;
            try {
                fetch(`${this.APIroot}formStack/categoryList/allWithStaples`).then(res => {
                    res.json().then(data => {
                        this.allStapledFormCatIDs = {};
                        this.categories = {};
                        for(let i in data) {
                            this.categories[data[i].categoryID] = data[i];
                            data[i].stapledFormIDs.forEach(id => {
                                this.allStapledFormCatIDs[id] = this.allStapledFormCatIDs[id] === undefined ?
                                    1 : this.allStapledFormCatIDs[id] + 1;
                            });
                        }
                        this.appIsLoadingCategories = false;
                        if(catID && /^form_[0-9a-f]{5}$/i.test(catID) === true) {
                            this.$router.push({
                                name:'category',
                                query:{
                                    formID: catID,
                                }
                            });
                        }
                    });
                });
            } catch(error) {
                console.log('error getting categories', error);
            }
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
                    url: `${this.APIroot}form/indicator/list?x-filterData=timeAdded`,
                    success: (res)=> {},
                    error: (err) => console.log(err),
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
         * updates app array allStapledFormCatIDs (when possible) and stapledFormIds for specified categories object
         * @param {string} catID id of the form having a staple added or removed
         * @param {string} stapledCatID id of the form being merged/unmerged
         * @param {boolean} removeStaple indicates whether staple is being added or removed
         */
        updateStapledFormsInfo(catID = '', stapledCatID = '', removeStaple = false) {
            const formID = catID;
            if(removeStaple === true) {
                this.categories[formID].stapledFormIDs = this.categories[formID].stapledFormIDs.filter(id => id !== stapledCatID);
                if(this.allStapledFormCatIDs?.[stapledCatID] > 0) {
                    this.allStapledFormCatIDs[stapledCatID] = this.allStapledFormCatIDs[stapledCatID] - 1;
                } else {
                    console.log("check staple calc")
                }
            } else {
                this.allStapledFormCatIDs[stapledCatID] = this.allStapledFormCatIDs[stapledCatID] === undefined ?
                    1 : this.allStapledFormCatIDs[stapledCatID] + 1;
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
         * close dialog and reset dialog properties
         */
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.dialogFormContent = '';
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
            this.formSaveFunction = null;
            this.dialogData = null;
        },
        lastModalTab(event) {
            if (event?.shiftKey === false) {
                const close = document.getElementById('leaf-vue-dialog-close');
                if(close !== null){
                    close.focus();
                    event.preventDefault();
                }
            }
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
            this.setCustomDialogTitle('<h2>Customize Write Access</h2>');
            this.setFormDialogComponent('edit-collaborators-dialog');
            this.dialogButtonText = {confirm: 'Add', cancel: 'Close'};
            this.showFormDialog = true;
        },
        openIfThenDialog(indicatorID = 0, indicatorName = 'Untitled') {
            const name = this.truncateText(this.decodeAndStripHTML(indicatorName), 35);
            this.dialogData = {
                indicatorID,
            }
            this.dialogButtonText = {confirm: 'Save', cancel: 'Close'};
            this.setCustomDialogTitle(`<h2>Conditions For <span style="color: #005EA2;">${name} (${indicatorID})</span></h2>`);
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
                `<h2>Adding question to ${parentID}</h2>` : `<h2>Editing indicatorID ${indicatorID}</h2>`;
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
            this.dialogButtonText = {confirm: 'Import', cancel: 'Close'};
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
        openRestoreFieldOptionsDialog() {
            this.setCustomDialogTitle(`<h2>Restore Field</h2>`);
            this.setFormDialogComponent('restore-field-options-dialog');
            this.dialogButtonText = {confirm: 'Restore', cancel: 'Close'};
            this.showFormDialog = true;
        },
    }
}