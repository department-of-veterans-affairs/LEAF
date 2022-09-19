export default {
    name: 'FormEntryPreview',
    props: {
        depth: Number,
        formNode: Object,
        index: Number
    },
    inject: [],
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
        formatPreview() {
            const baseFormat = this.formNode.format;
            console.log(baseFormat);

            let preview = ``;
            switch(baseFormat) {
                case 'number':
                case 'text':
                case 'currency':
                    const type = baseFormat === 'currency' ? 'number' : baseFormat;
                    preview += `<input type="${type}" ${baseFormat === 'currency' ? 'min="0.00" step="0.01"' : ''} class="text_input_preview"/>`
                    break;
                default:
                    break;

            }
            return preview;
        },
    },
    template:`<div class="form_data_entry_preview" :class="{'conditional-show': conditionallyShown}">
            <div :title="'preview for indicator ' + formNode.indicatorID" class="title-preview"
                v-html="formNode.name || '[blank]'">
            </div>
            <template v-if="formatPreview!==''">
            <div v-html="formatPreview" class="format-preview"></div>
            </template>
            
            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="hasChildNode">
                <form-entry-preview v-for="child in children"
                    :depth="depth + 1"
                    :formNode="child"
                    :key="'entry_preview_' + child.indicatorID">
                </form-entry-preview>
            </template>
        </div>`
}