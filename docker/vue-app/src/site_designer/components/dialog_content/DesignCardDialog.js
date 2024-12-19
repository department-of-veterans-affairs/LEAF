import CustomMenuItem from "../CustomMenuItem";

export default {
    name: 'design-card-dialog',
    data() {
        return {
            id: this.menuItem.id,
            order: this.menuItem?.order || 0,
            title: XSSHelpers.stripAllTags(this.menuItem?.title || ''),
            titleColor: this.menuItem?.titleColor || '#000000',
            subtitle: XSSHelpers.stripAllTags(this.menuItem?.subtitle || ''),
            subtitleColor: this.menuItem?.subtitleColor || '#000000',
            bgColor: this.menuItem?.bgColor || '#ffffff',
            icon: this.menuItem?.icon || '',
            link: XSSHelpers.stripAllTags(this.menuItem?.link || ''),
            enabled: +this.menuItem?.enabled === 1,

            iconPreviewSize: '30px',
            useTitleColor: this.menuItem?.titleColor === this.menuItem?.subtitleColor,
            useAnIcon: this.menuItem?.icon !== '',
            markedForDeletion: false
        }
    },
    mounted() {
        this.setDialogSaveFunction(this.onSave);
    },
    components: {
        CustomMenuItem
    },
    inject: [
        'libsPath',
        'menuItem',
        'builtInIDs',
        'updateMenuItemList',
        'iconList',
        'closeFormDialog',
        'setDialogSaveFunction',
        'setDialogButtonText'
    ],
    computed: {
        menuItemOBJ() {
            return {
                id: this.id,
                order: this.order,
                title: XSSHelpers.stripAllTags(this.title),
                titleColor: this.titleColor,
                subtitle: XSSHelpers.stripAllTags(this.subtitle),
                subtitleColor: this.useTitleColor ? this.titleColor : this.subtitleColor,
                bgColor: this.bgColor,
                icon: this.useAnIcon === true ? this.icon : '',
                link: XSSHelpers.stripAllTags(this.link),
                enabled: +this.enabled
            }
        },
        isBuiltInCard() {
            return this.builtInIDs.includes(this.id)
        },
        linkNotSet() {
            return !this.isBuiltInCard && +this.enabled === 1 && this.link.indexOf('https://') !== 0;
        },
        linkAttentionStyle() {
            return this.linkNotSet ? 'border: 2px solid #c00000': '';
        }
    },
    methods: {
        getIconSrc(absolutePath = '') {
            const index = absolutePath.indexOf('dynicons\/');
            return this.libsPath + absolutePath.slice(index);
        },
        setIcon(event = {}) {
            const id = event.target.id;
            const index = id.indexOf('svg\/');
            if (index > -1) {
                this.icon = id.slice(index + 4);
            }
        },
        onSave() {
            this.updateMenuItemList(this.menuItemOBJ, this.markedForDeletion);
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
    template: `<div style="max-width: 600px;" id="design_card_modal">
        <h3>Card Preview</h3>
        <div class="designer_inputs" style="margin-bottom:1rem;">
            <custom-menu-item :menuItem="menuItemOBJ"></custom-menu-item>
            <div>
                <label for="bg_color">Background</label>
                <input type="color" id="bg_color" v-model="bgColor" />
            </div>
            <div style="display: flex; flex-direction:column; margin-left:1.5rem;">
                <label class="checkable leaf_check" for="button_enabled"
                     :style="{color: +enabled === 1 ? '#209060' : '#b00000'}"
                     :title="+enabled === 1 ? 'uncheck to hide' : 'check to enable'">
                    <input type="checkbox" id="button_enabled" v-model="enabled" class="icheck leaf_check"/>
                    <span class="leaf_check"></span>{{ +enabled === 1 ? 'enabled' : 'check to enable'}}
                </label>
                <label class="checkable leaf_check" for="button_delete"
                    :style="{color: +markedForDeletion === 1 ? '#b00000' : 'inherit'}">
                    <input type="checkbox" id="button_delete" v-model="markedForDeletion" class="icheck leaf_check" />
                    <span class="leaf_check"></span>{{ +markedForDeletion === 1 ? 'delete to confirm' : 'mark for deletion'}}
                </label>
            </div>
        </div>
        <div class="designer_inputs">
            <div>
                <label for="menu_title">Card Title</label>
                <textarea id="menu_title" v-model="title"></textarea>
            </div>
            <div>
                <label for="title_color">Font Color</label>
                <input type="color" id="title_color" v-model="titleColor" />
            </div>
        </div>
        <div class="designer_inputs">
            <div>
                <label for="menu_subtitle">Card Subtitle</label>
                <textarea id="menu_subtitle" v-model="subtitle"></textarea>
            </div>
            <div>
                <div v-show="!useTitleColor" style="margin-bottom: 0.5rem;">
                    <label for="subtitle_color" style="margin-right: 0.5rem;">Font Color</label>
                    <input type="color" id="subtitle_color" v-model="subtitleColor"/>
                </div>
                <label class="checkable leaf_check" for="title_color_confirm">
                    <input type="checkbox" id="title_color_confirm" v-model="useTitleColor" class="icheck leaf_check" />
                    <span class="leaf_check"></span>title color
                </label>
            </div>
        </div>
        <div v-if="!isBuiltInCard" style="margin-bottom: 1rem;">
            <label for="card_link">Card Link (full URL)</label>
            <input type="text" id="card_link" :style="'width: 475px;'+ linkAttentionStyle" v-model="link" />
        </div>
        <div class="designer_inputs">
            <label class="checkable leaf_check" for="use_icon_confirm">
                <input type="checkbox" id="use_icon_confirm" v-model="useAnIcon" class="icheck leaf_check" />
                <span class="leaf_check"></span>Use an Icon
            </label>
        </div>
        <fieldset v-if="useAnIcon" style="padding-right: 0;">
            <legend>Icon Selections</legend>
            <div class="designer_inputs wrap" style="height:150px; max-width: 560px; overflow:auto;" @click="setIcon($event)">
                <img v-for="icon in iconList" :key="icon.name"
                    :style="{width: iconPreviewSize, height: iconPreviewSize}" style="cursor: pointer;"
                    :id="icon.src" class="icon_choice"
                    :src="getIconSrc(icon.src)" :alt="icon.name" />
            </div>
        </fieldset>
    </div>`
}