import { computed } from 'vue';
import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import DesignButtonDialog from "../components/dialog_content/DesignButtonDialog.js";
import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    data() {
        return {
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
            menuDirection: 'v',
            menuItemList: [],
            menuItem: {},
        }
    },
    mounted() {
        this.getSettingsData().then(res => {
            this.getHomeDesignSettings(res?.home_menu_json || "{}");
        });
    },
    inject: [
        'CSRFToken',
        'APIroot',
        'setUpdating',
        'getSettingsData',
        'isEditingMode',

        'showFormDialog',
        'dialogFormContent',
        'setDialogTitleHTML',
        'setDialogContent',
        'openDialog'
    ],
    provide() {
        return {
            menuDirection: computed(() => this.menuDirection),
            menuItemList: computed(() => this.menuItemList),
            menuItem: computed(() => this.menuItem),
            builtInIDs: this.builtInIDs,
            addStarterButtons: this.addStarterButtons,
            setMenuItem: this.setMenuItem,
            updateMenuItemList: this.updateMenuItemList,
            updateMenuDirection: this.updateMenuDirection,
            postMenuSettings: this.postMenuSettings,
        }
    },
    components: {
        LeafFormDialog,
        DesignButtonDialog,
        CustomHomeMenu,
        CustomSearch
    },
    methods: {
        openDesignButtonDialog() {
            this.setDialogTitleHTML('<h2>Menu Editor</h2>');
            this.setDialogContent('design-button-dialog');
            this.openDialog();
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
        getHomeDesignSettings(homeJSON = "{}") {
            const data = JSON.parse(homeJSON);
            this.menuDirection = data?.direction || 'v';

            let menuItems = data?.menuButtons || [];
            menuItems.map(item => {
                item.link = XSSHelpers.decodeHTMLEntities(item.link);
                item.title = XSSHelpers.decodeHTMLEntities(item.title);
                item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
            });
            this.menuItemList = menuItems.sort((a,b) => a.order - b.order);
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
                this.updateMenuItemList();
                this.postMenuSettings();
            }
        },
        /**
         * Updates order value on drop, or filters menu item list using ID of an existing or
         * new menu item. Adds the new or edited item and re-sorts the list if remove is not true
         * @param {Object|null} menuItem
         * @param {boolean} markedForDeletion
         */
        updateMenuItemList(menuItem = null, markedForDeletion = false) {
            if (menuItem === null) { //drag drop, clickToMove or when adding starter buttons
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
                }
                items = items.sort((a,b) => a.order - b.order);
                this.menuItemList = items;
            }
            this.postMenuSettings();
        },
        updateMenuDirection(event = {}) {
            this.menuDirection = event.target.value;
            this.postMenuSettings();
        },
        postMenuSettings() {
            this.setUpdating(true);
            $.ajax({
                type: 'POST', //homepage_design_json
                url: `${this.APIroot}site/settings/home_menu_json`,
                data: {
                    CSRFToken: this.CSRFToken,
                    home_menu_list: this.menuItemList,
                    menu_direction: this.menuDirection
                },
                success: (res) => {
                    if(+res !== 1) {
                        console.log('unexpected value returned:', res);
                    }
                    this.getSettingsData().then(res => {
                        this.getHomeDesignSettings(res?.home_menu_json || "{}");
                    }).catch(err => console.log(err));
                },
                error: (err) => console.log(err)
            });
        },
    },
    template: `<div id="site_designer_hompage">
        <h3 id="designer_page_header" style="margin: 1rem 0;">
            {{ isEditingMode ? 'Editing ' : 'Previewing '}} the Homepage
        </h3>
        <div style="color:#b00000; border:1px solid #b00000; width:100%;">TODO banner section</div>
        <div style="display: flex; flex-wrap: wrap;">
            <custom-home-menu></custom-home-menu>
            <custom-search></custom-search>
        </div>
        <!-- HOMEPAGE DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>
    </div>`
}