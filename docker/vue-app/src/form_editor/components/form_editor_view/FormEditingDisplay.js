import FormatPreview from "./FormatPreview";

export default {
    name: 'form-editing-display',
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
        'toggleToolbars',
        'makePreviewKey'
    ],
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
            const shortLabel = (this.formNode?.description || '') !== '' ? ` (${this.formNode.description})` : '';

            let name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            name = `${name}${shortLabel}${contentRequired}${contentSensitive}  &nbsp;${this.sensitiveImg}`;
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
                        <div v-html="indicatorName" @click="toggleToolbars($event, parseInt(formNode.indicatorID))"
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

                    <div style="width:100%;">
                        <button v-show="showToolbars" type="button"
                            class="btn-general"
                            @click="editQuestion(parseInt(formNode.indicatorID))"
                            :title="'edit indicator ' + formNode.indicatorID">
                            {{ depth === 0 ? 'Edit Header' : 'Edit' }}
                        </button>
                        <button v-if="conditionsAllowed" type="button" :id="'edit_conditions_' + formNode.indicatorID"
                            class="btn-general"
                            @click="openIfThenDialog(parseInt(formNode.indicatorID), formNode.name.trim())" 
                            :title="'Edit conditions for ' + formNode.indicatorID">
                            Modify Logic
                        </button>
                        <button type="button"
                            @click="openAdvancedOptionsDialog(parseInt(formNode.indicatorID))"
                            :title="'Open Advanced Options.' + formNode.has_code ? 'Advanced options are present' : ''"
                            :class="{'btn-confirm': formNode.has_code, 'btn-general': !formNode.has_code}">
                            Programmer
                        </button>
                    </div>
                    <button type="button" class="btn-general"
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
                    :key="'FED_' + child.indicatorID + makePreviewKey(child)">
                </form-editing-display>
            </template>
        </div>`
}