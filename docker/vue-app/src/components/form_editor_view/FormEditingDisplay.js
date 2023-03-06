import FormatPreview from "@/components/form_editor_view/FormatPreview";

export default {
    name: 'FormEditingDisplay',
    props: {
        depth: Number,
        formNode: Object,
        index: Number
    },
    components: {
        FormatPreview
    },
    inject: [
        'libsPath',
        'newQuestion',
        'editQuestion',
        'openAdvancedOptionsDialog',
        'openIfThenDialog',
        'listTracker',
        'allowedConditionChildFormats',
        'showToolbars',
        'toggleToolbars'
    ],
    mounted() {
        //console.log('form editing area mounted');
    },
    computed: {
        isHeaderLocation() {
            let ID = parseInt(this.formNode.indicatorID);
            let item = this.listTracker[ID];
            return (item?.parentID === null || item?.newParentID === null);
        },
        sensitiveImg() {
            return this.sensitive ? 
                `<img src="${this.libsPath}dynicons/svg/eye_invisible.svg"
                    style="width: 16px; margin-left: 4px;" alt="" class="sensitive-icon"
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
        indicatorFormat() {
            return `<span style="font-weight: normal; font-size: 90%; color:#404046;">${this.formNode?.format}</span> ${this.sensitiveImg}`;
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
    template:`<div class="printResponse" 
            :class="{'form-header': isHeaderLocation}"
            style="margin-bottom: 1rem;"
            :id="printResponseID">

            <!-- EDITING AREA FOR INDICATOR -->
            <div class="form_editing_area" style="display:flex"
                :class="{'conditional': conditionalQuestion, 'form-header': isHeaderLocation}">

                <div style="width: 100%;">
                    <!-- NAME -->
                    <div style="display:flex;">
                        <button v-show="showToolbars" type="button" @click="editQuestion(parseInt(formNode.indicatorID))"
                            class="icon" :title="'edit indicator ' + formNode.indicatorID" style="margin-top: 2px;">
                            <img :src="libsPath + 'dynicons/svg/accessories-text-editor.svg'" style="width: 20px" alt="" />
                        </button>
                        <div v-html="indicatorName" @click="toggleToolbars($event)"
                        class="indicator-name-preview" :id="formNode.indicatorID + '_format_label'"></div>
                    </div>
                    <!-- FORMAT PREVIEW -->
                    <div v-if="formNode.format !== ''" class="form_data_entry_preview">
                        <format-preview :indicator="formNode" :key="'FP_' + formNode.indicatorID"></format-preview>
                    </div>
                </div>
                <!-- TOOLBAR -->
                <div v-show="showToolbars"
                    :style="{backgroundColor: required ? '#eec8c8' : '#f2f2f5'}"
                    :id="'form_editing_toolbar_' + formNode.indicatorID"
                    :class="{'conditional': conditionalQuestion}">

                    <div v-html="indicatorFormat" style="white-space:nowrap;"></div>

                    <div style="width:100%;">
                        <div style="display:flex; align-items:center; margin-right: auto;">
                            <img v-if="formNode.has_code" tabindex="0" title="advanced options are present"
                            style="cursor:pointer; width: 20px;" :src="libsPath + 'dynicons/svg/document-properties.svg'" alt="advanced options are present" />
                        </div>
                        <button v-if="conditionsAllowed" type="button" :id="'edit_conditions_' + formNode.indicatorID" 
                            @click="openIfThenDialog(parseInt(formNode.indicatorID), formNode.name.trim())" 
                            :title="'Edit conditions for ' + formNode.indicatorID" class="icon">
                            <img :src="libsPath + 'dynicons/svg/preferences-system.svg'" style="width: 20px" alt="" />
                        </button>
                        <button type="button" @click="openAdvancedOptionsDialog(parseInt(formNode.indicatorID))"
                            title="Open Advanced Options" class="icon">
                            <img :src="libsPath + 'dynicons/svg/emblem-system.svg'" style="width: 20px" alt="" />
                        </button>
                    </div>
                    <button type="button" class="btn-general add-subquestion" 
                        :title="isHeaderLocation ? 'Add question to section' : 'Add sub-question'"
                        @click="newQuestion(formNode.indicatorID)">
                        + {{isHeaderLocation ? 'Add question to section' : 'Add sub-question'}}
                    </button>
                </div>
            </div>

            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="formNode.child">
                <form-editing-display v-for="child in formNode.child"
                    :depth="depth + 1"
                    :formNode="child"
                    :key="'FED_' + child.indicatorID">
                </form-editing-display>
            </template>
        </div>`
}