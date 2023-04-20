import { computed } from 'vue';

import LeafFormDialog from "../common/components/LeafFormDialog.js";
import './LEAF_Designer.scss';

import ModHomeMenu from "./components/ModHomeMenu.js";
import DesignButtonDialog from "./components/dialog_content/DesignButtonDialog.js";


export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            APIroot: APIroot,
            iconList: [],
            menuItemList: [],
            menuItem: {},

            /* sitemap json pattern for initial comparison
            {
                "buttons":[
                    {
                        "id":"rbm9i",
                        "title":"LEAF Request Portal",
                        "description":"The original and best portal",
                        "target":"https://localhost/LEAF_Request_Portal/",
                        "color":"#a694ff","order":0,
                        "fontColor":"#000000",
                        "icon":"https://localhost/libs/dynicons/svg/applications-other.svg"
                    },
                ]
            } */

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
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
            iconList: computed(() => this.iconList),
            menuItemList: computed(() => this.menuItemList),
            menuItem: computed(() => this.menuItem),
            formSaveFunction: computed(() => this.formSaveFunction),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),

            //static
            closeFormDialog: this.closeFormDialog,
            APIroot: this.APIroot,
            setMenuItem: this.setMenuItem,
            saveMenuItem: this.saveMenuItem
        }
    },
    components: {
        ModHomeMenu,
        LeafFormDialog,
        DesignButtonDialog,
    },
    mounted() {
        this.getIconList();
        //MOCK:
        this.menuItemList = [
            {
                id: "FUeoZ",
                title: "<b>Report Builder</b>",
                titleColor: "#2090a0",
                subtitle: "Item subtitle",
                subtitleColor: "#006080",
                bgColor: "#f0f0ff",
                icon: "",
                link: "https://localhost/LEAF_Request_Portal/?a=reports&v=3"
            },
        ]
    },
    methods: {
        generateID() {
            let result = '';
            do {
                const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                for (let i = 0; i < 5; i++ ) {
                   result += characters.charAt(Math.floor(Math.random() * characters.length));
                }
            } while (this.buttonIDExists(result));
            return result;
        },
        buttonIDExists(ID) {
            return this.menuItemList.length > 0 ? this.menuItemList.some(button => button?.id === ID) : false;
        },
        setMenuItem(ID = '') {
            this.menuItem = this.menuItemList.find(item => item.id === ID) || {id: this.generateID()};
            this.openDesignButtonDialog();
        },
        getIconList() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}iconPicker/list`,
                    success: (res) => {
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
            this.dialogTitle = '<h2>Menu Editor</h2>';
            this.setFormDialogComponent('design-button-dialog');
        }
    }
}