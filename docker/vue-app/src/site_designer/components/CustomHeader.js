export default {
    name: 'custom-header',
    data() {
        return {
            title: this.header?.title || '', //TODO: post, server tag method for rich html
            titleColor: this.header?.titleColor || '#000000',
            imageFile: this.header?.imageFile || '',
            imageW: this.header?.imageW || 300,
            headerType: this.header?.headerType || 4,
            enabled: +this.header?.enabled === 1,

            imageFiles: [],
            headerTypes: [
                { value: 1, text: 'text left' },
                { value: 2, text: 'text right' },
                { value: 3, text: 'text bottom' },
                { value: 4, text: 'text top' },
                { value: 5, text: 'text inside' },
            ]
        }
    },
    created() {
        this.getImageFiles();
    },
    mounted() {
        this.useTrumbowEditor();
    },
    inject: [
        'header',
        'updateHeader',
        'isEditingMode',
        'APIroot',
        'rootPath',
    ],
    computed: {
        headerOBJ() {
            return {
                title: XSSHelpers.stripAllTags(this.title),
                titleColor: this.titleColor,
                imageFile: this.imageFile,
                imageW: this.imageW,
                headerType: +this.headerType,

                enabled: +this.enabled,
            }
        },
        headerWrapperFlex() {
            let dir = 'row';
            switch(this.headerType) {
                case 2:
                    dir = 'row-reverse'
                    break;
                case 3:
                    dir = 'column-reverse'
                    break;
                case 4:
                    dir = 'column'
                    break;
                default:
                break
            }
            return dir;
        },
        headerOuterTextStyles() {
            return {
                padding: 0,
                color: this.titleColor,
                display: +this.headerType === 5 ? 'none' : 'block',
            }
        },
        headerInnerTextStyles() {
            //TODO: BG overlay calc based on text color
            return {
                position: 'absolute',
                top: '0',
                padding: '0.25em 0.5em',
                color: this.titleColor,
                display: +this.headerType !== 5 ? 'none' : 'block',
                backgroundColor: 'rgba(0,0,20,0.3)',
            }
        },
    },
    methods: {
        useTrumbowEditor() {
            $('#header_title_trumbowyg').trumbowyg({
                resetCss: false,
                btnsDef: {
                    formats: {
                        dropdown: ['p','h1','h2','h3','h4'],
                        ico:'p'
                    }
                },
                tagsToRemove: ['script', 'link'],
                btns: [['formats'], 'bold', 'italic', 'underline',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('.trumbowyg-box').css({
                'min-height': '60px',
                'height': 'auto',
                'max-width': '600px',
                'margin': '0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-width': '325px',
                'min-height': '60px',
                'height': 'auto',
                'padding': '0.5rem',
                'background-color': 'white',
            });
        },
        updateTrumbowygText() {
            const elTrumbow = document.querySelector(`#header_title_trumbowyg.trumbowyg-editor`);
            if(elTrumbow !== undefined && elTrumbow !== null) {
                this.title = elTrumbow.innerHTML;
            }
        },
        async getImageFiles() {
            const regImg = /\.(jpg|jpeg|svg|gif|png)$/i;
            try {
                const response = await fetch(this.APIroot + 'system/files');
                const files = await response.json();
                this.imageFiles = files.filter(filename => regImg.test(filename));
            } catch (error) {
                console.error(`Download error: ${error.message}`);
            }
        }
    },
    template: `<div id="design_custom_header">
        <!-- NOTE: HEADER EDITING -->
        <div v-show="isEditingMode" id="edit_header">
            <div>
                <label for="header_title_trumbowyg" id="header_title_trumbowyg_label">Header Text</label>
                <!-- can't use v-model for trumbowyg -->
                <div id="header_title_trumbowyg" aria-labelledby="header_title_trumbowyg_label"
                    @input="updateTrumbowygText" v-html="header.title">
                </div>
            </div>


            <div style="display: flex; gap: 1rem; flex-wrap: wrap; max-width: 500px;">
                <div style="width: 100%; display: flex; gap: 1rem; justify-content:space-between;">
                    <div>
                        <label for="title_color">Font Color</label>
                        <input type="color" id="title_color" v-model="titleColor" />
                    </div>
                    <div>
                        <label for="image_select">Image</label>
                        <select id="image_select" style="width: 100%; max-width: 180px;" v-model="imageFile">
                            <option value="">none</option>
                            <option v-for="i in imageFiles" :value="i">{{ i }}</option>
                        </select>
                    </div>
                    <div>
                        <label for="image_width">Image Width</label>
                        <input id="image_width" type="number" min="0" max="1800" step=10 v-model.number="imageW"/>
                    </div>
                    <div>
                        <label for="header_type_select">Layout Choices</label>
                        <select id="header_type_select" v-model.number="headerType">
                            <option v-for="t in headerTypes" :value="t.value">{{ t.text }}</option>
                        </select>
                    </div>
                </div>
                <div style="display: flex; gap: 1rem; margin: auto 0 0 auto;">
                    <label class="checkable leaf_check" for="header_enable"
                        style="margin: 0;" :style="{color: +enabled === 1 ? '#209060' : '#b00000'}"
                        :title="+enabled === 1 ? 'uncheck to hide' : 'check to enable'">
                        <input type="checkbox" id="header_enable" v-model="enabled" class="icheck leaf_check"/>
                        <span class="leaf_check"></span>{{ +enabled === 1 ? 'enabled' : 'check to enable'}}
                    </label>
                    <button type="button" class="btn-confirm" @click="updateHeader(headerOBJ)">
                        Save Header Settings
                    </button>
                </div>
            </div>
        </div>
        
        <!-- NOTE: HEADER DISPLAY -->
        <div id="custom_header_wrapper" :style="{flexDirection: headerWrapperFlex}">
            <div v-html="title" id="custom_header_outer_text" :style="headerOuterTextStyles"></div>
            <div id="custom_header_image_container">
                <img v-if="imageFile!==''" :src="rootPath + 'files/' + imageFile" :style="{width: imageW + 'px'}" />
                <div v-html="title" id="custom_header_inner_text" :style="headerInnerTextStyles"></div>
            </div>
        </div>
    </div>`
}