export default {
    name: 'design-header-dialog',
    data() {
        return {
            title: XSSHelpers.stripAllTags(this.header?.title || ''),
            titleColor: this.header?.titleColor || '#000000',
            subtitle: XSSHelpers.stripAllTags(this.header?.subtitle || ''),
            subtitleColor: this.header?.subtitleColor || '#000000',
            bgColor: this.header?.bgColor || '#ffffff',
            image: this.header?.image || '',
            enabled: +this.header?.enabled === 1,

            useTitleColor: this.header?.titleColor === this.header?.subtitleColor,
            markedForDeletion: false
        }
    },
    mounted() {
        this.setDialogSaveFunction(this.onSave);
        this.useTrumbowEditor();
    },
    inject: [
        'libsPath',
        'header',
        'updateHeader',
        'closeFormDialog',
        'setDialogSaveFunction',
        'setDialogButtonText'
    ],
    computed: {
        headerOBJ() {
            return {
                title: XSSHelpers.stripAllTags(this.title),
                titleColor: this.titleColor,
                subtitle: XSSHelpers.stripAllTags(this.subtitle),
                subtitleColor: this.useTitleColor ? this.titleColor : this.subtitleColor,
                bgColor: this.bgColor,
                image: this.image,
                enabled: +this.enabled
            }
        }
    },
    methods: {
        useTrumbowEditor() {
            $('#header_title_trumbowyg').trumbowyg({
                resetCss: false,
                btns: ['formatting', 'bold', 'italic', 'underline',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('.trumbowyg-box').css({
                'min-height': '60px',
                'height': 'auto',
                'max-width': '580px',
                'margin': '0 0.5rem 1rem 0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '60px',
                'height': 'auto',
                'padding': '0.5rem'
            });
        },
        updateTrumbowygText() {
            const elTrumbow = document.querySelector(`#header_title_trumbowyg.trumbowyg-editor`);
            if(elTrumbow !== undefined && elTrumbow !== null) {
                this.title = elTrumbow.innerHTML;
            }
        },
        getImageFiles(absolutePath = '') {
            console.log('TODO: get the images from the file manager')
        },
        uploadImageFile(file = '') {
            console.log('TODO: upload a png or jpg to the file manager')
        },
        setHeaderImage(event = {}) {
            const id = event.target.id;
            console.log(id);
        },
        onSave() {
            this.updateHeader(this.headerOBJ, this.markedForDeletion);
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
        <h3>Preview</h3>
        <!-- TODO: -->
        <div class="designer_inputs">
            <div v-html="title" class="custom_header" style="width: 100%; height: 60px;"
                :style="{backgroundColor: bgColor, color: titleColor}">
            </div>
        </div>
        <div class="designer_inputs" style="margin-bottom: 0.5rem;">
            <div style="width:165px;">
                <label for="bg_color">Background&nbsp;
                    <input type="color" id="bg_color" style="margin-left:auto;" v-model="bgColor" />
                </label>
                <label for="title_color">Text Color&nbsp;
                    <input type="color" id="title_color" style="margin-left:auto;" v-model="titleColor" />
                </label>
            </div>
            <div class="enable_del">
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
        <!-- NOTE: initial trumbow html content needs to use header injection (can't v-model) -->
        <label for="header_title_trumbowyg" id="header_title_trumbowyg_label">Header Text</label>
        <div id="header_title_trumbowyg" aria-labelledby="header_title_trumbowyg_label"
            @input="updateTrumbowygText" v-html="header.title">
        </div>
    </div>`
}