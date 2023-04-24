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

            builtInButtons: [
                {
                    id: "btn_reports",
                    order: -1,
                    title: "<h3>Report Builder</h3>",
                    titleColor: "#ffffff",
                    subtitle: "View saved links to requests",
                    subtitleColor: "#ffffff",
                    bgColor: "#000000",
                    icon: "dynicons/svg/x-office-spreadsheet.svg",
                    link: "?a=reports&v=3",
                    enabled: 1
                },
                {
                    id: "btn_bookmarks",
                    order: -2,
                    title: "<h3>Bookmarks</h3>",
                    titleColor: "#000000",
                    subtitle: "View saved links to requests",
                    subtitleColor: "#000000",
                    bgColor: "#7eb2b3",
                    icon: "dynicons/svg/bookmark.svg",
                    link: "?a=bookmarks",
                    enabled: 1
                },
                {
                    id: "btn_inbox",
                    order: -3,
                    title: "<h3>Inbox</h3>",
                    titleColor: "#000000",
                    subtitle: "Review and apply actions to active requests",
                    subtitleColor: "#000000",
                    bgColor: "#b6ef6d",
                    icon: "dynicons/svg/document-open.svg",
                    link: "?a=inbox",
                    enabled: 1
                },
                {
                    id: "btn_new_request",
                    order: -4,
                    title: "<h3>New Request</h3>",
                    titleColor: "#ffffff",
                    subtitle: "Start a new request",
                    subtitleColor: "#ffffff",
                    bgColor: "#2372b0",
                    icon: "dynicons/svg/document-new.svg",
                    link: "?a=newform",
                    enabled: 1
                },
            ],

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
            setDialogButtonText: this.setDialogButtonText,
            APIroot: this.APIroot,
            libsPath: this.libsPath,
            addStarterButtons: this.addStarterButtons,
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
    computed: {},
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
                    enabled: 0
                }
                : menuItem;

            this.openDesignButtonDialog();
        },
        addStarterButtons() {
            let buttonsAdded = 0;
            this.builtInButtons.forEach(b => {
                const doNotHaveID = !this.menuItemList.some(item => item.id === b.id);
                if (doNotHaveID) {
                    this.menuItemList.unshift({...b});
                    buttonsAdded += 1;
                }
            });
            if(buttonsAdded > 0) {
                this.editMenuItemList();
            }
        },
        /**
         * Updates order value on drop, or filters menu item list using ID of an existing or
         * new menu item. Adds the new or edited item and re-sorts the list if remove is not true
         * @param {Object|null} menuItem 
         * @param {boolean} markedForDeletion
         */
        editMenuItemList(menuItem = null, markedForDeletion = false) {
            if (menuItem === null) { //called for drag drop event or when adding starter buttons
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
                if (markedForDeletion !== true) {
                    items.push(menuItem);
                    items = items.sort((a,b) => a.order - b.order);
                }
                this.menuItemList = items;
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
                        home_menu_list: this.menuItemList,
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
        setDialogButtonText(textObj = {}) {
            const { confirm, cancel } = textObj;
            this.dialogButtonText = { confirm, cancel };
        },
        openDesignButtonDialog() {
            this.showFormDialog = true;
            this.dialogTitle = '<h2>Menu Editor</h2>';
            this.dialogFormContent = 'design-button-dialog';
        }
    }
}