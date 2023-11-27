import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import NewFormDialog from "../components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "../components/dialog_content/ImportFormDialog.js";

import BrowserAndRestoreMenu from "../components/BrowserAndRestoreMenu.js";
import FormBrowser from '../components/FormBrowser.js';

export default {
    name: 'form-browser-view',
    components: {
        LeafFormDialog,
        NewFormDialog,
        ImportFormDialog,
        BrowserAndRestoreMenu,
        FormBrowser
    },
    inject: [
        'getSiteSettings',
        'setDefaultAjaxResponseMessage',
        'getEnabledCategories',
        'showFormDialog',
        'dialogFormContent',
        'appIsLoadingCategories'
    ],
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.setDefaultAjaxResponseMessage();
            vm.getSiteSettings();
            if(vm.appIsLoadingCategories === false) {
                vm.getEnabledCategories();
            }
        });
    },
    template: `<BrowserAndRestoreMenu />
    <section>
        <div v-if="appIsLoadingCategories" class="page_loading">
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
    </section>`
}