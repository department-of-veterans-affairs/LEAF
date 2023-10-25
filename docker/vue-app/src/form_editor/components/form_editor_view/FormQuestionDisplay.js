import FormatPreview from "./FormatPreview";

export default {
    name: 'form-question-display',
    data() {
        return {
            dragging: false
        }
    },
    props: {
        categoryID: String,
        depth: Number,
        formPage: Number,
        formNode: Object
    },
    components: {
        FormatPreview
    },
    inject: [
        'libsPath',
        'newQuestion',
        'shortIndicatorNameStripped',
        'focusedFormID',
        'editQuestion',
        'hasDevConsoleAccess',
        'editAdvancedOptions',
        'openIfThenDialog',
        'listTracker',
        'allowedConditionChildFormats',
        'previewMode',
        'handleNameClick',
        'makePreviewKey'
    ],
    computed: {
        indicatorID() {
            return +this.formNode?.indicatorID;
        },
        isHeader() {
            return this.depth === 0;
        },
        sensitiveImg() {
            return this.sensitive ? 
                `<img src="${this.libsPath}dynicons/svg/eye_invisible.svg"
                    style="width: 16px; margin-left: 4px;" alt="" class="sensitive-icon"
                    title="This field is sensitive" />` : '';
        },
        hasCode() {
            return this.formNode?.html !== '' || this.formNode?.htmlPrint !== '';
        },
        conditionalQuestion() {
            return !this.isHeader && 
                this.formNode.conditions !== null && this.formNode.conditions !== '' & this.formNode.conditions !== 'null';
        },
        conditionsAllowed() {
            return !this.isHeader && this.allowedConditionChildFormats.includes(this.formNode.format?.toLowerCase());
        },
        indicatorName() {
            const page = this.depth === 0 ? `<div class="form_page">${this.formPage + 1}</div>`: '';
            const contentRequired = this.required ? `<span class="required-sensitive">*&nbsp;Required</span>` : '';
            const contentSensitive = this.sensitive ? `<span class="required-sensitive">*&nbsp;Sensitive</span>&nbsp;${this.sensitiveImg}` : '';
            const shortLabel = (this.formNode?.description || '') !== '' && !this.previewMode ? `<span style="font-weight:normal"> (${this.formNode.description})</span>` : '';
            const staple = this.depth === 0 && this.formNode.categoryID !== this.focusedFormID ? `<span role="img" aria="" alt="">📌&nbsp;</span>` : '';
            const name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            return `${page}${staple}${name}${shortLabel}${contentRequired}${contentSensitive}`;
        },
        printResponseID() {
            return `xhrIndicator_${this.indicatorID}_${this.formNode.series}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        sensitive() {
            return parseInt(this.formNode.is_sensitive) === 1;
        }
    },
    template:`<div v-if="!dragging" class="printResponse" :class="{'form-header': isHeader, preview: previewMode}" :id="printResponseID">
        <!-- NOTE: QUESTION EDITING AREA -->
        <div class="form_editing_area" :class="{'conditional': conditionalQuestion}">
            <div class="name_and_toolbar" :class="{'form-header': isHeader, preview: previewMode}">
                <!-- NAME -->
                <div v-html="indicatorName" @click.stop.prevent="handleNameClick(categoryID, parseInt(indicatorID))"
                    class="indicator-name-preview" :id="indicatorID + '_format_label'"
                    :class="{'conditional': conditionalQuestion}">
                </div>

                <!-- TOOLBAR -->
                <div v-show="!previewMode"
                    :style="{backgroundColor: required ? '#eec8c8' : '#f2f2f5'}"
                    :id="'form_editing_toolbar_' + indicatorID">

                    <div style="width:100%;">
                        <button type="button"
                            :id="'edit_indicator_' + indicatorID"
                            class="btn-general"
                            @click.exact="editQuestion(parseInt(indicatorID))"
                            :title="'edit indicator ' + indicatorID + '. Control-click to nav to form index.'">
                            {{ depth === 0 ? 'Edit Header' : 'Edit' }}
                        </button>
                        <button v-if="conditionsAllowed" type="button" :id="'edit_conditions_' + indicatorID"
                            class="btn-general"
                            @click="openIfThenDialog(parseInt(indicatorID), formNode.name.trim())" 
                            :title="'Edit conditions for ' + indicatorID">
                            Modify Logic
                        </button>
                        <button v-if="hasDevConsoleAccess === 1" type="button" class="btn-general"
                            @click="editAdvancedOptions(parseInt(indicatorID))"
                            :title="hasCode ? 'Open Advanced Options. Advanced options are present.' : 'Open Advanced Options.'">
                            Programmer
                        </button>
                        <img v-if="hasCode" :src="libsPath + 'dynicons/svg/document-properties.svg'" alt="" title="advanced options are present" />
                    </div>
                    <button v-if="!isHeader" type="button" class="btn-general"
                        title="Add sub-question"
                        @click="newQuestion(indicatorID)">
                        Add sub-question
                    </button>
                </div>
            </div>

            <!-- FORMAT PREVIEW -->
            <format-preview v-if="formNode.format !== ''" :indicator="formNode" :key="'FP_' + indicatorID"></format-preview>
        </div>

        <!-- NOTE: RECURSIVE SUBQUESTIONS -->
        <template v-if="formNode.child">
            <form-question-display v-for="child in formNode.child"
                :categoryID="categoryID"
                :depth="depth + 1"
                :formPage="formPage"
                :formNode="child"
                :key="'FED_' + child.indicatorID + makePreviewKey(child)">
            </form-question-display>
        </template>
        <button v-if="depth === 0 && !previewMode" type="button" class="btn-general new_section_question"
            title="Add Question to Section"
            @click="newQuestion(formNode.indicatorID)">
            Add Question to Section
        </button>
    </div>
    <div v-else class="form-page-card" :id="'form_card_' + indicatorID">
        <div class="form_page">{{ formPage + 1 }}</div>
        <b>{{ shortIndicatorNameStripped(formNode.name, 60) }}</b>
        <div class="descr" v-if="formNode.description">({{ formNode.description }})</div>
    </div>`
}