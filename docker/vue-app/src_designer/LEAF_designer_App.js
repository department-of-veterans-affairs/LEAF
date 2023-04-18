import { computed } from 'vue';

import LeafFormDialog from "../src_common/components/LeafFormDialog.js";
import './LEAF_designer.scss';

import ModHomeMenu from "./components/ModHomeMenu.js";
import DesignButtonDialog from "./components/dialog_content/DesignButtonDialog.js";


export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            APIroot: APIroot,
            sitemapOBJ: {},
            iconList: [],

            /* general modal data properties */
            formSaveFunction: ()=> {
                if(this.$refs[this.dialogFormContent]) {
                    this.$refs[this.dialogFormContent].onSave();
                } else { console.log('possible error setting modal save method')}
            },
            dialogTitle: "",
            dialogFormContent: "",
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            showFormDialog: false,
            /** modal values end */
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
            menuButtonList: computed(() => this.menuButtonList),
            showFormDialog: computed(() => this.showFormDialog),
            formSaveFunction: computed(() => this.formSaveFunction),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            //static
            closeFormDialog: this.closeFormDialog,
            APIroot: this.APIroot,
        }
    },
    components: {
        ModHomeMenu,
        LeafFormDialog,
        DesignButtonDialog,
    },
    mounted() {
        this.getSitemapOBJ();
        this.getIconList();
    },
    computed: {
        menuButtonList() {
            return this.sitemapOBJ?.buttons || [];
        }
    },
    methods: {
        getSitemapOBJ() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}system/settings`,
                    success: (res) => {
                        console.log('site btns', res)
                        this.sitemapOBJ = JSON.parse(res?.sitemap_json || '');
                        resolve();
                    },
                    error: (err) => reject(err)
                });
            });
        },
        getIconList() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}iconPicker/list`,
                    success: (res) => {
                        console.log('picker', res)
                        this.iconList = res || [];
                        resolve();
                    },
                    error: (err) => reject(err)
                });
            });
        },
        /** general modal methods */
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.setFormDialogComponent('');
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        /**
         * set the component for the dialog modal's main content. Components must be registered to this app
         * @param {string} component name as string, eg 'confirm-delete-dialog'
         */
        setFormDialogComponent(component = '') {
            this.dialogFormContent = component;
        },

        openDesignButtonDialog() {
            this.showFormDialog = true;
            this.dialogTitle = '<h3>Editor</h3>';
            this.dialogFormContent = 'design-button-dialog';
        }
    }
}