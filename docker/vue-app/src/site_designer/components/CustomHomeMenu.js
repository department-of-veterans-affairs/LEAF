import CustomMenuItem from "./CustomMenuItem";

export default {
    name: 'custom-home-menu',
    data() {
        return {
            menuDirectionSelection: this.menuDirection,
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
        }
    },
    components: {
        CustomMenuItem
    },
    inject: [
        'isEditingMode',
        'builtInIDs',
        'menuItemList',
        'menuDirection',
        'menuIsUpdating',
        'updateMenuItemList',
        'postHomeMenuSettings',
        'setMenuItem',
    ],
    computed: {
        wrapperStyles() {
            return this.isEditingMode ?
            {
                maxWidth: '500px',
                marginRight: '3rem'
            } : {}
        },
        ulStyles() {
            return this.menuDirectionSelection === 'v' || this.isEditingMode ?
                {
                    flexDirection: 'column',
                    maxWidth: '430px'
                } :
                { 
                    flexWrap: 'wrap'
                }
        },
        menuItemListDisplay() {
            return this.isEditingMode ?
                this.menuItemList : this.menuItemList.filter(item => +item.enabled === 1);
        },
        allBuiltinsPresent() {
            let result = true;
            this.builtInIDs.forEach(id => {
                if (result === true && !this.menuItemList.some(item => item.id === id)) {
                    result = false;
                }
            });
            return result;
        },
    },
    methods: {
        addStarterCards() {
            let buttonsAdded = 0;
            let newItems = this.menuItemList.map(item => ({...item}));

            this.builtInButtons.forEach(b => {
                const doNotHaveID = !this.menuItemList.some(item => item.id === b.id);
                if (doNotHaveID) {
                    newItems.unshift({...b});
                    buttonsAdded += 1;
                }
            });
            if(buttonsAdded > 0) {
                this.postHomeMenuSettings(newItems, this.menuDirection);
            }
        },
        onDragStart(event = {}) {
            if(event?.dataTransfer) {
                event.dataTransfer.dropEffect = 'move';
                event.dataTransfer.effectAllowed = 'move';
                event.dataTransfer.setData('text/plain', event.target.id);
            }
        },
        onDrop(event = {}) {
            if(event?.dataTransfer && event.dataTransfer.effectAllowed === 'move') {
                const dataID = event.dataTransfer.getData('text');
                const elUl = event.currentTarget;
                const listItems = Array.from(document.querySelectorAll('ul#menu > li'));
                const elLiToMove = document.getElementById(dataID);
                const elOtherLi = listItems.filter(item => item.id !== dataID);
                const closest = elOtherLi.find(item => window.scrollY + event.clientY <= item.offsetTop + item.offsetHeight/2);
                elUl.insertBefore(elLiToMove, closest);
                this.updateMenuItemList();
            }
        },
        /**
         * moves an item in the Form Index via the buttons that appear when the item is selected
         * @param {Object} event 
         * @param {string} id of the item to move
         * @param {boolean} moveup click/enter moves the item up/down
         */
        clickToMove(event = {}, id = '', moveup = false) {
            if (event?.keyCode === 32) event.preventDefault();
            const parentEl = event.currentTarget.closest('ul');
            const elToMove = document.getElementById(id);
            const oldElsLI = Array.from(parentEl.querySelectorAll('li'));
            const currentIndex = oldElsLI.indexOf(elToMove);
            const newElsLI = oldElsLI.filter(li => li !== elToMove);
            const spliceLoc = moveup ? currentIndex - 1 : currentIndex + 1;
            if(spliceLoc > -1 && spliceLoc < oldElsLI.length) {
                newElsLI.splice(spliceLoc, 0, elToMove);
                oldElsLI.forEach(li => parentEl.removeChild(li));
                newElsLI.forEach(li => {
                    parentEl.appendChild(li);
                });
                this.updateMenuItemList();
            }
        },
        updateDirection(event = {}) {
            console.log('direction updated via input')
            const d = event?.target?.value || '';
            if(d !== '' && d !== this.menuDirection) {
                this.postHomeMenuSettings(this.menuItemList, this.menuDirectionSelection);
            }
        }
    },
    template: `<div id="custom_menu_wrapper" :style="wrapperStyles">
        <div v-show="isEditingMode" style="margin-top: 2rem;">
            <p style="margin: 0.5rem 0;">Drag-Drop cards or use the up and down buttons to change their order. &nbsp;Use the card menu to edit text and other values.</p>
        </div>
        <ul v-if="menuItemListDisplay.length > 0" id="menu"
            :class="{editMode: isEditingMode}" :style="ulStyles"
            data-effect-allowed="move"
            @drop.stop="onDrop"
            @dragover.prevent>
            <li v-for="m in menuItemListDisplay" :key="m.id" :id="m.id" :class="{editMode: isEditingMode}"
                :aria-label="+m.enabled === 1 ? 'This card is enabled' : 'This card is hidden'"
                :draggable="isEditingMode && !menuIsUpdating ? true : false"
                @dragstart.stop="onDragStart">
                <custom-menu-item :menuItem="m"></custom-menu-item>
                <div v-show="isEditingMode" class="edit_card">
                    <div tabindex="0" role="button"
                    @click="clickToMove($event, m.id, true)" @keydown.stop.enter.space="clickToMove($event, m.id, true)"
                        aria-label="click to move card up" class="click_to_move up"></div>
                    <button type="button" @click="setMenuItem(m)" title="edit this card" class="edit_menu_card btn-general">
                        <span role="img" aria="">☰</span>
                    </button>
                    <div tabindex="0" role="button"
                        @click="clickToMove($event, m.id, false)" @keydown.stop.enter.space="clickToMove($event, m.id, false)"
                        aria-label="click to move card down" class="click_to_move down"></div>
                    <div class="notify_status" :class="{hidden: +m.enabled !== 1}">{{+m.enabled === 1 ? 'enabled' : 'hidden'}}</div>
                </div>
            </li>
        </ul>
        <div v-show="isEditingMode" style="display:flex; gap:1rem; margin:1rem 0 1rem 0; width:360px;">
            <button v-if="!allBuiltinsPresent" type="button" class="btn-general" @click="addStarterCards()">Add Starter Cards</button>
            <button type="button" class="btn-general" @click="setMenuItem(null)">Create New Card</button>
            <label for="menu_direction_select" style="align-self: flex-end">
            <select id="menu_direction_select" style="width: 80px;" v-model="menuDirectionSelection"
                @change="updateDirection" :disabled="menuIsUpdating">
                <option value="v">Columns</option>
                <option value="h">Rows</option>
            </select>&nbsp;Menu Direction</label>
        </div>
    </div>`
}