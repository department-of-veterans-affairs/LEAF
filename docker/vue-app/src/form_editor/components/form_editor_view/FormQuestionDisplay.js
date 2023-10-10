import FormatPreview from "./FormatPreview";

export default {
    name: 'form-question-display',
    props: {
        depth: Number,
        formPage: Number,
        formNode: Object,
        menuOpen: Boolean
    },
    components: {
        FormatPreview
    },
    inject: [
        'libsPath',
        'newQuestion',
        'shortIndicatorNameStripped',
        'updateFormMenuState',
        'editQuestion',
        'openAdvancedOptionsDialog',
        'openIfThenDialog',
        'listTracker',
        'allowedConditionChildFormats',
        'showToolbars',
        'handleNameClick',
        'makePreviewKey'
    ],
    computed: {
        indicatorID() {
            return +this.formNode?.indicatorID;
        },
        showDetails() {
            return !this.showToolbars || this.menuOpen || this.depth > 0;
        },
        isHeaderLocation() {
            let item = this.listTracker[this.indicatorID];
            return (item?.parentID === null || item?.newParentID === null);
        },
        sensitiveImg() {
            return this.sensitive ? 
                `<img src="${this.libsPath}dynicons/svg/eye_invisible.svg"
                    style="width: 16px; margin-left: 4px;" alt="" class="sensitive-icon"
                    title="This field is sensitive" />` : '';
        },
        hasCode() {
            return this.formNode?.html || this.formNode?.htmlPrint;
        },
        conditionalQuestion() {
            return !this.isHeaderLocation && 
                this.formNode.conditions !== null && this.formNode.conditions !== '' & this.formNode.conditions !== 'null';
        },
        conditionsAllowed() {
            return !this.isHeaderLocation && this.allowedConditionChildFormats.includes(this.formNode.format?.toLowerCase());
        },
        indicatorName() {
            const contentRequired = this.required ? `<span class="required-sensitive">*&nbsp;Required</span>` : '';
            const contentSensitive = this.sensitive ? `<span class="required-sensitive">*&nbsp;Sensitive</span>&nbsp;${this.sensitiveImg}` : '';
            const shortLabel = (this.formNode?.description || '') !== '' ? ` (${this.formNode.description})` : '';
            const name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';

            return `${name}${shortLabel}${contentRequired}${contentSensitive}`;
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
    template:`<div v-if="showDetails" class="printResponse" :class="{'form-header': isHeaderLocation}" :id="printResponseID">
            <button v-if="depth===0 && showToolbars" type="button" :id="'card_btn_open_' + indicatorID"
                class="card_toggle" title="collapse page"
                @click.exact="updateFormMenuState(indicatorID, false)"
                @click.ctrl.exact="updateFormMenuState(indicatorID, false, true)"
                aria-label="collapse page">-
            </button>

            <!-- EDITING AREA FOR INDICATOR -->
            <div class="form_editing_area" :class="{'conditional': conditionalQuestion}">
                <div class="name_and_toolbar" :class="{'form-header': isHeaderLocation}">
                    <!-- NAME -->
                    <div v-html="indicatorName" @click.stop.prevent="handleNameClick(parseInt(indicatorID))"
                        class="indicator-name-preview" :id="indicatorID + '_format_label'">
                    </div>

                    <!-- TOOLBAR -->
                    <div v-show="showToolbars"
                        :style="{backgroundColor: required ? '#eec8c8' : '#f2f2f5'}"
                        :id="'form_editing_toolbar_' + indicatorID">
    
                        <div style="width:100%;">
                            <button v-show="showToolbars" type="button"
                                class="btn-general"
                                @click="editQuestion(parseInt(indicatorID))"
                                :title="'edit indicator ' + indicatorID">
                                {{ depth === 0 ? 'Edit Header' : 'Edit' }}
                            </button>
                            <button v-if="conditionsAllowed" type="button" :id="'edit_conditions_' + indicatorID"
                                class="btn-general"
                                @click="openIfThenDialog(parseInt(indicatorID), formNode.name.trim())" 
                                :title="'Edit conditions for ' + indicatorID">
                                Modify Logic
                            </button>
                            <button type="button"
                                @click="openAdvancedOptionsDialog(parseInt(indicatorID))"
                                :title="hasCode ? 'Open Advanced Options. Advanced options are present.' : 'Open Advanced Options.'"
                                :class="{'btn-confirm': hasCode, 'btn-general': !hasCode}">
                                Programmer
                            </button>
                        </div>
                        <button type="button" class="btn-general"
                            :title="isHeaderLocation ? 'Add question to section' : 'Add sub-question'"
                            @click="newQuestion(indicatorID)">
                            + {{isHeaderLocation ? 'Add question to section' : 'Add sub-question'}}
                        </button>
                    </div>

                </div>

                <!-- FORMAT PREVIEW -->
                <format-preview v-if="formNode.format !== ''" :indicator="formNode" :key="'FP_' + indicatorID"></format-preview>
            </div>

            <!-- NOTE: RECURSIVE SUBQUESTIONS -->
            <template v-if="formNode.child">
                <form-question-display v-for="child in formNode.child"
                    :depth="depth + 1"
                    :formPage="formPage"
                    :formNode="child"
                    :key="'FED_' + child.indicatorID + makePreviewKey(child)">
                </form-question-display>
            </template>
    </div>

    <div v-else tabindex="0" class="form-page-card">
        <button type="button" :id="'card_btn_closed_' + indicatorID"
            class="card_toggle closed" title="expand page"
            @click.exact="updateFormMenuState(indicatorID, true)"
            @click.ctrl.exact="updateFormMenuState(indicatorID, true, true)"
            aria-label="expand page">+</button>
        <div>
            <b>{{ shortIndicatorNameStripped(formNode.name, 60) }}</b> {{formNode.description ? '(' + formNode.description + ')' : ''}}
        </div>
    </div>`
}