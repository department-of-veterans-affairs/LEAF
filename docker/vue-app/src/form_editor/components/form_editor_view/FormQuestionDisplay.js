import FormatPreview from "./FormatPreview";

export default {
    name: 'form-question-display',
    props: {
        categoryID: String,
        depth: Number,
        formPage: Number,
        index: Number,
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
        'focusIndicator',
        'focusedIndicatorID',
        'editQuestion',
        'hasDevConsoleAccess',
        'editAdvancedOptions',
        'openIfThenDialog',
        'listTracker',
        'previewMode',
        'handleNameClick',
        'makePreviewKey',
        'moveListItem'
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
            return (this.formNode?.html !== '' && this.formNode?.html != null) || (this.formNode?.htmlPrint !== '' && this.formNode?.htmlPrint != null);
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
            const contentSensitive = this.sensitive ? `<span class="required-sensitive">*&nbsp;Sensitive</span>&nbsp;${this.sensitiveImg}` : '';
            const shortLabel = (this.formNode?.description || '') !== '' && !this.previewMode ? `<span style="font-weight:normal"> (${this.formNode.description})</span>` : '';
            const staple = this.depth === 0 && this.formNode.categoryID !== this.focusedFormID ? `<span role="img" aria="" alt="">📌&nbsp;</span>` : '';
            const name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            return `${page}${staple}${name}${shortLabel}${contentRequired}${contentSensitive}`;
        },
        required() {
            return parseInt(this.formNode.required) === 1;
        },
        sensitive() {
            return parseInt(this.formNode.is_sensitive) === 1;
        }
    },
    template:`<div class="form_editing_area">
            <div class="name_and_toolbar" :class="{'form-header': isHeader, preview: previewMode}">
                <!-- VISIBLE DRAG INDICATOR / UP DOWN -->
                <button v-show="!previewMode" type="button" :id="'index_listing_' + indicatorID + '_button'"
                :title="'drag to move question (' + indicatorID + ')'"
                class="drag_question_button" @click="focusIndicator(indicatorID)">
                    <div class="icon_move_container">
                        <span role="img" aria="" alt="" class="icon_drag">∷</span>
                        <div v-show="indicatorID === focusedIndicatorID" tabindex="0" class="icon_move up" role="button" title="move item up"
                            @click.stop="moveListItem($event, indicatorID, true)"
                            @keydown.enter.space.prevent.stop="moveListItem($event, indicatorID, true)">
                        </div>
                        <div v-show="indicatorID === focusedIndicatorID" tabindex="0" class="icon_move down" role="button" title="move item down"
                            @click.stop="moveListItem($event, indicatorID, false)"
                            @keydown.enter.space.prevent.stop="moveListItem($event, indicatorID, false)">
                        </div>
                    </div>
                </button>

                <!-- TOOLBAR -->
                <div v-show="!previewMode"
                    :style="{backgroundColor: required ? '#eec8c8' : '#f2f2f5'}"
                    :id="'form_editing_toolbar_' + indicatorID">

                    <div style="width:100%;">
                        <button type="button"
                            :id="'edit_indicator_' + indicatorID"
                            class="btn-general"
                            @click.exact="editQuestion(parseInt(indicatorID))"
                            :title="'edit indicator ' + indicatorID">
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
                        <img v-if="conditionalQuestion" :src="libsPath + 'dynicons/svg/go-jump.svg'" alt="" title="conditional logic is present" />
                        <img v-if="hasCode" :src="libsPath + 'dynicons/svg/document-properties.svg'" alt="" title="advanced options are present" />
                    </div>
                    <button v-if="!isHeader" type="button" class="btn-general"
                        title="Add sub-question"
                        @click="newQuestion(indicatorID)">
                        + Add sub-question
                    </button>
                </div>
                <!-- NAME -->
                <div v-html="indicatorName" @click.stop.prevent="handleNameClick(categoryID, parseInt(indicatorID))"
                    class="indicator-name-preview" :id="'format_label_' + indicatorID">
                </div>
            </div>

            <!-- FORMAT PREVIEW -->
            <format-preview v-if="formNode.format !== ''" :indicator="formNode" :key="'FP_' + indicatorID"></format-preview>
        </div>`
}