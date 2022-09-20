export default {
    name: 'FormEditingDisplay',  //NOTE: this will replace previous 'print-subindicators' component
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
        'allListItemsAreAdded',
        'allowedConditionChildFormats',
        'showToolbars'
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
        sensitiveImg() {
            return parseInt(this.formNode.is_sensitive)===1 ? 
                `<img src="../../libs/dynicons/?img=eye_invisible.svg&amp;w=16" alt=""
                    style="vertical-align: text-bottom; display:inline-block;"
                    title="This field is sensitive" />` : '';
        },
        formatPreview() {
            const baseFormat = this.formNode.format?.toLowerCase();
            console.log(baseFormat);

            let preview = ``;
            switch(baseFormat) {
                case 'number':
                case 'text':
                case 'currency':
                    const type = baseFormat === 'currency' ? 'number' : baseFormat;
                    if (baseFormat === 'currency') preview += '$&nbsp;'
                    preview += `<input type="${type}" ${baseFormat === 'currency' ? 'min="0.00" step="0.01"' : ''} class="text_input_preview"/>`
                    break;
                default:
                    break;

            }
            return preview;
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
        consitionsAllowed() {
            return !this.isHeaderLocation && this.allowedConditionChildFormats.includes(this.formNode.format?.toLowerCase());
        },
        indicatorName() {
            let name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            name = `${this.sensitiveImg} ${name}`;
            return name;
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
        blockID() { //NOTE: not sure about empty id attr
            return parseInt(this.depth) === 0 ?  '' : `subIndicator_${this.suffix}`;
        },
        labelID() {
            return parseInt(this.depth) === 0 ? `PHindicator_${this.suffix}` : '';
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
    template:`<div class="printResponse" :id="'xhrIndicator_' + suffix" :style="{minHeight: depth===0 ? '50px': 0}">

            <!-- NOTE: EDITING AREA -->
            <div class="form_editing_area" :class="{'conditional-show': conditionallyShown}">

                <!-- PREVIEW QUESTION AND ENTRY FORMAT -->
                <!-- TOOLBAR -->
                <div v-show="showToolbars" :id="'form_editing_toolbar_' + formNode.indicatorID">
                    <div>
                        <span tabindex="0" style="cursor: pointer;"
                            @click="getForm(formNode.indicatorID, formNode.series)"
                            @keypress.enter="getForm(formNode.indicatorID, formNode.series)"
                            :title="'edit indicator ' + formNode.indicatorID">📝
                        </span>
                        format: {{formNode.format || 'none'}}
                    </div>

                    <div style="display: flex; align-items:center;">
                        <button v-if="consitionsAllowed" :id="'edit_conditions_' + formNode.indicatorID" 
                            @click="ifthenUpdateIndicatorID(formNode.indicatorID)" :title="'Edit conditions for ' + formNode.indicatorID" class="icon">
                            <img src="../../libs/dynicons/?img=preferences-system.svg&amp;w=20" alt="" />
                        </button>
                        <button @click="editIndicatorPrivileges(formNode.indicatorID)"
                            :title="'Edit indicator ' + formNode.indicatorID + ' privileges'" class="icon">
                            <img src="../../libs/dynicons/?img=emblem-readonly.svg&amp;w=20" alt=""/> 
                        </button>

                        <button v-if="formNode.has_code" title="Advanced Options present" class="icon">
                            <img v-if="formNode.has_code" src="../../libs/dynicons/?img=document-properties.svg&amp;w=20" alt="" />
                        </button>
                        <button class="btn-general add-subquestion" title="Add Sub-question"
                            @click="newQuestion(formNode.indicatorID)">
                            + Add Sub-question
                        </button>
                    </div>
                </div>

                <div v-html="indicatorName" class="indicator-name-preview"></div>
                
                <div v-if="formNode.format!==''" class="form_data_entry_preview">
                    <template v-if="formatPreview!==''">
                    <div v-html="formatPreview" class="format-preview"></div>
                    </template>

                    <!-- NOTE:/TODO: OLD FORMAT PREVIEWS -->
                    <template v-if="formNode.format==='grid'">
                        <br />
                        <div :id="'grid'+ suffix" style="width: 100%; max-width: 100%;"></div>
                    </template>
                    <template v-else>
                        <ul v-if="formNode.options && formNode.options !== ''" style="padding-left:26px;">
                            <li v-for="o in truncatedOptions" :key="o">{{o}}</li>
                            <li v-if="formNode.options !== '' && formNode.options.length > 6">...</li>
                        </ul>
                    </template>
                </div>


            </div>

            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="hasChildNode">
                <form-editing-display v-for="child in children"
                    :depth="depth + 1"
                    :formNode="child"
                    :key="'editing_display_' + child.indicatorID"> 
                </form-editing-display>
            </template>
        </div>`
}