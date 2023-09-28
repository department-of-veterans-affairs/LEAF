import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import NewFormDialog from "../components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "../components/dialog_content/ImportFormDialog.js";

import FormBrowser from '../components/FormBrowser.js';

export default {
    name: 'form-browser-view',
    data() {
        return {
            test: null
        }
    },
    components: {
        LeafFormDialog,
        NewFormDialog,
        ImportFormDialog,
        FormBrowser
    },
    inject: [
        'setDefaultAjaxResponseMessage',

        'showFormDialog',
        'dialogFormContent',

        'appIsLoadingForm',
        'appIsLoadingCategoryList'
    ],
    created() {
        console.log('browser view created');
    },
    beforeRouteEnter(to, from, next) {
        console.log('entering browser route')
        next(vm => {
            vm.setDefaultAjaxResponseMessage();
        });
    },
    methods: {

    },
    template: `<div>
        <div v-if="appIsLoadingForm || appIsLoadingCategoryList" class="page_loading">
            Loading... 
            <img src="../images/largespinner.gif" alt="loading..." />
        </div>
        <FormBrowser v-else></FormBrowser>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>
    </div>`
}