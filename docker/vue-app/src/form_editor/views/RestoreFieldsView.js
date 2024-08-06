import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import NewFormDialog from "../components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "../components/dialog_content/ImportFormDialog.js";

export default {
    name: 'restore-fields-view',
    data() {
        return {
            disabledFields: null
        }
    },
    components: {
        LeafFormDialog,
        NewFormDialog,
        ImportFormDialog,
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDefaultAjaxResponseMessage',

        'showFormDialog',
        'dialogFormContent'
    ],
    /**
     * get all disabled or archived indicators for indID > 0 and update app disabledFields (array)
     */
    created() {
        $.ajax({
            type: 'GET',
            url: `${this.APIroot}form/indicator/list/disabled`,
            success: (res) => {
                this.disabledFields = res.filter(obj => parseInt(obj.indicatorID) > 0);
            },
            error: (err) => console.log(err),
            cache: false
        });
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.setDefaultAjaxResponseMessage();
        });
    },
    methods: {
        /**
         * 
         * @param {number} indicatorID 
         */
        restoreField(indicatorID) {
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${indicatorID}/disabled`,
                data: {
                    CSRFToken: CSRFToken,
                    disabled: 0
                },
                success: () => {
                    this.disabledFields = this.disabledFields.filter(f => parseInt(f.indicatorID) !== indicatorID);
                    alert('The field has been restored.');
                },
                error: (err) => console.log(err)
            });
        },
    },
    template: `<section>
            <h2 id="page_breadcrumbs">
                <a href="../admin" class="leaf-crumb-link" title="to Admin Home">Admin</a>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>
                <router-link :to="{ name: 'browser' }" class="leaf-crumb-link" title="to Form Browser">Form Browser</router-link>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>Restore Fields
            </h2>
            <h3>List of disabled fields available for recovery</h3>
            <div>Deleted fields and associated data will be not display in the Report Builder</div>

            <div v-if="disabledFields === null" class="page_loading">
                Loading...
                <img src="../images/largespinner.gif" alt="loading..." />
            </div>
            <table v-else class="usa-table leaf-whitespace-normal">
                <thead>
                    <tr>
                        <th>indicatorID</th>
                        <th>Form</th>
                        <th>Field Name</th>
                        <th>Input Format</th>
                        <th>Status</th>
                        <th>Restore</th>
                    </tr>
                </thead>
                <tbody id="fields">
                    <tr v-for="f in disabledFields" key="f.indicatorID">
                        <td>{{ f.indicatorID }}</td>
                        <td>{{ f.categoryName }}</td>
                        <td>{{ f.name }}</td>
                        <td>{{ f.format }}</td>
                        <td>{{ f.disabled }}</td>
                        <td><button class="btn-general"
                            @click="restoreField(parseInt(f.indicatorID))">
                            Restore this field</button>
                        </td>
                    </tr>
                </tbody>
            </table>

            <!-- DIALOGS -->
            <leaf-form-dialog v-if="showFormDialog">
                <template #dialog-content-slot>
                    <component :is="dialogFormContent"></component>
                </template>
            </leaf-form-dialog>
        </section>`
}