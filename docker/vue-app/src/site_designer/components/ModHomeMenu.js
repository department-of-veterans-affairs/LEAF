import CustomMenuItem from "./CustomMenuItem";

export default {
    name: 'mod-home-menu',
    components: {
        CustomMenuItem
    },
    inject: [
        'menuItemList',
        'setMenuItem'
    ],
    template: `<div>
        <ul>
            <li v-for="m in menuItemList" :key="m.id" @click="setMenuItem(m.id)" style="cursor:pointer">
                <custom-menu-item :menuItem="m"></custom-menu-item>
            </li>
        </ul>
        <button type="button" @click="setMenuItem">Create New Menu Item</button>
    </div>`
}