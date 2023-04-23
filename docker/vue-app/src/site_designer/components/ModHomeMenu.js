import CustomMenuItem from "./CustomMenuItem";

export default {
    name: 'mod-home-menu',
    components: {
        CustomMenuItem
    },
    inject: [
        'menuItemList',
        'editMenuItemList',
        'setMenuItem'
    ],
    methods: {
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

                const listItems = Array.from(document.querySelectorAll('#menu_designer li'));
                const elLiToMove = document.getElementById(dataID);
                const elOtherLi = listItems.filter(item => item.id !== dataID);

                const closest = elOtherLi.find(item => event.clientY <= item.offsetTop + item.offsetHeight / 2);

                elUl.insertBefore(elLiToMove,closest);
                setTimeout(() => {
                    this.editMenuItemList();
                });
            }
        }
    },
    template: `<div>
        <p>Drag-Drop cards to change their order.  Use the card menu to edit text and other values.</p>
        <ul id="menu_designer"
            data-effect-allowed="move"
            @drop.stop="onDrop"
            @dragover.prevent>
            <li v-for="m in menuItemList" :key="m.id" :id="m.id"
                draggable="true"
                @dragstart.stop="onDragStart">
                <custom-menu-item :menuItem="m"></custom-menu-item>
                <button type="button" @click="setMenuItem(m)" title="edit this card" class="edit_menu_card btn-general">
                    <span role="img" aria="">☰</span>
                </button>
            </li>
        </ul>
        <button type="button" class="btn-general" @click="setMenuItem(null)">Create New Menu Item</button>
    </div>`
}