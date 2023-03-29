import CategoryItem from "@/components/form_editor_view/CategoryItem";

export default {
    data() {
        return {
            test: 'test'
        }
    },
    inject: [
        'appIsLoadingCategoryList',
        'showCertificationStatus',
        'activeForms',
        'inactiveForms',
        'supplementalForms'
    ],
    components: {
        CategoryItem,
    },
    template:
    `<template v-if="appIsLoadingCategoryList === false">
        <!-- secure form section -->
        <div v-if="showCertificationStatus" id="secure_forms_info" style="padding: 8px; background-color: #a00; margin-bottom:1em;">
            <span id="secureStatus" style="font-size: 120%; padding: 4px; color: white; font-weight: bold;">LEAF-Secure Certified</span>
            <a id="secureBtn" class="buttonNorm">View Details</a>
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