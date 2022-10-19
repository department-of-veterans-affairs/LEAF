import FormEditingDisplay from './FormEditingDisplay.js';
import FormIndexListing from './FormIndexListing.js';
import EditPropertiesPanel from './EditPropertiesPanel.js';

export default {
    data()  {
        return {
            formID: this.currentCategorySelection.categoryID,
            dragLI_Prefix: 'index_listing_',
            dragUL_Prefix: 'drop_area_parent_',
            listItems: {},  //object w key indID, vals parID, newParID, sort, listindex. for tracking parID and sort changes
            gridInstances: {},
            allowedConditionChildFormats: ['dropdown', 'text', 'multiselect'],
            showToolbars: true
        }
    },
    props: {
        orgchartPath: {
            type: String
        }
    },
    components: {
        FormEditingDisplay,
        FormIndexListing,
        EditPropertiesPanel
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'appIsLoadingCategoryInfo',
        'ajaxFormByCategoryID',
        'currCategoryID',       //always a main form
        'currSubformID',        //subform, if a subform
        'selectNewCategory',
        'selectNewFormNode',
        'selectedNodeIndicatorID',
        'selectedFormNode',
        'newQuestion',
        'currentCategorySelection',   //corresponds to currently selected form being viewed (form or subform)
        'currentCategoryIndicatorTotal'
    ],
    mounted() {
        console.log('MOUNTED VIEW CONTROLLER', this.currentCategorySelection.categoryID, this.currentCategoryIndicatorTotal);
    },
    provide() {
        return {
            listItems: Vue.computed(() => this.listItems),
            allListItemsAreAdded: Vue.computed(() => this.allListItemsAreAdded),
            gridInstances: Vue.computed(() => this.gridInstances),
            showToolbars: Vue.computed(() => this.showToolbars),
            orgchartPath: this.orgchartPath,
            addToListItemsObject: this.addToListItemsObject,
            allowedConditionChildFormats: this.allowedConditionChildFormats,
            startDrag: this.startDrag,
            onDragEnter: this.onDragEnter,
            onDragLeave: this.onDragLeave,
            onDrop: this.onDrop,
            moveListing: this.moveListing,
            updateGridInstances: this.updateGridInstances,
        }
    },
    computed: {
        currentSectionNumber() {
            let ID = parseInt(this.selectedFormNode?.indicatorID);
            let item = this.listItems[ID] || '';
            return item !== '' && this.allListItemsAreAdded && item.parentID===null ? `${item.sort + 1} ` : '';
        }, 
        allListItemsAreAdded() {
            return this.currentCategoryIndicatorTotal > 0 && this.currentCategoryIndicatorTotal === Object.keys(this.listItems).length;
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
        }
    },
    methods: {
        /**
         * NOTE: uses LEAF gridInput class for form data entry preview of grid format questions
         * @param {array} options array of objects with grid format properties (name, id, type)
         * @param {number} indicatorID 
         * @param {number} series 
         */
        updateGridInstances(options = [], indicatorID = 0, series = 1) {
            this.gridInstances[indicatorID] = new gridInput(options, indicatorID, series, '');
        },
        /**
         * moves an item in the Form Index via the buttons that appear when the item is selected
         * @param {Object} event 
         * @param {number} indID of the list item to move
         * @param {boolean} moveup click/enter moves the item up (false moves it down)
         */
        moveListing(event = {}, indID = 0, moveup = false) {
            if (event?.keyCode===32) event.preventDefault();
            const parentEl = event.currentTarget.closest('ul');
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
                    event.currentTarget.focus();
                } else {
                    console.log('is first item');
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
                    event.currentTarget.focus();
                } else {
                    console.log('is last item');
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
                        success: () => {},
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
                        success: () => {},
                        error: err => console.log('ind parentID post err', err)
                    })
                );
            });

            const all = updateSort.concat(updateParentID);
            Promise.all(all).then((res)=> {
                if (res.length > 0) {
                    this.selectNewCategory(this.formID, this.currSubformID !== null, this.selectedNodeIndicatorID);
                }
            });

        },
        /**
         * adds initial sort and parentID values to app listItems object
         * @param {Object} formNode from the Form Index listing
         * @param {number|null} parentID parent ID of the index listing (null for form sections)
         * @param {number} listIndex current index for that depth in the form index
         */
        addToListItemsObject(formNode = {}, parentID = null, listIndex = 0) {
            const { indicatorID, sort } = formNode;
            const item = { sort, parentID, listIndex, newParentID: '' }
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
        startDrag(evt = {}) {
            evt.dataTransfer.dropEffect = 'move';
            evt.dataTransfer.effectAllowed = 'move';
            evt.dataTransfer.setData('text/plain', evt.target.id);
        },
        onDrop(evt = {}) {
            evt.preventDefault();
            const draggedElID = evt.dataTransfer.getData('text');
            const parentEl = evt.currentTarget; //drop event is on the parent ul

            const indID = parseInt(draggedElID.replace(this.dragLI_Prefix, ''));
            const formParIndID = parentEl.id === "base_drop_area" ? null : parseInt(parentEl.id.replace(this.dragUL_Prefix, ''));

            const elsLI = Array.from(document.querySelectorAll(`#${parentEl.id} > li`));
            if (elsLI.length===0) { //if the drop ul has no lis, just append it
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
                    const newDist = el.getBoundingClientRect().top - evt.clientY;
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
                evt.target.classList.remove('entered-drop-zone');
            }
        },
        /**
         * 
         * @param {Object} evt removes the drop zone hilite if target is ul
         */
        onDragLeave(evt = {}) {
            if(evt.target.classList.contains('form-index-listing-ul')){
                evt.target.classList.remove('entered-drop-zone');
            }
        },
        /**
         * 
         * @param {Object} evt adds the drop zone hilite if target is ul
         */
        onDragEnter(evt = {}) {
            if(evt.target.classList.contains('form-index-listing-ul')){
                evt.target.classList.add('entered-drop-zone');
            }
        },
        toggleToolbars(event = {}) {
            event.stopPropagation();
            if (event?.keyCode===32) event.preventDefault();
            this.showToolbars=!this.showToolbars;
        },
    },
    watch: {
        allListItemsAreAdded(newVal, oldVal){
            console.log('watch triggered, allListItemsAreAdded (New/Old value): ', newVal, oldVal);
            /*
            //this would auto update legacy sort to from prev sort val to new index based value.
            if(newVal===true) {
                if (this.sortValuesToUpdate.length > 0) {
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
                                success: () => {},
                                error: err => console.log('ind sort post err', err)
                            })
                        );
                    });
                    Promise.all(updateSort).then((res)=> {
                        console.log('promise all:', updateSort, res);
                        if (res.length > 0) {
                            this.selectNewCategory(this.formID, this.currSubformID !== null);
                        }
                    });
                }
            } */
        }
    },
    template:`
    <div v-if="appIsLoadingCategoryInfo" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>

    <template v-else>
    <!-- TOP INFO PANEL -->
    <edit-properties-panel :key="currentCategorySelection.categoryID"></edit-properties-panel>

    <div id="form_index_and_editing">

        <!-- NOTE: FORM INDEX DISPLAY -->
        <div id="form_index_display">
            <div style="display:flex; align-items: center;">
                <h3 style="margin: 0; color: black;">Form Index</h3>
                <button v-if="sortOrParentChanged" @click="applySortAndParentID_Updates" 
                    class="can_update"
                    title="Apply form structure updates">Apply changes</button>
                <button v-else class="can_update" title="drag and drop sections and apply updates to change form structure">ℹ</button>
            </div>
            <div style="margin: 1em 0">
                <button v-if="selectedFormNode!==null" class="btn-general" style="width: 100%; margin-bottom: 0.5em;" 
                    @click="selectNewFormNode($event, null)" 
                    id="show_entire_form" 
                    title="Show entire form">Show entire form
                </button>
                <button v-else class="btn-general disabled" disabled="true" style="width: 100%; margin-bottom: 0.5em;">Viewing entire form</button>
                <button class="btn-general" style="width: 100%" 
                    @click="newQuestion(null)"
                    id="add_new_form_section"
                    title="Add new form section">
                    + Add Section
                </button>
            </div>

            <ul v-if="ajaxFormByCategoryID.length > 0"
                id="base_drop_area"
                class="form-index-listing-ul"
                data-effect-allowed="move"
                @drop.stop="onDrop"
                @dragover.prevent
                @dragenter.prevent="onDragEnter"
                @dragleave="onDragLeave">

                <form-index-listing v-for="(formSection, i) in ajaxFormByCategoryID"
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
        </div>

        <!-- NOTE: FORM EDITING AND ENTRY PREVIEW -->
        <div style="display:flex; flex-direction: column; width: 100%;">

            <template v-if="ajaxFormByCategoryID.length > 0 && allListItemsAreAdded">
                <!-- ENTIRE FORM EDIT / PREVIEW -->
                <div v-if="selectedFormNode===null" id="form_entry_and_preview">
                    <template v-for="(formSection, i) in ajaxFormByCategoryID" :key="'editing_display_' + formSection.indicatorID">
                        <div class="form-section-header" style="display: flex;">
                            <h3>Form Page {{i+1}}</h3>
                            <button v-if="i===0" id="indicator_toolbar_toggle" 
                                @click.stop="toggleToolbars($event)">
                                {{showToolbars ? 'Hide' : 'Show'}}&nbsp;toolbars
                            </button>
                        </div>
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
                        <h3>Form {{currentSectionNumber !== '' ? 'Page ' + currentSectionNumber : 'Selection'}}</h3>
                        <button id="indicator_toolbar_toggle"
                            @click.stop="toggleToolbars($event)">
                            {{showToolbars ? 'Hide' : 'Show'}}&nbsp;toolbars
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
    </div>
    </template>`
}