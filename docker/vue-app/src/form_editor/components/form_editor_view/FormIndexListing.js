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
        currentListLength: Number,
        parentID: Number
    },
    components: {
        FormQuestionDisplay
    },
    inject: [
        'shortIndicatorNameStripped',
        'clearListItem',
        'addToListTracker',
        'previewMode',
        'toggleIndicatorFocus',
        'clickToMoveListItem',
        'focusedIndicatorID',
        'startDrag',
        'endDrag',
        'handleOnDragCustomizations',
        'onDragEnter',
        'onDragLeave',
        'onDrop',
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
        },
        hasClickToMoveOptions() {
            return this.currentListLength > 1;
        }
    },
    template:`<li :title="'indicatorID: '+ indicatorID" :class="depth === 0 ? 'section_heading' : 'subindicator_heading'">
        <div class="printResponse" :class="{'form-header': depth === 0, preview: previewMode}" :id="printResponseID">
            <!-- VISIBLE DRAG INDICATOR (event is on li itself) / CLICK UP DOWN options -->

            <div v-show="!previewMode" class="move_question_container">
                <div v-show="!previewMode" :id="'index_listing_' + indicatorID + '_button'"
                    :title="'drag to move indicatorID ' + indicatorID + '.'"
                    class="drag_question_handle">
                    <div role="img" aria-hidden="true" alt="" class="icon_drag" :title="'drag to move indicatorID ' + indicatorID + '.'">∷</div>
                </div>
                <button v-show="hasClickToMoveOptions" type="button"
                    aria-label="Click to move options" class="focus_indicator_button"
                    :aria-controls="'click_to_move_options_' + indicatorID"
                    :aria-expanded="indicatorID === focusedIndicatorID"
                    title="Click to move options"
                    @click="toggleIndicatorFocus(indicatorID)">↕
                </button>
                <div v-show="indicatorID === focusedIndicatorID && hasClickToMoveOptions"
                    :id="'click_to_move_options_' + indicatorID" class="click_to_move_options">
                    <button type="button"
                        :disabled="index === 0"
                        :id="'click_to_move_up_' + indicatorID" class="icon_move up"
                        :title="'move indicatorID ' + indicatorID + ' up'" :aria-label="'move indicatorID ' + indicatorID + ' up'"
                        @click.stop="clickToMoveListItem($event, indicatorID, true)">
                    </button>
                    <button type="button"
                        :disabled="index === currentListLength - 1"
                        :id="'click_to_move_down_' + indicatorID" class="icon_move down"
                        :title="'move indicatorID ' + indicatorID + ' down'" :aria-label="'move indicatorID ' + indicatorID + ' down'"
                        @click.stop="clickToMoveListItem($event, indicatorID, false)">
                    </button>
                </div>
            </div>

            <form-question-display
                :key="'editing_display_' + formNode.indicatorID + makePreviewKey(formNode)"
                :categoryID="categoryID"
                :depth="depth"
                :formPage="formPage"
                :index="index"
                :currentListLength="currentListLength"
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
                    :currentListLength="formNode.child.length"
                    :key="'index_list_item_' + listItem.indicatorID"
                    :draggable="!previewMode"
                    @dragstart.stop="startDrag"
                    @dragend.stop="endDrag"
                    @drag.stop="handleOnDragCustomizations">
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