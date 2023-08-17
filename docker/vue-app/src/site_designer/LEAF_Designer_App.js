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
            allDesignData: null,
            designSettings: null,
            customizableTemplates: ['homepage'],
            views: ['homepage', 'testpage'], //NOTE: anticipate more templates, keeping for testing of page select
            currentView: 'homepage',

            currentDesignID: 0,
            appIsGettingData: true,
            appIsPublishing: false,
            isEditingMode: true,
            iconList: [],

            /* basic modal properties */
            dialogTitle: "",
            dialogFormContent: "",
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            formSaveFunction: '',
            showFormDialog: false
        }
    },
    provide() {
        return {
            iconList: computed(() => this.iconList),
            appIsGettingData: computed(() => this.appIsGettingData),
            isEditingMode: computed(() => this.isEditingMode),
            designSettings: computed(() => this.designSettings),
            currentViewDesigns: computed(() => this.currentViewDesigns),
            currentDesignID: computed(() => this.currentDesignID),
            selectedDesign: computed(() => this.selectedDesign),

            //static
            CSRFToken: this.CSRFToken,
            APIroot: this.APIroot,
            rootPath: this.rootPath,
            libsPath: this.libsPath,
            orgchartPath: this.orgchartPath,
            userID: this.userID,
            setCustom_page_select: this.setCustom_page_select,
            updateLocalDesignData: this.updateLocalDesignData,
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
            formSaveFunction: computed(() => this.formSaveFunction)
        }
    },
    created() {
        this.getIconList();
        this.getDesignData();
    },
    computed: {
        currentViewDesigns() {
            return (this.allDesignData || []).filter(d => d.templateName === this.currentView);
        },
        selectedDesign() {
            const selected = (this.currentViewDesigns|| []).find(d => d.designID === this.currentDesignID);
            return selected || null;
        },
        enabled() {
            return this.currentDesignID !== 0 && parseInt(this.designSettings?.[`${this.currentView}_enabled`] || 0) === this.currentDesignID;
        },
    },
    methods: {
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
        },
        setCustom_page_select(view = 'homepage') {
            this.currentView = view;
        },
        async getIconList() {
            try {
                const response = await fetch(`${this.APIroot}iconPicker/list`);
                const data = await response.json();
                this.iconList = data || [];
            } catch (error) {
                console.error(`error getting icons: ${error.message}`);
            }
        },
        async publishTemplate(designID = 0, templateName = '') {
            if(this.customizableTemplates.includes(templateName)) {
                this.appIsPublishing = true;

                try {
                    let formData = new FormData();
                    formData.append('CSRFToken', CSRFToken);
                    formData.append('designID', designID);
                    formData.append('templateName', templateName);

                    const response = await fetch(`${this.APIroot}design/publish`, {
                        method: 'POST',
                        body: formData
                    });
                    const data = await response.json();
                    if(+data?.status?.code === 2) {
                        this.designSettings[`${templateName}_enabled`] = designID;
                        console.log(data)
                    } else {
                        console.log('unexpected response returned:', data)
                    }

                } catch (error) {
                    console.log(error);
                } finally {
                    this.appIsPublishing = false;
                }
            } else {
                console.log('this page cannot be published');
            }
        },
        async getDesignData() {
            this.appIsGettingData = true;
            try {
                const settingResponse = await fetch(`${this.APIroot}system/settings`);
                const settings = await settingResponse.json();
                this.designSettings = {};
                this.customizableTemplates.forEach(t => {
                    this.designSettings[`${t}_enabled`] = settings[`${t}_enabled`] || 0;
                })

                const designResponse = await fetch(`${this.APIroot}design/designList`);
                this.allDesignData = await designResponse.json();

            } catch (error) {
                console.error(`error getting settings: ${error.message}`);
            } finally {
                this.appIsGettingData = false;
            }
        },
        /**
         * @param {number} designID of record to update
         * @param {string} json the new json value
         */
        updateLocalDesignData(designID = 0, json = '{}') {
            let record = this.allDesignData.find(rec => +rec.designID === +designID);
            record.designContent = json;

            let remainingDesigns = this.allDesignData.filter(rec => +rec.designID !== +designID);
            this.allDesignData = [...remainingDesigns, record];
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
        currentView(newVal, oldVal) {
            if(this.views.includes(newVal)) {
                this.$router.push({name: this.currentView});
                this.currentDesignID = 0;
            }
        }
    }
}