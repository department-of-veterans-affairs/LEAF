export default {
    name: 'custom-menu-item',
    props: {
        menuItem: {
            type: Object,
            required: true
        }
    },
    inject: [
        'libsPath',
    ],
    computed: {
        baseCardStyles() {
            return {
                backgroundColor: this.menuItem.bgColor,
            }
        }
    },
    template:`<div class="custom_card" :style="baseCardStyles">
        <img v-if="menuItem.icon" :src="libsPath + menuItem.icon" alt="" class="icon_choice "/>
        <div style="display: flex; flex-direction: column; width: 100%;">
            <div v-html="menuItem.title" :style="{color: menuItem.titleColor}" class="LEAF_custom"></div>
            <div v-html="menuItem.subtitle" :style="{color: menuItem.subtitleColor}" class="LEAF_custom"></div>
        </div>
    </div>`
}