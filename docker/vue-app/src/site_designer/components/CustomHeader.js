import { marked } from 'marked';

export default {
    name: 'custom-header',
    data() {
        return {
            title: XSSHelpers.stripAllTags(this.header?.title || '').trim(),
            titleColor: this.header?.titleColor || '#000000',
            imageFile: this.header?.imageFile || '',
            imageW: this.header?.imageW || 300,
            headerType: this.header?.headerType || 1,
            enabled: +this.header?.enabled === 1,

            imageFiles: [],
            headerTypes: [
                { value: 1, text: 'left of image' },
                { value: 2, text: 'right of image' },
                { value: 3, text: 'below image' },
                { value: 4, text: 'above image' },
                { value: 5, text: 'over image' },
            ],
            maxImageWidth: 1400,
            minImageWidth: 0
        }
    },
    created() {
        this.getImageFiles();
    },
    mounted() {
        console.log('dom for header comp is ready')
    },
    inject: [
        'updateHomeDesign',
        'appIsGettingData',
        'appIsUpdating',
        'header',
        'currentDesignID',
        'isEditingMode',
        'APIroot',
        'rootPath'
    ],
    computed: {
        headerOBJ() {
            return {
                title: XSSHelpers.stripAllTags(this.title).trim(),
                titleColor: this.titleColor,
                imageFile: this.imageFile,
                imageW: +this.imageW,
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
        headerInnerTextStyles() {
            const hex = this.titleColor.slice(1);
            const codes = hex.match((/.{2}/ig));
            const overlay = codes.every(c => parseInt(`0x${c}`, 16) < 125) ? 'rgba(255,255,255,0.3)' : 'rgba(0,0,20,0.3)';
            return {
                color: this.titleColor,
                backgroundColor: `${overlay}`
            }
        },
        markedTitle() {
            return marked(this.title);
        },
        wrapperStyles() {
            return {
                flexDirection: this.headerWrapperFlex
            }
        }
    },
    methods: {
        async getImageFiles() {
            const regImg = /\.(jpg|jpeg|svg|gif|png)$/i;
            try {
                const response = await fetch(this.APIroot + 'system/files');
                const files = await response.json();
                this.imageFiles = files.filter(filename => regImg.test(filename));
            } catch (error) {
                console.error(`error getting files: ${error.message}`);
            }
        }
    },
    watch: {
        //refresh header data if selected design is changed
        currentDesignID() {
            this.title = XSSHelpers.stripAllTags(this.header?.title || '').trim();
            this.titleColor = this.header?.titleColor || '#000000';
            this.imageFile = this.header?.imageFile || '';
            this.imageW = this.header?.imageW || 300;
            this.headerType = this.header?.headerType || 1;
            this. enabled = +this.header?.enabled === 1;
        }
    },
    template: `<section v-if="!appIsGettingData" id="custom_header">
        <!-- NOTE: HEADER EDITING -->
        <div v-show="isEditingMode" id="edit_header">
            <h3>Header Controls</h3>
            <label for="header_title">Header Text
                <textarea id="header_title" v-model="title" rows="4"></textarea>
            </label>
            <div style="display: flex; gap: 1rem; justify-content: space-between;">
                <label for="title_color">Font Color
                    <input type="color" id="title_color" v-model="titleColor" />
                </label>
                <label for="image_select">Main Image
                    <select id="image_select" style="width: 160px;" v-model="imageFile">
                        <option value="">none</option>
                        <option v-for="i in imageFiles" :value="i" :key="i">{{ i }}</option>
                    </select>
                </label>
                <label for="header_type_select">Text Position
                    <select id="header_type_select" style="width: 120px;" v-model.number="headerType">
                        <option v-for="t in headerTypes" :value="t.value" :key="'type_' + t.value">{{ t.text }}</option>
                    </select>
                </label>
                <label for="image_width">Image Width
                    <input id="image_width" type="number" min="0" :max="maxImageWidth" step=10 v-model.number="imageW"/>
                </label>
            </div>
            <div style="width: 100%; display: flex; gap: 1rem; margin-top:0.5rem;">
                <label class="checkable leaf_check" for="header_enable"
                    style="margin: 0 0 0 auto;" :style="{color: +enabled === 1 ? '#008060' : '#b00000'}"
                    :title="+enabled === 1 ? 'uncheck to disable' : 'check to enable'">
                    <input type="checkbox" id="header_enable" v-model="enabled" class="icheck leaf_check"/>
                    <span class="leaf_check"></span>{{ +enabled === 1 ? 'enabled' : 'disabled'}}
                </label>
                <button type="button" class="btn-confirm" @click="updateHomeDesign('header', headerOBJ)" :disabled="appIsUpdating">
                    Save Settings
                </button>
            </div>
        </div>
        
        <!-- NOTE: HEADER DISPLAY -->
        <div id="custom_header_wrapper" :style="wrapperStyles">
            <div v-show="headerType !== 5 && title !== ''" v-html="markedTitle" id="custom_header_outer_text" style="padding: 0;" :style="{color: titleColor}"></div>
            <div v-show="imageFile!==''" id="custom_header_image_container">
                <img :src="rootPath + 'files/' + imageFile" :style="{width: imageW + 'px'}" alt="custom header image" />
                <div v-show="headerType===5 && title!==''" v-html="markedTitle" id="custom_header_inner_text" :style="headerInnerTextStyles"></div>
            </div>
        </div>
    </section>`
}