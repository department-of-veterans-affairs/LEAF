export default {
    name: 'restore-fields-view',
    data() {
        return {
            disabledFields: null
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'selectNewCategory',
        'setDefaultAjaxResponseMessage'
    ],
    /**
     * get all disabled or archived indicators for indID > 0 and update app disabledFields (array)
     */
    beforeMount() { 
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
            vm.selectNewCategory(); //update during more signif refactor of restorefields view - for now this prevents menu issues
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
    template: `<div>
            <h3 style="margin: 0;">List of disabled fields available for recovery</h3>
            <div>Deleted fields and associated data will be not display in the Report Builder</div>
            <div>
                <table v-if="disabledFields !== null" class="usa-table leaf-whitespace-normal">
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
                <p v-else>Loading ...</p>
            </div>
        </div>`
}