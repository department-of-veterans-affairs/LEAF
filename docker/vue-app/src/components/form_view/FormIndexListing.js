export default {
    name: 'FormIndexListing',
    data() {
        return {
            subMenuOpen: true
        }
    },
    props: {
        depth: Number,
        formNode: Object,
        index: Number,
        parentID: Number
    },
    inject: [
        'truncateText',
        'addToListItemsObject',
        'selectNewFormNode',
        'selectedNodeIndicatorID',
        'startDrag',
        'onDragEnter',
        'onDragLeave',
        'onDrop',
        'moveListing'
    ],
    mounted() {
        //console.log('Form Index list item mounted')
        //each list item is added to the listItems array on parent component, to track indicatorID, parentID, sort and current index values
        this.addToListItemsObject(this.formNode, this.parentID, this.index);
        if(this.selectedNodeIndicatorID !== null) {
            document.getElementById(`index_listing_${this.selectedNodeIndicatorID}`).classList.add('index-selected');
        }
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
        }
    },
    computed: {
        children() {
            let eles = [];
            for (let c in this.formNode.child) {
                eles.push(this.formNode.child[c]);
            }
            eles = eles.sort((a, b)=> a.sort - b.sort);
            return eles;
        },
        headingNumber() {
            return this.depth === 0 ? this.index + 1 + '.' : '';
        },
        hasConditions() {
            return (this.depth !== 0 && this.formNode.conditions !== null && this.formNode.conditions !== '');
        },
        //NOTE: Uses globally available XSSHelpers.js (LEAF class)
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
            @click.stop="selectNewFormNode($event, formNode)"
            @keypress.enter.stop="selectNewFormNode($event, formNode)">
            <div>
                <span v-if="hasConditions" title="question is conditionally shown">→</span>
                {{headingNumber}}&nbsp;{{indexDisplay}}
                <div class="icon_move_container">
                    <div v-show="formNode.indicatorID === selectedNodeIndicatorID" 
                        tabindex="0" class="icon_move up" role="button" title="move item up"
                        @click.stop="moveListing($event, selectedNodeIndicatorID, true)"
                        @keydown.stop.enter.space="moveListing($event, selectedNodeIndicatorID, true)">
                    </div>
                    <div v-show="formNode.indicatorID === selectedNodeIndicatorID"
                        tabindex="0" class="icon_move down" role="button" title="move item down"
                        @click.stop="moveListing($event, selectedNodeIndicatorID, false)"
                        @keydown.stop.enter.space="moveListing($event, selectedNodeIndicatorID, false)">
                    </div>
                </div>
                <div v-if="formNode.child" tabindex="0" class="sub-menu-chevron"
                    @click.stop="toggleSubMenu($event)"
                    @keydown.stop.enter.space="toggleSubMenu($event)">
                    {{subMenuOpen ? '︽' : '︾'}}
                </div>
            </div>
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS. ul for each for drop zones -->
            
            <ul v-show="subMenuOpen" class="form-index-listing-ul" :id="'drop_area_parent_'+ formNode.indicatorID"
                data-effect-allowed="move"
                @drop.stop="onDrop"
                @dragover.prevent
                @dragenter.prevent="onDragEnter"
                @dragleave="onDragLeave">

                <template v-if="formNode.child">
                    <form-index-listing v-for="(child, i) in children"
                        :id="'index_listing_' + child.indicatorID"
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