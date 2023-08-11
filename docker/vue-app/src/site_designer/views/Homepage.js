import { computed } from 'vue';
import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import DesignCardDialog from "../components/dialog_content/DesignCardDialog.js";
import CustomHeader from "../components/CustomHeader.js";
import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    data() {
        return {
            homepageIsUpdating: false,
            builtInIDs: ["btn_reports","btn_bookmarks","btn_inbox","btn_new_request"],
            designs: ['header', 'menuItemList', 'menuDirection', 'chosenHeaders'],
            menuItem: {},

            header: this.homeData?.header || null,
            menuDirection: this.homeData?.menuDirection || null,
            menuItemList: this.homeData?.menuItemList || null,
            chosenHeaders: this.homeData?.chosenHeaders || null
        }
    },
    created() {
        console.log('homepage created')
        if(this.designData !== null) {
            console.log('design data is available, updating homepage data');
            this.setDesignData()
        }
    },
    inject: [
        'CSRFToken',
        'APIroot',
        'appIsGettingData',
        'appIsPublishing',
        'toggleEnableTemplate',
        'updateLocalDesignData',
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
            homepageIsUpdating: computed(() => this.homepageIsUpdating),
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
        CustomHeader,
        CustomHomeMenu,
        CustomSearch
    },
    computed: {
        enabled() {
            return parseInt(this.designData?.homepage_enabled) === 1;
        },
        homeData() {
            return JSON.parse(this.designData?.homepage_design_json || "{}");
        }
    },
    methods: {
        setDesignData() {
            this.header = this.homeData?.header || {};
            this.menuDirection = this.homeData?.direction || 'v';

            let menuItems = this.homeData?.menuCards || [];
            menuItems.map(item => {
                item.link = XSSHelpers.decodeHTMLEntities(item.link);
                item.title = XSSHelpers.decodeHTMLEntities(item.title);
                item.subtitle = XSSHelpers.decodeHTMLEntities(item.subtitle);
            });
            this.menuItemList = menuItems.sort((a,b) => a.order - b.order);

            this.chosenHeaders = this.homeData?.chosenHeaders || [];
        },
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
        updateHomeDesign(designKey = '', designOBJ = {}) {
            if (this.designs.includes(designKey)) {
                this[designKey] = designOBJ;
                this.postHomeSettings(this.menuItemList, this.menuDirection, this.header, this.chosenHeaders);

            }
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
            this.updateHomeDesign('menuItemList', newItems)
        },
        async postHomeSettings(menuCards = this.menuItemList, direction = this.menuDirection, header = this.header, chosenHeaders = this.chosenHeaders) {
            this.homepageIsUpdating = true; //appIsGettingData,
            try {
                let formData = new FormData();
                formData.append('CSRFToken', CSRFToken);
                formData.append('home_menu_list', JSON.stringify(menuCards));
                formData.append('menu_direction', direction);
                formData.append('home_header', JSON.stringify(header));
                formData.append('search_cols', JSON.stringify(chosenHeaders));
                
                const response = await fetch(`${this.APIroot}site/settings/homepage_design_json`, {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                if(+data?.code === 1) {
                    const newJSON = JSON.stringify({menuCards, direction, header, chosenHeaders})
                    this.updateLocalDesignData('homepage', newJSON);
                } else {
                    console.log('unexpected response returned:', data)
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.homepageIsUpdating = false;
            }
        },
    },
    watch: {
        designData(newVal, oldVal) {
            console.log('watch detected designData value change:')
            console.log(newVal, 'was:', oldVal)
            if(newVal !== null) {
                this.setDesignData();
            }
        }
    },
    template: `<div v-if="appIsGettingData" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>
    <template v-else>
        <div id="selected_page_status">
            <button type="button" @click="toggleEnableTemplate('homepage')"
                class="btn-confirm" :class="{enabled: enabled}" 
                style="width: 100px;" :disabled="appIsPublishing">
                {{ enabled ? 'Disable' : 'Publish'}}
            </button>
            <h3>
                {{ isEditingMode ? 'Editing the Homepage ' : 'Previewing the Homepage ' }}
                (<span :style="{color: enabled ? '#008060' : '#b00000'}">{{ enabled ? 'page is active' : 'page is inactive'}}</span>)
            </h3>
        </div>

        
        <CustomHeader v-if="header!==null" />
        

        <div id="menu_and_search" :class="{editMode: isEditingMode}">
            <custom-home-menu v-if="menuItemList!==null"></custom-home-menu>
            <custom-search v-if="chosenHeaders!==null"></custom-search>
        </div>

        <!-- HOMEPAGE DIALOGS -->
        <leaf-form-dialog v-if="showFormDialog">
            <template #dialog-content-slot>
                <component :is="dialogFormContent"></component>
            </template>
        </leaf-form-dialog>
    </template>`
}