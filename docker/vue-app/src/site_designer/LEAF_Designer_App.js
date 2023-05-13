import { computed } from 'vue';

import './LEAF_Designer.scss';

export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            APIroot: APIroot,
            rootPath: '../',
            libsPath: libsPath,
            orgchartPath: orgchartPath,
            userID: userID,
            settingsData: {},
            settingsDataTest: settingsDataTest,
            customizableTemplates: ['homepage', 'search'], //NOTE: only homepage is actually a view, but they are sep tpls
            views: ['homepage', 'testview'],
            custom_page_select: 'homepage',
            isPostingUpdate: true,
            isEditingMode: true,
            publishedStatus: {
                homepage: null,
                search: null
            },
            iconList: [],
            tagsToRemove: ['script', 'img', 'a', 'link', 'br'],

            /* basic modal properties */
            dialogTitle: "",
            dialogFormContent: "",
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            formSaveFunction: '',
            showFormDialog: false,
        }
    },
    provide() {
        return {
            iconList: computed(() => this.iconList),
            isPostingUpdate: computed(() => this.isPostingUpdate),
            isEditingMode: computed(() => this.isEditingMode),
            publishedStatus: computed(() => this.publishedStatus),
            settingsData: computed(() => this.settingsData),

            //static
            CSRFToken: this.CSRFToken,
            APIroot: this.APIroot,
            rootPath: this.rootPath,
            libsPath: this.libsPath,
            orgchartPath: this.orgchartPath,
            userID: this.userID,
            getSettingsData: this.getSettingsData,
            tagsToRemove: this.tagsToRemove,
            setUpdating: this.setUpdating,
            postEnableTemplate: this.postEnableTemplate,
            /** dialog  */
            openDialog: this.openDialog,
            closeFormDialog: this.closeFormDialog,
            setDialogTitleHTML: this.setDialogTitleHTML,
            setDialogButtonText: this.setDialogButtonText,
            setDialogContent: this.setDialogContent,
            setDialogSaveFunction: this.setDialogSaveFunction,
            showFormDialog: computed(() => this.showFormDialog),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            formSaveFunction: computed(() => this.formSaveFunction),
        }
    },
    beforeMount() {
        this.getIconList();
        this.getSettingsData();
    },
    mounted() {
        this.$router.push({name: this.custom_page_select});
    },
    methods: {
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
        },
        setUpdating(updating = true) {
            this.isPostingUpdate = updating;
        },
        getIconList() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}iconPicker/list`,
                success: (res) => this.iconList = res || [],
                error: (err) => console.log(err)
            });
        },
        postEnableTemplate(templateName = '') {
            if(this.customizableTemplates.includes(templateName)) {
                const flag = +(!this.publishedStatus[templateName]);
                this.isPostingUpdate = true;
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}site/settings/enable_${templateName}`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        enabled: flag,
                    },
                    success: (res) => {
                        if (+res === 1) {
                            this.publishedStatus[templateName] = !this.publishedStatus[templateName];
                            this.isPostingUpdate = false;
                        }
                    },
                    error: (err) => console.log(err)
                });
            }
        },
        getSettingsData() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}system/settings`,
                success: (res) => {
                    this.settingsData = res;
                    this.publishedStatus.homepage = +res?.home_enabled === 1;
                    this.publishedStatus.search = +res?.search_enabled === 1;
                    this.setUpdating(false);
                },
                error: (err) => {
                    console.log(err);
                }
            });
        },

        /** basic modal methods.  Use a component name to set the dialog's content.
        /** Components must be registered to the component containing the dialog */
        openDialog() {
            this.showFormDialog = true;
        },
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.dialogFormContent = '';
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        setDialogTitleHTML(titleHTML = '') {
            this.dialogTitle = titleHTML;
        },
        setDialogButtonText({ confirm = '', cancel = '' } = {}) {
            this.dialogButtonText = { confirm, cancel };
        },
        setDialogContent(component = '') {
            this.dialogFormContent = component;
        },
        setDialogSaveFunction(func = '') {
            if (typeof func === 'function') {
                this.formSaveFunction = func;
            }
        },
    },
    watch: {
        custom_page_select(newVal, oldVal) {
            if(newVal !== '') {
                this.$router.push({name: this.custom_page_select});
            }
        }
    }
}