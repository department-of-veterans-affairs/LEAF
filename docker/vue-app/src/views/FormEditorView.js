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
            listTracker: {},  //object w key indID, vals parID, newParID, sort, listindex. for tracking parID and sort changes
            allowedConditionChildFormats: ['dropdown', 'text', 'multiselect', 'radio', 'checkboxes'],
            showToolbars: true,
            sortLastUpdated: ''
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
        'appIsLoadingForm',
        'focusedFormTree',
        'categories',
        'internalFormRecords',
        'selectNewCategory',
        'selectNewFormNode',
        'selectedNodeIndicatorID',
        'selectedFormNode',
        'getFormByCategoryID',
        'updateFocusedFormTree',
        'showLastUpdate',
        'openFormHistoryDialog',
        'newQuestion',
        'focusedFormRecord',
        'selectedCategoryWithStapledForms',
        'stripAndDecodeHTML',
        'truncateText'
    ],
    mounted() {
        console.log('MOUNTED FORM EDITOR VIEW');
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            console.log('entered main/forms route');
            console.log(vm.$route.query.formID);
            //load catagories etc.  if the q is not empty, then get the specific form
        })
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
            toggleToolbars: this.toggleToolbars
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
                if (this.listTracker[i].sort !== this.listTracker[i].listIndex) {
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
    },
    methods: {
        setFocusedForm(catID) {
            this.getFormByCategoryID(catID).then(res => {
                this.updateFocusedFormTree(catID, res);
            });
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
            this.sortValuesToUpdate.forEach(item => {
                updateSort.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/${item.indicatorID}/sort`,
                        data: {
                            sort: item.listIndex,
                            CSRFToken: this.CSRFToken
                        },
                        success: () => { //returns empty array
                        },
                        error: err => console.log('ind sort post err', err)
                    })
                );
            });
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
                        success: () => { //returns null
                        },
                        error: err => console.log('ind parentID post err', err)
                    })
                );
            });

            const all = updateSort.concat(updateParentID);
            Promise.all(all).then((res)=> {
                if (res.length > 0) {
                    this.getFormByCategoryID(this.focusedFormID).then(res => {
                        this.updateFocusedFormTree(this.focusedFormID, res);
                        this.sortValuesToUpdate.forEach(item => {
                            this.listTracker[item.indicatorID].sort = item.listIndex;
                        });
                        this.parentIDsToUpdate.forEach(item => {
                            this.listTracker[item.indicatorID].parentID = item.newParentID;
                            this.listTracker[item.indicatorID].newParentID = '';
                        });
                        this.sortLastUpdated = new Date().toDateString();
                        this.showLastUpdate('form_index_last_update', `last modified: ${this.sortLastUpdated}`);

                        let elSublistDuplicates = Array.from(document.querySelectorAll('ul#base_drop_area > li.subindicator_heading'));
                        elSublistDuplicates.forEach(el => document.getElementById('base_drop_area').removeChild(el));

                    }).catch(err => console.log(err));
                }
            }).catch(err => console.log('an error has occurred', err));

        },
        clearListItem(indID) {
            delete this.listTracker[indID];
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
        toggleToolbars(event = {}) {
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
    },
    watch: {
        sortOrParentChanged(newVal, oldVal) {
            if(newVal === true) {
                this.applySortAndParentID_Updates();
            }
        }
    },
    template:`<div id="formEditor_content">
    <FormBrowser v-if="focusedFormID===''"></FormBrowser>

    <template v-else>
        <div v-if="appIsLoadingForm" style="border: 2px solid black; text-align: center; 
            font-size: 24px; font-weight: bold; padding: 16px;">
            Loading... 
            <img src="../images/largespinner.gif" alt="loading..." />
        </div>

        <template v-else>
            <!-- TOP INFO PANEL -->
            <edit-properties-panel :key="'panel_' + focusedFormID"></edit-properties-panel>

            <div id="form_index_and_editing">
                <!-- FORM INDEX -->
                <div id="form_index_display">
                    <div style="display:flex; align-items: center; justify-content: space-between; height: 28px;">
                        <h3 style="margin: 0;">Form Index</h3>
                        <button type="button" id="form_index_last_update" @click.prevent="openFormHistoryDialog"
                            :style="{display: sortLastUpdated==='' ? 'none' : 'flex'}">
                        </button>
                    </div>
                    <div style="margin: 1em 0">
                        <button v-if="selectedFormNode !== null" type="button" class="btn-general" style="width: 100%; margin-bottom: 0.5em;" 
                            @click="selectNewFormNode($event, null)" 
                            id="show_entire_form" 
                            title="Show entire form">Show entire form
                        </button>
                    </div>

                    <!-- focused drop zone -->
                    <ul v-if="focusedFormTree.length > 0" id="base_drop_area"
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
                    <div style="margin: 1em 0 0 0">
                        <button type="button" class="btn-general" style="width: 100%" 
                            @click="newQuestion(null)"
                            id="add_new_form_section"
                            title="Add new form section">
                            + Add Section
                        </button>
                    </div>
                    <!-- INTERNAL FORMS SECTION -->
                    <div v-if="internalFormRecords.length > 0" :id="'internalFormRecords_' + focusedFormID">
                        <div><b>Internal Forms</b></div>
                        <ul>
                            <li v-for="i in internalFormRecords" :key="'internal_' + i.categoryID">
                                <button v-if="focusedFormID === i.categoryID" disabled>
                                    {{shortFormNameStripped(i.categoryID, 28)}}<em>&nbsp;(selected)</em>
                                </button>
                                <button @click="setFocusedForm(i.categoryID)">
                                    {{shortFormNameStripped(i.categoryID, 28)}}
                                </button>
                            </li>
                        </ul>
                    </div>
                    <!-- FORM LAYOUT OVERVIEW (if there are staples, this shows the order, and used to changed the focused form) -->
                    <div v-if="selectedCategoryWithStapledForms.length > 1" :id="'layoutFormRecords_' + $route.query.formID">
                        <div><b>Form Layout</b></div>
                        <ul>
                            <li v-for="form in selectedCategoryWithStapledForms"
                            :key="'primary_form_item_' + form.categoryID" class="stapled-form-link" draggable="false">
                                <button @click="setFocusedForm(form.categoryID)">
                                    {{shortFormNameStripped(form.categoryID, 28)}}&nbsp;<span><em>({{form.formContextType}})</em></span>
                                </button>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- NOTE: FORM EDITING AND ENTRY PREVIEW -->
                <template v-if="focusedFormTree.length > 0">
                    <!-- ENTIRE FORM EDIT / PREVIEW -->
                    <div v-if="selectedFormNode === null" id="form_entry_and_preview">
                        <div class="form-section-header" style="display: flex; height: 32px;">
                            <h3 style="margin: 0;">{{ stripAndDecodeHTML(focusedFormRecord.categoryName) }}</h3>
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
                                    :key="'FED_' + formSection.indicatorID">
                                </form-editing-display>
                            </div>
                        </template>
                    </div>
                    <!-- SUBSECTION EDIT / PREVIEW -->
                    <div v-else id="form_entry_and_preview">
                        <div class="form-section-header" style="display: flex;">
                            <h3 style="margin: 0;">Form {{currentSectionNumber !== '' ? 'Page ' + currentSectionNumber : 'Selection'}}</h3>
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
                                :key="'FED_' + selectedFormNode.indicatorID">
                            </form-editing-display>
                        </div>
                    </div>
                </template>
            </div>
        </template>
    </template>
</div>`
}