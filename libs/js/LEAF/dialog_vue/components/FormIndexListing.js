export default {
    name: 'FormIndexListing',
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
        'onDrop'
    ],
    mounted() {
        //each list item is added to the listItems array on parent component, to track indicatorID, parentID, sort and current index values
        this.addToListItemsObject(this.formNode, this.parentID, this.index);
        if(this.selectedNodeIndicatorID!==null) {
            document.getElementById(`index_listing_${this.selectedNodeIndicatorID}`).classList.add('index-selected');
        }
    },
    methods: {
        indexHover(evt) {
            evt.currentTarget.classList.add('index-selected');
        },
        indexHoverOff(evt){
            evt.currentTarget.classList.remove('index-selected');
        }
    },
    computed: {
        hasChildNode() {
            const { child } = this.formNode;
            return child !== null && Object.keys(child).length > 0;
        },
        children() {
            let eles = [];
            if(this.hasChildNode) {
                for (let c in this.formNode.child) {
                    eles.push(this.formNode.child[c]);
                }
                eles = eles.sort((a, b)=> a.sort - b.sort);
            }
            return eles;
        },
        headingNumber() {
            return this.depth === 0 ? this.index + 1 + '.' : '';
        },
        conditionallyShown() {
            let isConditionalShow = false;
            if(this.depth !== 0 && this.formNode.conditions !== null && this.formNode.conditions !== '') {
                const conditions = JSON.parse(this.formNode.conditions) || [];
                if (conditions.some(c => c.selectedOutcome?.toLowerCase() === 'show')) {
                    isConditionalShow = true;
                }
            }
            return isConditionalShow;
        },
        conditionallyHidden() {
            let isConditionalHide = false;
            if(this.depth !== 0 && this.formNode.conditions !== null && this.formNode.conditions !== '') {
                const conditions = JSON.parse(this.formNode.conditions) || [];
                if (conditions.some(c => c.selectedOutcome?.toLowerCase() === 'hide')) {
                    isConditionalHide = true;
                }
            }
            return isConditionalHide;
        },
        hasConditionalPrefill() {
            let hasConditionalPrefill = false;
            if(this.depth !== 0 && this.formNode.conditions !== null && this.formNode.conditions !== '') {
                const conditions = JSON.parse(this.formNode.conditions) || [];
                if (conditions.some(c => c.selectedOutcome?.toLowerCase() === 'pre-fill')) {
                    hasConditionalPrefill = true;
                }
            }
            return hasConditionalPrefill;
        },
        //NOTE: Uses globally available XSSHelpers.js (LEAF class)
        shortLabel() { //FIX:TODO:  currently getting from name - too many items didn't have label - prompt during entry
            return XSSHelpers.decodeHTMLEntities(this.truncateText(XSSHelpers.stripAllTags(this.formNode.name))) || '[ blank ]';
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
            :class="depth===0 ? 'section_heading' : 'subindicator_heading'"
            @mouseover.stop="indexHover" @mouseout.stop="indexHoverOff"
            @click.stop="selectNewFormNode(formNode)"
            @keypress.enter="selectNewFormNode(formNode)">
            <span>
                <span v-if="conditionallyShown" title="question is conditionally shown">→ </span>
                <span v-if="conditionallyHidden" title="question is conditionally hidden">⇏ </span>
                <span v-if="hasConditionalPrefill" title="question has a conditional prefill value">✎ </span>
                {{headingNumber}} {{shortLabel}}
            </span>
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS. ul for each for drop zones -->
            
            <ul class="form-index-listing-ul" :id="'drop_area_parent_'+ formNode.indicatorID"
                data-effect-allowed="move"
                @drop.stop="onDrop"
                @dragover.prevent
                @dragenter.prevent="onDragEnter"
                @dragleave="onDragLeave">

                <template v-if="hasChildNode">
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