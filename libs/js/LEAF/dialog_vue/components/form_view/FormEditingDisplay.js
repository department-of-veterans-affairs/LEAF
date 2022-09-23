import FormatPreview from "./FormatPreview";

export default {
    name: 'FormEditingDisplay',  //NOTE: this will replace previous 'print-subindicators' component
    props: {
        depth: Number,
        formNode: Object,
        index: Number
    },
    components: {
        FormatPreview
    },
    inject: [
        'truncateText',
        'newQuestion',
        'getForm',
        'openAdvancedOptionsDialog',
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
            return this.sensitive ? 
                `<img src="../../libs/dynicons/?img=eye_invisible.svg&amp;w=16" alt=""
                    style="vertical-align: text-bottom; display:inline-block;"
                    title="This field is sensitive" />` : '';
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
        conditionsAllowed() {
            return !this.isHeaderLocation && this.allowedConditionChildFormats.includes(this.formNode.format?.toLowerCase());
        },
        indicatorName() {  //TODO: and label??
            const contentRequired = this.required ? `<span class="input-required-sensitive">*&nbsp;Required</span>` : '';
            const contentSensitive = this.sensitive ? `<span class="input-required-sensitive">*&nbsp;Sensitive</span>` : '';

            let name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            name = `${name}${contentRequired}${contentSensitive}  &nbsp;${this.sensitiveImg}`;
            return name;
        },
        bgColor() {
            return `rgb(${255-2*this.depth},${255-2*this.depth},${255-2*this.depth})`;
        },
        suffix() {
            return `${this.formNode.indicatorID}_${this.formNode.series}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        sensitive() {
            return parseInt(this.formNode.is_sensitive) === 1;
        }
    },
    mounted() {
        if(this.formNode.format==='grid') {
            const options = JSON.parse(this.formNode.options[0]);
            this.updateGridInstances(options, this.formNode.indicatorID, this.formNode.series);
            this.gridInstances[this.formNode.indicatorID].preview();
        }
    },
    template:`<div class="printResponse" :id="'xhrIndicator_' + suffix" :style="{minHeight: depth===0 ? '50px': 0}">

            <!-- EDITING AREA FOR INDICATOR -->
            <div class="form_editing_area" :class="{'conditional-show': conditionallyShown}">

                <!-- TOOLBAR -->
                <div v-show="showToolbars" :id="'form_editing_toolbar_' + formNode.indicatorID">
                    <div style="display: flex; align-items: center;">
                        <span tabindex="0" style="cursor: pointer; display: flex; align-items:center;"
                            @click="getForm(formNode.indicatorID, formNode.series)"
                            @keypress.enter="getForm(formNode.indicatorID, formNode.series)"
                            :title="'edit indicator ' + formNode.indicatorID">📝 <span class="toolbar-edit">EDIT</span>
                        </span>
                        <span style="margin-left: 1.5em; white-space:nowrap">{{formNode.format || 'no format'}}</span>
                    </div>
                    <div style="display: flex; align-items:center;">
                        <button v-if="conditionsAllowed" :id="'edit_conditions_' + formNode.indicatorID" 
                            @click="ifthenUpdateIndicatorID(formNode.indicatorID)" :title="'Edit conditions for ' + formNode.indicatorID" class="icon">
                            <img src="../../libs/dynicons/?img=preferences-system.svg&amp;w=20" alt="" />
                        </button>
                        <button @click="editIndicatorPrivileges(formNode.indicatorID)"
                            :title="'Edit indicator ' + formNode.indicatorID + ' privileges'" class="icon">
                            <img src="../../libs/dynicons/?img=emblem-readonly.svg&amp;w=20" alt=""/> 
                        </button>
                        <button @click="openAdvancedOptionsDialog(formNode.indicatorID)"
                            title="Open Advanced Options" class="icon">
                            <img src="../../libs/dynicons/?img=document-properties.svg&amp;w=20" alt="" />
                        </button>
                        <div style="padding-right: 0.5em; color: #007860; font-weight: bold; width:20px; display:flex; align-items:center;">
                            <div v-if="formNode.has_code" tabindex="0" style="cursor:pointer" title="advanced options are present">✓</div>
                        </div>
                        <button class="btn-general add-subquestion" title="Add Sub-question"
                            @click="newQuestion(formNode.indicatorID)">
                            + Add Sub-question
                        </button>
                    </div>
                </div>

                <!-- NAME -->
                <div v-html="indicatorName" class="indicator-name-preview"></div>
                
                <!-- FORMAT PREVIEW -->
                <div v-if="formNode.format!==''" class="form_data_entry_preview">
                    <format-preview :indicator="formNode" :key="'FP' + formNode.indicatorID"></format-preview>

                    <!-- NOTE:/TODO: OLD FORMAT PREVIEWS -->
                    <template v-if="formNode.format==='grid'">
                        <br />
                        <div :id="'grid'+ suffix" style="width: 100%; max-width: 100%;"></div>
                    </template>
                </div>
            </div>

            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="hasChildNode">
                <form-editing-display v-for="child in children"
                    :depth="depth + 1"
                    :formNode="child"
                    :key="'FED' + child.indicatorID">
                </form-editing-display>
            </template>
        </div>`
}