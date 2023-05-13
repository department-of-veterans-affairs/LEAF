import CustomMenuItem from "./CustomMenuItem";

export default {
    name: 'custom-home-menu',
    data() {
        return {
            menuDirectionSelection: this.menuDirection,
        }
    },
    components: {
        CustomMenuItem
    },
    inject: [
        'isPostingUpdate',
        'publishedStatus',
        'isEditingMode',
        'builtInIDs',
        'addStarterButtons',
        'menuItemList',
        'menuDirection',
        'updateMenuItemList',
        'postHomepageSettings',
        'setMenuItem',
        'postEnableTemplate',
    ],
    computed: {
        wrapperStyles() {
            return this.isEditingMode ?
            {
                maxWidth: '450px',
                marginRight: '3rem'
            } : {}
        },
        ulStyles() {
            return this.menuDirectionSelection === 'v' || this.isEditingMode ?
                {
                    flexDirection: 'column',
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
                if (!this.menuItemList.some(item => item.id === id)) {
                    result = false;
                }
            });
            return result;
        },
        enabled() {
            return this.publishedStatus.homepage === true;
        }
    },
    methods: {
        onDragStart(event = {}) {
            if(!this.isPostingUpdate && event?.dataTransfer) {
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
            const d = event?.target?.value || '';
            if(d !== '' && d !== this.menuDirection) {
                this.postHomepageSettings(this.menuItemList, this.menuDirectionSelection);
            }
        }
    },
    watch: {
        menuDirection(newVal, oldVal) {
            console.log(newVal, oldVal)
            this.menuDirectionSelection = newVal;
        }
    },
    template: `<div id="custom_menu_wrapper" :style="wrapperStyles">
        <template v-if="isEditingMode">
            <h4 style="margin: 0.5rem 0;">Homepage Menu is {{ enabled ? '' : 'not'}} enabled</h4>
            <button type="button" @click="postEnableTemplate('homepage')"
                class="btn-confirm" :class="{enabled: enabled}" 
                style="width: 100px; margin-bottom: 1rem;" :disabled="isPostingUpdate">
                {{ enabled ? 'Disable' : 'Publish'}}
            </button>
            <p style="margin: 0.5rem 0;">Drag-Drop cards or use the up and down buttons to change their order. &nbsp;Use the card menu to edit text and other values.</p>
            <label for="menu_direction_select">Menu Direction(use preview to view this effect)</label>
            <select id="menu_direction_select" style="width: 150px;" v-model="menuDirectionSelection" @change="updateDirection">
                <option v-if="menuDirectionSelection===''" value="">Select an Option</option>
                <option value="v">Columns</option>
                <option value="h">Rows</option>
            </select>
        </template>
        <ul v-if="menuItemListDisplay.length > 0" id="menu"
            :class="{editMode: isEditingMode}" :style="ulStyles"
            data-effect-allowed="move"
            @drop.stop="onDrop"
            @dragover.prevent>
            <li v-for="m in menuItemListDisplay" :key="m.id" :id="m.id" :class="{editMode: isEditingMode}"
                :aria-label="+m.enabled === 1 ? 'This card is enabled' : 'This card is hidden'"
                :draggable="isEditingMode ? true : false"
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
        <div v-show="isEditingMode" style="display:flex; gap:1rem; margin:1rem 0 2rem 0; width:360px;">
            <button type="button" class="btn-general" @click="setMenuItem(null)">Create New Card</button>
            <button v-if="!allBuiltinsPresent" type="button" class="btn-general" @click="addStarterButtons()">Add Starter Cards</button>
        </div>
    </div>`
}