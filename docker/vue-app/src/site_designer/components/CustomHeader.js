import { marked } from 'marked';
import MarkdownTable from './MarkdownTable';

export default {
    name: 'custom-header',
    data() {
        return {
            title: this.header?.title || '',
            titleColor: this.header?.titleColor || '#000000',
            imageFile: this.header?.imageFile || '',
            imageW: this.header?.imageW || 300,
            headerType: this.header?.headerType || 4,
            enabled: +this.header?.enabled === 1,

            imageFiles: [],
            headerTypes: [
                { value: 1, text: 'left of image area' },
                { value: 2, text: 'right of image area' },
                { value: 3, text: 'below image area' },
                { value: 4, text: 'above image area' },
                { value: 5, text: 'within image area' },
            ],
            maxImageWidth: 1400,
            minImageWidth: 0,
            showMarkdownTips: false
        }
    },
    created() {
        this.getImageFiles();
    },
    mounted() {
        console.log('custom header mounted')
    },
    components: {
        MarkdownTable
    },
    inject: [
        'updateHomeDesign',
        'appIsUpdating',
        'header',
        'truncateText',
        'openHistoryDialog',
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
        contentChanged() {
            let contentChanged = false;
            for (let k in this.headerOBJ) {
                if (this.header[k] !== this.headerOBJ[k]) {
                    contentChanged = true;
                    break;
                }
            }
            return contentChanged;
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
        markdownButtonTitle() {
            return this.showMarkdownTips ? 'Hide markdown tips' : 'Show markdown tips';
        },
        markedTitle() {
            return marked(this.title);
        },
        wrapperStyles() {
            return {
                flexDirection: this.headerWrapperFlex,
                marginBottom: this.isEditingMode ? '1rem' : '2rem'
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
    template: `<section id="custom_header">
        <!-- NOTE: HEADER DISPLAY -->
        <div id="header_display_wrapper" :style="wrapperStyles">
            <div v-show="headerType !== 5 && title !== ''" v-html="markedTitle" id="custom_header_outer_text" style="padding: 0;" :style="{color: titleColor}"></div>
            <div v-show="imageFile!==''" id="custom_header_image_container">
                <img :src="rootPath + 'files/' + imageFile" :style="{width: imageW + 'px'}" alt="custom header image" />
                <div v-show="headerType===5 && title!==''" v-html="markedTitle" id="custom_header_inner_text" :style="headerInnerTextStyles"></div>
            </div>
        </div>
        <!-- NOTE: HEADER EDITING -->
        <div v-show="isEditingMode" id="edit_header">
            <div class="design_control_heading">
                <h3>Header Controls</h3>
                <button type="button" id="custom_header_last_update" @click.prevent="openHistoryDialog"
                    style="display: none;">
                </button>
            </div>
            <div id="custom_header_inputs">
                <!-- MARKDOWN AREA -->
                <div id="custom_header_left">
                    <label for="header_title" style="position: relative;">Header Text
                        <span id="btn_markdown_tips" role="button" tabindex="0"
                            @click="showMarkdownTips=!showMarkdownTips" @keyup.enter="showMarkdownTips=!showMarkdownTips"
                            :title="markdownButtonTitle">ℹ <span style="color: #000000;">md</span>
                        </span>
                        <textarea id="header_title" v-model="title" rows="6"></textarea>
                    </label>
                </div>

                <!-- OTHER CONTROLS -->
                <div id="custom_header_right">
                    <label for="title_color">Font Color
                        <input type="color" id="title_color" v-model="titleColor" />
                    </label>
                    <label for="image_select">File Manager Image
                        <select id="image_select" style="width: 160px;" v-model="imageFile">
                            <option value="">none</option>
                            <option v-for="i in imageFiles" :value="i" :key="i">{{ truncateText(i) }}</option>
                        </select>
                    </label>
                    <label for="header_type_select" v-show="imageFile !==''">Text Position
                        <select id="header_type_select" style="width: 130px;" v-model.number="headerType">
                            <option v-for="t in headerTypes" :value="t.value" :key="'type_' + t.value">{{ t.text }}</option>
                        </select>
                    </label>
                    <label for="image_width" v-show="imageFile !==''">Image Width
                        <input id="image_width" type="number" min="0" :max="maxImageWidth" step=10 v-model.number="imageW"/>
                    </label>

                    <!-- HIDE/ENABLE SAVE -->
                    <div style="display: flex; gap: 1rem; margin: auto 0 0 auto;">
                        <label class="checkable leaf_check" for="header_enable"
                            style="margin: 0" :style="{color: +enabled === 1 ? '#008060' : '#b00000'}"
                            :title="+enabled === 1 ? 'uncheck to disable' : 'check to enable'">
                            <input type="checkbox" id="header_enable" v-model="enabled" class="icheck leaf_check"/>
                            <span class="leaf_check"></span>{{ +enabled === 1 ? 'enabled' : 'hidden'}}
                        </label>
                        <button type="button" class="btn-confirm" @click="updateHomeDesign('header', headerOBJ)"
                            :disabled="!contentChanged || appIsUpdating">
                            Save Changes
                        </button>
                    </div>
                </div> <!-- right side -->
            </div> <!-- controls -->
        </div>
        <MarkdownTable v-show="showMarkdownTips && isEditingMode" />
    </section>`
}