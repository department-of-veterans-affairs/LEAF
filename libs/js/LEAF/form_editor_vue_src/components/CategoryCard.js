export default {
    data() {
        return {
            staples: []
        }
    },
    props: {
        categoriesRecord: Object
    },
    inject: [
        'selectNewCategory',
        'getStapledFormsByCurrentCategory'
    ],
    mounted() {
        this.getStapledFormsByCurrentCategory(this.catID).then(res => this.staples = res);
    },
    computed: {
        workflowID() {
            return parseInt(this.categoriesRecord.workflowID);
        },
        cardLibraryClasses() {  //NOTE:? often null (LIVE).  called when smarty referFormLibraryID != ''
            return `formPreview formLibraryID_${this.categoriesRecord.formLibraryID}`
        },
        catID() {
            return this.categoriesRecord.categoryID;
        },
        staplesList() {
            let list = [];
            this.staples.forEach(staple => {
                list.push(staple.categoryID)
            });
            return list.join(', ');
        },
        categoryName() { //NOTE: XSSHelpers global
            return this.categoriesRecord.categoryName === '' ? 'Untitled' : XSSHelpers.stripAllTags(this.categoriesRecord.categoryName);
        },
        formDescription() {
            return XSSHelpers.stripAllTags(this.categoriesRecord.categoryDescription);
        },
        availability () {
            return parseInt(this.categoriesRecord.visible) === 1 && this.workflowID > 0 ? 
            'This form is available' : 'Hidden. Users cannot submit new requests.';
        },
        workflow() {
            let msg = ''
            if (this.workflowID===0) {
                msg = 'No Workflow';
            } else {
                msg = this.categoriesRecord.description !== null ? 'Workflow: ' + this.categoriesRecord.description : '';
            }
            return msg;
        }
    },
    template:`<div tabindex="0" 
        @click="selectNewCategory(catID)"
        @keyup.enter="selectNewCategory(catID)"
        :class="cardLibraryClasses" class="browser-category-card"
        :id="catID" 
        :title="catID + ': ' + categoryName">
            <div class="formPreviewTitle" style="position: relative">{{categoryName}}
                <img v-if="parseInt(categoriesRecord.needToKnow) === 1" src="../../libs/dynicons/?img=emblem-readonly.svg&w=16" alt="" 
                title="Need to know mode enabled" style="position: absolute; top: 4px; right: 4px;"/>
            </div>
            <div class="formPreviewDescription" v-html="formDescription"></div>
            <div style="display: flex; justify-content: space-between; margin-top:auto;">
                <div class="formPreviewStatus">{{ availability }}</div>
                <div v-if="staples.length > 0"
                    :title="'This form has stapled forms: ' + staplesList"
                >📌</div>
            </div>
            <div class="formPreviewWorkflow">{{ workflow }}</div>
        </div>`
}