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

            menuItem: {},
        }
    },
    mounted() {
        this.getSettingsData();
    },
    inject: [
        'CSRFToken',
        'APIroot',
        'setUpdating',
        'getSettingsData',
        'settingsData',
        'isEditingMode',

        'showFormDialog',
        'dialogFormContent',
        'setDialogTitleHTML',
        'setDialogContent',
        'openDialog'
    ],
    provide() {
        return {
            menuItem: computed(() => this.menuItem),
            menuDirection: computed(() => this.menuDirection),
            menuItemList: computed(() => this.menuItemList),
            chosenHeaders: computed(() => this.chosenHeaders),

            builtInIDs: this.builtInIDs,
            addStarterButtons: this.addStarterButtons,
            setMenuItem: this.setMenuItem,
            updateMenuItemList: this.updateMenuItemList,
            postHomepageSettings: this.postHomepageSettings,
            postSearchSettings: this.postSearchSettings
        }
    },
    components: {
        LeafFormDialog,
        DesignButtonDialog,
        CustomHomeMenu,
        CustomSearch
    },
    computed: {
        menuItemList() {
            const homeData = JSON.parse(this.settingsData?.home_design_json || "{}");

            let menuItems = homeData?.menuButtons || [];
            menuItems.map(item => {
                item.link = XSSHelpers.decodeHTMLEntities(item.link);
                item.title = XSSHelpers.decodeHTMLEntities(item.title);
                item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
            });
            return menuItems.sort((a,b) => a.order - b.order);
        },
        menuDirection() {
            const homeData = JSON.parse(this.settingsData?.home_design_json || "{}");
            return homeData?.direction || 'v';
        },
        chosenHeaders() {
            const searchTemplateJSON = this.settingsData?.search_design_json || "{}";
            const obj = JSON.parse(searchTemplateJSON);
            return obj?.chosenHeaders || [];
        },
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
            return this.menuItemList.some(button => button?.id === ID);
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
            }
        },
        /**
         * Updates order on drop and click to move, or adds new/edited item.  Posts the updated list
         * @param {Object|null} menuItem
         * @param {boolean} markedForDeletion
         */
        updateMenuItemList(menuItem = null, markedForDeletion = false) {
            //get a copy of computed menuitems
            let newItems = [];
            this.menuItemList.forEach(item => newItems.push({...item}));

            //drag drop, clickToMove or adding starter buttons
            if (menuItem === null) {
                //make an array of ids from the menu list elements. the index will be the order
                let itemIDs = []
                let elList = Array.from(document.querySelectorAll('ul#menu > li'));
                elList.forEach(li => itemIDs.push(li.id));

                newItems.forEach(item => {
                    const index = itemIDs.indexOf(item.id);
                    if(index > -1) {
                        item.order = index;
                    }
                });

            } else { //editing modal - either updating or deleting an item
                newItems = this.menuItemList.filter(item => item.id !== menuItem.id);
                if (markedForDeletion !== true) {
                    newItems.push(menuItem);
                }
            }
            this.postHomepageSettings(newItems, this.menuDirection);
        },
        postSearchSettings(searchHeaders = []) {
            console.log('post called with', searchHeaders)
            this.setUpdating(true);
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}site/settings/search_design_json`,
                data: {
                    CSRFToken: this.CSRFToken,
                    chosen_headers: searchHeaders,
                },
                success: (res) => {
                    if(+res !== 1) {
                        console.log('unexpected value returned:', res);
                    }
                    this.getSettingsData();
                },
                error: (err) => console.log(err)
            });
        },
        postHomepageSettings(menuItems = this.menuItemList, direction = this.menuDirection) {
            this.setUpdating(true);
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}site/settings/home_design_json`,
                data: {
                    CSRFToken: this.CSRFToken,
                    home_menu_list: menuItems,
                    menu_direction: direction
                },
                success: (res) => {
                    if(+res !== 1) {
                        console.log('unexpected value returned:', res);
                    }
                    this.getSettingsData();
                },
                error: (err) => console.log(err)
            });
        },
    },
    template: `<div id="site_designer_hompage">
        <h3 id="designer_page_header" :class="{editMode: isEditingMode}" style="margin: 1rem 0;">
            {{ isEditingMode ? 'Editing the Homepage' : 'Homepage Preview'}}
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