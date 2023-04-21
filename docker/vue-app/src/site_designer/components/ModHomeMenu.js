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
            <li v-for="m in menuItemList" :key="m.id" style="cursor:pointer; margin: 0.75rem 0;">
                <custom-menu-item :menuItem="m" @click="setMenuItem(m)"></custom-menu-item>
            </li>
        </ul>
        <button type="button" @click="setMenuItem(null)">Create New Menu Item</button>
    </div>`
}