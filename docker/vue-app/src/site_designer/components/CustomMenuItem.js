export default {
    name: 'custom-menu-item',
    data() {
        return {
            dyniconsPath: this.libsPath + 'dynicons/svg/',
        }
    },
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
            const linkClass = this.menuItem?.link && this.enableLink === true ? '' : ' disableClick';
            return "custom_menu_card" + linkClass;
        }
    },
    template:`<a :class="anchorClasses" :style="baseCardStyles" :href="menuItem.link" target="_blank">
        <img v-if="menuItem.icon" :src="dyniconsPath + menuItem.icon" alt="" class="icon_choice "/>
        <div class="card_text">
            <h2 :style="{color: menuItem.titleColor}" class="LEAF_custom">{{ menuItem.title }}</h2>
            <div :style="{color: menuItem.subtitleColor}" class="LEAF_custom">{{ menuItem.subtitle }}</div>
        </div>
    </a>`
}