import PrintSubindicators from './PrintSubindicators.js';
import FormEntryDisplay from './FormEntryDisplay.js';
import FormIndexListing from './FormIndexListing.js';

export default {
    components: {
        PrintSubindicators,
        FormEntryDisplay,
        FormIndexListing
    },
    inject: [
        'ajaxFormByCategoryID',
        'newQuestion',
        'currentCategorySelection',
    ],
    computed: {
        formID() {
            return this.currentCategorySelection.categoryID;
        },
        formName() {
            return this.currentCategorySelection.categoryName || 'Untitled';
        },
    },
    template:`
    <div style="display:flex;">

        <!-- FORM INDEX DISPLAY -->
        <div id="form_index_display">
            <h3 style="margin: 0; margin-bottom: 0.5em; color: black;">{{ formName }}</h3>
            <ul v-if="ajaxFormByCategoryID.length > 0">
                <form-index-listing v-for="(formSection, i) in ajaxFormByCategoryID"
                    :depth="0"
                    :formNode="formSection"
                    :sectionNumber=i+1
                    :key="formSection.indicatorID">
                </form-index-listing>
            </ul>
        </div>

        <!-- FORM ENTRY DISPLAY -->
        <div style="display:flex; flex-direction: column; width: 100%; background-color: white; border: 1px solid black; min-width: 400px;">
            <template v-if="ajaxFormByCategoryID.length > 0">
                <template v-for="(formSection, i) in ajaxFormByCategoryID">
                    <div class="printformblock">
                        <print-subindicators 
                            :depth="0"
                            :formNode="formSection"
                            :sectionNumber=i+1
                            :key="formSection.indicatorID">
                        </print-subindicators>
                    </div>
                </template>
            </template>
            <div class="buttonNorm" role="button" tabindex="0" 
                @click="newQuestion(null)" @keypress.enter="newQuestion(null)"
                style="margin: 0 -1px -1px -1px">
                <img src="../../libs/dynicons/?img=list-add.svg&amp;w=16" alt="" title="Add Section Heading"/> Add Section Heading
            </div>
        </div>
    </div>`
}