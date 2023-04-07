import { computed } from 'vue';

import FormBrowser from '@/components/form_editor_view/FormBrowser.js';
import FormEditingDisplay from '@/components/form_editor_view/FormEditingDisplay.js';
import FormIndexListing from '@/components/form_editor_view/FormIndexListing.js';
import EditPropertiesPanel from '@/components/form_editor_view/EditPropertiesPanel.js';

export default {
    name: 'form-editor-view',
    data()  {
        return {
            dragLI_Prefix: 'index_listing_',
            dragUL_Prefix: 'drop_area_parent_',
            listTracker: {},  //{indID:{parID, newParID, sort, listindex,},}. for tracking parID and sort changes
            allowedConditionChildFormats: ['dropdown', 'text', 'multiselect', 'radio', 'checkboxes'],
            showToolbars: true,
            sortOffset: 128, //number to subtract from listindex when comparing sort value to curr list index, and when posting new sort value
            sortLastUpdated: '',
            updateKey: 0,
        }
    },
    components: {
        FormEditingDisplay,
        FormIndexListing,
        EditPropertiesPanel,
        FormBrowser
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'setDefaultAjaxResponseMessage',
        'appIsLoadingCategoryList',
        'appIsLoadingForm',
        'categories',
        'internalFormRecords',
        'selectedNodeIndicatorID',
        'selectedFormNode',
        'getFormByCategoryID',
        'showLastUpdate',
        'openFormHistoryDialog',
        'newQuestion',
        'editQuestion',
        'focusedFormRecord',
        'focusedFormTree',
        'openNewFormDialog',
        'currentFormCollection',
        'stripAndDecodeHTML',
        'truncateText',
    ],
    mounted() {
        //console.log('MOUNTED FORM EDITOR VIEW');
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.setDefaultAjaxResponseMessage();
        });
    },
    provide() {
        return {
            listTracker: computed(() => this.listTracker),
            showToolbars: computed(() => this.showToolbars),
            clearListItem: this.clearListItem,
            addToListTracker: this.addToListTracker,
            allowedConditionChildFormats: this.allowedConditionChildFormats,
            startDrag: this.startDrag,
            onDragEnter: this.onDragEnter,
            onDragLeave: this.onDragLeave,
            onDrop: this.onDrop,
            moveListing: this.moveListing,
            toggleToolbars: this.toggleToolbars,
            makePreviewKey: this.makePreviewKey
        }
    },
    computed: {
        focusedFormID() {
            return this.focusedFormRecord?.categoryID || '';
        },
        currentSectionNumber() {
            let indID = parseInt(this.selectedFormNode?.indicatorID);
            const elHeaderItems = Array.from(document.querySelectorAll('#base_drop_area > li'));
            const elThisItem = document.getElementById(`index_listing_${indID}`);
            const index = elHeaderItems.indexOf(elThisItem);
            return index === -1 ? '' : index + 1;
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
        forceUpdate() {
            this.updateKey += 1;
        },
        /**
         * moves an item in the Form Index via the buttons that appear when the item is selected
         * @param {Object} event 
         * @param {number} indID of the list item to move
         * @param {boolean} moveup click/enter moves the item up (false moves it down)
         */
        moveListing(event = {}, indID = 0, moveup = false) {
            if (event?.keyCode === 32) event.preventDefault();
            const parentEl = event?.currentTarget?.closest('ul');
            const elToMove = document.getElementById(`index_listing_${indID}`);
            const oldElsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
            const newElsLI = oldElsLI.filter(li => li !== elToMove);
            const listitem = this.listTracker[indID];

            if(moveup) {
                if(listitem.listIndex > 0) {
                    newElsLI.splice(listitem.listIndex - 1, 0, elToMove);
                    oldElsLI.forEach(li => parentEl.removeChild(li));
                    newElsLI.forEach((li, i) => {
                        const liIndID = parseInt(li.id.replace('index_listing_', ''));
                        parentEl.appendChild(li);
                        this.listTracker[liIndID].listIndex = i;
                    });
                    event?.currentTarget?.focus();
                }
            } 
            else {
                if(listitem.listIndex < oldElsLI.length - 1) {
                    newElsLI.splice(listitem.listIndex + 1, 0, elToMove);
                    oldElsLI.forEach(li => parentEl.removeChild(li));
                    newElsLI.forEach((li, i) => {
                        const liIndID = parseInt(li.id.replace('index_listing_', ''));
                        parentEl.appendChild(li);
                        this.listTracker[liIndID].listIndex = i;
                    });
                    event?.currentTarget?.focus();
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
                    this.getFormByCategoryID(this.focusedFormID, this.selectedNodeIndicatorID).then(()=> {
                        this.sortLastUpdated = new Date().toLocaleString();
                        this.showLastUpdate('form_index_last_update', `last modified: ${this.sortLastUpdated}`);
                        this.forceUpdate();

                    }).catch(err => console.log(err));
                }
            }).catch(err => console.log('an error has occurred', err));

        },
        /**
         * adds initial sort and parentID values to app list tracker
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
            }
        },
        onDrop(event = {}) {
            if(event?.dataTransfer && event.dataTransfer.effectAllowed === 'move') {
                event.preventDefault();
                const draggedElID = event.dataTransfer.getData('text');
                const parentEl = event.currentTarget; //drop event is on the parent ul

                const indID = parseInt(draggedElID.replace(this.dragLI_Prefix, ''));
                const formParIndID = parentEl.id === "base_drop_area" ? null : parseInt(parentEl.id.replace(this.dragUL_Prefix, ''));

                const elsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
                if (elsLI.length === 0) { //if the drop ul has no lis, just append it
                    try {
                        parentEl.append(document.getElementById(draggedElID));
                        this.updateListTracker(indID, formParIndID, 0);
                        //TODO: not certain if needed - old parent list updates? (it would just batch on the next load otherwise)
                    } catch (error) {
                        console.log(error);
                    }
                    
                } else { //otherwise, find the closest li to the droppoint to insert before
                    let dist = 9999;
                    let closestLI_id = null;
                    elsLI.forEach(el => {
                        const newDist = el.getBoundingClientRect().top - event.clientY;
                        if(el.id !== draggedElID && newDist > 0 && newDist < dist) {
                            dist = newDist;
                            closestLI_id = el.id;
                        }
                    });
                
                    try {
                        if(closestLI_id !== null) {
                            parentEl.insertBefore(document.getElementById(draggedElID), document.getElementById(closestLI_id));
                        } else {
                            //it's at the end of the list
                            parentEl.append(document.getElementById(draggedElID));
                        }
                        //check the new indexes
                        const newElsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
                        newElsLI.forEach((li,i) => {
                            const indID = parseInt(li.id.replace(this.dragLI_Prefix, ''));
                            this.updateListTracker(indID, formParIndID, i);
                        });
                    } catch(error) {
                        console.log(error);
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
         * 
         * @param {Object} event adds the drop zone hilite if target is ul
         */
        onDragEnter(event = {}) {
            if(event?.dataTransfer && event.dataTransfer.effectAllowed === 'move' && event?.target?.classList.contains('form-index-listing-ul')){
                event.target.classList.add('entered-drop-zone');
            }
        },
        toggleToolbars(event = {}, indicatorID = null) {
            event?.stopPropagation();
            if (event?.keyCode === 32) event.preventDefault();
            if (event.currentTarget.classList.contains('indicator-name-preview')) {
                if (!this.showToolbars) {
                    const id = event.currentTarget.id;
                    const initialTop = event.currentTarget.getBoundingClientRect().top;
                    this.showToolbars = true;
                    setTimeout(() => {
                        const finalTop = document.getElementById(id).getBoundingClientRect().top;
                        window.scrollBy(0, finalTop - initialTop);
                    });
                } else {
                    if(indicatorID) {
                        this.editQuestion(indicatorID);
                    }
                }
            } else {
                this.showToolbars = !this.showToolbars;
            }
        },
        /**
         * //NOTE: uses XSSHelpers.js
         * @param {string} categoryID 
         * @param {number} len 
         * @returns 
         */
        shortFormNameStripped(catID = '', len = 21) {
            const form = this.categories[catID] || '';
            const name = this.stripAndDecodeHTML(form?.categoryName || '') || 'Untitled';
            return this.truncateText(name, len).trim();
        },
        layoutBtnIsDisabled(form) {
            return form.categoryID === this.focusedFormRecord.categoryID && this.selectedFormNode === null
        },
        makePreviewKey(node) {
            return `${node.format}${node?.options?.join() || ''}_${node?.default || ''}`;
        }
    },
    watch: {
        sortOrParentChanged(newVal, oldVal) {
            if(newVal === true) {
                this.applySortAndParentID_Updates();
            }
        }
    },
    template:`<div id="formEditor_content">
    <div v-if="appIsLoadingForm || appIsLoadingCategoryList" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>

    <template v-else>
        <FormBrowser v-if="focusedFormID===''"></FormBrowser>

        <template v-else>
            <!-- TOP INFO PANEL -->
            <edit-properties-panel :key="'panel_' + focusedFormID"></edit-properties-panel>

            <div id="form_index_and_editing">
                <!-- FORM INDEX -->
                <div id="form_index_display">
                    <div style="display:flex; align-items: center; justify-content: space-between; height: 28px; margin-bottom: 0.5rem;">
                        <h3 style="margin: 0; color: black;">{{ indexHeaderText }}</h3>
                        <img v-if="currentFormCollection.length > 1" 
                            :src="libsPath + 'dynicons/svg/emblem-notice.svg'"
                            style="width: 16px; margin-left: 0.25rem; margin-right:auto;" 
                            title="Details for the selected form are shown below" alt="" />
                        <button type="button" id="form_index_last_update" @click.prevent="openFormHistoryDialog"
                            :style="{display: sortLastUpdated==='' ? 'none' : 'flex'}">
                        </button>
                    </div>
                    <!-- FORM LAYOUT OVERVIEW -->
                    <div v-if="currentFormCollection.length > 1" :id="'layoutFormRecords_' + $route.query.formID">
                        <ul>
                            <li v-for="form in currentFormCollection" :key="'form_layout_item_' + form.categoryID" draggable="false">
                                <button type="button" @click="getFormByCategoryID(form.categoryID)"
                                    class="layout-listitem" :disabled="layoutBtnIsDisabled(form)"
                                    :title="'form ' + form.categoryID">
                                    <span :style="{textDecoration: layoutBtnIsDisabled(form) ? 'none' : 'underline'}">
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
                                <!-- focused drop zone for collection -->
                                <ul v-if="form.categoryID === focusedFormID && focusedFormTree.length > 0"
                                    id="base_drop_area" :key="'drop_zone_collection_' + form.categoryID + '_' + updateKey"
                                    class="form-index-listing-ul"
                                    data-effect-allowed="move"
                                    @drop.stop="onDrop"
                                    @dragover.prevent
                                    @dragenter.prevent="onDragEnter"
                                    @dragleave="onDragLeave">

                                    <form-index-listing v-for="(formSection, i) in focusedFormTree"
                                        :id="'index_listing_'+formSection.indicatorID"
                                        :depth=0
                                        :formNode="formSection"
                                        :index=i
                                        :parentID=null
                                        :key="'index_list_item_' + formSection.indicatorID"
                                        draggable="true"
                                        @dragstart.stop="startDrag">
                                    </form-index-listing>
                                </ul>
                            </li>
                        </ul>
                    </div>
                    <!-- focused drop zone for single form -->
                    <template v-else>
                        <ul v-if="focusedFormTree.length > 0"
                            id="base_drop_area" :key="'drop_zone_primary' + updateKey"
                            class="form-index-listing-ul"
                            data-effect-allowed="move"
                            @drop.stop="onDrop"
                            @dragover.prevent
                            @dragenter.prevent="onDragEnter"
                            @dragleave="onDragLeave">

                            <form-index-listing v-for="(formSection, i) in focusedFormTree"
                                :id="'index_listing_'+formSection.indicatorID"
                                :depth=0
                                :formNode="formSection"
                                :index=i
                                :parentID=null
                                :key="'index_list_item_' + formSection.indicatorID"
                                draggable="true"
                                @dragstart.stop="startDrag">
                            </form-index-listing>
                        </ul>
                    </template>

                    <div style="margin: 0.5rem 0 0 0">
                        <button type="button" class="btn-general" style="width: 100%" 
                            @click="newQuestion(null)"
                            id="add_new_form_section"
                            title="Add new form section">
                            + Add Section
                        </button>
                    </div>
                    <!-- INTERNAL FORMS SECTION -->
                    <div v-if="focusedFormRecord?.parentID === '' && focusedFormTree.length > 0"
                        :id="'internalFormRecords_' + focusedFormID"  style="margin-top: 0.5rem;">
                        <ul>
                            <li>
                                <button type="button" id="addInternalUse" @click="openNewFormDialog($event, focusedFormRecord.categoryID)"
                                    title="New Internal-Use Form" style="color: black;">
                                    Add Internal-Use&nbsp;<span role="img" aria="">➕</span>
                                </button>
                            </li>
                            <li v-for="i in internalFormRecords" :key="'internal_' + i.categoryID">
                                <button @click="getFormByCategoryID(i.categoryID)">
                                    <span class="internal">
                                        {{shortFormNameStripped(i.categoryID, 45)}}
                                    </span>
                                </button>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- NOTE: FORM EDITING AND ENTRY PREVIEW -->
                <template v-if="focusedFormTree.length > 0">
                    <!-- ENTIRE FORM EDIT / PREVIEW -->
                    <div v-if="selectedFormNode === null" id="form_entry_and_preview">
                        <div class="form-section-header" style="display: flex;">
                            <h3 style="margin: 0; color: black;">Form Editing and Preview</h3>
                            <button type="button" id="indicator_toolbar_toggle" class="btn-general"
                                @click.stop="toggleToolbars($event)">
                                {{showToolbars ? 'Preview This Section' : 'Edit This Section'}}
                            </button>
                        </div>
                        <template v-for="(formSection, i) in focusedFormTree" :key="'editing_display_' + formSection.indicatorID">
                            <div class="printformblock">
                                <form-editing-display 
                                    :depth="0"
                                    :formNode="formSection"
                                    :index="i"
                                    :key="'FED_' + formSection.indicatorID + makePreviewKey(formSection)">
                                </form-editing-display>
                            </div>
                        </template>
                    </div>
                    <!-- SUBSECTION EDIT / PREVIEW -->
                    <div v-else id="form_entry_and_preview">
                        <div class="form-section-header" style="display: flex;">
                            <h3 style="margin: 0; color: black;">Form {{currentSectionNumber !== '' ? 'Page ' + currentSectionNumber : 'Selection'}}</h3>
                            <button type="button" id="indicator_toolbar_toggle" class="btn-general"
                                @click.stop="toggleToolbars($event)">
                                {{showToolbars ? 'Preview This Section' : 'Edit This Section'}}
                            </button>
                        </div>
                        <div class="printformblock">
                            <form-editing-display 
                                :depth="0"
                                :formNode="selectedFormNode"
                                :index="-1"
                                :key="'FED_' + selectedFormNode.indicatorID + makePreviewKey(selectedFormNode)">
                            </form-editing-display>
                        </div>
                    </div>
                </template>
            </div>
        </template>
    </template>
</div>`
}