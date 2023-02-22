export default {
    data() {
        return {
            staples: this.categoriesRecord.stapledFormIDs
        }
    },
    props: {
        categoriesRecord: Object
    },
    inject: [
        'libsPath',
        'selectNewCategory',
        'truncateText',
        'stripAndDecodeHTML',
        'stapledFormsCatIDs',
    ],
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
        /**
         * 
         * @returns {string} of formIDs for display on card
         */
        staplesList() {
            let list = [];
            this.staples.forEach(staple => {
                list.push(staple.categoryID)
            });
            return list.join(', ');
        },
        isStapledToOtherForm() {
            return this.stapledFormsCatIDs.includes(this.categoriesRecord.categoryID);
        },
        /**
         * NOTE: uses LEAF XSSHelpers.js
         * @returns {string} truncated category name for card title
         */
        categoryName() {
            let name = this.categoriesRecord.categoryName === '' ? 
                'Untitled' : this.stripAndDecodeHTML(this.categoriesRecord.categoryName);
            return this.truncateText(name, 44);
        },
        formDescription() {
            return this.stripAndDecodeHTML(this.categoriesRecord.categoryDescription);
        },
        availability () {
            return parseInt(this.categoriesRecord.visible) === 1 && this.workflowID > 0 ? 
            'This form is available' : 'Hidden. Users cannot submit new requests.';
        },
        /**
         * 
         * @returns {string} truncated workflow name for card bottom
         */
        workflow() {
            let msg = ''
            if (this.workflowID === 0) {
                msg = 'No Workflow';
            } else {
                msg = this.categoriesRecord.workflowDescription !== null ? 'Workflow: ' + this.categoriesRecord.workflowDescription : '';
            }
            return this.truncateText(msg, 43);
        }
    },
    template:`<div tabindex="0" @click="selectNewCategory(catID)"
          @keyup.enter="selectNewCategory(catID)"
          :class="cardLibraryClasses" class="browser-category-card"
          :id="catID" 
          :title="catID + ': ' + categoryName + (staplesList ? '. Stapled with: ' + staplesList : '') + (isStapledToOtherForm ? '. This form is stapled to another' : '')">
            <div class="formPreviewTitle" style="position: relative">{{categoryName}}
                <img v-if="parseInt(categoriesRecord.needToKnow) === 1" :src="libsPath + 'dynicons/svg/emblem-readonly.svg'" alt="" 
                title="Need to know mode enabled" style="position: absolute; top: 4px; right: 4px; width: 16px"/>
            </div>
            <div class="formPreviewDescription" v-html="formDescription"></div>
            <div style="display: flex; justify-content: space-between;">
                <div class="formPreviewStatus">{{ availability }}</div>
                <div v-if="staples.length > 0"
                    :title="'This form has stapled forms: ' + staplesList">x{{staples.length}}<span role="img" aria="">📌</span></div>
                <div v-if="isStapledToOtherForm"
                    title="This form is stapled to another form"
                ><span role="img" aria="">📑</span></div>
            </div>
            <div class="formPreviewWorkflow">{{ workflow }}</div>
        </div>`
}