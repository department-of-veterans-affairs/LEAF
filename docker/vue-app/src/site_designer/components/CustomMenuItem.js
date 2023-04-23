export default {
    name: 'custom-menu-item',
    props: {
        menuItem: {
            type: Object,
            required: true
        },
        enableLink: {
            type: Boolean,
            default: false
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
        },
        anchorClasses() {
            const linkClass = this.menuItem?.link ? '' : ' disableClick';
            return "custom_menu_card" + linkClass;
        }
    },
    template:`<a :class="anchorClasses" :style="baseCardStyles" :href="menuItem.link" target="_blank">
        <img v-if="menuItem.icon" :src="libsPath + menuItem.icon" alt="" class="icon_choice "/>
        <div style="display: flex; flex-direction: column; justify-content: center; align-self: stretch; width: 100%;">
            <div v-html="menuItem.title" :style="{color: menuItem.titleColor}" class="LEAF_custom"></div>
            <div v-html="menuItem.subtitle" :style="{color: menuItem.subtitleColor}" class="LEAF_custom"></div>
        </div>
    </a>`
}