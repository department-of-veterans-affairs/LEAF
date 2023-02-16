import CategoryCard from "../components/CategoryCard";

export default {
    data() {
        return {
            test: 'test'
        }
    },
    inject: [
        'appIsLoadingCategoryList',
        'showCertificationStatus',
        'activeCategories',
        'inactiveCategories'
    ],
    components: {
        CategoryCard,
    },
    template:
    `<div v-if="appIsLoadingCategoryList === false" id="formEditor_content">
        <!-- secure form section -->
        <div v-if="showCertificationStatus" id="secure_forms_info" style="padding: 8px; background-color: #cb0000; margin-bottom:1em;">
            <span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span>
            <a id="secureBtn" class="buttonNorm">View Details</a>
        </div>
        <!-- form broswer -->
        <div id="forms" style="display:flex; flex-wrap:wrap">
            <category-card v-for="c in activeCategories" :categories-record="c" :key="'card_' + c.categoryID"></category-card>
        </div>
        <hr style="margin-top: 32px; border-top:1px solid #556;" aria-label="Not associated with a workflow" />
        <p>Not associated with a workflow:</p>
        <div id="forms_inactive" style="display:flex; flex-wrap:wrap">
            <category-card v-for="c in inactiveCategories" :categories-record="c" :key="'card_' + c.categoryID"></category-card>
        </div>
    </div>`
}