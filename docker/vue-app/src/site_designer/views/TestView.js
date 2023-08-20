import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import ConfirmPublishDialog from "../components/dialog_content/ConfirmPublishDialog.js";
import NewDesignDialog from "../components/dialog_content/NewDesignDialog.js";

export default {
    name: 'testpage',
    inject: [
        'appIsGettingData',
        'showFormDialog',
        'dialogFormContent'
    ],
    created() {
        console.log('testpage view created');
    },
    components: {
        LeafFormDialog,
        ConfirmPublishDialog,
        NewDesignDialog
    },
    template: `<div v-if="appIsGettingData" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>
    <div v-else>
        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>
    </div>`
}