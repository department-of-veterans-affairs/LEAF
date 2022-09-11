export default {
    name: 'FormIndexListing',  //NOTE: this will replace PrintSubindicators
    props: {
        depth: Number,
        formNode: Object,
        sectionNumber: Number
    },
    inject: [
        'newQuestion',
        'getForm',
        'truncateText',
    ],
    methods: {
        indexHover(event) {
            event.target.classList.add('index-selected');
        },
        indexHoverOff(event){
            event.target.classList.remove('index-selected');
        }
    },
    computed: {
        hasChildNode() {
            const { child } = this.formNode;
            return child !== null && Object.keys(child).length > 0;
        },
        headingNumber() {
            return this.sectionNumber !== undefined ? this.sectionNumber + '.' : '';
        },
        conditionallyShown() {
            let isConditionalShow = false;
            if(this.depth !== 0 && this.formNode.conditions !== null && this.formNode.conditions !== '') {
                const conditions = JSON.parse(this.formNode.conditions);
                console.log(conditions)
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
            return parseInt(this.depth) === 0 ?  `section_heading_${this.suffix}` : `section_indicator_${this.suffix}`;
        }
    },

    template:`
        <li tabindex=0
            :class="depth===0 ? 'section_heading' : 'subindicator_heading'"
            :id="'index_' + blockID"
            :style="{backgroundColor:bgColor}"
            @mouseover.stop="indexHover" @mouseout.stop="indexHoverOff">
            {{conditionallyShown}}{{headingNumber}} {{shortLabel}}
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="hasChildNode">
                <ul class="form-index-listing">
                    <form-index-listing v-for="child in formNode.child"
                        :depth="depth + 1"
                        :formNode="child"
                        :key="child.indicatorID"> 
                    </form-index-listing>
                </ul>
            </template>
        </li>`
}