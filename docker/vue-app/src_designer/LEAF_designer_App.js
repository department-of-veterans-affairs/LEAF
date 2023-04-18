import { computed } from 'vue';

import LeafFormDialog from "../src_common/components/LeafFormDialog.js";
import './LEAF_designer.scss';

import ModHomeMenu from "./components/ModHomeMenu.js";
import DesignButtonDialog from "./components/dialog_content/DesignButtonDialog.js";


export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            test: 'some test data',

            showFormDialog: false,
            formSaveFunction: ()=> {
                if(this.$refs[this.dialogFormContent]) {
                    this.$refs[this.dialogFormContent].onSave();
                } else { console.log('possible error setting modal save method')}
            },
            dialogTitle: "Test Title",
            dialogFormContent: "",
            dialogButtonText: computed(() => this.dialogButtonText),
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
            /** dialog related */
            showFormDialog: computed(() => this.showFormDialog),
            formSaveFunction: computed(() => this.formSaveFunction),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            closeFormDialog: this.closeFormDialog,
        }
    },
    components: {
        ModHomeMenu,
        LeafFormDialog,
        DesignButtonDialog,
    },
    methods: {
        testShowDialog() {
            this.showFormDialog = true;
            this.dialogFormContent = 'design-button-dialog';
        },
        closeFormDialog() {
            this.showFormDialog = false;
            this.setCustomDialogTitle('');
            this.setFormDialogComponent('');
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        setCustomDialogTitle(htmlContent = '') {
            this.dialogTitle = htmlContent;
        },
        /**
         * set the component for the dialog modal's main content. Components must be registered to this app
         * @param {string} component name as string, eg 'confirm-delete-dialog'
         */
        setFormDialogComponent(component = '') {
            this.dialogFormContent = component;
        },
    }
}