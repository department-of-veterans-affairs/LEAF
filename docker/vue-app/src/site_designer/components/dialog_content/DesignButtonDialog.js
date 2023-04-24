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

            builtInIDs: ['btn_reports','btn_bookmarks','btn_inbox','btn_new_request'],
            enabled: +this.menuItem?.enabled === 1,
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
        'closeFormDialog',
        'setDialogButtonText'
    ],
    mounted() {
        this.useTrumbowEditor();
    },
    computed: {
        menuItemOBJ() {
            return {
                id: this.id,
                order: this.order,
                title: XSSHelpers.stripTags(this.title, ['<script>']),
                titleColor: this.titleColor,
                subtitle: XSSHelpers.stripTags(this.subtitle, ['<script>']),
                subtitleColor: this.useTitleColor ? this.titleColor : this.subtitleColor,
                bgColor: this.bgColor,
                icon: this.useAnIcon === true ? this.icon : '',
                link: this.link,
                enabled: +this.enabled
            }
        },
        builtInCard() {
            return this.builtInIDs.includes(this.id)
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
                'min-height': '60px',
                'height': 'auto',
                'width':'475px',
                'margin': '0 0.5rem 1rem 0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '40px',
                'height': 'auto',
                'padding': '0.5rem'
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
            this.editMenuItemList(this.menuItemOBJ, this.markedForDeletion);
            this.closeFormDialog();
        }
    },
    watch: {
        markedForDeletion(newVal, oldVal) {
            let elButton = document.getElementById('button_save');
            if(newVal === true) {
                this.setDialogButtonText({confirm: 'Delete', cancel: 'Cancel'});
                elButton.setAttribute('title', 'Delete');
                elButton.style.backgroundColor = '#b00000';
            } else {
                this.setDialogButtonText({confirm: 'Save', cancel: 'Cancel'});
                elButton.setAttribute('title', 'Save');
                elButton.style.backgroundColor = '#005EA2';
            }
        }
    },
    template: `<div style="max-width: 600px;" id="design_button_modal">
        <h3>Card Preview</h3>
        <div class="designer_inputs" style="margin-bottom:1rem;">
            <custom-menu-item :menuItem="menuItemOBJ"></custom-menu-item>
            <div style="display: flex; flex-direction: column;">
                <label class="checkable leaf_check" for="button_enabled"
                    style="margin-top: auto;" :style="{color: +enabled === 1 ? '#209060' : '#b00000'}">
                    <input type="checkbox" id="button_enabled" v-model="enabled" class="icheck leaf_check" />
                    <span class="leaf_check"></span>{{ +enabled === 1 ? 'enabled' : 'hidden until enabled'}}
                </label>
                <label class="checkable leaf_check" for="button_delete"
                    :style="{color: +markedForDeletion === 1 ? '#b00000' : 'inherit'}">
                    <input type="checkbox" id="button_delete" v-model="markedForDeletion" class="icheck leaf_check" />
                    <span class="leaf_check"></span>{{ +markedForDeletion === 1 ? 'click delete to confirm' : 'mark for deletion'}}
                </label>
            </div>
        </div>
        <div v-if="!builtInCard" style="margin-bottom: 1rem;">
            <label for="card_link">Card Link (full URL)</label>
            <input type="text" id="card_link" style="width: 475px;" v-model="link" />
        </div>
        <!-- NOTE: initial trumbow html content needs to use menuitem -->
        <div class="designer_inputs">
            <div>
                <label for="menu_title_trumbowyg" id="menu_title_trumbowyg_label">Button Title</label>
                <div id="menu_title_trumbowyg" aria-labelledby="menu_title_trumbowyg_label"
                    @input="updateTrumbowygText('title')" v-html="menuItem.title">
                </div>
            </div>
            <div>
                <label for="title_color">Font Color</label>
                <input type="color" id="title_color" v-model="titleColor" />
            </div>
        </div>
        <div class="designer_inputs">
            <div>
                <label for="menu_subtitle_trumbowyg" id="menu_subtitle_trumbowyg_label">Button Subtitle</label>
                <div id="menu_subtitle_trumbowyg" aria-labelledby="menu_subtitle_trumbowyg_label"
                    @input="updateTrumbowygText('subtitle')" v-html="menuItem.subtitle">
                </div>
            </div>
            <div>
                <div v-show="!useTitleColor" style="margin-bottom: 1rem;">
                    <label for="subtitle_color" style="margin-right: 0.5rem;">Font Color</label>
                    <input type="color" id="subtitle_color" v-model="subtitleColor"/>
                </div>
                <label class="checkable leaf_check" for="title_color_confirm">
                    <input type="checkbox" id="title_color_confirm" v-model="useTitleColor" class="icheck leaf_check" />
                    <span class="leaf_check"></span>title color
                </label>
            </div>
        </div>

        <h3 style="margin: 0.5rem 0;">Style Attributes</h3>
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
            <div class="designer_inputs wrap" style="height:150px; max-width: 560px; overflow:auto;" @click="setIcon($event)">
                <img v-for="icon in iconList" :key="icon.name" 
                    :id="icon.src" class="icon_choice"
                    :src="getIconSrc(icon.src)" :alt="icon.name" />
            </div>
        </fieldset>
    </div>`
}