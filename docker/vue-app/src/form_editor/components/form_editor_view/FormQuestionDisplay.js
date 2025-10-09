import FormatPreview from "./FormatPreview";

export default {
    name: 'form-question-display',
    props: {
        categoryID: String,
        depth: Number,
        formPage: Number,
        index: Number,
        currentListLength: Number,
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
        'focusedIndicatorID',
        'editQuestion',
        'hasDevConsoleAccess',
        'editAdvancedOptions',
        'openIfThenDialog',
        'listTracker',
        'previewMode',
        'makePreviewKey',
    ],
    computed: {
        indicatorID() {
            return +this.formNode?.indicatorID;
        },
        isHeader() {
            return this.depth === 0;
        },
        hasCode() {
            return (this.formNode?.html || '').trim() !== '' || (this.formNode?.htmlPrint || '').trim() !== '';
        },
        conditionalQuestion() {
            return !this.isHeader &&
                this.formNode.conditions !== null && this.formNode.conditions !== '' & this.formNode.conditions !== 'null';
        },
        conditionsAllowed() {
            return !this.isHeader && (this.formNode.format || '').toLowerCase() !== 'raw_data';
        },
        indicatorName() {
            const page = this.depth === 0 ? `<div class="form_page">${this.formPage + 1}</div>`: '';
            const contentRequired = this.required ? `<span class="required-sensitive">*&nbsp;Required</span>` : '';
            const shortLabel = (this.formNode?.description || '') !== '' && !this.previewMode ? `<span style="font-weight:normal"> (${this.formNode.description})</span>` : '';
            const staple = this.depth === 0 && this.formNode.categoryID !== this.focusedFormID ? `<span role="img" aria-hidden="true" alt="">📌&nbsp;</span>` : '';

            let indName = this.formNode.name.trim();
            if (indName === "") {
                indName = "[ blank ]";
            }
            let indSSN_warn = "";
            if (false && /(SSN|social\s*security\s*number)/gmi.test(indName)) {
                indSSN_warn = `<div class="entry_warning bg-yellow-5" style="margin-bottom:0.25rem;">
                    <span role="img" alt="warning">⚠️</span>
                </div>`
            }
            const name = indSSN_warn + '<span class="name">' + indName + '</span>';

            return `${page}${staple}${name}${shortLabel}${contentRequired}`;
        },
        hasSpecialAccessRestrictions() {
            return parseInt(this.formNode.isMaskable) === 1;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        sensitive() {
            return parseInt(this.formNode.is_sensitive) === 1;
        },
    },
    template:`<div class="form_editing_area">
            <div class="name_and_toolbar" :class="{'form-header': isHeader, preview: previewMode}">
                <!-- TOOLBAR -->
                <div v-show="!previewMode"
                    :id="'form_editing_toolbar_' + indicatorID">

                    <div style="display: grid; grid-template-columns: 1fr auto auto; grid-template-rows: repeat(2, 1fr)">
                        <button type="button"
                            :id="'edit_indicator_' + indicatorID"
                            class="btn-general"
                            :style="{ 'grid-area': depth === 0 ? '1' : '1 / 1 / 3 / 2', 'height': depth === 0 ? 'auto' : '100%' }"
                            @click.exact="editQuestion(parseInt(indicatorID))"
                            :title="'edit indicator ' + indicatorID">
                            <span role="img" aria-hidden="true" alt="">✏️&nbsp;</span> {{ depth === 0 ? 'Edit Header' : 'Edit' }}
                        </button>
                        <button v-if="hasDevConsoleAccess" type="button"
                            :id="'programmer_indicator_' + indicatorID" class="btn-general"
                            @click="editAdvancedOptions(parseInt(indicatorID))">
                            Programmer
                        </button>
                        <button v-if="conditionsAllowed" type="button" :id="'edit_conditions_' + indicatorID"
                            class="btn-general"
                            @click="openIfThenDialog(parseInt(indicatorID), formNode.name.trim())">
                            Modify Logic
                        </button>
                        <button v-if="!isHeader" type="button" :id="'add_question_to_' + indicatorID"
                            class="btn-general"
                            title="add sub-question"
                            aria-label="add sub-question"
                            @click="newQuestion(indicatorID)">
                            + Sub-question
                        </button>
                        <div style="margin-left: auto; grid-area: 1 / 3 / 2 / 4">
                            <span v-if="sensitive">
                                <img :src="libsPath + 'dynicons/svg/eye_invisible.svg'" style="width: 16px; vertical-align: middle; margin: 0 4px 2px 0" alt="" class="sensitive-icon" title="This field is sensitive" />
                            </span>
                            <span v-if="hasSpecialAccessRestrictions" role="img" alt="special access restrictions are present" title="special access restrictions are present" style="text-shadow: 0 0 1px black, 0 0 1px black; cursor: help">🔒</span>
                            <span v-if="conditionalQuestion" role="img" alt="conditional logic is present" title="conditional logic is present" style="text-shadow: 0 0 1px black, 0 0 1px black; cursor: help">⛓️</span>
                            <span v-if="hasCode" role="img" alt="advanced options are present" title="advanced options are present" style="text-shadow: 0 0 1px black, 0 0 1px black; cursor: help">⚙️</span>
                        </div>
                    </div>
                </div>
                <!-- NAME -->
                <div v-html="indicatorName"
                    class="indicator-name-preview" :id="'format_label_' + indicatorID">
                </div>
            </div>

            <!-- FORMAT PREVIEW -->
            <format-preview :indicator="formNode" :key="'FP_' + indicatorID"></format-preview>
        </div>`
}