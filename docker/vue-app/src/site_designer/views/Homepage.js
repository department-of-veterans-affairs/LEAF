import { computed } from 'vue';
import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import DesignCardDialog from "../components/dialog_content/DesignCardDialog.js";
import ConfirmPublishDialog from "../components/dialog_content/ConfirmPublishDialog.js";
import NewDesignDialog from "../components/dialog_content/NewDesignDialog.js";
import HistoryDialog from "../components/dialog_content/HistoryDialog.js";
import CustomHeader from "../components/CustomHeader.js";
import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    data() {
        return {
            builtInIDs: ["btn_reports","btn_bookmarks","btn_inbox","btn_new_request"],
            pageSections: ['header', 'menuCardList', 'menuDirection', 'searchHeaders'],
            menuItem: {},

            header: null,
            menuDirection: null,
            menuCardList: null,
            searchHeaders: null
        }
    },
    mounted() {
        if(this.selectedDesignContent !== null) {
            this.setSectionData(this.selectedDesignContent);
            this.setBasicDesignInfo();
        }
    },
    unmounted() {
        console.log('search unmounted')
    },
    inject: [
        'appIsGettingData',
        'appIsUpdating',
        'postDesignContent',
        'selectedDesign',
        'currentDesignID',
        'isEditingMode',
        'generateID',
        'setBasicDesignInfo',

        'openDesignCardDialog',
        'showFormDialog',
        'dialogFormContent'
    ],
    provide() {
        return {
            menuItem: computed(() => this.menuItem),
            menuDirection: computed(() => this.menuDirection),
            menuCardList: computed(() => this.menuCardList),
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
        NewDesignDialog,
        HistoryDialog,
        CustomHeader,
        CustomHomeMenu,
        CustomSearch
    },
    computed: {
        selectedDesignContent() {
            return this.selectedDesign === null ? null : JSON.parse(this.selectedDesign?.designContent || '{}');
        },
        showSearch() {
            return this.isEditingMode || (!this.isEditingMode && this.searchHeaders?.length > 0);
        }
    },
    methods: {
        setSectionData(content = {}) {
            this.header = content?.header || {};
            this.menuDirection = content?.menu?.direction || 'v';

            let menuItems = content?.menu?.menuCards || [];
            menuItems.map(item => {
                item.link = XSSHelpers.decodeHTMLEntities(item.link);
                item.title = XSSHelpers.decodeHTMLEntities(item.title);
                item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
            });
            this.menuCardList = menuItems.sort((a,b) => a.order - b.order);

            this.searchHeaders = content?.searchHeaders || [];
        },
        /**
         * @param {object|null} menuItem set menuitem for editing
         */
        setMenuItem(menuItem = null) {
            this.menuItem = menuItem !== null ? menuItem :
                {
                    id: this.generateID(this.menuCardList, 'id'),
                    order: this.menuCardList.length,
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
                            menuCards: this.menuCardList,
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
            let newItems = this.menuCardList.map(item => ({...item}));

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
            this.menuCardList = newItems.sort((a,b) => a.order - b.order);
            this.updateHomeDesign('menuCardList', newItems)
        },
    },
    watch: {
        selectedDesign(newVal, oldVal) {
            if(newVal !== null) {
                this.setSectionData(this.selectedDesignContent);
            } else {
                this.header = null;
                this.searchHeaders = null;
                this.menuCardList = null;
                this.menuDirection = null;
                this.menuItem = {};
            }
            this.setBasicDesignInfo();
        }
    },
    template: `<div v-if="appIsGettingData" class="loading">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>
    <div>
        <CustomHeader v-if="header!==null" :key="'header_' + currentDesignID" />
        <div id="menu_and_search" :class="{editMode: isEditingMode}">
            <customHomeMenu v-if="menuCardList!==null" :key="'menu_' + currentDesignID" />
            <customSearch v-if="searchHeaders!==null && showSearch" :key="'search_' + currentDesignID" />
        </div>

        <!-- DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent" historyType="design" :historyID="currentDesignID"></component>
            </template>
        </leaf-form-dialog>
    </div>`
}