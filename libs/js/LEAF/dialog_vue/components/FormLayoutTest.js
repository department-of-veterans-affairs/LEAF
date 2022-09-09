export default {
    name: 'FormLayoutTest',
    props: {
        depth: Number,
        formNode: Object,
        sectionNumber: Number
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
    template:`<div :class="depth===0 ? 'printmainblock' : 'printsubblock'" :id="blockID" 
             :style="{margin: depth!==0 ? '0.4em 0.1em' : 0}">
            <div :class="depth===0 ? 'printmainlabel' : 'printsublabel'">
                <div :style="{display: depth===0 ? 'flex': 'inline-block'}">
                    <div v-if="depth===0" class="printcounter">
                        <span tabindex="0" aria-label="formNode.indicatorID" style="margin:0; height: 100%">{{sectionNumber}}</span>
                    </div>
                    <div :id="labelID" :class="labelClass" 
                        :style="{display: depth===0 ? 'flex' : 'block'}" 
                        style="align-items:center; width: 100%;">
                        <img v-if="parseInt(formNode.is_sensitive)===1" 
                            src="../../libs/dynicons/?img=eye_invisible.svg&amp;w=16" alt="" 
                            title="This field is sensitive" />
                        <span class="printsubheading"  
                            style="padding: 0 0.2em; font-size: 16px; cursor: pointer"
                            :style="{fontWeight: depth===0 ? 'bold' : 'normal'}" 
                            :title="'indicatorID: ' + formNode.indicatorID"
                            v-html="formNode.name || '[ blank ]'">
                        </span>
                        <div style="display:inline-block; float:right;">
                            <img src="../../libs/dynicons/?img=accessories-text-editor.svg&amp;w=16" tabindex="0" 
                                @keypress.enter="getForm(formNode.indicatorID, formNode.series)" @click="getForm(formNode.indicatorID, formNode.series)" alt="" 
                                title="Edit this field" style="cursor: pointer; margin-right: 0.2em;" />
                            <img src="../../libs/dynicons/?img=emblem-readonly.svg&amp;w=16" tabindex="0" 
                                @keypress.enter="editIndicatorPrivileges(formNode.indicatorID)" @click="editIndicatorPrivileges(formNode.indicatorID)" alt="" 
                                title="Edit indicator privileges" style="cursor: pointer; margin-right: 0.2em;" />
                            <img v-if="depth>0 && (formNode.format==='dropdown' || formNode.format==='text')" :id="'edit_conditions_' + formNode.indicatorID" 
                                src="../../libs/dynicons/?img=preferences-system.svg&amp;w=16" tabindex="0" @keypress.enter="ifthenUpdateIndicatorID(formNode.indicatorID)" 
                                @click="ifthenUpdateIndicatorID(formNode.indicatorID)" alt="" title="Edit conditions" style="cursor: pointer" />
                            <img v-if="formNode.has_code" src="../../libs/dynicons/?img=document-properties.svg&amp;w=16" alt="" 
                                title="Advanced Options present" style="cursor: pointer" />
                        </div>
                        <br v-if="depth>0" v-for="n in 3" />
                        <span class="buttonNorm" tabindex="0" title="Add Sub-question"
                            style="margin-left:auto;"
                            :class="{subquestionAddNew: depth > 0}"
                            @keypress.enter="newQuestion(formNode.indicatorID)"
                            @click="newQuestion(formNode.indicatorID)">
                            <img src="../../libs/dynicons/?img=list-add.svg&amp;w=16" alt="" /> 
                            Add Sub-question
                        </span>
                    </div>
                </div>

                <div style="display: flex;" :style="{minHeight: depth===0 ? '75px': 0}">
                    <div tabindex="0" class="printResponse" :id="'xhrIndicator_' + suffix">

                    <!-- NOTE: FORMAT PREVIEWS -->
                    <template v-if="formNode.format==='grid'">
                        {{formNode.format}}
                        <br /><br />
                        <div :id="'grid'+ suffix" style="width: 100%; max-width: 100%;"></div>
                    </template>
                    <template v-else>
                        {{formNode.format}}
                        <ul v-if="formNode.options && formNode.options !== ''">
                            <li v-for="o in truncatedOptions" :key="o">{{o}}</li>
                            <li v-if="formNode.options !== '' && formNode.options.length > 6">...</li>
                        </ul>
                    </template>

                    <span class="printResponse" :id="'data_' + suffix"></span>
                    <!-- NOTE: RECURSIVE SUBQUESTIONS -->
                    <template v-if="hasChildNode">
                        <div class="printformblock" :style="{marginLeft: depth +'px'}" style="display:flex; flex-wrap:wrap">
                            <form-layout-test v-for="child in formNode.child"
                                :depth="depth + 4"
                                :formNode="child"
                                :key="child.indicatorID"> 
                            </form-layout-test>
                        </div>
                    </template>
                    </div>
                </div>
            </div> <!-- END MAIN/SUB LABEL -->
        </div> <!-- END MAIN/SUB BLOCK -->`
}