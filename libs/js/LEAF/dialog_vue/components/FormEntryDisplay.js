export default {
    name: 'FormEntryDisplay',  //NOTE: this will replace previous 'print-subindicators' component
    props: {
        depth: Number,
        formNode: Object,
        index: Number
    },
    inject: [
        'truncateText',
        'newQuestion',
        'getForm',
        'editIndicatorPrivileges',
        'gridInstances',
        'updateGridInstances',
        'listItems',
        'allListItemsAreAdded'
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
        isHeaderLocation() {
            let ID = parseInt(this.formNode.indicatorID);
            let item = this.listItems[ID];
            return this.allListItemsAreAdded && (item.parentID===null || item.newParentID===null);
        },
        indicatorName() {
            let name = XSSHelpers.stripAllTags(this.formNode.name) || '[ blank ]';
            name = parseInt(this.depth) === 0 ? this.truncateText(name, 70) : name;
            return name + ' 📝'
        },
        formatPreview() {
            const baseFormat = this.formNode.format;
            console.log(baseFormat);

            let preview = ``;
            switch(baseFormat) {
                case 'number':
                case 'text':
                case 'currency':
                    preview += `<input type="baseFormat" class="text_input_preview"/>`
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
                <div :id="labelID" :class="labelClass">
                    <div v-if="depth===0 && index>=0" class="printcounter">{{index + 1}}</div>
                    <img v-if="parseInt(formNode.is_sensitive)===1" 
                        src="../../libs/dynicons/?img=eye_invisible.svg&amp;w=16" alt=""
                        :style="{margin: depth===0 ? '0.2em' : 'auto'}"
                        title="This field is sensitive" />
                    <div style="display: flex; align-items:center;">
                        <span tabindex="0" class="printsubheading" 
                            @click="getForm(formNode.indicatorID, formNode.series)"
                            @keypress.enter="getForm(formNode.indicatorID, formNode.series)"
                            :title="'edit indicator ' + formNode.indicatorID"
                            :style="{fontWeight: depth===0 ? 'bold' : 'normal'}">
                            {{indicatorName}}
                        </span>
                    </div>
                </div>

                
                <div class="printResponse" :id="'xhrIndicator_' + suffix" 
                    :style="{minHeight: depth===0 ? '75px': 0}">

                    <!-- NOTE: FORMAT PREVIEWS -->
                    <div class="form_entry_preview">

                        <div id="entry_display_toolbar">  <!-- format display and toolbar -->
                            <div>format: {{formNode.format || 'none'}}</div>

                            <div style="display: flex; align-items:center; height: 30px;">
                                <button @click="editIndicatorPrivileges(formNode.indicatorID)"
                                    :title="'Edit indicator ' + formNode.indicatorID + ' privileges'" class="icon">
                                    <img src="../../libs/dynicons/?img=emblem-readonly.svg&amp;w=20" alt=""/> 
                                </button>
                                <button v-if="!isHeaderLocation && (formNode.format==='dropdown' || formNode.format==='text')" :id="'edit_conditions_' + formNode.indicatorID" 
                                    @click="ifthenUpdateIndicatorID(formNode.indicatorID)" :title="'Edit conditions for ' + formNode.indicatorID" class="icon">
                                    <img src="../../libs/dynicons/?img=preferences-system.svg&amp;w=20" alt="" />
                                </button>
                                <button v-if="formNode.has_code" title="Advanced Options present" class="icon">
                                    <img v-if="formNode.has_code" src="../../libs/dynicons/?img=document-properties.svg&amp;w=20" alt="" />
                                </button>
                                <span class="buttonNorm" tabindex="0" title="Add Sub-question"
                                    :class="{subquestionAddNew: depth > 0}"
                                    @keypress.enter="newQuestion(formNode.indicatorID)"
                                    @click="newQuestion(formNode.indicatorID)">
                                    + Add Sub-question
                                </span>
                            </div>
                        </div>

                        <!-- TODO: section previe, mv -->
                        <div :title="'edit indicator ' + formNode.indicatorID"
                            @click="getForm(formNode.indicatorID, formNode.series)"
                            @keypress.enter="getForm(formNode.indicatorID, formNode.series)"
                            v-html="formNode.name || '[blank]'">
                        </div>
                        <div v-html="formatPreview"></div>

                        <!-- TODO: OLD -->
                        <!--
                        <template v-if="formNode.format==='grid'">
                            <br /><br />
                            <div :id="'grid'+ suffix" style="width: 100%; max-width: 100%;"></div>
                        </template>
                        <template v-else>
                            <ul v-if="formNode.options && formNode.options !== ''">
                                <li v-for="o in truncatedOptions" :key="o">{{o}}</li>
                                <li v-if="formNode.options !== '' && formNode.options.length > 6">...</li>
                            </ul>
                        </template> -->
                    </div>

                    <!-- NOTE: RECURSIVE SUBQUESTIONS -->
                    <template v-if="hasChildNode">
                        <div class="printformblock">
                            <Form-entry-display v-for="child in children"
                                :depth="depth + 1"
                                :formNode="child"
                                :key="child.indicatorID"> 
                            </form-entry-display>
                        </div>
                    </template>
                </div>
                
            </div> <!-- END MAIN/SUB LABEL -->
        </div> <!-- END MAIN/SUB BLOCK -->`
}