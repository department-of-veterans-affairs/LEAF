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
        'editQuestion',
        'openAdvancedOptionsDialog',
        'editIndicatorPrivileges',
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
        children() {
            let eles = [];
            for (let c in this.formNode.child) {
                eles.push(this.formNode.child[c]);
            }
            eles = eles.sort((a, b)=> a.sort - b.sort);
            return eles;
        },
        isHeaderLocation() {
            let ID = parseInt(this.formNode.indicatorID);
            let item = this.listItems[ID];
            return this.allListItemsAreAdded && (item.parentID===null || item.newParentID===null);
        },
        sensitiveImg() {
            return this.sensitive ? 
                `<img src="../../libs/dynicons/?img=eye_invisible.svg&amp;w=16" alt="" class="sensitive-icon"
                    title="This field is sensitive" />` : '';
        },
        conditionalQuestion() {
            return !this.isHeaderLocation && 
                this.formNode.conditions !== null && this.formNode.conditions !== '' & this.formNode.conditions !== 'null';

        },
        conditionsAllowed() {
            return !this.isHeaderLocation && this.allowedConditionChildFormats.includes(this.formNode.format?.toLowerCase());
        },
        indicatorName() {
            const contentRequired = this.required ? `<span class="input-required-sensitive">*&nbsp;Required</span>` : '';
            const contentSensitive = this.sensitive ? `<span class="input-required-sensitive">*&nbsp;Sensitive</span>` : '';

            let name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            name = `${name}${contentRequired}${contentSensitive}  &nbsp;${this.sensitiveImg}`;
            return name;
        },
        printResponseID() {
            return `xhrIndicator_${this.formNode.indicatorID}_${this.formNode.series}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        sensitive() {
            return parseInt(this.formNode.is_sensitive) === 1;
        }
    },
    template:`<div class="printResponse" :id="printResponseID" 
            :style="{minHeight: depth===0 ? '50px': 0, marginLeft: depth===0 ? '0': '0.75rem'}">

            <!-- EDITING AREA FOR INDICATOR -->
            <div class="form_editing_area" 
                :class="{'conditional': conditionalQuestion, 'form-header': isHeaderLocation}">

                <!-- TOOLBAR -->
                <div v-show="showToolbars" 
                    :id="'form_editing_toolbar_' + formNode.indicatorID"
                    :class="{'conditional': conditionalQuestion}">
                    <div style="display: flex; align-items: center;">
                        <span tabindex="0" role="button" style="cursor: pointer; display: flex; align-items:center;"
                            @click="editQuestion(parseInt(formNode.indicatorID))"
                            @keypress.enter="editQuestion(parseInt(formNode.indicatorID))"
                            :title="'edit indicator ' + formNode.indicatorID">📝 <span class="toolbar-edit">EDIT</span>
                        </span>
                        <span style="margin-left: 0.75rem; white-space:nowrap">{{formNode.format || 'no format'}}</span>
                        <span v-if="sensitive" v-html="sensitiveImg" style="margin-left: 0.4rem;"></span>
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
                        <button @click="openAdvancedOptionsDialog(parseInt(formNode.indicatorID))"
                            title="Open Advanced Options" class="icon">
                            <img src="../../libs/dynicons/?img=document-properties.svg&amp;w=20" alt="" />
                        </button>
                        <div style="padding-right: 0.5em; color: #007860; font-weight: bold; width:20px; display:flex; align-items:center;">
                            <div v-if="formNode.has_code" tabindex="0" style="cursor:pointer" class="adv-options-icon" title="advanced options are present">✓</div>
                        </div>
                        <button class="btn-general add-subquestion" title="Add Sub-question"
                            @click="newQuestion(formNode.indicatorID)">
                            + Add Sub-question
                        </button>
                    </div>
                </div>

                <!-- NAME -->
                <div v-html="indicatorName" 
                    class="indicator-name-preview" :id="formNode.indicatorID + '_format_label'"></div>
                
                <!-- FORMAT PREVIEW -->
                <div v-if="formNode.format!==''" class="form_data_entry_preview">
                    <format-preview :indicator="formNode" :key="'FP_' + formNode.indicatorID"></format-preview>
                </div>
            </div>

            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="formNode.child">
                <form-editing-display v-for="child in children"
                    :depth="depth + 1"
                    :formNode="child"
                    :key="'FED_' + child.indicatorID">
                </form-editing-display>
            </template>
        </div>`
}