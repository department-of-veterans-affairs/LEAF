export default {
    name: 'FormIndexListing',  //NOTE: this will replace PrintSubindicators
    props: {
        depth: Number,
        formNode: Object,
        index: Number,
        parentID: Number
    },
    inject: [
        'newQuestion',
        'getForm',
        'truncateText',
        'addToListItemsArray'
    ],
    mounted() {
        //each list item is added to the listItems array on parent component, to track indicatorID, parentID, sort and current index values
        this.addToListItemsArray(this.formNode, this.parentID, this.index);
    },
    methods: {
        indexHover() {
            event.target.classList.add('index-selected');
        },
        indexHoverOff(){
            event.target.classList.remove('index-selected');
        },
        handleIndexing(selectedCategory, index) {
            console.log(selectedCategory.sort, index);
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
                const conditions = JSON.parse(this.formNode.conditions);
                if (conditions.some(c => c.selectedOutcome?.toLowerCase() === 'show')) {
                    isConditionalShow = true;
                }
            }
            return isConditionalShow ? '→ ' : "";
        },
        //NOTE: Uses globally available XSSHelpers.js (LEAF class)
        shortLabel() { //TODO:  currently getting from name - too many items didn't have label - prompt during entry
            return XSSHelpers.decodeHTMLEntities(this.truncateText(XSSHelpers.stripAllTags(this.formNode.name))) || '[ blank ]';
        },
        bgColor() { //TODO: not sure if I will use
            return `rgb(${255-8*this.depth},${255-6*this.depth},${255})`;
        },
        suffix() {
            return `${this.formNode.indicatorID}_${this.formNode.series}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        isEmpty() {
            return this.formNode.isEmpty === true;
        },
        blockID() {
            return `section_indicator_${this.suffix}`;
        }
    },

    template:`
        <li tabindex=0 :title="'index item '+ formNode.indicatorID"
            :class="depth===0 ? 'section_heading' : 'subindicator_heading'"
            :id="'index_' + blockID"
            :style="{backgroundColor:bgColor}"
            @mouseover.stop="indexHover" @mouseout.stop="indexHoverOff"
            @click.stop="handleIndexing(formNode, index)">
            {{conditionallyShown}}{{headingNumber}} {{shortLabel}}
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="hasChildNode">
                <ul class="form-index-listing">
                    <form-index-listing v-for="(child, i) in children"
                        :depth="depth + 1"
                        :parentID="formNode.indicatorID"
                        :formNode="child"
                        :index="i"
                        :key="child.indicatorID"> 
                    </form-index-listing>
                </ul>
            </template>
        </li>`
}