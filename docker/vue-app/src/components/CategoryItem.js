export default {
    name: 'category-item',
    data() {
        return {
            staples: this.categoriesRecord.stapledFormIDs
        }
    },
    props: {
        categoriesRecord: Object,
        availability: String
    },
    inject: [
        'libsPath',
        'categories',
        'selectNewCategory',
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
            return name;
        },
        formDescription() {
            return this.stripAndDecodeHTML(this.categoriesRecord.categoryDescription);
        },
        /**
         * 
         * @returns {string} workflow ID and description
         */
        workflowDescription() {
            let msg = '';
            if (this.workflowID > 0) {
                msg = `#${this.categoriesRecord.workflowID}:(${this.categoriesRecord.workflowDescription || 'No Description'})`;
            } else {
                msg = 'No Workflow';
            }
            return msg;
        }
    },
    template:`<tr height="40" tabindex="0"
        @click="selectNewCategory(catID)" @keyup.enter="selectNewCategory(catID)" 
        :id="catID" :title="catID + ': ' + categoryName">
            <td>{{ categoryName }}</td>
            <td class="formPreviewDescription">{{ formDescription }}</td>
            <td v-if="availability !== 'supplemental'">{{ workflowDescription }}</td>
            <td v-if="availability==='supplemental'">
                <div v-if="stapledFormsCatIDs.includes(catID)" style="display: flex; justify-content: center;">
                    <span role="img" aria="">📑</span>&nbsp;Stapled
                </div>
            </td>
            <td>
                <div v-if="parseInt(categoriesRecord.needToKnow) === 1" class="need-to-know-enabled">
                    <img :src="libsPath + 'dynicons/svg/emblem-readonly.svg'" alt="" style="width: 20px;"/>
                    <em>&nbsp;Need to Know enabled</em>
                </div>
            </td>
        </tr>
        <template v-if="staples.length > 0">
            <tr height="40" v-for="staple_id in staples" :key="catID + '_stapled_with_' + staple_id"
                tabindex="0" style="padding-left:1rem; font-size: 85%;"
                @click="selectNewCategory(staple_id)" @keyup.enter="selectNewCategory(staple_id)">
                <td><span role="img" aria="">📌 </span>{{ categories[staple_id].categoryName }}</td>
                <td>{{ categories[staple_id].categoryDescription }}</td>
                <td></td>
                <td>
                    <div v-if="parseInt(categories[staple_id].needToKnow) === 1" class="need-to-know-enabled">
                        <img :src="libsPath + 'dynicons/svg/emblem-readonly.svg'" alt="" style="width: 20px;"/>
                        <em>&nbsp;Need to Know enabled</em>
                    </div>
                </td>
            </tr>
        </template>`
}