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

            menuItem: {},
            testMenuIsUpdating: this.appIsUpdating,
            testSearchIsUpdating: this.appIsUpdating,
        }
    },
    mounted() {
        this.getSettingsData();
    },
    inject: [
        'CSRFToken',
        'APIroot',
        'appIsUpdating',
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
        /**
         * Updates order on drop and click to move, or adds new/edited item.  Posts the updated list
         * @param {Object|null} menuItem
         * @param {boolean} markedForDeletion
         */
        updateMenuItemList(menuItem = null, markedForDeletion = false) {
            let newItems = [];
            this.menuItemList.forEach(item => newItems.push({...item}));

            if (menuItem === null) { //update the order after drag drop or clickToMove
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
        postHomepageSettings(menuItems = this.menuItemList, direction = this.menuDirection) {
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