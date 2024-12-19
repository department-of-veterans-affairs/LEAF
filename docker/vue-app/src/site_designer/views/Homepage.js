import { computed } from 'vue';
import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import DesignCardDialog from "../components/dialog_content/DesignCardDialog.js";
import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    data() {
        return {
            menuIsUpdating: false,
            builtInIDs: ["btn_reports","btn_bookmarks","btn_inbox","btn_new_request"],
            menuItem: {},
        }
    },
    created() {
        console.log('homepage view created, getting design data')
        this.getDesignData();
    },
    mounted() {
        console.log('homepage mounted')
    },
    inject: [
        'CSRFToken',
        'APIroot',
        'appIsGettingData',
        'appIsPublishing',
        'toggleEnableTemplate',
        'updateLocalDesignData',
        'getDesignData',
        'designData',
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
            menuIsUpdating: computed(() => this.menuIsUpdating),

            builtInIDs: this.builtInIDs,
            setMenuItem: this.setMenuItem,
            updateMenuItemList: this.updateMenuItemList,
            postHomeMenuSettings: this.postHomeMenuSettings,
            postSearchSettings: this.postSearchSettings
        }
    },
    components: {
        LeafFormDialog,
        DesignCardDialog,
        CustomHomeMenu,
        CustomSearch
    },
    computed: {
        enabled() {
            return parseInt(this.designData?.homepage_enabled) === 1;
        },
        menuItemList() {
            let returnVal;
            if (this.appIsGettingData) {
                returnVal = null;
            } else {
                const homeData = JSON.parse(this.designData?.homepage_design_json || "{}");
                let menuItems = homeData?.menuCards || [];
                menuItems.map(item => {
                    item.link = XSSHelpers.decodeHTMLEntities(item.link);
                    item.title = XSSHelpers.decodeHTMLEntities(item.title);
                    item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
                });
                returnVal = menuItems.sort((a,b) => a.order - b.order);
            }
            return returnVal;
        },
        menuDirection() {
            let returnVal;
            if (this.appIsGettingData) {
                returnVal = null;
            } else {
                const homeData = JSON.parse(this.designData?.homepage_design_json || "{}");
                returnVal = homeData?.direction || 'v';
            }
            return returnVal;
        },
        chosenHeaders() {
            let returnVal;
            if (this.appIsGettingData) {
                returnVal = null;
            } else {
                const searchTemplateJSON = this.designData?.search_design_json || "{}";
                const obj = JSON.parse(searchTemplateJSON);
                returnVal = obj?.chosenHeaders || [];
            }
            return returnVal
        },
    },
    methods: {
        openDesignButtonDialog() {
            this.setDialogTitleHTML('<h2>Menu Editor</h2>');
            this.setDialogContent('design-card-dialog');
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
            let newItems = this.menuItemList.map(item => ({...item}));

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
                newItems = newItems.filter(item => item.id !== menuItem.id);
                if (markedForDeletion !== true) {
                    newItems.push(menuItem);
                }
            }
            this.postHomeMenuSettings(newItems, this.menuDirection);
        },
        postHomeMenuSettings(menuCards = this.menuItemList, direction = this.menuDirection) {
            this.menuIsUpdating = true;
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}site/settings/homepage_design_json`,
                data: {
                    CSRFToken: this.CSRFToken,
                    home_menu_list: menuCards,
                    menu_direction: direction
                },
                success: (res) => {
                    if(+res?.code !== 1) {
                        console.log('unexpected response returned:', res);
                    } else {
                        const newJSON = JSON.stringify({menuCards, direction})
                        this.updateLocalDesignData('homepage', newJSON);
                    }
                    this.menuIsUpdating = false;
                },
                error: (err) => console.log(err)
            });
        },
    },
    template: `<div v-if="appIsGettingData" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="" />
    </div>
    <div v-else id="site_designer_hompage">
        <h3 id="designer_page_header" :class="{editMode: isEditingMode}" style="margin: 1rem 0;">
            {{ isEditingMode ? 'Editing the Homepage' : 'Homepage Preview'}}
        </h3>
        <h4 style="margin: 0.5rem 0;">This page is {{ enabled ? '' : 'not'}} enabled</h4>
        <button type="button" @click="toggleEnableTemplate('homepage')"
            class="btn-confirm" :class="{enabled: enabled}" 
            style="width: 100px; margin-bottom: 1rem;" :disabled="appIsPublishing">
            {{ enabled ? 'Disable' : 'Publish'}}
        </button>
        <div style="color:#b00000; border:1px solid #b00000; width:100%;">TODO banner section</div>
        <div style="display: flex; flex-wrap: wrap;">
            <custom-home-menu v-if="menuItemList!==null"></custom-home-menu>
            <custom-search v-if="chosenHeaders!==null"></custom-search>
        </div>
        <!-- HOMEPAGE DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>
    </div>`
}