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
            customizableViews: ['homepage', 'testpage'], //each is a router view
            currentDesignID: null,

            appIsGettingData: true,
            appIsUpdating: false,
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
            appIsUpdating: computed(() => this.appIsUpdating),
            isEditingMode: computed(() => this.isEditingMode),
            currentViewEnabledDesignID: computed(() => this.currentViewEnabledDesignID),
            currentView: computed(() => this.currentView),
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
            publishTemplate: this.publishTemplate,
            newDesign: this.newDesign,
            postDesignContent: this.postDesignContent,
            generateID: this.generateID,

            openDesignCardDialog: this.openDesignCardDialog,

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
        currentView() {
            return this.$route.name;
        },
        currentViewDesigns() {
            let viewDesigns = (this.allDesignData || []).filter(d => d.templateName === this.currentView);
            return viewDesigns.sort((a,b) => a.designID - b.designID);
        },
        selectedDesign() {
            return (this.currentViewDesigns|| []).find(d => +d.designID === +this.currentDesignID) || null;
        },
        enabled() {
            return this.currentDesignID !== 0 && parseInt(this.designSettings?.[`${this.currentView}_enabled`] || 0) === this.currentDesignID;
        },
        currentViewEnabledDesignID() {
            return this.designSettings === null ? null : +this.designSettings[`${this.currentView}_enabled`];
        }
    },
    methods: {
        setView(event) {
            console.log(event.target.value);
            this.$router.push({ name: event.target.value });
        },
        generateID(arrList = [], keyName = 'id') {
            let result = '';
            do {
                const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                for (let i = 0; i < 5; i++ ) {
                   result += characters.charAt(Math.floor(Math.random() * characters.length));
                }
            } while (this.idExistsInList(arrList, keyName, result));
            return result;
        },
        idExistsInList(arrItems = [], keyName = 'id', ID = '') {
            return arrItems.some(i => i?.[keyName] === ID);
        },
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
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
        async postDesignContent(inputJSON = '{}') {
            this.appIsUpdating = true;
            try {
                let formData = new FormData();
                formData.append('CSRFToken', CSRFToken);
                formData.append('inputJSON', inputJSON);
                formData.append('templateName', this.currentView);

                const designID = this.currentDesignID;
                const response = await fetch(`${this.APIroot}design/${designID}/content`, {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                if(+data?.status?.code === 2) {
                    this.updateAppDesignData(designID, inputJSON);
                } else {
                    console.log('unexpected response returned:', data);
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.appIsUpdating = false;
            }
        },
        async publishTemplate(designID = 0, templateName = '', confirmed = false) {
            if(this.customizableViews.includes(templateName)) {
                if (confirmed === false) {
                    this.openConfirmPublishDialog();

                } else {
                    this.appIsUpdating = true;
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
                        } else {
                            console.log('unexpected response returned:', data);
                        }

                    } catch (error) {
                        console.log(error);
                    } finally {
                        this.appIsUpdating = false;
                    }
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
                this.customizableViews.forEach(t => {
                    this.designSettings[`${t}_enabled`] = +settings[`${t}_enabled`] || 0;
                })

                const designResponse = await fetch(`${this.APIroot}design/designList`);
                this.allDesignData = await designResponse.json();

            } catch (error) {
                console.error(`error getting settings: ${error.message}`);
            } finally {
                this.appIsGettingData = false;
            }
        },
        async newDesign(designName = '', designDescription = '') {
            this.appIsUpdating = true;
            try {
                let formData = new FormData();
                formData.append('CSRFToken', CSRFToken);
                formData.append('templateName', this.currentView);
                formData.append('designName', designName);
                formData.append('designDescription', designDescription);

                const response = await fetch(`${this.APIroot}design/new`, {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                if(+data?.status?.code === 2) {
                    console.log(data);
                } else {
                    console.log('unexpected response returned:', data);
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.appIsUpdating = false;
            }
        },
        /**
         * @param {number} designID of record to update
         * @param {string} json the new json value
         */
        updateAppDesignData(designID = 0, json = '{}') {
            let record = this.allDesignData.find(rec => +rec.designID === +designID);
            record.designContent = json;

            let remainingDesigns = this.allDesignData.filter(rec => +rec.designID !== +designID);
            this.allDesignData = [...remainingDesigns, record];
        },
        openNewDesignDialog() {
            this.setDialogTitleHTML(`<h2>Creating a new item for the ${this.currentView}</h2>`);
            this.setDialogContent('new-design-dialog');
            this.openDialog();
        },
        openConfirmPublishDialog() {
            this.setDialogTitleHTML('<h2>Please Confirm</h2>');
            this.dialogButtonText = { confirm: 'Confirm', cancel: 'Cancel'};
            this.setDialogContent('confirm-publish-dialog');
            this.openDialog();
        },
        openDesignCardDialog() {
            this.setDialogTitleHTML('<h2>Menu Editor</h2>');
            this.setDialogContent('design-card-dialog');
            this.openDialog();
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
        //if the view is changed, or on initial data retrieval, set the designID to the one published for the view or 0 if there isn't one
        currentView(newVal, oldVal) {
            if(this.customizableViews.includes(newVal)) {
                this.currentDesignID = this.currentViewEnabledDesignID || 0;
            }
        },
        designSettings(newVal, oldVal) {
            if(oldVal === null) {
                this.currentDesignID = this.currentViewEnabledDesignID || 0;
            }
        }
    }
}