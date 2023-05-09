import CustomMenuItem from "./CustomMenuItem";

export default {
    name: 'custom-home-menu',
    components: {
        CustomMenuItem
    },
    inject: [
        'isPostingUpdate',
        'publishedStatus',
        'isEditingMode',
        'menuItemList',
        'menuDirection',
        'allBuiltinsPresent',
        'addStarterButtons',
        'editMenuItemList',
        'postMenuItemList',
        'setMenuItem',
        'postEnableTemplate'
    ],
    computed: {
        wrapperStyles() {
            return this.isEditingMode ?
            {
                maxWidth: '450px',
                marginRight: '5rem'
            } : {}
        },
        ulStyles() {
            return this.menuDirection === 'vertical' || this.isEditingMode ?
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
                this.editMenuItemList();
                this.postMenuItemList();
            }
        }
    },
    template: `<div id="custom_menu_wrapper" :style="wrapperStyles">
        <template v-if="isEditingMode">
            <h3 style="margin: 0.5rem 0;">Homepage Menu is {{ publishedStatus.homepage === true ? '' : 'not'}} enabled</h3>
            <button type="button" class="btn-confirm" @click="postEnableTemplate('homepage')"
                style="width: 150px; margin-bottom: 1rem;" :disabled="isPostingUpdate">
                {{ publishedStatus.homepage === true ? 'Click to disable' : 'Click to enable'}}
            </button>
            <p>Drag-Drop cards to change their order.  Use the card menu to edit text and other values.</p>
        </template>
        <ul v-if="menuItemListDisplay.length > 0" id="menu"
            :class="{editMode: isEditingMode}" :style="ulStyles"
            data-effect-allowed="move"
            @drop.stop="onDrop"
            @dragover.prevent>
            <li v-for="m in menuItemListDisplay" :key="m.id" :id="m.id" :class="{editMode: isEditingMode}"
                :aria-label="+m.enabled === 1 ? 'This card is enabled' : 'This card is not enabled'"
                :draggable="isEditingMode ? true : false"
                @dragstart.stop="onDragStart">
                <custom-menu-item :menuItem="m"></custom-menu-item>
                <div v-show="isEditingMode" class="edit_card">
                    <button type="button" @click="setMenuItem(m)" title="edit this card" class="edit_menu_card btn-general">
                        <span role="img" aria="">☰</span>
                    </button>
                    <div class="notify_status" :class="{hidden: +m.enabled !== 1}">{{+m.enabled === 1 ? 'enabled' : 'hidden'}}</div>
                </div>
            </li>
        </ul>
        <div v-show="isEditingMode" style="display:flex; gap:1rem; justify-content:space-between; margin:1rem 0 2rem 0; width:360px;">
            <button type="button" class="btn-general" @click="setMenuItem(null)">Create New Menu Item</button>
            <button v-if="!allBuiltinsPresent" type="button" class="btn-general" @click="addStarterButtons()">Add Starter Buttons</button>
        </div>
    </div>`
}