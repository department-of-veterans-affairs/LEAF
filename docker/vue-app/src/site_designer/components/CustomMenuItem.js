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
    },
    inject: [
        'libsPath',
        'rootPath',
        'builtInIDs',
        'isEditingMode'
    ],
    computed: {
        baseCardStyles() {
            return {
                backgroundColor: this.menuItem.bgColor,
            }
        },
        anchorClasses() {
            const linkClass = this.menuItem?.link && this.isEditingMode === false ? '' : ' disableClick';
            return "custom_menu_card" + linkClass;
        },
        href() {
            return this.builtInIDs.includes(this.menuItem.id) ?
                this.rootPath + this.menuItem.link : this.menuItem.link;
        }
    },
    template:`<a :class="anchorClasses" :style="baseCardStyles" :href="href" target="_blank">
        <img v-if="menuItem.icon" :src="dyniconsPath + menuItem.icon" alt="" class="icon_choice "/>
        <div class="card_text">
            <h2 :style="{color: menuItem.titleColor}" class="LEAF_custom">{{ menuItem.title }}</h2>
            <div :style="{color: menuItem.subtitleColor}" class="LEAF_custom">{{ menuItem.subtitle }}</div>
        </div>
    </a>`
}