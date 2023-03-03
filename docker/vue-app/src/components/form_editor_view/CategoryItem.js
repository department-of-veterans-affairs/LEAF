export default {
    name: 'category-item',
    props: {
        categoriesRecord: Object,
        availability: String
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'libsPath',
        'categories',
        'updateCategoriesProperty',
        'stripAndDecodeHTML',
        'allStapledFormCatIDs',
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
        stapledForms() {
            let stapledForms = [];
            this.categoriesRecord.stapledFormIDs.forEach(id => stapledForms.push({...this.categories[id]}));
            stapledForms = stapledForms.sort((eleA, eleB) => eleA.sort - eleB.sort );
            return stapledForms;
        },
        isStapledToOtherForm() {
            return this.allStapledFormCatIDs.includes(this.categoriesRecord.categoryID);
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
                msg = `${this.categoriesRecord.workflowDescription || 'No Description'} (#${this.categoriesRecord.workflowID})`;
            } else {
                msg = 'No Workflow';
            }
            return msg;
        }
    },
    methods: {
        updateSort(event = {}, categoryID = '') {
            let sortValue = parseInt(event.currentTarget.value);
            if(isNaN(sortValue)) return;

            if (sortValue < -128) {
                sortValue = -128;
                event.currentTarget.value = -128;
            }
            if (sortValue > 127) {
                sortValue = 127;
                event.currentTarget.value = 127;
            }
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/formSort`,
                data: {
                    sort: sortValue,
                    categoryID: categoryID,
                    CSRFToken: this.CSRFToken
                },
                success: () => {
                    this.updateCategoriesProperty(categoryID, 'sort', sortValue);
                },
                error: err => console.log('sort post err', err)
            })
        }
    },
    template:`<tr :id="catID" :title="catID + ': ' + categoryName">
            <td height="40" class="form-name">
                <router-link :to="{ name: 'category', query: { formID: catID }}">
                {{ categoryName }}
                </router-link>
            </td>
            <td class="formPreviewDescription">{{ formDescription }}</td>
            <td v-if="availability !== 'supplemental'">{{ workflowDescription }}</td>
            <td v-if="availability === 'supplemental'">
                <div v-if="allStapledFormCatIDs.includes(catID)" style="display: flex; justify-content: center;">
                    <span role="img" aria="">📑</span>&nbsp;Stapled
                </div>
            </td>
            <td>
                <div v-if="parseInt(categoriesRecord.needToKnow) === 1" class="need-to-know-enabled">
                    <img :src="libsPath + 'dynicons/svg/emblem-readonly.svg'" alt="" style="width: 20px;margin-right:2px"/>
                    &nbsp;<em>Need to Know enabled</em>
                </div>
            </td>
            <td>
                <input type="number" @change="updateSort($event, catID)"
                    :aria-labelledby="availability + '_sort'"
                    :value="categoriesRecord.sort" min="-128" max="127"
                    style="width: 100%; min-width:50px;" />
            </td>
        </tr>
        <template v-if="stapledForms.length > 0">
            <tr v-for="form in stapledForms" :key="catID + '_stapled_with_' + form.categoryID" class="sub-row">
                <td height="36" class="form-name">
                    <router-link :to="{ name: 'category', query: { formID: form.categoryID }}">
                        <span role="img" aria="">📌&nbsp;</span>{{ categories[form.categoryID].categoryName }}
                    </router-link>
                </td>
                <td>{{ categories[form.categoryID].categoryDescription }}</td>
                <td></td>
                <td>
                    <div v-if="parseInt(categories[form.categoryID].needToKnow) === 1" class="need-to-know-enabled">
                        <img :src="libsPath + 'dynicons/svg/emblem-readonly.svg'" alt="" style="width: 20px;margin-right:2px"/>
                        &nbsp;<em>Need to Know enabled</em>
                    </div>
                </td>
                <td>
                    <input type="number" @change="updateSort($event, form.categoryID)"
                        :aria-labelledby="availability + '_sort'"
                        :value="categories[form.categoryID].sort" min="-128" max="127"
                        style="width: 100%; min-width:50px;" />
                </td>
            </tr>
        </template>`
}