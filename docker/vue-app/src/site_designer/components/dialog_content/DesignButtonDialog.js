import CustomMenuItem from "../CustomMenuItem";

export default {
    name: 'design-button-dialog',
    data() {
        return {
            id: this.menuItem.id,
            order: this.menuItem.order || 0,
            title: this.menuItem?.title || '',
            titleColor: this.menuItem?.titleColor || '#000000',
            subtitle: this.menuItem?.subtitle || '',
            subtitleColor: this.menuItem?.subtitleColor || '#000000',
            bgColor: this.menuItem?.bgColor || '#ffffff',
            icon: this.menuItem?.icon || '',
            link: this.menuItem?.link || '',
            useTitleColor: this.menuItem?.titleColor === this.menuItem?.subtitleColor,
            useAnIcon: this.menuItem?.icon !== '',
            markedForDeletion: false
        }
    },
    components: {
        CustomMenuItem
    },
    inject: [
        'libsPath',
        'menuItem',
        'editMenuItemList',
        'iconList',
        'closeFormDialog'
    ],
    mounted() {
        this.useTrumbowEditor();
    },
    computed: {
        menuItemOBJ() {
            return {
                id: this.id,
                order: this.order,
                title: this.title,
                titleColor: this.titleColor,
                subtitle: this.subtitle,
                subtitleColor: this.useTitleColor ? this.titleColor : this.subtitleColor,
                bgColor: this.bgColor,
                icon: this.useAnIcon === true ? this.icon : '',
                link: this.link
            }
        },
        anchorClasses() {
            const linkClass = this.menuItemOBJ?.link ? '' : ' disableClick';
            return "LEAF_custom" + linkClass;
        }
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
        getIconSrc(absolutePath = '') {
            const index = absolutePath.indexOf('dynicons\/');
            return this.libsPath + absolutePath.slice(index);
        },
        setIcon(event = {}) {
            const id = event.target.id;
            const index = id.indexOf('dynicons\/');
            if (index > -1) {
                this.icon = id.slice(index);
            }
        },
        onSave() {
            this.editMenuItemList(this.menuItemOBJ);
            this.closeFormDialog();
        }
    },
    template: `<div style="max-width: 600px;">
        <div style="margin: 1rem 0 2rem 0;">
            <h3 style="margin: 1rem 0;">Button Preview</h3>
            <a :style="{bgColor: bgColor}" :href="link" target="_blank" :class="anchorClasses">
                <custom-menu-item :menuItem="menuItemOBJ"></custom-menu-item>
            </a>
        </div>
        <!-- NOTE: initial trumbow html content needs to use menuitem -->
        <label for="menu_title_trumbowyg" id="menu_title_trumbowyg_label">Button Title</label>
        <div id="menu_title_trumbowyg" aria-labelledby="menu_title_trumbowyg_label"
            @input="updateTrumbowygText('title')" v-html="menuItem.title">
        </div>
        <label for="menu_subtitle_trumbowyg" id="menu_subtitle_trumbowyg_label">Button Subtitle</label>
        <div id="menu_subtitle_trumbowyg" aria-labelledby="menu_subtitle_trumbowyg_label"
            @input="updateTrumbowygText('subtitle')" v-html="menuItem.subtitle">
        </div>
        <h3>Style Attributes</h3>
        <div class="designer_inputs">
            <label for="title_color">
                <input type="color" id="title_color" v-model="titleColor" />&nbsp;Title Color
            </label>
            <label class="checkable leaf_check" for="title_color_confirm">
                <input type="checkbox" id="title_color_confirm" v-model="useTitleColor" class="icheck leaf_check" />
                <span class="leaf_check"></span>Use title color for subtitle
            </label>
            <label v-if="!useTitleColor" for="descr_color">
                <input type="color" id="descr_color" v-model="subtitleColor" />&nbsp;Subtitle Color
            </label>
        </div>
        <div class="designer_inputs">
            <label for="bg_color">
                <input type="color" id="bg_color" v-model="bgColor" />&nbsp;Background Color
            </label>
            <label class="checkable leaf_check" for="use_icon_confirm">
                <input type="checkbox" id="use_icon_confirm" v-model="useAnIcon" class="icheck leaf_check" />
                <span class="leaf_check"></span>Use an Icon
            </label>
        </div>
        <fieldset v-if="useAnIcon">
            <legend>Icon Selections</legend>
            <div class="designer_inputs" style="height:150px; overflow:auto;" @click="setIcon($event)">
                <img v-for="icon in iconList" :key="icon.name" 
                    :id="icon.src" class="icon_choice"
                    :src="getIconSrc(icon.src)" :alt="icon.name" />
            </div>
        </fieldset>
    </div>`
}