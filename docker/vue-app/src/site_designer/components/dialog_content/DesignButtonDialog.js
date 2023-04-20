import CustomMenuItem from "../CustomMenuItem";

export default {
    name: 'design-button-dialog',
    data() {
        return {
            id: this.menuItem.id,
            title: this.menuItem?.title || '',
            titleColor: this.menuItem?.titleColor || '#000000',

            subtitle: this.menuItem?.subtitle || '',
            subtitleColor: this.menuItem?.subtitleColor || '#000000',

            bgColor: this.menuItem?.bgColor || '#ffffff',
            icon: this.menuItem?.icon || '',
            link: this.menuItem?.link || ''
        }
    },
    components: {
        CustomMenuItem
    },
    inject: [
        'menuItem',
        'saveMenuItem',
        'iconList'
    ],
    mounted() {
        this.useTrumbowEditor();
    },
    computed: {
        menuItemOBJ() {
            return {
                id: this.id,
                title: this.title,
                titleColor: this.titleColor,
                subtitle: this.subtitle,
                subtitleColor: this.subtitleColor,
                bgColor: this.bgColor,
                icon: this.icon,
                link: this.link
            }
        },
        menuItemJSON() {
            return JSON.stringify(this.menuItemOBJ);
        },
    },
    methods: {
        useTrumbowEditor() {
            $('#menu_title_trumbowyg').trumbowyg({
                resetCss: false,
                btns: ['formatting', 'bold', 'italic', 'underline',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('#menu_subtitle_trumbowyg').trumbowyg({
                resetCss: false,
                btns: ['formatting', 'bold', 'italic', 'underline',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('.trumbowyg-box').css({
                'min-height': '75px',
                'height': 'auto',
                'max-width': '700px',
                'margin': '0 0.5rem 1rem 0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '50px',
                'height': 'auto',
                'padding': '1rem'
            });
        },
        updateTrumbowygText(section = 'title') {
            if (['title','subtitle'].includes(section)) {
                const elTrumbow = document.querySelector(`#menu_${section}_trumbowyg.trumbowyg-editor`);
                if(elTrumbow !== undefined && elTrumbow !== null) {
                    this[section] = elTrumbow.innerHTML;
                }
            }
        },

        testing() {
            console.log('testing called')
        },
        onSave() {
            console.log('modal save')
        }
    },
    template: `<div style="max-width: 600px;">
        <!-- NOTE: the initial trumbow html content needs to use the menuitem not the data property -->
        <label for="menu_title_trumbowyg" id="menu_title_trumbowyg_label">Button Title</label>
        <div id="menu_title_trumbowyg" aria-labelledby="menu_title_trumbowyg_label"
            @input="updateTrumbowygText('title')" v-html="menuItem.title">
        </div>
        <label for="menu_subtitle_trumbowyg" id="menu_subtitle_trumbowyg_label">Button Description</label>
        <div id="menu_subtitle_trumbowyg" aria-labelledby="menu_subtitle_trumbowyg_label"
            @input="updateTrumbowygText('subtitle')" v-html="menuItem.subtitle">
        </div>
        <div style="display:flex; gap:1rem;">
            <label for="title_color">Title Color&nbsp;
                <input type="color" id="title_color" v-model="titleColor" />
            </label>
            <label for="descr_color">Subtitle Color&nbsp;
                <input type="color" id="descr_color" v-model="subtitleColor" />
            </label>
            <label for="bg_color">Background Color&nbsp;
                <input type="color" id="bg_color" v-model="bgColor" />
            </label>
        </div>
        <h3 style="margin: 1rem 0;">Button Preview</h3>
        <a :style="{bgColor: bgColor}" :href="link" target="_blank" class="LEAF_custom">
            <custom-menu-item :menuItem="menuItemOBJ"></custom-menu-item>
        </a>
        <div class="test">obj + json
            <div>{{ menuItemOBJ }}</div>
            <div style="word-break:break-all">{{ menuItemJSON }}</div>
        </div>
    </div>`
}