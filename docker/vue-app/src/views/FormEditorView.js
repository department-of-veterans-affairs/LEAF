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
            listItems: {},  //object w key indID, vals parID, newParID, sort, listindex. for tracking parID and sort changes
            allowedConditionChildFormats: ['dropdown', 'text', 'multiselect', 'radio', 'checkboxes'],
            showToolbars: true
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
        'currSubformID',        //catID of the subform, if a subform, otherwise null
        'selectedFormTree',
        'categories',
        'internalFormRecords',
        'selectNewCategory',
        'selectNewFormNode',
        'selectedNodeIndicatorID',
        'selectedFormNode',
        'newQuestion',
        'currentCategorySelection',   //corresponds to currently selected form being viewed (form or subform)
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

        })
    },
    provide() {
        return {
            listItems: computed(() => this.listItems),
            showToolbars: computed(() => this.showToolbars),
            clearListItem: this.clearListItem,
            addToListItemsObject: this.addToListItemsObject,
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
        formID() {
            return this.currentCategorySelection?.categoryID || null;
        },
        currentSectionNumber() {
            let ID = parseInt(this.selectedFormNode?.indicatorID);
            let item = this.listItems[ID] || '';
            return (item !== '' && item.parentID === null) ? `${item.currSortIndex + 1} ` : '';
        }, 
        sortOrParentChanged() {
            return this.sortValuesToUpdate.length > 0 || this.parentIDsToUpdate.length > 0;
        },
        sortValuesToUpdate() {
            let indsToUpdate = [];
            for (let i in this.listItems) {
                if (this.listItems[i].sort !== this.listItems[i].listIndex) {
                    indsToUpdate.push({indicatorID: parseInt(i), ...this.listItems[i]});
                }
            }
            return indsToUpdate;
        },
        parentIDsToUpdate() {
            let indsToUpdate = [];
            //NOTE: headers have null as parentID, so listitems element newParentID is initialized with ''
            for (let i in this.listItems) {
                if (this.listItems[i].newParentID !== '' && this.listItems[i].parentID !== this.listItems[i].newParentID) {
                    indsToUpdate.push({indicatorID:  parseInt(i), ...this.listItems[i]});
                }
            }
            return indsToUpdate;
        },
    },
    methods: {
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
            const listitem = this.listItems[indID];

            if(moveup) {
                if(listitem.listIndex > 0) {
                    newElsLI.splice(listitem.listIndex - 1, 0, elToMove);
                    oldElsLI.forEach(li => parentEl.removeChild(li));
                    newElsLI.forEach((li, i) => {
                        const liIndID = parseInt(li.id.replace('index_listing_', ''));
                        parentEl.appendChild(li);
                        this.listItems[liIndID].listIndex = i;
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
                        this.listItems[liIndID].listIndex = i;
                    });
                    event?.currentTarget?.focus();
                }
            }
        },
        /**
         * posts sort and parentID values when user confirms updates with 'apply updates' in Form Index
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
                        success: (res) => {
                            //returns the new sort value
                            console.log('sort update res o/n', item.indicatorID, item.listIndex, res)
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
                        success: (res) => {
                            //returns the new parentID
                            console.log('par ID update res o/n', item.indicatorID, item.newParentID, res)
                        },
                        error: err => console.log('ind parentID post err', err)
                    })
                );
            });

            const all = updateSort.concat(updateParentID);
            Promise.all(all).then((res)=> {
                if (res.length > 0) {
                    this.selectNewCategory(this.formID, this.selectedNodeIndicatorID);
                }
            }).catch(err => console.log('an error has occurred', err));

        },
        clearListItem(indID) {
            delete this.listItems[indID];
        },
        /**
         * adds initial sort and parentID values to app listItems object
         * @param {Object} formNode from the Form Index listing
         * @param {number|null} parentID parent ID of the index listing (null for form sections)
         * @param {number} listIndex current index for that depth in the form index
         */
        addToListItemsObject(formNode = {}, parentID = null, listIndex = 0) {
            const { indicatorID, sort } = formNode;
            const item = { sort, currSortIndex: listIndex, parentID, listIndex, newParentID: '' }
            this.listItems[indicatorID] = item;
        },
        /**
         * updates the listIndex and parentID values for a specific indicator in app listItems when moved via the Form Index
         * @param {number} indID 
         * @param {number|null} formParIndID null for form Sections
         * @param {number} listIndex 
         */
        updateListItems(indID = 0, formParIndID = 0, listIndex = 0) {
            let item = {...this.listItems[indID]};
            item.listIndex = listIndex;
            item.newParentID = formParIndID;
            this.listItems[indID] = item;
        },
        startDrag(event = {}) {
            if(event?.dataTransfer) {
                event.dataTransfer.dropEffect = 'move';
                event.dataTransfer.effectAllowed = 'move';
                event.dataTransfer.setData('text/plain', event.target.id);
            }
        },
        onDrop(event = {}) {
            if(event?.dataTransfer) {
                event.preventDefault();
                const draggedElID = event.dataTransfer.getData('text');
                const parentEl = event.currentTarget; //drop event is on the parent ul

                const indID = parseInt(draggedElID.replace(this.dragLI_Prefix, ''));
                const formParIndID = parentEl.id === "base_drop_area" ? null : parseInt(parentEl.id.replace(this.dragUL_Prefix, ''));

                const elsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
                if (elsLI.length === 0) { //if the drop ul has no lis, just append it
                    try {
                        parentEl.append(document.getElementById(draggedElID));
                        this.updateListItems(indID, formParIndID, 0); 
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
                            this.updateListItems(indID, formParIndID, i);
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
            if(event?.target?.classList.contains('form-index-listing-ul')){
                event.target.classList.add('entered-drop-zone');
            }
        },
        toggleToolbars(event = {}) {
            //for debug use
            //console.log(this.listItems, this.parentIDsToUpdate, this.sortValuesToUpdate)
            event?.stopPropagation();
            if (event?.keyCode === 32) event.preventDefault();
            if (event.currentTarget.classList.contains('indicator-name-preview')) {
                this.showToolbars = true;
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
        /*
        selectForm(catID = '', setPrimary = false) {
            if (setPrimary === true) {
                this.$route.query.primary = this.currCategoryID;
            }
            console.log('route index', this.currCategoryID, this.$route)
            this.selectNewCategory(catID);
        }, */
    },
    template:`<div id="formEditor_content">
    <FormBrowser v-if="formID===null"></FormBrowser>

    <template v-else>
        <div v-if="appIsLoadingForm" style="border: 2px solid black; text-align: center; 
            font-size: 24px; font-weight: bold; padding: 16px;">
            Loading... 
            <img src="../images/largespinner.gif" alt="loading..." />
        </div>

        <template v-else>
            <!-- TOP INFO PANEL -->
            <edit-properties-panel :key="formID"></edit-properties-panel>

            <div id="form_index_and_editing">
                <!-- FORM INDEX -->
                <div id="form_index_display">
                    <div style="display:flex; align-items: center; justify-content: space-between; height: 28px;">
                        <h3 style="margin: 0;">Primary Form</h3>
                        <p id="updateStatus" style="display:none">TEST</p>
                        <button v-if="sortOrParentChanged" type="button" @click="applySortAndParentID_Updates" 
                            class="btn-general"
                            title="Apply form structure updates">Apply sorting changes</button>
                    </div>
                    <div style="margin: 1em 0">
                        <button v-if="selectedFormNode !== null" type="button" class="btn-general" style="width: 100%; margin-bottom: 0.5em;" 
                            @click="selectNewFormNode($event, null)" 
                            id="show_entire_form" 
                            title="Show entire form">Show entire form
                        </button>
                    </div>

                    <ul>
                    <template v-for="form in selectedCategoryWithStapledForms" :key="'primary_form_item_' + form.categoryID">
                        <li v-if="currentCategorySelection.categoryID === form.categoryID">
                            <ul id="base_drop_area"
                                class="form-index-listing-ul"
                                data-effect-allowed="move"
                                @drop.stop="onDrop"
                                @dragover.prevent
                                @dragenter.prevent="onDragEnter"
                                @dragleave="onDragLeave">

                                <form-index-listing v-for="(formSection, i) in selectedFormTree"
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

                        <li v-else>
                            <router-link :to="{ name: 'category', query: { formID: form.categoryID, main: formID }}" class="router-link">
                                {{shortFormNameStripped(form.categoryID, 28)}}
                            </router-link>
                        </li>
                    </template>
                    </ul>
                    <div style="margin: 1em 0 0 0">
                        <button type="button" class="btn-general" style="width: 100%" 
                            @click="newQuestion(null)"
                            id="add_new_form_section"
                            title="Add new form section">
                            + Add Section
                        </button>
                    </div>
                    <!-- TODO: NOTE: -->
                    <template v-if="internalFormRecords.length > 0">
                        <hr style="border: 1px solid #d0d0d4; margin: 1rem auto 0.5rem; width: 80%;" />
                        <b>Internal Forms</b>
                        <ul id="internalFormRecords">
                            <li v-for="i in internalFormRecords" :key="'internal_' + i.categoryID">
                                <router-link :id="i.categoryID" title="select internal form"
                                    :to="{ name: 'category', query: { formID: i.categoryID }}" class="router-link">
                                    {{shortFormNameStripped(i.categoryID, 28)}}
                                </router-link>
                            </li>
                        </ul>
                    </template>
                </div>

                <!-- NOTE: FORM EDITING AND ENTRY PREVIEW -->
                <template v-if="selectedFormTree.length > 0">
                    <!-- ENTIRE FORM EDIT / PREVIEW -->
                    <div v-if="selectedFormNode === null" id="form_entry_and_preview">
                        <div class="form-section-header" style="display: flex; height: 28px;">
                            <h3 style="margin: 0;">{{ stripAndDecodeHTML(currentCategorySelection.categoryName) }}</h3>
                            <button type="button" id="indicator_toolbar_toggle" class="btn-general"
                                @click.stop="toggleToolbars($event)">
                                {{showToolbars ? 'Preview This Section' : 'Edit This Section'}}
                            </button>
                        </div>
                        <template v-for="(formSection, i) in selectedFormTree" :key="'editing_display_' + formSection.indicatorID">
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