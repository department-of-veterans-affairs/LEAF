export default {
    name: 'form-index-listing',
    data() {
        return {
            subMenuOpen: false
        }
    },
    props: {
        formPage: Number,
        depth: Number,
        formNode: Object,
        index: Number,
        parentID: Number
    },
    inject: [
        'truncateText',
        'clearListItem',
        'addToListTracker',
        'selectNewFormNode',
        'selectedNodeIndicatorID',
        'startDrag',
        'onDragEnter',
        'onDragLeave',
        'onDrop',
        'moveListItem'
    ],
    mounted() {
        console.log('mounted list item')
        //each list item is added to the array on parent component (FormEditorView), to track indicatorID, parentID, sort and current index values
        this.addToListTracker(this.formNode, this.parentID, this.index);
        //expands the selected section if it's currently focussed
        if(this.selectedNodeIndicatorID === this.formNode.indicatorID) {
            let el = document.getElementById(`index_listing_${this.selectedNodeIndicatorID}`);
            if (el !== null) {
                const headingEl = el.closest('li.section_heading');
                const elsMenu = Array.from(headingEl?.querySelectorAll(`li .sub-menu-chevron.closed`) || []);
                elsMenu.forEach(el => el.click());
                el.classList.add('index-selected');
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
        toggleSubMenu(event = {}) {
            if(event?.keyCode === 32) event.preventDefault();
            this.subMenuOpen = !this.subMenuOpen;
            event.currentTarget.closest('li')?.focus();
        }
    },
    computed: {
        headingNumber() {
            return this.depth === 0 ? this.index + 1 + '.' : '';
        },
        indexDisplay() {
            //if the indicator has a short label (description), display that, otherwise display the name. Show 'blank' if it has neither
            let display = this.formNode.description ?  XSSHelpers.stripAllTags(this.formNode.description) : XSSHelpers.stripAllTags(this.formNode.name);
            return XSSHelpers.decodeHTMLEntities(this.truncateText(display)) || '[ blank ]';
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
        <li tabindex=0 :title="'index item '+ formNode.indicatorID"
            :class="depth === 0 ? 'section_heading' : 'subindicator_heading'"
            @mouseover.stop="indexHover" @mouseout.stop="indexHoverOff"
            @click.stop="selectNewFormNode(formNode.indicatorID, formPage)"
            @keydown.enter.prevent="selectNewFormNode(formNode.indicatorID, formPage)">
            <div>
                {{headingNumber}}&nbsp;{{indexDisplay}}
                <div class="icon_move_container">
                    <div v-show="formNode.indicatorID === selectedNodeIndicatorID" 
                        tabindex="0" class="icon_move up" role="button" title="move item up"
                        @click.stop="moveListItem($event, selectedNodeIndicatorID, true)"
                        @keydown.enter.space.prevent.stop="moveListItem($event, selectedNodeIndicatorID, true)">
                    </div>
                    <div v-show="formNode.indicatorID === selectedNodeIndicatorID"
                        tabindex="0" class="icon_move down" role="button" title="move item down"
                        @click.stop="moveListItem($event, selectedNodeIndicatorID, false)"
                        @keydown.enter.space.prevent.stop="moveListItem($event, selectedNodeIndicatorID, false)">
                    </div>
                </div>
                <div v-if="formNode.child" tabindex="0" class="sub-menu-chevron" :class="{closed: !subMenuOpen}"
                    @click.stop="toggleSubMenu($event)"
                    @keydown.stop.enter.space="toggleSubMenu($event)">
                    <span v-show="subMenuOpen" role="img" aria="">▾</span>
                    <span v-show="!subMenuOpen" role="img" aria="">▸</span>
                </div>
            </div>
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS. ul for each for drop zones -->
            <ul class="form-index-listing-ul" :id="'drop_area_parent_'+ formNode.indicatorID"
                data-effect-allowed="move"
                @drop.stop="onDrop"
                @dragover.prevent
                @dragenter.prevent="onDragEnter"
                @dragleave="onDragLeave">

                <template v-if="formNode.child">
                    <form-index-listing v-show="subMenuOpen" v-for="(child, k, i) in formNode.child"
                        :id="'index_listing_' + child.indicatorID"
                        :formPage=formPage
                        :depth="depth + 1"
                        :parentID="formNode.indicatorID"
                        :formNode="child"
                        :index="i"
                        :key="'index_list_item_' + child.indicatorID"
                        draggable="true"
                        @dragstart.stop="startDrag"> 
                    </form-index-listing>
                </template>
            </ul>
        </li>`
}