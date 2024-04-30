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
            const shortLabel = (this.formNode?.description || '') !== '' && !this.previewMode ? `<span style="font-weight:normal"> (${this.formNode.description})</span>` : '';
            const staple = this.depth === 0 && this.formNode.categoryID !== this.focusedFormID ? `<span role="img" aria="" alt="">📌&nbsp;</span>` : '';
            const name = this.formNode.name.trim() !== '' ?  this.formNode.name.trim() : '[ blank ]';
            return `${page}${staple}${name}${shortLabel}${contentRequired}`;
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
                    :id="'form_editing_toolbar_' + indicatorID">

                    <div style="display: grid; grid-template-columns: 1fr auto auto; grid-template-rows: repeat(2, 1fr)">
                        <button type="button"
                            :id="'edit_indicator_' + indicatorID"
                            class="btn-general"
                            :style="{ 'grid-area': depth === 0 ? '1' : '1 / 1 / 3 / 2', 'height': depth === 0 ? 'auto' : '100%' }"
                            @click.exact="editQuestion(parseInt(indicatorID))"
                            :title="'edit indicator ' + indicatorID">
                            <span role="img" aria="" alt="">✏️&nbsp;</span> {{ depth === 0 ? 'Edit Header' : 'Edit' }}
                        </button>
                        <button v-if="hasDevConsoleAccess" type="button" class="btn-general"
                            @click="editAdvancedOptions(parseInt(indicatorID))"
                            :title="hasCode ? 'Open Advanced Options. Advanced options are present.' : 'Open Advanced Options.'">
                            Programmer
                        </button>
                        <button v-if="conditionsAllowed" type="button" :id="'edit_conditions_' + indicatorID"
                            class="btn-general"
                            @click="openIfThenDialog(parseInt(indicatorID), formNode.name.trim())" 
                            :title="conditionalQuestion ? 'Edit conditions for ' + indicatorID + '. Logic present' : 'Edit conditions for ' + indicatorID">
                            Modify Logic
                        </button>
                        <button v-if="!isHeader" type="button" class="btn-general"
                            title="Add sub-question"
                            @click="newQuestion(indicatorID)">
                            + Sub-question
                        </button>
                        <div style="margin-left: auto; grid-area: 1 / 3 / 2 / 4">
                            <span v-if="sensitive"><img :src="libsPath + 'dynicons/svg/eye_invisible.svg'" style="width: 16px; vertical-align: middle; margin: 0 4px 2px 0" alt="" class="sensitive-icon" title="This field is sensitive" /></span>
                            <span v-if="conditionalQuestion" role="img" aria="" alt="" title="conditional logic is present" style="text-shadow: 0 0 1px black, 0 0 1px black; cursor: help">⛓️</span>
                            <span v-if="hasCode" role="img" aria="" alt="" title="advanced options are present" style="text-shadow: 0 0 1px black, 0 0 1px black; cursor: help">⚙️</span>
                        </div>
                    </div>
                </div>
                <!-- NAME -->
                <div v-html="indicatorName"
                    class="indicator-name-preview" :id="'format_label_' + indicatorID">
                </div>
            </div>

            <!-- FORMAT PREVIEW -->
            <format-preview v-if="formNode.format !== ''" :indicator="formNode" :key="'FP_' + indicatorID"></format-preview>
        </div>`
}