import { computed } from 'vue';

import LeafFormDialog from "../common/components/LeafFormDialog.js";
import './LEAF_Designer.scss';

import DesignButtonDialog from "./components/dialog_content/DesignButtonDialog.js";

export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            APIroot: APIroot,
            rootPath: '../',
            libsPath: libsPath,
            orgchartPath: orgchartPath,
            userID: userID,
            customizableTemplates: ['homepage', 'search'], //NOTE: only homepage is tech a view
            views: ['homepage'],
            custom_page_select: 'homepage',
            isPostingUpdate: false,
            isEditingMode: true,
            publishedStatus: {
                homepage: null,
                search: null
            },
            iconList: [],
            menuItemList: [],
            menuItem: null,
            tagsToRemove: ['script', 'img', 'a', 'link', 'br'],
            builtInIDs: ["btn_reports","btn_bookmarks","btn_inbox","btn_new_request"],
            builtInButtons: [
                {
                    id: "btn_reports",
                    order: -1,
                    title: "Report Builder",
                    titleColor: "#ffffff",
                    subtitle: "View saved links to requests",
                    subtitleColor: "#ffffff",
                    bgColor: "#000000",
                    icon: "x-office-spreadsheet.svg",
                    link: "?a=reports&v=3",
                    enabled: 1
                },
                {
                    id: "btn_bookmarks",
                    order: -2,
                    title: "Bookmarks",
                    titleColor: "#000000",
                    subtitle: "View saved links to requests",
                    subtitleColor: "#000000",
                    bgColor: "#7eb2b3",
                    icon: "bookmark.svg",
                    link: "?a=bookmarks",
                    enabled: 1
                },
                {
                    id: "btn_inbox",
                    order: -3,
                    title: "Inbox",
                    titleColor: "#000000",
                    subtitle: "Review and apply actions to active requests",
                    subtitleColor: "#000000",
                    bgColor: "#b6ef6d",
                    icon: "document-open.svg",
                    link: "?a=inbox",
                    enabled: 1
                },
                {
                    id: "btn_new_request",
                    order: -4,
                    title: "New Request",
                    titleColor: "#ffffff",
                    subtitle: "Start a new request",
                    subtitleColor: "#ffffff",
                    bgColor: "#2372b0",
                    icon: "document-new.svg",
                    link: "?a=newform",
                    enabled: 1
                },
            ],

            /* general modal properties */
            formSaveFunction: ()=> {
                if(this.$refs[this.dialogFormContent] &&
                    typeof this.$refs[this.dialogFormContent].onSave === 'function'
                ) {
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
            isPostingUpdate: computed(() => this.isPostingUpdate),
            isEditingMode: computed(() => this.isEditingMode),
            menuItemList: computed(() => this.menuItemList),
            allBuiltinsPresent: computed(() => this.allBuiltinsPresent),
            menuItem: computed(() => this.menuItem),
            formSaveFunction: computed(() => this.formSaveFunction),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            publishedStatus: computed(() => this.publishedStatus),

            //static
            closeFormDialog: this.closeFormDialog,
            setDialogButtonText: this.setDialogButtonText,
            APIroot: this.APIroot,
            libsPath: this.libsPath,
            rootPath: this.rootPath,
            orgchartPath: this.orgchartPath,
            userID: this.userID,
            builtInIDs: this.builtInIDs,
            addStarterButtons: this.addStarterButtons,
            setMenuItem: this.setMenuItem,
            editMenuItemList: this.editMenuItemList,
            postMenuItemList: this.postMenuItemList,
            postEnableTemplate: this.postEnableTemplate,
            tagsToRemove: this.tagsToRemove
        }
    },
    components: {
        LeafFormDialog,
        DesignButtonDialog,
    },
    mounted() {
        this.getIconList();
        this.getSettingsData();
    },
    computed: {
        allBuiltinsPresent() {
            let result = true;
            this.builtInIDs.forEach(id => {
                if (!this.menuItemList.some(item => item.id === id)) {
                    result = false;
                }
            });
            return result;
        }
    },
    methods: {
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
        },
        //TODO: further organization of enabled templates and design data
        postEnableTemplate(templateName = '') {
            if(this.customizableTemplates.includes(templateName)) {
                const flag = +(!this.publishedStatus[templateName]);
                this.isPostingUpdate = true;
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}site/settings/enable_${templateName}`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        enabled: flag,
                    },
                    success: (res) => {
                        if (+res === 1) {
                            this.publishedStatus[templateName] = !this.publishedStatus[templateName];
                            this.isPostingUpdate = false;
                        }
                    },
                    error: (err) => console.log(err)
                });
            }
        },
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
        /**
         * @param {object|null} menuItem set menuitem for editing
         */
        setMenuItem(menuItem = null) {
            this.menuItem = menuItem !== null ? menuItem :
                {
                    id: this.generateID(),
                    order: this.menuItemList.length,
                    enabled: 0
                }

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
                this.postMenuItemList();
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
                let elList = Array.from(document.querySelectorAll('ul#menu > li'));
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
        },
        postMenuItemList() {
            this.isPostingUpdate = true;
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}site/settings/home_menu_json`,
                data: {
                    CSRFToken: this.CSRFToken,
                    home_menu_list: this.menuItemList
                },
                success: (res) => {
                    if(+res !== 1) {
                        console.log('unexpected value returned', res);
                    }
                    this.isPostingUpdate = false;
                    this.getSettingsData();
                },
                error: (err) => console.log(err)
            });
        },
        getSettingsData() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}system/settings`,
                success: (res) => {
                    let menuItems = JSON.parse(res?.home_menu_json || "[]");
                    menuItems.map(item => {
                        item.link = XSSHelpers.decodeHTMLEntities(item.link);
                        item.title = XSSHelpers.decodeHTMLEntities(item.title);
                        item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
                    });
                    this.menuItemList = menuItems.sort((a,b) => a.order - b.order);
                    this.publishedStatus.homepage = +res?.home_enabled === 1;
                    this.publishedStatus.search = +res?.search_enabled === 1;
                },
                error: (err) => console.log(err)
            });
        },
        getIconList() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}iconPicker/list`,
                success: (res) => this.iconList = res || [],
                error: (err) => console.log(err)
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
        setDialogButtonText({ confirm = '', cancel = '' } = {}) {
            this.dialogButtonText = { confirm, cancel };
        },
        openDesignButtonDialog() {
            this.showFormDialog = true;
            this.dialogTitle = '<h2>Menu Editor</h2>';
            this.dialogFormContent = 'design-button-dialog';
        }
    },
    watch: {
        custom_page_select(newVal, oldVal) {
            if(newVal !== '') {
                this.$router.push({name: this.custom_page_select});
            }
        }
    }
}