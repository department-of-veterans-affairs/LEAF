import { computed } from 'vue';

import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import HistoryDialog from "@/common/components/HistoryDialog.js";
import IndicatorEditingDialog from "../components/dialog_content/IndicatorEditingDialog.js";
import AdvancedOptionsDialog from "../components/dialog_content/AdvancedOptionsDialog.js";
import NewFormDialog from "../components/dialog_content/NewFormDialog.js";
import StapleFormDialog from "../components/dialog_content/StapleFormDialog.js";
import EditCollaboratorsDialog from "../components/dialog_content/EditCollaboratorsDialog.js";
import ConfirmDeleteDialog from "../components/dialog_content/ConfirmDeleteDialog.js";
import ConditionsEditorDialog from "../components/dialog_content/ConditionsEditorDialog.js";

import FormEditorMenu from "../components/form_editor_view/FormEditorMenu.js";
import FormQuestionDisplay from '../components/form_editor_view/FormQuestionDisplay.js';
import FormIndexListing from '../components/form_editor_view/FormIndexListing.js';
import EditPropertiesPanel from '../components/form_editor_view/EditPropertiesPanel.js';

export default {
    name: 'form-editor-view',
    data()  {
        return {
            dragLI_Prefix: 'index_listing_',
            dragUL_Prefix: 'drop_area_parent_',
            listTracker: {},
            allowedConditionChildFormats: [
                'dropdown',
                'text',
                'multiselect',
                'radio',
                'checkboxes',
                '',
                'fileupload',
                'image',
                'textarea',
                'orgchart_employee',
                'orgchart_group',
                'orgchart_position'
            ],
            previewMode: false,
            sortOffset: 128, //number to subtract from listindex when comparing or updating sort values
            updateKey: 0,
            appIsLoadingForm: false,
            focusedFormID: '',   //id of specific primary, staple or internal focused form.
            focusedFormTree: [], //detailed structure of the focused form.  Always a single form.
            previewTree: [],     //detailed structure of primary form and any staples.  Only used in preview mode, and only if primary has staples.
            focusedIndicatorID: null, //used for form focus management.
            hasCollaborators: false,
            fileManagerTextFiles: []
        }
    },
    components: {
        LeafFormDialog,
        IndicatorEditingDialog,
        AdvancedOptionsDialog,
        NewFormDialog,
        HistoryDialog,
        StapleFormDialog,
        EditCollaboratorsDialog,
        ConfirmDeleteDialog,
        ConditionsEditorDialog,

        FormEditorMenu,
        FormQuestionDisplay,
        FormIndexListing,
        EditPropertiesPanel
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'getSiteSettings',
        'setDefaultAjaxResponseMessage',
        'appIsLoadingCategories',
        'categories',
        'showLastUpdate',
        'openAdvancedOptionsDialog',
        'openIndicatorEditingDialog',
        'openNewFormDialog',
        'openStapleFormsDialog',
        'allStapledFormCatIDs',
        'decodeAndStripHTML',
        'truncateText',

        'showFormDialog',
        'dialogFormContent'
    ],
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getSiteSettings();
            vm.setDefaultAjaxResponseMessage();
            vm.getFileManagerTextFiles();
            if(!vm.appIsLoadingCategories && vm.queryID) {
                vm.getFormFromQueryParam();
            }
        });
    },
    mounted() {
        window.addEventListener("scroll", this.onScroll);
    },
    beforeUnmount() {
        window.removeEventListener("scroll", this.onScroll);
    },
    provide() {
        return {
            listTracker: computed(() => this.listTracker),
            previewMode: computed(() => this.previewMode),
            focusedIndicatorID: computed(() => this.focusedIndicatorID),
            fileManagerTextFiles: computed(() => this.fileManagerTextFiles),
            appIsLoadingForm: computed(() => this.appIsLoadingForm),
            queryID: computed(() => this.queryID),
            focusedFormID: computed(() => this.focusedFormID),
            focusedFormTree: computed(() => this.focusedFormTree),
            previewTree: computed(() => this.previewTree),
            focusedFormRecord: computed(() => this.focusedFormRecord),
            focusedFormIsSensitive: computed(() => this.focusedFormIsSensitive),
            noForm: computed(() => this.noForm),

            getFormByCategoryID: this.getFormByCategoryID,
            editAdvancedOptions: this.editAdvancedOptions,
            newQuestion: this.newQuestion,
            editQuestion: this.editQuestion,
            clearListItem: this.clearListItem,
            addToListTracker: this.addToListTracker,
            allowedConditionChildFormats: this.allowedConditionChildFormats,
            focusIndicator: this.focusIndicator,
            startDrag: this.startDrag,
            onDragEnter: this.onDragEnter,
            onDragLeave: this.onDragLeave,
            onDrop: this.onDrop,
            moveListItem: this.moveListItem,
            handleNameClick: this.handleNameClick,
            shortIndicatorNameStripped: this.shortIndicatorNameStripped,
            makePreviewKey: this.makePreviewKey,
            checkFormCollaborators: this.checkFormCollaborators
        }
    },
    computed: {
        queryID() {
            return this.$route.query.formID;
        },
        noForm() {
            return !this.appIsLoadingForm && this.focusedFormID === '';
        },
        /**
         * @returns {Object} current query from categories object from url query id.
         */
        currentCategoryQuery() {
            return this.categories[this.queryID] || {};
        },
        /**
         * @returns {Object} focused form record from categories object
         */
        focusedFormRecord() {
            return this.categories[this.focusedFormID] || {};
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
         * @returns {array} of categories records for queried form and any staples
         */
        currentFormCollection() {
            let allRecords = [];
            if(Object.keys(this.currentCategoryQuery)?.length > 0) {
                let mainInternals = [];
                for(let f in this.categories) {
                    if(this.categories[f].parentID === this.currentCategoryQuery.categoryID) {
                        mainInternals.push({...this.categories[f]});
                    }
                }
                const currStapleIDs = this.currentCategoryQuery?.stapledFormIDs || [];
                currStapleIDs.forEach(id => {
                    let stapleInternals = [];
                    for(let fs in this.categories) {
                        if(this.categories[fs].parentID === id) {
                            stapleInternals.push({...this.categories[fs]});
                        }
                    }
                    allRecords.push({...this.categories[id], formContextType: 'staple', internalForms: stapleInternals});
                });

                const focusedFormType = this.currentCategoryQuery.parentID !== '' ?
                        'internal' :
                        this.allStapledFormCatIDs.includes(this.currentCategoryQuery?.categoryID || '') ?
                        'staple' : 'main form';
                allRecords.push({...this.currentCategoryQuery, formContextType: focusedFormType, internalForms: mainInternals});
            }
            return allRecords.sort((eleA, eleB) => eleA.sort - eleB.sort);
        },
        /**
         * @returns concatenated string of formIDs associated with the current query.
         * Used to get the form pages for the preview display for a form if it has staples.
         */
        formPreviewIDs() {
            let ids = []
            this.currentFormCollection.forEach(form => {
                ids.push(form.categoryID);
            });
            return ids.join();
        },
        /**
         * @returns boolean.  Whether to use preview tree or focused tree for the form display.
         */
        usePreviewTree() {
            return this.focusedFormRecord?.stapledFormIDs?.length > 0 && this.previewMode && this.focusedFormID === this.queryID;
        },
        /**
         * @returns tree to display.  shorthand for template iterator.
         */
        fullFormTree() {
            return this.usePreviewTree ? this.previewTree : this.focusedFormTree;
        },
        firstEditModeIndicator() {
            return this.focusedFormTree?.[0]?.indicatorID || 0
        },
        /**
         * @returns boolean.  used to watch for index or parentID changes.  triggers sorting update if true
         */
        sortOrParentChanged() {
            return this.sortValuesToUpdate.length > 0 || this.parentIDsToUpdate.length > 0;
        },
        sortValuesToUpdate() {
            let indsToUpdate = [];
            for (let i in this.listTracker) {
                if (this.listTracker[i].sort !== this.listTracker[i].listIndex - this.sortOffset) {
                    indsToUpdate.push({indicatorID: parseInt(i), ...this.listTracker[i]});
                }
            }
            return indsToUpdate;
        },
        parentIDsToUpdate() {
            let indsToUpdate = [];
            //headers have null as their parentID, so newParentID is initialized with ''
            for (let i in this.listTracker) {
                if (this.listTracker[i].newParentID !== '' && this.listTracker[i].parentID !== this.listTracker[i].newParentID) {
                    indsToUpdate.push({indicatorID:  parseInt(i), ...this.listTracker[i]});
                }
            }
            return indsToUpdate;
        },
        /**
         * @returns string to display at top of form index.
         */
        indexHeaderText() {
            let text = '';
            if(this.focusedFormRecord.parentID !== '') {
                text = 'Internal Form';
            } else {
                text = this.currentFormCollection.length > 1 ? 'Form Layout' : 'Primary Form'
            }
            return text;
        }
    },
    methods: {
        /**
         * updates the position of the form options area in large screen displays
         */
        onScroll() {
            const elPreview = document.getElementById('form_entry_and_preview');
            let elIndex = document.getElementById('form_index_display');
            if(elPreview !== null && elIndex !== null) {
                const indexBoundTop = elIndex.getBoundingClientRect().top;
                const previewBoundTop = elPreview.getBoundingClientRect().top;
                const currTop = (elIndex.style.top || '0').replace('px', '');
                if (this.appIsLoadingForm || window.innerWidth <= 600 || (+currTop === 0 && indexBoundTop > 0)) {
                    elIndex.style.top = 0; //was preview
                } else {
                    const newTop = Math.round(-previewBoundTop - 8); //margin spacer
                    elIndex.style.top =  newTop < 0 ? 0 : newTop + 'px';
                }
            }
        },
        focusFirstIndicator() {
            const elEdit = document.getElementById(`edit_indicator_${this.firstEditModeIndicator}`);
            if(elEdit !== null) {
                elEdit.focus();
            }
        },
        /**
         * get details for the form specified in the url param.
         */
        getFormFromQueryParam() {
            const formReg = /^form_[0-9a-f]{5}$/i;
            if (formReg.test(this.queryID || '') === true) {
                const formID = this.queryID;
                if (this.categories[formID] === undefined) {
                    this.focusedFormID = '';
                    this.focusedFormTree = [];
                } else {
                    //an internal would need to be explicitly entered, but would cause issues
                    const parID = this.categories[formID].parentID;
                    if (parID === '') {
                        this.getFormByCategoryID(formID, true);
                    } else {
                        this.$router.push({name:'category', query:{formID: parID}});
                    }
                }

            } else { //if the value of formID is not a valid catID nav back to browser view
                this.$router.push({ name:'browser' });
            }
        },
        /**
         * Get details for a specific form and update focused form info
         * @param {string} catID
         * @param {boolean} setFormLoading show loader
         */
        getFormByCategoryID(catID = '', setFormLoading = false) {
            if (catID === '') {
                this.focusedFormID = '';
                this.focusedFormTree = [];
            } else {
                this.appIsLoadingForm = setFormLoading;
                this.setDefaultAjaxResponseMessage();
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${catID}?childkeys=nonnumeric`,
                    success: (res) => {
                        if(this.focusedFormID === catID) {
                            this.updateKey += 1; //ensures that the form editor view updates if the form ID does not change
                        }
                        this.focusedFormID = catID || '';
                        this.focusedFormTree = res || [];
                        this.appIsLoadingForm = false;
                    },
                    error: (err)=> console.log(err)
                });
            }
        },
        /**
         * @param {string} primaryID form that has staples attached.
         * Gets detailed information for multiple categories and sets focus ID after success.
         */
        getPreviewTree(primaryID = '') {
            if (primaryID !== '' && this.formPreviewIDs !== '') {
                this.appIsLoadingForm = true;
                this.setDefaultAjaxResponseMessage();
                try {
                    fetch(`${this.APIroot}form/specified?childkeys=nonnumeric&categoryIDs=${this.formPreviewIDs}`).then(res => {
                        res.json().then(data => {
                            if(data?.status?.code === 2) {
                                this.previewTree = data.data || [];
                                this.focusedFormID = primaryID;
                            } else {
                                console.log(data);
                            }
                            this.appIsLoadingForm = false;
                        }).catch(err => console.log(err));
                    }).catch(err => console.log(err));
                } catch(error) {
                    console.log(error);
                }
            }
        },
        /**
         * @param {number} indicatorID 
         * @returns {Object} with property information about the specific indicator
         */
        getIndicatorByID(indicatorID = 0) {
            return new Promise((resolve, reject)=> {
                try {
                    fetch(`${this.APIroot}formEditor/indicator/${indicatorID}`)
                    .then(res => {
                        res.json()
                        .then(data => {
                            resolve(data[indicatorID]);
                        }).catch(err => reject(err));
                    }).catch(err => reject(err));
                } catch (error) {
                    reject(error);
                }
            });
        },
        /**
         * get text and csv files from file manager.  Used for dropdown loading.
         */
        getFileManagerTextFiles() {
            try {
                fetch(`${this.APIroot}system/files`).then(res => {
                    res.json().then(data => {
                        const files = data || [];
                        this.fileManagerTextFiles = files.filter(
                            filename => filename.indexOf('.txt') > -1 || filename.indexOf('.csv') > -1
                        );
                    }).catch(err => console.log(err));
                });
            } catch (error) {
               console.log(error);
            }
        },
        /**
         * get indicator details and then open the advanced options (coding) modal
         * @param {number} indicatorID
         */
        editAdvancedOptions(indicatorID = 0) {
            this.getIndicatorByID(indicatorID).then(indicator => {
                this.openAdvancedOptionsDialog(indicator);
            }).catch(err => console.log('error getting indicator information', err));
        },
        /**
         * @param {number|null} parentID of the new subquestion.  null for new sections.
         */
        newQuestion(parentID = null) {
            this.openIndicatorEditingDialog(null, parentID, {});
        },
        /**
         * get information about the indicator and open indicator editing modal
         * @param {number} indicatorID 
         */
        editQuestion(indicatorID = 0) {
            this.getIndicatorByID(indicatorID).then(indicator => {
                this.focusedIndicatorID = indicatorID;
                const parentID = indicator?.parentID || null;
                this.openIndicatorEditingDialog(indicatorID, parentID, indicator);
            }).catch(err => console.log('error getting indicator information', err));
        },
        /**
         * recursively check for questions marked sensistive.  break on true.
         * @param {object} node form section
         * @returns boolean
         */
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
        /**
         * @param {Number|null} nodeID indicatorID of the form section selected in the Form Index
         */
        focusIndicator(nodeID = null) {
            this.focusedIndicatorID = nodeID;
        },
        /**
         * switch between edit and preview mode
         */
        toggleToolbars() {
            this.focusedIndicatorID = null;
            this.previewMode = !this.previewMode;
            this.updateKey += 1;
            if(this.usePreviewTree) {
                this.getPreviewTree(this.focusedFormID);
            } else {
                this.previewTree = [];
            }
        },
        /**
         * moves an item in the Form Index via the buttons that appear when the item is selected
         * @param {Object} event 
         * @param {number} indID of the list item to move
         * @param {boolean} moveup click/enter moves the item up (false moves it down)
         */
        moveListItem(event = {}, indID = 0, moveup = false) {
            if(!this.previewMode) {
                if (event?.keyCode === 32) event.preventDefault();
                const parentEl = event?.currentTarget?.closest('ul');
                const elToMove = document.getElementById(`index_listing_${indID}`);
                const oldElsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
                const newElsLI = oldElsLI.filter(li => li !== elToMove);
                const listitem = this.listTracker[indID];
                const condition = moveup === true ? listitem.listIndex > 0 : listitem.listIndex < oldElsLI.length - 1;
                const spliceLoc = moveup === true ? -1 : 1;
                if(condition) {
                    const oldIndex = listitem.listIndex;
                    newElsLI.splice(oldIndex + spliceLoc, 0, elToMove);
                    oldElsLI.forEach(li => parentEl.removeChild(li));
                    newElsLI.forEach((li, i) => {
                        const liIndID = parseInt(li.id.replace('index_listing_', ''));
                        parentEl.appendChild(li);
                        this.listTracker[liIndID].listIndex = i;
                    });
                }
            }
        },
        /**
         * posts sort and parentID values
         */
        applySortAndParentID_Updates() {
            let updateSort = [];
            if (this.sortValuesToUpdate.length > 0) {
                let sortData = [];
                this.sortValuesToUpdate.forEach(item => {
                    sortData.push({ indicatorID: item.indicatorID, sort: item.listIndex - this.sortOffset});
                });

                updateSort.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/sort/batch`,
                        data: {
                            sortData: sortData,
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {}, //returns array of updates, [{ indicatorID, sort },]
                        error: err => console.log('ind sort post err', err)
                    })
                );
            }

            let updateParentID = [];
            this.parentIDsToUpdate.forEach(item => {
                updateParentID.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/${item.indicatorID}/parentID`,
                        data: {
                            parentID: item.newParentID,
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {}, //returns null
                        error: err => console.log('ind parentID post err', err)
                    })
                );
            });

            const all = updateSort.concat(updateParentID);
            Promise.all(all).then((res)=> {
                if (res.length > 0) {
                    this.getFormByCategoryID(this.focusedFormID);
                    this.showLastUpdate('form_properties_last_update');
                }
            }).catch(err => console.log('an error has occurred', err));

        },
        /**
         * @param {number} indID remove a record from the tracker
         */
        clearListItem(indID = 0) {
            if (this.listTracker[indID]) {
                delete this.listTracker[indID];
            }
        },
        /**
         * adds initial sort and parentID values to app list tracker
         * @param {Object} formNode from the Form Index listing
         * @param {number|null} parentID parent ID of the index listing (null for form sections)
         * @param {number} listIndex current index for that depth in the form index
         */
        addToListTracker(formNode = {}, parentID = null, listIndex = 0) {
            const { indicatorID, sort } = formNode;
            const item = { sort, parentID, listIndex, newParentID: '', }
            this.listTracker[indicatorID] = item;
        },
        /**
         * updates the listIndex and newParentID values for a specific indicator in listtracker when moved via the Form Index
         * @param {number} indID 
         * @param {number|null} newParIndID null for form Sections
         * @param {number} listIndex
         */
        updateListTracker(indID = 0, newParIndID = 0, listIndex = 0) {
            let item = {...this.listTracker[indID]};
            item.listIndex = listIndex;
            item.newParentID = newParIndID;
            this.listTracker[indID] = item;
        },
        startDrag(event = {}) {
            if(!this.previewMode && event?.dataTransfer) {
                event.dataTransfer.dropEffect = 'move';
                event.dataTransfer.effectAllowed = 'move';
                event.dataTransfer.setData('text/plain', event.target.id);
                const indID = (event.target.id || '').replace(this.dragLI_Prefix, '');
                this.focusIndicator(+indID);
            }
        },
        onDrop(event = {}) {
            if(event?.dataTransfer && event.dataTransfer.effectAllowed === 'move') {
                const parentEl = event.currentTarget; //NOTE: drop event is on parent ul, the li is the el being moved
                if(parentEl.nodeName !== 'UL') return;

                event.preventDefault();
                const draggedElID = event.dataTransfer.getData('text');
                const elLiToMove = document.getElementById(draggedElID);

                const indID = parseInt(draggedElID.replace(this.dragLI_Prefix, ''));
                const parIndID = (parentEl.id || '').includes("base_drop_area") ? null : parseInt(parentEl.id.replace(this.dragUL_Prefix, ''));
                const elsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));

                //if the drop target ul has no items yet, just append
                if (elsLI.length === 0) {
                    try {
                        parentEl.append(elLiToMove);
                        this.updateListTracker(indID, parIndID, 0);
                    } catch (error) {
                        console.log(error);
                    }
                //otherwise, find the closest li to the drop-point and mv it if it has changed pos
                } else {
                    const parTop = parentEl.getBoundingClientRect().top;
                    const closest = elsLI.find(item => event.clientY - parTop <= item.offsetTop + item.offsetHeight/2) || null;
                    if (closest !== elLiToMove) {
                        try {
                            parentEl.insertBefore(elLiToMove, closest);
                            //update the new indexes
                            const newElsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
                            newElsLI.forEach((li, i) => {
                                const indID = parseInt(li.id.replace(this.dragLI_Prefix, ''));
                                this.updateListTracker(indID, parIndID, i);
                            });
                        } catch(error) {
                            console.log(error);
                        }
                    }
                }
                if(parentEl.classList.contains('entered-drop-zone')){
                    event.target.classList.remove('entered-drop-zone');
                }
            }
        },
        /**
         * @param {Object} event removes the drop zone hilite if target is ul
         */
        onDragLeave(event = {}) {
            if(event?.target?.classList.contains('form-index-listing-ul')){
                event.target.classList.remove('entered-drop-zone');
            }
        },
        /**
         * @param {Object} event adds the drop zone hilite if target is ul
         */
        onDragEnter(event = {}) {
            if(event?.dataTransfer && event.dataTransfer.effectAllowed === 'move' && event?.target?.classList.contains('form-index-listing-ul')){
                event.target.classList.add('entered-drop-zone');
            }
        },
        /**
         * @param {number} indicatorID focuses the indicator and changes mode to edit if in preview mode.
         */
        handleNameClick(categoryID = '', indicatorID = null) {
            this.focusedIndicatorID = indicatorID;
            if (this.previewMode) {
                this.previewMode = false;
                //previews show staples, so check if the form needs to change to the staple
                if(categoryID !== this.focusedFormID) {
                    this.getFormByCategoryID(categoryID, true);
                } else {
                    this.updateKey += 1;
                }
            }
        },
        /**
         * @param {string} categoryID 
         * @param {number} len 
         * @returns shortened form name
         */
        shortFormNameStripped(catID = '', len = 21) {
            const form = this.categories[catID] || '';
            const name = this.decodeAndStripHTML(form?.categoryName || 'Untitled');
            return this.truncateText(name, len).trim();
        },
        shortIndicatorNameStripped(text = '', len = 35) {
            const name = this.decodeAndStripHTML(text);
            return this.truncateText(name, len).trim() || '[ blank ]';
        },
        /**
         * @param {object} node form section
         * @returns string used to key the format preview.
         */
        makePreviewKey(node) {
            return `${node.format}${node?.options?.join() || ''}_${node?.default || ''}`;
        },
        checkFormCollaborators() {
            try {
                fetch(`${this.APIroot}formEditor/_${this.focusedFormID}/privileges`)
                .then(res => {
                    res.json().then(data => 
                        this.hasCollaborators = data?.length > 0)
                    .catch(err => console.log(err));
                }).catch(err => console.log(err));
            } catch(error) {
                console.log(error);
            }
        }
    },
    watch: {
        appIsLoadingCategories(newVal, oldVal) {
            if(oldVal === true && this.queryID) {
                this.getFormFromQueryParam();
            }
        },
        queryID(newVal = '', oldVal = '') {
            if(!this.appIsLoadingCategories) {
                this.getFormFromQueryParam();
            }
        },
        sortOrParentChanged(newVal, oldVal) {
            if(newVal === true && !this.previewMode) {
                this.applySortAndParentID_Updates();
            }
        },
        focusedFormID(newVal, oldVal) {
            window.scrollTo(0,0);
            if(newVal) {
                this.checkFormCollaborators();
                setTimeout(() => {
                    const elFormBtn = document.querySelector(`#layoutFormRecords_${this.queryID} li.selected button`);
                    if(elFormBtn !== null) {
                        elFormBtn.focus();
                    }
                });
            }
        }
    },
    template:`<FormEditorMenu />
    <section id="formEditor_content">
        <div v-if="appIsLoadingForm || appIsLoadingCategories" class="page_loading">
            Loading... 
            <img src="../images/largespinner.gif" alt="loading..." />
        </div>
        <div v-else-if="noForm">
            The form you are looking for ({{ queryID }}) was not found.
            <router-link :to="{ name: 'browser' }" class="router-link" style="display: inline-block;">
                Back to&nbsp;<b>Form Browser</b>
            </router-link>
        </div>

        <template v-else>
            <!-- admin home link, browser link, page title -->
            <h2 id="page_breadcrumbs">
                <a href="../admin" class="leaf-crumb-link" target="_blank" title="to Admin Home">Admin</a>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>
                <router-link :to="{ name: 'browser' }" class="leaf-crumb-link" title="to Form Browser">Form Browser</router-link>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>Form Editor
            </h2>
            <!-- TOP INFO PANEL -->
            <edit-properties-panel :key="'panel_' + focusedFormID" :hasCollaborators="hasCollaborators"></edit-properties-panel>

            <div id="form_index_and_editing" :data-focus="focusedIndicatorID">
                <!-- NOTE: INDEX (main + stapled forms, internals) -->
                <div id="form_index_display">
                    <div class="index_info">
                        <h3>{{ indexHeaderText }}</h3>
                        <button type="button" id="indicator_toolbar_toggle" class="btn-general"
                            style="margin-left:auto;"
                            @click.stop="toggleToolbars()">
                            {{previewMode ? 'Edit this Form' : 'Preview this Form'}}
                        </button>
                    </div>
                    <!-- LAYOUTS (FORMS AND INTERNAL/STAPLE OPTIONS ). -->
                    <ul v-if="!previewMode && currentFormCollection.length > 0" :id="'layoutFormRecords_' + queryID" :class="{preview: previewMode}">
                        <template v-for="form in currentFormCollection" :key="'form_layout_item_' + form.categoryID">
                            <li :class="{selected: form.categoryID === focusedFormID}">
                                <button type="button"
                                    @click="form.stapledFormIDs.length > 0 && previewMode && form.categoryID === queryID ?
                                        getPreviewTree(form.categoryID) : getFormByCategoryID(form.categoryID)"
                                    @click.ctrl.exact="focusFirstIndicator"
                                    class="layout-listitem"
                                    :title="'form ' + form.categoryID">
                                    <span v-if="form.formContextType === 'staple'" role="img" aria="" alt="">📌&nbsp;</span>
                                    <span v-if="form.formContextType === 'main form'" role="img" aria="" alt="">📂&nbsp;</span>
                                    <span :style="{textDecoration: form.categoryID === focusedFormID ? 'none' : 'underline'}">
                                        {{shortFormNameStripped(form.categoryID, 30)}}&nbsp;
                                    </span>
                                    <em v-show="form.categoryID === focusedFormID" style="font-weight: normal; text-decoration: none;">
                                        (selected)
                                    </em>
                                    <em v-show="form.categoryID === focusedFormRecord.parentID" style="font-weight: normal; text-decoration: none;">
                                        (parent)
                                    </em>
                                </button>
                                <!-- INTERNAL FORMS AND STAPLE OPTIONS -->
                                <div v-show="!previewMode || form.categoryID === focusedFormID || form.categoryID === focusedFormRecord.parentID" class="internal_forms">
                                    <ul v-if="form.internalForms.length > 0" :id="'internalFormRecords_' + form.categoryID">
                                        <li v-for="i in form.internalForms" :key="'internal_' + i.categoryID">
                                            <button type="button" @click="getFormByCategoryID(i.categoryID)"
                                                :class="{selected: i.categoryID === focusedFormID}">
                                                <span role="img" aria="" alt="">📃&nbsp;</span>
                                                {{shortFormNameStripped(i.categoryID, 30)}}
                                            </button>
                                        </li>
                                    </ul>
                                    <template v-if="form.categoryID===focusedFormID">
                                        <button v-if="!previewMode && form?.parentID === ''"
                                            type="button" class="btn-general"
                                            :id="'addInternalUse_' + form.categoryID"
                                            @click="openNewFormDialog(form.categoryID)"
                                            title="New Internal-Use Form" >
                                            <span role="img" aria="" alt="">➕&nbsp;</span>
                                            Add Internal-Use
                                        </button>
                                        <!-- staple options if not itself a staple and not an internal form -->
                                        <button v-if="!previewMode && !allStapledFormCatIDs.includes(form.categoryID) && form.parentID === ''"
                                            type="button" class="btn-general"
                                            :id="'addStaple_' + form.categoryID"
                                            @click="openStapleFormsDialog(form.categoryID)" title="Staple other form">
                                            <span role="img" aria="" alt="">📌&nbsp;</span>Staple other form 
                                        </button>
                                    </template>
                                </div>
                            </li>
                        </template>
                    </ul>
                    <!-- FORM MENU PREVIEW -->
                    <ul v-if="previewMode && fullFormTree.length > 0">
                        <li v-for="(page, i) in fullFormTree" :key="'preview_' + page.indicatorID + '_' + page.categoryID"
                            class="form_menu_preview">
                            {{ i + 1}}.
                            <span v-if="page.categoryID !== focusedFormID" role="img" aria="" alt="">📌</span>
                            {{ shortIndicatorNameStripped(page.description || page.name) }}
                        </li>
                    </ul>
                </div>

                <!-- FORM EDITING AND ENTRY PREVIEW -->
                <div id="form_entry_and_preview">
                    <div class="printformblock" :data-update-key="updateKey">

                        <!-- FORM DISPLAY WITH DRAG-DROP ZONE -->
                        <ul v-if="focusedFormTree.length > 0"
                            :id="'base_drop_area_' + focusedFormRecord.categoryID"
                            :key="'drop_zone_collection_' + focusedFormRecord.categoryID + '_' + updateKey"
                            class="form-index-listing-ul"
                            data-effect-allowed="move"
                            @drop.stop="onDrop($event)"
                            @dragover.prevent
                            @dragenter.prevent="onDragEnter"
                            @dragleave="onDragLeave">
    
                            <form-index-listing v-for="(formSection, i) in fullFormTree"
                                :id="'index_listing_' + formSection.indicatorID"
                                :categoryID="formSection.categoryID"
                                :formPage=i
                                :depth=0
                                :indicatorID="formSection.indicatorID"
                                :formNode="formSection"
                                :index=i
                                :parentID=null
                                :key="'index_list_item_' + formSection.indicatorID"
                                :draggable="!previewMode"
                                @dragstart.stop="startDrag">
                            </form-index-listing>
                        </ul>
                    </div>
                    <div v-if="!previewMode" id="blank_section_preview">
                        <button type="button" class="btn-general"
                            @click="newQuestion(null)"
                            title="Add new form section">
                            + Add Section
                        </button>
                    </div>
                </div>
            </div>
        </template>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent" @get-form="getFormByCategoryID"></component>
            </template>
        </leaf-form-dialog>
    </section>`
}