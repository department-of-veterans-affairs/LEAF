import { computed } from 'vue';

import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import HistoryDialog from "@/common/components/HistoryDialog.js";
import IndicatorEditingDialog from "../components/dialog_content/IndicatorEditingDialog.js";
import AdvancedOptionsDialog from "../components/dialog_content/AdvancedOptionsDialog.js";
import NewFormDialog from "../components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "../components/dialog_content/ImportFormDialog.js";
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
            adjustingMenu: false,
            dragLI_Prefix: 'index_listing_',
            dragUL_Prefix: 'drop_area_parent_',
            listTracker: {},  //{indID:{parID, newParID, sort, listindex,},}. for tracking parID and sort changes
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
            showToolbars: true,
            sortOffset: 128, //number to subtract from listindex when comparing sort value to curr list index, and when posting new sort value
            updateKey: 0,
            appIsLoadingForm: false,
            focusedFormID: '',
            focusedFormTree: [],
            focusedIndicatorID: null,
            fileManagerTextFiles: [],
            previewHandler: null
        }
    },
    components: {
        LeafFormDialog,
        IndicatorEditingDialog,
        AdvancedOptionsDialog,
        NewFormDialog,
        ImportFormDialog,
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
        'formMenuState',
        'updateFormMenuState',
        'showLastUpdate',
        'openAdvancedOptionsDialog',
        'openIndicatorEditingDialog',
        'openNewFormDialog',
        'allStapledFormCatIDs',
        'decodeAndStripHTML',
        'truncateText',

        'showFormDialog',
        'dialogFormContent'
    ],
    beforeRouteEnter(to, from, next) {
        window.scrollTo(0,0);
        next(vm => {
            vm.getSiteSettings();
            vm.setDefaultAjaxResponseMessage();
            vm.getFileManagerTextFiles();
            if(!vm.appIsLoadingCategories && vm.$route.query.formID) {
                vm.getFormFromQueryParam();
            }
        });
    },
    mounted() {
        this.previewHandler = () => {
            this.adjustFormPreview(0);
        }
        window.addEventListener('resize', this.previewHandler);
    },
    unmounted() {
        window.removeEventListener('resize', this.previewHandler);
    },
    updated() {
        console.log('FE view updated')
        this.adjustFormPreview(this.focusedIndicatorID);
    },
    provide() {
        return {
            listTracker: computed(() => this.listTracker),
            showToolbars: computed(() => this.showToolbars),
            focusedIndicatorID: computed(() => this.focusedIndicatorID),
            fileManagerTextFiles: computed(() => this.fileManagerTextFiles),
            internalFormRecords: computed(() => this.internalFormRecords),
            appIsLoadingForm: computed(() => this.appIsLoadingForm),
            focusedFormTree: computed(() => this.focusedFormTree),
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
            makePreviewKey: this.makePreviewKey
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
        mainFormID() {
            return this.focusedFormRecord?.parentID === '' ?
                this.focusedFormRecord.categoryID : this.focusedFormRecord?.parentID || '';
        },
        noForm() {
            return !this.appIsLoadingForm && this.focusedFormID === '';
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
         * @returns {array} categories records that are internal forms of the main form
         */
        internalFormRecords() {
            let internalFormRecords = [];
            for(let c in this.categories) {
                if (this.categories[c].parentID === this.mainFormID && this.mainFormID !== '') {
                    internalFormRecords.push({...this.categories[c]});
                }
            }
            return internalFormRecords;
        },
        /**
         * @returns {array} of categories records for queried form and any staples
         */
        currentFormCollection() {
            let allRecords = [];
            if(Object.keys(this.currentCategoryQuery)?.length > 0) {
                const currStapleIDs = this.currentCategoryQuery?.stapledFormIDs || [];
                currStapleIDs.forEach(id => {
                    allRecords.push({...this.categories[id], formContextType: 'staple'});
                });

                const focusedFormType = this.currentCategoryQuery.parentID !== '' ?
                        'internal' :
                        this.allStapledFormCatIDs.includes(this.currentCategoryQuery?.categoryID || '') ?
                        'staple' : 'main form';
                allRecords.push({...this.currentCategoryQuery, formContextType: focusedFormType,});
            }
            return allRecords.sort((eleA, eleB) => eleA.sort - eleB.sort);
        },
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
        getFormFromQueryParam() {
            const formReg = /^form_[0-9a-f]{5}$/i;
            if (formReg.test(this.$route.query?.formID || '') === true) {
                const formID = this.$route.query.formID;
                if (this.categories[formID] === undefined) {
                    this.getFormByCategoryID(); //valid formID pattern, but form does not exist.  This will clear out info but also provide a message and link back
                } else {
                    //if the form does exist, check that an internal form was not entered (it would need to be explicitly entered to the url, but would cause issues)
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
         * @param {string} catID
         * @param {boolean} setFormLoading show loader
         * @returns {array} of objects with information about the form (indicators and structure relations)
         */
        getFormByCategoryID(catID = '', setFormLoading = false) {
            return new Promise((resolve, reject)=> {
                if (catID === '') {
                    this.focusedFormID = '';
                    this.focusedFormTree = [];
                    resolve();
                } else {
                    this.appIsLoadingForm = setFormLoading;
                    this.setDefaultAjaxResponseMessage();
                    $.ajax({
                        type: 'GET',
                        url: `${this.APIroot}form/_${catID}?childkeys=nonnumeric`,
                        success: (res)=> {
                            const formChanged = this.focusedFormID !== catID;
                            this.focusedFormID = catID || '';
                            this.focusedFormTree = res || [];
                            this.appIsLoadingForm = false;
                            if(formChanged) {
                                window.scrollTo(0,0);
                            }
                            resolve(res)
                        },
                        error: (err)=> reject(err)
                    });
                }
            });
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
                            resolve(data[indicatorID])
                            .catch(err => console.log(err));
                        }).catch(err => console.log(err));
                    });
                } catch (error) {
                    reject(error);
                }
            });
        },
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
         * get information about the indicator and open indicator editing
         * @param {number} indicatorID 
         */
        editQuestion(indicatorID = 0) {
            this.getIndicatorByID(indicatorID).then(indicator => {
                const parentID = indicator?.parentID || null;
                this.openIndicatorEditingDialog(indicatorID, parentID, indicator);
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
        /**
         * @param {Number|null} nodeID indicatorID of the form section selected in the Form Index
         */
        focusIndicator(nodeID = null) {
            this.focusedIndicatorID = nodeID;
        },
        /** used to update scrolling and form height. called after component update or screen resize. */
        adjustFormPreview(nodeID = 0) {
            console.log('adjusting', nodeID);
            setTimeout(() => { //clear stack
                const pad = 12;
                const elListItem = document.getElementById(`index_listing_${nodeID}`);
                const elFormatLabel = document.getElementById(`${nodeID}_format_label`);
                const elFormCard = document.getElementById(`form_card_${nodeID}`);
                let elPreview = document.getElementById(`form_entry_and_preview`);
                let elBlock = document.querySelector(`#form_entry_and_preview .printformblock`);
                if(!this.adjustingMenu && elPreview !== null && elBlock !== null) { 
                    this.adjustingMenu = true;
                    const height = elBlock.offsetHeight;
                    if (window.innerWidth < 600) { //small screen mode just resize
                        elBlock.style.top = '0px';
                        elPreview.style.height = (height + 2*pad) + 'px';
                    } else {
                        const top = +(elBlock.style.top || '').replace('px','');
                        let diff = 0;
                        if(elListItem !== null && elFormatLabel !== null) {     //details are open
                            diff = elListItem.getBoundingClientRect().top - elFormatLabel.getBoundingClientRect().top;
                            console.log('open diff li - label', diff);
                        } else if (elListItem !== null && elFormCard !== null) { //details are closed (card view)
                            diff = elListItem.getBoundingClientRect().top - elFormCard.getBoundingClientRect().top;
                            console.log('closed diff li - card', diff);
                        } else {
                            console.log('else', elListItem, elFormCard)
                            diff = -top + pad; //there is no list item on initial load, changed forms
                        }
                        const calcTop = top - pad + diff;
                        //if the preview/card is higher than the list item use 0 with elBlock height
                        const newTop = calcTop < 0 ? calcTop : 0;
                        const newEffectiveHeight = (newTop + height + 2*pad).toFixed(0) + 'px';
                        elBlock.style.top = newTop.toFixed(0) + 'px';
                        elPreview.style.height = newEffectiveHeight;

                        let tar = elFormatLabel || elFormCard;
                        if(tar !== null) {
                            const curColor = tar.style.backgroundColor;
                            tar.style.backgroundColor = '#feffd1';
                            setTimeout(() => {
                                tar.style.backgroundColor = curColor;
                            }, 400); //background-color transition is also 1s
                        }
                    }
                    setTimeout(() => {
                        this.adjustingMenu = false;
                    }, 400);
                }
            });
        },
        toggleToolbars() {
            this.focusedIndicatorID = null;
            this.showToolbars = !this.showToolbars;
        },
        /**
         * moves an item in the Form Index via the buttons that appear when the item is selected
         * @param {Object} event 
         * @param {number} indID of the list item to move
         * @param {boolean} moveup click/enter moves the item up (false moves it down)
         */
        moveListItem(event = {}, indID = 0, moveup = false) {
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
                this.focusIndicatorID = indID;
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
                    this.getFormByCategoryID(this.focusedFormID).then(()=> {
                        this.showLastUpdate('form_properties_last_update');
                        this.updateKey += 1; //used to force view updates since the formID has not changed
                    }).catch(err => console.log(err));
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
            if(event?.dataTransfer) {
                event.dataTransfer.dropEffect = 'move';
                event.dataTransfer.effectAllowed = 'move';
                event.dataTransfer.setData('text/plain', event.target.id);
                const indID = (event.target.id || '').replace(this.dragLI_Prefix, '');
                this.focusIndicator(+indID);
            }
        },
        onDrop(event = {}) {
            if(event?.dataTransfer && event.dataTransfer.effectAllowed === 'move') {
                event.preventDefault();
                const baseDropArea = document.querySelector('ul#base_drop_area');
                const draggedElID = event.dataTransfer.getData('text');
                const indID = parseInt(draggedElID.replace(this.dragLI_Prefix, ''));

                const parentEl = event.currentTarget; //NOTE: drop event is on the parent ul, the li is the el being moved
                const formParIndID = parentEl.id === "base_drop_area" ? null : parseInt(parentEl.id.replace(this.dragUL_Prefix, ''));

                const elsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
                const elLiToMove = document.getElementById(draggedElID);

                let success = false;
                //if the drop target ul has no items yet, just append
                if (elsLI.length === 0) {
                    try {
                        parentEl.append(elLiToMove);
                        this.updateListTracker(indID, formParIndID, 0);
                        success = true;
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
                                this.updateListTracker(indID, formParIndID, i);
                            });
                            success = true;
                        } catch(error) {
                            console.log(error);
                        }
                    }
                }
                if(success === true) {
                    //open the parent item if it is not open
                    const elClosestFormPage = elLiToMove.closest('ul#base_drop_area > li');
                    if(elClosestFormPage !== null && baseDropArea !== null && +formParIndID > 0 && !this.formMenuState[formParIndID]) {
                        this.updateFormMenuState(formParIndID, true, false);
                    }
                }
                if(parentEl.classList.contains('entered-drop-zone')){
                    event.target.classList.remove('entered-drop-zone');
                }
            }
        },
        /**
         * 
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
         * @param {number} indicatorID changes mode to edit if in preview mode, otherwise opens editor
         */
        handleNameClick(indicatorID = null) {
            this.focusIndicatorID = indicatorID;
            if (!this.showToolbars) {
                this.showToolbars = true;
            } else {
                if(indicatorID) {
                    this.editQuestion(indicatorID);
                }
            }
        },
        /**
         * @param {string} categoryID 
         * @param {number} len 
         * @returns 
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
        makePreviewKey(node) {
            return `${node.format}${node?.options?.join() || ''}_${node?.default || ''}`;
        }
    },
    watch: {
        appIsLoadingCategories(newVal, oldVal) {
            if(oldVal === true && this.$route.query.formID) {
                this.getFormFromQueryParam();
            }
        },
        "$route.query.formID"(newVal = '', oldVal = '') {
            if(!this.appIsLoadingCategories) {
                this.getFormFromQueryParam();
            }
        },
        sortOrParentChanged(newVal, oldVal) {
            if(newVal === true) {
                this.applySortAndParentID_Updates();
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
            The form you are looking for ({{ this.$route?.query?.formID }}) was not found.
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
            <edit-properties-panel :key="'panel_' + focusedFormID"></edit-properties-panel>

            <div id="form_index_and_editing" :data-focus="focusedIndicatorID">
                <!-- NOTE: INDEX (main + stapled forms, internals for selected form) -->
                <div id="form_index_display">
                    <div class="index_info">
                        <h3>{{ indexHeaderText }}</h3>
                        <img v-if="currentFormCollection.length > 1"
                            :src="libsPath + 'dynicons/svg/emblem-notice.svg'"
                            title="Details for the selected form are shown below" alt="" />
                        <button type="button" v-if="focusedFormTree.length > 0" id="indicator_toolbar_toggle" class="btn-general"
                            @click.stop="toggleToolbars()">
                            {{showToolbars ? 'Preview this form' : 'Edit this form'}}
                        </button>
                    </div>
                    <!-- LAYOUTS (including stapled forms) -->
                    <ul v-if="currentFormCollection.length > 0" :id="'layoutFormRecords_' + $route.query.formID">
                        <li v-for="form in currentFormCollection" :key="'form_layout_item_' + form.categoryID"
                            draggable="false" :class="{selected: form.categoryID === focusedFormID}">

                            <button type="button" @click="getFormByCategoryID(form.categoryID)"
                                class="layout-listitem" :disabled="form.categoryID === focusedFormID"
                                :title="'form ' + form.categoryID">
                                <span :style="{textDecoration: form.categoryID === focusedFormID ? 'none' : 'underline'}">
                                    {{shortFormNameStripped(form.categoryID, 38)}}&nbsp;
                                </span>
                                <span v-if="form.formContextType === 'staple'" role="img" aria="">📌</span>
                                <em v-show="form.categoryID === focusedFormID" style="font-weight: normal; text-decoration: none;">
                                    (selected)
                                </em>
                                <em v-show="form.categoryID === focusedFormRecord.parentID" style="font-weight: normal; text-decoration: none;">
                                    (parent)
                                </em>
                            </button>

                            <!-- DRAG-DROP ZONE -->
                            <ul v-if="focusedFormTree.length > 0 &&
                                (form.categoryID === focusedFormRecord.categoryID || form.categoryID === focusedFormRecord.parentID)"
                                id="base_drop_area" :key="'drop_zone_collection_' + form.categoryID + '_' + updateKey"
                                class="form-index-listing-ul"
                                data-effect-allowed="move"
                                @drop.stop="onDrop"
                                @dragover.prevent
                                @dragenter.prevent="onDragEnter"
                                @dragleave="onDragLeave">

                                <form-index-listing v-for="(formSection, i) in focusedFormTree"
                                    :id="'index_listing_' + formSection.indicatorID"
                                    :formPage=i
                                    :depth=0
                                    :formNode="formSection"
                                    :index=i
                                    :parentID=null
                                    :menuOpen="formMenuState?.[formSection.indicatorID] !== undefined ? formMenuState[formSection.indicatorID] : false"
                                    :key="'index_list_item_' + formSection.indicatorID"
                                    draggable="true"
                                    @dragstart.stop="startDrag">
                                </form-index-listing>
                            </ul>
                        </li>
                    </ul>
                    <button type="button" class="btn-general" style="width: 100%;"
                        @click="newQuestion(null)"
                        id="add_new_form_section_1"
                        title="Add new form section">
                        + Add Section
                    </button>
                    <hr />
                    <!-- INTERNAL FORMS -->
                    <div v-if="showToolbars">
                        <h3>Internal Forms</h3>
                        <ul v-if="internalFormRecords.length > 0" :id="'internalFormRecords_' + focusedFormID">
                            <li v-for="i in internalFormRecords" :key="'internal_' + i.categoryID">
                                <button type="button" @click="getFormByCategoryID(i.categoryID)"
                                    :class="{selected: i.categoryID === focusedFormID}">
                                    <span role="img" aria="">📃&nbsp;</span>
                                    {{shortFormNameStripped(i.categoryID, 20)}}
                                </button>
                            </li>
                        </ul>
                        <button v-if="focusedFormRecord?.parentID === ''" type="button" class="btn-general"
                            id="addInternalUse"
                            @click="openNewFormDialog(focusedFormRecord.categoryID)"
                            title="New Internal-Use Form" >
                            Add Internal-Use&nbsp;<span role="img" aria="">➕</span>
                        </button>
                    </div>
                </div>

                <!-- FORM EDITING AND ENTRY PREVIEW -->
                <div id="form_entry_and_preview">
                    <div class="printformblock" :data-update-key="updateKey">
                        <form-question-display v-for="(formSection, i) in focusedFormTree"
                            :key="'editing_display_' + formSection.indicatorID + makePreviewKey(formSection)"
                            :depth="0"
                            :formPage="i"
                            :formNode="formSection"
                            :menuOpen="formMenuState?.[formSection.indicatorID] !== undefined ? formMenuState[formSection.indicatorID] : true">
                        </form-question-display>

                        <button type="button" class="btn-general" style="width: 100%; margin-top: auto;"
                            @click="newQuestion(null)"
                            id="add_new_form_section_2"
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