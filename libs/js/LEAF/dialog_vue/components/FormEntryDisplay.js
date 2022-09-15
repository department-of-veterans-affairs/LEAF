export default {
    name: 'FormEntryDisplay',  //NOTE: this will replace previous 'print-subindicators' component
    props: {
        depth: Number,
        formNode: Object,
        index: Number
    },
    inject: [
        'newQuestion',
        'getForm',
        'editIndicatorPrivileges',
        'gridInstances',
        'updateGridInstances'
    ],
    methods: {
        ifthenUpdateIndicatorID(indicatorID) {
            vueData.indicatorID = parseInt(indicatorID); //NOTE: TODO: possible better way
            document.getElementById('btn-vue-update-trigger').dispatchEvent(new Event("click"));
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
        indicatorName() {
            return (XSSHelpers.stripAllTags(this.formNode.name) || '[ blank ]') + ' 📝 ';
            //return this.formNode.name || '[ blank ]' + ' 📝';
        },
        formatPreview() {
            const baseFormat = this.formNode.format;
            console.log(baseFormat);

            let preview = baseFormat;
            switch(baseFormat) {
                case 'number':
                case 'text':
                case 'currency':
                    preview = `<div class="text_input_preview"></div>`
                    break;
                default:
                    break;

            }
            return preview;
        },
        bgColor() {
            return `rgb(${255-2*this.depth},${255-2*this.depth},${255-2*this.depth})`;
        },
        suffix() {
            return `${this.formNode.indicatorID}_${this.formNode.series}`;
        },
        colspan() {
            return this.formNode.format === null || this.formNode.format.toLowerCase() === 'textarea' ? 2 : 1;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        isEmpty() {
            return this.formNode.isEmpty === true;
        },
        blockID() { //NOTE: not sure about empty id attr
            return parseInt(this.depth) === 0 ?  '' : `subIndicator_${this.suffix}`;
        },
        labelID() {
            return parseInt(this.depth) === 0 ? `PHindicator_${this.suffix}` : '';
        },
        labelClass() {
            if (parseInt(this.depth) === 0) {
                return this.required && this.isEmpty ? `printheading_missing` : `printheading`;
            } else {
                return this.required && this.isEmpty ? `printsubheading_missing` : `printsubheading`;
            }
        },
        truncatedOptions() {
            return this.formNode.options?.slice(0, 6) || [];
        }
    },
    mounted(){
        if(this.formNode.format==='grid') {
            const options = JSON.parse(this.formNode.options[0]);
            this.updateGridInstances(options, this.formNode.indicatorID, this.formNode.series);
            this.gridInstances[this.formNode.indicatorID].preview();
        }
    },
    template:`<div :class="depth===0 ? 'printmainblock' : 'printsubblock'" :id="blockID">
            <div :class="depth===0 ? 'printmainlabel' : 'printsublabel'">
                <div style="display:flex; height:100%;">
                    <div v-if="depth===0" class="printcounter">{{index + 1}}</div>
                    <div :id="labelID" :class="labelClass">
                        
                            <img v-if="parseInt(formNode.is_sensitive)===1" 
                                src="../../libs/dynicons/?img=eye_invisible.svg&amp;w=16" alt=""
                                :style="{margin: depth===0 ? '0.2em' : 'auto'}"
                                title="This field is sensitive" />
                            
                            <div :style="{display: depth===0 ? 'flex':'block'}" style="width:100%; align-items: center;">
                                <span class="printsubheading"
                                    tabindex="0" 
                                    @keypress.enter="getForm(formNode.indicatorID, formNode.series)" @click="getForm(formNode.indicatorID, formNode.series)"
                                    :style="{fontWeight: depth===0 ? 'bold' : 'normal'}"
                                    :title="'edit indicator ' + formNode.indicatorID">
                                    {{indicatorName}}
                                </span>
                                <span tabindex="0"
                                    @keypress.enter="editIndicatorPrivileges(formNode.indicatorID)" 
                                    @click="editIndicatorPrivileges(formNode.indicatorID)"
                                    style="cursor: pointer;" 
                                    title="Edit indicator privileges">🔒 </span>
                                <span v-if="depth>0 && (formNode.format==='dropdown' || formNode.format==='text')" :id="'edit_conditions_' + formNode.indicatorID" 
                                    tabindex="0" @keypress.enter="ifthenUpdateIndicatorID(formNode.indicatorID)" 
                                    @click="ifthenUpdateIndicatorID(formNode.indicatorID)" alt="" title="Edit conditions" style="cursor: pointer">🛠️ </span>
                                <span v-if="formNode.has_code" title="Advanced Options present" style="cursor: pointer">🔧 </span>
                                <span class="buttonNorm" tabindex="0" title="Add Sub-question"
                                    :style="{marginLeft: depth===0 ? 'auto' : '0.25em'}"
                                    :class="{subquestionAddNew: depth > 0}"
                                    @keypress.enter="newQuestion(formNode.indicatorID)"
                                    @click="newQuestion(formNode.indicatorID)">
                                    <img src="../../libs/dynicons/?img=list-add.svg&amp;w=16" alt="" /> 
                                    Add Sub-question
                                </span>
                            </div>
                        
                    </div>
                </div>
                
                <div class="printResponse" :id="'xhrIndicator_' + suffix" 
                    :style="{minHeight: depth===0 ? '75px': 0, padding: depth===0 ? '1em': 0}">

                    <!-- NOTE: FORMAT PREVIEWS -->
                    <div class="form_entry_preview">
                        <div v-html="formatPreview"></div>
                        <template v-if="formNode.format==='grid'">
                            <br /><br />
                            <div :id="'grid'+ suffix" style="width: 100%; max-width: 100%;"></div>
                        </template>
                        <template v-else>
                            <ul v-if="formNode.options && formNode.options !== ''">
                                <li v-for="o in truncatedOptions" :key="o">{{o}}</li>
                                <li v-if="formNode.options !== '' && formNode.options.length > 6">...</li>
                            </ul>
                        </template>
                    </div>

                    <span class="printResponse" :id="'data_' + suffix"></span>
                    <!-- NOTE: RECURSIVE SUBQUESTIONS -->
                    <template v-if="hasChildNode">
                        <div class="printformblock" style="display:flex; flex-wrap:wrap">
                            <Form-entry-display v-for="child in children"
                                :depth="depth + 4"
                                :formNode="child"
                                :key="child.indicatorID"> 
                            </form-entry-display>
                        </div>
                    </template>
                </div>
                
            </div> <!-- END MAIN/SUB LABEL -->
        </div> <!-- END MAIN/SUB BLOCK -->`
}