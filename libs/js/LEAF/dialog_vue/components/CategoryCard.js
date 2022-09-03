export default {
    props: {
        category: Object
    },
    inject: [
        'selectNewCategory',
    ],
    computed: {
        workflowID() {
            return parseInt(this.category.workflowID);
        },
        cardLibraryClasses() {  //NOTE:? often null (LIVE).  called when smarty referFormLibraryID != ''
            return `formPreview formLibraryID_${this.category.formLibraryID}`
        },
        categoryName() {
            return this.category.categoryName === '' ? 'Untitled' : this.category.categoryName;
        },
        formDescription() {
            return this.category.categoryDescription;
        },
        availability () {
            return this.category.visible === 1 && this.workflowID > 0 ? 
            'This form is available' : 'Hidden. Users cannot submit new requests.';
        },
        workflow() {
            let msg = ''
            if (this.workflowID===0) {
                msg = 'No Workflow';
            } else {
                msg = this.category.description !== null ? 'Workflow: ' + this.category.description : '';
            }
            return msg;
        }
    },
    template:`<div tabindex="0" 
        @click="selectNewCategory(category.categoryID)"
        @keyup.enter="selectNewCategory(category.categoryID)"
        :class="cardLibraryClasses" class="browser-category-card"
        :id="category.categoryID" 
        :title="category.categoryID">
            <div class="formPreviewTitle" style="position: relative"><div v-html="categoryName"></div>
                <img v-if="parseInt(category.needToKnow) === 1" src="../../libs/dynicons/?img=emblem-readonly.svg&w=16" alt="" 
                title="Need to know mode enabled" style="position: absolute; top: 4px; right: 4px; z-index:10;"/>
            </div>
            <div class="formPreviewDescription" v-html="formDescription"></div>
            <div class="formPreviewStatus">{{ availability }}</div>
            <div class="formPreviewWorkflow">{{ workflow }}</div>
        </div>`
}