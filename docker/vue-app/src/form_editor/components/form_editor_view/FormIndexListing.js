import FormQuestionDisplay from './FormQuestionDisplay.js';

export default {
    name: 'form-index-listing',
    props: {
        categoryID: String,
        formPage: Number,
        depth: Number,
        indicatorID: Number,
        formNode: Object,
        index: Number,
        parentID: Number
    },
    components: {
        FormQuestionDisplay
    },
    inject: [
        'shortIndicatorNameStripped',
        'clearListItem',
        'addToListTracker',
        'focusedIndicatorID',
        'previewMode',
        'startDrag',
        'onDragEnter',
        'onDragLeave',
        'onDrop',
        'clickToMoveListItem',
        'makePreviewKey',
        'newQuestion',
    ],
    mounted() {
        //add to listTracker array to track indicatorID, parentID, sort and current index values
        //only track in edit mode because preview mode includes staples in the primary form list
        if(!this.previewMode) {
            this.addToListTracker(this.formNode, this.parentID, this.index);
        }
    },
    beforeUnmount() {
        this.clearListItem(this.formNode.indicatorID);
    },
    computed: {
        suffix() {
            return `${this.formNode.indicatorID}_${this.formNode.series}`;
        },
        printResponseID() {
            return `xhrIndicator_${this.suffix}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        }
    },
    template:`<li :title="'indicatorID: '+ indicatorID" :class="depth === 0 ? 'section_heading' : 'subindicator_heading'">
        <div class="printResponse" :class="{'form-header': depth === 0, preview: previewMode}" :id="printResponseID">
            <form-question-display
                :key="'editing_display_' + formNode.indicatorID + makePreviewKey(formNode)"
                :categoryID="categoryID"
                :depth="depth"
                :formPage="formPage"
                :index="index"
                :formNode="formNode">
            </form-question-display>
            
            <!-- NOTE: ul for drop zones always needs to be here in edit mode even if there are no current children -->
            <ul v-if="formNode.child !== null || !previewMode"
                class="form-index-listing-ul" :id="'drop_area_parent_'+ indicatorID"
                data-effect-allowed="move"
                @drop.stop="onDrop($event)"
                @dragover.prevent
                @dragenter.prevent="onDragEnter"
                @dragleave="onDragLeave">

                <form-index-listing v-for="(listItem, idx) in formNode.child"
                    :id="'index_listing_' + listItem.indicatorID"
                    :categoryID="categoryID"
                    :formPage=formPage
                    :depth="depth + 1"
                    :parentID="indicatorID"
                    :indicatorID="listItem.indicatorID"
                    :formNode="listItem"
                    :index="idx"
                    :key="'index_list_item_' + listItem.indicatorID"
                    :draggable="!previewMode"
                    @dragstart.stop="startDrag">
                </form-index-listing>
            </ul>
            <div v-if="depth === 0 && !previewMode" style="padding:0.5rem;">
                <button type="button" class="btn-general new_section_question"
                    aria-label="Add Question to Section"
                    @click="newQuestion(formNode.indicatorID)">
                    + Add Question to Section
                </button>
            </div>
        </div>
    </li>`
}