import { computed } from 'vue';
import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import DesignCardDialog from "../components/dialog_content/DesignCardDialog.js";
import ConfirmPublishDialog from "../components/dialog_content/ConfirmPublishDialog.js";
import CustomHeader from "../components/CustomHeader.js";
import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    data() {
        return {
            builtInIDs: ["btn_reports","btn_bookmarks","btn_inbox","btn_new_request"],
            pageSections: ['header', 'menuItemList', 'menuDirection', 'searchHeaders'],
            menuItem: {},

            header: this.selectedDesign?.header || null,
            menuDirection: this.selectedDesign?.menu?.menuDirection || null,
            menuItemList: this.selectedDesign?.menu?.menuCards || null,
            searchHeaders: this.selectedDesign?.searchHeaders || null
        }
    },
    created() {
        if(this.selectedDesign !== null) {
            this.setSectionData()
        }
    },
    inject: [
        'CSRFToken',
        'APIroot',
        'appIsGettingData',
        'appIsUpdating',
        'postDesignContent',
        'selectedDesign',
        'currentDesignID',
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
            searchHeaders: computed(() => this.searchHeaders),
            header: computed(() => this.header),

            builtInIDs: this.builtInIDs,
            setMenuItem: this.setMenuItem,
            updateHomeDesign: this.updateHomeDesign,
            updateMenuItemList: this.updateMenuItemList,
        }
    },
    components: {
        LeafFormDialog,
        DesignCardDialog,
        ConfirmPublishDialog,
        CustomHeader,
        CustomHomeMenu,
        CustomSearch
    },
    methods: {
        setSectionData(content) {
            this.header = content?.header || {};
            this.menuDirection = content?.menu?.direction || 'v';

            let menuItems = content?.menu?.menuCards || [];
            menuItems.map(item => {
                item.link = XSSHelpers.decodeHTMLEntities(item.link);
                item.title = XSSHelpers.decodeHTMLEntities(item.title);
                item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
            });
            this.menuItemList = menuItems.sort((a,b) => a.order - b.order);

            this.searchHeaders = content?.searchHeaders || [];
        },
        openDesignCardDialog() {
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

            this.openDesignCardDialog();
        },
        /**
         * @param {string} designKey 
         * @param {mixed} designVal 
         */
        updateHomeDesign(designKey = '', designVal = '') {
            if (this.pageSections.includes(designKey)) {
                this[designKey] = designVal;

                this.postDesignContent(
                    JSON.stringify({
                        menu: {
                            menuCards: this.menuItemList,
                            direction: this.menuDirection,
                        },
                        header: this.header,
                        searchHeaders: this.searchHeaders
                    })
                );
            }
        },
        /**
         * Updates order on drop and click to move, or adds new/edited item.  Posts the updated list
         * @param {Object|null} menuItem
         * @param {boolean} markedForDeletion
         */
        updateMenuItemList(menuItem = null, markedForDeletion = false) {
            let newItems = this.menuItemList.map(item => ({...item}));

            if (menuItem === null) { //if null, update the order after drag drop or clickToMove
                let itemIDs = []
                let elList = Array.from(document.querySelectorAll('ul#menu > li'));
                elList.forEach(li => itemIDs.push(li.id));

                newItems.forEach(item => {
                    const index = itemIDs.indexOf(item.id);
                    if(index > -1) {
                        item.order = index;
                    }
                });

            } else { //if not null, editing modal is being used
                newItems = newItems.filter(item => item.id !== menuItem.id);
                if (markedForDeletion !== true) {
                    newItems.push(menuItem);
                }
            }
            this.menuItemList = newItems.sort((a,b) => a.order - b.order);
            this.updateHomeDesign('menuItemList', newItems)
        },
    },
    watch: {
        currentDesignID(newVal, oldVal) {
            if(newVal !== 0) {
                const content = JSON.parse(this.selectedDesign?.designContent || '{}');
                this.setSectionData(content);
            } else {
                this.header = null;
                this.searchHeaders = null;
                this.menuItemList = null;
                this.menuDirection = null;
                this.menuItem = {};
            }
        }
    },
    template: `<div v-if="appIsGettingData" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>
    <template v-else>
        <CustomHeader v-if="header!==null" />
        <div id="menu_and_search" :class="{editMode: isEditingMode}">
            <custom-home-menu v-if="menuItemList!==null"></custom-home-menu>
            <custom-search v-if="searchHeaders!==null"></custom-search>
        </div>

        <!-- HOMEPAGE DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>
    </template>`
}