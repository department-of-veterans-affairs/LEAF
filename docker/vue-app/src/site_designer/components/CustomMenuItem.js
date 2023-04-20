export default {
    name: 'custom-menu-item',
    props: {
        menuItem: {
            type: Object,
            required: true
        }
    },
    template:`<div style="display: flex; width:200px; padding: 0.5rem;" :style="{backgroundColor: menuItem.bgColor}">
        <img v-if="menuItem.icon" :src="menuItem.icon" />
        <div style="display: flex; flex-direction: column; width: 100%;">
            <div v-html="menuItem.title" :style="{color: menuItem.titleColor}" class="LEAF_custom"></div>
            <div v-html="menuItem.subtitle" :style="{color: menuItem.subtitleColor}" class="LEAF_custom"></div>
        </div>
    </div>`
}