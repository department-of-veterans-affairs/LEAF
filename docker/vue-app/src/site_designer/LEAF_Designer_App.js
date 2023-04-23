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
            libsPath: libsPath,
            iconList: [],
            menuItemList: [],
            menuItem: null,
            builtInLinks: {
                "Portal Inbox": "?a=inbox",
                "Bookmarks": "?a=bookmarks",
                "New Request": "?a=newform",
                "Report Builder": "?a=reports&v=3",
            },

            /* general modal properties */
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
            libsPath: this.libsPath,
            setMenuItem: this.setMenuItem,
            editMenuItemList: this.editMenuItemList
        }
    },
    components: {
        ModHomeMenu,
        LeafFormDialog,
        DesignButtonDialog,
    },
    mounted() {
        this.getIconList();
        this.getHomeMenuJSON();
    },
    computed: {
        menuItemListJSON() {
            return JSON.stringify(this.menuItemList);
        },
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
        buttonIDExists(ID = '') {
            return this.menuItemList.length > 0 ? this.menuItemList.some(button => button?.id === ID) : false;
        },
        setMenuItem(menuItem = null) {
            this.menuItem = menuItem === null ?
            {
                id: this.generateID(),
                order: this.menuItemList.length,
                icon: '',
            } : menuItem;
            this.openDesignButtonDialog();
        },
        /**
         * Updates order value on drop, or filters menu item list using ID of an existing or
         * new menu item. Adds the new or edited item and re-sorts the list if remove is not true
         * @param {Object|null} menuItem 
         * @param {boolean} remove
         */
        editMenuItemList(menuItem = null, remove = false) {
            if (menuItem === null) { //drag drop 
                let itemIDs = []
                let elList = Array.from(document.querySelectorAll('#menu_designer li')) || [];
                
                elList.forEach(li => itemIDs.push(li.id));

                this.menuItemList.forEach(item => {
                    const index = itemIDs.indexOf(item.id);
                    if(index > -1) {
                        item.order = index;
                    }
                });

            } else { //editing modal - either updating or deleting an item
                let items = this.menuItemList.filter(item => item.id !== menuItem.id);
                if (remove !== true) {
                    items.push(menuItem);
                    this.menuItemList = items.sort((a,b) => a.order - b.order);
                }
            }
            this.postMenuItemListJSON().then((res) => {
                if(+res !== 1) {
                    console.log('unexpected value returned', res)
                }
            }).catch(err => console.log(err));
        },
        postMenuItemListJSON() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}site/settings/home_menu_json`,
                    data: {
                        home_menu_json: this.menuItemListJSON,
                        CSRFToken: this.CSRFToken
                    },
                    success: (res) => resolve(res),
                    error: (err) => reject(err)
                });
            });
        },
        getHomeMenuJSON() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}system/settings`,
                success: (res) => {
                    let menuItems = JSON.parse(res?.home_menu_json || "[]");
                    this.menuItemList = menuItems.sort((a,b) => a.order - b.order);
                },
                error: (err) => console.log(err)
            });
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

        /** general and app specific modal methods.  Use a component name to set 
        /** the dialog's main content. Components must be registered to this app */
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.dialogFormContent = '';
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        openDesignButtonDialog() {
            this.showFormDialog = true;
            this.dialogTitle = '<h2>Menu Editor</h2>';
            this.dialogFormContent = 'design-button-dialog';
        }
    }
}