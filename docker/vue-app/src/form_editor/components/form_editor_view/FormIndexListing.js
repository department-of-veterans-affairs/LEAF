export default {
    name: 'form-index-listing',
    props: {
        categoryID: String,
        formPage: Number,
        depth: Number,
        indicatorID: Number,
        formNode: Object,
        index: Number,
        parentID: Number,
        menuOpen: Boolean
    },
    inject: [
        'queryID',
        'focusedFormRecord',
        'truncateText',
        'shortIndicatorNameStripped',
        'clearListItem',
        'addToListTracker',
        'focusIndicator',
        'formMenuState',
        'updateFormMenuState',
        'focusedIndicatorID',
        'previewMode',
        'startDrag',
        'onDragEnter',
        'onDragLeave',
        'onDrop',
        'moveListItem'
    ],
    mounted() {
        //add to listTracker array to track indicatorID, parentID, sort and current index values
        //only track in edit mode because preview mode includes staples in the primary form list
        if(!this.previewMode) {
            this.addToListTracker(this.formNode, this.parentID, this.index);
        }
        //maintain focus on an indicator if it has been focused
        if(this.focusedIndicatorID === this.formNode.indicatorID) {
            const elSelected = document.getElementById(`index_listing_${this.focusedIndicatorID}`);
            if(elSelected !== null) {
                elSelected.focus();
            }
        }
    },
    beforeUnmount() {
        this.clearListItem(this.formNode.indicatorID);
    },
    methods: {
        indexHover(event = {}) {
            event?.currentTarget?.classList.add('index-selected');
        },
        indexHoverOff(event = {}){
            event?.currentTarget?.classList.remove('index-selected');
        },
        changeMenuState(indID = 0, menuOpen = true, cascade = false) {
            this.focusIndicator(indID || null);
            this.updateFormMenuState(indID, menuOpen, cascade);
        }
    },
    computed: {
        indexDisplay() {
            //short label (description), otherwise display the name. Show 'blank' if it has neither
            let display = this.formNode.description || this.formNode.name || '[ blank ]';
            return `${this.shortIndicatorNameStripped(display, Math.max(16, 38 - Math.round(1.33*this.depth)))}`;
        },
        menuIconTitle() {
            const option = this.menuOpen ? 'close' : 'open';
            return `Click to ${option} this menu.  Ctrl-click to also ${option} all submenus.`;
        },
        suffix() {
            return `${this.formNode.indicatorID}_${this.formNode.series}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        isEmpty() {
            return this.formNode.isEmpty === true;
        }
    },
    template:`
        <li :title="'index item '+ indicatorID + '. Ctrl-click to nav to edit.'"
            :class="depth === 0 ? 'section_heading' : 'subindicator_heading'"
            @mouseover.stop="indexHover" @mouseout.stop="indexHoverOff">

            <button type="button" :id="'btn_index_indicator_' + indicatorID"
                @click.stop="focusIndicator(indicatorID)"
                @click.ctrl.stop.exact="focusIndicator(indicatorID, true)">
                <span v-show="!previewMode" role="img" aria="" alt="" style="opacity:0.3">☰&nbsp;&nbsp;</span>
                {{indexDisplay}}
                <div v-if="formNode.child" tabindex="0" class="sub-menu-chevron" :class="{closed: !menuOpen}"
                    @click.stop.exact="changeMenuState(indicatorID, !menuOpen)"
                    @click.ctrl.stop.exact="changeMenuState(indicatorID, !menuOpen, true)"
                    @keydown.stop.enter.space.exact.prevent="changeMenuState(indicatorID, !menuOpen)"
                    @keydown.ctrl.stop.enter.space.exact.prevent="changeMenuState(indicatorID, !menuOpen, true)"
                    :title="menuIconTitle">
                    <span v-show="menuOpen" role="img" aria="">▾</span>
                    <span v-show="!menuOpen" role="img" aria="">▸</span>
                </div>
                <div v-show="!previewMode && indicatorID === focusedIndicatorID" class="icon_move_container">
                    <div tabindex="0" class="icon_move up" role="button" title="move item up"
                        @click.stop="moveListItem($event, indicatorID, true)"
                        @keydown.enter.space.prevent.stop="moveListItem($event, indicatorID, true)">
                    </div>
                    <div tabindex="0" class="icon_move down" role="button" title="move item down"
                        @click.stop="moveListItem($event, indicatorID, false)"
                        @keydown.enter.space.prevent.stop="moveListItem($event, indicatorID, false)">
                    </div>
                </div>
            </button>
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS. ul for each for drop zones -->
            <ul class="form-index-listing-ul" :id="'drop_area_parent_'+ indicatorID"
                data-effect-allowed="move"
                @drop.stop="onDrop($event)"
                @dragover.prevent
                @dragenter.prevent="onDragEnter"
                @dragleave="onDragLeave">

                <template v-if="formNode.child">
                    <form-index-listing v-show="menuOpen" v-for="(child, k, i) in formNode.child"
                        :id="'index_listing_' + child.indicatorID"
                        :categoryID="categoryID"
                        :formPage=formPage
                        :depth="depth + 1"
                        :parentID="indicatorID"
                        :indicatorID="child.indicatorID"
                        :formNode="child"
                        :index="i"
                        :menuOpen="formMenuState?.[child.indicatorID] === undefined ? true : formMenuState[child.indicatorID]"
                        :key="'index_list_item_' + child.indicatorID"
                        :draggable="true"
                        @dragstart.stop="startDrag"> 
                    </form-index-listing>
                </template>
            </ul>
        </li>`
}