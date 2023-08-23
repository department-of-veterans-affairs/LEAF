import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import ConfirmPublishDialog from "../components/dialog_content/ConfirmPublishDialog.js";
import ConfirmDeleteDialog from "../components/dialog_content/ConfirmDeleteDialog.js";
import NewDesignDialog from "../components/dialog_content/NewDesignDialog.js";
import HistoryDialog from "../components/dialog_content/HistoryDialog.js";

export default {
    name: 'testpage',
    inject: [
        'appIsGettingData',
        'showFormDialog',
        'currentDesignID',
        'currentView',
        'dialogFormContent'
    ],
    created() {
        console.log('testpage view created');
    },
    components: {
        LeafFormDialog,
        ConfirmPublishDialog,
        ConfirmDeleteDialog,
        NewDesignDialog,
        HistoryDialog
    },
    watch: {
        selectedDesign(newVal, oldVal) {
            if(newVal !== null) {
                console.log('not null')
            } else {
                console.log('null')
            }
        }
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
                <component :is="dialogFormContent" historyType="design" :historyID="currentView"></component>
            </template>
        </leaf-form-dialog>
    </div>`
}