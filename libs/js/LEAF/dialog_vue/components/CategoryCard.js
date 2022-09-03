export default {
    props: {
        category: Object
    },
    inject: ['selectNewCategory'],
    computed: {
        workflowID() {
            return parseInt(this.category.workflowID);
        },
        cardLibraryClasses() {  //NOTE:? often null (LIVE).  called when smarty referFormLibraryID != ''
            return `formPreview formLibraryID_${this.category.formLibraryID}`
        },
        formTitle() {
            return this.category.categoryName === '' ? 'Untitled' : this.category.categoryName;
        },
        availability () {
            return this.category.visible == 1 ? '' : 'Hidden. Users cannot submit new requests.';
        },
        workflow() {
            return this.category.description !== null ? 'Workflow: ' + this.category.description : '';
        }
    },
    template:`<div tabindex="0" 
        @click="selectNewCategory(category.categoryID)"
        @keyup.enter="selectNewCategory(category.categoryID)"
        :class="cardLibraryClasses" 
        :id="category.categoryID" 
        :title="category.categoryID">
            <div class="formPreviewTitle" style="position: relative">{{ formTitle }}
                <img v-if="category.needToKnow == 1" src="../../libs/dynicons/?img=emblem-readonly.svg&w=16" alt="" 
                title="Need to know mode enabled" style="position: absolute; top: 4px; right: 4px; z-index:10;"/>
            </div>
            <div class="formPreviewDescription" v-html="category.categoryDescription"></div>
            <div class="formPreviewStatus">{{ availability }}</div>
            <div class="formPreviewWorkflow">{{ workflow }}</div>
        </div>`
}