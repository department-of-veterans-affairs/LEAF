import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import NewFormDialog from "../components/dialog_content/NewFormDialog.js";
import ImportFormDialog from "../components/dialog_content/ImportFormDialog.js";

import BrowserMenu from "../components/BrowserMenu.js";
import FormBrowser from '../components/FormBrowser.js';

export default {
    name: 'form-browser-view',
    components: {
        LeafFormDialog,
        NewFormDialog,
        ImportFormDialog,
        BrowserMenu,
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
    template: `<section>
        <div v-if="appIsLoadingCategories" class="page_loading">
            Loading... 
            <img src="../images/largespinner.gif" alt="" />
        </div>
        <template v-else>
            <h2 id="page_breadcrumbs">
                <a href="../admin" class="leaf-crumb-link" title="to Admin Home">Admin</a>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>Form Browser
            </h2>
            <BrowserMenu />
            <FormBrowser />
        </template>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent" @import-form="getEnabledCategories"></component>
            </template>
        </leaf-form-dialog>
    </section>`
}