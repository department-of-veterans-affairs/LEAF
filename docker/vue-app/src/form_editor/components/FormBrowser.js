import CategoryItem from "./CategoryItem";

export default {
    name: 'form-browser',
    inject: [
        'appIsLoadingCategories',
        'showCertificationStatus',
        'secureStatusText',
        'secureBtnText',
        'secureBtnLink',
        'categories'
    ],
    components: {
        CategoryItem,
    },
    computed: {
        /**
         * @returns {array} of non-internal forms that have workflows and are available
         */
        activeForms() {
            let active = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID === '' &&
                    parseInt(this.categories[c].workflowID) !== 0 &&
                    parseInt(this.categories[c].visible) === 1) {
                        active.push({...this.categories[c]});
                }
            }
            active = active.sort((eleA, eleB) => eleA.sort - eleB.sort);
            return active;
        },
        /**
         * @returns {array} of non-internal forms that have workflows and are hidden
         */
        inactiveForms() {
            let inactive = [];
            for (let c in this.categories) {
                if (this.categories[c].parentID === '' &&
                    parseInt(this.categories[c].workflowID) !== 0 &&
                    parseInt(this.categories[c].visible) === 0) {
                    inactive.push({...this.categories[c]});
                }
            }
            inactive = inactive.sort((eleA, eleB) => eleA.sort - eleB.sort);
            return inactive;
        },
        /**
         * @returns {array} of non-internal forms that have no workflows
         */
        supplementalForms() {
            let supplementalForms = [];
            for(let c in this.categories) {
                if (this.categories[c].parentID === '' && parseInt(this.categories[c].workflowID) === 0 ) {
                    supplementalForms.push({...this.categories[c]});
                }
            }
            supplementalForms = supplementalForms.sort((eleA, eleB) => eleA.sort - eleB.sort);
            return supplementalForms;
        },
    },
    template:
    `<template v-if="appIsLoadingCategories === false">
        <!-- secure form section -->
        <div v-if="showCertificationStatus" id="secure_forms_info" style="padding: 8px; background-color: #a00; margin-bottom:1em;">
            <span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">{{secureStatusText}}</span>
            <a id="secureBtn" :href="secureBtnLink" target="_blank" class="buttonNorm">{{secureBtnText}}</a>
        </div>

        <!-- form browser tables -->
        <div id="form_browser_tables">
            <h3>Active Forms:</h3>
            <table v-if="activeForms.length > 0" id="active_forms">
                <tr class="header-row">
                    <th id="active_name" style="width:250px">Form Name</th>
                    <th style="width:400px">Description</th>
                    <th style="width:250px">Workflow</th>
                    <th style="width:125px">Need to Know</th>
                    <th id="active_sort" style="width:80px">Priority</th>
                </tr>
                <category-item v-for="c in activeForms" 
                    :categories-record="c" 
                    availability="active" 
                    :key="'active_' + c.categoryID">
                </category-item>
            </table>
            <p v-else style="margin-bottom: 2rem;">No Active Forms</p>

            <h3>Inactive Forms:</h3>
            <table v-if="inactiveForms.length > 0" id="inactive_forms">
                <tr class="header-row">
                    <th id="inactive_name" style="width:250px">Form Name</th>
                    <th style="width:400px">Description</th>
                    <th style="width:250px">Workflow</th>
                    <th style="width:125px">Need to Know</th>
                    <th id="inactive_sort" style="width:80px">Priority</th>
                </tr>
                <category-item v-for="c in inactiveForms" 
                    :categories-record="c" 
                    availability="inactive" 
                    :key="'inactive_' + c.categoryID">
                </category-item>
            </table>
            <p v-else style="margin-bottom: 2rem;">No Inctive Forms</p>

            <h3>Supplemental Forms:</h3>
            <table v-if="supplementalForms.length > 0" id="supplemental_forms">
                <tr class="header-row">
                    <th id="supplemental_name" style="width:250px">Form Name</th>
                    <th style="width:400px">Description</th>
                    <th style="width:250px">Staple Status</th>
                    <th style="width:125px">Need to Know</th>
                    <th id="supplemental_sort" style="width:80px">Priority</th>
                </tr>
                <category-item v-for="c in supplementalForms" 
                    :categories-record="c" 
                    availability="supplemental" 
                    :key="'supplement_' + c.categoryID">
                </category-item>
            </table>
            <p v-else style="margin-bottom: 2rem;">No Supplemental Forms</p>
        </div>
    </template>`
}