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
        'getStapledFormsByCurrentCategory',
        'truncateText',
        'formsStapledCatIDs',
        'updateFormsStapledCatIDs'
    ],
    mounted() {
        this.getStapledFormsByCurrentCategory(this.catID).then(res => {
            this.staples = res;
            for (let s in res) {
                this.updateFormsStapledCatIDs(res[s].stapledCategoryID);
            }
        });
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
        isStapledToOtherForm() {
            return this.formsStapledCatIDs.includes(this.categoriesRecord.categoryID);
        },
        categoryName() { //NOTE: XSSHelpers global
            let name = this.categoriesRecord.categoryName === '' ? 
                'Untitled' : XSSHelpers.stripAllTags(this.categoriesRecord.categoryName);
            return this.truncateText(name, 41);
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
        :title="catID + ': ' + categoryName + (staplesList ? '. Stapled with: ' + staplesList : '') + (isStapledToOtherForm ? '. This form is stapled to another' : '')">
            <div class="formPreviewTitle" style="position: relative">{{categoryName}}
                <img v-if="parseInt(categoriesRecord.needToKnow) === 1" src="../../libs/dynicons/?img=emblem-readonly.svg&w=16" alt="" 
                title="Need to know mode enabled" style="position: absolute; top: 4px; right: 4px;"/>
            </div>
            <div class="formPreviewDescription" v-html="formDescription"></div>
            <div style="display: flex; justify-content: space-between;">
                <div class="formPreviewStatus">{{ availability }}</div>
                <div v-if="staples.length > 0"
                    :title="'This form has stapled forms: ' + staplesList"
                >📌</div>
                <div v-if="isStapledToOtherForm"
                    title="This form is stapled to another form"
                >📑</div>
            </div>
            <div class="formPreviewWorkflow">{{ workflow }}</div>
        </div>`
}